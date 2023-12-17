#ifndef _FUNC
#define _FUNC

#include "value.fx"

void CalcLight2D(float3 _vWorldPos, inout tLightColor _Light)
{       
    for (int i = 0; i < g_Light2DCount; ++i)
    {
        if (g_Light2DBuffer[i].LightType == 0)
        {
            _Light.vDiffuse.rgb += g_Light2DBuffer[i].Color.vDiffuse.rgb;
            _Light.vAmbient.rgb += g_Light2DBuffer[i].Color.vAmbient.rgb;
        }
        else if (g_Light2DBuffer[i].LightType == 1)
        {
            float3 vLightWorldPos = float3(g_Light2DBuffer[i].vWorldPos.xy, 0.f);
            float3 vWorldPos = float3(_vWorldPos.xy, 0.f);

            float fDistance = abs(distance(vWorldPos, vLightWorldPos));
            float fPow = saturate(1.f - (fDistance / g_Light2DBuffer[i].Radius));
        
            _Light.vDiffuse.rgb += g_Light2DBuffer[i].Color.vDiffuse.rgb * fPow;
        }
        else if (g_Light2DBuffer[i].LightType == 2)
        {
            
        }
    }
}

void CalcLight2D(float3 _vWorldPos, float3 _vWorldDir, inout tLightColor _Light)
{
    for (int i = 0; i < g_Light2DCount; ++i)
    {
        if (g_Light2DBuffer[i].LightType == 0)
        {
            float fDiffusePow = saturate(dot(-g_Light2DBuffer[i].vWorldDir.xyz, _vWorldDir));
            _Light.vDiffuse.rgb += g_Light2DBuffer[i].Color.vDiffuse.rgb * fDiffusePow;                        
            _Light.vAmbient.rgb += g_Light2DBuffer[i].Color.vAmbient.rgb;
        }
        else if (g_Light2DBuffer[i].LightType == 1)
        {
            float3 vLightWorldPos = float3(g_Light2DBuffer[i].vWorldPos.xy, 0.f);
            float3 vWorldPos = float3(_vWorldPos.xy, 0.f);

            // 광원 중심에서 물체를 향하는 방향
            float3 vLight = normalize(vWorldPos - vLightWorldPos);
            float fDiffusePow = saturate(dot(-vLight, _vWorldDir));
            
            float fDistance = abs(distance(vWorldPos, vLightWorldPos));
            float fDistPow = saturate(1.f - (fDistance / g_Light2DBuffer[i].Radius));
        
            _Light.vDiffuse.rgb += g_Light2DBuffer[i].Color.vDiffuse.rgb * fDiffusePow * fDistPow;
        }
        else if (g_Light2DBuffer[i].LightType == 2)
        {
            
        }
    }
}

