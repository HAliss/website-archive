//Camera distance
struct Input {
    float2 uv_MainTex;
    float3 worldPos;
};

void surf (Input IN, inout SurfaceOutputStandard o) {
    // Albedo comes from a texture tinted by color
    fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
    o.Albedo = c.rgb;
    float camDist = distance(IN.worldPos, _WorldSpaceCameraPos);
    // Metallic and smoothness come from slider variables
    o.Metallic = _Metallic;
    o.Smoothness = _Glossiness;
    o.Alpha = c.a;
}


//View direction
struct Input {
    float2 uv_MainTex;
    float3 viewDir;
};
