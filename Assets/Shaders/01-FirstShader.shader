//這裏指定shader的名字，不要求跟文件名保持一致
Shader "myShader"{

//屬性
Properties{  

//屬性名字（"在面板上的名字", 類型）= RGBA
    _Color("Color",Color)=(1,1,1,1) 
    _Vector("Vector",Vector)=(1,2,3,4)
    _Int("Int",Int)=221312
    _Float("Float",Float)=2.3   //小數不用加f
    _Range("Range",Range(1,11))=6   //=6 是給一個默認值
    _2D("Texture",2D)= "white"{} //2D貼圖 ="white"{} 不指定貼圖默認為白色圖片
    _Cube("Cube",Cube)= "white"{}//立方體紋理 skyBox
    _3D("Texture",3D)="black"{}//3D紋理 較少使用

}
//子Shader 可以有多個SubShader 編寫效果 不同SubShader有不同效果 
//顯卡運行時 從第一個SubSader開始運行 如果第一個可以實現裏面的内容，就使用第一個Sub
//如果不行 自動去下一個SubShader
SubShader{ 

    //Pass塊 像在SubShader裡的方法 至少有一個Pass塊
    Pass{ 

        //在這裏編寫Shader代碼 HLSLPROGRAM
        //使用CG語言編寫Shader代碼 裏面代碼結束要;
        CGPROGRAM

        //在pass定義 float4 =RGBA Vector
        //定義在SubShader要用的屬性 沒有的可以不用定義
        float4 _Color; //float half fixed
        float4 _Vector;//half4 fixed4
        float _Int;
        float _Float;
        float _Range;
        sampler2D _2D;
        samplerCube _Cube;
        sampler3D _3D;
        //float 32位來存儲
        //half  16位 -6W ~ +6W
        //fixed 11位 -2 ~ +2 

        ENDCG


    }   

}

Fallback "VertexLit" //如果都無法實現 執行Fallback 使用指定的Shader



}