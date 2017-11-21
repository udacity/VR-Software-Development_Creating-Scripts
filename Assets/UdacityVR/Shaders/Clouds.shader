// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Clouds"
{
	Properties
	{
		_SkyColor 			("Sky Color", Color) 			= ( .5,  .5,  .5,  .5)
		_WaterColor 		("Water Color", Color) 			= (.25, .25, .25, .25)
		_Haze	 			("Haze", float) 				= .01
		_Displacement		("Displacement", float)			= -.095
		_Translation		("Translation", float)			= 1.5
		_Derivative			("Derivative", float)			= .1
		_Velocity			("Velocity", Vector)			= (1.,1.,1.,1.)
		_Waves				("Waves", Vector)				= (-.74, .78, 1.14, -.71)
		_Scale				("Scale", Vector)				= (1., 1., 1., 1.)
		_Height				("Height", float)				= -.07
		_Curvature			("Curvature", float)			= 0.1
		_View_Direction		("View Direction", float)		= 0.
		_Light_Direction	("Light Direction", float)		= 0.
		_Half_Direction		("Half Direction", float)		= 0.
		_Normal				("Normal Direction", float)		= 0.
		_Tangent			("Tangent Direction", float)	= 0.
		_UV					("UV Direction", float) 		= 0.
		_Topography			("Topography", float) 			= 0.
		_Depth				("Depth", float)				= 0.
		_Light_Exposure		("Light Exposure", float)		= 0.
		_View_Exposure		("View Exposure", float)		= 0.
		_Half_Exposure		("Half Exposure", float)		= 0.
		_Fresnel			("Fresnel", float)				= 0.
		_Geometry			("Geometry", float)				= 0.
		_Distribution		("Distribution", float)			= 0.
		_BRDF				("BRDF", float)					= 0.

		_Result				("Result", float)				= 1.

		_Roughness			("Roughness", float)			= .5
		_Refractive_Index	("Refractive Index", float)		= .35
		
		_Resolution			("Resolution", float)			= 128.
	}
	SubShader 
	{
		Tags { "RenderType"="Transparent" }
		
		Pass
		{ 
			Name "FORWARD" 

			Cull Back
			ZTest LEqual
			Blend One OneMinusSrcAlpha
			ZWrite On
			Lighting On
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#include "UnityCG.cginc"

			#define PI (4.*atan(1.))


			float4 		_SkyColor;
			float4 		_WaterColor;

			float 		_Haze;

			float4 		_Waves;	
			float4 		_Scale;	
			float4		_Velocity;

			float 		_Height;	
			float 		_Curvature;
			float 		_Displacement;
			float 		_Translation;
			float 		_Derivative;

			float 		_Roughness;
			float 		_Refractive_Index;

			float 		_Depth;
			float 		_Topography;

			float 		_View_Direction;
			float 		_Light_Direction;
			float 		_Half_Direction;

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
			
			float 		_Result;
			float 		_Resolution;


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

			float2 hash(float2 uv) 
			{	
				uv	+= sin(uv.yx * 1234.5678);
				return frac(cos(sin(uv + uv.x + uv.y)) * 1234.5678);
			}

			float voronoi(float2 v)
			{
				float2 p = floor(v);
				float2 f = frac(v);
			
				float res = 0.0;
				for( int j=-1; j<=1; j++ )
				{
					for( int i=-1; i<=1; i++ )
					{
						float2 b	= float2( i, j );
						float2 r	= float2(b) - f + hash(p + b);
						float d		= dot(r, r);
			
						res			+= 1./pow(d, 8.);
					}
				}

				return pow(1./res, 1./16. );
			}

			float map(float3 position)
			{
				position.xz				*= 2.;
				position.xz 			+= float2(8., 12.);
				
				float t					= _Time.x * _Velocity.w;
				float waves_prior		= 0.;
				float waves 			= voronoi(position.xz * _Scale.x + float2(1., 4.) - t * _Velocity.x) *  .35 * _Waves.x;
				waves_prior				= waves + cos(waves*6.28+_Time.x*.1) * .1;
				waves					+= waves + voronoi(position.zx * _Scale.y + position.xz * 3.  -  waves + t * _Velocity.y) *  (.85 - waves * .5) * _Waves.y;
				float ripples			= cos(_Time.z * .2 + position.xz + waves*.15)*.12;
				waves					+= voronoi(position.xz * _Scale.z + ripples  + t * _Velocity.z) * (.126 - waves * .25) * _Waves.z;
				waves 					= (sin(waves_prior-waves) + 1.) * .0425 - .1;
				waves 					*= 1. - waves;

				return waves * _Waves.w;
			}


			float3 derive_axis(float3 position, float delta)
			{
				float3 derivative		= float3(0., 0., 0.);
				float2 offset			= float2(.0, delta);
			
				derivative.x		= map(position + offset.yxx) - map(position - offset.yxx);
				derivative.y		= map(position + offset.xyx) - map(position - offset.xyx);
				derivative.z		= map(position + offset.xxy) - map(position - offset.xxy);
				return derivative;
			} 


			float fresnel(const in float i, float ndv)
			{
				float f = (1.-ndv);
				f = f * f * f * f;
				return i + (1.-i) * f;
			}



			float geometry(in float r, in float ndl, in float ndv)
			{
				float k  = r * r / PI;
				float l = 1./ndl*(1.-k)+k;
				float v = 1./ndv*(1.-k)+k;

				return 1./(l * v + 1e-4f);
			}


			
			float distribution(const in float r, const in float ndh)
			{ 
				float alpha = r * r;
				float denom = ndh * ndh * (alpha - 1.) + 1.;
				return abs(alpha) / (PI * denom * denom);
			}


			v2f vert (appdata v)
			{
				v2f o;
				
				float roughness			= clamp(1.-_Roughness, 0., 1.);
				float index				= clamp(_Refractive_Index, 0., 1.);

				float3 position			= float3(v.uv.x - .5, 0., v.uv.y - .5);

				float waves				= map(position);
				float curvature			= length(position.xz) * _Curvature;

				float3 gradient			= derive_axis(position, _Derivative);
				
				float shift				=  -length(gradient) * _Translation;

				gradient.y				= abs(waves) * _Displacement + .00625;

				float3 normal			= normalize(gradient) * float3(-1., 1., -1.);

				v.vertex.y				= waves;
				v.vertex.y				+= curvature;
				v.vertex.y				-= _Height;
				v.vertex.xz				+= normal.xz * shift;

				o.vertex 				= UnityObjectToClipPos(v.vertex);

				float3 world_position	= mul(unity_ObjectToWorld, v.vertex).xyz;

				float3 view_position	= _WorldSpaceCameraPos.xyz;
				float3 view_direction	= normalize(view_position - world_position);
				
				
				float3 light_direction	= normalize(_WorldSpaceLightPos0.xyz);

				float3 half_direction	= normalize(view_direction + light_direction);

				float light_exposure	= max(dot(normal, light_direction), 0.);
				float view_exposure		= max(dot(normal,  view_direction), 0.);
				float half_exposure		= max(dot(normal,  half_direction), 0.);
				
				float f					= fresnel(roughness, view_exposure);
				float g					= geometry(roughness, light_exposure, view_exposure);
				float d					= distribution(index, half_exposure);
				float n					= fresnel(f, light_exposure);

				float brdf				= abs(g*d*f)/(view_exposure * light_exposure * 4. + .1);

				float depth				= length(view_position - world_position);// * _ScreenParams.w;

				float s					= geometry(.3, .125 * depth, view_exposure);

				float haze				= depth * _Haze;

				float3 light_color		= unity_LightColor[0].xyz;
				float3 sky_color		= _SkyColor.xyz;
				float3 water_color		= _WaterColor.xyz;

				if(_Result > 0.)
				{
					o.color					= unity_LightColor[0] * _SkyColor * _WaterColor;
					o.color.xyz				+= brdf * light_color;
					o.color.xyz				+= pow(abs(haze), 3.)*_Haze;
					
					o.color.w				= 1.;
				}
				else
				{
					o.color = float4(0.,0.,0.,0.);
				}
				o.uv.xy					= v.vertex.xz;
				o.position				= v.vertex;
				o.view_direction		= float4(view_direction, view_exposure);
				o.light_direction		= float4(light_direction, light_exposure);
				o.half_direction		= float4(half_direction, half_exposure);
				o.normal				= float4(normal, depth);
				o.tangent				= mul(unity_ObjectToWorld, v.tangent);
				o.light_terms			= float4(f, g, d, brdf);
			
				return o;
			}
			

			float2 project(float2 position, float2 a, float2 b)
			{
				float2 q	= b - a;	
				float u 	= dot(position - a, q)/dot(q, q);
				u 			= clamp(u, 0., 1.);
				return lerp(a, b, u);
			}
			
			float projection(float2 position, float2 a, float2 b)
			{
				return distance(position, project(position, a, b));
			}
			
			float contour(float x, float w)
			{
				return 1.-clamp(dot(x, w ), 0., 1.);
			}


			float segment(float2 position, float2 a, float2 b, float w)
			{
				return contour(projection(position, a, b), w);	
			}


			fixed4 frag (v2f i) : COLOR
			{
				float2 uv 			= i.uv.xy;
				float2 position 	= i.position.xz;
			
				float scale			= _Resolution;
			 	position			= frac(position * scale) - .5;

				float depth			= scale/(i.normal.w);
				float light			= 0.;
				float3 color		= float3(0., 0., 0.);
				
				float lines			= 0.;
				bool show_lines		= false;

				if(_View_Direction > 0.)
				{
					float2 start	= float2(0., 0.);
					float2 end		= normalize(i.view_direction.xz) * abs(1.-i.view_direction.y)*4.;
					lines			+= segment(position, start, end, depth);
					color 			+= i.view_direction.xyz * _View_Direction;
					show_lines 		= true;
				}

				if(_Light_Direction > 0.)
				{
					float2 start	= float2(0., 0.);
					float2 end		= normalize(i.light_direction.xz) * abs(1.-i.light_direction.y)*4.;
					lines			+= segment(position, start, end, depth);
					color 			+= i.light_direction.xyz * _Light_Direction;
					show_lines 		= true;
				}

				if(_Half_Direction > 0.)
				{
					float2 start	= float2(0., 0.);
					float2 end		= normalize(i.half_direction.xz) * abs(1.-i.half_direction.y)*4.;
					lines			+= segment(position, start, end, depth);
					color 			+= i.half_direction.xyz * _Half_Direction;
					show_lines 		= true;
				}

				if(_Normal > 0.)
				{
					float2 start	= float2(0., 0.);
					float2 end		= normalize(i.normal.xz) * abs(1.-i.normal.y)*4.;
					lines			+= segment(position, start, end, depth);
					color 			+= i.normal.xyz * _Normal;
					show_lines 		= true;
				}

				if(_Tangent > 0.)
				{
					float2 start	= float2(0., 0.);
					float2 end		= normalize(i.tangent.xz) * abs(1.-i.tangent.y)*4.;
					lines			+= segment(position, start, end, depth);
					color 			+= i.tangent.xyz * _Tangent;
					show_lines 		= true;
				}

				if(_UV > 0.)
				{
					color.xy 		+= i.uv.xy * _UV;
				}

				if(_Light_Exposure > 0.)
				{
					light += i.light_direction.w;
				}

				if(_View_Exposure > 0.)
				{
					light += i.view_direction.w;
				}

				if(_Half_Exposure > 0.)
				{
					light += i.half_direction.w;
				}

				if(_Fresnel > 0.)
				{
					light += i.light_terms.x;
				}

				if(_Geometry > 0.)
				{
					light += i.light_terms.y;
				}

				if(_Distribution > 0.)
				{
					light += i.light_terms.z;
				}

				if(_Depth > 0.)
				{
					light += depth * .125;
				}

				if(_BRDF > 0.)
				{
					light += i.light_terms.w;
				}

				if(_Topography > 0.)
				{
					lines += 1.-clamp(dot(abs(frac(i.position.y * _Topography * 256.)-.5), 64.), 0., 1.);
				}

				if(show_lines)
				{
					lines			= contour(length(position)-.0025, depth);
				}

			
				return float4(color,1.) + lines * clamp(.025 * depth, .1, 1.) + light + i.color * _Result;
			}
			ENDCG
		}
	}
}

