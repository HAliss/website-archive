using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
public class TriggerShockwave : MonoBehaviour {
 
    public Material shockWaveMaterial;
 
    void Start() {
        shockWaveMaterial.SetFloat("_Radius", -0.2f);
    }
 
    void Update () {
        if (Input.GetButtonDown ("Fire1")) {
            Vector2 screenPos = new Vector2 (Input.mousePosition.x / Screen.width, Input.mousePosition.y / Screen.height);
            shockWaveMaterial.SetFloat ("_CenterX", screenPos.x);
            shockWaveMaterial.SetFloat ("_CenterY", screenPos.y);
            StopAllCoroutines();
            StartCoroutine(ShockWaveEffect());
        }
    }
 
    IEnumerator ShockWaveEffect () {
        float tParam = 0;
        float waveRadius;
        while (tParam < 1) {
            tParam += Time.deltaTime * 2;
            waveRadius = Mathf.Lerp(-0.2f, 2, tParam);
            shockWaveMaterial.SetFloat("_Radius", waveRadius);
            yield return null;
        }
    }
}
