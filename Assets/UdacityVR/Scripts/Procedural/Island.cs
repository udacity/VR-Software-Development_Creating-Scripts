using UnityEngine;
using System.Collections;

public static class Island
{
	const int TERRAIN_MESH_RESOLUTION 			= 32;
	const int OCEAN_MESH_RESOLUTION 			= 128;
	
	private static GameObject _ocean_object 	= null;

	private static GameObject _game_object 		= null;
	public static GameObject gameObject
	{
		get
		{
			if(_game_object == null)
			{
//				Texture2D normalmap = new Texture2D (512,512,  TextureFormat.ARGB32, true, false);
//				Textures.BlitShader(normalmap, Shader.Find("TerrainHeightNormals"));			
//				normalmap.Compress(true);
			
				Texture2D heightmap = new Texture2D ( TERRAIN_MESH_RESOLUTION, TERRAIN_MESH_RESOLUTION, TextureFormat.ARGB32, false, false);
				Textures.BlitShader(heightmap, Shader.Find("Island"));
			
//				Texture2D diffusemap = new Texture2D ( 1024, 1024, TextureFormat.ARGB32, false, false);
//				Textures.BlitShader(diffusemap, Shader.Find("TerrainHeightNormals"));
//				diffusemap.Compress(true);
			
				_game_object = new GameObject();
				ProceduralMesh.HeightMap(heightmap, _game_object);
				
			
				//terrain_object.GetComponent<MeshRenderer>().sharedMaterial.SetTexture("_MainTex", heightmap);
				//terrain_object.GetComponent<MeshRenderer>().sharedMaterial.SetTexture("_BumpMap", normalmap);
				_game_object.GetComponent<MeshRenderer>().sharedMaterial.SetColor("_Color", new Color(0.5f,0.45f,0.15f));
				_game_object.name = "Island";
				_game_object.transform.localScale							= Vector3.one * 32.0f;
				_game_object.transform.position								= new Vector3(0.0f, -3.0f, 0.0f);
			
				_ocean_object 												= new GameObject();
				ProceduralMesh.Plane(OCEAN_MESH_RESOLUTION, _ocean_object);
				_ocean_object.GetComponent<MeshRenderer>().material.shader 	= Shader.Find("OpenOcean");
				_ocean_object.transform.localScale							= new Vector3(64.0f, 27.0f, 64.0f);
				_ocean_object.transform.position							= new Vector3(0.0f, -1.7f, 0.0f);
				_ocean_object.name = "Ocean";
			}

			return _game_object;
		}
	}
}