using UnityEngine;
using System.Collections;

//Texture Management and Procedural Texture Creation

public static class Textures
{
	public static void BlitShader(Texture2D texture, Shader shader)
	{
		RenderTexture renderTarget  = new RenderTexture(texture.width, texture.height, 0, RenderTextureFormat.ARGB32);
		renderTarget.anisoLevel 	= 0;
		renderTarget.filterMode		= FilterMode.Trilinear;
		renderTarget.Create();

		RenderTexture prior_target	= RenderTexture.active;
		
		RenderTexture.active		= renderTarget;
		Camera.main.targetTexture	= renderTarget;
		
		Graphics.Blit(renderTarget, new Material(shader));
		
		texture.ReadPixels(new Rect(0, 0, texture.width, texture.height), 0, 0);
		texture.Apply();

		RenderTexture.active 		= prior_target;
	 	Camera.main.targetTexture 	= prior_target;

		renderTarget.DiscardContents();
		renderTarget.Release();
	}
}