Shader "Custom/DiffuseTex"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
    }

    SubShader
    {
        tags
        {
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
        }

        CGPROGRAM
            #pragma surface surf Lambert 
            
            sampler2D _MainTex;
            
            struct Input
            {
                float2 uv_MainTex;
            };

            void surf(Input IN, inout SurfaceOutput o)
            {
                half4 textColor = tex2D(_MainTex, IN.uv_MainTex);//half es la mitad de un float
                o.Albedo = textColor;
            }
        ENDCG
    }
}
