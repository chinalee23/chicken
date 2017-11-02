// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "PPSG/Transparent Bumped Specular" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0)
	_Shininess ("Shininess", Range (0.01, 1)) = 0.078125
	_MainTex ("Base (RGB) TransGloss (A)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
}
	
CGINCLUDE
sampler2D _MainTex;
sampler2D _BumpMap;
fixed4 _Color;
half _Shininess;

struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;
};

void surf(Input IN, inout SurfaceOutput o) {
	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex); 
	o.Albedo = tex.rgb * _Color.rgb;
	o.Gloss = tex.a;
	o.Alpha = tex.a * _Color.a;
	o.Specular = _Shininess;
	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
}
ENDCG

SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 600
	
	CGPROGRAM
	#pragma exclude_renderers xbox360 ps3
	#pragma surface surf BlinnPhong alpha:fade exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap nolppv noshadowmask
	#pragma target 3.0
	ENDCG
}

SubShader{
	Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
	LOD 400

	CGPROGRAM
	#pragma surface surf Lambert alpha exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap nolppv noshadowmask
	ENDCG
}

SubShader{
	Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
	LOD 200

	CGPROGRAM
	#pragma exclude_renderers xbox360 ps3
	#pragma surface surfDiffuse Lambert alpha exclude_path:deferred exclude_path:prepass noshadow nodynlightmap nodirlightmap noforwardadd nolppv noshadowmask


	void surfDiffuse(Input IN, inout SurfaceOutput o) {
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		o.Albedo = c.rgb;
		o.Alpha = c.a;
	}
	ENDCG
	}

}