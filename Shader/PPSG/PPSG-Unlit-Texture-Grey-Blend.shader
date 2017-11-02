Shader "PPSG/Unlit-Texture-Grey-Blend" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Greyed("Grey Ratio", Range(0,1)) = 0.0
	}

		SubShader{
			Tags{ "RenderType" = "Opaque" }
			LOD 100

			Pass{
			Lighting Off
			Fog{ Mode Off }

			CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		

		#include "UnityCG.cginc"

		struct appdata_t {
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 vertex : SV_POSITION;
			half2 texcoord : TEXCOORD0;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _Greyed;

		v2f vert(appdata_t v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			fixed4 ret = tex2D(_MainTex, i.texcoord);
			fixed greyColor = ret.r * 0.299 + ret.g * 0.587 + ret.b * 0.114;
			ret.rgb = lerp(ret.rgb, fixed3(greyColor, greyColor, greyColor), _Greyed);
			return ret;
		}
		ENDCG
		}
	}

}