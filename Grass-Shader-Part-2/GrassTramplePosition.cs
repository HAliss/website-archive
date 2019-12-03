using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GrassTramplePosition : MonoBehaviour {
    public Material material;
    public float radius;
    public float heightOffset;

    void Update() {
        material?.SetVector("_GrassTrample", new Vector4(transform.position.x, transform.position.y + heightOffset, transform.position.z, radius));
    }
}
