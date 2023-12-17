#ifndef _FUNC
#define _FUNC

#include "value.fx"

void CalcLight2D(float3 _vWorldPos, inout tLightColor _Light)
{       
    for (int i = 0; i < g_Light2DCount; ++i)
    {
        if (g_Light2DBuffer[i].LightType == 0)
        {
            _Light.vDiffuse.rgb += g_Light2DBuffer[i].Color.vDiffuse.rgb;
            _Light.vAmbient.rgb += g_Light2DBuffer[i].Color.vAmbient.rgb;
        }
        else if (g_Light2DBuffer[i].LightType == 1)
        {
            float3 vLightWorldPos = float3(g_Light2DBuffer[i].vWorldPos.xy, 0.f);
            float3 vWorldPos = float3(_vWorldPos.xy, 0.f);

            float fDistance = abs(distance(vWorldPos, vLightWorldPos));
            float fPow = saturate(1.f - (fDistance / g_Light2DBuffer[i].Radius));
        
            _Light.vDiffuse.rgb += g_Light2DBuffer[i].Color.vDiffuse.rgb * fPow;
        }
        else if (g_Light2DBuffer[i].LightType == 2)
        {
            
        }
    }
}

void CalcLight2D(float3 _vWorldPos, float3 _vWorldDir, inout tLightColor _Light)
{
    for (int i = 0; i < g_Light2DCount; ++i)
    {
        if (g_Light2DBuffer[i].LightType == 0)
        {
            float fDiffusePow = saturate(dot(-g_Light2DBuffer[i].vWorldDir.xyz, _vWorldDir));
            _Light.vDiffuse.rgb += g_Light2DBuffer[i].Color.vDiffuse.rgb * fDiffusePow;                        
            _Light.vAmbient.rgb += g_Light2DBuffer[i].Color.vAmbient.rgb;
        }
        else if (g_Light2DBuffer[i].LightType == 1)
        {
            float3 vLightWorldPos = float3(g_Light2DBuffer[i].vWorldPos.xy, 0.f);
            float3 vWorldPos = float3(_vWorldPos.xy, 0.f);

            // ���� �߽ɿ��� ��ü�� ���ϴ� ����
            float3 vLight = normalize(vWorldPos - vLightWorldPos);
            float fDiffusePow = saturate(dot(-vLight, _vWorldDir));
            
            float fDistance = abs(distance(vWorldPos, vLightWorldPos));
            float fDistPow = saturate(1.f - (fDistance / g_Light2DBuffer[i].Radius));
        
            _Light.vDiffuse.rgb += g_Light2DBuffer[i].Color.vDiffuse.rgb * fDiffusePow * fDistPow;
        }
        else if (g_Light2DBuffer[i].LightType == 2)
        {
            
        }
    }
}

