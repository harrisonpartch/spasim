MODULE Ngreen;
IMPORT Base, TexVox;
  
VAR 
	cv: TexVox.TexCubeVox;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN cv
END thisvox;

BEGIN
	NEW(cv,"earth");
	cv.tscale:=26
END Ngreen. 
 
Marsh.Rez Ngreen ~
 