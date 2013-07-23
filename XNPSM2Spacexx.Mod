MODULE XNPSM2Space;
IMPORT XNPSBase, XNPSE, XNPSFRep, Out := DebugLog;

CONST M=2;
	MMO=M-1;
	CUBERADIUS=0.866;   (*change to sqrt(3)/2 ???*)
	AIR=0;
	WATER=1;	

TYPE PT = XNPSBase.PT;
TYPE COLOR = XNPSBase.COLOR;
TYPE Ray = XNPSBase.Ray;
TYPE Voxel = XNPSBase.Voxel;
TYPE FR = XNPSBase.FR;

TYPE cell* = OBJECT(XNPSFRep.MSV);
VAR
	bloxtf*,nbloxtf*:BA;
	blox*: VA;
	nblox:  NA;
	red,green,blue,black: REAL;
	slock: BOOLEAN;
	outvox: Voxel;
	outvoxtf:BOOLEAN;

PROCEDURE & init*;
BEGIN
	passable:=TRUE;
END init;

PROCEDURE  lock*;
BEGIN
	slock:=TRUE
END lock;

PROCEDURE  setout*(v:Voxel);
BEGIN
	outvox:=v;
	outvoxtf:=TRUE
END setout;

PROCEDURE copyclear*;
VAR
	child:Voxel;
	i,j,k: INTEGER;
