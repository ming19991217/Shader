// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter6/Specular Vertex Level"
{
    Properties{
        _Diffuse("Diffuse",Color)=(1,1,1,1)

        //高光反射顔色
        _Specular("Specular",Color)=(1,1,1,1)
        //控制高光區域的大小
        _Gloss("Gloss",Range(8.0,256))=20
    }

    SubShader{
        Pass{
            //正確定義LightMode 才能獲得Unity的内建變量(_LightColor0)
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };
            struct v2f{
                float4 pos :SV_POSITION;
                fixed3 Color :COLOR;
            };

            v2f vert(a2v v){
                v2f o;

                o.pos=UnityObjectToClipPos(v.vertex);

                //漫反射計算
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));

                fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));
                

                //高光計算

                //獲得反射方向 （世界空間）
                // reflect(i,n)  參數：i(入射方向)、n(法綫方向)  但指定入射方向i和法綫方向n時，reflect傳回反射方向
                // 由於Cg的reflect函數的入射方向要求是由光源指向焦點処，因此需要對worldLightDir反轉後再傳給reflect函數
                fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));

                //獲得視野方向（世界空間）
                //_WorldSpaceCameraPos 獲得世界空間的攝影機位置
                //再將頂點位置轉換為世界空間，再透過和攝影機位置相減 即可獲得世界空間下的角度方向
                fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);

                fixed3 specular=_LightColor0.rgb*_Specular.rgb*
                pow(saturate(dot(reflectDir,viewDir)),_Gloss);

                o.Color=ambient+diffuse+specular;

                return o;
                //


            }
            fixed3 frag(v2f i):SV_Target{
                return fixed4(i.Color,1.0);
            }
            ENDCG


        }
    }
    Fallback "Specular"





}
