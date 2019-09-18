Shader "TS/Diced"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Width("Width", float) = 50
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
            float _Width;


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                // sinの値が0以下の部分(黒色部分)を0, 0以上の部分(白色部分)を0.5で表す。
                // 1ではなく、0.5なところが味噌。縦方向も同じように黒を0(0 * 0.5 = 0), 白を0.5(1 * 0.5 = 0.5)で表す
                // fixed2型、i.uvでx(横)、y(縦)をまとめて処理している
                fixed2 v = step(0, sin(_Width * i.uv)) * 0.5;
                // fracは数値から小数部分を取り出す演算なので、0は「0」、0.5は「5」になる。
                // この 0 と 5 に2をかけることで、0 と 1 になり、白と黒の市松模様が再現できる
                return frac(v.x + v.y) * 2; 
			}
			ENDCG
		}
	}
}
