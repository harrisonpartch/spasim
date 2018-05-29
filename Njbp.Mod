MODULE Njbp;
IMPORT Base, TexVox;
  
VAR 
	cv: TexVox.TexVox;
	center: Base.PT;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN cv
END thisvox;

BEGIN
	NEW(cv,"mirrorsunglasses.png");
	cv.tscale:=0;	
END Njbp. 
 
Marsh.Rez Njbp ~
 