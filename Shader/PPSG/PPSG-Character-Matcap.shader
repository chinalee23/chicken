// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PPSG/Character Matcap"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Diffuse("Diffuse", 2D) = "white" {}
		_DiffuseIns("DiffuseIns", Range( 0 , 2)) = 2.419182
		_NormalMap("Normal Map", 2D) = "bump" {}
		_Mask("Mask", 2D) = "white" {}
		_CubeMap("CubeMap", CUBE) = "white" {}
		_CubemapColor("CubemapColor", Color) = (1,0.8482759,0,0)
		_CubeMapIns("CubeMapIns", Range( 0 , 2)) = 1
		_CubemapBlend("CubemapBlend", Range( 0 , 1)) = 1
		_SkinMatcap("SkinMatcap", 2D) = "white" {}
		_SkinMatcapColor("SkinMatcapColor", Color) = (0,0,0,0)
		_SkinMatcapIns("SkinMatcapIns", Range( 0 , 5)) = 0
		_RimColor("RimColor", Color) = (0,0,0,0)
		_RimLightIns("RimLightIns", Range( 0.5 , 10)) = 0
		_RimLightExp("RimLightExp", Range( 0.5 , 10)) = 3
		_HairCubemap("HairCubemap", CUBE) = "white" {}
		_HairColor("HairColor", Color) = (1,0.8482759,0,0)
		_HairIns("HairIns", Range( 0 , 10)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		ZTest LEqual
		ColorMask RGB
		LOD 400
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		//#pragma target 3.0
		#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
		#pragma surface surf Lambert keepalpha  noshadow exclude_path:deferred exclude_path:prepass nolightmap  nodynlightmap nodirlightmap noforwardadd nolppv noshadowmask
		struct Input
		{
			float2 uv_texcoord;
			float3 worldRefl;
			INTERNAL_DATA
			float3 worldNormal;
			float3 viewDir;
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform fixed _DiffuseIns;
		uniform samplerCUBE _CubeMap;
		uniform fixed4 _CubemapColor;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform fixed _CubeMapIns;
		uniform fixed _CubemapBlend;
		uniform samplerCUBE _HairCubemap;
		uniform fixed4 _HairColor;
		uniform fixed _HairIns;
		uniform sampler2D _SkinMatcap;
		uniform fixed4 _SkinMatcapColor;
		uniform fixed _SkinMatcapIns;
		uniform fixed _RimLightExp;
		uniform fixed4 _RimColor;
		uniform fixed _RimLightIns;

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			o.Normal = UnpackNormal( tex2D( _NormalMap,uv_NormalMap) );
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			fixed3 tex2DNode54 = UnpackNormal( tex2D( _NormalMap,uv_NormalMap) );
			float3 worldrefVec46 = WorldReflectionVector( i , tex2DNode54 );
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			fixed4 tex2DNode132 = tex2D( _Mask,uv_Mask);
			o.Albedo = ( lerp( ( tex2D( _Diffuse,uv_Diffuse) * _DiffuseIns ) , ( ( ( ( texCUBE( _CubeMap,worldrefVec46) * _CubemapColor ) * tex2DNode132.r ) * 5 ) * _CubeMapIns ) , ( tex2DNode132.r * _CubemapBlend ) ) + ( ( ( texCUBE( _HairCubemap,worldrefVec46) * _HairColor ) * tex2DNode132.b ) * _HairIns ) ).rgb;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			fixed3 temp_cast_5 = (0.5).xxx;
			o.Emission = lerp( ( ( ( tex2D( _SkinMatcap,( ( mul( UNITY_MATRIX_V , fixed4( ase_worldNormal , 0.0 ) ) * 0.5 ) + temp_cast_5 ).xy) * _SkinMatcapColor ) * tex2DNode132.g ) * _SkinMatcapIns ) , ( ( ( pow( ( 1.0 - saturate( dot( tex2DNode54 , normalize( i.viewDir ) ) ) ) , _RimLightExp ) * _RimColor ) * tex2DNode132.g ) * _RimLightIns ) , 0.5 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}

	Fallback "PPSG/Character Matcap Low"

	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=7003
1956;46;1906;982;5298.475;1090.083;4.3;True;True
Node;AmplifyShaderEditor.CommentaryNode;133;-3178.41,1155.77;Float;False;2837.877;1448.083;SkinMatcap;26;75;100;101;74;103;102;72;104;80;81;105;79;116;106;78;77;114;76;111;109;131;128;108;110;130;107;
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;75;-3128.41,2082.85;Float;False;Tangent;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.WorldNormalVector;100;-2408.355,1299.903;Float;False;0;FLOAT3;0,0,0;False;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;54;-2754.175,-240.0123;Float;True;Property;_NormalMap;Normal Map;2;0;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.NormalizeNode;74;-2852.911,2087.45;Float;False;0;FLOAT3;0,0,0;False;FLOAT3
Node;AmplifyShaderEditor.ViewMatrixNode;101;-2328.167,1205.77;Float;False;FLOAT4x4
Node;AmplifyShaderEditor.RangedFloatNode;103;-2195.439,1362.93;Float;False;Constant;_Float2;Float 2;-1;0;0.5;0;0;FLOAT
Node;AmplifyShaderEditor.WorldReflectionVector;46;-2328.958,-662.2816;Float;True;0;FLOAT3;0,0,0;False;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DotProductOpNode;72;-2584.208,2064.05;Float;False;0;FLOAT3;0.0,0,0;False;1;FLOAT3;0.0,0,0;False;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-2169.623,1235.556;Float;False;0;FLOAT4x4;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;False;1;FLOAT3;0.0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;False;FLOAT3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-2002.367,1272.001;Float;False;0;FLOAT3;0.0,0,0;False;1;FLOAT;0,0,0;False;FLOAT3
Node;AmplifyShaderEditor.SaturateNode;80;-2444.01,2063.55;Float;False;0;FLOAT;1.23;False;FLOAT
Node;AmplifyShaderEditor.ColorNode;66;-1953.641,-437.767;Float;False;Property;_CubemapColor;CubemapColor;5;0;1,0.8482759,0,0;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;45;-2024.858,-689.2065;Float;True;Property;_CubeMap;CubeMap;4;0;Assets/AmplifyShaderEditor/Examples/Assets/Textures/Misc/Cubemap.jpg;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;1.0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;81;-2259.005,2063.849;Float;False;0;FLOAT;0;False;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;79;-2705.058,2346.564;Float;False;Property;_RimLightExp;RimLightExp;13;0;3;0.5;10;FLOAT
Node;AmplifyShaderEditor.SamplerNode;132;-3086.153,204.2323;Float;True;Property;_Mask;Mask;3;0;Assets/Art/Texture/Mask.tga;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;105;-1845.057,1322.078;Float;False;0;FLOAT3;0.0,0,0;False;1;FLOAT;0.0,0,0;False;FLOAT3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1553.141,-582.0667;Float;False;0;FLOAT4;0.0;False;1;COLOR;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SamplerNode;106;-1640.713,1292.495;Float;True;Property;_SkinMatcap;SkinMatcap;8;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;0;SAMPLER2D;0,0;False;1;FLOAT2;1.0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;121;-1432.912,569.3965;Float;False;Property;_HairColor;HairColor;15;0;1,0.8482759,0,0;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.CommentaryNode;52;-1331.059,-955.207;Float;False;292.1999;260.6;Multiplier to make it POP;1;53;
Node;AmplifyShaderEditor.SamplerNode;134;-1510.176,224.7149;Float;True;Property;_HairCubemap;HairCubemap;14;0;Assets/AmplifyShaderEditor/Examples/Assets/Textures/Misc/Cubemap.jpg;True;0;False;white;Auto;False;Object;-1;Auto;Cube;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;1.0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.PowerNode;77;-2054.206,2064.25;Float;False;0;FLOAT;0.0;False;1;FLOAT;0.0;False;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1373.725,-584.1379;Float;False;0;COLOR;0.0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.ColorNode;116;-1581.632,1519.164;Float;False;Property;_SkinMatcapColor;SkinMatcapColor;9;0;0,0,0,0;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;78;-2273.406,2396.853;Float;False;Property;_RimColor;RimColor;11;0;0,0,0,0;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-1780.806,2063.449;Float;False;0;FLOAT;0;False;1;COLOR;0;False;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;70;-1081.925,-366.6377;Float;False;Property;_CubemapBlend;CubemapBlend;7;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-1091.496,446.5392;Float;False;0;FLOAT4;0.0,0,0,0;False;1;COLOR;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-1326.631,1297.065;Float;False;0;FLOAT4;0.0;False;1;COLOR;0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SamplerNode;56;-996.4345,-878.0593;Float;True;Property;_Diffuse;Diffuse;0;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;68;-938.8456,-1072.37;Float;False;Property;_DiffuseIns;DiffuseIns;1;0;2.419182;0;2;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;63;-1219.159,-657.6066;Float;False;Property;_CubeMapIns;CubeMapIns;6;0;1;0;2;FLOAT
Node;AmplifyShaderEditor.ScaleNode;53;-1254.195,-918.1539;Float;True;5;0;COLOR;0.0;False;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;111;-1240.732,1517.564;Float;False;Property;_SkinMatcapIns;SkinMatcapIns;10;0;0;0;5;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;131;-1494.75,2367.76;Float;False;Property;_RimLightIns;RimLightIns;12;0;0;0.5;10;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-644.046,-1035.37;Float;True;0;FLOAT4;0.0;False;1;FLOAT;0.0,0,0,0;False;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-844.2795,446.4682;Float;False;0;COLOR;0.0;False;1;FLOAT;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;127;-909.4846,679.6511;Float;False;Property;_HairIns;HairIns;16;0;0;0;10;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-754.0336,-486.3226;Float;False;0;FLOAT;0.0;False;1;FLOAT;0.0,0,0,0;False;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-1178.132,1297.163;Float;True;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-848.4389,-676.9364;Float;False;0;COLOR;0.0;False;1;FLOAT;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-1388.048,2060.961;Float;True;0;COLOR;0.0;False;1;FLOAT;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-593.1853,447.6514;Float;True;0;COLOR;0.0;False;1;FLOAT;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-1092.549,2060.96;Float;False;0;COLOR;0.0;False;1;FLOAT;0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.LerpOp;58;-421.065,-696.0041;Float;True;0;FLOAT4;0.0;False;1;COLOR;0.0,0,0,0;False;2;FLOAT;0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-820.8336,1356.864;Float;False;0;COLOR;0.0;False;1;FLOAT;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;108;-678.3296,2011.36;Float;False;Constant;_SkinLerp;SkinLerp;10;0;0.5;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-4.842651,-489.5628;Float;True;0;COLOR;0.0;False;1;COLOR;0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.LerpOp;107;-605.5321,1504.362;Float;True;0;COLOR;0,0,0,0;False;1;COLOR;0.0,0,0,0;False;2;FLOAT;0.0;False;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;713.3,48.80001;Fixed;False;True;2;Fixed;ASEMaterialInspector;0;Lambert;PPSG/Character Matcap;False;False;False;False;False;False;True;True;True;False;False;True;Back;0;3;False;0;0;Opaque;0.5;True;False;0;False;Opaque;Geometry;ForwardOnly;True;True;True;True;True;True;False;False;False;False;False;False;False;True;True;True;False;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;Relative;0;;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;13;OBJECT;0.0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False
WireConnection;74;0;75;0
WireConnection;46;0;54;0
WireConnection;72;0;54;0
WireConnection;72;1;74;0
WireConnection;102;0;101;0
WireConnection;102;1;100;0
WireConnection;104;0;102;0
WireConnection;104;1;103;0
WireConnection;80;0;72;0
WireConnection;45;1;46;0
WireConnection;81;0;80;0
WireConnection;105;0;104;0
WireConnection;105;1;103;0
WireConnection;64;0;45;0
WireConnection;64;1;66;0
WireConnection;106;1;105;0
WireConnection;134;1;46;0
WireConnection;77;0;81;0
WireConnection;77;1;79;0
WireConnection;71;0;64;0
WireConnection;71;1;132;1
WireConnection;76;0;77;0
WireConnection;76;1;78;0
WireConnection;120;0;134;0
WireConnection;120;1;121;0
WireConnection;114;0;106;0
WireConnection;114;1;116;0
WireConnection;53;0;71;0
WireConnection;67;0;56;0
WireConnection;67;1;68;0
WireConnection;119;0;120;0
WireConnection;119;1;132;3
WireConnection;69;0;132;1
WireConnection;69;1;70;0
WireConnection;109;0;114;0
WireConnection;109;1;132;2
WireConnection;60;0;53;0
WireConnection;60;1;63;0
WireConnection;128;0;76;0
WireConnection;128;1;132;2
WireConnection;126;0;119;0
WireConnection;126;1;127;0
WireConnection;130;0;128;0
WireConnection;130;1;131;0
WireConnection;58;0;67;0
WireConnection;58;1;60;0
WireConnection;58;2;69;0
WireConnection;110;0;109;0
WireConnection;110;1;111;0
WireConnection;125;0;58;0
WireConnection;125;1;126;0
WireConnection;107;0;110;0
WireConnection;107;1;130;0
WireConnection;107;2;108;0
WireConnection;0;0;125;0
WireConnection;0;1;54;0
WireConnection;0;2;107;0
ASEEND*/
//CHKSM=C726637DE60462004E5733F7D3C37FCF1C3A5061