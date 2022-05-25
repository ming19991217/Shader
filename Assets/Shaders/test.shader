
Shader "Custom/10-Diffuse Specular"
{
    
    SubShader{
        Pass{
            
            CGPROGRAM

            
            #pragma vertex vert
            #pragma fragment frag

            

            struct a2v{
                float4 vertex:POSITION;
                
                
            };
            struct v2f{
                float4 svPos:SV_POSITION;
                float depth:DEPTH;

                
            };



            v2f vert(a2v v){
                v2f f;
                f.svPos=UnityObjectToClipPos(v.vertex);
                f.depth=-(mul(UNITY_MATRIX_MV,v.vertex).z)*_ProjectionParams.w;
                return f;
            }

            fixed4 frag(v2f f):SV_Target{
                float invert =1-f.depth;
                return fixed4(invert,invert,invert,1);

            }
            ENDCG
        }

    }
    Fallback "Specular"

}
