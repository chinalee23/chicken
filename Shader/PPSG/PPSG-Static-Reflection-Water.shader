// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PPSG/Static Reflect Water" {
	Properties{
		_WaveScale("Wave scale", Range(0.02,1)) = 0.063
		_ReflDistort("Reflection distort", Range(0,1.5)) = 0.44
		[NoScaleOffset] _BumpMap("Normalmap ", 2D) = "bump" {}
		[NoScaleOffset] _ReflectiveColor("Reflective color (RGB) fresnel (A) ", 2D) = "" {}
		WaveSpeed("Wave speed (map1 x,y; map2 x,y)", Vector) = (19,9,-16,-7)
		[HideInInspector]_WaveScale4("Wave Scale4 (map1 x,y; map2 x,y)", Vector) = (1,1,1,1)
		[HideInInspector]_WaveOffset("Wave Offset (map1 x,y; map2 x,y)", Vector) = (0,0,0,0)
		 _ReflectionTex("Static Reflection", 2D) = "" {}
	}


		// -----------------------------------------------------------
		// Fragment program cards


		Subshader{
			Tags { "WaterMode" = "Refractive" "RenderType" = "Opaque" }
			Pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_fog


		#include "UnityCG.cginc"

		uniform float4 _WaveScale4;
		uniform float4 _WaveOffset;
		uniform float _ReflDistort;
		sampler2D _BumpMap;
		sampler2D _ReflectionTex;
		sampler2D _ReflectiveColor;




		struct v2f {
			float4 pos : SV_POSITION;

			float4 ref : TEXCOORD0;
			float2 bumpuv0 : TEXCOORD1;
			float2 bumpuv1 : TEXCOORD2;
			float3 viewDir : TEXCOORD3;
			UNITY_FOG_COORDS(4)
			float4 color  : TEXCOORD5;
		};

		v2f vert(appdata_full v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.color = v.color;

			// scroll bump waves
			float4 temp;
			float4 wpos = mul(unity_ObjectToWorld, v.vertex);
			temp.xyzw = wpos.xzxz * _WaveScale4 + _WaveOffset;
			o.bumpuv0 = temp.xy;
			o.bumpuv1 = temp.wz;

			// object space view direction (will normalize per pixel)
			o.viewDir.xzy = WorldSpaceViewDir(v.vertex);

			o.ref = ComputeScreenPos(o.pos);

			UNITY_TRANSFER_FOG(o,o.pos);
			return o;
		}

		


		half4 frag(v2f i) : SV_Target
		{
			i.viewDir = normalize(i.viewDir);

			// combine two scrolling bumpmaps into one
			half3 bump1 = UnpackNormal(tex2D(_BumpMap, i.bumpuv0)).rgb;
			half3 bump2 = UnpackNormal(tex2D(_BumpMap, i.bumpuv1)).rgb;
			half3 bump = (bump1 + bump2) * 0.5;

			// fresnel factor
			half fresnelFac = dot(i.viewDir, bump);

			// perturb reflection/refraction UVs by bumpmap, and lookup colors


			float4 uv1 = i.ref; uv1.xy += bump * _ReflDistort;
			half4 refl = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(uv1));


			// final color is between refracted and reflected based on fresnel
			half4 color;
			half4 water = tex2D(_ReflectiveColor, float2(fresnelFac,fresnelFac));
			color.rgb = lerp(0.8, refl.rgb, 1 - water.r);
			color.a = refl.a;


			color.rgb *= (1.0 / i.color.r);

			UNITY_APPLY_FOG(i.fogCoord, color);
			return color;
	}
	ENDCG

		}
	}

}
