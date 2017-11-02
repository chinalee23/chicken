// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: commented out 'float4 unity_LightmapST', a built-in variable
// Upgrade NOTE: commented out 'sampler2D unity_Lightmap', a built-in variable
// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "PPSG/Scene Diffuse CullOff"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
    }

    SubShader
    {
        LOD 150
        Tags
        {
            "Queue"      = "Geometry"
            "RenderType" = "Opaque"
        }

        Pass
        {
            ColorMask RGB
            Cull Off
            Lighting Off
        	Tags { "LightMode" = "VertexLMRGBM" }

            CGPROGRAM

            #pragma multi_compile MID_QUALITY LOW_QUALITY

            //#pragma only_renderers gles d3d9 d3d11_9x opengl
            #pragma vertex   vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
#if defined(MID_QUALITY)
            float4    _MainTex_ST;      // Scale & position of _MainTex
            // sampler2D unity_Lightmap;   // Far lightmap
            // float4    unity_LightmapST; // Lightmap atlasing data
#endif

            struct appdata
            {
                float4 vertex    : POSITION;
                float4 texcoord  : TEXCOORD0;
#if defined(MID_QUALITY)
                float2 texcoord1 : TEXCOORD1;
#endif
            };

            struct v2f
            {
                float4 pos        : SV_POSITION;
                float2 texUV      : TEXCOORD0;
#if defined(MID_QUALITY)
                float2 lightmapUV : TEXCOORD1;
#endif
            }; 
            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos        = UnityObjectToClipPos(v.vertex);
#if defined(MID_QUALITY)
                o.texUV      = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.lightmapUV = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#else
                o.texUV      = TRANSFORM_UV(0);
#endif
                return o;
            }

            fixed4 frag(v2f i) : COLOR
            {
                fixed4 color    = tex2D(_MainTex, i.texUV);
#if defined(MID_QUALITY)
                fixed4 lightmap = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV);
                color.rgb       = color.rgb * DecodeLightmap(lightmap);
#endif
                return color;
            }

            ENDCG
        } // Pass

        Pass
        {
            ColorMask RGB
            Cull Off
            Lighting Off
        	Tags { "LightMode" = "VertexLM" }

            CGPROGRAM

            #pragma multi_compile MID_QUALITY LOW_QUALITY

            //#pragma only_renderers gles d3d9 d3d11_9x opengl
            #pragma vertex   vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
#if defined(MID_QUALITY)
            float4    _MainTex_ST;      // Scale & position of _MainTex
            // sampler2D unity_Lightmap;   // Far lightmap
            // float4    unity_LightmapST; // Lightmap atlasing data
#endif

            struct appdata
            {
                float4 vertex    : POSITION;
                float4 texcoord  : TEXCOORD0;
#if defined(MID_QUALITY)
                float2 texcoord1 : TEXCOORD1;
#endif
            };

            struct v2f
            {
                float4 pos        : SV_POSITION;
                float2 texUV      : TEXCOORD0;
#if defined(MID_QUALITY)
                float2 lightmapUV : TEXCOORD1;
#endif
            }; 
            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos        = UnityObjectToClipPos(v.vertex);
#if defined(MID_QUALITY)
                o.texUV      = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.lightmapUV = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#else
                o.texUV      = TRANSFORM_UV(0);
#endif
                return o;
            }

            fixed4 frag(v2f i) : COLOR
            {
                fixed4 color    = tex2D(_MainTex, i.texUV);
#if defined(MID_QUALITY)
                fixed4 lightmap = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV);
                color.rgb       = color.rgb * DecodeLightmap(lightmap);
#endif
                return color;
            }

            ENDCG
        } // Pass
    } // SubShader

    //Fallback "Unlit/Texture"
} // Shader