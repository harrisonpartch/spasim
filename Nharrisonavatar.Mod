MODULE Nharrisonavatar;
IMPORT Base, TexVox, XNXLRotaVox;
  
VAR 
	cv: TexVox.TexVox;
	rv: XNXLRotaVox.RVox;
	up,right: Base.PT;
	sabot, vox,v,sphere: Base.Voxel;
	center: Base.PT;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	IF vox=NIL THEN 
		sabot:=Base.VoxelFromName("NM3");	
(*		NEW(cv,"harrisonavatar.png");*)
		sphere:=Base.VoxelFromName("N2qeD84Fv78X2XEj8PtU667");  
		Base.setPT(center,1/2,1/2,1/2);
		sabot.stroke(center,1,sphere,v);
		Base.setPT(up,0,0,1);	
		Base.setPT(right,1,0,0);
		NEW(rv,sphere,up, right, 1/50, 1/100)	
	END;
	vox:=rv;
	vox.passable:=TRUE;
	RETURN vox
END thisvox;

 END Nharrisonavatar. 
 
 XNXLMarsh.Rez Nharrisonavtar ~