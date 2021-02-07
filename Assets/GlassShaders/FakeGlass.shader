// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Silent/FakeGlass"
{
	Properties
	{
		[Header(Glass Colour)]_Color("Diffuse Color", Color) = (1,1,1,0)
		_MainTex("Tint Texture", 2D) = "white" {}
		[HDR]_Glow("Glow Strength", Color) = (0,0,0,0)
		[Normal][Header(Material Properties)]_BumpMap("Normal Map", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_IOR("IOR", Float) = 1
		[Gamma]_Refraction("Refraction Power", Range( 0 , 1)) = 0.1
		[Header(Additional Properties)]_SurfaceMask("Surface Mask", 2D) = "black" {}
		_SurfaceSmoothness("Surface Smoothness ", Range( 0 , 1)) = 0
		_SurfaceLevelTweak("Surface Level Tweak", Range( -1 , 1)) = 0
		_SurfaceSmoothnessTweak("Surface Smoothness Tweak", Range( -1 , 1)) = 0
		_OcclusionMap("Occlusion Map", 2D) = "white" {}
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Int) = 0
		_ShadowTransparency("Shadow Transparency", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent-6" "IsEmissive" = "true"  }
		Cull [_CullMode]
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		ColorMask RGB
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			half ASEVFace : VFACE;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform int _CullMode;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform float _Metallic;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform float _NormalScale;
		uniform float4 _Glow;
		uniform sampler2D _SurfaceMask;
		uniform float4 _SurfaceMask_ST;
		uniform float _SurfaceLevelTweak;
		uniform float _ShadowTransparency;
		uniform float _SurfaceSmoothnessTweak;
		uniform float _SurfaceSmoothness;
		uniform float _Refraction;
		uniform float _IOR;
		uniform float _Smoothness;
		uniform sampler2D _OcclusionMap;
		uniform float4 _OcclusionMap_ST;


		float SmoothnesstoRoughness56( float smoothness )
		{
			return SmoothnessToRoughness(smoothness);
		}


		float surfaceReduction55( float roughness )
		{
			    half surfaceReduction;
			#   ifdef UNITY_COLORSPACE_GAMMA
			        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
			#   else
			        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
			#   endif
			    return surfaceReduction;
		}


		float3 FresnelLerp47( float3 specColor , float grazingTerm , float nv )
		{
			 return FresnelLerp (specColor, grazingTerm, nv);
		}


		float InvFresnelPow5200( float x )
		{
			return 1-Pow5(1-x);
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 mainTex121 = tex2D( _MainTex, uv_MainTex );
			float4 temp_output_123_0 = ( mainTex121 * _Color );
			float4 mainTint174 = temp_output_123_0;
			float metallic177 = _Metallic;
			half3 specColor42 = (0).xxx;
			half oneMinusReflectivity42 = 0;
			half3 diffuseAndSpecularFromMetallic42 = DiffuseAndSpecularFromMetallic(mainTint174.rgb,metallic177,specColor42,oneMinusReflectivity42);
			float oneMinusReflectivity44 = oneMinusReflectivity42;
			float alpha37 = (temp_output_123_0).a;
			float temp_output_41_0 = ( ( 1.0 - oneMinusReflectivity44 ) + ( alpha37 * oneMinusReflectivity44 ) );
			float2 uv_SurfaceMask = i.uv_texcoord * _SurfaceMask_ST.xy + _SurfaceMask_ST.zw;
			float4 tex2DNode96 = tex2D( _SurfaceMask, uv_SurfaceMask );
			float surfaceLevel165 = saturate( ( tex2DNode96.r + _SurfaceLevelTweak ) );
			float3 temp_cast_3 = (saturate( ( temp_output_41_0 + surfaceLevel165 ) )).xxx;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float2 uv0_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float3 switchResult137 = (((i.ASEVFace>0)?(float3( 1,1,1 )):(float3(1,1,-1))));
			float3 normalMap87 = ( UnpackScaleNormal( tex2D( _BumpMap, uv0_BumpMap ), _NormalScale ) * switchResult137 );
			float3 newWorldNormal26 = (WorldNormalVector( i , normalMap87 ));
			float3 worldNormal206 = newWorldNormal26;
			float dotResult203 = dot( ase_worldlightDir , worldNormal206 );
			float premultipliedAlpha212 = temp_output_41_0;
			float surfaceSmoothness166 = ( saturate( ( _SurfaceSmoothnessTweak + tex2DNode96.r ) ) * _SurfaceSmoothness );
			float lerpResult209 = lerp( premultipliedAlpha212 , ( 1.0 - surfaceSmoothness166 ) , surfaceLevel165);
			float3 temp_cast_4 = ((lerpResult209 + (dotResult203 - -1.0) * (1.0 - lerpResult209) / (( 1.0 - _ShadowTransparency ) - -1.0))).xxx;
			float temp_output_2_0_g4 = _ShadowTransparency;
			float temp_output_3_0_g4 = ( 1.0 - temp_output_2_0_g4 );
			float3 appendResult7_g4 = (float3(temp_output_3_0_g4 , temp_output_3_0_g4 , temp_output_3_0_g4));
			#ifdef UNITY_PASS_SHADOWCASTER
				float3 staticSwitch201 = ( ( temp_cast_4 * temp_output_2_0_g4 ) + appendResult7_g4 );
			#else
				float3 staticSwitch201 = temp_cast_3;
			#endif
			float3 finalOpacity215 = staticSwitch201;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float temp_output_191_0 = ( _IOR - 1.0 );
			float3 indirectNormal1 = refract( ase_worldViewDir , newWorldNormal26 , ( _Refraction + temp_output_191_0 ) );
			float smoothness60 = _Smoothness;
			float2 uv0_OcclusionMap = i.uv_texcoord * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
			float occlusion116 = tex2D( _OcclusionMap, uv0_OcclusionMap ).g;
			Unity_GlossyEnvironmentData g1 = UnityGlossyEnvironmentSetup( smoothness60, data.worldViewDir, indirectNormal1, float3(0,0,0));
			float3 indirectSpecular1 = UnityGI_IndirectSpecular( data, occlusion116, indirectNormal1, g1 );
			float3 indirectNormal5 = refract( ase_worldViewDir , newWorldNormal26 , ( temp_output_191_0 + 0.0 ) );
			Unity_GlossyEnvironmentData g5 = UnityGlossyEnvironmentSetup( smoothness60, data.worldViewDir, indirectNormal5, float3(0,0,0));
			float3 indirectSpecular5 = UnityGI_IndirectSpecular( data, occlusion116, indirectNormal5, g5 );
			float3 indirectNormal7 = refract( ase_worldViewDir , newWorldNormal26 , ( -_Refraction + temp_output_191_0 ) );
			Unity_GlossyEnvironmentData g7 = UnityGlossyEnvironmentSetup( smoothness60, data.worldViewDir, indirectNormal7, float3(0,0,0));
			float3 indirectSpecular7 = UnityGI_IndirectSpecular( data, occlusion116, indirectNormal7, g7 );
			float3 appendResult4 = (float3((indirectSpecular1).x , (indirectSpecular5).y , (indirectSpecular7).z));
			float smoothness56 = smoothness60;
			float localSmoothnesstoRoughness56 = SmoothnesstoRoughness56( smoothness56 );
			float roughness55 = localSmoothnesstoRoughness56;
			float localsurfaceReduction55 = surfaceReduction55( roughness55 );
			float3 specColor47 = specColor42;
			float grazingTerm51 = saturate( ( smoothness60 + ( 1.0 - oneMinusReflectivity44 ) ) );
			float grazingTerm47 = grazingTerm51;
			float dotResult54 = dot( newWorldNormal26 , ase_worldViewDir );
			float NdotV181 = abs( dotResult54 );
			float nv47 = NdotV181;
			float3 localFresnelLerp47 = FresnelLerp47( specColor47 , grazingTerm47 , nv47 );
			float3 indirectNormal66 = WorldNormalVector( i , (WorldNormalVector( i , float3( (normalMap87).xy ,  0.0 ) )) );
			Unity_GlossyEnvironmentData g66 = UnityGlossyEnvironmentSetup( surfaceSmoothness166, data.worldViewDir, indirectNormal66, float3(0,0,0));
			float3 indirectSpecular66 = UnityGI_IndirectSpecular( data, occlusion116, indirectNormal66, g66 );
			float temp_output_2_0_g5 = metallic177;
			float temp_output_3_0_g5 = ( 1.0 - temp_output_2_0_g5 );
			float3 appendResult7_g5 = (float3(temp_output_3_0_g5 , temp_output_3_0_g5 , temp_output_3_0_g5));
			float x200 = NdotV181;
			float localInvFresnelPow5200 = InvFresnelPow5200( x200 );
			c.rgb = max( ( ( appendResult4 * localsurfaceReduction55 * localFresnelLerp47 ) + ( surfaceSmoothness166 * indirectSpecular66 * ( ( mainTint174.rgb * temp_output_2_0_g5 ) + appendResult7_g5 ) * localInvFresnelPow5200 ) ) , float3( 0,0,0 ) );
			c.a = finalOpacity215.x;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 mainTex121 = tex2D( _MainTex, uv_MainTex );
			float4 temp_output_123_0 = ( mainTex121 * _Color );
			float4 mainTint174 = temp_output_123_0;
			float metallic177 = _Metallic;
			half3 specColor42 = (0).xxx;
			half oneMinusReflectivity42 = 0;
			half3 diffuseAndSpecularFromMetallic42 = DiffuseAndSpecularFromMetallic(mainTint174.rgb,metallic177,specColor42,oneMinusReflectivity42);
			float alpha37 = (temp_output_123_0).a;
			o.Albedo = ( diffuseAndSpecularFromMetallic42 * alpha37 );
			float2 uv0_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float3 switchResult137 = (((i.ASEVFace>0)?(float3( 1,1,1 )):(float3(1,1,-1))));
			float3 normalMap87 = ( UnpackScaleNormal( tex2D( _BumpMap, uv0_BumpMap ), _NormalScale ) * switchResult137 );
			float3 newWorldNormal26 = (WorldNormalVector( i , normalMap87 ));
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult54 = dot( newWorldNormal26 , ase_worldViewDir );
			float NdotV181 = abs( dotResult54 );
			o.Emission = ( NdotV181 * _Glow * mainTex121 ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18301
2186;673;1654;1364;628.8091;-329.0947;1.206845;True;False
Node;AmplifyShaderEditor.SamplerNode;122;-1473.02,-307.8318;Inherit;True;Property;_MainTex;Tint Texture;1;0;Create;False;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-1127.235,-311.8233;Float;False;mainTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;34;-1185.428,-195.3818;Float;False;Property;_Color;Diffuse Color;0;0;Create;False;0;0;False;1;Header(Glass Colour);False;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;103;-2829.456,-641.3262;Inherit;False;1086.169;452.8964;Normal Map;8;28;87;9;30;137;139;140;153;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1282.262,78.10296;Float;False;Property;_Metallic;Metallic;7;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-891.0203,-243.8318;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;-2571.456,-489.403;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;153;-2660.094,-595.7634;Inherit;False;Property;_NormalScale;Normal Scale;5;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;139;-2549.384,-347.1627;Inherit;False;Constant;_NormalFlip;NormalFlip;13;0;Create;True;0;0;False;0;False;1,1,-1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-729.0396,-50.83344;Float;False;mainTint;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;177;-940.2236,110.738;Inherit;False;metallic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-1665.393,1727.191;Inherit;False;Property;_SurfaceSmoothnessTweak;Surface Smoothness Tweak;13;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DiffuseAndSpecularFromMetallicNode;42;-482.5618,98.80298;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;3;FLOAT3;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;96;-1681.393,1887.191;Inherit;True;Property;_SurfaceMask;Surface Mask;10;0;Create;True;0;0;False;1;Header(Additional Properties);False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwitchByFaceNode;137;-2237.384,-307.1627;Inherit;False;2;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;125;-705.0203,-253.8318;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-2347.14,-513.4296;Inherit;True;Property;_BumpMap;Normal Map;3;1;[Normal];Create;False;0;0;False;1;Header(Material Properties);False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-2047.384,-361.1627;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-80.24444,215.0795;Float;False;oneMinusReflectivity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;33;-400.0161,662.6182;Inherit;False;610;309;Premultiplied Alpha;4;38;41;40;39;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-404.01,19.59497;Float;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-1281.393,1743.191;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-1665.393,1807.191;Inherit;False;Property;_SurfaceSmoothness;Surface Smoothness ;11;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-345.5984,718.595;Inherit;False;37;alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-2002.285,-514.8854;Float;False;normalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;150;-1064.277,1745.757;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1530.43,1010.171;Float;False;Property;_Smoothness;Smoothness;6;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-1490.544,902.9796;Inherit;False;44;oneMinusReflectivity;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-1665.393,1647.191;Inherit;False;Property;_SurfaceLevelTweak;Surface Level Tweak;12;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;114;-1680.726,-874.8558;Inherit;False;1190.7;493.9;Occlusion;4;115;117;118;116;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-62.59837,831.595;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;151;-1281.393,1647.191;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2137.428,32.61816;Float;False;Property;_Refraction;Refraction Power;9;1;[Gamma];Create;False;0;0;False;0;False;0.1;0.09999994;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;39;-345.5983,810.595;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;118;-1438.417,-643.4614;Inherit;False;0;115;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;102;-2310.341,272.4379;Inherit;False;87;normalMap;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-894.2769,1770.757;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-1216.296,1003.883;Float;False;smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2135.428,120.6182;Float;False;Property;_IOR;IOR;8;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;-1214.675,665.5969;Inherit;False;60;smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;32;-1578.428,460.6182;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;-712.4203,1766.315;Inherit;False;surfaceSmoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;63;-1176.828,823.398;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;115;-1156.825,-683.7558;Inherit;True;Property;_OcclusionMap;Occlusion Map;14;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;26;-2084.727,261.7181;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;41;74.40163,763.595;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;53;-2085.912,413.3828;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;191;-1997.601,124.3519;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;146;-1066.277,1650.757;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;250.2271,659.2321;Inherit;False;premultipliedAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;165;-900.0392,1645.672;Inherit;False;surfaceLevel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;211;-3.836576,1862.167;Inherit;False;166;surfaceSmoothness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-823.0759,-637.6456;Float;False;occlusion;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;193;-1425.601,312.3519;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;192;-1421.601,193.3519;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-939.5111,773.2219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;194;-1407.601,447.3519;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;206;-1502.162,72.04053;Inherit;False;worldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;54;-1786.626,648.5461;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;213;-3.836538,1782.634;Inherit;False;212;premultipliedAlpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;205;204.1783,1455.986;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;214;218.1929,1939.491;Inherit;False;165;surfaceLevel;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;234.7912,1601.953;Inherit;False;206;worldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RefractOpVec;190;-1260.601,409.3519;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RefractOpVec;186;-1248.601,177.3519;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-26.50301,1690.219;Inherit;False;Property;_ShadowTransparency;Shadow Transparency;16;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;-811.5111,782.2219;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;210;231.4484,1864.376;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-1199.903,536.0563;Inherit;False;116;occlusion;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-929.3141,1389.613;Inherit;False;87;normalMap;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;57;-1666.129,651.106;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RefractOpVec;180;-1255.153,292.5882;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;225;465.5859,1687.314;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;45.49823,999.376;Inherit;False;165;surfaceLevel;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;7;-884.342,452.9867;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectSpecularLight;5;-881.342,338.9867;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;203;538.5459,1509.07;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;-1542.675,643.5696;Inherit;False;NdotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;164;-725.6722,1386.528;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-658.4658,757.0433;Float;False;grazingTerm;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;1;-882,223;Inherit;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;209;445.7453,1802.518;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;56;-959.6453,955.1857;Float;False;return SmoothnessToRoughness(smoothness)@$;1;False;1;True;smoothness;FLOAT;0;In;;Float;False;Smoothness to Roughness;True;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;-602.2236,1051.738;Inherit;False;177;metallic;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-343.966,549.6431;Inherit;False;51;grazingTerm;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;157;-478.6218,1319.428;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;175;-601.2544,1126.483;Inherit;False;174;mainTint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;6;-571.026,363.9601;Inherit;False;False;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;182;-334.6748,462.5696;Inherit;False;181;NdotV;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;3;-575.684,290.9734;Inherit;False;True;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;8;-566.026,444.9601;Inherit;False;False;False;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;252.1592,760.6245;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-15.4541,1421.07;Inherit;False;181;NdotV;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-477.0912,1230.584;Inherit;False;166;surfaceSmoothness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-463.6904,1471.434;Inherit;False;116;occlusion;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;208;667.7912,1515.953;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;0.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;55;-721.6453,958.1857;Float;False;    half surfaceReduction@$#   ifdef UNITY_COLORSPACE_GAMMA$        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness@      // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0@1]$#   else$        surfaceReduction = 1.0 / (roughness*roughness + 1.0)@           // fade \in [0.5@1]$#   endif$    return surfaceReduction@$;1;False;1;True;roughness;FLOAT;0;In;;Float;False;surfaceReduction;True;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;176;-351.2544,1035.483;Inherit;False;Lerp White To;-1;;5;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;47;-108.5445,506.4797;Float;False; return FresnelLerp (specColor, grazingTerm, nv)@;3;False;3;True;specColor;FLOAT3;1,1,1;In;;Float;False;True;grazingTerm;FLOAT;1;In;;Float;False;True;nv;FLOAT;0;In;;Float;False;FresnelLerp;True;False;0;3;0;FLOAT3;1,1,1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IndirectSpecularLight;66;-61.0536,1210.823;Inherit;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;1;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;200;176.5459,1359.07;Inherit;False;return 1-Pow5(1-x)@;1;False;1;True;x;FLOAT;0;In;;Inherit;False;InvFresnelPow5;True;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;-345.684,306.9734;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;224;895.3274,1528.571;Inherit;False;Lerp White To;-1;;4;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;106;429.8304,902.6027;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;193.5556,502.4798;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;201;596.5459,1100.07;Inherit;False;Property;_Keyword0;Keyword 0;16;0;Create;True;0;0;False;0;False;0;0;0;False;UNITY_PASS_SHADOWCASTER;Toggle;2;Key0;Key1;Fetch;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;317.6324,1028.665;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;210.2981,156.9906;Inherit;False;121;mainTex;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;109;173.8463,318.7032;Float;False;Property;_Glow;Glow Strength;2;1;[HDR];Create;False;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;907.4786,1093.35;Inherit;False;finalOpacity;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;537.1592,487.6246;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;133;-95.52808,-87.59631;Float;False;specColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;170;667.6545,489.5679;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;141;-1494.726,774.0547;Inherit;False;level = level * 3 - 1.5@$return saturate(float3($-level, 1-level, level))@;1;False;1;True;level;FLOAT;0;In;;Float;False;AberrationColour;True;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureTransformNode;28;-2779.456,-473.403;Inherit;False;9;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-57.01001,15.59497;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;637.9498,312.3799;Inherit;False;215;finalOpacity;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureTransformNode;117;-1646.417,-627.4614;Inherit;False;115;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.RangedFloatNode;65;-73.74048,303.2379;Float;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-1194.017,0.7037628;Inherit;False;165;surfaceLevel;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;113;-458.7034,-215.9207;Float;False;Property;_CullMode;Cull Mode;15;1;[Enum];Create;True;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;1;INT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;172;-923.5332,-7.15497;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-66.38965,125.9029;Float;False;finalAlbedo;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;441.2114,249.3541;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;226;496.5859,1375.314;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;869.2847,129.4671;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Silent/FakeGlass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;-6;True;Custom;;Transparent;All;14;all;True;True;True;False;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;1;1;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;4;-1;-1;-1;0;False;0;0;True;113;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;121;0;122;0
WireConnection;123;0;121;0
WireConnection;123;1;34;0
WireConnection;30;0;28;0
WireConnection;30;1;28;1
WireConnection;174;0;123;0
WireConnection;177;0;43;0
WireConnection;42;0;174;0
WireConnection;42;1;177;0
WireConnection;137;1;139;0
WireConnection;125;0;123;0
WireConnection;9;1;30;0
WireConnection;9;5;153;0
WireConnection;140;0;9;0
WireConnection;140;1;137;0
WireConnection;44;0;42;2
WireConnection;37;0;125;0
WireConnection;152;0;144;0
WireConnection;152;1;96;1
WireConnection;87;0;140;0
WireConnection;150;0;152;0
WireConnection;40;0;38;0
WireConnection;40;1;46;0
WireConnection;151;0;96;1
WireConnection;151;1;143;0
WireConnection;39;0;46;0
WireConnection;118;0;117;0
WireConnection;118;1;117;1
WireConnection;149;0;150;0
WireConnection;149;1;148;0
WireConnection;60;0;35;0
WireConnection;32;0;31;0
WireConnection;166;0;149;0
WireConnection;63;0;46;0
WireConnection;115;1;118;0
WireConnection;26;0;102;0
WireConnection;41;0;39;0
WireConnection;41;1;40;0
WireConnection;191;0;27;0
WireConnection;146;0;151;0
WireConnection;212;0;41;0
WireConnection;165;0;146;0
WireConnection;116;0;115;2
WireConnection;193;0;191;0
WireConnection;192;0;31;0
WireConnection;192;1;191;0
WireConnection;49;0;195;0
WireConnection;49;1;63;0
WireConnection;194;0;32;0
WireConnection;194;1;191;0
WireConnection;206;0;26;0
WireConnection;54;0;26;0
WireConnection;54;1;53;0
WireConnection;190;0;53;0
WireConnection;190;1;26;0
WireConnection;190;2;194;0
WireConnection;186;0;53;0
WireConnection;186;1;26;0
WireConnection;186;2;192;0
WireConnection;48;0;49;0
WireConnection;210;0;211;0
WireConnection;57;0;54;0
WireConnection;180;0;53;0
WireConnection;180;1;26;0
WireConnection;180;2;193;0
WireConnection;225;1;217;0
WireConnection;7;0;190;0
WireConnection;7;1;195;0
WireConnection;7;2;119;0
WireConnection;5;0;180;0
WireConnection;5;1;195;0
WireConnection;5;2;119;0
WireConnection;203;0;205;0
WireConnection;203;1;207;0
WireConnection;181;0;57;0
WireConnection;164;0;91;0
WireConnection;51;0;48;0
WireConnection;1;0;186;0
WireConnection;1;1;195;0
WireConnection;1;2;119;0
WireConnection;209;0;213;0
WireConnection;209;1;210;0
WireConnection;209;2;214;0
WireConnection;56;0;60;0
WireConnection;157;0;164;0
WireConnection;6;0;5;0
WireConnection;3;0;1;0
WireConnection;8;0;7;0
WireConnection;99;0;41;0
WireConnection;99;1;168;0
WireConnection;208;0;203;0
WireConnection;208;2;225;0
WireConnection;208;3;209;0
WireConnection;55;0;56;0
WireConnection;176;1;175;0
WireConnection;176;2;178;0
WireConnection;47;0;42;1
WireConnection;47;1;52;0
WireConnection;47;2;182;0
WireConnection;66;0;157;0
WireConnection;66;1;167;0
WireConnection;66;2;120;0
WireConnection;200;0;199;0
WireConnection;4;0;3;0
WireConnection;4;1;6;0
WireConnection;4;2;8;0
WireConnection;224;1;208;0
WireConnection;224;2;217;0
WireConnection;106;0;99;0
WireConnection;45;0;4;0
WireConnection;45;1;55;0
WireConnection;45;2;47;0
WireConnection;201;1;106;0
WireConnection;201;0;224;0
WireConnection;169;0;167;0
WireConnection;169;1;66;0
WireConnection;169;2;176;0
WireConnection;169;3;200;0
WireConnection;215;0;201;0
WireConnection;100;0;45;0
WireConnection;100;1;169;0
WireConnection;133;0;42;1
WireConnection;170;0;100;0
WireConnection;36;0;42;0
WireConnection;36;1;37;0
WireConnection;172;0;171;0
WireConnection;172;1;43;0
WireConnection;104;0;42;0
WireConnection;112;0;182;0
WireConnection;112;1;109;0
WireConnection;112;2;126;0
WireConnection;0;0;36;0
WireConnection;0;2;112;0
WireConnection;0;9;216;0
WireConnection;0;13;170;0
ASEEND*/
//CHKSM=EAA1542122877EEC05D45873BDA18B5C9ECE30CB