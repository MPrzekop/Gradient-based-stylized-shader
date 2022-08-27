// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Przekop/Custom Lighting/Gradient Shading"
{
	Properties
	{
		[Header(Base)]_MainTexture("Main Texture", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		[NoScaleOffset][Normal][SingleLineTexture]_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 5)) = 0
		[NoScaleOffset][SingleLineTexture]_DiffuseGradient("DiffuseGradient", 2D) = "white" {}
		[Header(Specular)][Toggle(_USESPECULAR_ON)] _UseSpecular("Use Specular", Float) = 0
		[NoScaleOffset][SingleLineTexture]_Smoothness("Smoothness", 2D) = "white" {}
		[NoScaleOffset][SingleLineTexture]_SpecularGradient("Specular Gradient", 2D) = "black" {}
		_SmoothnessMax("Smoothness Max", Range( 0 , 1)) = 0
		[Header(Emission)][Toggle(_HASEMISSION_ON)] _HasEmission("Has Emission", Float) = 0
		[HDR]_EmissionColor("Emission Color", Color) = (1,1,1,0)
		[NoScaleOffset][SingleLineTexture]_EmissionMap("Emission Map", 2D) = "white" {}
		[Header(Ambient)][Toggle(_APPLYAMBIENTLIGHTING_ON)] _Applyambientlighting("Apply ambient lighting", Float) = 0
		[Header(Fresnel)][Toggle(_APPLYFRESNEL_ON)] _ApplyFresnel("Apply Fresnel ", Float) = 0
		[NoScaleOffset][SingleLineTexture]_FresnelGradient("Fresnel Gradient", 2D) = "white" {}
		_Fresnelbias("Fresnel bias", Range( -1 , 1)) = 0
		_Fresnelscale("Fresnel scale", Range( 0 , 3)) = 1
		_Fresnelpower("Fresnel power", Range( 0 , 10)) = 5
		_FresnelStrength("Fresnel Strength", Range( 0 , 1)) = 0.54
		_FresnelLightAttenuationOffset("Fresnel Light Attenuation Offset", Range( 0 , 1)) = 0.5
		[Toggle(_FRESNELUSELIGHTATTENUATION_ON)] _FresnelUseLightAttenuation("Fresnel Use Light Attenuation", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _HASEMISSION_ON
		#pragma shader_feature_local _APPLYAMBIENTLIGHTING_ON
		#pragma shader_feature_local _USESPECULAR_ON
		#pragma shader_feature_local _APPLYFRESNEL_ON
		#pragma shader_feature_local _FRESNELUSELIGHTATTENUATION_ON
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

		uniform sampler2D _EmissionMap;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float4 _EmissionColor;
		uniform sampler2D _NormalMap;
		uniform float _NormalScale;
		uniform sampler2D _DiffuseGradient;
		uniform float4 _Color;
		uniform sampler2D _SpecularGradient;
		uniform sampler2D _Smoothness;
		uniform float _SmoothnessMax;
		uniform sampler2D _FresnelGradient;
		uniform float _Fresnelbias;
		uniform float _Fresnelscale;
		uniform float _Fresnelpower;
		uniform float _FresnelLightAttenuationOffset;
		uniform float _FresnelStrength;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode12 = tex2D( _MainTexture, uv_MainTexture );
			float3 worldnormal74 = normalize( (WorldNormalVector( i , UnpackScaleNormal( tex2D( _NormalMap, uv_MainTexture ), _NormalScale ) )) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult5 = dot( worldnormal74 , ase_worldlightDir );
			float diffuselight11 = saturate( ( ase_lightAtten * (0.0 + (dotResult5 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) );
			float ifLocalVar38 = 0;
			if( ( 1.0 - _WorldSpaceLightPos0.w ) > 0.0 )
				ifLocalVar38 = 1.0;
			else if( ( 1.0 - _WorldSpaceLightPos0.w ) == 0.0 )
				ifLocalVar38 = diffuselight11;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 appendResult16 = (float2(diffuselight11 , 0.5));
			float4 ifLocalVar22 = 0;
			if( ifLocalVar38 > 0.0 )
				ifLocalVar22 = ( float4( ase_lightColor.rgb , 0.0 ) * tex2D( _DiffuseGradient, appendResult16 ) * ase_lightColor.a );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult4_g1 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult41 = dot( worldnormal74 , normalizeResult4_g1 );
			float Smoothnessinput89 = _SmoothnessMax;
			float fresnelNdotV97 = dot( worldnormal74, ase_worldViewDir );
			float fresnelNode97 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV97, 2.14 ) );
			float temp_output_102_0 = ( ( tex2D( _Smoothness, uv_MainTexture ).r * Smoothnessinput89 ) + (0.0 + (saturate( fresnelNode97 ) - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) );
			float2 appendResult52 = (float2(saturate( ( pow( (0.0 + (dotResult41 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) , ( temp_output_102_0 * 32.0 ) ) * diffuselight11 * temp_output_102_0 ) ) , 0.0));
			float4 Specular101 = ( tex2D( _SpecularGradient, appendResult52 ) * ( ase_lightColor.a * 1.0 ) * float4( ase_lightColor.rgb , 0.0 ) );
			#ifdef _USESPECULAR_ON
				float4 staticSwitch106 = Specular101;
			#else
				float4 staticSwitch106 = float4( 0,0,0,0 );
			#endif
			float fresnelNdotV108 = dot( normalize( worldnormal74 ), ase_worldViewDir );
			float fresnelNode108 = ( _Fresnelbias + _Fresnelscale * pow( max( 1.0 - fresnelNdotV108 , 0.0001 ), _Fresnelpower ) );
			float temp_output_115_0 = saturate( fresnelNode108 );
			#ifdef _FRESNELUSELIGHTATTENUATION_ON
				float staticSwitch127 = ( temp_output_115_0 * saturate( ( ase_lightAtten + _FresnelLightAttenuationOffset ) ) );
			#else
				float staticSwitch127 = temp_output_115_0;
			#endif
			float2 appendResult109 = (float2(staticSwitch127 , 0.0));
			#ifdef _APPLYFRESNEL_ON
				float4 staticSwitch125 = ( tex2D( _FresnelGradient, saturate( appendResult109 ) ) * _FresnelStrength );
			#else
				float4 staticSwitch125 = float4( 0,0,0,0 );
			#endif
			float4 Fresnel118 = staticSwitch125;
			c.rgb = ( ( tex2DNode12 * ( ifLocalVar22 + float4( 0,0,0,0 ) ) * _Color ) + staticSwitch106 + Fresnel118 ).rgb;
			c.a = 1;
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
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			#ifdef _HASEMISSION_ON
				float4 staticSwitch60 = ( tex2D( _EmissionMap, uv_MainTexture ) * _EmissionColor );
			#else
				float4 staticSwitch60 = float4( 0,0,0,0 );
			#endif
			float3 worldnormal74 = normalize( (WorldNormalVector( i , UnpackScaleNormal( tex2D( _NormalMap, uv_MainTexture ), _NormalScale ) )) );
			float dotResult71 = dot( float3(0,1,0) , worldnormal74 );
			float4 lerpResult87 = lerp( unity_AmbientEquator , unity_AmbientGround , (1.0 + (dotResult71 - -1.0) * (0.0 - 1.0) / (0.0 - -1.0)));
			float4 lerpResult86 = lerp( unity_AmbientEquator , unity_AmbientSky , (0.0 + (dotResult71 - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)));
			float4 lerpResult83 = lerp( lerpResult87 , lerpResult86 , (0.0 + (dotResult71 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)));
			float4 ambient92 = lerpResult83;
			#ifdef _APPLYAMBIENTLIGHTING_ON
				float4 staticSwitch94 = ambient92;
			#else
				float4 staticSwitch94 = float4( 0,0,0,0 );
			#endif
			float4 tex2DNode12 = tex2D( _MainTexture, uv_MainTexture );
			o.Emission = ( staticSwitch60 + ( staticSwitch94 * tex2DNode12 ) ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers nomrt 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows noambient 

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
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
378;722;1119;636;1252.728;746.5202;1.309427;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;25;-3616,-625.4215;Inherit;True;Property;_MainTexture;Main Texture;0;1;[Header];Create;True;1;Base;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;24;-3775.174,-168.6201;Inherit;False;Property;_NormalScale;Normal Scale;3;0;Create;True;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-3431.701,-408.1343;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;-3512,-227.5678;Inherit;True;Property;_NormalMap;NormalMap;2;3;[NoScaleOffset];[Normal];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;526263bc3d621484f9d3a0dc7755ba78;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;4;-3168,-224;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-2976,-240;Inherit;False;worldnormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;10;-2719.096,-268.5899;Inherit;False;1036;611.5001;Comment;9;6;5;1;8;7;11;18;29;75;Normalized diffuse light;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-3439.078,934.53;Inherit;False;74;worldnormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;6;-2688,142.6415;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;75;-2636.896,-0.8673875;Inherit;False;74;worldnormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;97;-3233.712,928.5224;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2.14;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;5;-2464,0;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-3506.323,770.9286;Inherit;False;Property;_SmoothnessMax;Smoothness Max;8;0;Create;True;0;0;0;False;0;False;0;0.434;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;1;-2638.096,-196.0898;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-2272,0;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-3201.437,779.9647;Inherit;False;Smoothnessinput;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;103;-2934.548,934.6481;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;45;-3344,464;Inherit;True;Property;_Smoothness;Smoothness;6;3;[Header];[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-2016,-192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-4064,2320;Inherit;False;Property;_Fresnelbias;Fresnel bias;15;0;Create;True;0;0;0;False;0;False;0;-0.038;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;121;-3614.143,2591.647;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-4064,2480;Inherit;False;Property;_Fresnelpower;Fresnel power;17;0;Create;True;0;0;0;False;0;False;5;2.51;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-2991.311,566.6246;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-3909.61,2182.394;Inherit;False;74;worldnormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;56;-2832,496;Inherit;False;Blinn-Phong Half Vector;-1;;1;91a149ac9d615be429126c95e20753ce;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-4064,2400;Inherit;False;Property;_Fresnelscale;Fresnel scale;16;0;Create;True;0;0;0;False;0;False;1;1.57;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;100;-2825.98,953.8896;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-2821.737,417.2697;Inherit;False;74;worldnormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-3721.439,2733.498;Inherit;False;Property;_FresnelLightAttenuationOffset;Fresnel Light Attenuation Offset;19;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-2971.7,738.7;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;32;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;123;-3343.837,2652.899;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;108;-3600,2272;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;102;-2818.476,633.9756;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;41;-2533.336,409.0389;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;29;-1861.79,-72.87704;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-1872,-192;Inherit;False;diffuselight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;104;-3536,1168;Inherit;False;1600.335;832.2686;Comment;13;77;72;71;85;67;65;84;68;87;82;86;83;92;Ambient;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;129;-2286.8,426.5742;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;115;-3297.49,2293.245;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;126;-3232,2656;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2656.799,650.8;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-3488,1376;Inherit;False;74;worldnormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;72;-3488,1216;Inherit;False;Constant;_Vector0;Vector 0;11;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-3081.01,2535.284;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;46;-2113.17,534.803;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;16;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-2311.483,723.1545;Inherit;False;11;diffuselight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;71;-3312,1280;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1936.552,538.2302;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;127;-3098.262,2488.563;Inherit;False;Property;_FresnelUseLightAttenuation;Fresnel Use Light Attenuation;20;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;67;-3472,1616;Inherit;False;unity_AmbientEquator;0;1;COLOR;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;68;-3472,1696;Inherit;False;unity_AmbientGround;0;1;COLOR;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;65;-3472,1536;Inherit;False;unity_AmbientSky;0;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;85;-3056,1744;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;84;-3056,1536;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-1408,-128;Inherit;False;11;diffuselight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;-1703.718,534.9775;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;109;-3122.604,2270.394;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;82;-3056,1344;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-1495.419,466.6445;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;-1248,144;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;36;-1503.778,-258.1425;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;128;-2984.155,2256.393;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;87;-2736,1824;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;86;-2784,1552;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;53;-2631.427,802.0244;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;110;-2949.61,2332.394;Inherit;True;Property;_FresnelGradient;Fresnel Gradient;14;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;0a0a1576cfd406f4c84d80ac135f8cb6;5bc1cd78ff33ce3448b88f4a7de04e4b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-1343.677,-55.15802;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;49;-1333.904,475.0688;Inherit;True;Property;_SpecularGradient;Specular Gradient;7;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;0e5af8115d1a8c241b58159d87423094;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;117;-2960.688,2623.546;Inherit;False;Property;_FresnelStrength;Fresnel Strength;18;0;Create;True;0;0;0;False;0;False;0.54;0.126;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-1088,176;Inherit;True;Property;_DiffuseGradient;DiffuseGradient;4;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;c11b116d4f5a2e74aa37743b3a9e3329;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-2455.781,915.2382;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;83;-2528,1744;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;20;-1008,64;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;37;-1280,-240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-2120.999,1763;Inherit;False;ambient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-2578.768,2307.873;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-984.0306,549.3254;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ConditionalIfNode;38;-1068.677,-169.158;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-800,-96;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;61;-672,-672;Inherit;False;Property;_EmissionColor;Emission Color;10;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ConditionalIfNode;22;-640,-208;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;125;-2368,2304;Inherit;False;Property;_ApplyFresnel;Apply Fresnel ;13;0;Create;True;0;0;0;False;1;Header(Fresnel);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;63;-752,-864;Inherit;True;Property;_EmissionMap;Emission Map;11;2;[NoScaleOffset];[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-807.246,573.9547;Inherit;False;Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;-895.3025,-509.2365;Inherit;False;92;ambient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-338.4987,-227.6464;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;12;-3262.579,-624;Inherit;True;Property;_a;a;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-400.2275,-611.6859;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;9;-848,-350;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2156862,0.8862746,0.8352942,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;105;-480,-112;Inherit;False;101;Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-2126.824,2296.052;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;94;-691.2318,-518.7363;Inherit;False;Property;_Applyambientlighting;Apply ambient lighting;12;0;Create;True;0;0;0;False;1;Header(Ambient);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;106;-318.2676,-131.1899;Inherit;False;Property;_UseSpecular;Use Specular;5;0;Create;True;0;0;0;False;1;Header(Specular);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;60;-208,-608;Inherit;False;Property;_HasEmission;Has Emission;9;0;Create;True;0;0;0;False;1;Header(Emission);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-346.4543,-465.8073;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-444.7911,108.5724;Inherit;False;118;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-279.3481,-360.5401;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;-2233.487,1679.119;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Exp2OpNode;96;-1141.828,779.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;18;-2384,-128;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;90;-1380.737,760.3096;Inherit;False;89;Smoothnessinput;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;133;-56.85809,-427.4126;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureTransformNode;27;-3430.037,-746.2034;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-48,-144;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;128,-384;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Przekop/Custom Lighting/Gradient Shading;False;False;False;False;True;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;17;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;28;2;25;0
WireConnection;23;1;28;0
WireConnection;23;5;24;0
WireConnection;23;7;25;1
WireConnection;4;0;23;0
WireConnection;74;0;4;0
WireConnection;97;0;98;0
WireConnection;5;0;75;0
WireConnection;5;1;6;0
WireConnection;8;0;5;0
WireConnection;89;0;58;0
WireConnection;103;0;97;0
WireConnection;45;1;28;0
WireConnection;7;0;1;0
WireConnection;7;1;8;0
WireConnection;59;0;45;1
WireConnection;59;1;89;0
WireConnection;100;0;103;0
WireConnection;123;0;121;0
WireConnection;123;1;124;0
WireConnection;108;0;111;0
WireConnection;108;1;112;0
WireConnection;108;2;113;0
WireConnection;108;3;114;0
WireConnection;102;0;59;0
WireConnection;102;1;100;0
WireConnection;41;0;76;0
WireConnection;41;1;56;0
WireConnection;29;0;7;0
WireConnection;11;0;29;0
WireConnection;129;0;41;0
WireConnection;115;0;108;0
WireConnection;126;0;123;0
WireConnection;50;0;102;0
WireConnection;50;1;51;0
WireConnection;122;0;115;0
WireConnection;122;1;126;0
WireConnection;46;0;129;0
WireConnection;46;1;50;0
WireConnection;71;0;72;0
WireConnection;71;1;77;0
WireConnection;44;0;46;0
WireConnection;44;1;55;0
WireConnection;44;2;102;0
WireConnection;127;1;115;0
WireConnection;127;0;122;0
WireConnection;85;0;71;0
WireConnection;84;0;71;0
WireConnection;48;0;44;0
WireConnection;109;0;127;0
WireConnection;82;0;71;0
WireConnection;52;0;48;0
WireConnection;16;0;17;0
WireConnection;128;0;109;0
WireConnection;87;0;67;0
WireConnection;87;1;68;0
WireConnection;87;2;85;0
WireConnection;86;0;67;0
WireConnection;86;1;65;0
WireConnection;86;2;84;0
WireConnection;110;1;128;0
WireConnection;49;1;52;0
WireConnection;14;1;16;0
WireConnection;107;0;53;2
WireConnection;83;0;87;0
WireConnection;83;1;86;0
WireConnection;83;2;82;0
WireConnection;37;0;36;2
WireConnection;92;0;83;0
WireConnection;116;0;110;0
WireConnection;116;1;117;0
WireConnection;54;0;49;0
WireConnection;54;1;107;0
WireConnection;54;2;53;1
WireConnection;38;0;37;0
WireConnection;38;2;39;0
WireConnection;38;3;17;0
WireConnection;21;0;20;1
WireConnection;21;1;14;0
WireConnection;21;2;20;2
WireConnection;22;0;38;0
WireConnection;22;2;21;0
WireConnection;125;0;116;0
WireConnection;63;1;28;0
WireConnection;101;0;54;0
WireConnection;131;0;22;0
WireConnection;12;0;25;0
WireConnection;12;1;28;0
WireConnection;12;7;25;1
WireConnection;62;0;63;0
WireConnection;62;1;61;0
WireConnection;118;0;125;0
WireConnection;94;0;93;0
WireConnection;106;0;105;0
WireConnection;60;0;62;0
WireConnection;134;0;94;0
WireConnection;134;1;12;0
WireConnection;130;0;12;0
WireConnection;130;1;131;0
WireConnection;130;2;9;0
WireConnection;132;1;83;0
WireConnection;96;0;90;0
WireConnection;133;0;60;0
WireConnection;133;1;134;0
WireConnection;47;0;130;0
WireConnection;47;1;106;0
WireConnection;47;2;119;0
WireConnection;0;2;133;0
WireConnection;0;13;47;0
ASEEND*/
//CHKSM=619071A825B361B8074E05738EDB74BA8BAEF446