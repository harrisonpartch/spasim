MODULE Ndiffusered;
IMPORT Base, TexVox,  XNXLHalfSpace;

VAR vox: XNXLHalfSpace.halfvox; v: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	 NEW(v, 'reddot.png'); 
	 v.tscale:=0;
	 NEW(vox,v,Base.randPT(),Base.randPT());
	RETURN v
END thisvox;
END Ndiffusered. 

reddot.png