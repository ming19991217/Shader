// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 7 /Single Texture"{

    Properties{
        //控制物體的整體顔色        
        _Color("Color Tint",Color)=(1,1,1,1)
        //white是内建紋理的名字，全白的紋理
        _MainTex("Main Tex",2D)="white"{}

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
            //與其他屬性不同，我們還需要為紋理類型的屬性宣告一個float4類型的變數_MainTex_ST
            //在Unity 我們需要使用 紋理名_ST的方式來宣告某個紋理的屬性，ST是縮放和平移的縮寫，讓我們獲得紋理的縮放平移值
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;//unity將模型的第一組紋理儲存到該變數中
            };
            struct v2f{
                float4 pos:SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);

                o.worldNormal=UnityObjectToWorldNormal(v.normal);

                o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;

                //使用紋理的屬性值_MainTex_ST來對頂點紋理坐標進行轉換，獲得最後的紋理坐標
                //先使用縮放屬性xy對頂點紋理坐標進行縮放，再使用zw對結果進行偏移
                o.uv=v.texcoord.xy* _MainTex_ST.xy+_MainTex_ST.zw;
                //或者使用内置函數
                //  o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);

                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 worldNormal = normalize(i.worldNormal);//世界空間的法綫方向
                fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(i.worldPos));//世界空間的光源方向

                //使用cg的tex2D函數對紋理進行采樣 tex2D(要被采樣的紋理,float2類型的紋理坐標) 回傳計算獲得的紋素值
                //和顔色屬性相乘來作爲材質的反射率
                fixed3 albedo=tex2D(_MainTex,i.uv).rgb*_Color.rgb;
                //和環境光相乘獲得環境光部分
                fixed3 ambient= UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
                //並加入漫反射的計算
                fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));

                //blinnPhong高光的計算
                fixed3 viewDir= normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir=normalize(worldLightDir+viewDir);
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(worldNormal,halfDir)),_Gloss);

                return fixed4 (ambient+diffuse+specular,1.0);

            }




            ENDCG
        }
    }
    Fallback "Specular"
}