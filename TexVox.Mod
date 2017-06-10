MODULE TexVox;
IMPORT Base, (* ALUT := OpenALUtil, *)  SPSMMath, Noise, FilmLoop, Raster, Graphics := WMGraphics, Random, Math,Out := KernelLog; 

TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Voxel = Base.Voxel;
	FR = Base.FR;
	Name = Base.Name;
 	NCube=Base.NCube;
	TexCube= Base.TexCube;

(* pseudosolid texture *)

TYPE AvaVox* = OBJECT(Voxel);
VAR
	texcube*: TexCube;
	name: Name;

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,FALSE);
	name:=n;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: LONGINT;
	dr,dg,db,a: REAL;
	lx,ly: REAL;
	i,j,face: INTEGER;
	dot: REAL;	
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color: Base.Color;
	exit:PT;
	xx,yy,zz: REAL;
BEGIN
	IF ray.length>0.00001 THEN
		xx:=ray.xyz.x;
		yy:=ray.xyz.y;
		zz:=ray.xyz.z;	
		ray.lxyz.x:=xx*tscale-ENTIER(xx*tscale);
		ray.lxyz.y:=yy*tscale-ENTIER(yy*tscale);
		ray.lxyz.z:=zz*tscale-ENTIER(zz*tscale);
		CASE ray.face OF
			 0: lx := ray.lxyz.y; ly := 1-ray.lxyz.z; 
			|1: lx := ray.lxyz.x; ly := 1-ray.lxyz.z; 
			|2: lx := ray.lxyz.x; ly := ray.lxyz.y;
			|3: lx := ray.lxyz.y; ly := 1-ray.lxyz.z; 
			|4: lx := ray.lxyz.x; ly := 1-ray.lxyz.z; 
			|5: lx := ray.lxyz.x; ly := ray.lxyz.y;  
		END;	
		color:=texcube.side[ray.face].pixelmip_one(lx,ly);
		dot := ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z); 
		dr:=color.red*dot;
		dg:=color.green*dot;
		db:=color.blue*dot;	
		IF color.alpha<0.98 THEN
			IF color.alpha>0.7 THEN
				ray.clr.alpha:=ray.clr.alpha-0.2;
				mirror(ray)
			ELSE
				ray.clr.r := ray.clr.r + dr;
				ray.clr.ra:=ray.clr.ra-dr;
				ray.clr.g := ray.clr.g + dg;
				ray.clr.ga:=ray.clr.ga-dg;
				ray.clr.b := ray.clr.b + db;
				ray.clr.ba:=ray.clr.ba-db;
			END
		ELSE
			ray.clr.r := ray.clr.r + dr;
			ray.clr.g := ray.clr.g + dg;
			ray.clr.b := ray.clr.b + db;	
			ray.terminate:=TRUE
		END
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

PROCEDURE mirror(VAR ray: Ray);
BEGIN
	ray.hitmirrorTF := TRUE;
	ray.hitxyz:=ray.xyz;
	ray.changed := TRUE;
	ray.mirrortf:=TRUE;	
	reflect(ray.dxyz, ray.fnormal);	
	ray.clr.alpha:=ray.clr.alpha-0.1;
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
END mirror;

END AvaVox;

TYPE TexVox* = OBJECT(Voxel);
VAR
	txTF*: BOOLEAN;
	texcube*: TexCube;
	texscale*:LONGINT;
	name: Name;

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,FALSE);
	name:=n;
	tscale:=10;
	texscale:=900;
END init;

PROCEDURE deepcopy*():Voxel;
VAR
	v: TexVox;
BEGIN
	NEW(v,"fake");
	v.texcube:=texcube;
	v.tscale:=tscale;	
	RETURN v
END deepcopy;

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
	IF ray.length>0.00000001 THEN
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
		mip:=ray.length*ray.scale/12;
		IF mip>7 THEN 	
			color:=texcube.side[ray.face].pixelmip_zero(lx,ly);
		ELSIF mip>4 THEN
			color:=texcube.side[ray.face].pixelmip_one(lx,ly);
		ELSE
			color:=texcube.side[ray.face].pixelmip_two(lx,ly);		
		END; 
		IF color.alpha<0.99 THEN
			IF color.alpha>0.69 THEN 
				mirror(ray,mix)
			ELSE
				dot:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);	
				dr:=color.red*dot;
				dg:=color.green*dot;
				db:=color.blue*dot;	
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
	  (* camera is inside textured cube *)
	END
END Shade;

