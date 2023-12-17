#include "pch.h"
#include "CLight3D.h"

#include "CRenderMgr.h"
#include "CTransform.h"


CLight3D::CLight3D()
	: CComponent(COMPONENT_TYPE::LIGHT3D)
{
}

CLight3D::~CLight3D()
{

}

void CLight3D::finaltick()
{
	// ������Ʈ ������ transform�� �� ���� ȣ���� �ް� ��.
	// ������ Ʈ���������� �ǽð����� ���Ǵ� ���� ���� ��ġ���� ���Ⱚ�� �����ͼ� m_LightInfo�� ���Ž����ش�.
	m_LightInfo.vWorldPos = Transform()->GetWorldPos();

	// ���� ȸ������ ���� ������Ʈ�� ������� ������ ������ �� ������ ���ͷ� ��� �ִ�. ���� �츮�� ���� ������ ������
	// �Ϳ� ���缭 �����غ��� front������ �����پ��°� �´� (�̰� �ٵ� �� ���� �Ȱ��� ���� ������ҵ�)
	m_LightInfo.vWorldDir = Transform()->GetWorldDir(DIR_TYPE::FRONT);


	// ������ �߰��Ǵ� ������� �ڿ������� ���Ϳ� �� �߰��ǵ��� �����ص�
	CRenderMgr::GetInst()->RegisterLight3D(m_LightInfo);
}

void CLight3D::SaveToLevelFile(FILE* _File)
{

}

void CLight3D::LoadFromLevelFile(FILE* _File)
{

}