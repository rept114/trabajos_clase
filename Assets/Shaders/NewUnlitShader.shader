 Shader "custom/global shader" 
 {
     Properties
     {
 
 //lay out like this: maptype ("UI name", function) = "
 
 //Color multiplies diffuse texture, useful for tinting.        
         _Color ("Diffuse tint", COLOR) = (1,1,1)
 //Maintex is the diffuse texture we call up.
         _MainTex ("Diffuse texture", 2D) = "white" {}
 //Transparency slider defines alpha cutoff value
         _Transparency ("Transparency", Range (0.0, 1.0)) = 1
 //MaskTex has multiple functions - Red = Rim strength, Green = Rim broadness, Blue = Diffuse tint mask
         _MaskTex ("Effect masks", 2D) = "white" {} 
 //WrapAmount is half lambert amount        
         _WrapAmount ("Half Lambert", Range (0.0, 1.0)) = 0.5
 //bumpmap is normalmap        
         _BumpMap ("Normalmap", 2D) = "white" {}
 //Emmission slider to control the brightness of full emmission.
         _Emission ("Emission", Range (0.0, 2.0)) = 0
 //RimStrength can multiply rimlight to zero. also defines the maximum rim strength.
         _RimStrength ("Rimlight Strength", Range (0,2)) = 1 
 //RimColor is rim light colour, and RimPower is broadness + brightness of rim light. also defines maximum broadness of the rim light.        
         _RimColor ("Rim Color", Color) = (1,1,1,0.0)
         _RimPower ("Rim Broadness", Range(0.5,8.0)) = 3.0
 //Rim-tint is a test to see if we can have a portion of the shader dedicated to metallics specifically.
         _RimTint ("Rim tint", Range(0.0,1.0)) = 1.0      
         }
     
     
     SubShader {      
               
       Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
     LOD 200
               
       CGPROGRAM
       //defines the surface types for the material.    
       #pragma surface surf WrapLambert alphatest:_Transparency
       
          
       //defines half lambert strength. closer to 0 - more strongly lit.
       float _WrapAmount;  
       half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten) {
           half NdotL = dot (s.Normal, lightDir);
           half diff = NdotL * _WrapAmount + (1 - _WrapAmount);
           half4 c;
           c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
           c.a = s.Alpha;
           return c;
       }
       
        
       struct Input {
           //"should" define a colour to tint diffuse with
           float3 _Color;
           //calls textures to be used          
           float2 uv_MainTex;
           float2 uv_BumpMap;
           float2 uv_MaskTex;
           //defines camera direction in relation to object
           float3 viewDir;
          
           
       };
       sampler2D _MainTex;
       sampler2D _BumpMap;
       sampler2D _MaskTex;           
       float3 _Color;
       float _Emission;
       float4 _RimColor;
       float _RimPower;
       float _RimStrength;
       float _RimTint;
       void surf (Input IN, inout SurfaceOutput o) {
         // cache the texture lookups
         // the line below creates a new local variable (it will not exist outside this function, and once the function is finished, it will be removed from memory) and fill it with the result of the texture lookup
         // this means that the variable main will have 4 components, r, g, b and a. Which you can use at your whim. :)
         float4 main = tex2D(_MainTex, IN.uv_MainTex);
         float4 mask = tex2D(_MaskTex, IN.uv_MaskTex);
         float4 bump = tex2D(_BumpMap, IN.uv_BumpMap);
         //Albedo = final unlit colour map, in this case combination of diffuse map * diffuse tint. tint map can be masked.
         o.Albedo = lerp(main.rgb, main.rgb * _Color, main.a);
         o.Normal = UnpackNormal (bump); 
         //Alpha channel in normal map is transparency
         o.Alpha = bump.a;       
         //Rimlight calculation is emmissive.
         half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
         //Can now transition between coloured rim light, and metallic rim light, keep rim tint slider at 0 for non-metallic surfaces.
         o.Emission = ((mask.a * main.rgb) * _Emission + (lerp(_RimColor.rgb, main.rgb * 2.0, _RimTint * mask.b) * pow (rim, _RimPower *  mask.g)) * (_RimStrength * mask.r));
         
         
     }      
       
       ENDCG
       
         Pass {
         //first render pass.               
                           
                           Tags { "RenderType" = "Transparent" }    
              
             //Lighting function turns on/off, defaults to off if function not present.
             Lighting ON
             
         }
     }
 }