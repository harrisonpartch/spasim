MODULE Npng;
IMPORT Base, Files, Raster, Graphics := WMGraphics, Random, Math,Out := KernelLog;
TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Voxel = Base.Voxel;
	FR = Base.FR;
	Name = Base.Name;
 	NCube=Base.NCube;
	TexCube= Base.TexCube;

TYPE FilmVox=OBJECT(Voxel);
VAR 
	e: Files.Enumerator;
	name: ARRAY 256 OF CHAR; 
	flags: SET;
	time,date,size: LONGINT;
	go:BOOLEAN;
	texcube*: TexCube;
	film: ARRAY 457 OF Raster.Image;
	acidcats: Raster.Image;
	copy: Raster.Mode;
	frame: LONGINT;

PROCEDURE  &init(n:Name);
VAR
	i:LONGINT;
BEGIN
	NEW(texcube,n,FALSE);
	Raster.InitMode(copy,Raster.srcCopy);
	acidcats:=Graphics.LoadImage(n, FALSE);
   	NEW(e);
     e.Open("ngs/*.png",{});
     FOR i:=0 TO 456 DO
		IF e.HasMoreEntries() THEN
			IF e.GetEntry(name,flags,time,date,size) THEN
				film[i]:=Graphics.LoadImage(name, FALSE);
			ELSE
				film[i] := acidcats;		
			END  
		ELSE
			film[i] := acidcats;		   	
	    END
	END;
     register;
END init;

PROCEDURE tick;
BEGIN
	frame:=(frame+1)MOD 456;
	texcube.side[0].img:=film[frame];
END tick;

PROCEDURE pixel*(img: Raster.Image; x,y:REAL):Color;
VAR
	i,j: LONGINT;
	p: Raster.Pixel;
	c: Color;
	W,H: LONGINT;
BEGIN
	W:=img.width; 
	H:=img.height;
	i:= ENTIER(x*W) MOD W;
	j:=ENTIER((1-y)*H) MOD H;
	Raster.Get(img,i,j,p,copy); 
	c.red := ORD(p[2])/255; c.green := ORD(p[1])/255; c.blue := ORD(p[0])/255; c.alpha:= ORD(p[3])/255;	
	RETURN c
END pixel;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: LONGINT;
	X,Y, xblend, yblend,blendx,blendy: REAL;
	r,g,b,a: REAL;
	dr,dg,db,da,blackness:REAL;
	bb,c, lx, ly,lz, lx1,ly1,lz1,lx2,ly2,lz2,tq,xx,yy,zz,xxx,yyy,zzz,sc : REAL;
	i,j,face: INTEGER;
	mix,dot,dot1,dot2, nx, ny, nz: REAL;	
	bpdx,bpdy,cq: REAL;
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color,color1,color2: Base.Color;
	txcube: TexCube;
	rlf: REAL;
	rlm: BOOLEAN;
	lxyz,exit: Base.PT;
	lsp: Base.SPT;
	faace:INTEGER;
	dtl: LONGINT;
	mip,mipverse,gray,grayinv: REAL;
	patchradius: REAL;
	pclr: Base.ray_color;
