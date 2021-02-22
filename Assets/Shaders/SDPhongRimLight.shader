Shader "Custom/PhongRimLight"
{
    Properties
    {
     
        _Albedo("Albedo Color", Color) = (1, 1, 1, 1)

        //Phong
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularPower("Specular Power", Range(1.0, 10.0)) = 5.0
        _SpecularGloss("Specular Gloss", Range(1.0, 5.0)) = 1.0
        _GlossSteps("GlossSteps", Range(1, 8)) = 4

        //RimLight
        [HDR] _RimColor("Rim Color", Color) = (1, 0, 0, 1)
        _RimPower("Rim Power", Range(0.0, 8.0)) = 1.0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
        }

        CGPROGRAM

            #pragma surface surf PhongCustom
            
            half4 _Albedo;
            
            //Phong
            half4 _SpecularColor;
            half _SpecularPower;
            int _SpecularGloss;
            int _GlossSteps;

            //RimLight
            half4 _RimColor;
            float _RimPower;
            
            half4 LightingPhongCustom(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
            {
                half NdotL = max(0, dot (s.Normal, lightDir));
                half3 reflectedLight = reflect(-lightDir, s.Normal);
                half RdotV = max(0, dot(reflectedLight, viewDir));
                half3 specularity = pow(RdotV, _SpecularGloss / _GlossSteps) * _SpecularPower *_SpecularColor.rgb;
                half4 c;
                c.rgb = (NdotL * s.Albedo + specularity) * _LightColor0.rgb * atten;
                c.a = s.Alpha;
                return c;
            }

            struct Input
            {  
                //Phong
                float a;

                //RimLight
                float3 viewDir;
            };

            void surf(Input IN, inout SurfaceOutput o)
            { 
                 //Phong/RimLight
                o.Albedo = _Albedo.rgb;

                //RimLight
                float3 nVwd= normalize(IN.viewDir);
                float3 NdotV = dot(nVwd, o.Normal);
                half rim = 1 - saturate(NdotV);
                o.Emission = _RimColor.rgb * pow(rim, _RimPower);
            }
        ENDCG
    }
}