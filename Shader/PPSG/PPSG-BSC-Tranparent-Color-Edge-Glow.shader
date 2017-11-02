// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PPSG/BSC-Transparent-Color-Edge-Glow" 
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Color("Main Color", Color) = (1,1,1,1)
		_BrightnessAmount("Brightess Amount",Range(0.0,10)) = 1.0
		_satAmount("Saturation Amount",Range(0.0,10)) = 1.0
		_conAmount("Contrast Amount",Range(0.0,10)) = 1.0
		_GlowColor("GlowColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_BlurOffset("BlurOffset", float) = 1.0
		_GlowPower("GlowPower", float) = 3.0
	}
		SubShader
		{
			Tags{ "RenderType" = "Transparent" }
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Lighting Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			uniform sampler2D _MainTex;
			uniform fixed4 _MainTex_TexelSize;
			uniform fixed4 _Offsets;
			float _GlowPower;
			fixed4 _GlowColor;
			float _BlurOffset;
			fixed _BrightnessAmount;
			fixed _satAmount;
			fixed _conAmount;
			fixed4 _Color;

			float3 ContrastSaturationBrightness(float3 color,float brt,float sat,float con)
			{
				float AvgLumR = 0.5;
				float AvgLumG = 0.5;
				float AvgLumB = 0.5;
				float3 LuminanceCoeff = float3(0.2125,0.7154,0.0721);
				float3 AvgLumin = float3(AvgLumR,AvgLumG,AvgLumB);
				float3 brtColor = color * brt;
				float intensityf = dot(brtColor,LuminanceCoeff);
				float3 intensity = float3(intensityf,intensityf,intensityf);

				float3 satColor = lerp(intensity,brtColor,sat);

				float3 conColor = lerp(AvgLumin,satColor,con);
				return conColor;
			}

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				half4 uv0 : TEXCOORD1;
				half4 uv1 : TEXCOORD2;
				fixed4 color : COLOR;
			};

			v2f o;

			v2f vert(appdata_t v)
			{
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color;

				float2 uv = v.texcoord.xy;
				float offX = _MainTex_TexelSize.x * _BlurOffset;
				float offY = _MainTex_TexelSize.y * _BlurOffset;
				o.uv0.xy = uv + float2(offX, offY);
				o.uv0.zw = uv + float2(-offX, offY);
				o.uv1.xy = uv + float2(offX, -offY);
				o.uv1.zw = uv + float2(-offX, -offY);

				return o;
			}

			fixed4 frag(v2f IN) : COLOR
			{


				fixed4 c;
			c = tex2D(_MainTex, IN.uv0.xy);
			c += tex2D(_MainTex, IN.uv0.zw);
			c += tex2D(_MainTex, IN.uv1.xy);
			c += tex2D(_MainTex, IN.uv1.zw);
			c /= 4.0;
			if (c.a > 0.5) //texture color
			{
				fixed4 renderTex = tex2D(_MainTex, IN.texcoord);
				renderTex.rgb = ContrastSaturationBrightness(renderTex.rgb, _BrightnessAmount, _satAmount, _conAmount);
				return renderTex * _Color;
			}
			else //edge color
			{
				c.rgb = _GlowColor.rgb;
				c.a *= _GlowPower;
				return c;
			}
			}

			ENDCG
		}

			
	}
}