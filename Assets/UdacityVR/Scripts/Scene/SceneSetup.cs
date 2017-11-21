using UnityEngine;
using System.Collections;

public class SceneSetup : MonoBehaviour {
    public Material ocean_material;

    void Start() {
        Ocean.gameObject.SetActive(true);
        Ocean.gameObject.transform.position = new Vector3(0.0f, -1.7f, 0.0f);
        Ocean.gameObject.transform.localScale = Vector3.one * 64.0f;

        Ocean.gameObject.GetComponent<MeshRenderer>().material = ocean_material;

        Ocean.audio_source.volume = 0.125f;
        Ocean.audio_source.Play();
    }


    void Update() {
        Ocean.AdjustPitch();
        Ocean.SetSoundPositionRelativeToViewer();
        Framerate.Update();
    }


    void OnGUI() {
        GUI.skin.label.normal.textColor = Color.white;
        GUI.Label(new Rect(16.0f, 0.0f, 128.0f, 24.0f), Framerate.Fps().ToString());
    }
}