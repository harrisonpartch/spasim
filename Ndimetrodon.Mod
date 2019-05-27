MODULE Ndimetrodon;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

PROCEDURE tick;
BEGIN
	vox.tscale:= 26 + Base.rand.Uniform()*5;
END tick;

BEGIN
	NEW(vox,"opossumetrodon.png");
	vox.tscale:=1100;  
	vox.register;
END Ndimetrodon. 