MODULE XLTLM2Space;
IMPORT XLTLBase, XLTLGL, XLTLE, XLTLFRep, Out:=KernelLog;

CONST 	
	M=2;
	MMO=M-1;
	M2=M*2;
	CUBERADIUS=0.7;   (*change to sqrt(3)/2 ???*)
	A2=0;
	WATER=1;	

TYPE PT = XLTLBase.PT;
TYPE COLOR = XLTLBase.COLOR;
TYPE Ray = XLTLBase.Ray;
TYPE Voxel = XLTLBase.Voxel;
TYPE MSV=XLTLBase.MSV;
TYPE FR = XLTLBase.FR;
TYPE AR2 = ARRAY M,M,M OF Voxel;

TYPE cell* = OBJECT(XLTLBase.MSV)
VAR
	blox*: ARRAY M,M,M OF Voxel;
	bloxnorm: ARRAY M,M,M OF PT;
	m*: INTEGER;

PROCEDURE & init*;
BEGIN
	passable:=TRUE;
	imposter:=XLTLBase.SOLID;
	m:=M;
END init;

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
		blox[i,j,k] :=v
	END END END
END fill;

PROCEDURE erase*(p:PT; resolution:LONGINT);
VAR
	i,j,k: INTEGER;
BEGIN
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		blox[i,j,k] := NIL; 
	END END END
END erase;

PROCEDURE fillwithprobability*(v: Voxel; p: REAL);
VAR
	i,j,k: INTEGER;
BEGIN
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		IF XLTLBase.rand.Uniform()<p THEN blox[i,j,k] := v END
	END END END
END fillwithprobability;

PROCEDURE serp*(v,w: Voxel);
VAR
	i,j,k,center: INTEGER;
BEGIN
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		blox[i,j,k] := v 
	END END END;
	center:=MMO DIV 2;
	blox[center,center,center]:=w;
	blox[0,center,center]:=w;
	blox[MMO,center,center]:=w;
	blox[center,0,center]:=w;
	blox[center,MMO,center]:=w;
	blox[center,center,0]:=w;
	blox[center,center,MMO]:=w	
END serp;

PROCEDURE fillchequer*(v,w: Voxel);
VAR
	i,j,k: INTEGER;
BEGIN
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		IF ODD(i+j+k) THEN blox[i,j,k] := v ELSE blox[i,j,k] := w END
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

PROCEDURE Shade (VAR ray: Ray);
VAR
	pushxyz, newxyz, xyz: XLTLBase.PT;
	ijk: XLTLBase.IPT;
	drx, dry, drz, dr,rr,gr,br,blr: REAL;
	out,shadenil,A,B,C: BOOLEAN;
	v: Voxel;
	vdepth: REAL;
	last:BOOLEAN;
