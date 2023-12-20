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
    float4 vPosition : SV_Position; // SV�� ������ �����Ͷ������� �ش� ���� ���� ��
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


// ==== PS �ܰ�

// MRT ��Ʈ ���� �� ���۵� ������ ����Ÿ���� 4���̹Ƿ� �Ʒ�ó�� �� (�ٸ� ���̴� ���� �� �κ��� �ٸ�)
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
        output.vDiffuse.a = 1.f; // ���ӱ��̿��� ���İ� 0�̸� �̸����⿡ �ȶ߰� ����ó�� �Ǽ� 1�� ��        
    }
    
    if (g_btex_1)
    {
        float3 vNormal = g_tex_1.Sample(g_sam_0, _in.vUV).xyz;
        
         // 0 ~ 1 ������ ���� -1 ~ 1 �� Ȯ��  
        vNormal = vNormal * 2.f - 1.f;
        
        float3x3 vRotateMat =
        {
            _in.vViewTangent,
            -_in.vViewBinormal, // ���� ���� �ؽ�ó�� �������� ��ǥ��� -���ΰ�. dx��ǥ�Ը� - ����
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