BEGIN
	IF ray.length>0 THEN
		IF tscale>0 THEN
			xx:=ray.xyz.x;
			yy:=ray.xyz.y;
			zz:=ray.xyz.z;	
			lx:=xx*90-ENTIER(xx*90);
			ly:=yy*90-ENTIER(yy*90);
			lz:=zz*90-ENTIER(zz*90);
			xx:=xx*tscale-ENTIER(xx*tscale);
			yy:=yy*tscale-ENTIER(yy*tscale);
			zz:=zz*tscale-ENTIER(zz*tscale);
			xxx:=ABS(1/2-xx);
			yyy:=ABS(1/2-yy);
			zzz:=ABS(1/2-zz);
			IF xxx>yyy THEN
				IF xxx>zzz THEN
					(* yz pyramid *)  				(*  faces come in pairs: (0,3),(2,5),(1,4) *)
					lx:=yy; ly:=zz;
					lx1:=tscale*ray.lxyz.x/ray.scale;
					CASE ray.face OF
						0:
						|1: lx:=lx+lx1;
						|2:  ly:=ly+lx1; 
						|3: 
						|4: lx:=lx+lx1-1;
						|5: ly:=ly+lx1-1; 
					END
				ELSE
					(* xy pyramid *)
					lx:=xx; ly:=yy;
					lz1:=tscale*ray.lxyz.z/ray.scale;
					CASE ray.face OF
						 0: lx:=lx+lz1;
						|1:  ly:=ly+lz1;
						|2: 
						|3: lx:=lx+lz1-1;
						|4: ly:=ly+lz1-1;
						|5:
					END
				END
			ELSE
				IF yyy>zzz THEN
					(* xz pyramid *)	
					lx:=xx; ly:=zz;	
					ly1:=tscale*ray.lxyz.y/ray.scale;	
					CASE ray.face OF
						 0: lx:= lx+ly1;
						|1:
						|2: ly:=ly+ly1;
						|3: lx:= lx+ly1-1;
						|4:  
						|5:ly:=ly+ly1-1;
					END
				ELSE
					(* xy pyramid *)
					lx:=xx; ly:=yy;
					lz1:=tscale*ray.lxyz.z/ray.scale;
					CASE ray.face OF
						 0: lx:=lx+lz1;
						|1:  ly:=ly+lz1;
						|2: 
						|3: lx:=lx+lz1-1;
						|4: ly:=ly+lz1-1;
						|5:
					END
				END
			END 
		ELSE
			CASE ray.face OF
				 0: lx := ray.lxyz.y; ly := 1-ray.lxyz.z; 
				|1: lx := ray.lxyz.x; ly := 1-ray.lxyz.z; 
				|2: lx := ray.lxyz.x; ly := ray.lxyz.y;
				|3: lx := ray.lxyz.y; ly := 1-ray.lxyz.z; 
				|4: lx := ray.lxyz.x; ly := 1-ray.lxyz.z; 
				|5: lx := ray.lxyz.x; ly := ray.lxyz.y;  
			END
		END;										
		color:=pixel(film[frame],lx,ly);
		IF color.alpha<0.99 THEN
			IF color.alpha>0.39 THEN 
				mirror(ray,mix)
			ELSE
				dot:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);	
				dr:=color.red*color.alpha*dot;
				dg:=color.green*color.alpha*dot;
				db:=color.blue*color.alpha*dot;	
				ray.clr.r := ray.clr.r + dr*ray.clr.ra;
				ray.clr.g := ray.clr.g + dg*ray.clr.ga;
				ray.clr.b := ray.clr.b + db*ray.clr.ba;	
				ray.clr.ra:= ray.clr.ra-dr;
				ray.clr.ga:= ray.clr.ga-dg;
				ray.clr.ba:= ray.clr.ba-db;
				ray.clr.alpha:=ray.clr.alpha-0.1;
				IF ray.clr.alpha<0.1 THEN ray.terminate:=TRUE END;
			END
		ELSE
			dot:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);	
			dr:=color.red*dot;
			dg:=color.green*dot;
			db:=color.blue*dot;	
			ray.clr.r := ray.clr.r + dr*ray.clr.ra;
			ray.clr.g := ray.clr.g + dg*ray.clr.ga;
			ray.clr.b := ray.clr.b + db*ray.clr.ba;	
			ray.clr.alpha:=0;	
			ray.terminate:=TRUE;
		END
	ELSE
	END
END Shade;	

PROCEDURE reflect(VAR p: PT; n: PT);
VAR 
	a,b,c,dot: REAL;
BEGIN
	dot := p.x*n.x+p.y*n.y+p.z*n.z;
	a := 2*n.x*dot; b := 2*n.y*dot; c := 2*n.z*dot;
	p.x := p.x-a; p.y := p.y-b; p.z := p.z-c;
END reflect;

PROCEDURE mirror(VAR ray: Ray; CONST mix: REAL);
VAR
	n: PT;
BEGIN
	ray.hitmirrorTF := TRUE;
	ray.hitxyz:=ray.xyz;
	ray.changed := TRUE;
	ray.mirrortf:=TRUE;	
	ray.clr.ra:= ray.clr.ra + 0.2;
	ray.clr.ga := ray.clr.ga + 0.2;
	ray.clr.ba := ray.clr.ba + 0.2;
	ray.clr.alpha:= ray.clr.alpha - 0.2;	
	IF ray.clr.alpha < 0.1 THEN ray.terminate:=TRUE END;		
	n.x:=(ray.normal.x*mix+ray.fnormal.x*(1-mix));
	n.y:=(ray.normal.y*mix+ray.fnormal.y*(1-mix));	
	n.z:=(ray.normal.z*mix+ray.fnormal.z*(1-mix));	
	reflect(ray.dxyz, n);	
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
END mirror;

END FilmVox;

VAR
	VAR vox: FilmVox;

PROCEDURE thisvox*():Base.Voxel;
BEGIN
	RETURN vox
END thisvox;

BEGIN
	NEW(vox,"acidcats.png");
     vox.tscale:=0;
END Npng. 
 
Marsh.Rez Npng ~