using UnityEngine;

public class Cypher
{
	//A very simple one way cypher that transforms an input string into an equal length string consisting of random numbers and letters
	public static string Encode(string input, int salt)
	{
		string cypher		= null;
		
		char[]	character	= input.ToCharArray();
	
		for(int i = input.Length-1; i > 0; i--)
		{
			Random.InitState(((int)character[i] + salt) % 32768);
			
			float value		= Random.value * 3.0f;
			value 			= value < 1.0f ? value < 2.0f ? Random.Range(48.0f, 58.0f) : Random.Range(65.0f, 90.0f) : Random.Range(97.0f, 122.0f);
			
			cypher			+= ((char)(int)value).ToString();
			
			salt 			+= cypher.GetHashCode();
		}
	
		return cypher;
	}
}