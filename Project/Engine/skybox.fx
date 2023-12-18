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
    
    // ������ ����pos�� �� ���⺤��
    float3 vPos : POSITION;
};

#define SKYBOX_TYPE g_int_0

VS_SKY_OUT VS_SkyBoxShader(VS_SKY_IN _in)
{
    VS_SKY_OUT output = (VS_SKY_OUT) 0.f;
    
    
    // �������� ���� ���� �̷�� �������� �佺���̽��� �̵��Ȱɷ� �����ϰ� ���̴��� �ۼ��� ���̴�. (_in.vPos)
    // ���� �츮�� ������� ������ ���̴�. �Ȱ����ָ� ������ ���� ���� �Ͼ��.
    // �佺���̽����� ī�޶� ������ ���� ��, z���� ������ �����ε� �� z���� �ٶ󺸰� �ִ� ���� �ٷ� ���� �� �κ��̱� �����̶�
    // ī�޶� �ƹ��� ȸ���� �ص� �� �κи� ���̰� �ȴ�.
    // ī�޶��� ȸ���� ���� ��� ���� �� ���� �� �ֵ��� �ϱ� ���ؼ��� ������� ���ϴ� ���̴�. 
    // �� ������� ���� ��, �츮�� 'ȸ��'�� ����Ǳ� ���ϴ� ���̹Ƿ� w���� �̵��� ������ ���� �ʵ��� 0���� �ݵ�� ����Ѵ�.
    float4 vViewPos = mul(float4(_in.vPos, 0.f), g_matView); 
    float4 vProjPos = mul(vViewPos, g_matProj); 
    
    // z�ڸ��� w�� �־������ Pz.Vz���� ���� Vz�� �Ǿ������. �� ���·� �����Ͷ��������� �Ѱ��ָ�
    // w�� ���� ������ �� z�ڸ��� 1�� �ǹ����ٺ��� ��ġ ��ī�̹ڽ��� far��ġ�� �ִ� ��ó�� �ָ� �Ÿ��� �ΰ� �� �� �ִ� ���̴�.
    // x, y ��ǥ�� ndc��ǥ�迡 �״�� �����ؼ� �ش� ��ġ�� ���̰Դ� �ϰ� z���� �ִ밪�� �༭ 
    // ��� �ָ��� ���� �ִ� �Ͱ� ���� �������� �� �� �ִ� ���̴�. 
    vProjPos.z = vProjPos.w;
    
    
    output.vPosition = vProjPos;
    output.vUV = _in.vUV;
    output.vPos = _in.vPos; // �̰͵��� �ȼ����̴��� �Է����� ���� �� �ȼ����� �����޾ư��� �鸶�� ������ ���͹����� ���� �ɰ�
    
    return output;
}

float4 PS_SkyBoxShader(VS_SKY_OUT _in) : SV_Target // �ش� �ø�ƽ�� ����ϸ� �̰� �����Ͷ������� ������ ����.
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
            
            
            float3 vUV = normalize(_in.vPos); // ������ �߿��ϱ� ������ ���̴� �ʿ�����Ƿ� �븻�������ؼ� ���̸� 1�� ����� ����
           vOutColor = g_cube_0.Sample(g_sam_0, vUV); // �����Ǽ� ���� �ȼ��� ���⺤�͸� ������ ���ø�

        }
    }
    return vOutColor;
}


#endif