(*
texture patch rays: diverge by dtheta, dphi: so distance between them at the hit is approximately
sin(dtheta)*ray.length -- screw it. this should be handled in the mspace shader!
X X X
X x X
X X X 

*)

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

PROCEDURE play*();
BEGIN
(*	SPSMAudio.LoadWav("test.wav");
	SPSMAudio.Play 

	ALUT.Play(Base.texsound);	*)
END play;

END TexVox;

TYPE TexCubeVox* = OBJECT(TexVox);

PROCEDURE & init*(n: Name);
BEGIN
	NEW(texcube,n,TRUE);
	name:=n;
	tscale:=1;
	texscale:=1;
END init;

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
	lxyz: Base.PT;
	lsp: Base.SPT;
	dtl: LONGINT;
	mip,mipverse: REAL;
BEGIN
	IF tscale>0 THEN
		xx:=ray.lxyz.x;
		yy:=ray.lxyz.y;
		zz:=ray.lxyz.z;
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
	color:=texcube.side[ray.face].pixelmip_two(lx,ly);	
	dot := ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z); 
	dr:=color.red*dot*ray.clr.ra;
	dg:=color.green*dot*ray.clr.ra;
	db:=color.blue*dot*ray.clr.ra;	
	IF color.alpha<0.9 THEN
			ray.clr.r := ray.clr.r + dr*color.alpha;
			ray.clr.ra:=ray.clr.ra-(dr*color.alpha)-0.1;
			ray.clr.g := ray.clr.g + dg*color.alpha;
			ray.clr.ga:=ray.clr.ga-(dg*color.alpha)-0.1;
			ray.clr.b := ray.clr.b + db*color.alpha;
			ray.clr.ba:=ray.clr.ba-(db*color.alpha)-0.1;
			IF color.alpha>0.85 THEN 
				mirror(ray,dot) 
			ELSE (* if the pixel is transparent, trace to the back side of the cube *)
				Base.ExitF(ray,lxyz,face);
				CASE face OF
					 0: lx := lxyz.y; ly := 1-lxyz.z; 
					|1: lx := lxyz.x; ly := 1-lxyz.z; 
					|2: lx := lxyz.x; ly := lxyz.y;
					|3: lx := lxyz.y; ly := 1-lxyz.z; 
					|4: lx := lxyz.x; ly := 1-lxyz.z; 
					|5: lx := lxyz.x; ly := lxyz.y;  
				END;
				color:=texcube.side[ray.face].pixelmip_two(lx,ly);	
				dot := ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z); 
				dr:=color.red*dot*ray.clr.ra;
				dg:=color.green*dot*ray.clr.ra;
				db:=color.blue*dot*ray.clr.ra;	
				IF color.alpha<0.9 THEN
				ray.clr.r := ray.clr.r + dr*color.alpha;
				ray.clr.ra:=ray.clr.ra-(dr*color.alpha)-0.1;
				ray.clr.g := ray.clr.g + dg*color.alpha;
				ray.clr.ga:=ray.clr.ga-(dg*color.alpha)-0.1;
				ray.clr.b := ray.clr.b + db*color.alpha;
				ray.clr.ba:=ray.clr.ba-(db*color.alpha)-0.1;
					IF color.alpha>0.5 THEN 
						mirror(ray,dot) 	
					END	
				ELSE
					ray.clr.r := ray.clr.r + dr;
					ray.clr.g := ray.clr.g + dg;
					ray.clr.b := ray.clr.b + db;	
					ray.terminate:=TRUE
				END			
			END			
	ELSE
		ray.clr.r := ray.clr.r + dr;
		ray.clr.g := ray.clr.g + dg;
		ray.clr.b := ray.clr.b + db;	
		ray.terminate:=TRUE
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

END TexCubeVox;

TYPE FloopVox* = OBJECT(Voxel);
VAR
	fl: FilmLoop.floop;
	tscale*: REAL;

PROCEDURE&init*(fname: Name);
BEGIN
	NEW(fl,fname);
	tscale:=81;
	lock;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	p: Raster.Pixel;
	x,y,xi,yj: LONGINT;
	r,g,b,a: REAL;
	dr,dg,db,da,blackness:REAL;
	bb,c, lx, ly,lx1,ly1, lz1,lx2,ly2,xx,yy,zz,xxx,yyy,zzz,dtl,tq :REAL;
	i,j: INTEGER;
	bpdx,bpdy: REAL;
	dot:REAL;
	xov,yov,zov:REAL;
	color, color1, color2: Base.Color;
