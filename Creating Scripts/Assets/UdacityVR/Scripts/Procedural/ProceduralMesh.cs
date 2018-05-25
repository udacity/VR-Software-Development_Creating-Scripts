using UnityEngine;
using System.Collections;


//Procedural Mesh Creation

public class ProceduralMesh
{
//	public static int gap		= 21;
//	public static int cutoff	= 512;
//
//	public static void Spiral(int resolution, GameObject gameObject)
//	{
//		// Build vertices and UVs
//		Vector2[] points 		= new Vector2[resolution];
//
//		float theta				= 3.0f;
//		float cos 				= Mathf.Cos(theta);
//		float sin				= Mathf.Sin(theta);
//		
//		float scale				= 1.001f;
//		float increment 		= 1.0f/points.Length/points.Length;		
//		points[0]	 			=  new Vector2(0.0f, 0.25f);
//		for (int i = 0 ; i < points.Length-1; i++)
//		{
//			points[i]		*= scale;
//			float x			= cos * points[i].x - sin * points[i].y;
//			float y 		= sin * points[i].x + cos * points[i].y;
//			points[i+1] 	= new Vector2(x, y);
//			scale 			-= increment;
//			
//		}
//		points[0] = Vector2.zero;
//
//		// Build triangle indices: 3 
//		int[] triangles		= new int[points.Length * 6];
//		for (int i = 0 ; i < points.Length; i++)
//		{
//			int ia 			= 0;
//			int ib 			= 0;
//			float minimum 	= float.MaxValue;
//
//			for(int j = 0; j < points.Length; j++)
//			{
//				if(i > j)
//				{
//					float distance			= Vector2.Distance(points[i], points[j]);
//					if(distance < minimum)
//					{	
//							ib 		= ia;
//							ia 		= j;
//							minimum = distance;
//					}
//				}
//			}
//
//			
//			if(i > cutoff)
//			{
//				int n = i - cutoff;
//				triangles[n * 6 + 0] = i;
//				triangles[n * 6 + 1] = ia;
//				triangles[n * 6 + 2] = ib;
//				triangles[n * 6 + 3] = ib;
//				triangles[n * 6 + 4] = ia+gap;
//				triangles[n * 6 + 5] = i;
//			}
//		}
//
//		for(int i = 0; i < triangles.Length; i++)
//		{
//			if(i < cutoff)
//			{
//				int n = i - cutoff;
//				triangles[i * 6 + 0] = i;
//				triangles[i * 6 + 1] = 0;
//				triangles[i * 6 + 2] = i+1;
//				triangles[i * 6 + 3] = i+2;
//				triangles[i * 6 + 4] = 0;
//				triangles[i * 6 + 5] = i+3;
//			}
//
//			triangles[i] = triangles[i] < 0 ? 0 : triangles[i];
//			triangles[i] = triangles[i] > points.Length-1 ? points.Length-1 : triangles[i];
//		}
//
//		
//		Vector3[] vertex 	= new Vector3[points.Length];		
//		for (int i = 0 ; i < vertex.Length; i++)
//		{	
//			vertex[i]			= new Vector3(points[i].x, 0.0f, points[i].y);
//		}
//
//		if(gameObject.GetComponent<MeshRenderer>() == null)
//		{
// 			gameObject.AddComponent<MeshRenderer>();
//		}
//	
//		if(gameObject.GetComponent<MeshFilter>() == null)
//		{
//			gameObject.AddComponent<MeshFilter>();
//		}
//
//		MeshRenderer meshRenderer		= gameObject.GetComponent<MeshRenderer>();
//		MeshFilter	meshFilter			= gameObject.GetComponent<MeshFilter>();
//
//		meshRenderer.receiveShadows		= false;
//		meshRenderer.shadowCastingMode	= UnityEngine.Rendering.ShadowCastingMode.Off;
//
//		if(meshRenderer.material == null)
//		{
//			meshRenderer.material 			= new Material(Shader.Find("Standard"));
//		}
//
//		if(meshFilter.mesh == null)
//		{
//				meshFilter.mesh = new Mesh();
//		}
////	
//		
//		meshFilter.mesh.vertices 			= vertex;
//		meshFilter.mesh.triangles			= triangles;
//		meshFilter.mesh.uv					= points;
// 		meshFilter.mesh.RecalculateNormals();
//		
//		meshFilter.mesh.name 				= "Spiral Mesh";
//	}

