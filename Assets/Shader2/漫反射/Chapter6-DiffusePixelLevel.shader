﻿// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter6/Diffuse Pixel Level"
{
    // 逐像素光源
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
                fixed3 worldNormal:TEXCOORD0;
            };

            //逐頂點的漫反射
            v2f vert(a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                //把法綫 從 物件坐標 轉換為 世界坐標
                o.worldNormal=mul(v.normal,(float3x3)unity_WorldToObject);

                return o;
                
            }

            fixed4 frag(v2f i):SV_Target{

                //獲取環境光變數
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                //歸一化世界坐標法綫
                fixed3 worldNormal=normalize(i.worldNormal);
                //獲取光綫方向(世界空間)
                fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse=_LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir));

                //_LightColor0 存取該Pass處理的光源的顔色和强度資訊（需要定義合適的LightMode標簽）
                //worldLightDir 光源方向
                //_Diffuse 材質漫反射顔色
                //v.normal 頂點法綫

                fixed3 color=ambient + diffuse;
                return fixed4(color,1.0);
            }
            ENDCG
        }
        
    }
    Fallback "Diffuse"
}
