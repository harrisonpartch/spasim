MODULE NMjMiBiHzuhtrETMbA4X0MQ;(*anonymous module created by saboteur*)
 
IMPORT Math, Base:=XNXLBase, XNXLVoxel, XNXLLifeVox, XNXLTexVox, Random, 
M2:=XNXLM3Space, M3:=XNXLM3Space, XNXLFRep, XNXLRotaVox, XNXLSierp, XNXLHalfSpace;

VAR 
	vox: XNXLHalfSpace.halfvox; 
	v: XNXLTexVox.TexVox
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	 NEW(v,'tigerlily.png'); 
	 NEW(vox,v,Base.randPT(),Base.randPT());
	RETURN vox
END thisvox;
 END NMjMiBiHzuhtrETMbA4X0MQ. 