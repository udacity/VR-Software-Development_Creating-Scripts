using UnityEngine;
using System.Collections;


public static class Framerate
{
	private static float _frames_per_second = 0.0f;
	private static float _prior_fps = 0.0f;
	private static float _delta = 0.0f;


	public static void Update()
	{
		_delta += (Time.deltaTime - _delta) * 0.1f;
		_frames_per_second = 1.0f / _delta;
		_frames_per_second = Mathf.Lerp(_frames_per_second, _prior_fps, 0.95f);
		_prior_fps = _frames_per_second;
	}


	public static float Milliseconds()
	{
		return _delta * 1000.0f;
	}


	public static float Fps()
	{
		return _frames_per_second;
	}
}
