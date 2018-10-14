MODULE Ngreen;
IMPORT Base, TexVox;
  
VAR 
	cv: TexVox.TexVox;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN cv
END thisvox;

BEGIN
	NEW(cv,"green.png");
	cv.tscale:=5000;
END Ngreen. 
 
Marsh.Rez Ngreen ~
 