
Shader "09-Specular Fragment BlinnPhone"{

    Properties{
        _Diffuse("Diffuse Color",Color)=(1,1,1,1)//漫反射顔色
        _Specular("Specular Color",Color)=(1,1,1,1)//高光反射顔色
        _Gloss("Gloss",Range(8,200))=10//高光光暈

    }

    SubShader{
        Pass{
            //定義LightMode 還需要include LightMode
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM

            #include "Lighting.cginc" //包含、引入 類似unity的using

            #pragma vertex vert       
            
            #pragma fragment frag

            fixed4 _Diffuse;//使用屬性重新定義
            half _Gloss;
            fixed4 _Specular;

            struct a2v{ 
                float4 vertex:POSITION;//告訴unity把模型空間下的頂點坐標填充給vertex
                float3 normal:NORMAL;//告訴unity把模型空間下的法綫填充給normal 
            };

            struct v2f{
                float4 position:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float4 worldVertex:TEXCOORD1;
                
            };


            v2f vert(a2v v){ 
                v2f f;
                f.position=UnityObjectToClipPos(v.vertex);
                //f.worldNormal=mul(v.normal,(float3x3)unity_WorldToObject);
                f.worldNormal= UnityObjectToWorldNormal(v.normal);//法綫 模型轉世界

                f.worldVertex=mul(v.vertex,unity_WorldToObject);
                
                return f;
            }
            
            fixed4 frag(v2f f):SV_Target{

                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.rgb;
                
                fixed3 normalDir=normalize(f.worldNormal) ;//把v的法綫從模型空間轉換到世界空間 將mull（）中兩個函數調換可以從世界——>模型 or 模型——>世界
                
                //fixed lightDir=normalize(_WorldSpaceLightPos0.xyz) ;
                fixed3 lightDir=normalize(WorldSpaceLightDir(f.worldVertex).xyz) ;

                fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * _Diffuse.rgb;
                
                //反射光的方向
                //fixed3 reflectDir= normalize(reflect(-lightDir,normalDir));
                //視野方向
                //fixed3 viewDir= normalize(_WorldSpaceCameraPos.xyz-f.worldVertex);
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(f.worldVertex));

                //視野方向與平行光的平分綫
                fixed3 halfDir=normalize(viewDir+lightDir);

                //BlinnPhone高光反射公式
                fixed3 specular=_LightColor0.rgb *_Specular.rgb *pow(max(dot(normalDir,halfDir),0),_Gloss) ;  
                
                fixed3 tempColor= diffuse + ambient + specular;

                return fixed4(tempColor,1);
            }

            ENDCG
        }
    }

    Fallback "VertexLit"

}