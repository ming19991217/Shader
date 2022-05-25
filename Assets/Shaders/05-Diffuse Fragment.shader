// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "05-Diffuse Fragment"{

    Properties{
        _Diffuse("Diffuse Color",Color)=(1,1,1,1)
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

            struct a2v{ 
                float4 vertex:POSITION;//告訴unity把模型空間下的頂點坐標填充給vertex
                float3 normal:NORMAL;//告訴unity把模型空間下的法綫填充給normal 
            };

            struct v2f{
                float4 position:SV_POSITION;
                fixed3 wordNormalDir:COLOR0;
                
                
            };


            v2f vert(a2v v){ 
                v2f f;
                f.position=UnityObjectToClipPos(v.vertex);

                f.wordNormalDir= mul(v.normal,(float3x3)unity_WorldToObject); //在頂點函數獲得法綫
                
                return f;
            }
            
            fixed4 frag(v2f f):SV_Target{

                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.rgb; //在片元函數獲得環境光
                
                fixed3 normalDir=normalize(f.wordNormalDir) ;
                
                fixed lightDir=normalize(_WorldSpaceLightPos0.xyz) ;//光照方向

                fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * _Diffuse.rgb;
                
                fixed3 tempColor= diffuse + ambient;

                return fixed4(tempColor,1);
            }

            ENDCG
        }
    }

    Fallback "Diffuse"

}