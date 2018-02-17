MODULE Nbilb;
IMPORT Base, TexVox;
  
VAR 
	cv: TexVox.BilbVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN cv
END thisvox;

BEGIN
	NEW(cv,"mirrorsunglasses.png");
	cv.passable:=TRUE;
END Nbilb. 
 
Marsh.Rez Nbilb ~
 