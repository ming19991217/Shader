// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter6/Diffuse Vertex Level"
{

    Properties{
        //控制材質的漫射顔色，初始值為白色
        _Diffuse("Diffuse",Color)=(1,1,1,1)
    }

    SubShader{
        Pass{
            
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            
            struct a2v{
                float4 vertex:POSITION;
                float4 normal:NORMAL;
            };
            struct v2f{
                float4 pos:SV_POSITION;
                fixed3 color:COLOR;
            };

            //逐頂點的漫反射
            v2f vert(a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                
                //獲取環境光的變數
                fixed3 ambient= UNITY_LIGHTMODEL_AMBIENT.xyz;

                //轉換法綫 從物件空間 到 世界空間
                fixed3 worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));

                //獲取光源方向 在世界空間
                fixed3  worldLight=normalize(_WorldSpaceLightPos0.xyz);

                //計算漫射光源需要知道4個參數：材質的漫射顔色_Diffuse、頂點法綫v.normal、光源的顔色强度、光源方向
                fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLight));

                o.color=ambient+diffuse;

                return o;
                
            }

            fixed4 frag(v2f i):SV_Target{
                return fixed4(i.color,1.0);
            }
            ENDCG
        }
        
    }
    Fallback "Diffuse"
}
