#pragma once
#include "CEntity.h"
#include "CTexture.h"
#include "ptr.h"


// Multi Render Target
// ����Ÿ�ٸ��� ��� �뵵�� �ٸ��� �����Ͽ�, ���� ����ϰ� ���߿� ���������� ȭ�鿡 present�Ǵ� ����ü�� ������ mrt���ٰ�
// �׸��� �ϳ��� ��ĥ ���̴�.
class CMRT :
    public CEntity
{
public:
    CMRT();
    ~CMRT();


public:
    CLONE_DISABLE(CMRT);

private:
    Ptr<CTexture>   m_arrRT[8]; // ����̽����� ����Ÿ���� �ִ� 8�������� ���� �� �ִ�.
    UINT            m_RTCount;
    Ptr<CTexture>   m_DSTex;

    Vec4            m_ClearColor[8];
    D3D11_VIEWPORT  m_Viewport;

public:
    void Create(Ptr<CTexture>* _arrRTTex, UINT _RTCount, Ptr<CTexture> _DSTex);
    void SetClearColor(Vec4 _ClearColor, UINT _RTIdx) { m_ClearColor[_RTIdx] = _ClearColor; }
    void ClearTarget();
    void OMSet();



};