	public static void Plane(int resolution, GameObject gameObject)
	{
		gameObject.AddComponent<MeshRenderer>();
		gameObject.AddComponent<MeshFilter>();
		
		int y 					= 0;
		int x 					= 0;

		// Build vertices and UVs
		Vector3[] vertices 		= new Vector3[resolution * resolution];
		Vector2[] uvs 			= new Vector2[resolution * resolution];
		Vector4[] tangents 		= new Vector4[resolution * resolution];

		Vector2 uv_scale 		= new Vector2 (1.0f / (resolution - 1.0f),       1.0f / (resolution - 1.0f));
		Vector3 vertex_scale 	= new Vector3 (1.0f / (resolution - 1.0f), 1.0f, 1.0f / (resolution - 1.0f));

		Vector3 vertex_offset 	= new Vector3(0.5f, 0.0f, 0.5f);
		
		for (y = 0 ; y < resolution; y++)
		{
			for (x = 0; x < resolution ; x++)
			{
				Vector3 vertex 					= new Vector3 (x, 0.0f, y);
				Vector2 uv						= new Vector2 (x, y);
				
				if(x > 0 && x < resolution && y > 0 && y < resolution)
				{
					Vector2 jitter				= Random.insideUnitCircle * (1.0f - Mathf.Sqrt(2.0f) * 0.5f);
					vertex.x					+= jitter.x;
					vertex.z					+= jitter.y;
					uv							+= jitter;
				}

				vertices[y * resolution + x] 	= Vector3.Scale(vertex, vertex_scale) - vertex_offset;
				uvs[y * resolution + x] 		= Vector2.Scale(uv, uv_scale);
	
				Vector3 vertex_tangent			= new Vector3( x - 1.0f, 0.0f, y ) - new Vector3( x + 1.0f, 0.0f, y );

				Vector3 tan 					= Vector3.Scale(vertex_scale, vertex_tangent).normalized;

				tangents[y * resolution + x] 	= new Vector4( tan.x, tan.y, tan.z, -1.0f );
			}
		}
		
		// Build triangle indices: 3 
		//indices into vertex array for each triangle
		int[] triangles = new int[(resolution - 1) * (resolution - 1) * 6];
		int index = 0;
		for (y = 0; y < resolution - 1; y++)
		{
			for (x = 0; x < resolution - 1; x++)
			{
				// For each grid cell output two triangles
				triangles[index++] = (y     * resolution) + x;
				triangles[index++] = ((y+1) * resolution) + x;
				triangles[index++] = (y     * resolution) + x + 1;
	
				triangles[index++] = ((y+1) * resolution) + x;
				triangles[index++] = ((y+1) * resolution) + x + 1;
				triangles[index++] = (y     * resolution) + x + 1;
			}
		}
		
		if(gameObject.GetComponent<MeshRenderer>() == null)
		{
 			gameObject.AddComponent<MeshRenderer>();
		}
	
		if(gameObject.GetComponent<MeshFilter>() == null)
		{
			gameObject.AddComponent<MeshRenderer>();
		}

		MeshRenderer meshRenderer		= gameObject.GetComponent<MeshRenderer>();
		MeshFilter	meshFilter			= gameObject.GetComponent<MeshFilter>();
		
		if(meshRenderer.material == null)
		{
			meshRenderer.material 			= new Material(Shader.Find("Standard"));
		}

		if(meshFilter.mesh == null)
		{
				meshFilter.mesh = new Mesh();
		}
		
		//Assign the data to the mesh
		//_mesh					= new Mesh();
		 meshFilter.mesh.vertices 			= vertices;
		 meshFilter.mesh.uv 				= uvs;
		 meshFilter.mesh.triangles			= triangles;

		 meshFilter.mesh.name 				= "Procedural Mesh";

		// Auto-calculate vertex normals from the mesh
		 meshFilter.mesh.RecalculateNormals();

		// Assign tangents after recalculating normals
		 meshFilter.mesh.tangents 			= tangents;
	}

