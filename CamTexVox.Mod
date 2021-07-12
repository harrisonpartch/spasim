MODULE CamTexVox;
IMPORT Base, Raster, VideoExample, Out:=KernelLog;

CONST
	TX=100;

TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Voxel = Base.Voxel;

TYPE CamVox* = OBJECT(Voxel);
VAR
	copy: Raster.Mode;
	
PROCEDURE & init*;
BEGIN
	Raster.InitMode(copy,Raster.srcCopy);	
END init;

PROCEDURE pixel*(x,y:REAL):Color;
VAR
	i,j: SIZE;
	p: Raster.Pixel;
	c: Color;
BEGIN
	i:= ABS((ENTIER(x*720)+280) MOD 1280);
	j:=ABS(ENTIER(y*720) MOD 720);
	Raster.Get(VideoExample.preview.img,i,j,p,copy); 
	c.red := ORD(p[2])/255; c.green := ORD(p[1])/255; c.blue := ORD(p[0])/255; c.alpha:= ORD(p[3])/255;	
	RETURN c
END pixel;

PROCEDURE Shade (VAR ray: Ray);
VAR
	r,g,b,a: REAL;
	dr,dg,db:REAL;
	lx, ly,lz : REAL;
	i,j,face: INTEGER;
	dot: REAL;
	color: Base.Color;

BEGIN
			CASE ray.face OF
				 0: lx := ray.xyz.y; ly := 1-ray.xyz.z;
				|1: lx := ray.xyz.x; ly := 1-ray.xyz.z;
				|2: lx := ray.xyz.x; ly := ray.xyz.y;
				|3: lx := ray.xyz.y; ly := 1-ray.xyz.z;
				|4: lx := ray.xyz.x; ly := 1-ray.xyz.z;
				|5: lx := ray.xyz.x; ly := ray.xyz.y;
				|6: lx := ray.xyz.x; ly := ray.xyz.y; lz:=ray.xyz.z; (* 6 means inside *)
			END;
			lx:= ABS(lx*TX-ENTIER(lx*TX));
			ly:=1-(ABS(ly*TX-ENTIER(ly*TX)));
			color:=pixel(lx,ly); 
				dot:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
				dr:=color.red*dot*ray.clr.ra;
				dg:=color.green*dot*ray.clr.ga;
				db:=color.blue*dot*ray.clr.ba;
				ray.clr.r := ray.clr.r + dr;
				ray.clr.g := ray.clr.g + dg;
				ray.clr.b := ray.clr.b + db;	
				ray.terminate:=TRUE 
END Shade;

END CamVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN camvox
END thisvox;

VAR	
	camvox:CamVox;

BEGIN
	Out.Char('v');
	VideoExample.Start2;
	VideoExample.OpenPreview; 
	NEW(camvox);
END CamTexVox.


	VideoExample.Start ~
		VideoExample.Stop ~ 