// 뷰스페이스를 기준으로 조명 연산 진행
// _vViewPos : 호출될 픽셀의 뷰스페이스상의 본인의 위치
// 광원의 적용을 받을 픽셀 본인의 노말 값
// (이걸 알아야 _vViewPos와 _vViewNormal의 방향을 내적해서 램버튼 코사인 법칙의 의한 뷰스페이스상의 빛의 세기를 알 수 있기 때문)
// _LightIdx : 나한테 적용될 광원이 인덱스버퍼의 몇 인덱스에 있는지 
// tLightColor : 연산을 하고 난 뒤의 최종 색상을 담아낼 용도. inout을 붙였기 때문에 tLightColor에 들어있는 값을
// 입력으로도 받아오고, 받아온 걸 수정하면 그 값이 원본에도 적용이 된다(레퍼런스 개념)
void CalcLight3D(float3 _vViewPos, float3 _vViewNormal, int _LightIdx, inout tLightColor _Light, inout float _SpecPow)
{
    
   // 월드상에서의 광원의 방향
   // g_vLightDir = normalize(g_vLightDir);
    
    
    tLightInfo LightInfo = g_Light3DBuffer[_LightIdx];
    
    float fLightPow = 0.f;
    float fSpecPow = 0.f;
    float3 vViewLightDir = (float3) 0.f;
        
    // DirLight 인 경우
    if (0 == LightInfo.LightType)
    {
        
        
    // == View상에서의 광원의 방향
    // 0으로 두는 이유는 방향이기 때문에 행렬의 크기나 이동에 적용을 받지 않기 위해서다.
    // g_matView를 곱해주는 이유는 g_vLightDir의 초기값을 월드를 기준으로 뒀기 때문에 이것을 뷰스페이스로 보내기 위함
    // 맨 앞에 다시 normalize를 하는 이유는 g_matView 안에는 이동 크기 정보도 있기 때문에 혹시몰라서 방향 정보를 정확하게 유지하기 위해서 해둠
    // vWorldDir를 16바이트 단위로 맞춰주기 위해 flaot4로 해둔 상황. w값은 필요없으니  xyz라고 구체적으로 명시해둠
    // ******* 근데 왜 인덱스0에서만 ㄲ ㅓ내는지 궁금함. 일단 우리는 현재 넣은게 1개뿐이라 그런건지.... 아니면 흠
    // directional 광원은 '방향 정보'만 필요하기 때문에 worldPos는 안쓰고 worldDir만 아래에 쓰고 있는 것이다
        vViewLightDir = normalize(mul(float4(normalize(LightInfo.vWorldDir.xyz), 0.f), g_matView)).xyz;
        
            // 월드상에서의 광원의 방향
   // g_vLightDir = normalize(g_vLightDir);
    
     
   // == 정점에 들어오는 빛의 세기가 어느정도인지에 대해 계산한다.
    // 길이를 1로 만들어준 광원의 역방향과 월드 상의 노말 벡터를 내적한다. 
    // 이런 방법을 '램버트 코사인 법칙'이라고 한다. 
    // 빛의 세기는 빛을 안받는다 하더라도 음수로 빠지게 두면 안된다. 코싸인 그래프에 의하면 음수로 빠지면 빛을 빨아들이는 형태기 때문.
    // 때문에 빛의 세기는 최소 0도를 보장해야한다. 이렇게 음수로 빠지지 않게 0~1 사이의 값을 유지하게해주는 역할을 하는게 saturate다.  
   // float fLightPow = saturate(dot(_in.vViewNormal, -g_vLightDir)); // 월드 기준이였을 때의 빛의 세기 구하는 방법
    
    // view 스페이스에서의 노말벡터와 광원의 방향을 내적하여 빛의 세기를 구함(램버트 코사인 법칙)   
        fLightPow = saturate(dot(_vViewNormal, -vViewLightDir));
        
     // 월드 상에서의 반사광의 방향 벡터 구하는 공식
    //float3 vWorldReflect = g_vLightDir + 2.f * (dot(-g_vLightDir, _in.vWorldNormal)) * _in.vWorldNormal;
    
    // 뷰스페이스상에서의 반사광의 방햑 벡터 구하는 공식 (뷰스페이스상의 노말을 가지고 구한다)
    // 내적을 해서 구한 다음 그걸 2배로 키워서 뷰공간에서의 반사각을 구한다. 
    // ** 원래 반사광을 구하는 함수가 hlsl의 reflect라고 있는데 면접에서 반사광 구하는 공식 쓰라고 나온 적 있댔어서 쌤이 일부러 아래로 했다함             
        float3 vViewReflect = normalize(vViewLightDir + 2.f * (dot(-vViewLightDir, _vViewNormal)) * _vViewNormal);        
         // float3 vViewReflect = normalize(reflect(vViewLightDir, _vViewNormal)); (reflect 함수 활용하면 위에껀 안써도 됨)
    
    // 뷰스페이스상의 픽셀의 좌표는 곧 카메라가 물체를 향하는 방향벡터와도 같다. (뷰스페이스는 원점에 카메라가 있기 때문)
    // 방향이기 때문에 normalize를 한다. 물체가 뷰스페이스의 카메라를 바라보는 방향과 원점에서 물체를 바라보는 방향이 같은지 아닌지로
    // 반사광이 카메라 방향으로 튀었는지를 판별할 수 있다. (같다면 둘 중 한 녀석을 뒤집어서 내적을 하여 코싸인 셀타(각도(를 구한 뒤,
    // 해당 각도에 따른 빛의 세기를 코싸인 그래프를 참고하여 알 수 있다.
        float3 vEye = normalize(_vViewPos);
        
        
     // 반사광의 세기 구하기
     // 반사광이 바라보는 각도에 따라 뷰스페이스상의 빛의 세기를 구한다. 
     // 왜 역방향으로 내적을 하냐면, 그렇게 안하면 오히려 최대치 180도라는 각도가 나오게 되기 때문
    // saturate를 안해주면 반사광이 과하게 붙어서 엄청 새까매짐.
        fSpecPow = saturate(dot(vViewReflect, -vEye));
        
        
    // 코싸인그래프의 모양을 뒤집어 주기 위해 제곱함 (제곱하면 점점 값이 낮아짐)
        fSpecPow = pow(fSpecPow, 20); // 20승을 해준다는 의미의 코드다. 
    }
    
    // 2. Point Light인 경우
    else if (1 == LightInfo.LightType)
    {
         // 거리에 따른 빛의 세기
        // 빛의 세기가 거리에 따라 감쇄되는 효과를 주기 위해 만듦.
        // 이걸 하지 않으면 point light의 지정한 반경 밖으로도 빛이 나가게 됨 
        float fDistPow = 1.f;
        
        // == ViewSpace에서의 광원의 위치
        // 위치는 이동값의 영향을 받아야하니 1로 확장 
        float3 vLightViewPos = mul(float4(LightInfo.vWorldPos.xyz, 1.f), g_matView).xyz;
        
        // 광원에서 호출되는 픽셀로 가는 빛의 방향 구하기(방향이므로 normalize해서 길이를 1로 만들어둠)
        vViewLightDir = normalize(_vViewPos - vLightViewPos);
        
        
        // point light로부터 픽셀 간의 거리 체크 
        float fDist = distance(_vViewPos, vLightViewPos); // 두 점 사이에 거리값을 구함        
        
        
        // range의 최대치에 가까워질수록 빛의 세기가 옅어지는 효과를 주기 위해 거리에 따른 비율을 구해준다.    
       
        // Q. 1로 뺴준 이유?
        // 반경이 1천인데 fDist가 1천이라면 거의 끝에 도달했다는 의미가 된다. 그런데 이 둘을 나누면 오히려
        // 빛의 세기가 쎄진다 (최대값 1이 나오기 때문). 또한 반경이 1천인데, dist가 200 정도의 위치에 있다면
        // 0.2가 나온다. 그런데 dist에 가까울수록 오히려 빛의 세기가 쎄야할 것이다. 때문에 1에서 빼줘서
        // 0.8로 만들어서 80퍼의 빛을 가져갈 수 있도록 바꿔준거다.
        // 또한 음수로 빠지는 걸 방지하기 위해서라도 saturate를 해준다.
        fDistPow = saturate(1.f - (fDist / LightInfo.Radius));
               
        
         // viewSpace에서의 노말벡터와 광원의 방향을 내적 (램버트 코사인 법칙)
        fLightPow = saturate(dot(_vViewNormal, -vViewLightDir)) * fDistPow;
        
        // 반사광
        float3 vViewReflect = normalize(vViewLightDir + 2.f * (dot(-vViewLightDir, _vViewNormal)) * _vViewNormal);
        float3 vEye = normalize(_vViewPos);
        
        // 반사광의 세기 구하기
        fSpecPow = saturate(dot(vViewReflect, -vEye));
        fSpecPow = pow(fSpecPow, 20) * fDistPow; // 20승을 해준다는 의미의 코드다. 
    }
    
    // Spot Light 인 경우
    else
    {
        // LightDir 과 Angle 값을 활용해서 SpotLight 구현해보기
    }
  
    
    // ======= 연산 결과 전달 
    // 광원의 빛의 세기만 구해주는 함수기 때문에 물체의 색은 안 곱하고 순수하게 광원의 색상에만 곱해줌 
    _Light.vDiffuse += LightInfo.Color.vDiffuse * fLightPow; 
    _Light.vAmbient += LightInfo.Color.vAmbient;
    _SpecPow += fSpecPow; // 최종  반사광의 세기 
}

