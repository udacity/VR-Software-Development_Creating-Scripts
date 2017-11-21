Shader "Udacity/StandardUndistorted" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
#pragma surface surf Lambert vertex:vert
#pragma target 3.0

#pragma multi_compile __ CARDBOARD_DISTORTION   
#include "CardboardDistortion.cginc"

		sampler2D _MainTex;
	fixed4 _Color;

	struct Input {
		float2 uv_MainTex;
	};

	void vert(inout appdata_full v) {
		v.vertex = undistortSurface(v.vertex);
	}

	void surf(Input IN, inout SurfaceOutput o) {
		o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
	}
	ENDCG
	}
		FallBack "Diffuse"
}