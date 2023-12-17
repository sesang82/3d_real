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
	// 컴포넌트 순서상 transform이 맨 먼저 호출을 받게 됨.
	// 때문에 트랜스폼에서 실시간으로 계산되는 월드 상의 위치값과 방향값을 가져와서 m_LightInfo에 갱신시켜준다.
	m_LightInfo.vWorldPos = Transform()->GetWorldPos();

	// 전혀 회전하지 않은 오브젝트는 기저축과 동일한 방향을 각 방향의 벡터로 들고 있다. 현재 우리가 빛의 방향을 기재한
	// 것에 맞춰서 생각해보면 front방향을 가져다쓰는게 맞다 (이거 근데 잘 이해 안가서 따로 여쭤야할듯)
	m_LightInfo.vWorldDir = Transform()->GetWorldDir(DIR_TYPE::FRONT);


	// 레벨에 추가되는 조명들은 자연스럽게 벡터에 다 추가되도록 기재해둠
	CRenderMgr::GetInst()->RegisterLight3D(m_LightInfo);
}

void CLight3D::SaveToLevelFile(FILE* _File)
{

}

void CLight3D::LoadFromLevelFile(FILE* _File)
{

}