Shader "Custom/InteriorMappingSurface" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex("Main texture", 2D) = "white" {} 
        _Normal("Normal", 2D) = "bump" {} 
        _InteriorMask("Interior mask", 2D) = "white" {} 
        _InteriorCubemap("Interior cubemap", Cube) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" "DisableBatching"="True"}
        LOD 200
 
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert
 
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
 
        samplerCUBE _InteriorCubemap;
        sampler2D _InteriorMask;
        sampler2D _Normal;
        sampler2D _MainTex;
 
        struct Input {
            float2 uv_InteriorCubemap;
            float2 uv_MainTex;
            float3 viewDirTangent;
        };
 
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
 
        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
 
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            float4 objCam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
            float3 viewDir = v.vertex.xyz - objCam.xyz;
            float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
            float3 bitangent = cross(v.normal.xyz, v.tangent.xyz) * tangentSign;
            o.viewDirTangent = float3(
                    dot(viewDir, v.tangent.xyz),
                    dot(viewDir, bitangent),
                    dot(viewDir, v.normal)
                    );
        }
 
        void surf (Input IN, inout SurfaceOutputStandard o) {
            float2 uv = frac(IN.uv_InteriorCubemap);
            float3 pos = float3(uv * 2.0 - 1.0, 1.0);
            float3 id = 1.0 / IN.viewDirTangent;
            float3 k = abs(id) - pos * id;
            float kMin = min(min(k.x, k.y), k.z);
            pos += kMin * IN.viewDirTangent;
 
            fixed4 col = tex2D(_MainTex, IN.uv_MainTex);
            half mask = tex2D(_InteriorMask, IN.uv_MainTex);
            o.Albedo = lerp( col.rgb, texCUBE(_InteriorCubemap, pos.xyz).rgb, mask);
            o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_MainTex));
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
