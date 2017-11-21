// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Fade"
{
	Properties
	{
		_Fade 	("Fade", float) = 1.0
	}
	SubShader 
	{
		Tags { "RenderType"="Transparent" }
		Cull Off
		Blend DstAlpha SrcAlpha
		ZTest Less
		ZWrite On
		Lighting Off
		Fog {Mode Off}
	
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
		
			uniform float _Fade;			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
			};
			
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
				float4 vertex : SV_POSITION;
			};
			
			
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				return float4(0., 0., 0., 1.) * _Fade;
			}
			ENDCG
		}
	}
}

