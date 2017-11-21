// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Waypoint"
{
	Properties
	{
		_Color 			("Color", Color) 		= ( 1., 1., 1., 1.)
	}
	SubShader 
	{
		Tags { "RenderType"="Transparent" }
		Cull Off
		
		Blend SrcAlpha DstAlpha 
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
			
			uniform float4 _Color;

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
				o.vertex	= UnityObjectToClipPos(v.vertex);
				o.color		= _Color;
				o.uv		= v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				return i.color;
			}
			ENDCG
		}
	}
}

