#pragma once
#include "CRenderComponent.h"


enum class SKYBOX_TYPE
{
    SPHERE,
    CUBE,
};


// 렌더컴포넌트들은 사용할 메쉬와 재질을 선택해줘야하지만
// 스카이박스는 이례적으로 처음부터 메쉬와 재질을 클래스 내부에서 결정한 상태로 둘 것임
class CSkyBox :
    public CRenderComponent
{

public:
    CSkyBox();
    ~CSkyBox();

public:
    virtual void finaltick() override;
    virtual void render() override;


    CLONE(CSkyBox);

private:
    SKYBOX_TYPE     m_Type;
    Ptr<CTexture>   m_SkyBoxTex;

public:
    void SetSkyBoxType(SKYBOX_TYPE _Type); // 이 부분은 컴포넌트UI에다가 만들기(재질UI에 띄우지말고)
    void SetSkyBoxTexture(Ptr<CTexture> _Tex);



};

