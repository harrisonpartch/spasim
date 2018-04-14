MODULE Nharrisonavatar;
IMPORT Base, TexVox;
  
VAR 
	cv: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN cv
END thisvox;

BEGIN
	NEW(cv,"diffusiontensors.png");
	cv.passable:=TRUE;
	cv.tscale:=32;
END Nharrisonavatar. 
 
 XNXLMarsh.Rez Nharrisonavatar ~
 
	NEW(cv,"seahorse.png"); 	