MODULE Nrdpseudosolid;

IMPORT Base, XNXLE, FRep;

CONST	
	M=200;
	M2 = M DIV 2;
	A = 60;
	B = 20;
	C = 0.03;

TYPE
	PT=Base.PT;
	Voxel=Base.Voxel;
	Ray=Base.Ray;
	
TYPE rdps*=OBJECT(Base.Voxel);
VAR
	mesh1*,mesh2,n1,n2: ARRAY M,M OF REAL;
	gen: INTEGER;
	i:LONGINT;
	tscale: REAL

PROCEDURE &New*;
VAR 
	i, j : LONGINT;
BEGIN
	clere;
	seed;
	register
END New;
			
PROCEDURE clere*;
VAR
	i,j,k:LONGINT;
BEGIN								
	FOR i := 0 TO M - 1 DO
		FOR j := 0 TO M - 1 DO
			mesh1[i, j] := 0;
			mesh2[i, j] := 0;
			n1[i, j] := 0;
			n2[i, j] := 0
		END
	END;
	gen := 0;
END clere;

PROCEDURE seed*;
VAR
	i,j,k:LONGINT;
BEGIN								
	FOR i := 0 TO M - 1 DO
		FOR j := 0 TO M - 1 DO
			IF (i*j+k)MOD 43= 0 THEN mesh1[i, j] := 0.3  END 
		END
	END;
END seed;

PROCEDURE bounds (i, j, k: LONGINT; VAR out: BOOLEAN);
BEGIN
	IF (i < 0) OR (i > M-1) OR (j < 0) OR (j > M-1) OR (k < 0) OR (k > M-1) THEN
		out := TRUE
	ELSE
		out := FALSE
	END
END bounds;

PROCEDURE tick;
VAR i, j,im1,ip1,jm1,jp1: LONGINT;
BEGIN
	FOR i := 0 TO M - 1 DO
		FOR j := 0 TO M - 1 DO
			im1:=(i-1)MOD M; ip1:=(i+1)MOD M; jm1:=(j-1)MOD M; jp1:=(j+1)MOD M; 
			n1[i, j] := mesh1[im1, j] + mesh1[ip1, j] + mesh1[i, jm1] + mesh1[i, jp1]
				+ mesh1[im1, jm1] +  mesh1[ip1, jp1] + mesh1[ip1, jm1] + mesh1[im1, jp1]
		END
	END;
	FOR i := 0 TO M - 1 DO
		FOR j := 0 TO M - 1 DO
			(*  HERE ARE THE DIFFERENCE RULES! *)	
			mesh1[i, j] := mesh1[i, j] + n1[i, j]/A - mesh2[i, j];
			mesh2[i, j] := ABS(mesh2[i, j] +  mesh1[i, j]/100 - 0.0081);   
			IF mesh1[i, j] < 0 THEN mesh1[i, j] := 0 END;
			IF mesh2[i, j] < 0 THEN mesh2[i, j] := 0 END;
			IF mesh1[i, j] > 1 THEN mesh1[i, j] := 1 END;
			IF mesh2[i, j] > 1 THEN mesh2[i, j] := 1 END;
		END;
	END; 
END tick;

PROCEDURE Shade (VAR ray: Ray);
VAR
	x,y,xi,yj: LONGINT;
	X,Y, xblend, yblend,blendx,blendy: REAL;
	r,g,b: REAL;
	dr,dg,db,da,blackness:REAL;
	bb,c, lx, ly,lz, lx1,ly1,lz1,lx2,ly2,lz2,tq,xx,yy,zz,xxx,yyy,zzz,sc : REAL;
	i,j: LONGINT;
	mix,dot,dot1,dot2, nx, ny, nz: REAL;	
	bpdx,bpdy,cq: REAL;
	xov,yov,zov:REAL;
	inside: BOOLEAN;
	color,color1,color2: Base.Color;
	rlf: REAL;
	rlm: BOOLEAN;
	lxyz: Base.PT;
	lsp: Base.SPT;
	dtl: LONGINT;
	mip,mipverse: REAL;
BEGIN
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
	Base.clamp(lx);
	Base.clamp(ly);
	dot:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z); 
	i:=ENTIER(lx*(M-1));
	j:=ENTIER(ly*(M-1));	
	r:=ENTIER(mesh1[i, j] * 255)/255;
	g:=ENTIER(mesh2[i, j] * 55)/255;
	b:= ENTIER(mesh1[i, j] * 1357)/255;			
	dr:=r*dot*ray.ra;
	dg:=g*dot*ray.ga;
	db:=b*dot*ray.ba;	
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;	
	ray.terminate:=TRUE
END Shade;		
END rdps;

VAR
	vox: rdps; 
	r,b,y: Base.Voxel;
	center: Base.PT;
	ball: FRep.sphere;
	
PROCEDURE thisvox*():Base.Voxel;
BEGIN	
	RETURN vox
END thisvox;

BEGIN
	NEW(vox);
	vox.tscale:=128
END Nrdpseudosolid. 