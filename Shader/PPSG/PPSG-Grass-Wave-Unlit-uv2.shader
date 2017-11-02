Shader "PPSG/Grass Wave Unlit UV2" {

	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_ShakeTime("Shake Time", Range(0, 3.0)) = 1.0
		_ShakeWindspeed("Shake Windspeed", Range(0, 3.0)) = 1.0
		_ShakeBending("Shake Bending", Range(0, 3.0)) = 1.0
	}

		SubShader{
		Tags{ "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		LOD 300

		Pass{
			Lighting Off
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fog

#include "UnityCG.cginc"
		sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 _Color;
	fixed  _Cutoff;
	float _ShakeTime;
	float _ShakeWindspeed;
	float _ShakeBending;

	struct appdata_t {
		float4 vertex : POSITION;
		float2 texcoord : TEXCOORD0;
		float2 texcoord1: TEXCOORD1;
		float4 color : COLOR;
	};

	struct v2f {
		float4 vertex : SV_POSITION;
		half2 texcoord : TEXCOORD0;
		UNITY_FOG_COORDS(1)
	};


	void FastSin(float4 val, out float4 s) {
		val = val * 6.408849 - 3.1415927;
		float4 r5 = val * val;
		float4 r1 = r5 * val;
		float4 r2 = r1 * r5;
		float4 r3 = r2 * r5;
		float4 sin7 = { 1, -0.16161616, 0.0083333, -0.00019841 };
		float4 cos8 = { -0.5, 0.041666666, -0.0013888889, 0.000024801587 };
		s = val + r1 * sin7.y + r2 * sin7.z + r3 * sin7.w;
		//c = 1 + r5 * cos8.x + r6 * cos8.y + r7 * cos8.z + r8 * cos8.w;
	}


	v2f vert(appdata_t v) {

		const float _WindSpeed = (_ShakeWindspeed + v.color.r); //顶点色的r通道存储风速

		const float4 _waveXSize = float4(0.048, 0.06, 0.24, 0.096);
		const float4 _waveZSize = float4 (0.024, .08, 0.08, 0.2);
		const float4 waveSpeed = float4 (1.2, 2, 1.6, 4.8);

		float4 _waveXmove = float4(0.024, 0.04, -0.12, 0.096);
		float4 _waveZmove = float4 (0.006, .02, -0.02, 0.1);

		float4 waves;
		waves = v.vertex.x * _waveXSize;
		waves += v.vertex.z * _waveZSize;

		waves += _Time.x * (1 - _ShakeTime * 2 - v.color.g) * waveSpeed *_WindSpeed; //g通道存储时间

		float4 s;
		waves = frac(waves);
		FastSin(waves, s); //计算waves的正弦值，waves是根据时间计算出的相位值，弧度为单位

		float waveAmount = v.texcoord1.y * (v.color.b + _ShakeBending); //根据纹理坐标的方向来判断朝向，顶点色的b通道存储弯曲度
		s *= waveAmount; //计算振幅

		s *= normalize(waveSpeed);

		s = s * s;
		//s = s * s;  //这里做了s的4次方处理，使得不同的y导致的变化幅度更小，摆动更真实

		float3 waveMove = float3 (0, 0, 0);
		waveMove.x = dot(s, _waveXmove);
		waveMove.z = dot(s, _waveZmove);
		float3 objectVertex = v.vertex;
		objectVertex.xz -= mul((float3x3)unity_WorldToObject, waveMove).xz;

		v2f o;
		o.vertex = UnityObjectToClipPos(objectVertex);
		o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
		UNITY_TRANSFER_FOG(o, o.vertex);
		return o;

	}


	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.texcoord) * _Color;
		UNITY_APPLY_FOG(i.fogCoord, col);
		return col;
	}
		ENDCG
	}

	}

		SubShader{
		Tags{ "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		LOD 200

		Pass{
			Lighting Off
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fog

#include "UnityCG.cginc"
		sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 _Color;

	struct appdata_t {
		float4 vertex : POSITION;
		float2 texcoord : TEXCOORD0;
		float4 color : COLOR;
	};

	struct v2f {
		float4 vertex : SV_POSITION;
		half2 texcoord : TEXCOORD0;
		UNITY_FOG_COORDS(1)
	};


	v2f vert(appdata_t v) {

		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
		UNITY_TRANSFER_FOG(o, o.vertex);
		return o;

	}


	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.texcoord) * _Color;
	UNITY_APPLY_FOG(i.fogCoord, col);
	return col;
	}
		ENDCG
	}

	}

		//Fallback "Transparent/Cutout/VertexLit"
}