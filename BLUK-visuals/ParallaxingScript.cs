public class ParallaxingScript : MonoBehaviour {
  
    private Vector3 prevPos;
  
    void Start() {
        prevPos = transform.position;
    }
  
    void Update () {
        Vector3 curPos = transform.position;
        if (curPos != prevPos) {
            foreach(Transform t in transform) {
                t.Translate((prevPos - curPos) * ( Camera.main.farClipPlane - t.position.z) / Camera.main.farClipPlane);
            }
        }
        prevPos = curPos;
    }
}
