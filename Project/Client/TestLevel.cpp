#include "pch.h"
#include "TestLevel.h"

#include <Engine\CLevelMgr.h>
#include <Engine\CLevel.h>
#include <Engine\CLayer.h>
#include <Engine\CGameObject.h>
#include <Engine\components.h>

#include <Engine\CResMgr.h>
#include <Engine\CCollisionMgr.h>

#include <Script\CPlayerScript.h>
#include <Script\CMonsterScript.h>

#include "CLevelSaveLoad.h"


#include <Engine/CSetColorShader.h>



void CreateTestLevel()
{
	//return;

	// 컴퓨트 쉐이더 테스트
	Ptr<CTexture> pTestTexture = 
		CResMgr::GetInst()->CreateTexture(L"ComputeTestTex"
			, 200, 200, DXGI_FORMAT_R8G8B8A8_UNORM
			, D3D11_BIND_SHADER_RESOURCE | D3D11_BIND_UNORDERED_ACCESS
			, D3D11_USAGE_DEFAULT );

	Ptr<CSetColorShader> pCS = (CSetColorShader*)CResMgr::GetInst()->FindRes<CComputeShader>(L"SetColorCS").Get();
	pCS->SetTargetTexture(pTestTexture);
	pCS->SetColor(Vec3(1.f, 0.f, 1.f));
	pCS->Execute();


	//Ptr<CSound> pSound = CResMgr::GetInst()->FindRes<CSound>(L"sound\\BGM_Stage1.wav");
	//pSound->Play(1, 0.5f, false);

	CLevel* pCurLevel = CLevelMgr::GetInst()->GetCurLevel();
	pCurLevel->ChangeState(LEVEL_STATE::STOP);

	// Layer 이름설정
	pCurLevel->GetLayer(0)->SetName(L"Default");
	pCurLevel->GetLayer(1)->SetName(L"Tile");
	pCurLevel->GetLayer(2)->SetName(L"Player");
	pCurLevel->GetLayer(3)->SetName(L"Monster");
	pCurLevel->GetLayer(4)->SetName(L"PlayerProjectile");
	pCurLevel->GetLayer(5)->SetName(L"MonsterProjectile");
	pCurLevel->GetLayer(31)->SetName(L"ViewPort UI");


	// Main Camera Object 생성
	CGameObject* pMainCam = new CGameObject;
	pMainCam->SetName(L"MainCamera");

	pMainCam->AddComponent(new CTransform);
	pMainCam->AddComponent(new CCamera);

	pMainCam->Camera()->SetProjType(PROJ_TYPE::ORTHOGRAPHIC);
	pMainCam->Camera()->SetCameraIndex(0);		// MainCamera 로 설정
	pMainCam->Camera()->SetLayerMaskAll(true);	// 모든 레이어 체크
	pMainCam->Camera()->SetLayerMask(31, false);// UI Layer 는 렌더링하지 않는다.

	SpawnGameObject(pMainCam, Vec3(0.f, 0.f, 0.f), 0);

	// UI cameara
	CGameObject* pUICam = new CGameObject;
	pUICam->SetName(L"UICamera");

	pUICam->AddComponent(new CTransform);
	pUICam->AddComponent(new CCamera);

	pUICam->Camera()->SetProjType(PROJ_TYPE::ORTHOGRAPHIC);
	pUICam->Camera()->SetCameraIndex(1);		// Sub 카메라로 지정
	pUICam->Camera()->SetLayerMask(31, true);	// 31번 레이어만 체크

	SpawnGameObject(pUICam, Vec3(0.f, 0.f, 0.f), 0);


	// 광원 추가
	CGameObject* pLightObj = new CGameObject;
	pLightObj->SetName(L"Directional Light");

	pLightObj->AddComponent(new CTransform);
	pLightObj->AddComponent(new CLight3D);
	pLightObj->Transform()->SetRelativeRot(Vec3(XM_PI / 4.f, XM_PI / 4.f, 0.f)); 	// pi/4.f는 45도임 
	pLightObj->Light3D()->SetLightType(LIGHT_TYPE::DIRECTIONAL);
	pLightObj->Light3D()->SetLightColor(Vec3(1.f, 1.f, 1.f));
	pLightObj->Light3D()->SetLightAmbient(Vec3(0.15f, 0.15f, 0.15f));
	
	//pLightObj->Light2D()->SetRadius(500.f);

	SpawnGameObject(pLightObj, Vec3(0.f, 0.f, 0.f), 0);


	//// 광원 추가
	//CGameObject* pLightObj = new CGameObject;
	//pLightObj->SetName(L"Point Light");

	//pLightObj->AddComponent(new CTransform);
	//pLightObj->AddComponent(new CLight3D);
	////pLightObj->Transform()->SetRelativeRot(Vec3(0.f, 0.f, XM_PI / 2.f));

	//// pi/4.f는 45도임 
	//pLightObj->Light3D()->SetLightType(LIGHT_TYPE::POINT);
	//pLightObj->Light3D()->SetLightColor(Vec3(1.f, 1.f, 1.f));
	//pLightObj->Light3D()->SetLightAmbient(Vec3(0.f, 0.f, 0.f));
	//pLightObj->Light3D()->SetRadius(500.f);


	//SpawnGameObject(pLightObj, Vec3(0.f, -250.f, 0.f), 0);


	//	// 광원 추가
	//CGameObject* pLightObj = new CGameObject;
	//pLightObj->SetName(L"Point Light 1");

	//pLightObj->AddComponent(new CTransform);
	//pLightObj->AddComponent(new CLight3D);

	//pLightObj->Light3D()->SetLightType(LIGHT_TYPE::POINT);
	//pLightObj->Light3D()->SetLightColor(Vec3(1.f, 0.2f, 0.2f));
	//pLightObj->Light3D()->SetLightAmbient(Vec3(0.f, 0.f, 0.f));
	//pLightObj->Light3D()->SetRadius(1000.f);

	//SpawnGameObject(pLightObj, Vec3(-500.f, -250.f, 0.f), 0);


	//pLightObj = new CGameObject;
	//pLightObj->SetName(L"Point Light 2");

	//pLightObj->AddComponent(new CTransform);
	//pLightObj->AddComponent(new CLight3D);

	//pLightObj->Light3D()->SetLightType(LIGHT_TYPE::POINT);
	//pLightObj->Light3D()->SetLightColor(Vec3(0.2f, 0.2f, 1.f));
	//pLightObj->Light3D()->SetLightAmbient(Vec3(0.f, 0.f, 0.f));
	//pLightObj->Light3D()->SetRadius(1000.f);

	//SpawnGameObject(pLightObj, Vec3(500.f, -250.f, 0.f), 0);


	// ===== SkyBox 추가
	CGameObject* pSkyBox = new CGameObject;
	pSkyBox->SetName(L"SkyBox");
	pSkyBox->AddComponent(new CTransform);
	pSkyBox->AddComponent(new CSkyBox);

	pSkyBox->Transform()->SetRelativeScale(Vec3(100.f, 100.f, 100.f));
	pSkyBox->SkyBox()->SetSkyBoxType(SKYBOX_TYPE::CUBE);
	//pSkyBox->SkyBox()->SetSkyBoxTexture(CResMgr::GetInst()->FindRes<CTexture>(L"texture\\skybox\\Sky02.jpg"));
	pSkyBox->SkyBox()->SetSkyBoxTexture(CResMgr::GetInst()->FindRes<CTexture>(L"texture\\skybox\\SkyWater.dds"));

	SpawnGameObject(pSkyBox, Vec3(0.f, 0.f, 0.f), 0);

	//// 오브젝트 생성
	//CGameObject* pParent = new CGameObject;
	//pParent->SetName(L"Player");
	//pParent->AddComponent(new CTransform);
	//pParent->AddComponent(new CMeshRender);
	//pParent->AddComponent(new CPlayerScript);

	//pParent->Transform()->SetRelativeScale(Vec3(200.f, 200.f, 200.f));
	//pParent->Transform()->SetRelativeRot(Vec3(XM_PI / 2.f, 0.f, 0.f)); // 90도로 돌려놓기

	//pParent->MeshRender()->SetMesh(CResMgr::GetInst()->FindRes<CMesh>(L"SphereMesh"));
	//pParent->MeshRender()->SetMaterial(CResMgr::GetInst()->FindRes<CMaterial>(L"Std3D_DefferedMtrl"));
	//pParent->MeshRender()->GetMaterial()->SetTexParam(TEX_0, CResMgr::GetInst()->FindRes<CTexture>(L"texture\\skybox\\Sky02.jpg"));

	//SpawnGameObject(pParent, Vec3(0.f, -500.f, 0.f), L"Player");

	
	// 충돌 시킬 레이어 짝 지정
	CCollisionMgr::GetInst()->LayerCheck(L"Player", L"Monster");	
}
