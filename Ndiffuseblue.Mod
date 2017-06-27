MODULE Ndiffuseblue;
IMPORT Base, TexVox,  HalfSpace;

VAR vox: HalfSpace.halfvox; v: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	 NEW(v, 'bluedot.png'); 
	 v.tscale:=0;
	 v.lockTF:=TRUE;
	RETURN v
END thisvox;
END Ndiffuseblue. 

bluedot.png