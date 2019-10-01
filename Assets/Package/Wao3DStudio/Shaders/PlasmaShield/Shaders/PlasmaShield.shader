// Upgrade NOTE: replaced 'UNITY_INSTANCE_ID' with 'UNITY_VERTEX_INPUT_INSTANCE_ID'

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Wao3DStudio/FX/PlasmaShield"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
		_AlphaTexture01("AlphaTexture01", 2D) = "white" {}
		_AlphaTexture02("AlphaTexture02", 2D) = "white" {}
		_Opacity("Opacity", Range( -5 , 0)) = -10
		_Distorsion("Distorsion", Range( 1 , 2)) = 0.5
		_ShieldColor("ShieldColor", Color) = (0.5147059,0.8995942,1,0)
		_EmissionColor("Emission Color", Color) = (0.5441177,0.9082841,1,1)
		_ShieldPower("ShieldPower", Range( 0 , 10)) = 1
		_EmissionPower("EmissionPower", Range( 0 , 10)) = 0
		_IntersectionColor("Intersection Color", Color) = (0.03137255,0.2588235,0.3176471,1)
		_IntersectionFalloff("Intersection Falloff", Range( 0 , 1)) = 0.1870691
		_Fresnel("Fresnel", Range( 7 , 10)) = 8
		_HitColor("HitColor", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 texcoord_0;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
		};

		uniform float4 _ShieldColor;
		uniform sampler2D _AlphaTexture02;
		uniform sampler2D _AlphaTexture01;
		uniform float _Distorsion;
		uniform float _ShieldPower;
		uniform float4 _IntersectionColor;
		uniform float _Fresnel;
		uniform float4 _HitColor;
		uniform float4 _EmissionColor;
		uniform float _EmissionPower;
		uniform sampler2D _CameraDepthTexture;
		uniform float _IntersectionFalloff;
		uniform float _Opacity;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.texcoord_0.xy = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_output_293_0 = lerp( (abs( i.texcoord_0+_Time[1] * float2(0,0.01 ))) , (abs( i.texcoord_0+_Time[1] * float2(-0.01,0 ))) , 0.0 );
			float4 tex2DNode301 = tex2D( _AlphaTexture01, temp_output_293_0 );
			float4 tex2DNode311 = tex2D( _AlphaTexture02, ( lerp( tex2DNode301 , float4( i.texcoord_0, 0.0 , 0.0 ) , _Distorsion ) + float4( lerp( temp_output_293_0 , i.texcoord_0 , float2( 0,0 ) ), 0.0 , 0.0 ) ).xy );
			float4 ALbedo = ( ( _ShieldColor * tex2DNode311 ) * _ShieldPower );
			o.Albedo = ALbedo.rgb;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelFinalVal303 = (0.0 + 1.0*pow( 1.0 - dot( ase_worldNormal, worldViewDir ) , (10.0 + (_Fresnel - 0.0) * (0.0 - 10.0) / (10.0 - 0.0))));
			float4 ShieldPattern = tex2DNode311;
			float4 waves = tex2DNode301;
			float4 temp_cast_6 = (0.0).xxxx;
			float4 ase_vertexPos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float temp_output_288_0 = distance( ase_vertexPos.xyz , float3(0,0,0) );
			float4 EmissionColor = _EmissionColor;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float screenDepth323 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(ase_screenPos))));
			float distanceDepth323 = abs( ( screenDepth323 - LinearEyeDepth( ase_screenPos.z/ ase_screenPos.w ) ) / _IntersectionFalloff );
			float4 Emission = lerp( _IntersectionColor , ( ( ( clamp( ( fresnelFinalVal303 * 2.0 ) , 1.0 , 2.0 ) + ShieldPattern ) * waves ) * ( (( temp_cast_6 > _HitColor ) ? (( temp_output_288_0 < 0.2 ) ? lerp( EmissionColor , ( _HitColor * ( 0.2 / temp_output_288_0 ) ) , (0.0 + (0.0 - 0.0) * (1.0 - 0.0) / (100.0 - 0.0)) ) :  EmissionColor ) :  EmissionColor ) * EmissionColor * _EmissionPower ) ) , clamp( distanceDepth323 , 0.0 , 1.0 ) );
			o.Emission = Emission.xyz;
			float Opacity = ( tex2DNode311.g * ( 1.0 - _Opacity ) );
			o.Alpha = Opacity;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			# include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD6;
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "Wao3DStudio"
}
/*ASEBEGIN
Version=11002
12;514;1513;937;687.875;501.181;1;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;356;-1998.187,-1314.979;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.PannerNode;289;-1582.968,-1160.132;Float;False;-0.01;0;2;0;FLOAT2;0,0;False;1;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.PannerNode;291;-1564.66,-1407.548;Float;False;0;0.01;2;0;FLOAT2;0,0;False;1;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.RangedFloatNode;358;-1366.784,-1121.179;Float;False;Constant;_Float0;Float 0;13;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.Vector3Node;286;-2620.576,14.60599;Float;False;Constant;_Vector4;Vector 4;8;0;0,0,0;0;4;FLOAT3;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.PosVertexDataNode;287;-2647.082,-408.6927;Float;False;0;0;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;293;-1226.337,-1429.197;Float;False;3;0;FLOAT2;0.0;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;1;FLOAT2
Node;AmplifyShaderEditor.DistanceOpNode;288;-2349.278,-211.1929;Float;False;2;0;FLOAT3;0.0;False;1;FLOAT3;0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;290;-2187.573,-349.0952;Float;False;Constant;_Float3;Float 3;11;0;0.2;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;295;-1922.178,-844.6489;Float;False;Property;_Fresnel;Fresnel;10;0;8;7;10;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;301;-962.0134,-1507.664;Float;True;Property;_AlphaTexture01;AlphaTexture01;0;0;Assets/Wao3DStudio/Shaders/Plasma/Textures/AlphaCircles.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;298;-987.4664,-950.949;Float;False;Property;_Distorsion;Distorsion;3;0;0.5;1;2;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleDivideOpNode;294;-1910.887,178.2747;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;299;-660.8232,651.153;Float;False;Property;_EmissionColor;Emission Color;5;0;0.5441177,0.9082841,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;307;-921.7627,-1162.375;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2
Node;AmplifyShaderEditor.LerpOp;305;-548.4699,-1329.905;Float;False;3;0;FLOAT4;0,0;False;1;FLOAT2;0,0,0,0;False;2;FLOAT;0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.TFHCRemap;297;-1608.874,-795.1931;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;10.0;False;3;FLOAT;10.0;False;4;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;364;-2695.177,-106.5833;Float;False;Constant;_Float1;Float 1;11;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;292;-2245.267,113.2068;Float;False;Property;_HitColor;HitColor;11;0;1,1,1,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.TFHCRemap;302;-2286.488,-25.52591;Float;False;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;100.0;False;3;FLOAT;0.0;False;4;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.RegisterLocalVarNode;359;-319.5778,673.02;Float;False;EmissionColor;-1;True;1;0;COLOR;0.0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;304;-1433.785,-419.9579;Float;False;Constant;_Float11;Float 11;14;0;2;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleAddOpNode;310;-346.9526,-1174.178;Float;False;2;2;0;FLOAT4;0,0;False;1;FLOAT2;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.FresnelNode;303;-1395.972,-724.4932;Float;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;3;FLOAT;5.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;300;-1750.292,72.07426;Float;False;2;2;0;COLOR;0.0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.GetLocalVarNode;362;-1954.281,-395.7811;Float;False;359;0;1;COLOR
Node;AmplifyShaderEditor.LerpOp;306;-1556.692,-27.62491;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.0;False;1;COLOR
Node;AmplifyShaderEditor.SamplerNode;311;-209.6293,-982.5873;Float;True;Property;_AlphaTexture02;AlphaTexture02;1;0;Assets/Wao3DStudio/Shaders/Plasma/Textures/AlphaElectric.png;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT4;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;-1133.486,-622.5593;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.ClampOpNode;315;-958.9825,-541.1573;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;1.0;False;2;FLOAT;2.0;False;1;FLOAT
Node;AmplifyShaderEditor.RegisterLocalVarNode;317;810.6343,-1206.895;Float;False;ShieldPattern;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.TFHCCompareLower;309;-1331.275,-196.56;Float;False;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.GetLocalVarNode;314;-1082.505,-42.337;Float;False;317;0;1;FLOAT4
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;-491.1727,-1513.01;Float;False;waves;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleAddOpNode;318;-704.6779,-99.19798;Float;False;2;2;0;FLOAT;0.0,0,0,0;False;1;FLOAT4;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.TFHCCompareGreater;313;-1008.888,-375.3611;Float;False;4;0;FLOAT;0.0,0,0,0;False;1;COLOR;0.0;False;2;COLOR;0.0;False;3;COLOR;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;316;-1061.891,270.1288;Float;False;Property;_IntersectionFalloff;Intersection Falloff;9;0;0.1870691;0;1;0;1;FLOAT
Node;AmplifyShaderEditor.GetLocalVarNode;360;-726.7771,-304.8803;Float;False;359;0;1;COLOR
Node;AmplifyShaderEditor.GetLocalVarNode;319;-1010.425,124.0501;Float;False;312;0;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;296;-701.291,-216.18;Float;False;Property;_EmissionPower;EmissionPower;7;0;0;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.ColorNode;321;-130.7115,-1550.044;Float;False;Property;_ShieldColor;ShieldColor;4;0;0.5147059,0.8995942,1,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;322;-520.4387,-28.06392;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.DepthFade;323;-613.9505,302.2223;Float;False;1;0;FLOAT;0.5;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;353;-271.6125,-457.0039;Float;False;Property;_Opacity;Opacity;2;0;-10;-5;0;0;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;324;-415.6055,-385.5059;Float;False;3;3;0;COLOR;0.0,0,0,0;False;1;COLOR;0.0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;326;-158.4935,-79.44494;Float;True;2;2;0;FLOAT4;0.0;False;1;COLOR;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.OneMinusNode;345;219.2586,-820.0187;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;328;193.3084,-1413.097;Float;False;2;2;0;COLOR;0.0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.ColorNode;329;-107.7026,-316.8387;Float;False;Property;_IntersectionColor;Intersection Color;8;0;0.03137255,0.2588235,0.3176471,1;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;352;208.1873,-1177.904;Float;False;Property;_ShieldPower;ShieldPower;6;0;1;0;10;0;1;FLOAT
Node;AmplifyShaderEditor.ClampOpNode;327;-285.4955,205.6505;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;330;239.2994,-65.83995;Float;False;3;0;COLOR;0,0,0,0;False;1;FLOAT4;0.0,0,0,0;False;2;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;331;541.5965,-1380.387;Float;False;2;2;0;COLOR;0;False;1;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;346;495.1385,-1014.944;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.GetLocalVarNode;350;1911.897,-457.5056;Float;False;333;0;1;FLOAT
Node;AmplifyShaderEditor.RegisterLocalVarNode;347;845.9951,-1338.805;Float;False;ALbedo;-1;True;1;0;COLOR;0.0;False;1;COLOR
Node;AmplifyShaderEditor.RegisterLocalVarNode;336;401.5655,-63.33294;Float;False;Emission;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.GetLocalVarNode;351;1877.596,-779.306;Float;False;347;0;1;COLOR
Node;AmplifyShaderEditor.RegisterLocalVarNode;333;794.7964,-1050.507;Float;False;Opacity;-1;True;1;0;FLOAT;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.GetLocalVarNode;349;1895.485,-622.1088;Float;False;336;0;1;FLOAT4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2272.058,-680.8273;Float;False;True;2;Float;Wao3DStudio;0;Standard;Wao3DStudio/FX/PlasmaShield;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;Off;1;7;False;0;0;Transparent;0.5;True;True;0;False;Transparent;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;Relative;0;;-1;-1;-1;-1;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;OBJECT;0.0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;289;0;356;0
WireConnection;291;0;356;0
WireConnection;293;0;291;0
WireConnection;293;1;289;0
WireConnection;293;2;358;0
WireConnection;288;0;287;0
WireConnection;288;1;286;0
WireConnection;301;1;293;0
WireConnection;294;0;290;0
WireConnection;294;1;288;0
WireConnection;307;0;293;0
WireConnection;307;1;356;0
WireConnection;305;0;301;0
WireConnection;305;1;356;0
WireConnection;305;2;298;0
WireConnection;297;0;295;0
WireConnection;302;0;364;0
WireConnection;359;0;299;0
WireConnection;310;0;305;0
WireConnection;310;1;307;0
WireConnection;303;3;297;0
WireConnection;300;0;292;0
WireConnection;300;1;294;0
WireConnection;306;0;362;0
WireConnection;306;1;300;0
WireConnection;306;2;302;0
WireConnection;311;1;310;0
WireConnection;308;0;303;0
WireConnection;308;1;304;0
WireConnection;315;0;308;0
WireConnection;317;0;311;0
WireConnection;309;0;288;0
WireConnection;309;1;290;0
WireConnection;309;2;306;0
WireConnection;309;3;362;0
WireConnection;312;0;301;0
WireConnection;318;0;315;0
WireConnection;318;1;314;0
WireConnection;313;0;364;0
WireConnection;313;1;292;0
WireConnection;313;2;309;0
WireConnection;313;3;362;0
WireConnection;322;0;318;0
WireConnection;322;1;319;0
WireConnection;323;0;316;0
WireConnection;324;0;313;0
WireConnection;324;1;360;0
WireConnection;324;2;296;0
WireConnection;326;0;322;0
WireConnection;326;1;324;0
WireConnection;345;0;353;0
WireConnection;328;0;321;0
WireConnection;328;1;311;0
WireConnection;327;0;323;0
WireConnection;330;0;329;0
WireConnection;330;1;326;0
WireConnection;330;2;327;0
WireConnection;331;0;328;0
WireConnection;331;1;352;0
WireConnection;346;0;311;2
WireConnection;346;1;345;0
WireConnection;347;0;331;0
WireConnection;336;0;330;0
WireConnection;333;0;346;0
WireConnection;0;0;351;0
WireConnection;0;2;349;0
WireConnection;0;9;350;0
ASEEND*/
//CHKSM=0EC129D1D8AFD7F4E4E306E878548A2514A6D9DA