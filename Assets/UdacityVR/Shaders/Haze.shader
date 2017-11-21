// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Haze"
{
	Properties
	{
		_Color 				("Color", Color) 				= ( .5,  .5,  .5,  .5)
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		
		Pass
		{ 
			Name "FORWARD" 

			Fog {Mode Off}

			Cull 		Off
			Colormask	A
			ZTest 		Lequal
			Blend 		Off
			ZWrite 		Off
			Lighting 	Off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#include "UnityCG.cginc"


			samplerCUBE _Cube;
			float4 		_Color;

			struct appdata
			{
				float4 vertex	: POSITION;
				float2 uv		: TEXCOORD0;
			};


			struct v2f
			{
				float2 uv				: TEXCOORD0;
				float4 vertex			: SV_POSITION;
			};


			//vertex function
			v2f vert (appdata v)
			{
				v2f o;
				
				o.uv					= v.vertex.xy;
				o.vertex 				= UnityObjectToClipPos(v.vertex);

				return o;
			}


			fixed4 frag (v2f i) : COLOR
			{
				float2 uv 			= 1.-abs(i.uv.xy);
				uv					= clamp(uv, 0., 1.);
				
				float4 result		= uv.y * _Color;
				
				return result;
			}
			ENDCG
		}
	}
}