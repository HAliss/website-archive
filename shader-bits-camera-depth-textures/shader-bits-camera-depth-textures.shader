//Linear eye depth
sampler2D _CameraDepthTexture;
 
fixed4 frag (v2f i) : SV_Target
{
    fixed4 col = tex2D(_MainTex, i.uv);
    float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
    depth = LinearEyeDepth(depth);
    return col;
}

//Linear 0-1 depth
sampler2D _CameraDepthTexture;
 
struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float4 scrPos : TEXCOORD1;
};
 
v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    o.scrPos = ComputeScreenPos(o.vertex);
    return o;
}
 
fixed4 frag (v2f i) : SV_Target
{
    fixed4 col = tex2D(_MainTex, i.uv);
    float depth = (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)));
    depth = Linear01Depth(depth);
    return col;
}



//Depth and normals
sampler2D _CameraDepthNormalsTexture;
 
fixed4 frag (v2f i) : SV_Target
{
    fixed4 col = tex2D(_MainTex, i.uv);
    half3 normal;
    float depth;
    DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal);
    return col;
}
