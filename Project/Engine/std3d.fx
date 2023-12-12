#ifndef _STD3D
#define _STD3D

#include "value.fx"
#include "func.fx"

// ���� �� �������� �� �ο�
static float3 g_vLightPos = float3(0.f, 0.f, 0.f);  // ���� �󿡼� ���� ��ġ�� �������� ���� 
static float3 g_vLightDir = float3(1.f, -1.f, 1.f); // ���� ���� 

static float3 g_vLightColor = float3(1.f, 1.f, 1.f);
static float3 g_vLightSpec = float3(0.3f, 0.3f, 0.3f);
// ȯ�汤 (����Ʈ���̽� ����� ���� ������ �Ʒ�ó�� �⺻���� ȯ�汤 ��ġ�� �׳� �ο��Ѵ�)
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
    
   // float fLightPow : FOG; // fog : float�ϳ��� �ѱ� �� ���� �ø�ƽ�̴�.
    float3 vWorldNormal : NORMAL;
};


VS_OUT VS_Std3D(VS_IN _in)
{
    VS_OUT output = (VS_OUT) 0.f;
    
    
    // ���� ���� normal ������ ����� �̵����Ѽ� ���� ���� �븻 ���� ������ ���Ѵ�. 
    
    /* ���ý����̽� �󿡼� ������ �־�� �븻 ������ ȸ���� �ƿ� ���ٴ� �����Ͽ� �����Ƿ� �Ű��� ���� �븻 ����
     ȸ���� �ƿ� ������� ���� ���´�. �׷��� ���� �� ��ġ�� �� ��ü�� ȸ���� ���·� ��ġ�� ���� �ִ�. ������ ȸ�� ����� ���ؼ���
     ���� ���� �븻 ������ ���忡 �̵����Ѿ��Ѵ�. ������Ŀ� ȸ�� ���� �ֱ� ����.
    
     ������Ŀ��� �̵��� ũ�� ���� ���� �ִ�. �츮�� ȸ������ �ʿ�� �ϹǷ� �̵��� ũ��� ����ް� �ؼ� �ȵȴ�. 
    ������ �Ʒ� �븻 ���� w���� 0���� Ȯ��. ũ�⵵ �þ ������ �� �����Ƿ� ���̸� 1�� �������ϱ� ���� normalize���ش� */
    output.vWorldNormal = normalize(mul(float4(_in.vNormal, 0.f), g_matWorld)).xyz;
    
    
    // ��ü�� ��ġ���� �̵� ���� ����Ǿ��ϹǷ� w���� 1�� ���� 
    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);    
    output.vUV = _in.vUV;
    
    // �ȼ����̴����� �Ѱ��༭ �� �ȼ����� ������ ���� ���⸦ �����ؼ� �޾ư��Բ� ���ֱ� ���� �Ѱ��ش�.
   // output.fLightPow = fLightPow;    
    
    return output;
}


// �ȼ� ������ �� �� ������ �� ������ �Ѵ�.
float4 PS_Std3D(VS_OUT _in) : SV_Target
{
    float4 vOutColor = (float4) 0.f;
    
    vOutColor = float4(0.5f, 0.5f, 0.5f, 1.f);
    
        // ����󿡼��� ������ ����
    g_vLightDir = normalize(g_vLightDir);
    
        
   // -- ������ ������ ���� ���Ⱑ ������������� ���� ����Ѵ�.
    // ���̸� 1�� ������� ������ ������� ���� ���� �븻 ���͸� �����Ѵ�. 
    // �̷� ����� '����Ʈ �ڻ��� ��Ģ'�̶�� �Ѵ�. 
    // ���� ����� ���� �ȹ޴´� �ϴ��� ������ ������ �θ� �ȵȴ�. �ڽ��� �׷����� ���ϸ� ������ ������ ���� ���Ƶ��̴� ���±� ����.
    // ������ ���� ����� �ּ� 0���� �����ؾ��Ѵ�. �̷��� ������ ������ �ʰ� 0~1 ������ ���� �����ϰ����ִ� ������ �ϴ°� saturate��.
    float fLightPow = saturate(dot(_in.vWorldNormal, -g_vLightDir));
    
     // �����Ǿ� ���� ���� ���Ⱚ�� ��� ����� �����ش�.
    // ȯ�汤 ���� ��� ����� ��췯���ߵǱ� ������ �����ش�.
    vOutColor.xyz = (vOutColor.xyz * fLightPow) + (vOutColor.xyz * g_vLightAmb);
    
    return vOutColor;
}



#endif