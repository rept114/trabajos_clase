Shader "Custom/ToonShading"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _Albedo("Albedo Color", Color) = (1, 1, 1, 1)
        _RampTex("Ramp Texture", 2D) = "white" {}
        _FallOff("Max falloff", Range(0.0, 0.5)) = 0.0
        [HDR] _EmissionColor("EmissionColor", Color) = (1, 1, 1, 1)
        _RimPower("Rim Power", Range(0.0, 8.0)) = 1.0
        _NormalTex("Normal Texture", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Range(-5.0, 5.0)) = 1.0
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularPower("Specular Power", Range(1.0, 10.0)) = 5.0
        _SpecularGloss("Specular Gloss", Range(1.0, 5.0)) = 1.0
        _GlossSteps("GlossSteps", Range(1, 8)) = 4
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
        }
        CGPROGRAM

        #pragma surface surf Toon

        sampler2D _MainTex;
        sampler2D _RampTex;
        half4 _Albedo;
        half _FallOff;
        float4 _EmissionColor;
        float _RimPower;
        sampler2D _NormalTex;
        float _NormalStrength;
        half4 _SpecularColor;
        half _SpecularPower;
        half _SpecularGloss;
        int _GlossSteps;

        half4 LightingToon(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            half3 reflectedLight = reflect(-lightDir, s.Normal);
            half RdotV = max(0, dot(reflectedLight, viewDir));
            half3 specularity = pow(RdotV, _SpecularGloss / _GlossSteps) * _SpecularPower * _SpecularColor.rgb;
            half NdotL = dot(s.Normal, lightDir);
            half diff = NdotL * _FallOff + _FallOff;
            float x = NdotL * 0.5 + 0.5;
            float2 uv_RampTex = float2(x, 0);
            half4 rampColor = tex2D(_RampTex, uv_RampTex);
            half4 c;
            c.rgb = (NdotL * s.Albedo + specularity) * _LightColor0.rgb * rampColor * atten;
            c.a = s.Alpha;
            return c;

        }

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
            float2 uv_NormalTex;
                  
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
      
            half4 mainTexColor = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = mainTexColor * _Albedo;
      
            half4 normalColor = tex2D(_NormalTex, IN.uv_NormalTex);
            half3 normal = UnpackNormal(normalColor);
            normal.z = normal.z / _NormalStrength;
            o.Normal = normalize(normal);

            float3 viewDirNormalized= normalize(IN.viewDir);
            float VdotN = dot(viewDirNormalized, o.Normal);
            fixed rim = 1 - saturate(VdotN);
            o.Emission = _EmissionColor * pow(rim, _RimPower);

        }

        ENDCG
    }
}