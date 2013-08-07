MODULE NUzl1lqmBmaKyswkc70kO3w;(*anonymous module created by saboteur*)
 
IMPORT Base:=Base, TexVox;
  
VAR vox: TexVox.TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN NEW(vox,'XNXL.sky2.jpg')  END;
	RETURN vox
END thisvox;

 END NUzl1lqmBmaKyswkc70kO3w. 