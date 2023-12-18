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

	// Transform �� UpdateData ��û
	Transform()->UpdateData();

	// Type�� ���õ� �Ķ���� ���� ����
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



	// ���� ������Ʈ(������ ������ �Ķ���� ������ ����)
	GetMaterial()->UpdateData();

	// ����
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
