MODULE NBsHFiBKkSckXBAd46ZbEQw;
 
IMPORT Base, TexVox,  HalfSpace;

VAR vox: HalfSpace.halfvox; v: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	 NEW(v, "mandel.png"); 
	 v.tscale:=3000;
	 NEW(vox,v,Base.randPT(),Base.randPT());
	RETURN v
END thisvox;
 END NBsHFiBKkSckXBAd46ZbEQw. 