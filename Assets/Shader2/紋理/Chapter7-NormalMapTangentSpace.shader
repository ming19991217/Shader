// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 7 /Normal Map In Tangent Space"{

    Properties{
        
        _Color("Color Tint",Color)=(1,1,1,1) //控制物體的整體顔色           
        _MainTex("Main Tex",2D)="white"{}////white是内建紋理的名字，全白的紋理

        //法綫紋理
        _BumpMap("Normal Map",2D)="bump"{} //使用"bump"作爲預設值 unity内建的法綫紋理，當沒有提供任何法綫紋理，bump就對應了模型附帶的法綫資料
        _BumpScale("Bump Scale",float)=1.0 //控制凹凸程度 當它為0時 表示該法綫紋理不會對光源產生任何影響。
        
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
    }
    SubShader{
        Pass{
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc" 

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _BumpMap;
            float4 _BumpMap_ST;//紋理屬性 延展和偏移
            float _BumpScale;

            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;//需要獲得切綫資訊
                float4 texcoord:TEXCOORD0;//unity將模型的第一組紋理儲存到該變數中
            };
            struct v2f{
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;

                //儲存切綫空間的光源和角度方向
                float3 lightDir:TEXCOORD1;
                float3 viewDir:TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);

                
                //uv定義爲float4 其中xy分量儲存了_MainTex紋理坐標
                o.uv.xy=v.texcoord.xy* _MainTex_ST.xy+_MainTex_ST.zw;
                // zw分量儲存了_BumpMap的紋理坐標 
                o.uv.zw=v.texcoord.xy* _BumpMap_ST.xy+_BumpMap_ST.zw;
                
                //計算副法綫 
                TANGENT_SPACE_ROTATION;

                //光源方向從模型空間轉換至切綫空間 使用Unity内建函數ObjSpaceLightDir來得到模型空間下的光源方向
                o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;

                //角度方向從模型空間轉換至切綫空間    ObjSpaceViewDir獲得模型空間下的角度方向
                o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
                
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 tangentLightDir=normalize(i.lightDir);
                fixed3 tangentViewDir=normalize(i.viewDir);

                //获取法线贴图中的纹素 法綫紋理中儲存的是把法綫經過對映後獲得的像素值
                fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
                fixed3 tangentNormal;

                /*  
                //如果沒有在Unity裡吧該法綫紋理的類型設定成NormalMap 就需要手動在程式中進行這個過程
                
                //方法1 把packedNormal.xy 用公式對映回法綫方向
                tangentNormal.xy=(packedNormal.xy*2-1)*_BumpScale;
                tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
                */
                //方法2 標記為 "Normal map"  和 使用内建函數
                tangentNormal=UnpackNormal(packedNormal);
                tangentNormal.xy *=_BumpScale;
                tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
                

                fixed3 albedo = tex2D(_MainTex,i.uv).rgb*_Color.rgb;

                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

                fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangentNormal,tangentLightDir));

                fixed3 halfDir=normalize(tangentLightDir+tangentViewDir);
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(tangentNormal,halfDir)),_Gloss);

                return fixed4(ambient+diffuse+specular,1.0);



            }
            




            ENDCG
        }
    }
    Fallback "Specular"
}