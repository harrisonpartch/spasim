MODULE Narchaeopteryx;
IMPORT Base, TexVox, RotaVox;
  
VAR 
	cv: TexVox.TexVox;
	sabot, vox,v,sphere: Base.Voxel;
	center: Base.PT;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN cv
END thisvox;

BEGIN
	NEW(cv,"archaeopteryx.png");
	cv.passable:=TRUE;
	cv.tscale:=125;	
END Narchaeopteryx. 
 
Marsh.Rez Narchaeopteryx ~
 
	NEW(cv,"seahorse.png"); 	