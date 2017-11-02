// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PPSG/VertexAlpha-Unlit-nofog" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
}

SubShader
{
	LOD 150
	Tags
{
	"Queue" = "Transparent"
	"RenderType" = "Transparent"
}

Pass
{
	Blend SrcAlpha OneMinusSrcAlpha
	ColorMask RGB
	Lighting Off

	CGPROGRAM

	//#pragma only_renderers gles d3d9 d3d11_9x opengl
#pragma vertex   vert
#pragma fragment frag
#pragma multi_compile_fog
#include "UnityCG.cginc"

sampler2D _MainTex;
fixed4 _Color;

struct v2f
{
	float4 pos    : SV_POSITION;
	float2 uv     : TEXCOORD0;
	float4 color  : TEXCOORD1;
	//UNITY_FOG_COORDS(2) //this mean defining float fogCoord : TEXCOORD2
};

v2f vert(appdata_full v)
{
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_UV(0);
	o.color = v.color;

	//UNITY_TRANSFER_FOG(o, o.pos);

	return o;
}



fixed4 frag(v2f i) : COLOR
{
	fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
albedo.a = albedo.a * i.color.a;
//UNITY_APPLY_FOG(i.fogCoord, albedo);
return albedo;
}

ENDCG
} // Pass
} // SubShader

Fallback "Transparent/VertexLit"
}
