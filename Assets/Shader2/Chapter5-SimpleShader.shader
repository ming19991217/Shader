// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/Simple Shader"
{
    Properties{
        //宣告一個Color屬性
        _Color("Color Tint",Color)=(1.0,1.0,1.0,1.0)
    }

    SubShader{
        Pass{

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //使用一個結構來定義頂點著色器的輸入
            struct a2v{
                //POSITION語義告訴UNITY，用模型空間的頂點坐標填充Vertex變數
                float4 vertex:POSITION;

                //NORMAL語義告訴UNITY，用模型空間的法綫方向填充normal變數
                float3 normal:NORMAL;

                //TEXCOORD0語義告訴UNITY，用模型的第一套紋理坐標填充texcoord變數
                float4 texcoord:TEXCOORD0;
            };

            //使用一個結構來定義頂點著色器的輸出
            struct v2f{
                //SV_POSITION 語義告訴UNITY，pos裡包含了頂點在修改空間中的位置資訊
                float4 pos:SV_POSITION;

                //COLOR 語義可以用於儲存顔色
                fixed3 color:COLOR0;

            };


            v2f vert(a2v v):SV_POSITION{
                //宣告輸出結構
                v2f o;

                o.pos=UnityObjectToClipPos(v.vertex)

                //v.normal 包含了頂點的法綫方向，其分量範圍在[-1.0,1.0]
                //下面的程式把分量範圍對應到了[0.0,1.0]
                //儲存到o.color中傳遞給片段著色器
                o.color=v.normal * 0.5+fixed3(0.5,0.5,0.5);

                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed3 c =i.color;
                c*=_Color.rgb;
                return fixed4(c,1.0);
            }
            ENDCG
        }
        
    }
}
