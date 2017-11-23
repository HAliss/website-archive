public class SkyColorManager : MonoBehaviour {
  
    public Color skyColor;
    public Material fogMat;
  
    void Update () {
        Camera.main.backgroundColor = skyColor;
        fogMat.SetColor("_SkyColor", skyColor);
    }
}
