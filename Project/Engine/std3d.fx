#ifndef _STD3D
#define _STD3D

#include "value.fx"
#include "func.fx"

// ���� �� �������� �� �ο�
static float3 g_vLightPos = float3(0.f, 0.f, 0.f);  // ���� �󿡼� ���� ��ġ�� �������� ���� 
static float3 g_vLightDir = float3(1.f, -1.f, 1.f); // ���� ���� 

static float3 g_vLightColor = float3(1.f, 1.f, 1.f);
//static float g_vLightSpec = float3(0.3f, 0.3f, 0.3f);
static float g_fLightSpecCoeff = 0.3f; // �ִ� �ݻ籤 ����


// ȯ�汤 (����Ʈ���̽� ����� ���� ������ �Ʒ�ó�� �⺻���� ȯ�汤 ��ġ�� �׳� �ο��Ѵ�)
static float3 g_vLightAmb = float3(0.15f, 0.15f, 0.15f); 

struct VS_IN
{
    float3 vPos : POSITION;
    float2 vUV : TEXCOORD;
    
    // ���� �ȿ� �ִ� ���� ������ ����´�. 
    float3 vNormal : NORMAL;
    float3 vTangent : TANGENT;
    float3 vBinormal : BINORMAL;
};

struct VS_OUT
{
    float4 vPosition : SV_Position;
    float2 vUV : TEXCOORD;   
    
   // float fLightPow : FOG; // fog : float�ϳ��� �ѱ� �� ���� �ø�ƽ�̴�.
    
    // �� �����̽� �������� ������ ������ ���� �Ʒ�ó�� �̸� ������
    float3 vViewPos : POSITION; 
    
    float3 vViewNormal : NORMAL;
    float3 vViewTangent : TANGENT;
    float3 vViewBinormal : BINORMAL;
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
    //output.vViewNormal = normalize(mul(float4(_in.vNormal, 0.f), g_matWorld)).xyz;
    
    
    // �Է����� ���� �������ٰ� �佺���̽��� ���Ͽ�, �佺���̽����� ������ ��ġ�� ���س���.
    // ��ǥ�� ���ϴ°ű� ������ w���� 1�� �д�. �� ���� �ȼ����̴��� �Ѿ�� �Ǹ� ������ ����������� �ȼ����� ��ǥ�� �˾Ƴ� �� �ְ� �ȴ�.
    output.vViewPos = mul(float4(_in.vPos, 1.f), g_matWV);
    
    // === ��� ������ �� �����̽��� �������� �д�. ��, ī�޶� �������� ���� ��Ȳ. ���� ī�޶� ���� ������ z���� ��
    output.vViewNormal = normalize(mul(float4(_in.vNormal, 0.f), g_matWV)).xyz;
    output.vViewTangent = normalize(mul(float4(_in.vTangent, 0.f), g_matWV)).xyz;
    output.vViewBinormal = normalize(mul(float4(_in.vBinormal, 0.f), g_matWV)).xyz;
     
    
    
    // ��ü�� ��ġ���� �̵� ���� ����Ǿ��ϹǷ� w���� 1�� ���� 
    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);    
    output.vUV = _in.vUV;
    
    // �ȼ����̴����� �Ѱ��༭ �� �ȼ����� ������ ���� ���⸦ �����ؼ� �޾ư��Բ� ���ֱ� ���� �Ѱ��ش�.
   // output.fLightPow = fLightPow;    
    
    return output;
}


