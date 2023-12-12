#ifndef _STD3D
#define _STD3D

#include "value.fx"
#include "func.fx"

// 월드 상 기준으로 값 부여
static float3 g_vLightPos = float3(0.f, 0.f, 0.f);  // 월드 상에서 광원 위치를 원점으로 잡음 
static float3 g_vLightDir = float3(1.f, -1.f, 1.f); // 빛의 방향 

static float3 g_vLightColor = float3(1.f, 1.f, 1.f);
static float3 g_vLightSpec = float3(0.3f, 0.3f, 0.3f);
// 환경광 (레이트레이싱 기법을 쓰지 않으면 아래처럼 기본적인 환경광 수치를 그냥 부여한다)
static float3 g_vLightAmb = float3(0.15f, 0.15f, 0.15f); 

struct VS_IN
{
    float3 vPos : POSITION;
    float2 vUV : TEXCOORD;
    
    float3 vNormal : NORMAL;
};

struct VS_OUT
{
    float4 vPosition : SV_Position;
    float2 vUV : TEXCOORD;   
    
   // float fLightPow : FOG; // fog : float하나를 넘길 때 쓰는 시멘틱이다.
    float3 vWorldNormal : NORMAL;
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
    output.vWorldNormal = normalize(mul(float4(_in.vNormal, 0.f), g_matWorld)).xyz;
    
    
    // 물체의 위치에는 이동 값도 적용되야하므로 w값을 1로 설정 
    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);    
    output.vUV = _in.vUV;
    
    // 픽셀쉐이더에게 넘겨줘서 각 픽셀들이 정점의 빛의 세기를 보간해서 받아가게끔 해주기 위해 넘겨준다.
   // output.fLightPow = fLightPow;    
    
    return output;
}


// 픽셀 단위로 좀 더 정밀한 빛 연산을 한다.
float4 PS_Std3D(VS_OUT _in) : SV_Target
{
    float4 vOutColor = (float4) 0.f;
    
    vOutColor = float4(0.5f, 0.5f, 0.5f, 1.f);
    
        // 월드상에서의 광원의 방향
    g_vLightDir = normalize(g_vLightDir);
    
        
   // -- 정점에 들어오는 빛의 세기가 어느정도인지에 대해 계산한다.
    // 길이를 1로 만들어준 광원의 역방향과 월드 상의 노말 벡터를 내적한다. 
    // 이런 방법을 '램버트 코사인 법칙'이라고 한다. 
    // 빛의 세기는 빛을 안받는다 하더라도 음수로 빠지게 두면 안된다. 코싸인 그래프에 의하면 음수로 빠지면 빛을 빨아들이는 형태기 때문.
    // 때문에 빛의 세기는 최소 0도를 보장해야한다. 이렇게 음수로 빠지지 않게 0~1 사이의 값을 유지하게해주는 역할을 하는게 saturate다.
    float fLightPow = saturate(dot(_in.vWorldNormal, -g_vLightDir));
    
     // 보간되어 들어온 빛의 세기값을 출력 색상과 곱해준다.
    // 환경광 또한 출력 색상와 어우러져야되기 때문에 곱해준다.
    vOutColor.xyz = (vOutColor.xyz * fLightPow) + (vOutColor.xyz * g_vLightAmb);
    
    return vOutColor;
}



#endif