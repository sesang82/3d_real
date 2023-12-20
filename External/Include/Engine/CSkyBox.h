#pragma once
#include "CRenderComponent.h"


enum class SKYBOX_TYPE
{
    SPHERE,
    CUBE,
};


// ����������Ʈ���� ����� �޽��� ������ ���������������
// ��ī�̹ڽ��� �̷������� ó������ �޽��� ������ Ŭ���� ���ο��� ������ ���·� �� ����
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
    void SetSkyBoxType(SKYBOX_TYPE _Type); // �� �κ��� ������ƮUI���ٰ� �����(����UI�� ���������)
    void SetSkyBoxTexture(Ptr<CTexture> _Tex);



};