	public static void HeightMap(Texture2D heightmap, GameObject gameObject)
	{
		gameObject.AddComponent<MeshRenderer>();
		gameObject.AddComponent<MeshFilter>();
		
		int width				= heightmap.width;
		int height				= heightmap.height;
		int y 					= 0;
		int x 					= 0;

		// Build vertices and UVs
		Vector3[] vertices 		= new Vector3[height * width];
		Vector2[] uvs 			= new Vector2[height * width];
		Vector4[] tangents 		= new Vector4[height * width];

		Vector2 uv_scale 		= new Vector2 (1.0f / (width - 1.0f),       1.0f / (height - 1.0f));
		Vector3 vertex_scale 	= new Vector3 (1.0f / (width - 1.0f), 1.0f, 1.0f / (height - 1.0f));

		Vector3 vertex_offset 	= new Vector3(0.5f, 0.0f, 0.5f);
		
		for (y = 0 ; y < height; y++)
		{
			for (x = 0; x < width ; x++)
			{
				Vector4 pixel				= heightmap.GetPixel(x, y);
		
				Vector3 vertex 				= new Vector3 (x, pixel.w + (Random.value-0.5f)*0.00125f, y);
				Vector2 uv					= new Vector2 (x, y);
				
				if(x != 0 && y != 0 && x != width - 1 && y != height - 1)
				{
					vertex.x 				+= pixel.x - 0.5f;
					vertex.z 				+= pixel.y - 0.5f;
					
					uv.x	 				+= pixel.x - 0.5f;
					uv.y	 				+= pixel.x - 0.5f;
				}
 			
				vertices[y * width + x] 	= Vector3.Scale(vertex, vertex_scale) - vertex_offset;
				uvs[y * width + x] 			= Vector2.Scale(uv, uv_scale);
	
	
				Vector3 vertex_tangent		= new Vector3( x - 1.0f, heightmap.GetPixel(x-1, y).a, y ) - new Vector3( x + 1.0f, heightmap.GetPixel(x+1, y).a, y );

				Vector3 tan 				= Vector3.Scale(vertex_scale, vertex_tangent).normalized;

				tangents[y * width + x] 	= new Vector4( tan.x, tan.y, tan.z, -1.0f );
			}
		}
		
		// Build triangle indices: 3 
		//indices into vertex array for each triangle
		int[] triangles = new int[(height - 1) * (width - 1) * 6];
		int index = 0;
		for (y = 0; y < height - 1; y++)
		{
			for (x = 0; x < width - 1; x++)
			{
				// For each grid cell output two triangles
				triangles[index++] = (y     * width) + x;
				triangles[index++] = ((y+1) * width) + x;
				triangles[index++] = (y     * width) + x + 1;
	
				triangles[index++] = ((y+1) * width) + x;
				triangles[index++] = ((y+1) * width) + x + 1;
				triangles[index++] = (y     * width) + x + 1;
			}
		}
		
		if(gameObject.GetComponent<MeshRenderer>() == null)
		{
 			gameObject.AddComponent<MeshRenderer>();
		}
	
		if(gameObject.GetComponent<MeshFilter>() == null)
		{
			gameObject.AddComponent<MeshRenderer>();
		}

		MeshRenderer meshRenderer		= gameObject.GetComponent<MeshRenderer>();
		MeshFilter	meshFilter			= gameObject.GetComponent<MeshFilter>();
		
		if(meshRenderer.material == null)
		{
			meshRenderer.material 			= new Material(Shader.Find("Standard"));
		}

		if(meshFilter.mesh == null)
		{
				meshFilter.mesh = new Mesh();
		}
		
		//Assign the data to the mesh
		//_mesh					= new Mesh();
		 meshFilter.mesh.vertices 			= vertices;
		 meshFilter.mesh.uv 				= uvs;
		 meshFilter.mesh.triangles			= triangles;

		 meshFilter.mesh.name 				= "Procedural Mesh";

		// Auto-calculate vertex normals from the mesh
		 meshFilter.mesh.RecalculateNormals();

		// Assign tangents after recalculating normals
		 meshFilter.mesh.tangents 			= tangents;
	}


