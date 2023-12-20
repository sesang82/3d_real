#pragma once
#include "CRenderComponent.h"


class CDecal :
    public CRenderComponent
{
public:
    CDecal();
    ~CDecal();

    CLONE(CDecal);

public:
    virtual void finaltick() override;
    virtual void render() override;


private:
    Ptr<CTexture>   m_DecalTex;


};

