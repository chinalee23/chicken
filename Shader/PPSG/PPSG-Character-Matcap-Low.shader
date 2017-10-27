// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PPSG/Character Matcap Low"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_Diffuse("Diffuse", 2D) = "white" {}
		_DiffuseIns("DiffuseIns", Range( 0 , 2)) = 1.126967
		_CubeMap("CubeMap", CUBE) = "white" {}
		_CubemapColor("CubemapColor", Color) = (1,0.8482759,0,0)
		_CubeMapIns("CubeMapIns", Range( 0 , 2)) = 1.158525
		_CubemapBlend("CubemapBlend", Range( 0 , 1)) = 0
		_RimColor("RimColor", Color) = (0.5102725,0.6384948,0.8897059,0)
		_RimLightIns("RimLightIns", Range( 0.5 , 10)) = 0
		_RimLightExp("RimLightExp", Range( 0 , 10)) = 0.9548794
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		ZTest LEqual
		ColorMask RGB
		LOD 200
		CGPROGRAM
		#pragma target 2.0
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

		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform fixed _DiffuseIns;
		uniform samplerCUBE _CubeMap;
		uniform fixed4 _CubemapColor;
		uniform fixed _CubeMapIns;
		uniform fixed _CubemapBlend;
		uniform fixed _RimLightExp;
		uniform fixed4 _RimColor;
		uniform fixed _RimLightIns;

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			fixed4 tex2DNode56 = tex2D( _Diffuse,uv_Diffuse);
			float3 worldrefVec46 = i.worldRefl;
			o.Albedo = lerp( ( tex2DNode56 * _DiffuseIns ) , ( ( ( ( texCUBE( _CubeMap,worldrefVec46) * _CubemapColor ) * tex2DNode56.a ) * 5 ) * _CubeMapIns ) , ( tex2DNode56.a * _CubemapBlend ) ).rgb;
			o.Emission = ( ( pow( ( 1.0 - saturate( dot( i.worldNormal , normalize( i.viewDir ) ) ) ) , _RimLightExp ) * _RimColor ) * _RimLightIns ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=7003
1956;46;1906;982;3680.256;1259.104;2.5;True;True
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;148;-2678.857,321.5963;Float;False;World;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.NormalizeNode;74;-2448.076,287.3976;Float;False;0;FLOAT3;0,0,0;False;FLOAT3
Node;AmplifyShaderEditor.WorldNormalVector;149;-2698.857,86.59628;Float;False;0;FLOAT3;0,0,0;False;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.WorldReflectionVector;46;-2342.411,-662.2816;Float;True;0;FLOAT3;0,0,0;False;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DotProductOpNode;72;-2079.17,307.5977;Float;False;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;FLOAT
Node;AmplifyShaderEditor.ColorNode;66;-1972.173,-460.0091;Float;False;Property;_CubemapColor;CubemapColor;5;0;1,0.8482759,0,0;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;45;-2009.221,-728.0748;Float;True;Property;_CubeMap;CubeMap;4;0;Assets/NewArts/Character/Avatar/Common/char_reflection_env.exr;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;1.0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SaturateNode;80;-1893.672,304.4977;Float;False;0;FLOAT;1.23;False;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1553.141,-582.0667;Float;False;0;FLOAT4;0.0;False;1;COLOR;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SamplerNode;56;-1539.182,-130.1702;Float;True;Property;_Diffuse;Diffuse;0;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;79;-2060.621,522.9114;Float;False;Property;_RimLightExp;RimLightExp;13;0;0.9548794;0;10;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;81;-1719.766,293.4968;Float;False;0;FLOAT;0;False;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1363.725,-592.1379;Float;False;0;COLOR;0.0,0,0,0;False;1;FLOAT;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;70;-877.5094,-133.1587;Float;False;Property;_CubemapBlend;CubemapBlend;7;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;77;-1516.267,269.9976;Float;False;0;FLOAT;0.0;False;1;FLOAT;0.0;False;FLOAT
Node;AmplifyShaderEditor.ColorNode;78;-1751.467,647.6002;Float;False;Property;_RimColor;RimColor;11;0;0.5102725,0.6384948,0.8897059,0;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ScaleNode;53;-1235.137,-997.7488;Float;True;5;0;COLOR;0.0;False;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;63;-1199.265,-461.0962;Float;False;Property;_CubeMapIns;CubeMapIns;6;0;1.158525;0;2;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;68;-834.5878,-819.0119;Float;False;Property;_DiffuseIns;DiffuseIns;1;0;1.126967;0;2;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;150;-1223.26,693.6963;Float;False;Property;_RimLightIns;RimLightIns;12;0;0;0.5;10;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-458.9142,-1006.459;Float;True;0;FLOAT4;0.0;False;1;FLOAT;0.0,0,0,0;False;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-1215.769,345.5966;Float;False;0;FLOAT;0;False;1;COLOR;0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-849.2966,-554.0994;Float;False;0;COLOR;0.0;False;1;FLOAT;0.0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-592.134,-401.2226;Float;False;0;FLOAT;0.0;False;1;FLOAT;0.0,0,0,0;False;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-821.0585,386.8962;Float;False;0;COLOR;0.0;False;1;FLOAT;0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.LerpOp;58;-140.7703,-649.1354;Float;True;0;FLOAT4;0.0;False;1;COLOR;0.0,0,0,0;False;2;FLOAT;0,0,0,0;False;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-395.0998,150.8;Fixed;False;True;0;Fixed;ASEMaterialInspector;0;Lambert;PPSG/Character Matcap Low;False;False;False;False;False;False;True;True;True;False;False;True;Back;0;3;False;0;0;Opaque;0.5;True;False;0;False;Opaque;Geometry;ForwardOnly;True;True;True;True;True;True;False;False;False;False;False;False;False;True;True;True;False;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;False;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;Relative;0;;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;13;OBJECT;0.0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False
WireConnection;74;0;148;0
WireConnection;72;0;149;0
WireConnection;72;1;74;0
WireConnection;45;1;46;0
WireConnection;80;0;72;0
WireConnection;64;0;45;0
WireConnection;64;1;66;0
WireConnection;81;0;80;0
WireConnection;71;0;64;0
WireConnection;71;1;56;4
WireConnection;77;0;81;0
WireConnection;77;1;79;0
WireConnection;53;0;71;0
WireConnection;67;0;56;0
WireConnection;67;1;68;0
WireConnection;76;0;77;0
WireConnection;76;1;78;0
WireConnection;60;0;53;0
WireConnection;60;1;63;0
WireConnection;69;0;56;4
WireConnection;69;1;70;0
WireConnection;151;0;76;0
WireConnection;151;1;150;0
WireConnection;58;0;67;0
WireConnection;58;1;60;0
WireConnection;58;2;69;0
WireConnection;0;0;58;0
WireConnection;0;2;151;0
ASEEND*/
//CHKSM=04CB628C492910E8EC90E32F86721106E1779F9C