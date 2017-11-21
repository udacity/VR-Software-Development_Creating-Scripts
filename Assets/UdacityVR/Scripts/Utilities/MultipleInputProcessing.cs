using UnityEngine;
using System.Collections;

//this forces touch and vr gaze to play nice together when not in vr mode

//[RequireComponent(typeof(GazeInputModule))]
public class MultipleInputProcessing : MonoBehaviour 
{
	private UnityEngine.EventSystems.BaseInputModule[] _module;

	void Start()
	{
		_module = gameObject.GetComponents<UnityEngine.EventSystems.BaseInputModule>();
		
		for(int i = 0; i < _module.Length; i++)
		{
			if(_module[i].GetType().ToString() == "UnityEngine.EventSystems.StandaloneInputModule")
			{
				(_module[i] as UnityEngine.EventSystems.StandaloneInputModule).forceModuleActive = true;
			}
		}
	}


	void Update () 
	{
//		if(!GvrViewer.Instance.VRModeEnabled)
//		{
//			for(int i = 0; i < _module.Length; i++)
//			{
//				_module[i].Process();
//			}
//		}
	}
}
