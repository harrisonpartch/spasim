MODULE Nearthchan;
IMPORT Base:=Base, TexVox;
VAR vox: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	NEW(vox,"earthchan.png");
	vox.tscale:=10000;  
	vox.register;	
	RETURN vox
END thisvox;

PROCEDURE tick;
BEGIN
	vox.tscale:= 26 + Base.rand.Uniform()*250;
END tick;

BEGIN
END Nearthchan. 