BEGIN
	xx:=ray.xyz.x;
	yy:=ray.xyz.y;
	zz:=ray.xyz.z;
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
				|4: lx:=lx+lx1;
				|5: ly:=ly+lx1; 
			END
		ELSE
			(* xy pyramid *)
			lx:=xx; ly:=yy;
			lz1:=tscale*ray.lxyz.z/ray.scale;
			CASE ray.face OF
				 0: lx:=lx+lz1;
				|1:  ly:=ly+lz1;
				|2: 
				|3: lx:=lx+lz1;
				|4: ly:=ly+lz1;
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
				|3: lx:= lx+ly1;
				|4:  
				|5:ly:=ly+ly1;
			END

		ELSE
			(* xy pyramid *)
			lx:=xx; ly:=yy;
			lz1:=tscale*ray.lxyz.z/ray.scale;
			CASE ray.face OF
				 0: lx:=lx+lz1;
				|1:  ly:=ly+lz1;
				|2: 
				|3: lx:=lx+lz1;
				|4: ly:=ly+lz1;
				|5:
			END
		END
	END;
	lx1:=lx*3-ENTIER(lx*3);
	ly1:=ly*3-ENTIER(ly*3);
	lx2:=lx*79-ENTIER(lx*79);
	ly2:=ly*79-ENTIER(ly*79);
	fl.shade(lx1,ly1,color1);
	fl.shade(lx1,ly1,color2);
	tq:=ray.length*ray.scale/3;
	Base.clamp(tq);	
	color.red:=(color1.red*tq+color2.red*(1-tq));
	color.green:=(color1.green*tq+color2.green*(1-tq));
	color.blue:=(color1.blue*tq+color2.blue*(1-tq));
	dot := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z); 	
	dr:=color.red*dot*ray.clr.ra;
	dg:=color.green*dot*ray.clr.ga;
	db:=color.blue*dot*ray.clr.ba;	
	ray.clr.r := ray.clr.r + dr;
	ray.clr.g := ray.clr.g + dg;
	ray.clr.b := ray.clr.b + db;
	ray.terminate:=TRUE;
END Shade;

END FloopVox;

TYPE NoiseVox* = OBJECT(Voxel);
VAR
	seed:LONGINT;
	octaves:INTEGER;
	aa,bb,cc,persistence: REAL;
	tscale: REAL;
	
PROCEDURE&init*(s:LONGINT;o:INTEGER; a,b,c,p:REAL);
BEGIN
	seed:=s; octaves:=SHORT(o); persistence:=p;
	aa:=a; bb:=b; cc:=c;
	tscale:=243;
END init;

PROCEDURE Shade (VAR ray: Ray);
VAR
	r,g,b,a: REAL;
	dr,dg,db:REAL;
	bb,c, x, y, z,tq: REAL;
	i,j: INTEGER;
	bpdx,bpdy: REAL;
	dot:REAL;
	xov,yov,zov:REAL;
	color,color1,color2: Base.Color;
BEGIN
	x:= ray.xyz.x; y:=ray.xyz.y; z:=ray.xyz.z;
	x:= x; y:=y; z:=z;
	c:=Noise.noise3dperlinabs(x,y,z, 6985, 4,3.5);
	color.red:=c;
	color.green:=c;	
	color.blue:=c;
	Base.clampColor(color);
	dot := ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z)*0.7+0.4; 
	dr:=color.red*dot*ray.clr.ra;
	dg:=color.green*dot*ray.clr.ga;
	db:=color.blue*dot*ray.clr.ba;
	ray.clr.r := ray.clr.r + dr;
	ray.clr.g := ray.clr.g + dg;
	ray.clr.b := ray.clr.b + db;
	ray.terminate:=TRUE
END Shade;

END NoiseVox;


PROCEDURE nshade(CONST nc: NCube; VAR ray: Ray);
VAR
	mix,dot,dot1,dot2: REAL;	
BEGIN
	dot1 := ABS(ray.normal.x*ray.dxyz.x + ray.normal.y*ray.dxyz.y+ ray.normal.z*ray.dxyz.z); 
	dot2:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
	dot1:=dot1*0.7+0.3;
	dot2:=dot2*0.7+0.3;
	IF ray.length*ray.scale<75 THEN mix:=1-(ray.length*ray.scale/75) ELSE mix:=0 END;
	dot:=mix*dot2+(1-mix)*dot1;
	ray.clr.r := ray.clr.r + nc.color.red * ray.clr.ra*dot;
	ray.clr.g := ray.clr.g + nc.color.green * ray.clr.ga*dot;
	ray.clr.b := ray.clr.b + nc.color.blue * ray.clr.ba*dot; 		
	ray.terminate:=TRUE
END nshade;

END TexVox.
