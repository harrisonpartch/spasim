MODULE Ngreen;
IMPORT Base, TexVox, RotaVox;
  
VAR 
	cv: TexVox.TexVox;
	center: Base.PT;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN cv
END thisvox;

BEGIN
	NEW(cv,"green.png");
	cv.tscale:=100;
END Ngreen. 
 
Marsh.Rez Ngreen ~
 