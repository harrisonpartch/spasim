MODULE Ndiffuseblue;
IMPORT Base, TexVox,  HalfSpace;

VAR vox: HalfSpace.halfvox; v: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	 NEW(v, 'bluedot.png'); 
	 v.tscale:=100;
	 NEW(vox,v,Base.randPT(),Base.randPT());
	RETURN v
END thisvox;
END Ndiffuseblue. 

bluedot.png