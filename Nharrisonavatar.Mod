MODULE Nharrisonavatar;
IMPORT Base, TexVox;
  
VAR 
	cv: TexVox.TexVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN cv
END thisvox;

BEGIN
	NEW(cv,"ugandaknuckles.png");
	cv.passable:=TRUE;
	cv.tscale:=0;
END Nharrisonavatar. 
 
 XNXLMarsh.Rez Nharrisonavatar ~
 
	NEW(cv,"seahorse.png"); 	