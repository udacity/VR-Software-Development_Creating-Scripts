// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "StormParticle"
{
	Properties
	{
		_Color	("Color", Color) 		= ( 1., 1., 1., 1.)
	}
	SubShader 
	{
		Tags { "RenderType"="Transparent" }
		Cull Back
		
		Blend One One 
		ZTest Less
		ZWrite Off
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
				o.uv		= v.uv * 2. - 1.;
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				float2 uv 		= i.uv.xy;
				
				float l			= clamp(2.-length(i.uv), 0., 1.);

				float4 result	= _Color;
				result.w		= 1.-l;

				return result;
			}
			ENDCG
		}
	}
}

