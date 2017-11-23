//Camera distance
fixed4 frag (v2f i) : SV_Target
{
    // sample the texture
    fixed4 col = tex2D(_MainTex, i.uv);
    float camDist = distance(i.worldPos, _WorldSpaceCameraPos);
    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, col);
    return col;
}

//View direction
struct v2f
{
    float2 uv : TEXCOORD0;
    UNITY_FOG_COORDS(1)
    float4 vertex : SV_POSITION;
    float4 worldPos : TEXCOORD1;
    float3 viewDir : TEXCOORD2;
};

v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos);
    UNITY_TRANSFER_FOG(o,o.vertex);
    return o;
}


//Normal vectors
struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    UNITY_FOG_COORDS(1)
    float4 vertex : SV_POSITION;
    float3 normal : NORMAL;
};

v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    UNITY_TRANSFER_FOG(o,o.vertex);
    return o;
}