	public static void Circle(int resolution, GameObject gameObject)
	{
		gameObject.AddComponent<MeshRenderer>();
		gameObject.AddComponent<MeshFilter>();
		
		int y 					= 0;
		int x 					= 0;

		// Build vertices and UVs
		Vector3[] vertices 		= new Vector3[resolution * resolution];
		Vector2[] uvs 			= new Vector2[resolution * resolution];
		Vector4[] tangents 		= new Vector4[resolution * resolution];

		Vector2 uv_scale 		= new Vector2 (1.0f / (resolution - 1.0f),       1.0f / (resolution - 1.0f));
		Vector3 vertex_scale 	= new Vector3 (1.0f / (resolution - 1.0f), 1.0f, 1.0f / (resolution - 1.0f));

		Vector3 vertex_offset 	= new Vector3(0.5f, 0.0f, 0.5f);
		float radius 			= (float)resolution * 0.5f;
		Vector3 center			= new Vector3(radius, 0.0f, radius);
		float circle_vert_count = 0;
		for (y = 0 ; y < resolution; y++)
		{
			for (x = 0; x < resolution ; x++)
			{
				Vector3 vertex 					= new Vector3 (x, 0.0f, y);

				if(Vector3.Magnitude(vertex - center) > radius)
				{				
					vertices[y * resolution + x] 	= Vector3.zero;
					uvs[y * resolution + x] 		= Vector3.zero;
					tangents[y * resolution + x] 	= Vector3.zero;
				}
				else
				{
					Vector2 uv						= new Vector2 (x, y);
					
					if(x > 0 && x < resolution && y > 0 && y < resolution)
					{
						Vector2 jitter				= Random.insideUnitCircle * (1.0f - Mathf.Sqrt(2.0f) * 0.5f);
						vertex.x					+= jitter.x;
						vertex.z					+= jitter.y;
						uv							+= jitter;
					}
					
					vertices[y * resolution + x] 	= Vector3.Scale(vertex, vertex_scale) - vertex_offset;
					uvs[y * resolution + x] 		= Vector2.Scale(uv, uv_scale);
					
					Vector3 vertex_tangent			= new Vector3( x - 1.0f, 0.0f, y ) - new Vector3( x + 1.0f, 0.0f, y );
					
					Vector3 tan 					= Vector3.Scale(vertex_scale, vertex_tangent).normalized;
					
					tangents[y * resolution + x] 	= new Vector4( tan.x, tan.y, tan.z, -1.0f );

					circle_vert_count++;
				}
			}
		}

		// Build triangle indices: 3 
		//indices into vertex array for each triangle
		int[] triangles = new int[(resolution - 1) * (resolution - 1) * 6];
		int index = 0;
		for (y = 0; y < resolution - 1; y++)
		{
			for (x = 0; x < resolution - 1; x++)
			{
				// For each grid cell output two triangles
				triangles[index++] = (y     * resolution) + x;
				triangles[index++] = ((y+1) * resolution) + x;
				triangles[index++] = (y     * resolution) + x + 1;
	
				triangles[index++] = ((y+1) * resolution) + x;
				triangles[index++] = ((y+1) * resolution) + x + 1;
				triangles[index++] = (y     * resolution) + x + 1;
			}
		}
		
		if(gameObject.GetComponent<MeshRenderer>() == null)
		{
 			gameObject.AddComponent<MeshRenderer>();
		}
	
		if(gameObject.GetComponent<MeshFilter>() == null)
		{
			gameObject.AddComponent<MeshRenderer>();
		}

		MeshRenderer meshRenderer		= gameObject.GetComponent<MeshRenderer>();
		MeshFilter	meshFilter			= gameObject.GetComponent<MeshFilter>();
		
		if(meshRenderer.material == null)
		{
			meshRenderer.material 			= new Material(Shader.Find("Standard"));
		}

		if(meshFilter.mesh == null)
		{
				meshFilter.mesh = new Mesh();
		}
		
		//Assign the data to the mesh
		//_mesh					= new Mesh();
		 meshFilter.mesh.vertices 			= vertices;
		 meshFilter.mesh.uv 				= uvs;
		 meshFilter.mesh.triangles			= triangles;

		 meshFilter.mesh.name 				= "Procedural Mesh";

		// Auto-calculate vertex normals from the mesh
		 meshFilter.mesh.RecalculateNormals();

		// Assign tangents after recalculating normals
		 meshFilter.mesh.tangents 			= tangents;
	}

}
