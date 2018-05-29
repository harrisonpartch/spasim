MODULE NM4; (*! This module may be either imported or used anonymously *)
IMPORT Objects, Base, SPSME, Noise, Math, TexVox, Out := KernelLog, Debugging, Streams,Strings;

(*
Special voxel containing 27 children arranged in a 3x3x3 grid.
Some shapes e.g. sierpinski cubes can only be represented on a 3^n grid.
*)

CONST M=4; (* defines grid size *)
	MMO=M-1;
	CUBERADIUS=0.866025;   (*change to sqrt(3)/2 ???*)
	NCODE="NM4";
	NL=Base.NL;

TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Path = Base.Path;
	Voxel = Base.Voxel;
	FR = Base.FR;
	Name = Base.Name;
 	NCube=Base.NCube;
 	LCube=Base.LightCube;

TYPE cell* = OBJECT(Voxel);
VAR
	nposterTF*:BOOLEAN;
	nposter*: NCube;
	blox*: ARRAY M,M,M OF Voxel;
	nbloxTF*: ARRAY M,M,M OF BOOLEAN;
	nblox*: ARRAY M,M,M OF NCube;
	deepcopyofme:cell;

PROCEDURE Shade(VAR ray: Ray);
VAR
	pushxyz, newxyz, xyz: Base.PT;
	ijk: Base.IPT;
	drx, dry, drz, dr,rr,gr,br,blr,bla: REAL;
	out,shadenil,A,B,C: BOOLEAN;
	v: Voxel;
	vdepth, blainv: REAL;
	last:BOOLEAN;
	i,j: LONGINT;
	patchray,pray: Ray;
	patchdx, patchdy: PT;
	patchradiusx, patchradiusy: REAL;
	lastlength:REAL;
