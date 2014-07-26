MODULE NMjMiBiHzuhtrETMbA4X0MQ;(*anonymous module created by saboteur*)
 
IMPORT Base, TexVox, HalfSpace ;
VAR 
	vox: HalfSpace.halfvox; 
	v: TexVox.TexVox
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	 NEW(v,'tigerlily.png'); 
	 NEW(vox,v,Base.randPT(),Base.randPT());
	RETURN vox
END thisvox;
 END NMjMiBiHzuhtrETMbA4X0MQ. 