// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "DebugVertex"
{
	Properties
	{
		[Header(Debug Options)]
		[Header((The lowest checkbox is active))]
		[MaterialToggle] 	_UV0("UV 0", Float)						= 0
		[MaterialToggle] 	_UV1("UV 1", Float)						= 0
		[MaterialToggle] 	_UV2("UV 2", Float)						= 0
		[MaterialToggle] 	_UV3("UV 3", Float)						= 0
		[MaterialToggle] 	_Normal("Normal", Float)				= 1
		[MaterialToggle] 	_Tangent("Tangent", Float)				= 0
		[MaterialToggle] 	_Color("Color", Float)					= 0
		[MaterialToggle] 	_Position("Position", Float)			= 0
		[MaterialToggle] 	_Texture("Texture", Float)				= 0		
		[MaterialToggle] 	_Lines("Grid", Float)					= 1
		[MaterialToggle] 	_X("X Lines", Float)					= 1
		[MaterialToggle] 	_Y("Y Lines", Float)					= 1
		[MaterialToggle] 	_Z("Z Lines", Float)					= 1
		_MainTex 			("Texture", 2D) 						= "white" {}
		_Resolution			("Grid Resolution", float)				= 1.
		_Weight				("Line Weight", Float)					= 32.
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
			Blend 		Off
			ZWrite 		On
			Lighting 	On


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _UV0;
			float _UV1;
			float _UV2;
			float _UV3;
			float _Tangent;
			float _Normal;
			float _Color;
			float _Position;
			float _Texture;
			float _Resolution;
			float _Weight;	
			float _Lines;
			float _X;
			float _Y;
			float _Z;

			struct appdata
			{
				float4 vertex	: POSITION;
				float3 normal	: NORMAL;
				float4 tangent	: TANGENT;
				float4 color	: COLOR;
				float2 uv0		: TEXCOORD0;
				float2 uv1		: TEXCOORD1;
				float2 uv2		: TEXCOORD2;
				float2 uv3		: TEXCOORD3;
			};


			struct v2f
			{
				float4 vertex	: SV_POSITION;
				float3 normal	: NORMAL;
				float3 tangent	: TANGENT;
				float4 color	: COLOR;
				float2 uv0		: TEXCOORD0;
				float2 uv1		: TEXCOORD1;
				float2 uv2		: TEXCOORD2;
				float2 uv3		: TEXCOORD3;
				float4 position	: TEXCOORD4;
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
				return 1.-clamp(dot(x, w), 0., 1.);
			}


			float line_segment(float2 position, float2 a, float2 b)
			{
				float l = contour(projection(position, a, b)/_Resolution, _Weight*(_Resolution*_Resolution));	
				return clamp(l, 0., 1.);
			}

			
			float grid(float2 position)
			{
				float width = 1.;
				float g 	= 0.;
				g 			+= line_segment(position.xy, float2(0., -1.), float2(0., 1.)) * _X;
				g 			+= line_segment(position.xy, float2(-1., 0.), float2(1., 0.)) * _Y;
				return g;
			}


			float grid(float3 position)
			{
				float g 	= 0.;
				g 			+= line_segment(position.xy, float2(0., -1.), float2(0., 1.)) * _X;
				g 			+= line_segment(position.yx, float2(0., -1.), float2(0., 1.)) * _Y;
				g 			+= line_segment(position.zy, float2(0., -1.), float2(0., 1.)) * _Z;
				
				return g;
			}


			//vertex function
			v2f vert (appdata v)
			{
				v2f o;
				
				
				o.vertex				= UnityObjectToClipPos(v.vertex);

				o.position.xyz			= mul(unity_ObjectToWorld, v.vertex.xyz);
				o.position.w 			= 1.;
				o.normal				= normalize(mul(unity_ObjectToWorld, v.normal));
				float3 pnormal			= float3(0., 0., 0.);

				o.tangent				= normalize(mul(unity_ObjectToWorld, v.tangent));
				o.color					= float4(0., 0., 0., 0.);
				
				o.uv0					= TRANSFORM_TEX(v.uv0, _MainTex);
				o.uv1					= v.uv1;
				o.uv2					= v.uv2;
				o.uv3					= v.uv3;

				return o;
			}


			//fragment (pixel) function
			fixed4 frag (v2f i) : COLOR
			{
				float3 position 	= frac(frac(i.position) * _Resolution)-.5;
				float lines			= 0.;
				float grid_lines	= 0.;
				float4 result		= float4(0., 0., 0., 0.);
			
				if(_UV0 > 0.)
				{
					lines			= grid(frac(i.uv0 * _Resolution * 4.) - .5);
					result.xy	 	= i.uv0.xy;
				}

				if(_UV1 > 0.)
				{
					lines			= grid(frac(i.uv1 * _Resolution * 4.) - .5);
					result.xy	 	= i.uv1.xy;
				}

				if(_UV2 > 0.)
				{
					lines			= grid(frac(i.uv2 * _Resolution * 4.) - .5);
					result.xy	 	= i.uv2.xy;
				}

				if(_UV3 > 0.)
				{
					lines			= grid(frac(i.uv3 * _Resolution * 4.) - .5);
					result.xy	 	= i.uv3.xy;
				}

				if(_Color > 0.)
				{
					result		 	= i.color;
				}

				if(_Position > 0.)
				{
					lines			= grid(position);
					result.xyz	 	= normalize(i.position.xyz)*.25+.5;
				}

				if(_Normal > 0.)
				{
					float g 	= 0.;
					float x		= line_segment(position.xx, float2(0., -1.), float2(0., 1.)) * _Z;					
					float y		= line_segment(position.yy, float2(0., -1.), float2(0., 1.)) * _Y;
					float z 	= line_segment(position.zz, float2(0., -1.), float2(0., 1.)) * _X;
				
					float3 n	= abs(i.normal*i.normal)*2.-.125;
					
					lines		= (x+z) * n.y + (x+y) * n.z + (y+z) * n.x;
					lines		= clamp(lines*lines-.45, 0., 1.);
					result.xyz	= i.normal;
				}

				if(_Tangent > 0.)
				{	
					result.xyz	 = i.tangent;
				}

				if(_Texture > 0.)
				{
					result			= tex2D(_MainTex, i.uv0);
				}
				
			
				lines *= _Lines ? 1. : 0.;
				result += lines;

				return result;
			}
			ENDCG
		}
	}
}