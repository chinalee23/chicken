// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PPSG/Unlit-Line" {
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
	}

		SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100

		Pass
	{
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		Lighting Off
		ZWrite Off

		CGPROGRAM

#pragma exclude_renderers xbox360 ps3
#pragma vertex   vert
#pragma fragment frag
		//#pragma multi_compile_fog
#include "UnityCG.cginc"

		sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 _Color;

	struct v2f
	{
		float4 pos    : SV_POSITION;
		float2 uv     : TEXCOORD0;
		float4 color  : TEXCOORD1;
		UNITY_FOG_COORDS(2) //this mean defining float fogCoord : TEXCOORD2
	};

	v2f vert(appdata_full v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.uv.x = o.uv.x - _Time.y * 0.3f;
		o.color = v.color;

		UNITY_TRANSFER_FOG(o, o.pos);

		return o;
	}



	fixed4 frag(v2f i) : COLOR
	{
		fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
	albedo.a = albedo.a * i.color.a;
	UNITY_APPLY_FOG(i.fogCoord, albedo);
	return albedo;
	}

		ENDCG
	} // Pass
	} // SubShader

	  //Fallback "Transparent/VertexLit"
}