BEGIN
	patchray:=ray;
	ray.lastlxyz:=ray.lxyz;
	ray.scale := ray.scale*M;
	xyz.x := ABS(ray.lxyz.x-offset.x) * M;
	xyz.y := ABS(ray.lxyz.y-offset.y) * M;
	xyz.z := ABS(ray.lxyz.z-offset.z)* M;
	pushxyz:=xyz;
	IF (ray.length*ray.scale>ray.dtl) THEN
		ray.terminate:=TRUE;
		ray.clr.r:=1;
		(*IF imposter#NIL THEN
			imposter.Shade(ray);
		ELSIF nposterTF THEN
			ray.normalTF:=TRUE;
			ray.normal:=nposter.normal;
			nshade(nposter,ray);
		END;*)
	ELSE
		SPSME.E(xyz,ijk);
		bounds(ijk.i,ijk.j,ijk.k,out);
		IF ~out THEN
			v:= blox[ijk.i,ijk.j,ijk.k];
			IF (v#NIL) THEN
				ray.lxyz.x := ABS(xyz.x - ijk.i);
				ray.lxyz.y := ABS(xyz.y - ijk.j);
				ray.lxyz.z := ABS(xyz.z - ijk.k);
				ray.popdelta := Base.Origin;
				ray.normal:=nblox[ijk.i,ijk.j,ijk.k].normal;
				v.Shade(ray);
				xyz.x := xyz.x + ray.popdelta.x;
				xyz.y := xyz.y + ray.popdelta.y;
				xyz.z := xyz.z + ray.popdelta.z;
			ELSIF nbloxTF[ijk.i,ijk.j,ijk.k] THEN
				nshade(nblox[ijk.i,ijk.j,ijk.k],ray);
			END;
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
					ray.face := 0; ray.fnormal:= Base.Face[0]
				ELSE
					INC(ijk.i, -1);
					ray.face := 3; ray.fnormal:= Base.Face[3]
				END;
				newxyz.x := xyz.x + drx * ray.dxyz.x; newxyz.y := xyz.y + drx * ray.dxyz.y; newxyz.z  := xyz.z + drx * ray.dxyz.z
			ELSIF A&~B THEN
				dr := drz;
				IF ray.dk THEN
					INC(ijk.k, 1);
					ray.face := 2; ray.fnormal:= Base.Face[2]
				ELSE
					INC(ijk.k, -1);
					ray.face := 5; ray.fnormal:= Base.Face[5]
				END;
				newxyz.x := xyz.x + drz * ray.dxyz.x; newxyz.y := xyz.y + drz * ray.dxyz.y; newxyz.z  := xyz.z + drz * ray.dxyz.z
			ELSIF C THEN
				dr := dry;
				IF ray.dj THEN
					INC(ijk.j, 1);
					ray.face := 1; ray.fnormal:= Base.Face[1]
				ELSE
					INC(ijk.j, -1);
					ray.face := 4; ray.fnormal:= Base.Face[4]
				END;
				newxyz.x := xyz.x + dry * ray.dxyz.x; newxyz.y := xyz.y + dry * ray.dxyz.y; newxyz.z  := xyz.z+ dry * ray.dxyz.z
			ELSE
				dr := drz;
				IF ray.dk  THEN
					INC(ijk.k, 1);
					ray.face := 2; ray.fnormal:= Base.Face[2]
				ELSE
					INC(ijk.k, -1);
					ray.face := 5; ray.fnormal:= Base.Face[5]
				END;
				newxyz.x := xyz.x + drz * ray.dxyz.x; newxyz.y := xyz.y + drz * ray.dxyz.y; newxyz.z  := xyz.z + drz * ray.dxyz.z
			END;
			vdepth:=Base.distance(newxyz,xyz)/ray.scale;
			ray.xyz.x:=ray.xyz.x +(newxyz.x-xyz.x)/ray.scale;
			ray.xyz.y:=ray.xyz.y +(newxyz.y-xyz.y)/ray.scale;
			ray.xyz.z:=ray.xyz.z +(newxyz.z-xyz.z)/ray.scale;
			xyz:=newxyz;
			ray.hitxyz:=ray.xyz;
			ray.length:=ray.length+vdepth;
			blr:=black*vdepth;
			blainv:=1-blr;	
			rr := red*vdepth*ray.clr.ra;
			gr := green*vdepth*ray.clr.ga;
			br := blue*vdepth*ray.clr.ba;
			ray.clr.r := ray.clr.r+rr;
			ray.clr.g:= ray.clr.g+gr;
			ray.clr.b := ray.clr.b+br;
			ray.clr.ra := (ray.clr.ra-(rr+blr));
			ray.clr.ga := (ray.clr.ga-(gr+blr));
			ray.clr.ba := (ray.clr.ba-(br+blr));
			ray.clr.alpha:=ray.clr.alpha-blr;
			IF (ray.clr.alpha<0.1) OR (ray.clr.ra<0.1) OR (ray.clr.ga<0.1) OR (ray.clr.ba<0.1)  THEN ray.terminate:=TRUE; out:=TRUE END;
			bounds(ijk.i,ijk.j,ijk.k, out);
			IF ~out THEN
				v := blox[ijk.i,ijk.j,ijk.k];
				IF (v#NIL) THEN
					ray.lxyz.x := ABS(xyz.x - ijk.i);
					ray.lxyz.y := ABS(xyz.y - ijk.j);
					ray.lxyz.z := ABS(xyz.z - ijk.k);
					ray.popdelta := Base.Origin; (* because many shaders don't set it *)
					ray.normal:=nblox[ijk.i,ijk.j,ijk.k].normal;
					v.Shade(ray);
					xyz.x := xyz.x + ray.popdelta.x;
					xyz.y := xyz.y + ray.popdelta.y;
					xyz.z := xyz.z + ray.popdelta.z;
				ELSIF nbloxTF[ijk.i,ijk.j,ijk.k] THEN
					nshade(nblox[ijk.i,ijk.j,ijk.k],ray);
				END
			END;
		UNTIL out OR ray.terminate;
	END;
	ray.popdelta.x := (xyz.x-pushxyz.x)/M;
	ray.popdelta.y := (xyz.y-pushxyz.y)/M;
	ray.popdelta.z := (xyz.z-pushxyz.z)/M;
	ray.scale := ray.scale/M;
END Shade;

PROCEDURE nshade(nc: NCube; VAR ray: Ray);
VAR
	dr,dg,db,mix,dot,dot1,dot2: REAL;
	light: Base.Light;
BEGIN
	IF texture#NIL THEN
		texture.Shade(ray)
	ELSE
		dot1:= ABS(nc.normal.x*ray.dxyz.x + nc.normal.y*ray.dxyz.y+ nc.normal.z*ray.dxyz.z);
		dot2:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
		mix:=ray.length*ray.scale/10;
		IF mix>1 THEN mix:=1 END;
		dot:=mix*dot1+(1-mix)*dot2;
		ray.clr.r := ray.clr.r + nc.color.red * ray.clr.ra*dot;
		ray.clr.g := ray.clr.g + nc.color.green * ray.clr.ga*dot;
		ray.clr.b := ray.clr.b + nc.color.blue * ray.clr.ba*dot;
		ray.terminate:=TRUE
	END
END nshade;

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
	INC(ray.mirrors);
	IF ray.mirrors<4 THEN reflect(ray.dxyz, ray.normal) END;
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END;
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;
	ray.popdelta.x:=ray.dxyz.x*3.0;
	ray.popdelta.y:=ray.dxyz.z*3.0;
	ray.popdelta.z:=ray.dxyz.z*3.0;
END mirror;

PROCEDURE tick*;
BEGIN
END tick;

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
		IF Base.rand.Uniform()<p THEN blox[i,j,k] := v END
	END END END
END fillwithprobability;

PROCEDURE fillchequer*(v,w: Voxel);
VAR
	i,j,k: INTEGER;
BEGIN
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		IF ODD(i+j+k) THEN blox[i,j,k] := v ELSE blox[i,j,k] := w END
	END END END
END fillchequer;

PROCEDURE fillsierp*(v,w: Voxel);
VAR
	i,j,k: INTEGER;
BEGIN
	fill(v);
	blox[1,1,0]:=w;
	blox[0,1,1]:=w;
	blox[1,0,1]:=w;
	blox[1,1,1]:=w;

	blox[1,1,2]:=w;
	blox[2,1,1]:=w;
	blox[1,2,1]:=w;
	
END fillsierp;

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

PROCEDURE & init*;
BEGIN
	passable:=TRUE;
	complex:=TRUE;
	imposter:=Base.EMPTY;
	code:=NCODE;
	ncode:=NCODE
END init;

PROCEDURE copyclear*;
VAR
	child:Voxel;
	i,j,k: INTEGER;
BEGIN
	copymarker:=FALSE;
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		IF (blox[i,j,k]#NIL) & blox[i,j,k].copymarker THEN
			blox[i,j,k].copyclear
		END
	END END END;
END copyclear;

PROCEDURE setcolor* (r,g,b,bl,a: REAL);
VAR
	i,j,k: INTEGER;
BEGIN
	copyclear;
	setcolorrec(r,g,b,bl,a)
END setcolor;

PROCEDURE setcolorrec(r,g,b,bl,a: REAL);
VAR
	v: Voxel;
	i,j,k: INTEGER;
BEGIN
	IF ~copymarker THEN
		copymarker:=TRUE;
		red:= r;
		green := g;
		blue := b;
		black:= bl;
		alpha:=a;
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			v:=blox[i,j,k];
			IF v#NIL THEN
				IF v IS cell THEN
					IF v.code=code THEN
						WITH v: cell DO
							v.setcolorrec(r,g,b,bl,a);
						END
					END
				END
			END
		END END END;
		copymarker:=FALSE
	END
END setcolorrec;

PROCEDURE bounds*(i, j, k: LONGINT; VAR out: BOOLEAN);
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
		blox[i,j,k] := v
	END END END
END fill;

PROCEDURE probe(p:PT; resolution:LONGINT):Voxel;
VAR
	X,Y,Z: REAL;
	i,j,k: LONGINT;
BEGIN
	IF probelock THEN RETURN SELF END;
	RETURN proberec(p,resolution,1);
END probe;

PROCEDURE proberec(p:PT; resolution,scale:LONGINT):Voxel;
VAR
	X,Y,Z: REAL;
	v: Voxel;
	i,j,k: LONGINT;
	newscale: LONGINT;
BEGIN
	Base.clamPT(p);
	newscale:=scale*M;
	X := p.x*M; Y := p.y*M; Z := p.z*M;
	i := ENTIER(X);
	j := ENTIER(Y);
	k := ENTIER(Z);
	p.x:=X-i; p.y:=Y-j; p.z:=Z-k;
	v:=blox[i,j,k];
	IF scale>=resolution THEN
		(* v.touch; *)
		RETURN(v)
	ELSIF  (v#NIL) & (v IS cell) THEN
		WITH v:cell  DO
			RETURN(v.proberec(p,resolution,newscale))
		END
	ELSE RETURN(v)
	END;
END proberec;

PROCEDURE passprobe(p:PT):BOOLEAN;
VAR
	X,Y,Z: REAL;
	i,j,k: LONGINT;
BEGIN
	IF ~passable THEN RETURN FALSE END;
	Base.clamPT(p);
	X := p.x*M; Y := p.y*M; Z := p.z*M;
	i := ENTIER(X);
	j := ENTIER(Y);
	k := ENTIER(Z);
	IF blox[i,j,k]=NIL THEN
		RETURN ~nbloxTF[i,j,k]
	ELSE
		RETURN(blox[i,j,k].passprobe(Base.mkPT(X-i, Y-j, Z-k)))
	END
END passprobe;

PROCEDURE copyprime;
BEGIN
	copyonstroke:=TRUE;
	copyengine.add(SELF);	
END copyprime;

PROCEDURE stroke*(p:PT; resolution: LONGINT; voxel :Voxel);
VAR
	i,j,k: LONGINT;
BEGIN
	Base.clamPT(p);
	IF voxel#NIL THEN
		strokerec(p,resolution,1, voxel);
	END
END stroke;

PROCEDURE nstroke(p:PT; resolution:LONGINT; normal:PT; color: Color);
VAR
	i,j,k: LONGINT;
BEGIN
	Base.clamPT(p);
	color.alpha:=1;
	nstrokerec(p,resolution,1,normal,color);
END nstroke;

PROCEDURE strokerec*(p:PT; resolution,scale: LONGINT; voxel :Voxel);
VAR
	i,j,k,ii,jj,kk,nextscale: LONGINT;
	v,vv:Voxel;
	c,c2: cell;
	copyv,vu: Voxel;
	code: Base.Name;
BEGIN
	IF ~lockTF THEN
		code:=NCODE; (* if this cell was born from a name, it is changed now and will be engrained accordingly *)
		nextscale:=scale*M;
		p.x:=p.x*M;
		p.y:=p.y*M;
		p.z:=p.z*M;
		i := ENTIER(p.x)MOD M; j := ENTIER(p.y)MOD M; k := ENTIER(p.z)MOD M;
		IF nextscale>resolution THEN
			blox[i,j,k]:=voxel
		ELSE
			IF blox[i,j,k]#NIL THEN
				IF  blox[i,j,k].copyonstroke THEN
					copyv:= blox[i,j,k].deepcopyofme;
					IF (copyv#NIL) & (copyv.baked) THEN
						copyv.strokerec(p, resolution,nextscale,voxel);
						copyengine.add(blox[i,j,k]);
						blox[i,j,k]:=copyv	
					END	
				ELSIF blox[i,j,k].complex THEN
					blox[i,j,k].strokerec(p, resolution,nextscale,voxel)
				ELSE
					NEW(c);
					c.red:=red; c.blue:=blue; c.green:=green; c.black:=black; 
					c.fill(blox[i,j,k]);
					blox[i,j,k]:=c;
					p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
					c.strokerec(p, resolution,nextscale, voxel);
				END
			ELSE
				NEW(c);
				blox[i,j,k]:=c;
				p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
				c.strokerec(p, resolution,nextscale, voxel);
			END
		END
	END
END strokerec;

PROCEDURE strokephemeralrec(p:PT; resolution,scale:LONGINT; voxel,voxundo:Voxel);
VAR
	i,j,k,ii,jj,kk,nextscale: LONGINT;
	v,vv:Voxel;
	c,c2: cell;
	copy,vu: Voxel;
	code: Base.Name;
	path: Path;
BEGIN
	IF ~lockTF THEN
		nextscale:=scale*M;
		p.x:=p.x*M;
		p.y:=p.y*M;
		p.z:=p.z*M;
		i := ENTIER(p.x)MOD M; j := ENTIER(p.y)MOD M; k := ENTIER(p.z)MOD M;
		IF nextscale>resolution THEN
			blox[i,j,k]:=voxel
		ELSE
			IF blox[i,j,k]#NIL THEN
				IF blox[i,j,k].complex THEN
					blox[i,j,k].strokephemeralrec(p, resolution,nextscale,voxel,vu)
				ELSE
					NEW(c);
					c.fill(blox[i,j,k]);
					c.passable:=blox[i,j,k].passable;
					blox[i,j,k]:=c;
					p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
					c.strokerec(p, resolution,nextscale, voxel);
				END
			ELSE
				NEW(c);
				blox[i,j,k]:=c;
				p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
				c.strokerec(p, resolution,nextscale, voxel);
			END
		END
	END
END strokephemeralrec;

PROCEDURE nstrokerec(p:PT; resolution,scale:LONGINT; normal:PT; color: Color);
VAR
	i,j,k,ii,jj,kk,nextscale: LONGINT;
	v:Voxel;
	c,c2: cell;
	smallcopy: Voxel;
BEGIN
	IF ~lockTF THEN
		nextscale:=scale*M;
		p.x:=p.x*M;
		p.y:=p.y*M;
		p.z:=p.z*M;
		i := ENTIER(p.x)MOD M; j := ENTIER(p.y)MOD M; k := ENTIER(p.z)MOD M;
		IF nextscale>resolution THEN
			IF ~((blox[i,j,k]#NIL) &  blox[i,j,k].lockTF) THEN
				nblox[i,j,k].normal:= normal;
				nblox[i,j,k].color:= color;
			END
		ELSE
			IF blox[i,j,k]#NIL THEN
				IF (blox[i,j,k] IS cell) THEN
					v:=blox[i,j,k];
					WITH v: cell DO v.nstrokerec(p, resolution,nextscale,normal,color) END
				ELSIF (blox[i,j,k] IS Voxel) THEN
					blox[i,j,k].nstroke(p, resolution DIV nextscale,normal,color)
				ELSE
					NEW(c);
					c.setcolor(red,green,blue,black,alpha);
					c.imposter:=blox[i,j,k];
					IF blox[i,j,k].emptysplit THEN
						FOR ii := 0 TO MMO DO FOR jj := 0 TO MMO DO FOR kk:= 0 TO MMO DO
							NEW(c2);
							blox[i,j,k]:=c2
						END END END;
					ELSE
						c.fill(blox[i,j,k])
					END;
					blox[i,j,k]:=c;
					p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
					c.nstrokerec(p, resolution,nextscale,normal,color);
				END
			ELSE
				NEW(c);
				c.setcolor(red,green,blue,black,alpha);
				blox[i,j,k]:=c;
				p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
				c.nstrokerec(p, resolution,nextscale,normal,color);
			END
		END
	END
END nstrokerec;

PROCEDURE line*(a,b: PT; resolution: LONGINT; v: Voxel);
VAR
	tx,ty,tz, dxdt, dydt, dzdt: REAL;
	t: LONGINT;
	delta: REAL;
	n: LONGINT;
	p: PT;
	path: Path;
	vu: Voxel
BEGIN
	n := ENTIER(Base.distance(a,b)*resolution*M);
	IF n > 0 THEN
		tx := b.x; ty := b.y; tz := b.z;;
		dxdt := (a.x-b.x)/n; dydt := (a.y-b.y)/n; dzdt := (a.z-b.z)/n;
		FOR t := 0 TO n DO
			Base.setPT(p,tx, ty, tz);
			stroke(p, resolution, v);
			tx := tx + dxdt; ty := ty + dydt; tz := tz+dzdt;
		END
	END
END line;

PROCEDURE FRaster*( f: FR; resolution: LONGINT);
VAR
	origin: PT;
BEGIN
	origin.x:=0; origin.y:=0; origin.z:=0;
	FRasterrec(f,resolution,origin,1);   (* origin is (0,0,0) *)
END FRaster;

PROCEDURE FRasterrec(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT); (*origin is always in world space*)
VAR
	i,j,k: INTEGER;
	o,p:PT;
	d2s,MS,TWOMS,CRDS,CRDNS:REAL;
	nextscale: LONGINT;
	v: Voxel;
	newcell: cell;
BEGIN
	code:=NCODE; (* if this cell was born from a name, it is changed now and will be engrained accordingly *)
	MS:=M*scale;
	TWOMS:=2*MS;
	nextscale:=scale*M;
	CRDS:=CUBERADIUS/scale;
	CRDNS:=CUBERADIUS/nextscale;
	IF nextscale<=resolution THEN
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS; (*world coordinates*)
			d2s:=f.d2s(p);
			IF ABS(d2s) < CRDNS THEN
				o.x:=p.x-1/TWOMS; o.y:=p.y-1/TWOMS; o.z:=p.z-1/TWOMS; (* p is center, o is corner *)
				IF blox[i,j,k]=NIL THEN
					NEW(newcell);
					newcell.setcolor(red,green,blue,black,alpha);
					blox[i,j,k]:=newcell;
					IF f.normaltf(p) THEN
						newcell.nposterTF:=TRUE;
						newcell.nposter.normal:=f.normal(p)
					END;
					newcell.nposter.color:=f.color(p);
					newcell.imposter:=f.getimposter(p);
					newcell.FRasterrec(f,resolution,o,nextscale);
				ELSE
				 	v:=blox[i,j,k];
				 	IF v IS cell THEN
				 		WITH v:cell DO
				 			v.imposter:=f.voxel(p);
							v.nposterTF:=TRUE;
							v.nposter.normal:=f.normal(p);
							v.nposter.color:=f.color(p);
							v.FRasterrec(f,resolution,o,nextscale)
				 		END
				 	END
				 END
			END
		END END END
	ELSE
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS;
			d2s:=f.d2s(p);
			IF ABS(d2s) < CRDNS THEN
				nbloxTF[i,j,k]:=TRUE;
				nblox[i,j,k].color:=f.color(p);
				nblox[i,j,k].normal:=f.normal(p);
				blox[i,j,k]:=f.voxel(p);
			END
		END END END
	END
END FRasterrec;

PROCEDURE FRasterSolid*( f: FR; resolution: LONGINT);
VAR
	origin: PT;
BEGIN
	origin.x:=0; origin.y:=0; origin.z:=0;
	SFRasterrec(f,resolution,origin,1);   (* origin is (0,0,0) *)
END FRasterSolid;

PROCEDURE SFRasterrec(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT);
VAR
	i,j,k,ii,jj,kk: INTEGER;
	o,p:PT;
	d2s,MS,TWOMS,CRDS,CRDNS:REAL;
	nextscale: LONGINT;
	v: Voxel;
	newcell: cell;
	solidmarker: BOOLEAN;
BEGIN
	MS:=M*scale;
	TWOMS:=2*MS;
	nextscale:=scale*M;
	CRDS:=CUBERADIUS/scale;
	CRDNS:=CUBERADIUS/nextscale;
	IF nextscale<=resolution THEN
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			solidmarker:=FALSE;
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS; (*world coordinates*)
			d2s:=f.d2s(p);
			IF ABS(d2s)<CRDS THEN  (* at surface *)
				o.x:=p.x-1/TWOMS; o.y:=p.y-1/TWOMS; o.z:=p.z-1/TWOMS; (* p is center, o is corner *)
				IF blox[i,j,k]=NIL THEN
					NEW(newcell);
					newcell.setcolor(red,green,blue,black,alpha);
					newcell.imposter:=f.voxel(p);
					newcell.nposterTF:=TRUE;
					newcell.nposter.normal:=f.normal(p);
					newcell.nposter.color:=f.color(p);
					newcell.SFRasterrec(f,resolution,o,nextscale);
					blox[i,j,k]:=newcell				
				ELSE
				 	v:=blox[i,j,k];
				 	IF v IS cell THEN
				 		WITH v:cell DO
				 			v.imposter:=f.voxel(p);
							v.nposterTF:=TRUE;
							v.nposter.normal:=f.normal(p);
							v.nposter.color:=f.color(p);
							v.SFRasterrec(f,resolution,o,nextscale)
				 		END
				 	END
				 END
			ELSIF d2s<0 THEN
				nbloxTF[i,j,k]:=TRUE;
				nblox[i,j,k].color:=f.color(p);
				nblox[i,j,k].normal:=f.normal(p);
				blox[i,j,k]:=f.voxel(p);
			END
		END END END
	ELSE
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS;
			d2s:=f.d2s(p);
			IF ABS(d2s) < CRDNS THEN
				nbloxTF[i,j,k]:=TRUE;
				nblox[i,j,k].color:=f.color(p);
				nblox[i,j,k].normal:=f.normal(p);
				blox[i,j,k]:=f.voxel(p);
			END
		END END END
	END;
END SFRasterrec;

PROCEDURE copy():Voxel;
VAR c: cell;
	i,j,k: INTEGER;
BEGIN
	NEW(c);
	c.setcolor(red,green,blue,black,alpha);
	c.nbloxTF:=nbloxTF;
	c.nblox:=nblox;
	c.passable:=passable;
	FOR i:=0 TO MMO DO
		FOR j := 0 TO MMO DO
			FOR k := 0 TO MMO DO
				IF blox[i,j,k] # NIL THEN
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
	cv,child:Voxel;
	i,j,k: INTEGER;
BEGIN
	copymarker:=TRUE;
	NEW(c);
	c.red:=red; c.green:=green; c.blue:=blue; c.black:=black; 
	c.nbloxTF:=nbloxTF;
	c.nblox:=nblox;
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		child:=blox[i,j,k];
		IF (child#NIL) THEN
			IF ~child.copymarker  & ~child.copyonstroke THEN
				 c.blox[i,j,k]:=child.deepcopy();
			ELSE
				c.blox[i,j,k]:=child
			END
		END
	END END END;
	copymarker:=FALSE;
	c.baked:=TRUE; (* baked means done copying *)
	RETURN c
END deepcopy;

PROCEDURE count*(level: INTEGER):LONGINT;
VAR
	c: LONGINT;
	i,j,k:INTEGER;
BEGIN
	c:=1;
	IF level>1 THEN
		FOR i:=0 TO MMO DO
			FOR j:=0 TO MMO DO
				FOR k:=0 TO MMO DO
					IF (blox[i,j,k]#NIL) THEN c:=c+blox[i,j,k].count(level-1)
					END
				END
			END
		END
	END;
RETURN c
END count;

(*
Engrains this voxel and it's children recursively in the following format:
"NM4"|red|green|blue|TRUE|child0.engrain|FALSE|TRUE|child1.engrain|....
<----- Voxel data -----><------                     children data                     ------>
Children data contains 27 boolean-child pairs, each boolean being TRUE if a child is contained in that position.
In case of FALSE the length of child data is 0 for that child (i.e. no data is being written except for the FALSE).
Child data is engrained by the child itself.

Note that children can be composite voxels containing children allowing an infinitely large tree where the
deeper a voxel is the smaller it is compared to the world voxel.
*)
PROCEDURE engrain(w: Streams.Writer);
VAR
	i,j,k: INTEGER;
BEGIN
(* copymarker code removed: this will not terminate [ie it WILL trap] if the cell is recursive *)
	IF code=NCODE THEN
		IF TRUE THEN
			w.Bytes(code,0,NL);
			w.RawReal(red);
			w.RawReal(green);
			w.RawReal(blue);
			w.RawReal(black);
			FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
					IF (blox[i,j,k]#NIL) THEN
						w.RawBool(TRUE);
						blox[i,j,k].engrain(w)
					ELSE
						w.RawBool(FALSE);
					END
			END END END
		END
	END;
END engrain;

(*
Sprouts the voxel and it's children recursively using the inverse of the engrain procedure.
*)
PROCEDURE sprout(r: Streams.Reader);
VAR
	i,j,k: INTEGER;
	b: BOOLEAN;
	name: Name;
	anothercell: cell;
	len: LONGINT;
BEGIN
		r.RawReal(red);
		r.RawReal(green);
		r.RawReal(blue);
		r.RawReal(black);
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			r.RawBool(b);
			IF b THEN
				r.Bytes(name,0,NL,len);
				blox[i,j,k]:=Base.VoxelFromName(name);
				IF blox[i,j,k]#NIL THEN blox[i,j,k].sprout(r) END
			END;
		END END END
END sprout;

END cell;

TYPE CopyEngine = OBJECT(Base.V);
VAR
	tobecopied: Voxel;	
	COPYGO:BOOLEAN;
PROCEDURE add(CONST v:Voxel);
BEGIN
	tobecopied:=v;
	go
END add;
PROCEDURE go;
BEGIN
	BEGIN {EXCLUSIVE} COPYGO:=TRUE END;
END go;

BEGIN{ACTIVE, PRIORITY(Objects.Low)}
REPEAT
	Out.String("COPYENGINE");
	BEGIN {EXCLUSIVE} AWAIT(COPYGO) END;
	tobecopied.deepcopyofme:=tobecopied.deepcopy();
	Out.String("COPYENGINE");
	BEGIN {EXCLUSIVE} COPYGO:=FALSE END;
UNTIL FALSE
END CopyEngine;

VAR
	copyengine: CopyEngine;

PROCEDURE thisvox*():Voxel;
VAR
	v: cell;
BEGIN
	NEW(v);
	RETURN v
END thisvox;

BEGIN
	NEW(copyengine)
END NM4.
