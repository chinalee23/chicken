// Simplified Bumped shader. Differences from regular Bumped one:
// - no Main Color
// - Normalmap uses Tiling/Offset of the Base texture
// - fully supports only 1 directional light. Other lights can affect it, but it will be per-vertex/SH.

Shader "PPSG/Bumped Diffuse Simple" {
Properties {
	_Color("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
}

SubShader {
	Tags { "RenderType"="Opaque"}
	LOD 300
	CGPROGRAM
	#pragma exclude_renderers xbox360 ps3
	#pragma surface surf Lambert noforwardadd exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap noforwardadd nolppv noshadowmask

sampler2D _MainTex;
sampler2D _BumpMap;
fixed4 _Color;

struct Input {
	float2 uv_MainTex;
};

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = c.rgb;
	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
}
ENDCG  
}

SubShader{
	Tags{ "RenderType" = "Opaque" }
	LOD 200

	CGPROGRAM
	#pragma exclude_renderers xbox360 ps3
	#pragma surface surf Lambert noforwardadd exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap noforwardadd nolppv noshadowmask

	sampler2D _MainTex;
	fixed4 _Color;

struct Input {
	float2 uv_MainTex;
};

void surf(Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = c.rgb;
}
ENDCG
}
}
