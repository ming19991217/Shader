Shader "03-Use Struct"{

    SubShader{
        Pass{
            CGPROGRAM
            //application to vertex 應用程序到頂點函數的語義：
            //POSITION 頂點坐標（模型空間下的）
            //NORMAL 法綫（模型空間下）
            //TANGENT 切綫（模型空間）
            //TEXCOORD0 ~n 紋理坐標
            //COLOR 頂點顔色

            //頂點函數到片元函數的時候可以使用的語義：
            //SV_POSITION 剪裁空間中的頂點坐標（一般是系統直接使用）
            //COLOR0 可以傳遞一組值 4個
            //COLOR1 可以傳遞一組值 4個
            //TEXCOORD0 ~ 7 傳遞紋理坐標

            //片元函數傳遞給系統：
            //SV_Target 顔色值，顯示到屏幕上的顔色

            //光照糢型
            //光照模型就是一個公式，使用這個公式來計算某個點的光照效果

            //標準光照模型
            //在標準光照模型裏面，我們把進入攝像機的光分爲下面四個部分
            //自發光   
            //高光反射
            //漫反射
            //環境光 

            
            #pragma vertex vert       
            
            #pragma fragment frag

            //application to vertex 應用程序到頂點
            struct a2v{ //結構體 封裝
                float4 vertex:POSITION;//告訴unity把模型空間下的頂點坐標填充給vertex
                float3 normal:NORMAL;//告訴unity把模型空間下的法綫方向填充給normal
                float4 texcoord:TEXCOORD0;//告訴unity把第一套紋理坐標填充給texcoord
            };

            struct v2f{
                float4 position:SV_POSITION;
                float3 temp:COLOR0;//這個語義可以由用戶自己的定義，一般都存儲顔色
            };


            v2f vert(a2v v){ 
                v2f f;
                f.position=UnityObjectToClipPos(v.vertex);
                f.temp=v.normal;
                return f;
            }
            
            fixed4 frag(v2f f):SV_Target{
                return fixed4(f.temp,1);
            }

            ENDCG
        }
    }

    Fallback "VertexLit"

}