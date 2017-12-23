MODULE Ndrdh;
IMPORT Base, TexVox;
  
VAR 
	cv: TexVox.TexVox;
	center: Base.PT;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN cv
END thisvox;

BEGIN
	NEW(cv,"DRDH.png");
	cv.tscale:=0;	
END Ndrdh. 
 
Marsh.Rez Ndrdh ~
 