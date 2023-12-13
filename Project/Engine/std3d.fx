#ifndef _STD3D
#define _STD3D

#include "value.fx"
#include "func.fx"

// 월드 상 기준으로 값 부여
static float3 g_vLightPos = float3(0.f, 0.f, 0.f);  // 월드 상에서 광원 위치를 원점으로 잡음 
static float3 g_vLightDir = float3(1.f, -1.f, 1.f); // 빛의 방향 

static float3 g_vLightColor = float3(1.f, 1.f, 1.f);
//static float g_vLightSpec = float3(0.3f, 0.3f, 0.3f);
static float g_fLightSpecCoeff = 0.3f; // 최대 반사광 색상


// 환경광 (레이트레이싱 기법을 쓰지 않으면 아래처럼 기본적인 환경광 수치를 그냥 부여한다)
static float3 g_vLightAmb = float3(0.15f, 0.15f, 0.15f); 

struct VS_IN
{
    float3 vPos : POSITION;
    float2 vUV : TEXCOORD;
    
    // 정점 안에 있는 벡터 정보를 갖고온다. 
    float3 vNormal : NORMAL;
    float3 vTangent : TANGENT;
    float3 vBinormal : BINORMAL;
};

struct VS_OUT
{
    float4 vPosition : SV_Position;
    float2 vUV : TEXCOORD;   
    
   // float fLightPow : FOG; // fog : float하나를 넘길 때 쓰는 시멘틱이다.
    
    // 뷰 스페이스 기준으로 라이팅 연산을 위해 아래처럼 이름 지어줌
    float3 vViewPos : POSITION; 
    
    float3 vViewNormal : NORMAL;
    float3 vViewTangent : TANGENT;
    float3 vViewBinormal : BINORMAL;
};


VS_OUT VS_Std3D(VS_IN _in)
{
    VS_OUT output = (VS_OUT) 0.f;
    
    
    // 로컬 상의 normal 방향을 월드로 이동시켜서 월드 상의 노말 벡터 방향을 구한다. 
    
    /* 로컬스페이스 상에서 정점에 넣어둔 노말 정보는 회전이 아예 없다는 가정하에 했으므로 매개로 들어온 노말 값은
     회전이 아예 고려되지 않은 상태다. 그러나 게임 상에 배치될 때 물체는 회전된 상태로 배치될 수도 있다. 때문에 회전 고려를 위해서라도
     로컬 상의 노말 정보를 월드에 이동시켜야한다. 월드행렬에 회전 값이 있기 때문.
    
     월드행렬에는 이동과 크기 값도 같이 있다. 우리는 회전값만 필요로 하므로 이동과 크기는 적용받게 해선 안된다. 
    때문에 아래 노말 값의 w값은 0으로 확대. 크기도 늘어난 상태일 수 있으므로 길이를 1로 만들어야하기 땜에 normalize해준다 */
    //output.vViewNormal = normalize(mul(float4(_in.vNormal, 0.f), g_matWorld)).xyz;
    
    
    // 입력으로 들어온 정점에다가 뷰스페이스를 곱하여, 뷰스페이스상의 정점의 위치를 구해낸다.
    // 좌표를 구하는거기 때문에 w값은 1로 둔다. 이 값이 픽셀쉐이더로 넘어가게 되면 보간된 뷰공간에서의 픽셀들의 좌표도 알아낼 수 있게 된다.
    output.vViewPos = mul(float4(_in.vPos, 1.f), g_matWV);
    
    // === 모든 연산을 뷰 스페이스를 기준으로 둔다. 즉, 카메라를 원점으로 보낸 상황. 또한 카메라가 보는 방향이 z축이 됨
    output.vViewNormal = normalize(mul(float4(_in.vNormal, 0.f), g_matWV)).xyz;
    output.vViewTangent = normalize(mul(float4(_in.vTangent, 0.f), g_matWV)).xyz;
    output.vViewBinormal = normalize(mul(float4(_in.vBinormal, 0.f), g_matWV)).xyz;
     
    
    
    // 물체의 위치에는 이동 값도 적용되야하므로 w값을 1로 설정 
    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);    
    output.vUV = _in.vUV;
    
    // 픽셀쉐이더에게 넘겨줘서 각 픽셀들이 정점의 빛의 세기를 보간해서 받아가게끔 해주기 위해 넘겨준다.
   // output.fLightPow = fLightPow;    
    
    return output;
}


