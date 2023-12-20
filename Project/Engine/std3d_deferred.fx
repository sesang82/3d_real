#ifndef _STD3D_DEFFERED
#define _STD3D_DEFERRED

#include "value.fx"
#include "func.fx"

struct VS_IN
{
    float3 vPos : POSITION;
    float2 vUV : TEXCOORD;
    
    float3 vNormal : NORMAL;
    float3 vTangent : TANGENT;
    float3 vBinormal : BINORMAL;
    
};

struct VS_OUT
{
    float4 vPosition : SV_Position; // SV가 붙으면 레스터라이저가 해당 값을 갖다 씀
    float2 vUV : TEXCOORD;
    
    float3 vViewPos : POSITION;
    
    float3 vViewNormal : NORMAL;
    float3 vViewTangent : TANGENT;
    float3 vViewBinormal : BINORMAL;
    
};


VS_OUT VS_Std3D_Deferred(VS_IN _in)
{
    VS_OUT output = (VS_OUT) 0.f;
    
    output.vViewPos = normalize(mul(float4(_in.vPos, 1.f), g_matWV));
    output.vViewTangent = normalize(mul(float4(_in.vTangent, 0.f), g_matWV)).xyz;
    output.vViewBinormal = normalize(mul(float4(_in.vBinormal, 0.f), g_matWV)).xyz;
    
    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);
    output.vUV = _in.vUV;
    
    return output;
}


// ==== PS 단계

// MRT 세트 유형 중 디퍼드 유형은 렌더타겟이 4개이므로 아래처럼 함 (다른 쉐이더 보면 이 부분이 다름)
struct PS_OUT
{
    float4 vDiffuse : SV_Target0;
    float4 vNormal : SV_Target1;
    float4 vPoistion : SV_Target2;
    float4 vData : SV_Target3;
};


PS_OUT PS_Std3D_Deferred(VS_OUT _in)
{
    PS_OUT output = (PS_OUT) 0.f;
    
    output.vDiffuse = float4(1.f, 0.f, 1.f, 1.f);
    
    float3 vViewNormal = _in.vViewNormal;
    
    if(g_btex_0)
    {
        output.vDiffuse = g_tex_0.Sample(g_sam_0, _in.vUV);
        output.vDiffuse.a = 1.f; // 아임구이에서 알파값 0이면 미리보기에 안뜨고 투명처리 되서 1로 줌        
    }
    
    if (g_btex_1)
    {
        float3 vNormal = g_tex_1.Sample(g_sam_0, _in.vUV).xyz;
        
         // 0 ~ 1 범위의 값을 -1 ~ 1 로 확장  
        vNormal = vNormal * 2.f - 1.f;
        
        float3x3 vRotateMat =
        {
            _in.vViewTangent,
            -_in.vViewBinormal, // 현재 쓰는 텍스처가 오픈지엘 좌표계라 -붙인거. dx좌표게면 - 떼기
            _in.vViewNormal    
        };
        
        vViewNormal = normalize(mul(vNormal, vRotateMat));
                
    }
    
    output.vNormal = float4(vViewNormal, 1.f);
    output.vPoistion = float4(_in.vViewPos, 1.f);
    output.vData = float4(0.f, 0.f, 0.f, 1.f);
    
    return output;
       
}





#endif
