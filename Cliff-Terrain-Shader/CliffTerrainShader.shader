Shader "Custom/CliffTerrainShader"
{
    Properties
    {
        _CliffTexture("Cliff texture", 2D) = "white" {}
        [Normal]_CliffNormal("Cliff normal", 2D) = "bump" {} 
        _CliffNormalStrength("Cliff normal strength", float) = 1
        _CliffSmoothness("Cliff smoothness", Range(0,1)) = 0
        _CliffMetallic("Cliff metallic", Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
 
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
 
        sampler2D _CliffTexture;
        float4 _CliffTexture_ST;
        sampler2D _CliffNormal;
        float _CliffNormalStrength;
        float _CliffMetallic;
        float _CliffSmoothness;
 
        sampler2D _Control;
 
        // Textures
        sampler2D _Splat0, _Splat1, _Splat2, _Splat3;
        float4 _Splat0_ST, _Splat1_ST, _Splat2_ST, _Splat3_ST;
 
        //Normal Textures
        sampler2D _Normal0, _Normal1, _Normal2, _Normal3;
 
        //Normal scales
        float _NormalScale0, _NormalScale1, _NormalScale2, _NormalScale3;
 
        //Smoothness
        float _Smoothness0, _Smoothness1, _Smoothness2, _Smoothness3;
 
        //Metallic
        float _Metallic0, _Metallic1, _Metallic2, _Metallic3;
 
 
        struct Input
        {
            float2 uv_Control;
            float3 worldPos;
            float3 worldNormal;
            INTERNAL_DATA
        };
 
 
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
 
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 splatControl = tex2D(_Control, IN.uv_Control);
            fixed4 col = splatControl.r * tex2D (_Splat0, IN.uv_Control * _Splat0_ST.xy);
            col += splatControl.g * tex2D(_Splat1, IN.uv_Control * _Splat1_ST.xy);
            col += splatControl.b * tex2D (_Splat2, IN.uv_Control * _Splat2_ST.xy);
            col += splatControl.a * tex2D (_Splat3, IN.uv_Control * _Splat3_ST.xy);
             
            o.Normal = splatControl.r * UnpackNormalWithScale(tex2D(_Normal0, IN.uv_Control * _Splat0_ST.xy), _NormalScale0);
            o.Normal += splatControl.g * UnpackNormalWithScale(tex2D(_Normal1, IN.uv_Control * _Splat1_ST.xy), _NormalScale1);
            o.Normal += splatControl.b * UnpackNormalWithScale(tex2D(_Normal2, IN.uv_Control * _Splat2_ST.xy), _NormalScale2);
            o.Normal += splatControl.a * UnpackNormalWithScale(tex2D(_Normal3, IN.uv_Control * _Splat3_ST.xy), _NormalScale3);
 
            o.Smoothness = splatControl.r * _Smoothness0;
            o.Smoothness += splatControl.g * _Smoothness1;
            o.Smoothness += splatControl.b * _Smoothness2;
            o.Smoothness += splatControl.a * _Smoothness3;
 
            o.Metallic = splatControl.r * _Metallic0;
            o.Metallic += splatControl.g * _Metallic1;
            o.Metallic += splatControl.b * _Metallic2;
            o.Metallic += splatControl.a * _Metallic3;
 
            float3 vec = abs(WorldNormalVector (IN, o.Normal));
            float threshold =  smoothstep(0.5, 0.9, abs(dot(vec, float3(0, 1, 0))));
            fixed4 cliffColorXY = tex2D(_CliffTexture, IN.worldPos.xy * _CliffTexture_ST.xy);
            fixed4 cliffColorYZ = tex2D(_CliffTexture, IN.worldPos.yz * _CliffTexture_ST.xy);
            fixed4 cliffColor = vec.x * cliffColorYZ + vec.z * cliffColorXY;
 
            float3 cliffNormalXY = UnpackNormalWithScale(tex2D(_CliffNormal, IN.worldPos.xy * _CliffTexture_ST.xy), _CliffNormalStrength);
            float3 cliffNormalYZ = UnpackNormalWithScale(tex2D(_CliffNormal, IN.worldPos.yz * _CliffTexture_ST.xy), _CliffNormalStrength);
            float3 cliffNormal = vec.x * cliffNormalYZ + vec.z * cliffNormalXY;
 
            col = lerp(cliffColor, col, threshold);
            o.Normal = lerp(cliffNormal, o.Normal, threshold);
            o.Smoothness = lerp(_CliffSmoothness, o.Smoothness, threshold);
            o.Metallic = lerp(_CliffMetallic, o.Metallic, threshold);
 
            o.Albedo = col.rgb;
            o.Alpha = col.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
