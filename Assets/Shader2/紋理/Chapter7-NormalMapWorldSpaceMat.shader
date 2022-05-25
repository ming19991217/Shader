// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'


// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 7 /Normal Map In World Space"{

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

                //這些用來儲存從切綫空間到世界空間的轉換矩陣的每一行
                //w分量用來儲存世界空間下頂點位置
                float4 TtoW0:TEXCOORD1;
                float4 TtoW1:TEXCOORD2;
                float4 TtoW2:TEXCOORD3;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);

                
                //uv定義爲float4 其中xy分量儲存了_MainTex紋理坐標
                o.uv.xy=v.texcoord.xy* _MainTex_ST.xy+_MainTex_ST.zw;
                // zw分量儲存了_BumpMap的紋理坐標 
                o.uv.zw=v.texcoord.xy* _BumpMap_ST.xy+_BumpMap_ST.zw;
                
                
                //計算世界空間下的 頂點 法綫 切綫 副法綫
                float3 worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w;

                //計算從切綫世界到世界空間的轉換矩陣 按列放置
                //將頂點的世界坐標放在w分量
                o.TtoW0=float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.TtoW1=float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.TtoW2=float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                //世界空間的位置
                float3 worldPos=float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                fixed3 lightDir=normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));

                //UnpackNormal 對法綫紋理進行取樣和解碼
                //tex2D 获取法线贴图中的纹素 法綫紋理中儲存的是把法綫經過對映後獲得的像素值
                fixed3 bump=UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                //縮放一下凹凸程度
                bump.xy*=_BumpScale;
                bump.z=sqrt(1.0-saturate(dot(bump.xy,bump.xy)));
                //將法綫從切綫空間轉到世界空間 透過點乘來實現矩陣的每一行和法綫相乘來得到
                bump=normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
                

                fixed3 albedo = tex2D(_MainTex,i.uv).rgb*_Color.rgb;

                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

                fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(bump, lightDir));

                fixed3 halfDir=normalize(lightDir+viewDir);
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(bump,halfDir)),_Gloss);

                return fixed4(ambient+diffuse+specular,1.0);



            }
            




            ENDCG
        }
    }
    Fallback "Specular"
}