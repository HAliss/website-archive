using UnityEngine;
 
[ExecuteInEditMode]
public class CustomImageEffect : MonoBehaviour {
 
    public Material material;
 
    void OnRenderImage(RenderTexture src, RenderTexture dest) {
        Graphics.Blit(src, dest, material);
    }
}
