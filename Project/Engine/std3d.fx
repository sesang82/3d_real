#ifndef _STD3D
#define _STD3D

#include "value.fx"
#include "func.fx"



// === 광원 정보를 렌더매니저에서 보내주고 있기 때문에 아래 값은 이제 안 사용함 (임시값이었기 때문) 
//// 월드 상 기준으로 값 부여
//static float3 g_vLightPos = float3(0.f, 0.f, 0.f);  // 월드 상에서 광원 위치를 원점으로 잡음 
//static float3 g_vLightDir = float3(1.f, -1.f, 1.f); // 빛의 방향 

//static float3 g_vLightColor = float3(1.f, 1.f, 1.f);
////static float g_vLightSpec = float3(0.3f, 0.3f, 0.3f);
//static float g_fLightSpecCoeff = 0.3f; // 최대 반사광 색상

// 환경광 (레이트레이싱 기법을 쓰지 않으면 아래처럼 기본적인 환경광 수치를 그냥 부여한다)
//static float3 g_vLightAmb = float3(0.15f, 0.15f, 0.15f); 





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
    float3 vViewBinormal: BINORMAL;    
};


// ===========================
// Std3DShader
//
// Param

// 나중에 반사 계수가 0에 가까워질수록 반사된 환경을 맵핑하는 것의 품질을 저하시키는 것까지 할 것임.
#define SPEC_COEFF g_float_0 // 반사 계수

// 환경 맵핑이 가능한 큐브텍스처 관련
#define IS_SKYBOX_ENV   g_btexcube_0
#define SKYBOX_ENV_TEX  g_cube_0


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
    
    
    // 일반 텍스처가 바인딩 된게 있다면
    if(g_btex_0)
    {
        vOutColor = g_tex_0.Sample(g_sam_0, _in.vUV);
    }
    
    
    // == 만약에 노말 텍스처를 바인딩했다면
    // 여기에 바인딩된 게 있다면 해당 텍스처에 꺼낸 노말을 vViewNormal로 쓸 것이다.
    if (g_btex_1)
    {
        float3 vNormal = g_tex_1.Sample(g_sam_0, _in.vUV).xyz;        
      
        
        // 0 ~ 1 범위의 값을 -1 ~ 1 로 확장        
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
        }; // 사용하는 노말 텍스처가 오픈지엘 좌표계를 쓴다면 바이노말에 -를 붙이고, 왼손좌표계dx좌표계를 쓴다면 +를 쓰도록 하는거 만들기
        
        vViewNormal = normalize(mul(vNormal, vRotateMat)); // 방향 값이기 때문에 확실하게 노말라이즈까지 해줌
    }
    
    tLightColor lightcolor = (tLightColor) 0.f;
    float fSpecPow = 0.f;
    
        // 레벨에 여러 개의 조명이 있을 때도 연산받을 수 있도록 해둠 
    for (int i = 0; i < g_Light3DCount; ++i)
    {
                
    // == 광원의 세기를 구한다.
    // 현재 3D광원을 1개만 넣어놨기 때문에 일단 인덱스는 0으로 해둠 
        CalcLight3D(_in.vViewPos, vViewNormal, i, lightcolor, fSpecPow);
    }
     
    
    
             //=== 반사광이 없었을 때
    //보간되어 들어온 빛의 세기값을 출력 색상과 곱해준다.
    // 환경광 또한 출력 색상와 어우러져야되기 때문에 곱해준다.
   // vOutColor.xyz = (vOutColor.xyz * fLightPow) + (vOutColor.xyz * g_vLightAmb);
    
    
    // === 반사광이 있는 현재
    // CalcLight3D에서 연산한 것을 받아다가 갖다 쓴다. 
    // 반사광에는 빛의 세기에다가 물체의 색을 곱해주지 않음. 튕겨낸 빛이기 때문에 본래의 광원의 색을 가져가야되기 때문
    // 빛 자체에도 색상이 있기 때문에 g_vLightcolor라는 걸 위에서 만들어줬었음.    
    // 여기서의 vOutColor는 물체의 색상    
    vOutColor.xyz = vOutColor.xyz * lightcolor.vDiffuse.xyz // g_vLightColor를 왜 곱해야하냐면 물체가 빨간색이면 조명이 하얀색이어도 붉게 비춰져야하기 때문
                    + vOutColor.xyz * lightcolor.vAmbient.xyz
                    + saturate(g_Light3DBuffer[0].Color.vDiffuse.xyz) * 0.3f * fSpecPow * SPEC_COEFF;
    
    
    // 큐브 메쉬이고, 환경 맵핑을 하려는 것인지에 대한 것
    if (IS_SKYBOX_ENV)
    {
        // 큐브 메쉬이므로 방향값을 이용하여 샘플링하는 방식을 이용한다.
        float3 vEye = normalize(_in.vViewPos); // 방향값만 취할 것이므로 노말라이즈. 여기서의 eye는 뷰스페이스상의 원점에 있는 카메라
        float3 vEyeReflect = normalize(reflect(vEye, vViewNormal)); // 둘의 반사광을 구하고 방향만 취한다. vViewNormal은 오브젝트의 호출된 픽셀의 노말 방향 
        
        // == 월드 상의 카메라가 오브젝트를 쳐다본 방향으로 튕겨나가는 반사광을 구한다 
        // 원래는 뷰스페이스 기준으로 그냥 계산했는데 그러다보니 뷰스페이스의 카메라의 z축이 정면만 보고 있어서
        // 실제로 카메라가 회전할 때 반사되는 그림이 달라져야하는데 똑같아서 뷰의 역행렬을 구해와서 월드 기준의 것으로 갖고 온 것
        vEyeReflect = normalize(mul(float4(vEyeReflect, 0.f), g_matViewInv));
        
        // 재질 계수가 낮을 수록 샘플링되는 품질이 저하되어야하는데 그건 아직 안되서 나중에 해주신다 함.
        // == 샘플링2로 한건 혹시나 다른 샘플러쓰면 그렇게 될까 싶어서 쌤이 추가해서 해봤는데 안됨
        vOutColor *= SKYBOX_ENV_TEX.Sample(g_sam_2, vEyeReflect);

    }
    
        return vOutColor;
}



#endif