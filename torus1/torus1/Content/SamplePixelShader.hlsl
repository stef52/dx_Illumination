//// THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
//// ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
//// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
//// PARTICULAR PURPOSE.
////
//// Copyright (c) Microsoft Corporation. All rights reserved
cbuffer ModelViewProjectionConstantBuffer : register(b0)
{
	matrix model;
	matrix view;
	matrix projection;
	float4 lightpos[2];
	float4 eyepos;
};

// Per-pixel color data passed through the pixel shader.
struct PixelShaderInput
{
    float4 pos : SV_POSITION;
    float3 color : COLOR0;
	float3 normal : NORMAL0;
	float4 surfpos : POSITION0;
};

// 
float4 main(PixelShaderInput input) : SV_TARGET
{
	float3 eyee;
	float3 lighte;
	float3 lighteTwo;

	eyee = float3(eyepos.x, eyepos.y, eyepos.z);
	lighte = float3(lightpos[0].x, lightpos[0].y, lightpos[0].z);
	lighteTwo = float3(lightpos[1].x, lightpos[1].y, lightpos[1].z);

	float3 L, N, V,  R, L2,  R2;
	
	N = normalize(input.normal);
	V = (eyee - input.surfpos);
	V = normalize(V);
	L = (lighte - input.surfpos);
	L = normalize(L);

	L2 = (lighteTwo - input.surfpos);
	L2 = normalize(L2);

	float diffuse = dot(N,L);
	float diffuseTwo = dot(N, L2);
	diffuse = saturate(diffuse);
	diffuseTwo = saturate(diffuseTwo);
	
	R = (2*(dot(L, N))*N - L);
	R = normalize(R);
	R2 = (2 * (dot(L2, N))*N - L2);
	R2 = normalize(R2);

	float spec = dot(V,R);
	spec = pow(spec, 275);
	spec = saturate(spec);

	float specTwo = dot(V, R2);
	specTwo = pow(specTwo, 275);
	specTwo = saturate(specTwo);
	
	float3 cr = float3(1.0, 0.5, 0.9);
		float amb = 0.1;
	

	float c = 0.3*diffuse + 0.7*spec + 0.3*diffuseTwo + 0.7*specTwo + amb;

	// blin-phong
	//cr = float3 (input.color.x, input.color.y, input.color.z);
	//return float4(cr*c, 1.0f);


	//toon shading
	float vdotn = dot(V,N);
	vdotn = saturate(vdotn);

		
		cr = float3(0,0,0);

		if (c > 0.3) cr = float3 (input.color.x/9, input.color.y/9, input.color.z/9);
		if (c > 0.4) cr = float3 (input.color.x/4, input.color.y/4, input.color.z/4);
		if (c > 0.9) cr = float3 (input.color.x / 3, input.color.y / 3, input.color.z / 3);

		if (vdotn <= 0.13f && vdotn > 0){
			cr = float3(1.0f, 1.0f, 1.0f);
		}

    return float4(cr, 1.0f);
}
