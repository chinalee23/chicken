// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PPSG/UI-Unlit" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
	}

		SubShader
	{
		LOD 150
		Tags
	{
		"Queue" = "Transparent"
		"IgnoreProjector" = "True"
		"RenderType" = "Transparent"
	}

	Pass
	{
		//UI的shader主要是开启zwrite off及lighting off，UI不受雾效影响
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		Lighting Off
		ZWrite Off

		CGPROGRAM

		//#pragma only_renderers gles d3d9 d3d11_9x opengl
    #pragma exclude_renderers xbox360 ps3
	#pragma vertex   vert
	#pragma fragment frag
	//#pragma multi_compile_fog
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	fixed4 _Color;

	struct appdata
	{
		float4 vertex    : POSITION;
		float4 texcoord  : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos    : SV_POSITION;
		float2 uv     : TEXCOORD0;
		//float4 color  : TEXCOORD1;  //不需要顶点色
		//UNITY_FOG_COORDS(2) //this mean defining float fogCoord : TEXCOORD2
	};

	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_UV(0);
		//o.color = v.color;

		//UNITY_TRANSFER_FOG(o, o.pos);

		return o;
	}



	fixed4 frag(v2f i) : COLOR
	{
		fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
	//albedo.a = albedo.a * i.color.a;
	//UNITY_APPLY_FOG(i.fogCoord, albedo);
	return albedo;
	}

	ENDCG
	} // Pass
	} // SubShader

		//Fallback "Transparent/VertexLit"
}
