Shader "Unlit/DirectionalColoring"
{
	Properties
	{
		_LightColor("Light Color", Color) = (1,1,1,1)
		_MiddleColor("Middle Color", Color) = (1,1,1,1)
		_DarkColor("Dark Color", Color) = (1,1,1,1)	
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 color : TEXCOORD0;
			};
			

			fixed4 _LightColor;
			fixed4 _MiddleColor;
			fixed4 _DarkColor;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				half3 normal = normalize(mul(unity_ObjectToWorld, half4(v.normal, 0))).xyz;
				half lightDot = clamp(dot(normal, _WorldSpaceLightPos0), -1.0, 1.0);
				if (lightDot > 0) {
					o.color = lerp(_MiddleColor, _DarkColor, lightDot);
				} else if (lightDot < 0) {
					o.color = lerp(_MiddleColor, _LightColor, abs(lightDot));
				} else {
					o.color = _MiddleColor;
				}
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = fixed4(i.color, 1);
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
