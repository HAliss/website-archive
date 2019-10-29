Shader "Geometry/GrassGeometryShaderUnlit"
{
    Properties
    {
        //Color stuff
        _Color("Color", Color) = (1,1,1,1)
        _GradientMap("Gradient map", 2D) = "white" {}
         
        //Noise and wind
        _NoiseTexture("Noise texture", 2D) = "white" {} 
        _WindTexture("Wind texture", 2D) = "white" {}
        _WindStrength("Wind strength", float) = 0
        _WindSpeed("Wind speed", float) = 0
        _WindColor("Wind color", Color) = (1,1,1,1)
 
        //Position and dimensions
        _GrassHeight("Grass height", float) = 0
        _GrassWidth("Grass width", Range(0.0, 1.0)) = 1.0
        _PositionRandomness("Position randomness", float) = 0
 
        //Grass blades
        _GrassBlades("Grass blades per triangle", Range(0, 15)) = 1
        _MinimunGrassBlades("Minimum grass blades per triangle", Range(0, 15)) = 1
        _MaxCameraDistance("Max camera distance", float) = 10
    }
    SubShader
    {
 
        CGINCLUDE
         
            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
            };
 
            struct v2g
            {
                float4 vertex : POSITION;
            };
 
            struct g2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 col : COLOR;
            };
 
            fixed4 _Color;
            sampler2D _GradientMap;
 
            sampler2D _NoiseTexture;
            float4 _NoiseTexture_ST;
            sampler2D _WindTexture;
            float4 _WindTexture_ST;
            float _WindStrength;
            float _WindSpeed;
            fixed4 _WindColor;
 
            float _GrassHeight;
            float _GrassWidth;
            float _PositionRandomness;
 
            float _GrassBlades;
            float _MinimunGrassBlades;
            float _MaxCameraDistance;
 
            float random (float2 st) {
                return frac(sin(dot(st.xy,
                                    float2(12.9898,78.233)))*
                    43758.5453123);
            }
 
 
            g2f GetVertex(float4 pos, float2 uv, fixed4 col) {
                g2f o;
                o.vertex = UnityObjectToClipPos(pos);
                o.uv = uv;
                o.col = col;
                return o;
            }
 
            v2g vert (appdata v)
            {
                v2g o;
                o.vertex = v.vertex;
                return o;
            }
 
            //3 + 3 * 15 = 48
            [maxvertexcount(48)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                float3 normal = normalize(cross(input[1].vertex - input[0].vertex, input[2].vertex - input[0].vertex));
                int grassBlades = ceil(lerp(_GrassBlades, _MinimunGrassBlades, saturate(distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, input[0].vertex)) / _MaxCameraDistance)));
 
                for (uint i = 0; i < grassBlades; i++) {
                    float r1 = random(mul(unity_ObjectToWorld, input[0].vertex).xz * (i + 1));
                    float r2 = random(mul(unity_ObjectToWorld, input[1].vertex).xz * (i + 1));
 
                    //Random barycentric coordinates from https://stackoverflow.com/a/19654424
                    float4 midpoint = (1 - sqrt(r1)) * input[0].vertex + (sqrt(r1) * (1 - r2)) * input[1].vertex + (sqrt(r1) * r2) * input[2].vertex;
 
                    r1 = r1 * 2.0 - 1.0;
                    r2 = r2 * 2.0 - 1.0;
 
                    float4 pointA = midpoint + _GrassWidth * normalize(input[i % 3].vertex - midpoint);
                    float4 pointB = midpoint - _GrassWidth * normalize(input[i % 3].vertex - midpoint);
 
                    float4 worldPos = mul(unity_ObjectToWorld, midpoint);
 
                    float2 windTex = tex2Dlod(_WindTexture, float4(worldPos.xz * _WindTexture_ST.xy + _Time.y * _WindSpeed, 0.0, 0.0)).xy;
                    float2 wind = (windTex * 2.0 - 1.0) * _WindStrength;
 
                    float noise = tex2Dlod(_NoiseTexture, float4(worldPos.xz * _NoiseTexture_ST.xy, 0.0, 0.0)).x;
                    float heightFactor = noise * _GrassHeight;                        
 
                    triStream.Append(GetVertex(pointA, float2(0,0), fixed4(0,0,0,1)));
 
                    float4 newVertexPoint = midpoint + float4(normal, 0.0) * heightFactor + float4(r1, 0.0, r2, 0.0) * _PositionRandomness + float4(wind.x, 0.0, wind.y, 0.0);
                    triStream.Append(GetVertex(newVertexPoint, float2(0.5, 1), fixed4(1.0, length(windTex), 1.0, 1.0)));
 
                    triStream.Append(GetVertex(pointB, float2(1,0), fixed4(0,0,0,1)));
 
                    triStream.RestartStrip();
                }
                 
 
                for (int i = 0; i < 3; i++) {
                    triStream.Append(GetVertex(input[i].vertex, float2(0,0), fixed4(0,0,0,1)));
                }
 
 
                triStream.RestartStrip();
            }
 
            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 gradientMapCol = tex2D(_GradientMap, float2(i.col.x, 0.0));
                fixed4 col = (gradientMapCol + _WindColor * i.col.g) * _Color;
                return col;
            }
             
 
        ENDCG
 
        Pass
        {
            Tags { "RenderType"="Opaque"}
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
             
            ENDCG
        }
 
    }
}
