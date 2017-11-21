// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "DebugProceduralVertex"
{
	Properties
	{
		[Header(Shading)]
		_SunColor 			("Sun Color", Color) 							= ( .5,  .5,  .5,  .5)
		_WaterColor 		("Water Color", Color) 							= (.25, .25, .25, .25)
		_Roughness			("Roughness", Range (0., 1.))					= .5
		_Refractive_Index	("Refractive Index", Range (0., 1.))			= .35
		_Reflection			("Cube Map Reflection", Range (0., 1.))			= .0
		_Haze	 			("Haze", Range (0., 1.)) 						= .01
		_Depth_Rays			("Depth Rays", Range (0., 2.)) 					= .01
		[Space]
		[Space]
		[Header(Procedural Geometry)]
		_Displacement		("Displacement", float)							= -.095
		_Translation		("Vertex Translation", float)					= 1.5
		_Noise				("Vertex Noise", float)							= 1.5
		_Derivative			("Partial Derivative Offset", float)			= .1
		_Velocity			("Wave Velocity", Vector)						= (1.,1.,1.,1.)
		_Frequency			("Wave Frequency", Vector)						= (-.74, .78, 1.14, -.71)
		_Scale				("WaveScale", Vector)							= (1., 1., 1., 1.)
		_Curvature			("Global Curvature", float)						= 0.1
		_Height				("Global Height Offset", float)					= -.07
		[Space]
		[Space]
		[Header(Debug Visualization)]
		[MaterialToggle] 	_Debug("Toggle Debug Lighting", Float)	= 0
		[Space]
		[Header(Lighting Components)]
		[MaterialToggle] 	_Light_Exposure("Light Exposure", Float)		= 0
		[MaterialToggle] 	_View_Exposure("View Exposure", Float)			= 0
		[MaterialToggle] 	_Half_Exposure("Half Exposure", Float)			= 0
		[MaterialToggle] 	_Fresnel("Fresnel", Float)						= 0
		[MaterialToggle] 	_Geometry("Geometry", Float)					= 0
		[MaterialToggle] 	_Distribution("Distribution", Float)			= 0
		[MaterialToggle] 	_BRDF("Combined BRDF", Float)					= 0
		_Brightness			("Brightness", Range (0., 1.)) 					= 1.
		[Space]
		[Header(Ocean Effects)]
		[MaterialToggle] 	_DepthRay("Depth Rays", Float)					= 0
		[MaterialToggle] 	_DistanceHaze("Haze", Float)					= 0
		[Space]
		[Space]
		[Header(Vector Field Lines)]
		[MaterialToggle] 	_View("View Direction", Float)					= 0
		[MaterialToggle] 	_Light("Light Direction", Float)				= 0
		[MaterialToggle] 	_Half("Half Direction", Float)					= 0
		[MaterialToggle] 	_Tangent("Tangent Direction", Float)			= 0
		[MaterialToggle] 	_Normal("Normal Direction", Float)				= 0
		[MaterialToggle] 	_UV("UV Direction", Float)						= 0
		[MaterialToggle] 	_Topography("Topography", Float)				= 0
		[MaterialToggle] 	_Depth("Depth", Float)							= 0
		_FieldBrightness	("Field Brightness", Range (0., 1.)) 			= 1.
		_Resolution			("Line Resolution", float)						= 128.
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{ 
			Name "FORWARD" 

			Fog 		{Mode Off}
			Cull 		Back
			ZTest 		Lequal
			Blend 		Off //transparency disabled
			ZWrite 		On
			Lighting 	On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#include "UnityCG.cginc"

			#define PI (4.*atan(1.))
			#define E	2.7182818

			float4 		_Frequency;	
			float4 		_Scale;	
			float4		_Velocity;
			float 		_Height;	
			float 		_Curvature;
			float 		_Displacement;
			float 		_Translation;
			float 		_Noise;
			float 		_Derivative;

			float 		_Roughness;
			float 		_Refractive_Index;
			float4 		_SunColor;
			float4 		_WaterColor;
			float 		_Haze;
			float 		_Reflection;
			float 		_Depth_Rays;
			float 		_DistanceHaze;
			float 		_Debug;

			float 		_Resolution;
			float 		_Depth;
			float 		_Topography;

			float 		_View;
			float 		_Brightness;
			float 		_Light;
			float 		_Half;
			float 		_Normal;
			float 		_Tangent;
			float 		_UV;	
			float 		_Light_Exposure;
			float 		_View_Exposure;
			float 		_Half_Exposure;
			float 		_Fresnel;
			float 		_Geometry;
			float 		_Distribution;
			float 		_BRDF;
			float		_DepthRay;
			float		_FieldBrightness;

			struct appdata
			{
				float4 vertex	: POSITION;
				float3 normal	: NORMAL;
				float4 color	: COLOR;
				float2 uv		: TEXCOORD0;
				float4 tangent	: TANGENT;
			};


			struct v2f
			{
				float2 uv				: TEXCOORD0;
				float4 color			: COLOR;
				float4 vertex			: SV_POSITION;
				float4 normal			: NORMAL;
				float4 view_direction	: TEXCOORD1;
				float4 light_direction	: TEXCOORD2;
				float4 half_direction	: TEXCOORD3;
				float4 tangent			: TEXCOORD4;
				float4 light_terms		: TEXCOORD5;
				float4 position			: TEXCOORD6;
			};


			//the projection of point a to b - the direct path is a line between the two at zero, and off angle paths are greater values
			float2 project(float2 position, float2 a, float2 b)
			{
				float2 q	= b - a;	
				float u 	= dot(position - a, q)/dot(q, q);
				u 			= clamp(u, 0., 1.);
				return lerp(a, b, u);
			}


			//distance to the projection
			float projection(float2 position, float2 a, float2 b)
			{
				return distance(position, project(position, a, b));
			}


			//creates a sharp contour on a distance field
			float contour(float x, float w)
			{
				return 1.-clamp(dot(x * 2., w), 0., 1.);
			}


			float line_segment(float2 position, float2 a, float2 b, float w)
			{
				return contour(projection(position, a, b), w);	
			}


			////procedural distance field map
			////these are the functions used to generate the procedural water shape and normals

			//random number generator
			float2 hash(float2 uv) 
			{	
				uv	+= sin(uv.yx * 1234.5678);
				return frac(cos(sin(uv + uv.x + uv.y)) * 1234.5678);
			}


			//voronoi noise
			float voronoi(float2 v)
			{
				float2 lattice 	= floor(v);
				float2 field 	= frac(v);
			
				float result = 0.0;
				for(float j = -1.; j <= 1.; j++)
				{
					for(float i = -1.; i <= 1.; i++)
					{
						float2 position	= float2(i, j);
						float2 weight	= position - field + hash(lattice + position);
						float smoothed	= dot(weight, weight) * .5 + .01;

						result			+= 1./pow(smoothed, 8.);
					}
				}
				return clamp(pow(1./result, 1./16.), 0.01, 1.);
			} 


			//2d rotation matrix
			float2x2 rmat(float theta)
			{
				float c = cos(theta);
				float s = sin(theta);
				return float2x2(c, s, -s, c);
			}


			//distance field function map (takes a point at position and returns its distance to the procedural landscape)
			float map(float3 position)
			{
				//shift to avoid mirroring along xy axis in the hash
				position.xz				+= float2(8., 5.);

				//time for animation
				float time				= _Time.x * _Velocity.w;
				float2 noise			= (lerp(hash(position.xz), hash(1.+position.xz), cos(_Time.x * _Velocity.y * 4.)*.5+.5) - .5)*.1;
				float wavesa 			= voronoi(7. + position.xz * _Frequency.x + time * _Velocity.x) * _Scale.x;

				position.xz				= mul(rmat(wavesa * - .005 + time*.0025), position.xz);

				float wavesb			= voronoi(noise + 5. - position.xz * _Frequency.y + time * _Velocity.y) * _Scale.y;
			
				float waves				= lerp(wavesa, wavesb, (cos(sin(_Time.x)*wavesa*wavesb)*.5+.5) * _Scale.z);

				return clamp(waves, -4., 4.) * _Scale.w;
			}

	
			//get the gradient of the distance field around the position (this tells you its slope and which way the surface normal faces)
			float3 map_gradient(float3 position, float delta)
			{
				float3 gradient	= float3(0., 0., 0.);
				float2 offset	= float2(.0, delta);
			
				gradient.x		= map(position + offset.yxx) - map(position - offset.yxx);
				gradient.y		= map(position + offset.xyx) - map(position - offset.xyx);
				gradient.z		= map(position + offset.xxy) - map(position - offset.xxy);

				return gradient;
			} 


			////lights
			////these are the component terms of the "physically based microfacet bi-directional reflectance distribution function" (PBMFBRDF) (hah!)
			
			//fresnel lighting term (how light scattered at grazing angles due to the material properties)
			float fresnel(const in float i, float ndv)
			{
				float f = (1.-ndv);
				f = f * f * f * f;
				return i + (1.-i) * f;
			}


			//geometry lighting term (how shadowed the surface becomes at grazing angle due to having a rough surface)
			float geometry(in float r, in float ndl, in float ndv)
			{
				float k  = r * r / PI;
				float l = 1./ndl*(1.-k)+k;
				float v = 1./ndv*(1.-k)+k;
				return 1./(l * v + 1e-4f);
			}

			


			//lighting distrobution term (how focused the light bounce is)
			float distribution(const in float r, const in float ndh)
			{ 
				float alpha = r * r;
				float denom = ndh * ndh * (alpha - 1.) + 1.;
				return abs(alpha) / (PI * denom * denom);
			}


			//exponental fog
			float fog(float depth, float density)
			{	
				return 1./pow(E, depth * density);
			}


			//depth rays effect (h4x!)
			float depth_rays(float3 world_position, float3 view_position, float3 light_direction, float3 normal, float depth) 
			{
				float3 light_position	= cross(_WorldSpaceLightPos0.zyx * float3(-1., -1., 1.), float3(0., 1., 0.));
				
				float2 light_xz			= light_position.xz;
				light_xz				*= depth + depth  - normal.xz;
				
				float2 ray_start		= light_xz + normal.xz - normal.xz * 16.;
				float2 ray_end			= -light_xz-normal.xz/(depth);

				float rays				= clamp(1.-projection(world_position.xz-view_position.xz, ray_start, ray_end)-depth*.125, 0., 1.);
				
				return rays;
			}


			//vertex function
			v2f vert (appdata v)
			{
				v2f o;
				//generate procedural geometry and normals
				float3 position			= v.vertex.xyz;
				float waves				= map(position);
				float curvature			= length(position.xz) * _Curvature;
				float3 gradient			= map_gradient(position, _Derivative);
				float2 noise			= (lerp(hash(v.uv.xy), hash(1.+v.uv.xy), cos(_Time.x * _Velocity.z)*.5+.5) - .5) * _Noise;
				float translation		= length(gradient) * _Translation;
				
				gradient.y				= abs(waves) * _Displacement + .00625;
				
				float3 normal			= normalize(gradient * float3(-1., 1., -1.));
				
				float cutoff			= length(v.vertex.xz) > .495 ? 0.2 : 1.;

				float displacement 		= waves;
				displacement			+= curvature;
				displacement			*= cutoff;
				displacement			+= _Height;

				//transform vertex position
				v.vertex.y				+= displacement + length(noise) * (.5-normal.y);
				v.vertex.xz				+= normal.xz * translation + noise * normal.y;
				
				o.vertex 				= UnityObjectToClipPos(v.vertex);


				//lighting
				float roughness			= clamp(1.-_Roughness, 0., 1.);
				float index				= clamp(_Refractive_Index, 0., 1.);

				float3 world_position	= mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 view_position	= _WorldSpaceCameraPos.xyz;
				float3 view_direction	= normalize(view_position - world_position);
				float3 light_direction	= -normalize(_WorldSpaceCameraPos.xyz-_WorldSpaceLightPos0.xyz*512.);
				float3 half_direction	= normalize(view_direction + light_direction);

				float light_exposure	= max(dot(normal, light_direction), 0.);
				float view_exposure		= max(dot(normal,  view_direction), 0.);
				float half_exposure		= max(dot(normal,  half_direction), 0.);
				
				float f					= fresnel(roughness, view_exposure);
				float n					= fresnel(f, light_exposure);
				light_exposure			*= n;
				float g					= geometry(roughness, light_exposure, view_exposure);
				float d					= distribution(index, half_exposure);
				
				float brdf				= abs(g*d*f)/(view_exposure * light_exposure * 4. + .1);

				float depth				= length(view_position - world_position);

				float density			= _Haze;
				float haze				= fog(depth, density);
				haze					= clamp(f-haze, 0., 1.);
				
				float3 light_color		= unity_LightColor[0].xyz;
				
				float surface_scatter	= clamp(waves * waves * 32. * 64., 0., 1.) * clamp(light_color/depth, 0., 1.);
			
				float rays				= depth_rays(world_position, view_position, light_direction, normal, depth);
				rays					*= _Depth_Rays;

				//composite the light into an output color
				o.color					= float4(0., 0., 0., 0.);
				o.color.xyz				= _WaterColor.xyz * light_exposure * _WaterColor;
				o.color.xyz				+= (1.-light_exposure) * surface_scatter * brdf;
				o.color.xyz				+= rays * surface_scatter * _WaterColor.xyz;
				o.color.xyz				+= brdf * light_color * _SunColor.xyz;
				o.color.xyz				+= haze;
//				o.color.xyz				*= 0.; o.color.xyz				+= rays;
				o.color.a				= f;
				
				//debug visualization output
				o.uv.xy					= v.uv.xy;
				o.position				= v.vertex;
				o.position.w			= haze;
				o.view_direction		= float4(view_direction, view_exposure);
				o.light_direction		= float4(light_direction, light_exposure);
				o.half_direction		= float4(half_direction, half_exposure);
				o.normal				= float4(normal, depth);
				o.tangent				= float4(cross(normal, float3(0., 1., 0.)), rays);
				o.light_terms			= float4(f, g, d, brdf);
			
				return o;
			}


			//fragment (pixel) function
			fixed4 frag (v2f i) : COLOR
			{
				float2 uv 			= i.uv.xy;
			
				float depth			= i.normal.w / _ZBufferParams.w;
			
				float scale			= _Resolution;	
				float2 position 	= i.position.xz;
			 	position			= frac(position * scale) - .5;
				
				float lines			= 0.;
				float line_scale	= 16. - .125 * i.normal.w;
				bool lines_enabled	= false;

				float light			= 0.;
				
				float3 debug_color	= (contour(abs(position.x), 16.) + contour(abs(position.y), 16.)) * .125;

				//all of these are to mix in the debug results based on the sliders
				if(_View > 0.)
				{
					float2 start	= float2(0., 0.);
					float2 end		= normalize(i.view_direction.xz) * abs(1.-i.view_direction.y);
					lines			+= line_segment(position, start, end, line_scale);
					lines_enabled	= true;
					debug_color 	= i.view_direction.xyz;
				}

				if(_Light > 0.)
				{
					float2 start	= float2(0., 0.);
					float2 end		= normalize(i.light_direction.xz) * abs(1.-i.light_direction.y) ;
					lines			+= line_segment(position, start, end, line_scale);
					lines_enabled	= true;
					debug_color 	= i.light_direction.xyz;
				}

				if(_Half > 0.)
				{
					float2 start	= float2(0., 0.);
					float2 end		= normalize(i.half_direction.xz) * abs(1.-i.half_direction.y);
					lines			+= line_segment(position, start, end, line_scale);
					lines_enabled	= true;
					debug_color 	= i.half_direction.xyz;
				}

				if(_Tangent > 0.)
				{
					float2 start	= float2(0., 0.);
					float2 end		= normalize(i.tangent.xz) * abs(1.-i.tangent.y);
					lines			+= line_segment(position, start, end, line_scale);
					lines_enabled	= true;
					debug_color 	= i.tangent.xyz * _Tangent;
				}

				if(_Normal > 0.)
				{
					float2 start	= float2(0., 0.);
					float2 end		= normalize(i.normal.xz);
					lines			+= line_segment(position, start, end, line_scale);
					lines_enabled	= true;
					debug_color 	= i.normal.xyz * _Normal;
				}

				if(_UV > 0.)
				{
					float2 start	= float2(0., 0.);
					float2 end		= normalize(i.uv);
					lines			+= line_segment(position, start, end, line_scale);
					lines_enabled	= true;
					debug_color.xy 	= i.uv.xy;
				}

				if(_Depth > 0.)
				{
					lines += 1.-clamp(dot(abs(frac(depth * 8.)-.5), 64.), 0., 1.);
				}

				if(_Topography > 0.)
				{
					float t = frac(i.position.y * _Topography * 256.);
					t		= abs(t - .5);
					t 		= dot(t, 64. * i.view_direction.w);

					lines += 1.-clamp(t, 0., 1.);
				}

				lines += lines_enabled ? contour(length(position), line_scale) : 0.;

				if(_Debug > 0.)
				{
					if(_Light_Exposure > 0.)
					{
						light = i.light_direction.w * _Light_Exposure;
					}
	
					if(_View_Exposure > 0.)
					{
						light = i.view_direction.w * _View_Exposure;
					}
	
					if(_Half_Exposure > 0.)
					{
						light = i.half_direction.w * _Half_Exposure;
					}
	
					if(_Fresnel > 0.)
					{
						light = i.light_terms.x;
					}
	
					if(_Geometry > 0.)
					{
						light = i.light_terms.y;
					}
	
					if(_Distribution > 0.)
					{
						light = i.light_terms.z;
					}
	
					if(_BRDF > 0.)
					{
						light = i.light_terms.w;
					}

					if(_DepthRay > 0.)
					{
						light = i.tangent.w;
					}

					if(_DistanceHaze > 0.)
					{
						light = i.position.w;
					}

					light *= _Brightness;
				}

				debug_color	*= _FieldBrightness;


				//this samples the built in reflection cubemap from unity - in true brdf the roughness would be added here, I'm cheating
				float4 shading			= i.color;
				if(_Reflection > 0.)
				{
					float3 n			= i.normal.xyz;
					float3 v			= i.view_direction.xyz;
float4 reflectionb	= UNITY_SAMPLE_TEXCUBE(unity_SpecCube1, reflect(v, n));
					reflectionb.xyz		= DecodeHDR(reflectionb, unity_SpecCube1_HDR);
					
					v.y					+= map((i.normal * _Frequency.z + i.position.xyz) + _Time.x) * _Frequency.w;
					float4 reflectiona	= UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,  reflect(-v, n));
					reflectiona.xyz		= DecodeHDR(reflectiona, unity_SpecCube0_HDR);
					

					
					float4 reflection	= lerp(reflectionb, reflectiona, .25 + i.color.w * .25);
					shading				+= reflection * _Reflection;
				}

				float4 result			= float4(0., 0., 0., 0.);
				result.xyz				+= debug_color * _Debug;
				result					+= light;
				result 					+= lines;

				result					= max(0., result);
				
				result					+= shading *(1.-_Debug);

				return result;
			}
			ENDCG
		}
	}
}