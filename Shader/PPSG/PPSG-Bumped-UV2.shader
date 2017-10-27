// Simplified Bumped shader. Differences from regular Bumped one:
// - no Main Color
// - Normalmap uses Tiling/Offset of the Base texture
// - fully supports only 1 directional light. Other lights can affect it, but it will be per-vertex/SH.

Shader "PPSG/Bumped Diffuse UV2" {
Properties {
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

struct Input {
	float2 uv_MainTex;
	float2 uv2_BumpMap;
};

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
	o.Albedo = c.rgb;
	o.Alpha = c.a;
	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv2_BumpMap));
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

struct Input {
	float2 uv_MainTex;
	float2 uv2_BumpMap;
};

void surf(Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
	o.Albedo = c.rgb;
	o.Alpha = c.a;
}
ENDCG
}
}
