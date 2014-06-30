MODULE Ngreenmirrordot;
IMPORT Base, TexVox,  XNXLHalfSpace;

VAR vox: XNXLHalfSpace.halfvox; v: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	 NEW(v, 'mandel.png'); 
	 v.tscale:=1000;
	 NEW(vox,v,Base.randPT(),Base.randPT());
	RETURN v
END thisvox;
END Ngreenmirrordot. 

greenmirrordot.png