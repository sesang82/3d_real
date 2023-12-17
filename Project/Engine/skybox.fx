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
};


VS_SKY_OUT VS_SkyBoxShader(VS_SKY_IN _in)
{
    VS_SKY_OUT output = (VS_SKY_OUT) 0.f;
    
    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);
    output.vUV = _in.vUV;
    
    return output;
}

float4 PS_SkyBoxShader(VS_SKY_OUT _in) : SV_Target // 해당 시멘틱을 사용하면 이걸 레스터라이저가 가져다 쓴다.
{
    float4 vOutColor = (float4) 0.f;
    
    if(g_btex_0)
    {
        vOutColor = g_tex_0.Sample(g_sam_0, _in.vUV);
    }
    
    return vOutColor;
}


#endif