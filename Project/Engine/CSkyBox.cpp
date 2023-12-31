#include "pch.h"
#include "CSkyBox.h"
#include "CTransform.h"
#include "CResMgr.h"
#include "CMesh.h"
#include "CMaterial.h"

CSkyBox::CSkyBox()
	: CRenderComponent(COMPONENT_TYPE::SKYBOX)
	, m_Type(SKYBOX_TYPE::SPHERE)
{
	SetSkyBoxType(m_Type);
	SetMaterial(CResMgr::GetInst()->FindRes<CMaterial>(L"SkyBoxMtrl"));
}

CSkyBox::~CSkyBox()
{
}

void CSkyBox::finaltick()
{



}

void CSkyBox::render()
{
	if (nullptr == GetMesh() || nullptr == GetMaterial())
		return;

	// Transform 에 UpdateData 요청
	Transform()->UpdateData();

	// Type과 관련된 파라미터 정보 세팅
	GetMaterial()->SetScalarParam(INT_0, &m_Type);


	if (nullptr != m_SkyBoxTex)
	{
		if (m_SkyBoxTex->IsCube())
		{
			GetMaterial()->SetTexParam(TEX_CUBE_0, m_SkyBoxTex);
		}

		else
		{
			GetMaterial()->SetTexParam(TEX_0, m_SkyBoxTex);
		}


	}



	// 재질 업데이트(위에서 세팅한 파라미터 정보와 같이)
	GetMaterial()->UpdateData();

	// 렌더
	GetMesh()->render();


}

void CSkyBox::SetSkyBoxType(SKYBOX_TYPE _Type)
{
	m_Type = _Type;

	if(m_Type == SKYBOX_TYPE::SPHERE)
	{
		SetMesh(CResMgr::GetInst()->FindRes<CMesh>(L"SphereMesh"));
	}

	else
	{
		SetMesh(CResMgr::GetInst()->FindRes<CMesh>(L"CubeMesh"));
	}


}

void CSkyBox::SetSkyBoxTexture(Ptr<CTexture> _Tex)
{
	m_SkyBoxTex = _Tex;



}
