using UnityEngine;
using System.Collections;

public class Ocean
{
	private const int MESH_RESOLUTION 										= 100; //max 255 (256*256 is too many verts per mesh in unity)

	private static GameObject _gameObject 									= null;
	public static GameObject gameObject
	{
		get
		{
			if(_gameObject == null)
			{
				_gameObject 													= new GameObject();
				ProceduralMesh.Plane(MESH_RESOLUTION, _gameObject);
				_gameObject.transform.localScale								= Vector3.one * 16.0f;
				_gameObject.GetComponent<MeshRenderer>().material.shader 		= Shader.Find("Ocean");
				_gameObject.GetComponent<MeshRenderer>().shadowCastingMode		= UnityEngine.Rendering.ShadowCastingMode.Off;
				_gameObject.GetComponent<MeshRenderer>().receiveShadows			= false;
				_gameObject.GetComponent<MeshRenderer>().reflectionProbeUsage	= UnityEngine.Rendering.ReflectionProbeUsage.Simple;
				_gameObject.name 												= "Ocean";
			}

			return _gameObject;
		}
	}


	private const string AUDIO_RESOURCE_PATH								= "Sounds/Ocean_Waves-Mike_Koenig";
	private static GameObject _audio_object									= null;	
	private static AudioClip _audio_clip									= Resources.Load(AUDIO_RESOURCE_PATH, typeof(AudioClip)) as AudioClip;


	private static float _pitch												= 1.0f;
	private static AudioSource _audio_source								= null;
	public static AudioSource audio_source
	{
		get
		{
			if(_audio_source == null)
			{
				_audio_object												= new GameObject();
				_audio_object.name											= "Audio Source";
				_audio_object.transform.parent								= _gameObject.transform;
				_audio_object.transform.localScale							= Vector3.one;
				_audio_source												= _audio_object.AddComponent<AudioSource>();
				_audio_source.clip											= _audio_clip;
				_audio_source.playOnAwake									= true;
				_audio_source.loop											= true;
				_audio_source.spatialBlend									= 0.5f;
			}

			return _audio_source;
		}	
	}

	//random pitch flux 
	public static void AdjustPitch()
	{
		_pitch = Mathf.Lerp(_pitch, Random.value * 2.0f, 0.025f);
		_pitch = Mathf.Lerp(_pitch, 1.0f, .0125f);

		_audio_source.pitch = _pitch;
	}


	//position the sound at the edge of the island that the viewer is closest to 
	public static void SetSoundPositionRelativeToViewer()
	{
		Vector3 direction_to_shore							= Vector3.Normalize(-Camera.main.gameObject.transform.position);
		Vector3 position_of_sound 							= direction_to_shore * -256.0f;
		position_of_sound.y									= 1.0f;

		audio_source.gameObject.transform.position			= position_of_sound;
	
		Debug.DrawRay(Camera.main.transform.position, position_of_sound);
	}
}
