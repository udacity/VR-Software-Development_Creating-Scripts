// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/CubemapDebug" {
    Properties {
        _Cube("Reflection Map", CUBE) = "" {}
    }

SubShader {
    Tags { "RenderType"="Opaque" }

    pass
    {     
        //Tags { "LightMode"="ForwardAdd"}

        CGPROGRAM

        #pragma target 3.0

        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

        sampler2D _DiffuseTexture;
        //half4 _Cube_HDR;
        //UNITY_DECLARE_TEXCUBE(unity_SpecCube0);
            //UNITY_DECLARE_TEXCUBE(_Cube);
        samplerCUBE _Cube;

        struct v2f{
            float4 pos : SV_POSITION;
            float3 coord: TEXCOORD0;
        };

            v2f vert(appdata_base v){
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.coord = v.normal;
      
                return o;
            }

            float4 frag(v2f i) : COLOR{
                float3 coords = normalize(i.coord);
                float4 finalColor = 1.0;
                float4 val = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, coords);
                finalColor.xyz = DecodeHDR(val, unity_SpecCube0_HDR);
                finalColor.w = 1.0;              
                return finalColor;
            }

            ENDCG
        }
    }
    FallBack Off
}