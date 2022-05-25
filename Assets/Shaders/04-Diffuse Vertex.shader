// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "04-Diffuse Vertex"{

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
                fixed3 color:COLOR;
                
            };


            v2f vert(a2v v){ 
                v2f f;
                f.position=UnityObjectToClipPos(v.vertex);

                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.rgb;
                
                fixed3 normalDir=normalize(mul(v.normal,(float3x3)unity_WorldToObject)) ;//把v的法綫從模型空間轉換到世界空間 將mull（）中兩個函數調換可以從世界——>模型 or 模型——>世界

                
                //第一個直射光的位置 對於每個頂點來説 光的位置就是光的方向 因爲光是平行光
                fixed lightDir=normalize(_WorldSpaceLightPos0.xyz) ;

                //取得漫反射的顔色 = 直射光顔色 *max(0, cosθ=光方向 點乘 法綫方向)                 
                fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * _Diffuse.rgb;
                //_LightColor0取得第一個直射光的顔色 unity内置的變量 在"Lighting.cginc"中
                // * _Diffuse.rgb 叠加顔色 兩個顔色相乘會混合顔色

                f.color= diffuse + ambient;
                return f;
            }
            
            fixed4 frag(v2f f):SV_Target{
                return fixed4(f.color,1);
            }

            ENDCG
        }
    }

    Fallback "VertexLit"

}