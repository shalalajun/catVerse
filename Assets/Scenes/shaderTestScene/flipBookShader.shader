Shader "Unlit/flipBookShader"
{
    Properties
    {
        _BaseMap("BaseMap",2D) = "white"{}
        _Width("Width Count",Range(0,5)) = 5 
        _Height("Height Count",Range(0,5)) = 5 
        _Offset("Offset",Range(0,3)) = 1 
        _Speed("speed",Range(0,24)) = 24 
        _Maxframe("Maxframe",Range(0,30)) = 25 
       [Toggle] _Inverse ("Invert Direction", float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        //LOD 100

        Pass
        {
            HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           #pragma shader_feature_local _INVERSE_OFF _INVERSE_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct Varying
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);


            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float _Width;
                float _Height;
                float _Offset;
                float2 _Invert;
                float _Speed;
                float _Maxframe;

            CBUFFER_END


            Varying vert(Attributes IN)
            {
                Varying OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            float2 Flipbook(float2 UV, float Width, float Height, float Speed, float2 Invert)
            {
                
                Speed = fmod(Speed, Width * Height);

                //float MatrixSize = floor(fmod(_Time.y * Offset, Width * Height));
                float2 tileCount = float2(1.0,1.0) / float2(Width, Height);
               
               
                float U = abs(Invert.x - (tileCount.x * (fmod(Speed, Width) + Invert.x) ) );
                float V = abs(Invert.y - (tileCount.y * (floor(Speed / Width) + Invert.y) ) );

                float2 tileOffset = float2(U, V);

                return UV * tileCount + tileOffset;
            }


            half4 frag(Varying IN) : SV_Target
            {
                _Invert = float2(0,1); // 정방향
                #if _INVERSE_ON
                _Invert = float2(1,0); // 역방향
                #endif

                float Frame = floor(fmod(_Time.y * _Speed, _Maxframe));
                //half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, float2(IN.uv.x * (1/_Width), IN.uv.y * (1/_Height)));
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, Flipbook(IN.uv,_Width,_Height,Frame, _Invert));
                //half4 color = half4(0.5, 0.0, 0.0, 1.0);
                //half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                return color;
            }
            ENDHLSL
        }   
    }
}
