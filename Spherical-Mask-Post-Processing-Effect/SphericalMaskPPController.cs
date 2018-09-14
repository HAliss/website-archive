using System.Collections;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class SphericalMaskPPController : MonoBehaviour {

	public Material material;
	public Vector3 spherePosition;

	public float radius = 0.5f;
	public float softness = 0.5f;

	private Camera camera;
	void OnEnable () {
		camera = GetComponent<Camera> ();
		camera.depthTextureMode = DepthTextureMode.Depth;
	}

	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (material == null) return;
		var p = GL.GetGPUProjectionMatrix (camera.projectionMatrix, false);
		p[2, 3] = p[3, 2] = 0.0f;
		p[3, 3] = 1.0f;
		var clipToWorld = Matrix4x4.Inverse (p * camera.worldToCameraMatrix) * Matrix4x4.TRS (new Vector3 (0, 0, -p[2, 2]), Quaternion.identity, Vector3.one);
		material.SetMatrix ("_ClipToWorld", clipToWorld);
		material.SetVector ("_Position", spherePosition);
		material.SetFloat ("_Radius", radius);
		material.SetFloat ("_Softness", softness);
		Graphics.Blit (src, dest, material);
	}

}

#if UNITY_EDITOR
[CustomEditor (typeof (SphericalMaskPPController))]
public class SphericalMaskPPControllerEditor : Editor {
	private void OnSceneGUI () {
		SphericalMaskPPController controller = target as SphericalMaskPPController;
		Vector3 spherePosition = controller.spherePosition;
		EditorGUI.BeginChangeCheck ();
		spherePosition = Handles.DoPositionHandle (spherePosition, Quaternion.identity);
		if (EditorGUI.EndChangeCheck ()) {
			Undo.RecordObject (controller, "Move sphere pos");
			EditorUtility.SetDirty (controller);
			controller.spherePosition = spherePosition;
		}

		Handles.DrawWireDisc (controller.spherePosition, Vector3.up, controller.radius);
		Handles.DrawWireDisc (controller.spherePosition, Vector3.forward, controller.radius);
		Handles.DrawWireDisc (controller.spherePosition, Vector3.right, controller.radius);
	}
}
#endif
