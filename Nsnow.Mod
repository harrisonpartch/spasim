MODULE Nsnow;
  
IMPORT Objects, Base, TexVox;

TYPE Ray = Base.Ray;
	Voxel = Base.Voxel;  
	PT =Base.PT;
VAR 
	snow: TexVox.FloopVox;
	
PROCEDURE draw;
BEGIN
	NEW(snow,"snow.mpeg",1200);
	snow.register;
END draw;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN snow
END thisvox;

BEGIN
	draw
END Nsnow.

Marsh.Rez Nsnow ~
 
