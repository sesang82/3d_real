#include "pch.h"
#include "CMRT.h"
#include "CDevice.h"

CMRT::CMRT()
	: m_arrRT{}
	, m_RTCount(0)
	, m_ClearColor{}
	, m_Viewport{}
{
}

CMRT::~CMRT()
{
}

void CMRT::Create(Ptr<CTexture>* _arrRTTex, UINT _RTCount, Ptr<CTexture> _DSTex)
{
	for (UINT i = 0; i < _RTCount; ++i)
	{
		m_arrRT[i] = _arrRTTex[i];
	}

	m_RTCount = _RTCount;
	m_DSTex = _DSTex;

}

void CMRT::ClearTarget()
{
	for (UINT i = 0; i < m_RTCount; ++i)
	{
		CONTEXT->ClearRenderTargetView(m_arrRT[i]->GetRTV().Get(), m_ClearColor[i]);
	}

	CONTEXT->ClearDepthStencilView(m_DSTex->GetDSV().Get(), D3D11_CLEAR_DEPTH | D3D11_CLEAR_STENCIL, 1.f, 0.f);


}

// OMSet 단계에 출력 타겟 지정    
// MRT 세트를 만들 때 깊이 텍스처를 같이 만들지 않고, 바인딩되어있던 이전 다른 세트의 깊이 텍스처를 갖다 쓰는 부분도 있어서
// 그것까지 고려하여 설계함
void CMRT::OMSet(bool _bStay)
{
	ID3D11RenderTargetView* arrRTV[8] = {};

	for (UINT i = 0; i < m_RTCount; ++i)
	{
		arrRTV[i] = m_arrRT[i]->GetRTV().Get();
	}


	if (nullptr != m_DSTex)
	{
		CONTEXT->OMSetRenderTargets(m_RTCount, arrRTV, m_DSTex->GetDSV().Get());
	}

	// 해당 세트에 깊이 텍스처가 없다면
	else
	{
		ComPtr<ID3D11DepthStencilView> pDSV = nullptr;

		if (_bStay)
		{
			CONTEXT->OMGetRenderTargets(0, nullptr, pDSV.GetAddressOf());

		}

		CONTEXT->OMSetRenderTargets(m_RTCount, arrRTV, pDSV.Get());



	}
}
