// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PPSG/Card Percent"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
		_BlendColor("Blend Color", Color) = (0, 0, 0, 1)
        _Alpha("Alpha", Float)  = 0.7
	    _AlphaCutoff("Alpha Cutoff", Range(0, 1)) = 0.5
    }

    SubShader
    {
        LOD 150
        Tags
        {
            "IgnoreProjector" = "True"
            "Queue"           = "Transparent"
            "RenderType"      = "Transparent"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
            Lighting Off
            ZWrite Off

            CGPROGRAM

            //#pragma only_renderers gles d3d9 d3d11_9x opengl
			#pragma exclude_renderers xbox360 ps3
            #pragma vertex   vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
            }; 
            
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv  = TRANSFORM_UV(0);

                return o;
            }

            sampler2D _MainTex;
			half4 _BlendColor;
            half _Alpha;
			float _AlphaCutoff;

            fixed4 frag(v2f i) : COLOR
            {
                float4 color = tex2D(_MainTex, i.uv);

				if(color.a < 0.5)
				{
					color.a = 0;
				}
				else
				{
					if (i.uv.y <= _AlphaCutoff)
					{
						color.a = 0;
					}
					else
					{
						color.a = _Alpha;
					}
				}
				
				color.rgb = _BlendColor.rgb;

                return  color;
            }

            ENDCG
        } // Pass
    } // SubShader

    Fallback "Unlit/Texture"
} // Shader
