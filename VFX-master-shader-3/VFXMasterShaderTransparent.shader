Shader "VFX/VFXMasterShaderTransparent"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientMap("Gradient map", 2D) = "white" {} 
        [HDR]_Color("Color", Color) = (1,1,1,1)
 
        //Secondary texture
        [Space(20)]
        [Toggle(SECONDARY_TEX)]
        _SecondTex("Second texture", float) = 0
        _SecondaryTex("Secondary texture", 2D) = "white" {}
        _SecondaryPanningSpeed("Secondary panning speed", Vector) = (0,0,0,0)
         
        _PanningSpeed("Panning speed (XY main texture - ZW displacement texture)", Vector) = (0,0,0,0)
        _Contrast("Contrast", float) = 1
        _Power("Power", float) = 1
 
        //Clipping
        [Space(20)]
        _Cutoff("Cutoff", Range(0, 1)) = 0
        _CutoffSoftness("Cutoff softness", Range(0, 1)) = 0
        [HDR]_BurnCol("Burn color", Color) = (1,1,1,1)
        _BurnSize("Burn size", float) = 0
 
        //Softness
        [Space(20)]
        [Toggle(SOFT_BLEND)]
        _SoftBlend("Soft blending", float) = 0
        _IntersectionThresholdMax("Intersection Threshold Max", float) = 1
         
        //Vertex offset
        [Space(20)]
        [Toggle(VERTEX_OFFSET)]
        _VertexOffset("Vertex offset", float) = 0
        _VertexOffsetAmount("Vertex offset amount", float) = 0
 
        //Displacement
        [Space(20)]
        _DisplacementAmount("Displacement", float) = 0
        _DisplacementGuide("DisplacementGuide", 2D) = "white" {}
         
        //Culling
        [Space(20)]
        [Enum(UnityEngine.Rendering.CullMode)] _Culling ("Cull Mode", Int) = 2
 
        //Banding
        [Space(20)]
        [Toggle(BANDING)]
        _Banding("Color banding", float) = 0
        _Bands("Number of bands", float) = 3
 
        //Polar coordinates
        [Space(20)]
        [Toggle(POLAR)]
        _PolarCoords("Polar coordinates", float) = 0
 
        //Circle mask
        [Space(20)]
        [Toggle(CIRCLE_MASK)]
        _CircleMask("Circle mask", float) = 0
        _OuterRadius("Outer radius", Range(0,1)) = 0.5
        _InnerRadius("Inner radius", Range(-1,1)) = 0
        _Smoothness("Smoothness", Range(0,1)) = 0.2
 
        //Rect mask
        [Space(20)]
        [Toggle(RECT_MASK)]
        _RectMask("Rectangle mask", float) = 0
        _RectWidth("Rectangle width", float) = 0
        _RectHeight("Rectangle height", float) = 0
        _RectMaskCutoff("Rectangle mask cutoff", Range(0,1)) = 0
        _RectSmoothness("Rectangle mask smoothness", Range(0,1)) = 0        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Offset -1, -1
        Cull [_Culling]
        LOD 100
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature SECONDARY_TEX
            #pragma shader_feature VERTEX_OFFSET
            #pragma shader_feature SOFT_BLEND
            #pragma shader_feature BANDING
            #pragma shader_feature POLAR
            #pragma shader_feature CIRCLE_MASK
            #pragma shader_feature RECT_MASK
            // make fog work
            #pragma multi_compile_fog
 
            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float3 normal : NORMAL;
            };
 
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float2 displUV : TEXCOORD2;
                float2 secondaryUV : TEXCOORD3;
                float4 scrPos : TEXCOORD4;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SecondaryTex;
            float4 _SecondaryTex_ST;
            sampler2D _GradientMap;
            float _Contrast;
            float _Power;
 
            fixed4 _Color;
 
            float _Bands;
 
            float4 _PanningSpeed;
            float4 _SecondaryPanningSpeed;
             
            float _Cutoff;
            float _CutoffSoftness;
            fixed4 _BurnCol;
            float _BurnSize;
 
            sampler2D _CameraDepthTexture;
            float _IntersectionThresholdMax;
 
            float _VertexOffsetAmount;
 
            sampler2D _DisplacementGuide;
            float4 _DisplacementGuide_ST;
            float _DisplacementAmount;
 
            float _Smoothness;
            float _OuterRadius;
            float _InnerRadius;
 
            float _RectSmoothness;
            float _RectHeight;
            float _RectWidth;
            float _RectMaskCutoff;
 
            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.secondaryUV = TRANSFORM_TEX(v.uv, _SecondaryTex);
 
                #ifdef VERTEX_OFFSET
                float vertOffset = tex2Dlod(_MainTex, float4(o.uv + _Time.y * _PanningSpeed.xy, 1, 1)).x;
                #ifdef SECONDARY_TEX
                float secondTex = tex2Dlod(_SecondaryTex, float4(o.secondaryUV + _Time.y * _SecondaryPanningSpeed.xy, 1, 1)).x;
                vertOffset = vertOffset * secondTex * 2;
                #endif
                vertOffset = ((vertOffset * 2) - 1) * _VertexOffsetAmount;
                v.vertex.xyz += vertOffset * v.normal;
                #endif
 
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.displUV = TRANSFORM_TEX(v.uv, _DisplacementGuide);
                o.scrPos = ComputeScreenPos(o.vertex);
                o.color = v.color;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
 
                // sample the texture
                float2 uv = i.uv;
                float2 displUV = i.displUV;
                float2 secondaryUV = i.secondaryUV;
 
                //Polar coords
                #ifdef POLAR
                float2 mappedUV = (i.uv * 2) - 1;
                uv = float2(atan2(mappedUV.y, mappedUV.x) / UNITY_PI / 2.0 + 0.5, length(mappedUV));
                mappedUV = (i.displUV * 2) - 1;
                displUV = float2(atan2(mappedUV.y, mappedUV.x) / UNITY_PI / 2.0 + 0.5, length(mappedUV));
                mappedUV = (i.secondaryUV * 2) - 1;
                secondaryUV = float2(atan2(mappedUV.y, mappedUV.x) / UNITY_PI / 2.0 + 0.5, length(mappedUV));
                #endif
 
                //UV Panning
                uv += _Time.y * _PanningSpeed.xy;
                displUV += _Time.y * _PanningSpeed.zw;
                secondaryUV += _Time.y * _SecondaryPanningSpeed.xy;
 
                //Displacement
                float2 displ = tex2D(_DisplacementGuide, displUV).xy;
                displ = ((displ * 2) - 1) * _DisplacementAmount;
 
                float col = pow(saturate(lerp(0.5, tex2D(_MainTex, uv + displ).x, _Contrast)), _Power);
                #ifdef SECONDARY_TEX
                col = col * pow(saturate(lerp(0.5, tex2D(_SecondaryTex, secondaryUV + displ).x, _Contrast)), _Power) * 2;
                #endif
 
                //Masking
                #ifdef CIRCLE_MASK
                float circle = distance(i.uv, float2(0.5, 0.5));
                col *= 1 - smoothstep(_OuterRadius, _OuterRadius + _Smoothness, circle);
                col *= smoothstep(_InnerRadius, _InnerRadius + _Smoothness, circle);
                #endif
 
                #ifdef RECT_MASK
                float2 uvMapped = (i.uv * 2) - 1;
                float rect = max(abs(uvMapped.x / _RectWidth), abs(uvMapped.y / _RectHeight));
                col *= 1 - smoothstep(_RectMaskCutoff, _RectMaskCutoff + _RectSmoothness, rect);
                #endif
             
 
                float orCol = col;
 
                //Banding
                #ifdef BANDING
                col = round(col * _Bands) / _Bands;
                #endif
 
                //Transparency
                float cutoff = saturate(_Cutoff + (1 - i.color.a));
                float alpha = smoothstep(cutoff, cutoff + _CutoffSoftness, orCol);
 
                //Coloring
                fixed4 rampCol = tex2D(_GradientMap, float2(col, 0)) + _BurnCol * smoothstep(orCol - cutoff, orCol - cutoff + _CutoffSoftness, _BurnSize) * smoothstep(0.001, 0.5, cutoff);
                fixed4 finalCol = fixed4(rampCol.rgb * _Color.rgb * rampCol.a, 1);
                 
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, finalCol);
                finalCol.a = alpha * tex2D(_MainTex, uv + displ).a * _Color.a;
 
                //Soft Blending
                #ifdef SOFT_BLEND
                float depth = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)));
                float diff = saturate(_IntersectionThresholdMax * (depth - i.scrPos.w));
                finalCol.a *= diff;
                #endif
                return finalCol;
            }
            ENDCG
        }
    }
}
