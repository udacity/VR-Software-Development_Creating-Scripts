using UnityEngine;
using System.Collections;

public class Seagull : MonoBehaviour 
{
	private const float AVERAGE_VELOCITY	= 0.5f;
	
	private static Vector3 ORIGIN			= new Vector3(0.0f, 0.0f, 0.0f);
	private const float RADIUS				= 10.0f;

	private Vector3	_position				= Vector3.zero;	
	private Vector3	_direction				= Vector3.zero;

	private  float	_velocity				= 0;
	private  float	_seed					= 0;
	private float _vertical_drift			= 0;


	void Start ()
	{
		_position			= gameObject.transform.position;
		_direction			= gameObject.transform.forward;

		_seed				= Mathf.Repeat(1234.5678f * Random.value * (_position.x + _position.y + _position.z), 1.0f);

		//set an initial random velocity and drift
		_velocity			= _seed * 0.5f + 0.125f;
		_vertical_drift		= (_seed - 0.5f) * 0.05f;
	}


	void FixedUpdate () 
	{
		 UpdatePosition();
	}


	private void UpdatePosition()
	{
		//find the direction and distance to the origin of the flock bounds
		Vector3 direction_to_origin		= Vector3.Normalize(ORIGIN - gameObject.transform.position);
		float distance_to_origin		= Vector3.Distance(ORIGIN, gameObject.transform.position) - RADIUS * 0.5f;
		
		
		//interpolate the values for the new direction by how far the gull is from the edges of the origin
		float interpolation			= _velocity/RADIUS;

		if(distance_to_origin < RADIUS)
		{
			//pick a random direction and go there if within the radius
			_direction	=  Vector3.Lerp(_direction, Random.insideUnitCircle, interpolation * 0.125f);
		}
		else
		{
			//else point back towards the origin
			_direction	=  Vector3.Lerp(_direction, direction_to_origin, interpolation);
		}
		
		
		//this points them along a course parallel to the ground, with each gull having a tendency to drift up or down as it goes
		_direction.y	= Mathf.Lerp(_direction.y + _vertical_drift, -0.01f, 1.0f/32.0f);


		//a random drift for the velocity
		float velocity_drift 	= 1.0f - Random.value * 0.0625f;


		//extra velocity if they are pointing down, less if they are going up
		float velocity_swoop	= -_direction.y * _velocity * 0.05f;


		//blend the velocity towards the average 
		_velocity				= Mathf.Lerp(_velocity * velocity_drift + velocity_swoop, AVERAGE_VELOCITY, 0.01f);


		//normalize the direction
		_direction				= Vector3.Normalize(_direction);


		//look towards where the gull is flying
		gameObject.transform.LookAt(gameObject.transform.position + _direction);


		//move the gull forward along that path
		gameObject.transform.position	= gameObject.transform.position + _direction * _velocity;

		//Debug.DrawRay(gameObject.transform.position, gameObject.transform.forward*2.0f);
	}

}
