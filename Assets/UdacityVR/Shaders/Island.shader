Shader "Island" 
{
	SubShader 
	{
		Pass 
		{
			Fog { Mode Off } 
			Lighting On
			ZTest Less
			ZWrite On
			Cull Back
			
			//Blend SrcColor DstAlpha
			
			Offset 0, 0
			GLSLPROGRAM

			#include "UnityCG.glslinc"


			#ifdef VERTEX
			uniform vec4 _LightColor0; 
			varying vec4 _FragCoord;
			varying vec4 _Color;


			void main()
			{	
				_FragCoord				= gl_MultiTexCoord0;
				gl_Position				= gl_Vertex-.5;
				
				
			}
			#endif

			#ifdef FRAGMENT
			varying vec4 	_FragCoord;
			varying vec4 	_Color;
			#include "Includes/Maps/terrain.glslinc"
			float map(vec3 position)
			{
				float bowl			= length(position.xz);

				float island		= island_map(position);
				
				return island;
			}


			vec3 derive_axis(in vec3 position, in float delta)
			{
				vec3 derivative		= vec3(0.);
				vec2 offset			= vec2(.0, delta);
			
				derivative.x		= map(position + offset.yxx) - map(position - offset.yxx);
				derivative.y		= map(position + offset.xyx) - map(position - offset.xyx);
				derivative.z		= map(position + offset.xxy) - map(position - offset.xxy);
				return derivative;
			} 

			void main(void) 
			{
				vec3 position			= _FragCoord.xzy - .5;
				position.y 				= 0.;

				float height			= map(position);

				vec3 gradient			= derive_axis(position, .00625);
				gradient.xz				*= -1.;
				gradient.y				= height * .0175;
				vec3 normal				= normalize(gradient);
				

				gl_FragColor 			= vec4(normal, height);
			}//sphinx
			#endif 
			ENDGLSL 
		} 
	}
}