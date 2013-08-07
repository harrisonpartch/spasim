MODULE NMjMiBiHzuhtrETMbA4X0MQ;(*anonymous module created by saboteur*)
 
IMPORT Base, TexVox, XNXLHalfSpace ;
VAR 
	vox: XNXLHalfSpace.halfvox; 
	v: TexVox.TexVox
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	 NEW(v,'tigerlily.png'); 
	 NEW(vox,v,Base.randPT(),Base.randPT());
	RETURN vox
END thisvox;
 END NMjMiBiHzuhtrETMbA4X0MQ. 