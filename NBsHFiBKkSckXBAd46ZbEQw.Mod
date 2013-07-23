MODULE NBsHFiBKkSckXBAd46ZbEQw;
 
IMPORT Base, TexVox,  XNXLHalfSpace;

VAR vox: XNXLHalfSpace.halfvox; v: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	 NEW(v, 'galaxy.jpg'); 
	 NEW(vox,v,Base.randPT(),Base.randPT());
	RETURN v
END thisvox;
 END NBsHFiBKkSckXBAd46ZbEQw. 