//Shader "Clouds" 
//{
//	SubShader 
//	{
//		Pass 
//		{
//			Fog { Mode Off } 
//			Lighting On
//			ZTest Greater
//			ZWrite On
//			Cull Back
//			
//			//Blend SrcColor DstAlpha
//			
//			Offset 0, 0
//			GLSLPROGRAM
//
//			#include "UnityCG.glslinc"
//
//
//			#ifdef VERTEX
//
////			#define gl_TexCoord _glesTexCoord;
//			
////			varying highp vec4 _glesTexCoord[1];
////			uniform vec4 _Time;
////			uniform mat4x4 _Object2World;
////			uniform vec4 _WorldSpaceCameraPos;
////			uniform vec4 _WorldSpaceLightPos0;
//
//			#include "Includes/Maps/terrain.glslinc"
//
//
//			float map(vec3 position)
//			{
//				float bowl			= -length(position.xz*.5) * .52;
//				
//				vec2 wave_position	= position.xz;
//				position.xz			*= 3.;
//				position.xz 		+= vec2(8., 12.);
//				float t				= _Time.x * 8.;
//			
//				float waves 	=  voronoi(position.xz * 3.  + vec2(1., 4.) - t * .125) * .535;
//				waves			+= voronoi(position.xz * 4.  -        waves + t * .45)  * .85 - waves  * .5;
//				waves			+= voronoi(position.xz * 12. +        waves - t * .25) * .126 - waves * .5;
//				waves 			= (sin(waves)+1.)*.0425-.1;
//				waves 			*= (1.-waves);
//				waves			+= bowl;
//				return waves;
//			}
//
//
//			vec3 derive_axis(in vec3 position, in float delta)
//			{
//				vec3 derivative		= vec3(0.);
//				vec2 offset			= vec2(.0, delta);
//			
//				derivative.x		= map(position + offset.yxx) - map(position - offset.yxx);
//				derivative.y		= map(position + offset.xyx) - map(position - offset.xyx);
//				derivative.z		= map(position + offset.xxy) - map(position - offset.xxy);
//				return derivative;
//			} 
//
//
//			float fresnel(const in float i, const in float ndl)
//			{   
//				return i + (1.-i) * pow((1.-ndl), 5.0);
//			}
//
//			float distribution(const in float r, const in float ndh)
//			{ 
//				float alpha = r * r;
//				float denom = ndh * ndh * (alpha - 1.) + 1.;
//				return alpha / (3.14 * denom * denom);
//			}
//			
//			uniform vec4 _LightColor0; 
//			varying vec4 _FragCoord;
//			varying vec4 _Color;
//
//			void main()
//			{	
//				_FragCoord				= gl_MultiTexCoord0;
//				
//				vec3 position			= gl_MultiTexCoord0.xzy - .5;
//				position.y 				= 0.;
//
//				float waves				= map(position);
//
//				gl_Position				= gl_Vertex;//;
//				vec3 gradient			= derive_axis(position, .00625);
//				gradient.xz				*= -1.;
//				gradient.y				= waves * .0175;
//
//				gl_Position.xyz			-= gradient;
//
//				vec3 normal				= normalize(gradient);
//			
//				gl_Position.y			+= waves;
//
//				vec3 world_position		= (_Object2World * gl_Position).xyz;
//				gl_Position				= gl_ModelViewProjectionMatrix * gl_Position;
//				vec3 direction			= normalize(-_WorldSpaceCameraPos.xyz - world_position);
//				
//				vec3 light_position		= normalize(_WorldSpaceLightPos0.xyz)*8192.;
//
//				vec3 light_direction	= normalize(world_position - light_position);
//
//				vec3 half_direction		= normalize(light_direction + direction);
//
//				float ndl				= max(dot(normal, light_direction), 0.);
//				float ndh				= max(dot(normal,  half_direction), 0.);
//
//
//				float diffuse			= distribution( .8, max(ndl, 0.));
//				float specular			= distribution(.15, max(ndh, 0.));
//				float light_incidence	= max(fresnel(.125, ndh), 0.);
//				float view_incidence	= max(dot(normal, direction), -1.);
//				float depth				= length(world_position-_WorldSpaceCameraPos.xyz);
//				float haze				= -log(1./depth) * .54;
//
//
//				vec3 color				= vec3(.15, .3285,.5) * 1.6;
//				color					+= diffuse				* _LightColor0.xyz;
//				color					+= specular 			* .25;
//				color					+= light_incidence 		* .25;
//				color					+= (1.-view_incidence) 	* _LightColor0.xyz + depth*.01625;
//				color					+= diffuse * pow(max(view_incidence, .04), depth * 2.) + haze;
//				color					*= clamp(depth, 0., .2);
//				
//				float opacity			= 1.-(1.5 * depth * view_incidence)/depth;
//				opacity					+= depth * gl_Position.w * 128. + haze ;
//				opacity					-= light_incidence 	* .95;
//
//				_Color					= clamp(vec4(color, opacity), 0., 1.);
//			}
//			#endif
//
//			#ifdef FRAGMENT
//			varying vec4 	_FragCoord;
//			varying vec4 	_Color;
//
//			void main(void) 
//			{
//				gl_FragColor 	= _Color;
//			}//sphinx
//			#endif 
//			ENDGLSL 
//		} 
//	}
//}