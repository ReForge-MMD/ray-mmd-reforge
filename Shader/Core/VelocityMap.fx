#include "VelocityMap.fxsub"

technique MainTec0_0 < 
	string MMDPass = "object"; 
	bool UseToon = true;
	string Subset = "0"; 
	string Script =
		"RenderColorTarget=MatrixBufTex;"
		"RenderDepthStencilTarget=DepthBufferMB;"
		"Pass=DrawMatrixBuf;"
		
		"RenderColorTarget=VertexPosBufTex2;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"Pass=CopyVertexBuf;"
		
		"RenderColorTarget=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawObject;"
		
		"RenderColorTarget=VertexPosBufTex;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"Pass=DrawVertexBuf;"
	;
> {
	pass DrawMatrixBuf < string Script = "Draw=Buffer;"; > { StateBlock = (makeMatrixBufState); }
	pass DrawObject    < string Script = "Draw=Geometry;"; > { StateBlock = (PMD_State); }
	pass DrawVertexBuf < string Script = "Draw=Geometry;"; > { StateBlock = (makeVertexBufState); }
	pass CopyVertexBuf < string Script = "Draw=Buffer;"; > { StateBlock = (copyVertexBufState); }
}

technique MainTec0_1 < 
	string MMDPass = "object"; 
	bool UseToon = true;
	string Script =
		"RenderColorTarget=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawObject;"
		
		"RenderColorTarget=VertexPosBufTex;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"Pass=DrawVertexBuf;"
	;
> {
	pass DrawObject    < string Script = "Draw=Geometry;"; > { StateBlock = (PMD_State); }
	pass DrawVertexBuf < string Script = "Draw=Geometry;"; > { StateBlock = (makeVertexBufState); }
}

technique MainTec1 < 
	string MMDPass = "object"; 
	bool UseToon = false;
	string Script =
		"RenderColorTarget=MatrixBufTex;"
		"RenderDepthStencilTarget=DepthBufferMB;"
		"Pass=DrawMatrixBuf;"
		
		"RenderColorTarget=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawObject;"
	;
> {
	pass DrawObject    < string Script = "Draw=Geometry;"; > { StateBlock = (Accessory_State); }
	pass DrawMatrixBuf < string Script = "Draw=Buffer;"; > { StateBlock = (makeMatrixBufState); }
}

technique MainTec0_0SS < 
	string MMDPass = "object_ss"; 
	bool UseToon = true;
	string Subset = "0"; 
	string Script =
		"RenderColorTarget=MatrixBufTex;"
		"RenderDepthStencilTarget=DepthBufferMB;"
		"Pass=DrawMatrixBuf;"
		
		"RenderColorTarget=VertexPosBufTex2;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"Pass=CopyVertexBuf;"
		
		"RenderColorTarget=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawObject;"
		
		"RenderColorTarget=VertexPosBufTex;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"Pass=DrawVertexBuf;"
	;
> {
	pass DrawMatrixBuf < string Script = "Draw=Buffer;"; > { StateBlock = (makeMatrixBufState); }
	pass DrawObject    < string Script = "Draw=Geometry;"; > { StateBlock = (PMD_State); }
	pass DrawVertexBuf < string Script = "Draw=Geometry;"; > { StateBlock = (makeVertexBufState); }
	pass CopyVertexBuf < string Script = "Draw=Buffer;"; > { StateBlock = (copyVertexBufState); }
}

technique MainTec0_1SS < 
	string MMDPass = "object_ss"; 
	bool UseToon = true;
	string Script =
		"RenderColorTarget=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawObject;"
		
		"RenderColorTarget=VertexPosBufTex;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"Pass=DrawVertexBuf;"
	;
> {
	pass DrawObject    < string Script = "Draw=Geometry;"; > { StateBlock = (PMD_State); }
	pass DrawVertexBuf < string Script = "Draw=Geometry;"; > { StateBlock = (makeVertexBufState); }
}

technique MainTec1SS < 
	string MMDPass = "object_ss"; 
	bool UseToon = false;
	string Script =
		"RenderColorTarget=MatrixBufTex;"
		"RenderDepthStencilTarget=DepthBufferMB;"
		"Pass=DrawMatrixBuf;"
		
		"RenderColorTarget=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawObject;"
	;
> {
	pass DrawObject    < string Script = "Draw=Geometry;"; > { StateBlock = (Accessory_State); }
	pass DrawMatrixBuf < string Script = "Draw=Buffer;"; > { StateBlock = (makeMatrixBufState); }
}

technique EdgeTec < string MMDPass = "edge"; > {
	pass DrawObject < string Script = "Draw=Geometry;"; > { StateBlock = (PMD_State); }
}

technique ShadowTec < string MMDPass = "shadow"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}
