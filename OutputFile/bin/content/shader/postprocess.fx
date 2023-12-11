#ifndef _POSTPROCESS
#define _POSTPROCESS

#include "value.fx"

struct VS_IN
{
	float3 vLocalPos : POSITION;
	float2 vUV : TEXCOORD;	
};

struct VS_OUT
{
	float4 vPosition : SV_Position; // System Value
	float2 vUV : TEXCOORD;
};


// ============================
// GrayShader
// mesh : RectMesh
// Domain : DOMAIN_POSTPROCESS
// g_tex_0 : RederTarget Copy Texture
// ============================
VS_OUT VS_GrayShader(VS_IN _in)
{
	VS_OUT output = (VS_OUT)0.f;

	//output.vPosition = float4(_in.vLocalPos * 2.f, 1.f);	

	output.vUV = _in.vUV;

	return output;
}

float4 PS_GrayShader(VS_OUT _in) : SV_Target
{
	// 픽셀 좌표
    // _in.vPosition.xy;
    float2 vScreenUV = _in.vPosition.xy / g_Resolution;
    
    //float4 vColor = g_tex_0.Sample(g_sam_0, _in.vUV);	
    float4 vColor = g_tex_0.Sample(g_sam_0, vScreenUV);
	
    float vAver = (vColor.r + vColor.g + vColor.b) / 3.f;

    vColor = float4(vAver, vAver, vAver, 1.f);
  
	return vColor;
}


// ============================
// Distortion Shader
// mesh : RectMesh
// Domain : DOMAIN_POSTPROCESS
// g_tex_0 : RederTarget Copy Texture
// g_tex_1 : Noise Texture
// ============================
VS_OUT VS_Distortion(VS_IN _in)
{
	VS_OUT output = (VS_OUT)0.f;

	
	// 2배로 곱해서 투영좌표계 0~1이라는 기준에 맞춰지게끔 해둠.
	// 이상태로 레스터라이저에게 넘겨버리는 것. 여기서 네번째 값을 1로 준 상황. 
	// 레스터라이저에서는 로컬포즈의 xyz값을 w값을 나눠 쓰기 때문에 화면 전체에 뜨게 하고 싶으니 1로 준것
	// (0으로 하면 곱해봤자 0이 되버리므로). 만약에 화면 전체가 아닌 절반에만 적용하고 싶다면
	// w값을 2.f로 줘버리면 된다. 
    output.vPosition = float4(_in.vLocalPos * 2.f, 1.f);	
	output.vUV = _in.vUV;

	return output;
}

float4 PS_Distortion(VS_OUT _in) : SV_Target
{
    float2 vUV = _in.vPosition.xy / g_Resolution;
		
	
    float fChange = cos(((vUV.x - g_AccTime * 0.05f) / 0.15f) * 2 * 3.1415926535f) * 0.05f;

    vUV.y += fChange;

    float4 vColor = g_tex_0.Sample(g_sam_0, vUV);
	//vColor.r *= 2.f;

    return vColor;
}

//float4 PS_Distortion(VS_OUT _in) : SV_Target
//{
//	float2 vUV = _in.vPosition.xy / g_Resolution;		
	
//	// Noise Texture 가 세팅이 되어 있다면
//	if (g_btex_1)
//	{
//		float2 vNoiseUV = float2(_in.vUV.x - (g_AccTime * 0.2f), _in.vUV.y);
//		float4 vNoise = g_tex_1.Sample(g_sam_0, vNoiseUV);

//		vNoise = (vNoise - 0.5f) * 0.02f;		

//		vUV += vNoise.r;
//	}

//	float4 vColor = g_tex_0.Sample(g_sam_0, vUV);

//    //vColor.r *= 2.f;
	
//	return vColor;
//}








#endif