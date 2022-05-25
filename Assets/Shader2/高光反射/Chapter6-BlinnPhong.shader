
Shader "Unity Shaders Book/Chapter6/Specular Pixel Level"
{
    //逐像素光源 高光
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
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
            };

            v2f vert(a2v v){
                v2f o;

                o.pos=UnityObjectToClipPos(v.vertex);
                //法綫 模型2世界
                o.worldNormal=mul(v.normal,(float3x3)unity_WorldToObject);
                //頂點 模型2世界
                o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;

                return o;

            }
            fixed4 frag(v2f i):SV_Target{
                //環境光資料
                fixed3 ambient =UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal=normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
                //comput diffuse term
                fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));

                // fixed3 reflectDir=normalize(reflect(-worldLightDir,worldNormal));
                fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);

                //BlinnPhong的新向量h 角度方向和光源方向相加後再歸一化獲得
                fixed3 halfDir=normalize(viewDir+worldLightDir);
                
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                return fixed4(ambient+diffuse+specular,1.0);
            }
            ENDCG


        }
    }
    Fallback "Specular"





}
