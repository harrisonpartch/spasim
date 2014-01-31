MODULE NBsHFiBKkSckXBAd46ZbEQw;
 
IMPORT Base, TexVox,  XNXLHalfSpace;

VAR vox: XNXLHalfSpace.halfvox; v: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	 NEW(v, "XNXL.lobster.png"); 
	 v.tscale:=100;
	 NEW(vox,v,Base.randPT(),Base.randPT());
	RETURN v
END thisvox;
 END NBsHFiBKkSckXBAd46ZbEQw. 