BEGIN
	copymarker:=FALSE;
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		child:=blox[i,j,k]; 
		IF (child#NIL)&child.copymarker THEN
			child.copyclear;
		END
	END END END;		
END copyclear;

PROCEDURE setcolor* (r,g,b,bl: REAL); 
BEGIN
	red:= r/M;
	green := g/M;
	blue := b/M;
	black:= bl/M;
END setcolor;

PROCEDURE bounds* (i, j, k: LONGINT; VAR out: BOOLEAN);
BEGIN
	IF (i < 0) OR (i > MMO) OR (j < 0) OR (j > MMO) OR (k < 0) OR (k > MMO) THEN
		out := TRUE
	ELSE
		out := FALSE
	END
END bounds;

PROCEDURE fill*(v: Voxel);
VAR
	i,j,k: INTEGER;
BEGIN
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		blox[i,j,k] := v;
		bloxtf[i,j,k] := TRUE;
	END END END
END fill;

PROCEDURE erase*(p:PT; resolution:LONGINT);
VAR
	i,j,k: INTEGER;
BEGIN
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		blox[i,j,k] := NIL; nblox[i,j,k].bottom := TRUE; 
	END END END
END erase;

PROCEDURE fillwithprobability*(v: Voxel; p: REAL);
VAR
	i,j,k: INTEGER;
BEGIN
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		IF XNPSBase.rand.Uniform()<p THEN blox[i,j,k] := v END
	END END END
END fillwithprobability;

PROCEDURE fillchequer*(v,w: Voxel);
VAR
	i,j,k: INTEGER;
BEGIN
	fill(w);
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		IF ODD(i+j+k) THEN blox[i,j,k] := v END;
	END END END
END fillchequer;

PROCEDURE fillcqr2*(v,w: Voxel);
VAR
	i,j,k: INTEGER;
	c: cell;
BEGIN
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		NEW(c);
		c.fillchequer(v,w);
		blox[i,j,k]:=c;
	END END END
END fillcqr2;

PROCEDURE fillcqr3*(v,w: Voxel);
VAR
	i,j,k: INTEGER;
BEGIN
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		fillcqr2(v,w)
	END END END
END fillcqr3;

PROCEDURE ncolor(VAR ray: Ray; cube:NCUBE);
VAR
	dot,omm,r,g,b,bl: REAL;	

PROCEDURE reflect(VAR x,y,z: REAL; nx,ny,nz:REAL);
VAR 
	dot: REAL;
BEGIN
	dot := x*nx+y*ny+z*nz;
	nx := 2*nx*dot; ny := 2*ny*dot; nz := 2*nz*dot;
	x := x-nx; y := y-ny; z := z-nz; 
END reflect;

PROCEDURE mirror(VAR ray: Ray);
BEGIN
	reflect(ray.dxyz.x,ray.dxyz.y,ray.dxyz.z, cube.normal.x,cube.normal.y,cube.normal.z);
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
	ray.popdelta.x := ray.dxyz.x;  (* ray.lxyz could be renamed to ray.pushxyz *)
	ray.popdelta.y := ray.dxyz.y;		
	ray.popdelta.z := ray.dxyz.z; 
END mirror;

BEGIN
	IF cube.mirror>0 THEN
		omm:=1-cube.mirror; 
	(*	dot := ABS((cube.normal.x*ray.dxyz.x + cube.normal.y*ray.dxyz.y+ cube.normal.z*ray.dxyz.z)*omm); *)
		dot := omm;
		r:=cube.color.red * ray.ra*dot;
		g:=cube.color.green * ray.ga*dot;
		b:=cube.color.blue * ray.ba*dot; 
		bl:=0.3;
		ray.r := ray.r+r;
		ray.g := ray.g+g;
		ray.b := ray.b+b; 		
		ray.ra:= ray.ra-r-bl;
		ray.ga := ray.ga-g-bl;
		ray.ba := ray.ba-b-bl; 					
		mirror(ray)	
	ELSE
		dot := ABS(cube.normal.x*ray.dxyz.x + cube.normal.y*ray.dxyz.y+ cube.normal.z*ray.dxyz.z); 
		ray.r := ray.r + cube.color.red * ray.ra*dot;
		ray.g := ray.g + cube.color.green * ray.ga*dot;
		ray.b := ray.b + cube.color.blue * ray.ba*dot; 		
		ray.terminate:=TRUE
	END
END ncolor;

PROCEDURE Shade (VAR ray: Ray);
VAR
	pushxyz, newxyz, xyz: XNPSBase.PT;
	ijk: XNPSBase.IPT;
	drx, dry, drz, dr,rr,gr,br,blr: REAL;
	out,shadenil,A,B,C: BOOLEAN;
	v: Voxel;
	vdepth: REAL;
	last:BOOLEAN;
BEGIN
	ray.scale := ray.scale*M;
	xyz.x := ray.lxyz.x * M  - ray.ddxyz.x;  (* ray.lxyz could be renamed to ray.pushxyz *)
	xyz.y := ray.lxyz.y * M  - ray.ddxyz.y;		
	xyz.z := ray.lxyz.z * M  - ray.ddxyz.z; 
	IF  (ray.length*ray.scale>XNPSBase.DTL) THEN
		IF (imposter#NIL) THEN
			imposter.Shade(ray)	
		ELSIF nbloxtf[ijk.i,ijk.j,ijk.k] THEN	
			ncolor(ray,nblox[ijk.i,ijk.j,ijk.k]);						
		END			
	ELSE		
	pushxyz:=xyz;
	XNPSE.E(xyz,ijk);
	bounds(ijk.i,ijk.j,ijk.k,out);
	IF ~out THEN
		IF bloxtf[ijk.i,ijk.j,ijk.k] THEN v:= blox[ijk.i,ijk.j,ijk.k] END;
		IF (v#NIL) THEN
			ray.lxyz.x := ABS(xyz.x - ijk.i);  
			ray.lxyz.y := ABS(xyz.y - ijk.j);
			ray.lxyz.z := ABS(xyz.z - ijk.k);
			ray.popdelta := XNPSBase.Origin; (* because many shaders don't set it and it *)
			v.Shade(ray);					(* must be (0,0,0) in that case       *)
			xyz.x := xyz.x + ray.popdelta.x;    
			xyz.y := xyz.y + ray.popdelta.y;
			xyz.z := xyz.z + ray.popdelta.z
		ELSIF nbloxtf[ijk.i,ijk.j,ijk.k] & nblox[ijk.i,ijk.j,ijk.k].bottom THEN		
			ncolor(ray,nblox[ijk.i,ijk.j,ijk.k]);
			xyz.x := xyz.x + ray.popdelta.x;    
			xyz.y := xyz.y + ray.popdelta.y;
			xyz.z := xyz.z + ray.popdelta.z			
		END
	END;	 
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;	
	IF ~ray.terminate THEN
		REPEAT
			IF ray.di  THEN
				drx := ( (ijk.i + 1) - xyz.x) / ray.dxyz.x
			ELSE
				drx :=  (ijk.i -  xyz.x) / ray.dxyz.x
			END;
			IF ray.dj THEN
				dry := ( (ijk.j + 1) - xyz.y) / ray.dxyz.y
			ELSE
				dry :=  (ijk.j - xyz.y) / ray.dxyz.y
			END;
			IF ray.dk  THEN
				drz := ( (ijk.k + 1) - xyz.z) / ray.dxyz.z
			ELSE
				drz :=  (ijk.k - xyz.z) / ray.dxyz.z
			END;
			A:=drx<dry; B:=drx<drz; C:=dry<drz;	
			IF A&B THEN
				dr := drx;
				IF ray.di THEN 
					INC(ijk.i, 1);
					ray.face := 1; ray.normal:= XNPSBase.Face[0] 
				ELSE 
					INC(ijk.i, -1);
					ray.face := 4; ray.normal:= XNPSBase.Face[3] 
				END;
				newxyz.x := xyz.x + drx * ray.dxyz.x; newxyz.y := xyz.y + drx * ray.dxyz.y; newxyz.z  := xyz.z + drx * ray.dxyz.z	
			ELSIF A&~B THEN
				dr := drz;
				IF ray.dk THEN 
					INC(ijk.k, 1);
					ray.face := 3; ray.normal:= XNPSBase.Face[2] 
				ELSE
					INC(ijk.k, -1);
					ray.face := 6; ray.normal:= XNPSBase.Face[5]
				END;
				newxyz.x := xyz.x + drz * ray.dxyz.x; newxyz.y := xyz.y + drz * ray.dxyz.y; newxyz.z  := xyz.z + drz * ray.dxyz.z
			ELSIF C THEN
				dr := dry;
				IF ray.dj THEN 
					INC(ijk.j, 1);
					ray.face := 2; ray.normal:= XNPSBase.Face[1] 
				ELSE 
					INC(ijk.j, -1);
					ray.face := 5; ray.normal:= XNPSBase.Face[4] 
				END;
				newxyz.x := xyz.x + dry * ray.dxyz.x; newxyz.y := xyz.y + dry * ray.dxyz.y; newxyz.z  := xyz.z+ dry * ray.dxyz.z
			ELSE
				dr := drz;		
				IF ray.dk  THEN 
					INC(ijk.k, 1);
					ray.face := 3; ray.normal:= XNPSBase.Face[2] 
				ELSE
					INC(ijk.k, -1);
					ray.face := 6; ray.normal:= XNPSBase.Face[5]
				END;
				newxyz.x := xyz.x + drz * ray.dxyz.x; newxyz.y := xyz.y + drz * ray.dxyz.y; newxyz.z  := xyz.z + drz * ray.dxyz.z
			END;
			vdepth:=XNPSBase.distance(newxyz,xyz);
			xyz:=newxyz;
			ray.length:=ray.length+vdepth/ray.scale;
			rr := red*vdepth*ray.ra; gr := green*vdepth*ray.ga; br := blue*vdepth*ray.ba; blr:=black*vdepth;
			ray.r := ray.r+rr;
			ray.g:= ray.g+gr;
			ray.b := ray.b+br; 
			ray.ra := (ray.ra-rr)-blr;
			ray.ga := (ray.ga-gr)-blr;
			ray.ba := (ray.ba-br)-blr; 			
			bounds(ijk.i,ijk.j,ijk.k, out);
			IF ~out  THEN
				v:=NIL;
				IF FALSE & (ray.length*ray.length*ray.length*ray.scale>XNPSBase.DTL) THEN
					v:=imposter
				ELSIF bloxtf[ijk.i,ijk.j,ijk.k] THEN 
					v:= blox[ijk.i,ijk.j,ijk.k] 
				END;						
				IF (v#NIL) THEN
					ray.lxyz.x := ABS(xyz.x - ijk.i);  
					ray.lxyz.y := ABS(xyz.y - ijk.j);
					ray.lxyz.z := ABS(xyz.z - ijk.k);
					ray.popdelta := XNPSBase.Origin; (* because many shaders don't set it and it *)
					v.Shade(ray);					(* must be (0,0,0) in that case       *)
					xyz.x := xyz.x + ray.popdelta.x;    
					xyz.y := xyz.y + ray.popdelta.y;
					xyz.z := xyz.z + ray.popdelta.z;		
				ELSIF nbloxtf[ijk.i,ijk.j,ijk.k] & nblox[ijk.i,ijk.j,ijk.k].bottom THEN	
					ray.popdelta := XNPSBase.Origin; 
					ncolor(ray,nblox[ijk.i,ijk.j,ijk.k]);
					xyz.x := xyz.x + ray.popdelta.x;    
					xyz.y := xyz.y + ray.popdelta.y;
					xyz.z := xyz.z + ray.popdelta.z								
				END
			END; 
			IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;
		UNTIL  ray.terminate OR out;
		IF ~ray.terminate&outvoxtf THEN 
			outvox.Shade(ray);
		END
	END 
	
	END;
	ray.popdelta.x := (xyz.x-pushxyz.x)/M;
	ray.popdelta.y := (xyz.y-pushxyz.y)/M;
	ray.popdelta.z := (xyz.z-pushxyz.z)/M;
	ray.scale := ray.scale/M;
END Shade;

PROCEDURE probe(x,y,z: REAL):Voxel;
VAR
	X,Y,Z: REAL;
	i,j,k: LONGINT;
BEGIN
	XNPSBase.clamp3(x,y,z);
	X := x*M; Y := y*M; Z := z*M;
	i := ENTIER(X); 
	j := ENTIER(Y);
	k := ENTIER(Z);
	IF blox[i,j,k]#NIL THEN RETURN(blox[i,j,k].probe(X-i, Y-j, Z-k)) END;
	RETURN(SELF);
END probe;

PROCEDURE passprobe(x,y,z: REAL):BOOLEAN;
VAR
	X,Y,Z: REAL;	
	i,j,k: LONGINT;
BEGIN
	XNPSBase.clamp3(x,y,z);
	X := x*M; Y := y*M; Z := z*M;
	i := ENTIER(X); 
	j := ENTIER(Y);
	k := ENTIER(Z);
	IF blox[i,j,k]=NIL THEN 
		IF nblox[i,j,k].bottom THEN
			RETURN FALSE
		ELSE
			RETURN TRUE
		END
	ELSE
		RETURN(blox[i,j,k].passprobe(X-i, Y-j, Z-k)) 
	END
END passprobe;

PROCEDURE stroke*(p:PT; level: LONGINT; normal:PT; color: COLOR);
BEGIN
	IF  ~slock & (level>=1) & XNPSBase.inzerodotdotonePT(p) THEN
		strokerec(p, level,normal,color);
	END
END stroke;


PROCEDURE strokergb*(p:PT; level: LONGINT; nx,ny,nz:REAL; r,g,b: REAL);
VAR
	color: COLOR;
	normal: PT;
BEGIN
	normal.x:=nx;
	normal.y:=ny;
	normal.z:=nz;
	color.red:=r; color.green:=g; color.blue:=b;
	IF  ~slock & (level>=1) & XNPSBase.inzerodotdotonePT(p) THEN
		strokerec(p, level,normal,color);
	END
END strokergb;


PROCEDURE strokerec(p:PT; level: LONGINT; normal:PT; color: COLOR);
VAR
	i,j,k: LONGINT;
	c: cell;
BEGIN
	p.x:=p.x*M;
	p.y:=p.y*M;
	p.z:=p.z*M;
	i := ENTIER(p.x); j := ENTIER(p.y); k := ENTIER(p.z);
	IF level=1 THEN
		(* we're here. *)
		nbloxtf[i,j,k]:=TRUE;
		nblox[i,j,k].normal:=normal; 
		nblox[i,j,k].color:=color;
		nblox[i,j,k].bottom:=TRUE;	(* remove -- nbloxtf replaces *)
	ELSIF ~slock THEN
		IF blox[i,j,k]=NIL THEN 
			NEW(c);
			bloxtf[i,j,k]:=TRUE;
			blox[i,j,k]:=c;
		END;
		p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
		blox[i,j,k].strokerec(p, level-1,normal,color);
	END
END strokerec;

PROCEDURE strokevoxel*(p:PT; resolution:LONGINT; voxel:Voxel);
VAR
	i,j,k: LONGINT;
	c: cell;
	v:Voxel;
BEGIN
	IF ~slock THEN
		XNPSBase.clamPT(p);
		strokevoxelrec(p,resolution,1,voxel);
	END
END strokevoxel;

PROCEDURE strokevoxelrec*(p:PT; resolution,scale:LONGINT; voxel:Voxel);
VAR
	i,j,k,nextscale: LONGINT;
	v:Voxel;
	c: cell;
BEGIN
	nextscale:=scale*M;
	p.x:=p.x*M;
	p.y:=p.y*M;
	p.z:=p.z*M;
	i := ENTIER(p.x); j := ENTIER(p.y); k := ENTIER(p.z);	
	IF nextscale>resolution THEN	
		bloxtf[i,j,k]:=TRUE;
		blox[i,j,k]:=voxel
	ELSIF ~slock THEN
		IF blox[i,j,k]#NIL THEN 
			IF ~(blox[i,j,k] IS cell) THEN
				NEW(c);
				c.setcolor(red/M,green/M,blue/M,black/M);
				c.imposter:=blox[i,j,k];	
				c.fill(c.imposter);
			ELSE
				v:=blox[i,j,k];
				bloxtf[i,j,k]:=TRUE;
				WITH v: cell DO c:=v END
			END
		ELSE
			NEW(c)
		END;
		bloxtf[i,j,k]:=TRUE;
		blox[i,j,k]:=c;
		p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
		blox[i,j,k].strokevoxelrec(p, resolution,nextscale,voxel);
	END
END strokevoxelrec;

PROCEDURE clear*(p:PT; level: LONGINT);
BEGIN
	IF  (level>=1) & XNPSBase.inzerodotdotonePT(p) THEN
		clearrec(p, level);
	END
END clear;

PROCEDURE clearrec(p:PT; level: LONGINT);
VAR
	i,j,k: LONGINT;
BEGIN
	XNPSBase.clamPT(p);
	p.x:=p.x*M;
	p.y:=p.y*M;
	p.z:=p.z*M;
	i := ENTIER(p.x); j := ENTIER(p.y); k := ENTIER(p.z);
	IF level=1 THEN
		(* we're here. *)
		bloxtf[i,j,k]:=FALSE;
		nbloxtf[i,j,k]:=FALSE;
		nblox[i,j,k].bottom:=FALSE;	
		blox[i,j,k]:=NIL
	ELSE
		IF blox[i,j,k]#NIL THEN
			blox[i,j,k].clearrec(p,level-1)
		END
	END
END clearrec;

PROCEDURE line*(a,b: PT; level: LONGINT; v: Voxel);
VAR
	tx,ty,tz, dxdt, dydt, dzdt: REAL;
	t: LONGINT;
	delta: REAL;
	n: LONGINT;
	p: PT;
BEGIN
	CASE level OF
		1: delta := 1/M;
		|2: delta := 1/M*M;
		| 3: delta := 1/M*M*M;	
		|4: delta := 1/M*M*M*M;
		ELSE
		delta := 0;
	END;
	IF delta > 0 THEN
		n := ENTIER(XNPSBase.distance(a,b)/delta);
		tx := b.x; ty := b.y; tz := b.z;
		dxdt := (a.x-b.x)/n; dydt := (a.y-b.y)/n; dzdt := (a.z-b.z)/n; 
		FOR t := 0 TO n DO
			XNPSBase.setPT(p,tx, ty, tz);
			strokevoxel(p, level,v);
			tx := tx + dxdt; ty := ty + dydt; tz := tz+dzdt;
		END		
	END
END line;

PROCEDURE linevoxel*(a,b: PT; level: LONGINT; v: Voxel);
VAR
	tx,ty,tz, dxdt, dydt, dzdt: REAL;
	t: LONGINT;
	delta: REAL;
	n: LONGINT;
	p: PT;

BEGIN
	CASE level OF		
		1: delta := 1/M;
		|2: delta := 1/M*M;
		| 3: delta := 1/M*M*M;	
		|4: delta := 1/M*M*M*M;
	ELSE
		delta := 0;
	END;
	IF delta > 0 THEN
		n := ENTIER(XNPSBase.distance(a,b)/delta);
		tx := b.x; ty := b.y; tz := b.z;
		dxdt := (a.x-b.x)/n; dydt := (a.y-b.y)/n; dzdt := (a.z-b.z)/n; 
		FOR t := 0 TO n DO
			XNPSBase.setPT(p,tx, ty, tz);
			strokevoxel(p, level,v);
			tx := tx + dxdt; ty := ty + dydt; tz := tz+dzdt;
		END		
	END
END linevoxel;

PROCEDURE FRasterrec(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT); (*origin is always in world space*)
VAR
	i,j,k: INTEGER;
	o,p:PT;
	d2s,MS,TWOMS,CRDS,CRDNS:REAL;
	nextscale: LONGINT;
	v: Voxel;
	newcell: cell; 
BEGIN
	MS:=M*scale;
	TWOMS:=2*MS;
	nextscale:=scale*M;
	CRDS:=CUBERADIUS/scale;
	CRDNS:=CUBERADIUS/nextscale;
	IF nextscale<resolution THEN 
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS; (*world coordinates*)
			d2s:=f.d2s(p);
			IF ABS(d2s) < CRDS THEN				
				o.x:=p.x-1/TWOMS; o.y:=p.y-1/TWOMS; o.z:=p.z-1/TWOMS; (* p is center, o is corner *)
				IF blox[i,j,k]=NIL THEN 
					NEW(newcell);
					bloxtf[i,j,k]:=TRUE;
					blox[i,j,k]:=newcell;
					newcell.setcolor(red,green,blue,black);
					newcell.FRasterrec(f,resolution,o,nextscale);
				ELSIF ~slock THEN
				 	v:=blox[i,j,k];  (* compiler disallows type tests and guards on array elements *)
				 	IF v IS XNPSFRep.MSV THEN
				 		WITH v:XNPSFRep.MSV DO
				 			v.FRasterrec(f,resolution,o,nextscale);
				 		END
				 	END
				 END
			END	
		END END END
	ELSE
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS;
			d2s:=f.d2s(p);		
			IF ABS(d2s)<CRDNS THEN 
				v:=f.voxel(p);
				IF v#NIL THEN 
					bloxtf[i,j,k]:=TRUE;
					blox[i,j,k]:=v
				ELSE
					nbloxtf[i,j,k]:=TRUE;
					nblox[i,j,k].normal:=f.normal(p); 
					nblox[i,j,k].color:=f.getcolor(p);
					nblox[i,j,k].mirror:=f.mirror(p);				
					nblox[i,j,k].bottom:=TRUE;
				END;
			END; 	
		END END END
	END; 
END FRasterrec;

PROCEDURE FRasterrecSolid(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT); (*origin is always in world space*)
VAR
	i,j,k: INTEGER;
	o,p:PT;
	d2s,MS,TWOMS,CRDS,CRDNS:REAL;
	nextscale: LONGINT;
	v: Voxel;
	newcell: cell;
BEGIN
	MS:=M*scale;
	TWOMS:=2*MS;
	nextscale:=scale*M;
	CRDS:=CUBERADIUS/scale;
	CRDNS:=CUBERADIUS/nextscale;
	IF nextscale<resolution THEN 
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS; (*world coordinates*)
			d2s:=f.d2s(p);
			IF d2s< -CRDS THEN (* inside solid *)
				bloxtf[i,j,k]:=TRUE;
				blox[i,j,k]:=f.getimposter(p)
			ELSIF d2s<CRDS THEN  (* at surface *)				
				o.x:=p.x-1/TWOMS; o.y:=p.y-1/TWOMS; o.z:=p.z-1/TWOMS; (* p is center, o is corner *)
				IF blox[i,j,k]=NIL THEN
					NEW(newcell);
					bloxtf[i,j,k]:=TRUE;
					blox[i,j,k]:=newcell;
					newcell.setcolor(red,green,blue,black);
					newcell.imposter:=f.getimposter(p);
					newcell.FRasterrecSolid(f,resolution,o,nextscale);
				ELSIF ~slock THEN
				 	v:=blox[i,j,k];  (* compiler disallows type tests and guards on array elements *)
				 	nbloxtf[i,j,k]:=TRUE;
					nblox[i,j,k].normal:=f.normal(p); 
					nblox[i,j,k].color:=f.getcolor(p);
					nblox[i,j,k].mirror:=f.mirror(p);				
					nblox[i,j,k].bottom:=TRUE;
				 	IF v IS XNPSFRep.MSV THEN
				 		WITH v:XNPSFRep.MSV DO
				 			v.FRasterrecSolid(f,resolution,o,nextscale);
				 		END
				 	END
				 END
			END	
		END END END
	ELSE
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS;
			d2s:=f.d2s(p);		
			IF ABS(d2s)<CRDNS THEN 
				v:=f.voxel(p);
				IF v#NIL THEN 
					bloxtf[i,j,k]:=TRUE;
					blox[i,j,k]:=v
				ELSE
					nbloxtf[i,j,k]:=TRUE;
					nblox[i,j,k].normal:=f.normal(p); 
					nblox[i,j,k].color:=f.getcolor(p);
					nblox[i,j,k].mirror:=f.mirror(p);				
					nblox[i,j,k].bottom:=TRUE;
				END;
			END; 	
		END END END
	END; 
END FRasterrecSolid;

PROCEDURE FRaster*( f: FR; resolution: LONGINT); 
VAR
	origin: PT;
BEGIN
	origin.x:=0; origin.y:=0; origin.z:=0;
	FRasterrec(f,resolution,origin,1);   (* origin is (0,0,0) *)
END FRaster;

PROCEDURE FRasterSolid*( f: FR; resolution: LONGINT); 
VAR
	origin: PT;
BEGIN
	origin.x:=0; origin.y:=0; origin.z:=0;
	FRasterrecSolid(f,resolution,origin,1);   (* origin is (0,0,0) *)
END FRasterSolid;

PROCEDURE copy():Voxel;
VAR c: cell;
	i,j,k: INTEGER;
BEGIN
	NEW(c);
	c.setcolor(red,green,blue,black);
	FOR i:=0 TO MMO DO
		FOR j := 0 TO MMO DO
			FOR k := 0 TO MMO DO
				c.nblox:=nblox;
				c.bloxtf:=bloxtf;
				c.nbloxtf:=nbloxtf;
				IF bloxtf[i,j,k] (* & blox[i,j,k] # NIL*) THEN 
					c.blox[i,j,k] := blox[i,j,k].copy(); 
				END
			END
		END
	END;	
	RETURN(c)
END copy;

PROCEDURE deepcopy*():Voxel;
VAR	
	c:cell;
	child:Voxel;
	i,j,k: INTEGER;
BEGIN
	copymarker:=TRUE;
	NEW(c);
	c.red:=red; c.green:=green; c.blue:=blue; c.black:=black;
	c.nblox:=nblox;
	c.bloxtf:=bloxtf;
	c.nbloxtf:=nbloxtf;
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		child:=blox[i,j,k]; 
		IF (child#NIL)&~child.copymarker THEN
			c.blox[i,j,k]:=child.deepcopy();
		END
	END END END;	
	copyclear;
	RETURN(c)
END deepcopy;

PROCEDURE split;
BEGIN
END split;

END cell;

TYPE NCUBE=RECORD
	bottom: BOOLEAN;
	normal: PT; 
	normaltype:INTEGER ;
	color:COLOR;
	mirror:REAL;	
	
END;
TYPE BA=ARRAY M,M,M OF BOOLEAN;
TYPE VA=ARRAY M,M,M OF Voxel;
TYPE NA=ARRAY M,M,M OF NCUBE;

(* PROCEDURE mcompose*(a,b:cell);  (* a over b composition for now ; nonrecursive for now*) 
VAR
	v: Voxel;
	c,d: cell;
	i,j,k: INTEGER;
BEGIN
	FOR i:=0 TO MMO DO
		FOR j := 0 TO MMO DO
			FOR k := 0 TO MMO DO
				IF a.blox[i,j,k] IS cell THEN 
					v:=a.blox[i,j,k];
					WITH v:cell DO c:=v END;
					
						
					b.blox[i,j,k] := a.blox[i,j,k]
				END
			END
		END
	END;
END mcompose;
*)

END XNPSM2Space.




