Shader "Custom/2DFogSpriteShader"
 {
     Properties
     {
         [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
         _SkyColor ("Sky Color", Color) = (1,1,1,1)
         _MaxCamDist("Max Camera distance", float) = 100
         [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
     }
  
     SubShader
     {
         Blend SrcAlpha OneMinusSrcAlpha
  
         Pass
         {
         CGPROGRAM
             #pragma vertex vert
             #pragma fragment frag
             #pragma multi_compile DUMMY PIXELSNAP_ON
             #include "UnityCG.cginc"
  
             struct appdata_t
             {
                 float4 vertex   : POSITION;
                 float4 color    : COLOR;
                 float2 texcoord : TEXCOORD0;
             };
  
             struct v2f
             {
                 float4 vertex   : SV_POSITION;
                 fixed4 color    : COLOR;
                 half2 texcoord  : TEXCOORD0;
                 float4 worldPos : TEXCOORD1;
             };
  
             v2f vert(appdata_t IN)
             {
                 v2f OUT;
                 OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
                 OUT.texcoord = IN.texcoord;
                 OUT.color = IN.color;
                 OUT.worldPos = mul(unity_ObjectToWorld, IN.vertex);
                 #ifdef PIXELSNAP_ON
                 OUT.vertex = UnityPixelSnap (OUT.vertex);
                 #endif
  
                 return OUT;
             }
  
             sampler2D _MainTex;
             fixed4 _SkyColor;
             float _MaxCamDist;
  
            fixed4 frag(v2f IN) : COLOR
            {
                float dist = distance(IN.worldPos, _WorldSpaceCameraPos);
                half4 texcol = tex2D (_MainTex, IN.texcoord) * IN.color;
                float distFactor = saturate(dist/_MaxCamDist);
                half4 intercol = lerp(texcol, _SkyColor, distFactor);
                float gradientFactor = distFactor / 3;
                half4 finalCol = lerp(_SkyColor, intercol, (IN.texcoord.y - gradientFactor)/ (1 - gradientFactor)) * step(gradientFactor, IN.texcoord.y);
                if (IN.texcoord.y < gradientFactor) finalCol = _SkyColor;
                finalCol.a = texcol.a;
                return finalCol;
            }
         ENDCG
         }
     }
     Fallback "Sprites/Default"
 }