// 픽셀 단위로 좀 더 정밀한 빛 연산을 한다.
// 입력에 들어오는 것은 이제 뷰 스페이스 기준의 노말 정보가 들어오게 된다. 
float4 PS_Std3D(VS_OUT _in) : SV_Target
{
    float4 vOutColor = float4(0.5f, 0.5f, 0.5f, 1.f);
    
    // 입력으로 들어온 뷰스페이스상의 노말을 받아둔다.
    float3 vViewNormal = _in.vViewNormal;
    
    if(g_btex_0)
    {
        vOutColor = g_tex_0.Sample(g_sam_0, _in.vUV);
    }
    
    
    // 텍스처에 노말 정보 넣어주는 용도
    // 여기에 바인딩된 게 있다면 해당 텍스처에 꺼낸 노말을 vViewNormal로 쓸 것이다.
    if (g_btex_1)
    {
        float3 vNormal = g_tex_1.Sample(g_sam_0, _in.vUV).xyz;
        
        // 0~1범위로 샘플링 되는 값을 탄젠트 스페이스 좌표계의 범위인 -1 ~ 1로 확장하기 위해 0~2로 확대한 후, 전체에 -1을 해준 것
        // 이렇게 한 이유는 저장되어 있는 데이터가 '방향 데이터'이기 때문이다.
        vNormal = vNormal * 2.f - 1.f;
        
        // 뷰스페이스 기준의 각 정보들을 갖고 와서 회전 행렬 만듦
        // 왜 회전을 하냐면 우리쪽 표면으로 텍스처의 방향 정보를 가져오기 위해서다.
        // 즉, 우리 쪽 물체의 원래 방향정보들을 미리 구해놓고 탄젠트스페이스의 좌표계의 각 축들에 어떤 회전 행렬을 곱하면
        // 서로의 각 축이 일치하게 될 것이다. (x는 t, y는 N, z축은 b). 이렇게 만드는 어떤 회전행렬을 구해서 
        // 추출하려는 탄젠트스페이스 축에 곱해주면 우리 표면에 회전한 상태로 가져다 놓을 수 있기 때문이다.  
        // 근데 우리쪽 물체의 원래 방향정보들이 단위행렬의 형태라서 결국 그 어떤 회전 행렬은 t/n/b (1열 3행)이었던거다.
        // 그래서 아래처럼 입력으로 들어온 값을 받아둔것  
        float3x3 vRotateMat = 
        {
            _in.vViewTangent,
            -_in.vViewBinormal, // 원래는 음수로 안뒤집어도 되는데 쌤 텍스처가 좌표계가 반대라서 -로 뒤집음(오픈지엘 좌표계써서)
            _in.vViewNormal
        };
        
        vViewNormal = mul(vNormal, vRotateMat);

    }
    
    
    
    // 월드상에서의 광원의 방향
   // g_vLightDir = normalize(g_vLightDir);
    
    // View상에서의 광원의 방향
    // 0으로 두는 이유는 방향이기 때문에 행렬의 크기나 이동에 적용을 받지 않기 위해서다.
    // g_matView를 곱해주는 이유는 g_vLightDir의 초기값을 월드를 기준으로 뒀기 때문에 이것을 뷰스페이스로 보내기 위함
    // 맨 앞에 다시 normalize를 하는 이유는 g_matView 안에는 이동 크기 정보도 있기 때문에 혹시몰라서 방향 정보를 정확하게 유지하기 위해서 해둠
    float3 vViewLightDir = normalize(mul(float4(normalize(g_vLightDir), 0.f), g_matView)).xyz;
        
    
    
   // -- 정점에 들어오는 빛의 세기가 어느정도인지에 대해 계산한다.
    // 길이를 1로 만들어준 광원의 역방향과 월드 상의 노말 벡터를 내적한다. 
    // 이런 방법을 '램버트 코사인 법칙'이라고 한다. 
    // 빛의 세기는 빛을 안받는다 하더라도 음수로 빠지게 두면 안된다. 코싸인 그래프에 의하면 음수로 빠지면 빛을 빨아들이는 형태기 때문.
    // 때문에 빛의 세기는 최소 0도를 보장해야한다. 이렇게 음수로 빠지지 않게 0~1 사이의 값을 유지하게해주는 역할을 하는게 saturate다.  
   // float fLightPow = saturate(dot(_in.vViewNormal, -g_vLightDir)); // 월드 기준이였을 때의 빛의 세기 구하는 방법
    
    // view 스페이스에서의 노말벡터와 과우언의 방향을 내적하여 빛의 세기를 구함(램버트 코사인 법칙)
    float fLightPow = saturate(dot(vViewNormal, -vViewLightDir));
    
    // 월드 상에서의 반사광의 방향 벡터 구하는 공식
    //float3 vWorldReflect = g_vLightDir + 2.f * (dot(-g_vLightDir, _in.vWorldNormal)) * _in.vWorldNormal;
    
    // 뷰스페이스상에서의 반사광의 방햑 벡터 구하는 공식 (뷰스페이스상의 노말을 가지고 구한다)
    // 내적을 해서 구한 다음 그걸 2배로 키워서 뷰공간에서의 반사각을 구한다. 
    // 이렇게 되면 
    float3 vViewReflect = normalize(vViewLightDir + 2.f * (dot(-vViewLightDir, vViewNormal)) * vViewNormal);
    
    // 뷰스페이스상의 픽셀의 좌표는 곧 카메라가 물체를 향하는 방향벡터와도 같다. (뷰스페이스는 원점에 카메라가 있기 때문)
    // 방향이기 때문에 normalize를 한다. 물체가 뷰스페이스의 카메라를 바라보는 방향과 원점에서 물체를 바라보는 방향이 같은지 아닌지로
    // 반사광이 카메라 방향으로 튀었는지를 판별할 수 있다. (같다면 둘 중 한 녀석을 뒤집어서 내적을 하여 코싸인 셀타(각도(를 구한 뒤,
    // 해당 각도에 따른 빛의 세기를 코싸인 그래프를 참고하여 알 수 있다.
    float3 vEye = normalize(_in.vViewPos);
    
    // 뷰스페이스상의 빛의 세기를 구한다. 왜 역방향으로 내적을 하냐면, 그렇게 안하면 오히려 최대치 180도라는 각도가 나오게 되기 때문
    // saturate를 안해주면 반사광이 과하게 붙어서 엄청 새까매짐
    float fSpecPow = saturate(dot(vViewReflect, -vEye));
    
    // 코싸인그래프의 모양을 뒤집어 주기 위해 제곱함 (제곱하면 점점 값이 낮아짐)
    fSpecPow = pow(fSpecPow, 20); // 20승을 해준다는 의미의 코드다. 
      
    
     //=== 반사광이 없었을 때
    //보간되어 들어온 빛의 세기값을 출력 색상과 곱해준다.
    // 환경광 또한 출력 색상와 어우러져야되기 때문에 곱해준다.
   // vOutColor.xyz = (vOutColor.xyz * fLightPow) + (vOutColor.xyz * g_vLightAmb);
    
    
    // === 반사광이 있는 현재
    // 반사광에는 빛의 세기에다가 물체의 색을 곱해주지 않음. 튕겨낸 빛이기 때문에 본래의 광원의 색을 가져가야되기 때문
    // 빛 자체에도 색상이 있기 때문에 g_vLightcolor라는 걸 위에서 만들어줬었음.    
    vOutColor.xyz = (vOutColor.xyz * g_vLightColor * fLightPow) // g_vLightColor를 왜 곱해야하냐면 물체가 빨간색이면 조명이 하얀색이어도 붉게 비춰져야하기 때문
                    + (vOutColor.xyz * g_vLightColor * g_vLightAmb)
                    + g_vLightColor * g_fLightSpecCoeff * fSpecPow;
   
    
    return vOutColor;
}



#endif