MODULE Ngold;
IMPORT Base, Raster;

TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Voxel = Base.Voxel;
	FR = Base.FR;
	Name = Base.Name;
 	NCube=Base.NCube;
 	Texture=Base.Texture;
	TexCube= Base.TexCube;

TYPE TexVox* = OBJECT(Voxel);
VAR
	txTF*: BOOLEAN;
	texcube*: TexCube;
	texscale*:INTEGER;
	name*: Name; 

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,FALSE);
	name:=n;
	tscale:=27;
	texscale:=900;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: INTEGER;
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
	raycolor: Base.ray_color;
	txcube: TexCube;
	rlf: REAL;
	rlm: BOOLEAN;
	hitp,lxyz,exit: Base.PT;
	lsp: Base.SPT;
	faace:INTEGER;
	dtl: INTEGER;
	mip,mipverse,gray,grayinv: REAL;
	patchradius: REAL;
	pclr: Base.ray_color;
	ai,ainv:REAL;
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
		mip:=ray.length*ray.scale;
		IF mip>7 THEN 	
			color:=texcube.side[ray.face].pixelmip_zero(lx,ly);
		ELSIF mip>4 THEN
			color:=texcube.side[ray.face].pixelmip_one(lx,ly);
		ELSIF mip>2 THEN
			color:=texcube.side[ray.face].pixelmip_two(lx,ly);		
		ELSE
			color:=texcube.side[ray.face].pixel(lx,ly);
		END; 
		IF color.alpha<0.99 THEN
			IF color.alpha>0.5 THEN 
				dot:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);				
				dr:=color.red*color.alpha*dot;
				dg:=color.green*color.alpha*dot;
				db:=color.blue*color.alpha*dot;	
				ray.clr.r:= ray.clr.r + dr*ray.clr.ra;
				ray.clr.g := ray.clr.g + dg*ray.clr.ga;
				ray.clr.b:= ray.clr.b + db*ray.clr.ba;	
				ray.clr.ra:= ray.clr.ra-dr;
				ray.clr.ga:= ray.clr.ga-dg;
				ray.clr.ba:= ray.clr.ba-db;		
				ray.clr.alpha:=ray.clr.alpha-(dr+dg+db)/3 -0.1;		
				hitp:=ray.hitxyz;	
				mirror(ray,0);
				ray.hitxyz:=hitp;
			ELSE
				dot:=ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z);
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
			ray.terminate:=TRUE;
		END
	ELSE
	  (* camera is inside textured cube *)
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
	reflect(ray.dxyz, ray.fnormal);	
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
	Base.world.Shade(ray);
END mirror;

END TexVox;


VAR v: TexVox;
PROCEDURE thisvox*():Base.Voxel;
BEGIN
	 NEW(v, 'gold.png'); 
	 v.tscale:=100;
	RETURN v
END thisvox;
END Ngold. 

gold.png