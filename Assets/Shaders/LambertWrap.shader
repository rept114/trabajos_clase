Shader "Custom/LambertWrap"
{
    Properties
    {
        _Albedo("Albedo Color", Color) = (1, 1, 1, 1)
        _FallOff("FallOff", Range(0.1, 0.5)) = 0.1 //Tiene que ser 0 a 1 y el 0.5 para que corte a 1
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
        }

        CGPROGRAM
            #pragma surface surf MyLambert

            half _FallOff;

            half4 LightingMyLambert(SurfaceOutput s, half3 lightDir, half atten)
            {
                half NdotL = dot(s.Normal, lightDir); //Almacenar el producto punto entre la Normal y la Dirección de la Luz
                half diff = NdotL * _FallOff + _FallOff;
                half4 c;
                c.rgb = s.Albedo * _LightColor0.rgb * NdotL * diff;
                c.a = s.Alpha;
                return c;
            }

            half4 _Albedo;

            struct Input
            {
                float2 uv_MainTex;
            };

            void surf (Input IN, inout SurfaceOutput o)
            {
                o.Albedo = _Albedo.rgb;
            }

        ENDCG
    }
}