BEGIN
	ray.scale := ray.scale*M;
	xyz.x := ray.lxyz.x * M;  (* ray.lxyz could be renamed to ray.pushxyz *)
	xyz.y := ray.lxyz.y * M;		
	xyz.z := ray.lxyz.z * M; 
	IF (ray.length*ray.scale>XLTLBase.DTL)&(imposter#NIL) THEN
		imposter.Shade(ray);
		ray.far:=TRUE
	ELSE		
	pushxyz:=xyz;
	XLTLE.E(xyz,ijk);
	bounds(ijk.i,ijk.j,ijk.k,out);
	IF ~out THEN
		v:= blox[ijk.i,ijk.j,ijk.k];
		IF (v#NIL) THEN
			ray.lxyz.x := ABS(xyz.x - ijk.i);  
			ray.lxyz.y := ABS(xyz.y - ijk.j);
			ray.lxyz.z := ABS(xyz.z - ijk.k);
			ray.bloxnorm:=bloxnorm[ijk.i,ijk.j,ijk.k];
			ray.popdelta := XLTLBase.Origin; (* because many shaders don't set it and it *)
			v.Shade(ray);					(* must be (0,0,0) in that case       *)
			xyz.x := xyz.x + ray.popdelta.x;    
			xyz.y := xyz.y + ray.popdelta.y;
			xyz.z := xyz.z + ray.popdelta.z; 
		END
	END;	 
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
					ray.face := 1; ray.normal:= XLTLBase.Face[0] 
				ELSE 
					INC(ijk.i, -1);
					ray.face := 4; ray.normal:= XLTLBase.Face[3] 
				END;
				newxyz.x := xyz.x + drx * ray.dxyz.x; newxyz.y := xyz.y + drx * ray.dxyz.y; newxyz.z  := xyz.z + drx * ray.dxyz.z	
			ELSIF A&~B THEN
				dr := drz;
				IF ray.dk THEN 
					INC(ijk.k, 1);
					ray.face := 3; ray.normal:= XLTLBase.Face[2] 
				ELSE
					INC(ijk.k, -1);
					ray.face := 6; ray.normal:= XLTLBase.Face[5]
				END;
				newxyz.x := xyz.x + drz * ray.dxyz.x; newxyz.y := xyz.y + drz * ray.dxyz.y; newxyz.z  := xyz.z + drz * ray.dxyz.z
			ELSIF C THEN
				dr := dry;
				IF ray.dj THEN 
					INC(ijk.j, 1);
					ray.face := 2; ray.normal:= XLTLBase.Face[1] 
				ELSE 
					INC(ijk.j, -1);
					ray.face := 5; ray.normal:= XLTLBase.Face[4] 
				END;
				newxyz.x := xyz.x + dry * ray.dxyz.x; newxyz.y := xyz.y + dry * ray.dxyz.y; newxyz.z  := xyz.z+ dry * ray.dxyz.z
			ELSE
				dr := drz;		
				IF ray.dk  THEN 
					INC(ijk.k, 1);
					ray.face := 3; ray.normal:= XLTLBase.Face[2] 
				ELSE
					INC(ijk.k, -1);
					ray.face := 6; ray.normal:= XLTLBase.Face[5]
				END;
				newxyz.x := xyz.x + drz * ray.dxyz.x; newxyz.y := xyz.y + drz * ray.dxyz.y; newxyz.z  := xyz.z + drz * ray.dxyz.z
			END;
			vdepth:=XLTLBase.distance(newxyz,xyz); 
			ray.xyz.x:=ray.xyz.x +((newxyz.x-xyz.x)+ray.ddxyz.x)/ray.scale;
			ray.xyz.y:=ray.xyz.y +((newxyz.y-xyz.y)+ray.ddxyz.y)/ray.scale;			
			ray.xyz.z:=ray.xyz.z +((newxyz.z-xyz.z)+ray.ddxyz.z)/ray.scale;			
			xyz:=newxyz;
			ray.length:=ray.length+vdepth/ray.scale;
			bounds(ijk.i,ijk.j,ijk.k, out);
			IF ~out  THEN	
				v:= blox[ijk.i,ijk.j,ijk.k];			
				IF (v#NIL) THEN
					ray.lxyz.x := ABS(xyz.x - ijk.i);  
					ray.lxyz.y := ABS(xyz.y - ijk.j);
					ray.lxyz.z := ABS(xyz.z - ijk.k);
					ray.bloxnorm:=bloxnorm[ijk.i,ijk.j,ijk.k];
					ray.popdelta.x:=0; 
					ray.popdelta.y:=0; 
					ray.popdelta.z:=0; 
					v.Shade(ray);	
					xyz.x := xyz.x + ray.popdelta.x;    
					xyz.y := xyz.y + ray.popdelta.y;
					xyz.z := xyz.z + ray.popdelta.z; 				
				END
			END; 
		UNTIL  ray.terminate OR out;
	END 
	END;
	ray.popdelta.x := (xyz.x-pushxyz.x)/M;
	ray.popdelta.y := (xyz.y-pushxyz.y)/M;
	ray.popdelta.z := (xyz.z-pushxyz.z)/M;
	ray.scale := ENTIER(ray.scale/M);
END Shade;

PROCEDURE probe(x,y,z: REAL):Voxel;
VAR
	X,Y,Z: REAL;
	i,j,k: LONGINT;
BEGIN
	XLTLBase.clamp3(x,y,z);
	X := x*M; Y := y*M; Z := z*M;
	i := ENTIER(X); 
	j := ENTIER(Y);
	k := ENTIER(Z);
	IF blox[i,j,k]#NIL THEN RETURN(blox[i,j,k].probe(X-i, Y-j, Z-k))
	ELSE RETURN(SELF)
	END;
END probe;

PROCEDURE passprobe(x,y,z: REAL):BOOLEAN;
VAR
	X,Y,Z: REAL;	
	i,j,k: LONGINT;
BEGIN
	XLTLBase.clamp3(x,y,z);
	X := x*M; Y := y*M; Z := z*M;
	i := ENTIER(X); 
	j := ENTIER(Y);
	k := ENTIER(Z);
	IF blox[i,j,k]#NIL THEN 
		RETURN(blox[i,j,k].passprobe(X-i, Y-j, Z-k)) 
	ELSE
		RETURN(passable)
	END
END passprobe;

PROCEDURE stroke*(p:PT; resolution:LONGINT; voxel:Voxel);
VAR
	i,j,k: LONGINT;
	c: cell;
	v:Voxel;
BEGIN
	XLTLBase.clamPT(p);
	IF TRUE OR ~lock  THEN strokerec(p,resolution,M,voxel) END 
END stroke;

PROCEDURE strokerec*(p:PT; resolution,scale:LONGINT; voxel:Voxel);
VAR
	i,j,k,nextscale: LONGINT;
	v:Voxel;
	c: cell;
BEGIN
	Out.Char('3');
	nextscale:=scale*M;
	p.x:=p.x*M;
	p.y:=p.y*M;
	p.z:=p.z*M;
	i := ENTIER(p.x); j := ENTIER(p.y); k := ENTIER(p.z);	
	p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
	IF nextscale>resolution THEN	
		blox[i,j,k]:=voxel	
	ELSIF blox[i,j,k]=NIL THEN		
		NEW(c);
		c.strokerec(p, resolution,nextscale,voxel);
		blox[i,j,k]:=c
	ELSIF ~(blox[i,j,k] IS cell) THEN
			NEW(c);
			c.imposter:=blox[i,j,k];	
			c.fill(c.imposter); 
			c.strokerec(p, resolution,nextscale,voxel);
			blox[i,j,k]:=c
	ELSE	
		v:=blox[i,j,k];
		WITH v:cell DO
			IF v.m#m THEN
				nextscale:=scale*c.m;
				p.x:=c.m*p.x/M;
				p.y:=c.m*p.y/M;
				p.z:=c.m*p.z/M;
				i := ENTIER(p.x); j := ENTIER(p.y); k := ENTIER(p.z);	
				p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
			END;
		v.strokerec(p, resolution,nextscale,voxel)
		END
	END
END strokerec;

PROCEDURE clear*(p:PT; level: LONGINT);
BEGIN
	IF  (level>=1) & XLTLBase.inzerodotdotonePT(p) THEN
		clearrec(p, level);
	END
END clear;

PROCEDURE clearrec(p:PT; level: LONGINT);
VAR
	i,j,k: LONGINT;
	v: Voxel;
BEGIN
	XLTLBase.clamPT(p);
	p.x:=p.x*M;
	p.y:=p.y*M;
	p.z:=p.z*M;
	i := ENTIER(p.x); j := ENTIER(p.y); k := ENTIER(p.z);
	IF level=1 THEN
		(* we're here. *)
		blox[i,j,k]:=NIL
	ELSE
		IF blox[i,j,k]#NIL THEN
			v:= blox[i,j,k];
			IF v IS MSV THEN WITH v:MSV DO v.clearrec(p,level-1) END END
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
		n := ENTIER(XLTLBase.distance(a,b)/delta);
		tx := b.x; ty := b.y; tz := b.z;
		dxdt := (a.x-b.x)/n; dydt := (a.y-b.y)/n; dzdt := (a.z-b.z)/n; 
		FOR t := 0 TO n DO
			XLTLBase.setPT(p,tx, ty, tz);
			stroke(p, level,v);
			tx := tx + dxdt; ty := ty + dydt; tz := tz+dzdt;
		END		
	END
END line;

PROCEDURE FRasterrec(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT); (*origin is always in world space*)
VAR
	i,j,k: INTEGER;
	o,p:PT;
	d2s,MS, MS2,TWOMS,CRDS,CRDNS, scaleciprocal:REAL;
	nextscale: LONGINT;
	v: Voxel;
	normal:PT;
	newcell: cell; 
BEGIN
	MS:=M*scale;
	TWOMS:=2*MS;
	MS2:=TWOMS;
	scaleciprocal:=1/scale;
	nextscale:=scale*M;
	CRDS:=CUBERADIUS/scale;
	CRDNS:=CUBERADIUS/nextscale;
	IF nextscale<resolution THEN 
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS; (*world coordinates*)
			d2s:=f.d2s(p);
			IF ABS(d2s) < CRDS THEN				
				o.x:=p.x-1/TWOMS; o.y:=p.y-1/TWOMS; o.z:=p.z-1/TWOMS; (* p is center, o is center *)
				IF blox[i,j,k]=NIL THEN 
					NEW(newcell);
					blox[i,j,k]:=newcell;
					newcell.imposter:=f.getimposter(p);
					newcell.bloxnorm[i,j,k]:=f.normal(p);
					newcell.FRasterrec(f,resolution,o,nextscale);
				ELSE
				 	v:=blox[i,j,k];  (* compiler disallows type tests and guards on array elements *)
				 	IF v IS XLTLBase.MSV  THEN
				 		WITH v:XLTLBase.MSV  DO
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
			IF ABS(d2s)<CRDS THEN 
				v:=f.voxel(p);
				IF v#NIL THEN 
					IF v IS XLTLBase.MSV  THEN v:=v.clone() END;
					blox[i,j,k]:=v
				END;
			END; 	
		END END END
	END; 
END FRasterrec;

PROCEDURE FRasterrecSolid(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT); (*origin is always in world space*)
VAR
	i,j,k: INTEGER;
	o,p:PT;
	d2s,MS,MS2,TWOMS,CRDS,CRDNS,scaleciprocal:REAL;
	nextscale: LONGINT;
	v: Voxel;
	newcell: cell;
BEGIN
	MS:=M*scale;
	TWOMS:=2*MS;
	MS2:=TWOMS;
	nextscale:=scale*M;
	scaleciprocal:=1/scale;
	CRDS:=CUBERADIUS/scale;
	CRDNS:=CUBERADIUS/nextscale;
	IF nextscale<resolution THEN 
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS; (*world coordinates*)
			d2s:=f.d2s(p);
			IF d2s < 0 THEN 
				IF ABS(d2s) > CRDNS THEN	 (* inside solid *)
					blox[i,j,k]:=f.voxel(p)
				ELSE   					(* at surface *)				
					o.x:=p.x-1/TWOMS; o.y:=p.y-1/TWOMS; o.z:=p.z-1/TWOMS; (* p is center, o is center *)
					IF blox[i,j,k]=NIL THEN
						NEW(newcell);
						blox[i,j,k]:=newcell;
						newcell.imposter:=f.getimposter(p);
						newcell.bloxnorm[i,j,k]:=f.normal(p);
						newcell.FRasterrecSolid(f,resolution,o,nextscale);
					ELSE
					 	v:=blox[i,j,k];  (* compiler disallows type tests and guards on array elements *)
					 	IF v IS XLTLBase.MSV  THEN
					 		WITH v: XLTLBase.MSV DO
					 			v.FRasterrecSolid(f,resolution,o,nextscale);
					 		END
					 	END
					 END
				 END
			END	
		END END END
	ELSE
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS;
			d2s:=f.d2s(p);		
			IF ABS(d2s)<CRDS THEN 
				v:=f.voxel(p);
				IF v#NIL THEN 
					IF v IS XLTLBase.MSV  THEN v:=v.clone()  END;
					blox[i,j,k]:=v
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
	FOR i:=0 TO MMO DO
		FOR j := 0 TO MMO DO
			FOR k := 0 TO MMO DO
				IF blox[i,j,k] # NIL THEN 
					c.blox[i,j,k] := blox[i,j,k].clone(); 
				END
			END
		END
	END;	
	RETURN(c)
END copy;

PROCEDURE deepclone*():Voxel;
VAR	
	c:cell;
	child:Voxel;
	i,j,k: INTEGER;
BEGIN
	copymarker:=TRUE;
	NEW(c);
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		child:=blox[i,j,k]; 
		IF (child#NIL)&~child.copymarker THEN
			c.blox[i,j,k]:=child.clone();
		END
	END END END;	
	copyclear;
	RETURN(c)
END deepclone;

PROCEDURE split;
BEGIN
END split;

END cell;

END XLTLM2Space.