// �佺���̽��� �������� ���� ���� ����
// _vViewPos : ȣ��� �ȼ��� �佺���̽����� ������ ��ġ
// ������ ������ ���� �ȼ� ������ �븻 ��
// (�̰� �˾ƾ� _vViewPos�� _vViewNormal�� ������ �����ؼ� ����ư �ڻ��� ��Ģ�� ���� �佺���̽����� ���� ���⸦ �� �� �ֱ� ����)
// _LightIdx : ������ ����� ������ �ε��������� �� �ε����� �ִ��� 
// tLightColor : ������ �ϰ� �� ���� ���� ������ ��Ƴ� �뵵. inout�� �ٿ��� ������ tLightColor�� ����ִ� ����
// �Է����ε� �޾ƿ���, �޾ƿ� �� �����ϸ� �� ���� �������� ������ �ȴ�(���۷��� ����)
void CalcLight3D(float3 _vViewPos, float3 _vViewNormal, int _LightIdx, inout tLightColor _Light, inout float _SpecPow)
{
    
   // ����󿡼��� ������ ����
   // g_vLightDir = normalize(g_vLightDir);
    
    
    tLightInfo LightInfo = g_Light3DBuffer[_LightIdx];
    
    float fLightPow = 0.f;
    float fSpecPow = 0.f;
    float3 vViewLightDir = (float3) 0.f;
        
    // DirLight �� ���
    if (0 == LightInfo.LightType)
    {
        
        
    // == View�󿡼��� ������ ����
    // 0���� �δ� ������ �����̱� ������ ����� ũ�⳪ �̵��� ������ ���� �ʱ� ���ؼ���.
    // g_matView�� �����ִ� ������ g_vLightDir�� �ʱⰪ�� ���带 �������� �ױ� ������ �̰��� �佺���̽��� ������ ����
    // �� �տ� �ٽ� normalize�� �ϴ� ������ g_matView �ȿ��� �̵� ũ�� ������ �ֱ� ������ Ȥ�ø��� ���� ������ ��Ȯ�ϰ� �����ϱ� ���ؼ� �ص�
    // vWorldDir�� 16����Ʈ ������ �����ֱ� ���� flaot4�� �ص� ��Ȳ. w���� �ʿ������  xyz��� ��ü������ ����ص�
    // ******* �ٵ� �� �ε���0������ �� �ó����� �ñ���. �ϴ� �츮�� ���� ������ 1�����̶� �׷�����.... �ƴϸ� ��
    // directional ������ '���� ����'�� �ʿ��ϱ� ������ worldPos�� �Ⱦ��� worldDir�� �Ʒ��� ���� �ִ� ���̴�
        vViewLightDir = normalize(mul(float4(normalize(LightInfo.vWorldDir.xyz), 0.f), g_matView)).xyz;
        
            // ����󿡼��� ������ ����
   // g_vLightDir = normalize(g_vLightDir);
    
     
   // == ������ ������ ���� ���Ⱑ ������������� ���� ����Ѵ�.
    // ���̸� 1�� ������� ������ ������� ���� ���� �븻 ���͸� �����Ѵ�. 
    // �̷� ����� '����Ʈ �ڻ��� ��Ģ'�̶�� �Ѵ�. 
    // ���� ����� ���� �ȹ޴´� �ϴ��� ������ ������ �θ� �ȵȴ�. �ڽ��� �׷����� ���ϸ� ������ ������ ���� ���Ƶ��̴� ���±� ����.
    // ������ ���� ����� �ּ� 0���� �����ؾ��Ѵ�. �̷��� ������ ������ �ʰ� 0~1 ������ ���� �����ϰ����ִ� ������ �ϴ°� saturate��.  
   // float fLightPow = saturate(dot(_in.vViewNormal, -g_vLightDir)); // ���� �����̿��� ���� ���� ���� ���ϴ� ���
    
    // view �����̽������� �븻���Ϳ� ������ ������ �����Ͽ� ���� ���⸦ ����(����Ʈ �ڻ��� ��Ģ)   
        fLightPow = saturate(dot(_vViewNormal, -vViewLightDir));
        
     // ���� �󿡼��� �ݻ籤�� ���� ���� ���ϴ� ����
    //float3 vWorldReflect = g_vLightDir + 2.f * (dot(-g_vLightDir, _in.vWorldNormal)) * _in.vWorldNormal;
    
    // �佺���̽��󿡼��� �ݻ籤�� ���e ���� ���ϴ� ���� (�佺���̽����� �븻�� ������ ���Ѵ�)
    // ������ �ؼ� ���� ���� �װ� 2��� Ű���� ����������� �ݻ簢�� ���Ѵ�. 
    // ** ���� �ݻ籤�� ���ϴ� �Լ��� hlsl�� reflect��� �ִµ� �������� �ݻ籤 ���ϴ� ���� ����� ���� �� �ִ� ���� �Ϻη� �Ʒ��� �ߴ���             
        float3 vViewReflect = normalize(vViewLightDir + 2.f * (dot(-vViewLightDir, _vViewNormal)) * _vViewNormal);        
         // float3 vViewReflect = normalize(reflect(vViewLightDir, _vViewNormal)); (reflect �Լ� Ȱ���ϸ� ������ �Ƚᵵ ��)
    
    // �佺���̽����� �ȼ��� ��ǥ�� �� ī�޶� ��ü�� ���ϴ� ���⺤�Ϳ͵� ����. (�佺���̽��� ������ ī�޶� �ֱ� ����)
    // �����̱� ������ normalize�� �Ѵ�. ��ü�� �佺���̽��� ī�޶� �ٶ󺸴� ����� �������� ��ü�� �ٶ󺸴� ������ ������ �ƴ�����
    // �ݻ籤�� ī�޶� �������� Ƣ�������� �Ǻ��� �� �ִ�. (���ٸ� �� �� �� �༮�� ����� ������ �Ͽ� �ڽ��� ��Ÿ(����(�� ���� ��,
    // �ش� ������ ���� ���� ���⸦ �ڽ��� �׷����� �����Ͽ� �� �� �ִ�.
        float3 vEye = normalize(_vViewPos);
        
        
     // �ݻ籤�� ���� ���ϱ�
     // �ݻ籤�� �ٶ󺸴� ������ ���� �佺���̽����� ���� ���⸦ ���Ѵ�. 
     // �� ���������� ������ �ϳĸ�, �׷��� ���ϸ� ������ �ִ�ġ 180����� ������ ������ �Ǳ� ����
    // saturate�� �����ָ� �ݻ籤�� ���ϰ� �پ ��û �������.
        fSpecPow = saturate(dot(vViewReflect, -vEye));
        
        
    // �ڽ��α׷����� ����� ������ �ֱ� ���� ������ (�����ϸ� ���� ���� ������)
        fSpecPow = pow(fSpecPow, 20); // 20���� ���شٴ� �ǹ��� �ڵ��. 
    }
    
    // 2. Point Light�� ���
    else if (1 == LightInfo.LightType)
    {
         // �Ÿ��� ���� ���� ����
        // ���� ���Ⱑ �Ÿ��� ���� ����Ǵ� ȿ���� �ֱ� ���� ����.
        // �̰� ���� ������ point light�� ������ �ݰ� �����ε� ���� ������ �� 
        float fDistPow = 1.f;
        
        // == ViewSpace������ ������ ��ġ
        // ��ġ�� �̵����� ������ �޾ƾ��ϴ� 1�� Ȯ�� 
        float3 vLightViewPos = mul(float4(LightInfo.vWorldPos.xyz, 1.f), g_matView).xyz;
        
        // �������� ȣ��Ǵ� �ȼ��� ���� ���� ���� ���ϱ�(�����̹Ƿ� normalize�ؼ� ���̸� 1�� ������)
        vViewLightDir = normalize(_vViewPos - vLightViewPos);
        
        
        // point light�κ��� �ȼ� ���� �Ÿ� üũ 
        float fDist = distance(_vViewPos, vLightViewPos); // �� �� ���̿� �Ÿ����� ����        
        
        
        // range�� �ִ�ġ�� ����������� ���� ���Ⱑ �������� ȿ���� �ֱ� ���� �Ÿ��� ���� ������ �����ش�.    
       
        // Q. 1�� ���� ����?
        // �ݰ��� 1õ�ε� fDist�� 1õ�̶�� ���� ���� �����ߴٴ� �ǹ̰� �ȴ�. �׷��� �� ���� ������ ������
        // ���� ���Ⱑ ������ (�ִ밪 1�� ������ ����). ���� �ݰ��� 1õ�ε�, dist�� 200 ������ ��ġ�� �ִٸ�
        // 0.2�� ���´�. �׷��� dist�� �������� ������ ���� ���Ⱑ ����� ���̴�. ������ 1���� ���༭
        // 0.8�� ���� 80���� ���� ������ �� �ֵ��� �ٲ��ذŴ�.
        // ���� ������ ������ �� �����ϱ� ���ؼ��� saturate�� ���ش�.
        fDistPow = saturate(1.f - (fDist / LightInfo.Radius));
               
        
         // viewSpace������ �븻���Ϳ� ������ ������ ���� (����Ʈ �ڻ��� ��Ģ)
        fLightPow = saturate(dot(_vViewNormal, -vViewLightDir)) * fDistPow;
        
        // �ݻ籤
        float3 vViewReflect = normalize(vViewLightDir + 2.f * (dot(-vViewLightDir, _vViewNormal)) * _vViewNormal);
        float3 vEye = normalize(_vViewPos);
        
        // �ݻ籤�� ���� ���ϱ�
        fSpecPow = saturate(dot(vViewReflect, -vEye));
        fSpecPow = pow(fSpecPow, 20) * fDistPow; // 20���� ���شٴ� �ǹ��� �ڵ��. 
    }
    
    // Spot Light �� ���
    else
    {
        // LightDir �� Angle ���� Ȱ���ؼ� SpotLight �����غ���
    }
  
    
    // ======= ���� ��� ���� 
    // ������ ���� ���⸸ �����ִ� �Լ��� ������ ��ü�� ���� �� ���ϰ� �����ϰ� ������ ���󿡸� ������ 
    _Light.vDiffuse += LightInfo.Color.vDiffuse * fLightPow; 
    _Light.vAmbient += LightInfo.Color.vAmbient;
    _SpecPow += fSpecPow; // ����  �ݻ籤�� ���� 
}

