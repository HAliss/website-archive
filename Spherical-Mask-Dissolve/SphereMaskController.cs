using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SphereMaskController : MonoBehaviour {

	public float radius = 0.5f;
	public float softness = 0.5f;

	void Update () {
		Shader.SetGlobalVector ("_GLOBALMaskPosition", transform.position);
		Shader.SetGlobalFloat ("_GLOBALMaskRadius", radius);
		Shader.SetGlobalFloat ("_GLOBALMaskSoftness", softness);
	}
}
