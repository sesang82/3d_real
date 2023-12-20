#pragma once
#include "CEntity.h"
#include "CTexture.h"
#include "ptr.h"


// Multi Render Target
// 렌더타겟마다 출력 용도를 다르게 지정하여, 각각 출력하고 나중에 최종적으로 화면에 present되는 스왑체인 유형의 mrt에다가
// 그림을 하나로 합칠 것이다.
class CMRT :
    public CEntity
{
public:
    CMRT();
    ~CMRT();


public:
    CLONE_DISABLE(CMRT);

private:
    Ptr<CTexture>   m_arrRT[8]; // 디바이스에서 렌더타겟은 최대 8개까지도 만들 수 있다.
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