// ======
// Random
// ======
static float GaussianFilter[5][5] =
{
    0.003f,  0.0133f, 0.0219f, 0.0133f, 0.003f,
    0.0133f, 0.0596f, 0.0983f, 0.0596f, 0.0133f,
    0.0219f, 0.0983f, 0.1621f, 0.0983f, 0.0219f,
    0.0133f, 0.0596f, 0.0983f, 0.0596f, 0.0133f,
    0.003f,  0.0133f, 0.0219f, 0.0133f, 0.003f,
};

void GaussianSample(in Texture2D _NoiseTex, float2 _vResolution, float _NomalizedThreadID, out float3 _vOut)
{
    float2 vUV = float2(_NomalizedThreadID, 0.5f);       
    
    vUV.x += g_AccTime * 0.5f;
    
    // sin �׷����� �ؽ����� ���ø� ��ġ UV �� ���
    vUV.y -= (sin((_NomalizedThreadID - (g_AccTime/*�׷��� ���� �̵� �ӵ�*/)) * 2.f * 3.1415926535f * 10.f/*�ݺ��ֱ�*/) / 2.f);
    
    if( 1.f < vUV.x)
        vUV.x = frac(vUV.x);
    else if(vUV.x < 0.f)
        vUV.x = 1.f + frac(vUV.x);
    
    if( 1.f < vUV.y)
        vUV.y = frac(vUV.y);
    else if (vUV.y < 0.f)
        vUV.y = 1.f + frac(vUV.y);
        
    int2 pixel = vUV * _vResolution;           
    int2 offset = int2(-2, -2);
    float3 vOut = (float3) 0.f;    
    
    for (int i = 0; i < 5; ++i)
    {
        for (int j = 0; j < 5; ++j)
        {            
            vOut += _NoiseTex[pixel + offset + int2(j, i)] * GaussianFilter[i][j];
        }
    }        
    
    _vOut = vOut;    
}

#endif