// �ȼ� ������ �� �� ������ �� ������ �Ѵ�.
// �Է¿� ������ ���� ���� �� �����̽� ������ �븻 ������ ������ �ȴ�. 
float4 PS_Std3D(VS_OUT _in) : SV_Target
{
    float4 vOutColor = float4(0.5f, 0.5f, 0.5f, 1.f);
    
    // �Է����� ���� �佺���̽����� �븻�� �޾Ƶд�.
    float3 vViewNormal = _in.vViewNormal;
    
    if(g_btex_0)
    {
        vOutColor = g_tex_0.Sample(g_sam_0, _in.vUV);
    }
    
    
    // �ؽ�ó�� �븻 ���� �־��ִ� �뵵
    // ���⿡ ���ε��� �� �ִٸ� �ش� �ؽ�ó�� ���� �븻�� vViewNormal�� �� ���̴�.
    if (g_btex_1)
    {
        float3 vNormal = g_tex_1.Sample(g_sam_0, _in.vUV).xyz;
        
        // 0~1������ ���ø� �Ǵ� ���� ź��Ʈ �����̽� ��ǥ���� ������ -1 ~ 1�� Ȯ���ϱ� ���� 0~2�� Ȯ���� ��, ��ü�� -1�� ���� ��
        // �̷��� �� ������ ����Ǿ� �ִ� �����Ͱ� '���� ������'�̱� �����̴�.
        vNormal = vNormal * 2.f - 1.f;
        
        // �佺���̽� ������ �� �������� ���� �ͼ� ȸ�� ��� ����
        // �� ȸ���� �ϳĸ� �츮�� ǥ������ �ؽ�ó�� ���� ������ �������� ���ؼ���.
        // ��, �츮 �� ��ü�� ���� ������������ �̸� ���س��� ź��Ʈ�����̽��� ��ǥ���� �� ��鿡 � ȸ�� ����� ���ϸ�
        // ������ �� ���� ��ġ�ϰ� �� ���̴�. (x�� t, y�� N, z���� b). �̷��� ����� � ȸ������� ���ؼ� 
        // �����Ϸ��� ź��Ʈ�����̽� �࿡ �����ָ� �츮 ǥ�鿡 ȸ���� ���·� ������ ���� �� �ֱ� �����̴�.  
        // �ٵ� �츮�� ��ü�� ���� ������������ ��������� ���¶� �ᱹ �� � ȸ�� ����� t/n/b (1�� 3��)�̾����Ŵ�.
        // �׷��� �Ʒ�ó�� �Է����� ���� ���� �޾Ƶа�  
        float3x3 vRotateMat = 
        {
            _in.vViewTangent,
            -_in.vViewBinormal, // ������ ������ �ȵ���� �Ǵµ� �� �ؽ�ó�� ��ǥ�谡 �ݴ�� -�� ������(�������� ��ǥ��Ἥ)
            _in.vViewNormal
        };
        
        vViewNormal = mul(vNormal, vRotateMat);

    }
    
    
    
    // ����󿡼��� ������ ����
   // g_vLightDir = normalize(g_vLightDir);
    
    // View�󿡼��� ������ ����
    // 0���� �δ� ������ �����̱� ������ ����� ũ�⳪ �̵��� ������ ���� �ʱ� ���ؼ���.
    // g_matView�� �����ִ� ������ g_vLightDir�� �ʱⰪ�� ���带 �������� �ױ� ������ �̰��� �佺���̽��� ������ ����
    // �� �տ� �ٽ� normalize�� �ϴ� ������ g_matView �ȿ��� �̵� ũ�� ������ �ֱ� ������ Ȥ�ø��� ���� ������ ��Ȯ�ϰ� �����ϱ� ���ؼ� �ص�
    float3 vViewLightDir = normalize(mul(float4(normalize(g_vLightDir), 0.f), g_matView)).xyz;
        
    
    
   // -- ������ ������ ���� ���Ⱑ ������������� ���� ����Ѵ�.
    // ���̸� 1�� ������� ������ ������� ���� ���� �븻 ���͸� �����Ѵ�. 
    // �̷� ����� '����Ʈ �ڻ��� ��Ģ'�̶�� �Ѵ�. 
    // ���� ����� ���� �ȹ޴´� �ϴ��� ������ ������ �θ� �ȵȴ�. �ڽ��� �׷����� ���ϸ� ������ ������ ���� ���Ƶ��̴� ���±� ����.
    // ������ ���� ����� �ּ� 0���� �����ؾ��Ѵ�. �̷��� ������ ������ �ʰ� 0~1 ������ ���� �����ϰ����ִ� ������ �ϴ°� saturate��.  
   // float fLightPow = saturate(dot(_in.vViewNormal, -g_vLightDir)); // ���� �����̿��� ���� ���� ���� ���ϴ� ���
    
    // view �����̽������� �븻���Ϳ� ������� ������ �����Ͽ� ���� ���⸦ ����(����Ʈ �ڻ��� ��Ģ)
    float fLightPow = saturate(dot(vViewNormal, -vViewLightDir));
    
    // ���� �󿡼��� �ݻ籤�� ���� ���� ���ϴ� ����
    //float3 vWorldReflect = g_vLightDir + 2.f * (dot(-g_vLightDir, _in.vWorldNormal)) * _in.vWorldNormal;
    
    // �佺���̽��󿡼��� �ݻ籤�� ���e ���� ���ϴ� ���� (�佺���̽����� �븻�� ������ ���Ѵ�)
    // ������ �ؼ� ���� ���� �װ� 2��� Ű���� ����������� �ݻ簢�� ���Ѵ�. 
    // �̷��� �Ǹ� 
    float3 vViewReflect = normalize(vViewLightDir + 2.f * (dot(-vViewLightDir, vViewNormal)) * vViewNormal);
    
    // �佺���̽����� �ȼ��� ��ǥ�� �� ī�޶� ��ü�� ���ϴ� ���⺤�Ϳ͵� ����. (�佺���̽��� ������ ī�޶� �ֱ� ����)
    // �����̱� ������ normalize�� �Ѵ�. ��ü�� �佺���̽��� ī�޶� �ٶ󺸴� ����� �������� ��ü�� �ٶ󺸴� ������ ������ �ƴ�����
    // �ݻ籤�� ī�޶� �������� Ƣ�������� �Ǻ��� �� �ִ�. (���ٸ� �� �� �� �༮�� ����� ������ �Ͽ� �ڽ��� ��Ÿ(����(�� ���� ��,
    // �ش� ������ ���� ���� ���⸦ �ڽ��� �׷����� �����Ͽ� �� �� �ִ�.
    float3 vEye = normalize(_in.vViewPos);
    
    // �佺���̽����� ���� ���⸦ ���Ѵ�. �� ���������� ������ �ϳĸ�, �׷��� ���ϸ� ������ �ִ�ġ 180����� ������ ������ �Ǳ� ����
    // saturate�� �����ָ� �ݻ籤�� ���ϰ� �پ ��û �������
    float fSpecPow = saturate(dot(vViewReflect, -vEye));
    
    // �ڽ��α׷����� ����� ������ �ֱ� ���� ������ (�����ϸ� ���� ���� ������)
    fSpecPow = pow(fSpecPow, 20); // 20���� ���شٴ� �ǹ��� �ڵ��. 
      
    
     //=== �ݻ籤�� ������ ��
    //�����Ǿ� ���� ���� ���Ⱚ�� ��� ����� �����ش�.
    // ȯ�汤 ���� ��� ����� ��췯���ߵǱ� ������ �����ش�.
   // vOutColor.xyz = (vOutColor.xyz * fLightPow) + (vOutColor.xyz * g_vLightAmb);
    
    
    // === �ݻ籤�� �ִ� ����
    // �ݻ籤���� ���� ���⿡�ٰ� ��ü�� ���� �������� ����. ƨ�ܳ� ���̱� ������ ������ ������ ���� �������ߵǱ� ����
    // �� ��ü���� ������ �ֱ� ������ g_vLightcolor��� �� ������ ����������.    
    vOutColor.xyz = (vOutColor.xyz * g_vLightColor * fLightPow) // g_vLightColor�� �� ���ؾ��ϳĸ� ��ü�� �������̸� ������ �Ͼ���̾ �Ӱ� ���������ϱ� ����
                    + (vOutColor.xyz * g_vLightColor * g_vLightAmb)
                    + g_vLightColor * g_fLightSpecCoeff * fSpecPow;
   
    
    return vOutColor;
}



#endif