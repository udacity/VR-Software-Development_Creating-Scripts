using UnityEngine;
using System.Collections;

public class Clouds
{
	const int MESH_RESOLUTION 				= 128;

	private static GameObject _gameObject 	= null;
	public static GameObject gameObject
	{
		get
		{
			if(_gameObject == null)
			{
				_gameObject 												= new GameObject();

				ProceduralMesh.Plane(MESH_RESOLUTION, _gameObject);

				_gameObject.GetComponent<MeshRenderer>().material.shader 	= Shader.Find("Clouds");
				_gameObject.name 											= "Clouds";
			}

			return _gameObject;
		}
	}
}
