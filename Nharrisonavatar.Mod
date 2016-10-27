MODULE Nharrisonavatar;
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
	NEW(cv,"hexglass.png");
	cv.passable:=TRUE;
	cv.tscale:=64;	
END Nharrisonavatar. 
 
 XNXLMarsh.Rez Nharrisonavtar ~