// ======
// Random
// ======
static float GaussianFilter[5][5] =
{
    0.003f,  0.0133f, 0.0219f, 0.0133f, 0.003f,
    0.0133f, 0.0596f, 0.0983f, 0.0596f, 0.0133f,
    0.0219f, 0.0983f, 0.1621f, 0.0983f, 0.0219f,
    0.0133f, 0.0596f, 0.0983f, 0.0596f, 0.0133f,
    0.003f,  0.0133f, 0.0219f, 0.0133f, 0.003f,
};

void GaussianSample(in Texture2D _NoiseTex, float2 _vResolution, float _NomalizedThreadID, out float3 _vOut)
{
    float2 vUV = float2(_NomalizedThreadID, 0.5f);       
    
    vUV.x += g_AccTime * 0.5f;
    
    // sin 그래프로 텍스쳐의 샘플링 위치 UV 를 계산
    vUV.y -= (sin((_NomalizedThreadID - (g_AccTime/*그래프 우측 이동 속도*/)) * 2.f * 3.1415926535f * 10.f/*반복주기*/) / 2.f);
    
    if( 1.f < vUV.x)
        vUV.x = frac(vUV.x);
    else if(vUV.x < 0.f)
        vUV.x = 1.f + frac(vUV.x);
    
    if( 1.f < vUV.y)
        vUV.y = frac(vUV.y);
    else if (vUV.y < 0.f)
        vUV.y = 1.f + frac(vUV.y);
        
    int2 pixel = vUV * _vResolution;           
    int2 offset = int2(-2, -2);
    float3 vOut = (float3) 0.f;    
    
    for (int i = 0; i < 5; ++i)
    {
        for (int j = 0; j < 5; ++j)
        {            
            vOut += _NoiseTex[pixel + offset + int2(j, i)] * GaussianFilter[i][j];
        }
    }        
    
    _vOut = vOut;    
}

#endif
