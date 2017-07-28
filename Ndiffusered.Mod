MODULE Ndiffusered;
IMPORT Base, TexVox;

VAR  v: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN v
END thisvox;

BEGIN
	NEW(v, 'reddot.png'); 
		v.tscale:=0;
END Ndiffusered. 

reddot.png