Shader "Cutout/Bumped Specular" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
	_Shininess ("Shininess", Range (0.01, 1)) = 0.078125
	_ReflectColor ("Reflection Color", Color) = (1,1,1,0.5)
	_MainTex ("Base (RGB) RefStrGloss (A)", 2D) = "white" {}
	_Cube ("Reflection Cubemap", Cube) = "" { TexGen CubeReflect }
	_BumpMap ("Normalmap", 2D) = "bump" {}
	_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
}

SubShader {
	Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
	LOD 400
CGPROGRAM
#pragma surface surf BlinnPhong alphatest:_Cutoff
#pragma target 3.0
//input limit (8) exceeded, shader uses 9
#pragma exclude_renderers d3d11_9x

sampler2D _MainTex;
sampler2D _BumpMap;
samplerCUBE _Cube;

fixed4 _Color;
fixed4 _ReflectColor;
half _Shininess;

struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;
	float3 worldRefl;
	INTERNAL_DATA
};

void surf (Input IN, inout SurfaceOutput o) {
	float4 tex = tex2D(_MainTex, IN.uv_MainTex);
	float4 c = tex * _Color;
	o.Albedo = c.rgb;
	
	// QYY: HACK to use alpha channel of normal map in Unity
	float4 normal = tex2D(_BumpMap, IN.uv_BumpMap).wywx;
	o.Normal = UnpackNormal(normal);

	o.Gloss = normal.x;
	o.Specular = _Shininess;
	
	float3 worldRefl = WorldReflectionVector (IN, o.Normal);
	float4 reflcol = texCUBE (_Cube, worldRefl);
	reflcol *= normal.x;
	o.Emission = reflcol.rgb * _ReflectColor.rgb;
	o.Alpha = tex.a * _Color.a;
}
ENDCG
}

FallBack "Transparent/Cutout/VertexLit"
}
