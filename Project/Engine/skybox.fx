#ifndef _SKYBOX
#define _SKYBOX

#include "value.fx"
#include "func.fx"

struct VS_SKY_IN
{
    float3 vPos : POSITION;
    float2 vUV : TEXCOORD;
    
};

struct VS_SKY_OUT
{
    float4 vPosition : SV_Position;
    float2 vUV : TEXCOORD;
    
    // 본인의 로컬pos가 곧 방향벡터
    float3 vPos : POSITION;
};

#define SKYBOX_TYPE g_int_0

VS_SKY_OUT VS_SkyBoxShader(VS_SKY_IN _in)
{
    VS_SKY_OUT output = (VS_SKY_OUT) 0.f;
    
    
    // 원점으로 들어온 구를 이루는 정점들은 뷰스페이스로 이동된걸로 가정하고 쉐이더를 작성할 것이다. (_in.vPos)
    // 먼저 우리는 뷰행렬을 곱해줄 것이다. 안곱해주면 다음과 같은 일이 일어난다.
    // 뷰스페이스상의 카메라가 원점에 있을 때, z축은 수직인 방향인데 그 z축이 바라보고 있는 면이 바로 구의 한 부분이기 때문이라
    // 카메라가 아무리 회전을 해도 그 부분만 보이게 된다.
    // 카메라의 회전에 따라 모든 면이 다 보일 수 있도록 하기 위해서라도 뷰행렬을 곱하는 것이다. 
    // 단 뷰행렬을 곱할 때, 우리는 '회전'만 적용되길 원하는 것이므로 w값은 이동에 영향을 받지 않도록 0으로 반드시 줘야한다.
    float4 vViewPos = mul(float4(_in.vPos, 0.f), g_matView); 
    float4 vProjPos = mul(vViewPos, g_matProj); 
    
    // z자리에 w를 넣어버리면 Pz.Vz였던 것이 Vz가 되어버린다. 이 상태로 레스터라이저에게 넘겨주면
    // w를 갖다 나눠쓸 때 z자리가 1이 되버리다보니 마치 스카이박스가 far위치에 있는 것처럼 멀리 거리를 두게 할 수 있는 것이다.
    // x, y 좌표는 ndc좌표계에 그대로 압축해서 해당 위치에 보이게는 하고 z값만 최대값을 줘서 
    // 계속 멀리서 보고 있는 것과 같은 눈속임을 줄 수 있는 것이다. 
    vProjPos.z = vProjPos.w;
    
    
    output.vPosition = vProjPos;
    output.vUV = _in.vUV;
    output.vPos = _in.vPos; // 이것들이 픽셀쉐이더의 입력으로 들어가면 각 픽셀들이 보간받아가서 면마다 동일한 벡터방향을 갖게 될것
    
    return output;
}

float4 PS_SkyBoxShader(VS_SKY_OUT _in) : SV_Target // 해당 시멘틱을 사용하면 이걸 레스터라이저가 가져다 쓴다.
{
    float4 vOutColor = (float4) 0.f;
    
    // 0 : Sphere type
    if(0 == SKYBOX_TYPE)
    {
    
        if (g_btex_0)
        {
            vOutColor = g_tex_0.Sample(g_sam_0, _in.vUV);
        }
    }
    
    // 1 : Cube Type
    else if (1 == SKYBOX_TYPE)
    {
        if(g_btexcube_0)
        {
            
            
            float3 vUV = normalize(_in.vPos); // 방향이 중요하기 때문에 길이는 필요없으므로 노말라이즈해서 길이를 1로 만들고 취함
           vOutColor = g_cube_0.Sample(g_sam_0, vUV); // 보간되서 받은 픽셀의 방향벡터를 가지고 샘플링

        }
    }
    return vOutColor;
}


#endif