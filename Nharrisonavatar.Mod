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
END Nharrisonavatar. 
 
 XNXLMarsh.Rez Nharrisonavatar ~
 
	