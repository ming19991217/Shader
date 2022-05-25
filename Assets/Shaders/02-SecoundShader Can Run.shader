// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "02-SecoundShader Can Run"{

SubShader{
    Pass{
        CGPROGRAM

        //頂點函數 這裏只是聲明了 頂點函數的函數名 
        //基本作用：確定位置 完成頂點坐標從模型空間到剪裁空間的轉換（從游戲環境轉換到視野相機屏幕上） 
        #pragma vertex vert
       
        //片元函數 這裏只是聲明了 片元函數的函數名
        //基本作用：確定顔色 返回模型對應的屏幕上的每一個像素的顏色值
        #pragma fragment frag


        //通過語義告訴系統，我這個參數是幹嘛的，如POSITION是告訴系統我需要頂點坐標
        //POSITION 語義 把頂點坐標傳遞給v
        //SV_POSITION 語義 這個語義用來解釋説明返回值，意思是返回值是剪裁空間下的頂點坐標
        float4 vert(float4 v:POSITION):SV_POSITION{ 
            //完成頂點坐標從模型空間到剪裁空間的轉換
          //float4 pos= UnityObjectToClipPos(v);//矩陣與v相乘 獲得剪裁空間
            //UNITY_MAIRIX_MVP 矩陣 4*4 
            //return UnityObjectToClipPos(v);
            return UnityObjectToClipPos(v);

        }

        //返回模型對應的屏幕上的每一個像素的顏色值
        fixed4 frag():SV_Target{
            return fixed4(0.5,1,1,1);
        }

        ENDCG
    }
}

Fallback "VertexLit"

}