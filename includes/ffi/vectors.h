// Only incldued for clangd
#pragma once

typedef union
{
	float data[4];
	struct
	{
		float x, y, z, w;
	};
} fvector4;

typedef union
{
	float data[4];
	struct
	{
		float x, y, z, w;
	};
} fvector3;

typedef union
{
	float data[4][4];
	struct
	{
		struct
		{
			float x, y, z, w;
		} rows[4];
	};
} fmatrix44;
