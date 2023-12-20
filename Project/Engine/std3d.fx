#ifndef _STD3D
#define _STD3D

#include "value.fx"
#include "func.fx"



// === ���� ������ �����Ŵ������� �����ְ� �ֱ� ������ �Ʒ� ���� ���� �� ����� (�ӽð��̾��� ����) 
//// ���� �� �������� �� �ο�
//static float3 g_vLightPos = float3(0.f, 0.f, 0.f);  // ���� �󿡼� ���� ��ġ�� �������� ���� 
//static float3 g_vLightDir = float3(1.f, -1.f, 1.f); // ���� ���� 

//static float3 g_vLightColor = float3(1.f, 1.f, 1.f);
////static float g_vLightSpec = float3(0.3f, 0.3f, 0.3f);
//static float g_fLightSpecCoeff = 0.3f; // �ִ� �ݻ籤 ����

// ȯ�汤 (����Ʈ���̽� ����� ���� ������ �Ʒ�ó�� �⺻���� ȯ�汤 ��ġ�� �׳� �ο��Ѵ�)
//static float3 g_vLightAmb = float3(0.15f, 0.15f, 0.15f); 





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
    float3 vViewBinormal: BINORMAL;    
};


// ===========================
// Std3DShader
//
// Param

// ���߿� �ݻ� ����� 0�� ����������� �ݻ�� ȯ���� �����ϴ� ���� ǰ���� ���Ͻ�Ű�� �ͱ��� �� ����.
#define SPEC_COEFF g_float_0 // �ݻ� ���

// ȯ�� ������ ������ ť���ؽ�ó ����
#define IS_SKYBOX_ENV   g_btexcube_0
#define SKYBOX_ENV_TEX  g_cube_0


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
    
    
    // �Ϲ� �ؽ�ó�� ���ε� �Ȱ� �ִٸ�
    if(g_btex_0)
    {
        vOutColor = g_tex_0.Sample(g_sam_0, _in.vUV);
    }
    
    
    // == ���࿡ �븻 �ؽ�ó�� ���ε��ߴٸ�
    // ���⿡ ���ε��� �� �ִٸ� �ش� �ؽ�ó�� ���� �븻�� vViewNormal�� �� ���̴�.
    if (g_btex_1)
    {
        float3 vNormal = g_tex_1.Sample(g_sam_0, _in.vUV).xyz;        
      
        
        // 0 ~ 1 ������ ���� -1 ~ 1 �� Ȯ��        
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
        }; // ����ϴ� �븻 �ؽ�ó�� �������� ��ǥ�踦 ���ٸ� ���̳븻�� -�� ���̰�, �޼���ǥ��dx��ǥ�踦 ���ٸ� +�� ������ �ϴ°� �����
        
        vViewNormal = normalize(mul(vNormal, vRotateMat)); // ���� ���̱� ������ Ȯ���ϰ� �븻��������� ����
    }
    
    tLightColor lightcolor = (tLightColor) 0.f;
    float fSpecPow = 0.f;
    
        // ������ ���� ���� ������ ���� ���� ������� �� �ֵ��� �ص� 
    for (int i = 0; i < g_Light3DCount; ++i)
    {
                
    // == ������ ���⸦ ���Ѵ�.
    // ���� 3D������ 1���� �־���� ������ �ϴ� �ε����� 0���� �ص� 
        CalcLight3D(_in.vViewPos, vViewNormal, i, lightcolor, fSpecPow);
    }
     
    
    
             //=== �ݻ籤�� ������ ��
    //�����Ǿ� ���� ���� ���Ⱚ�� ��� ����� �����ش�.
    // ȯ�汤 ���� ��� ����� ��췯���ߵǱ� ������ �����ش�.
   // vOutColor.xyz = (vOutColor.xyz * fLightPow) + (vOutColor.xyz * g_vLightAmb);
    
    
    // === �ݻ籤�� �ִ� ����
    // CalcLight3D���� ������ ���� �޾ƴٰ� ���� ����. 
    // �ݻ籤���� ���� ���⿡�ٰ� ��ü�� ���� �������� ����. ƨ�ܳ� ���̱� ������ ������ ������ ���� �������ߵǱ� ����
    // �� ��ü���� ������ �ֱ� ������ g_vLightcolor��� �� ������ ����������.    
    // ���⼭�� vOutColor�� ��ü�� ����    
    vOutColor.xyz = vOutColor.xyz * lightcolor.vDiffuse.xyz // g_vLightColor�� �� ���ؾ��ϳĸ� ��ü�� �������̸� ������ �Ͼ���̾ �Ӱ� ���������ϱ� ����
                    + vOutColor.xyz * lightcolor.vAmbient.xyz
                    + saturate(g_Light3DBuffer[0].Color.vDiffuse.xyz) * 0.3f * fSpecPow * SPEC_COEFF;
    
    
    // ť�� �޽��̰�, ȯ�� ������ �Ϸ��� �������� ���� ��
    if (IS_SKYBOX_ENV)
    {
        // ť�� �޽��̹Ƿ� ���Ⱚ�� �̿��Ͽ� ���ø��ϴ� ����� �̿��Ѵ�.
        float3 vEye = normalize(_in.vViewPos); // ���Ⱚ�� ���� ���̹Ƿ� �븻������. ���⼭�� eye�� �佺���̽����� ������ �ִ� ī�޶�
        float3 vEyeReflect = normalize(reflect(vEye, vViewNormal)); // ���� �ݻ籤�� ���ϰ� ���⸸ ���Ѵ�. vViewNormal�� ������Ʈ�� ȣ��� �ȼ��� �븻 ���� 
        
        // == ���� ���� ī�޶� ������Ʈ�� �Ĵٺ� �������� ƨ�ܳ����� �ݻ籤�� ���Ѵ� 
        // ������ �佺���̽� �������� �׳� ����ߴµ� �׷��ٺ��� �佺���̽��� ī�޶��� z���� ���鸸 ���� �־
        // ������ ī�޶� ȸ���� �� �ݻ�Ǵ� �׸��� �޶������ϴµ� �Ȱ��Ƽ� ���� ������� ���ؿͼ� ���� ������ ������ ���� �� ��
        vEyeReflect = normalize(mul(float4(vEyeReflect, 0.f), g_matViewInv));
        
        // ���� ����� ���� ���� ���ø��Ǵ� ǰ���� ���ϵǾ���ϴµ� �װ� ���� �ȵǼ� ���߿� ���ֽŴ� ��.
        // == ���ø�2�� �Ѱ� Ȥ�ó� �ٸ� ���÷����� �׷��� �ɱ� �; ���� �߰��ؼ� �غôµ� �ȵ�
        vOutColor *= SKYBOX_ENV_TEX.Sample(g_sam_2, vEyeReflect);

    }
    
        return vOutColor;
}



#endif