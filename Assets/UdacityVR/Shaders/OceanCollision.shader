// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "OceanCollision"
{
	Properties
	{
		_Displacement		("Displacement", float)			= -.095
		_Translation		("Translation", float)			= 1.5
		_Derivative			("Derivative", float)			= .1
		_Velocity			("Velocity", Vector)			= (1.,1.,1.,1.)
		_Waves				("Waves", Vector)				= (-.74, .78, 1.14, -.71)
		_Scale				("Scale", Vector)				= (1., 1., 1., 1.)
		_Height				("Height", float)				= -.07
		_Curvature			("Curvature", float)			= 0.1
	}
	SubShader 
	{
		Pass
		{ 
			Name "FORWARD" 

			Cull Off
			ZTest Always
			Blend Off
			ZWrite Off
			Lighting Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#include "UnityCG.cginc"

			#define PI (4.*atan(1.))

			float4 		_Waves;	
			float4 		_Scale;	
			float4		_Velocity;

			float4 		_Position;	

			float 		_Height;	
			float 		_Curvature;
			float 		_Displacement;
			float 		_Translation;
			float 		_Derivative;


			struct appdata
			{
				float4 vertex			: SV_POSITION;
				float4 normal			: NORMAL;
				float4 position			: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex			: SV_POSITION;
				float4 normal			: NORMAL;
				float4 position			: TEXCOORD0;
			};

			float2 hash(float2 uv) 
			{	
				uv	+= sin(uv * 1234.5678);
				return frac(sin(uv + uv.x + uv.y) * 1234.5678);
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
				
				float time				= _Time.x * _Velocity.w;
				
				float waves_a			= voronoi(time * _Velocity.x + position.xz * _Waves.x) * _Scale.x;
				float waves_b			= voronoi(time * _Velocity.y + position.xz * _Waves.y) * _Scale.y;
				float waves_c			= cos(position.x * .125 + position.z * .25 + time * .75);
					
				float waves				= lerp(waves_a, waves_b, waves_c);
				
				return waves * _Scale.w;
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

			v2f vert (appdata v)
			{
				v2f o;

				float3 mesh_position	= _Position.xyz;

				float3 position			= float3(mesh_position.x, 0., mesh_position.z);

				float waves				= map(position);
				float curvature			= length(position.xz) * .2;

				float3 gradient			= derive_axis(position, _Derivative);
				
				float shift				=  -length(gradient) * _Translation;

				gradient.y				= abs(waves) * _Displacement + .00625;

				float3 normal			= normalize(gradient) * float3(-1., 1., -1.);

				v.vertex.y				= waves;
				v.vertex.y				+= curvature;
				v.vertex.y				-= 2.;
				
				v.vertex.xz				+= normal.xz * shift;

				o.vertex 				= UnityObjectToClipPos(v.vertex);

				o.position				= v.vertex;
				o.normal				= float4(normal, o.position.y);

				return o;
			}

			fixed4 frag (v2f i) : COLOR
			{
				return  i.normal;
			}
			ENDCG
		}
	}
}