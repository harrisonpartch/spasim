MODULE NM10; (*! This module may be either imported or used anonymously *)
IMPORT Objects, Base, SPSME, Noise, Math:=MathL, TexVox, NM3, Out := KernelLog, Debugging, Heaps, Streams,Strings;

(*
Special voxel containing 1000 children arranged in a grid.
Some shapes e.g. sierpinski cubes can only be represented on a 3^n grid.
*)

CONST M*=10; (* defines grid size *)
	MMO=M-1;
	CUBERADIUS=0.866025;   (*change to sqrt(3)/2 ???*)
	NL=Base.NL;

TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Path = Base.Path;
	Voxel = Base.Voxel;
	Cell = Base.Cell;
	FR = Base.FR;
	Name = Base.Name;
 	NCube=Base.NCube;
 	RCube=Base.RCube;
 	LCube=Base.LightCube;

TYPE cell* = OBJECT(Cell);
VAR
	nposterTF*:BOOLEAN;
	nposter*: NCube;
	blox*: ARRAY M,M,M OF Voxel;
	nbloxTF*: ARRAY M,M,M OF BOOLEAN;
	nblox*: ARRAY M,M,M OF NCube;
	rbloxTF*: ARRAY M,M,M OF BOOLEAN;
	rblox*: ARRAY M,M,M OF RCube;	
	deepcopyofme:cell;

PROCEDURE Shade(VAR ray: Ray);
VAR
	pushxyz, newxyz, xyz: Base.PT;
	ijk: Base.IPT;
	drx, dry, drz, dr,rr,gr,br,blr,bla,a: REAL;
	out,shadenil,A,B,C: BOOLEAN;
	v: Voxel;
	vdepth, v2, fog,f2: REAL;
	last:BOOLEAN;
	i,j: INTEGER;
	lastlength:REAL;
BEGIN
	IF (ray.length*ray.scale>Base.DTL) THEN (* size of the child voxels at camera *)
		IF imposter#NIL THEN
			imposter.Shade(ray)
		END
	ELSE
		ray.lighting := lighting;
		ray.scale := ray.scale*M;
		pushxyz:=ray.xyz;	
		xyz.x := (ray.lxyz.x) * M;
		xyz.y := (ray.lxyz.y) * M;
		xyz.z := (ray.lxyz.z)* M;
		SPSME.E(xyz,ijk);
		bounds(ijk.i,ijk.j,ijk.k,out);
		IF ~out THEN	
			v:= blox[ijk.i,ijk.j,ijk.k];	
			IF (v#NIL) THEN
				ray.justhit:=v;
				ray.lxyz.x := ABS(xyz.x - ijk.i);
				ray.lxyz.y := ABS(xyz.y - ijk.j);
				ray.lxyz.z := ABS(xyz.z - ijk.k);
				ray.normal := ray.fnormal;
				v.Shade(ray);
			ELSIF nbloxTF[ijk.i,ijk.j,ijk.k] THEN
				nshade(nblox[ijk.i,ijk.j,ijk.k],ray) 
			ELSIF rbloxTF[ijk.i,ijk.j,ijk.k] THEN
				rshade(rblox[ijk.i,ijk.j,ijk.k],ray) 	
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
				vdepth:=Base.distance(newxyz,xyz); 	
				v2:=vdepth/ray.scale;
				ray.xyz.x:=ray.xyz.x + (newxyz.x-xyz.x)/ray.scale;
				ray.xyz.y:=ray.xyz.y + (newxyz.y-xyz.y)/ray.scale;
				ray.xyz.z:=ray.xyz.z + (newxyz.z-xyz.z)/ray.scale;				
				ray.length:=ray.length+v2;
				v2:=vdepth; 
				ray.hitxyz:=ray.xyz;
				xyz:=newxyz;	
				ray.clr.r := ray.clr.r+red*ray.clr.ra*v2;
				ray.clr.g:= ray.clr.g+green*ray.clr.ga*v2;
				ray.clr.b := ray.clr.b+blue*ray.clr.ba*v2;		
				ray.clr.ra := ray.clr.ra-redblack*v2;
				ray.clr.ga := ray.clr.ga-greenblack*v2;
				ray.clr.ba := ray.clr.ba-blueblack*v2;	
				bounds(ijk.i,ijk.j,ijk.k, out);		
				IF ~(out OR ray.terminate) THEN				
						v := blox[ijk.i,ijk.j,ijk.k];
						IF (v#NIL) THEN
							ray.justhit:=v;
							ray.lxyz.x := ABS(xyz.x - ijk.i);
							ray.lxyz.y := ABS(xyz.y - ijk.j);
							ray.lxyz.z := ABS(xyz.z - ijk.k);
							IF nbloxTF[ijk.i,ijk.j,ijk.k] THEN 
								ray.normal := nblox[ijk.i,ijk.j,ijk.k].normal
							ELSE
								ray.normal := ray.fnormal;
							END;
							v.Shade(ray);
						ELSIF nbloxTF[ijk.i,ijk.j,ijk.k] THEN
							nshade(nblox[ijk.i,ijk.j,ijk.k],ray);
						ELSIF rbloxTF[ijk.i,ijk.j,ijk.k] THEN
							rshade(rblox[ijk.i,ijk.j,ijk.k],ray) 					
						END
					END;
				IF (ray.clr.ba<0.1) OR (ray.clr.ga<0.1) OR (ray.clr.ra<0.1) THEN 		
					ray.terminate:=TRUE 
				END;		
			UNTIL out OR ray.terminate;
		END;	
		ray.scale := ray.scale/M;	
		ray.xyz:=pushxyz;	
	END
END Shade;

PROCEDURE nshade(nc: NCube; VAR ray: Ray);

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
	mi:=0.1;
	ray.clr.ra:= ray.clr.ra - mi;
	ray.clr.ga := ray.clr.ga - mi;
	ray.clr.ba := ray.clr.ba - mi;	
	reflect(ray.dxyz, nc.normal);
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END;
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;
	ray.xyz.x:=ray.xyz.x+2*ray.dxyz.x/(ray.scale) ;
	ray.xyz.y:=ray.xyz.y+2*ray.dxyz.y/(ray.scale);	
	ray.xyz.z:=ray.xyz.z+2*ray.dxyz.z/(ray.scale);	
END mirror;

VAR
	dr,dg,db,mix,dot,dot1,dot2,mi,mir: REAL;
	A,B,C,exit: PT;
	a,b,c,depth: REAL;
	i:INTEGER;	
	red: REAL;
BEGIN
	dot1:= ABS(nc.normal.x*ray.dxyz.x + nc.normal.y*ray.dxyz.y+ nc.normal.z*ray.dxyz.z);
	dot2:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
	mix:=ray.length*ray.scale*0.015;
	IF mix>1 THEN mix:=1 END;
	dot:=mix*dot1+(1-mix)*dot2;		
	ray.clr.r := ray.clr.r + nc.color.red*ray.clr.ra*dot;
	ray.clr.g := ray.clr.g + nc.color.green * ray.clr.ga*dot;
	ray.clr.b := ray.clr.b + nc.color.blue * ray.clr.ba*dot;	
	ray.terminate:=TRUE
END nshade;

PROCEDURE rshade(rc: RCube; VAR ray: Ray);

END rshade;

PROCEDURE erase*(p:PT; resolution:INTEGER);
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
	code:="NM10";
	ncode:="NM10"
END init;

PROCEDURE copyclear*;
VAR
	child:Voxel;
	i,j,k: INTEGER;
BEGIN
	copymarker:=FALSE;
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		IF (blox[i,j,k]#NIL) THEN
			blox[i,j,k].copyclear
		END
	END END END;
END copyclear;

PROCEDURE setcolor* (r,g,b,rb,gb,bb: REAL);
VAR
	i,j,k: INTEGER;
BEGIN
(*	copyclear; this crashes recursive geometry *)
	colorlock:=TRUE;
	setcolorrec(r,g,b,rb,gb,bb)
END setcolor;

PROCEDURE setcolorrec(r,g,b,rb,gb,bb: REAL);
VAR
	v: Voxel;
	i,j,k: INTEGER;
BEGIN
	IF ~copymarker THEN
		copymarker:=TRUE;
		red:= r;
		green := g;
		blue := b;
		redblack := rb;
		greenblack:= gb;
		blueblack := bb;
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			v:=blox[i,j,k];
			IF (v#NIL) THEN
				v.setcolorrec(r,g,b,rb,gb,bb);
			END
		END END END;
		copymarker:=FALSE
	END
END setcolorrec;

PROCEDURE bounds*(i, j, k: INTEGER; VAR out: BOOLEAN);
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

PROCEDURE probe(p:PT; resolution:INTEGER):Voxel;
VAR
	X,Y,Z: REAL;
	i,j,k: INTEGER;
BEGIN
	IF probelock THEN RETURN SELF END;
	RETURN proberec(p,resolution,1);
END probe;

PROCEDURE proberec(p:PT; resolution,scale:INTEGER):Voxel;
VAR
	X,Y,Z: REAL;
	v: Voxel;
	i,j,k: INTEGER;
	newscale: INTEGER;
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
	ELSIF  (v#NIL) & (v IS Cell) THEN
		WITH v:Cell  DO
			RETURN(v.proberec(p,resolution,newscale))
		END
	ELSE RETURN(v)
	END;
END proberec;

PROCEDURE passprobe(p:PT):BOOLEAN;
VAR
	X,Y,Z: REAL;
	i,j,k: INTEGER;
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
END copyprime;

PROCEDURE stroke*(p:PT; res: INTEGER; voxel :Voxel);
VAR
	i,j,k: INTEGER;
BEGIN
	IF ~lockTF THEN
		Base.clamPT(p);
		IF voxel#NIL THEN
			strokerec(p,res,M, voxel);
		END
	END
END stroke;

PROCEDURE strokerec*(p:PT; resolution,scale: INTEGER; voxel :Voxel);
VAR
	i,j,k,ii,jj,kk,nextscale: INTEGER;
	v,vv:Voxel;
	c,c2: cell;
	copyv,vu: Voxel;
	code: Base.Name;
BEGIN
	IF ~lockTF THEN
		code:="NM10"; (* if this cell was born from a name, it is changed now and will be engrained accordingly *)
		nextscale:=scale*M;
		p.x:=p.x*M;
		p.y:=p.y*M;
		p.z:=p.z*M;
		i := ENTIER(p.x)MOD M; j := ENTIER(p.y)MOD M; k := ENTIER(p.z)MOD M;
		IF nextscale>resolution THEN
			voxel:= voxel.deepcopy();
			voxel.setcolor(red, green, blue, redblack, greenblack, blueblack); 
			voxel.lighting := voxel.lighting*0.9;
			blox[i,j,k]:=voxel;
		ELSE
			vu:=blox[i,j,k];
			IF vu#NIL THEN
				IF  vu.copyonstroke THEN
					copyv:= vu.deepcopy();
					IF copyv IS cell THEN
						copyv.strokerec(p, resolution,nextscale,voxel)
					END;
					blox[i,j,k]:=copyv;					
				ELSIF blox[i,j,k] IS Cell THEN
					blox[i,j,k].strokerec(p, resolution,nextscale,voxel)
				ELSE
					NEW(c);
					c.lighting := c.lighting*0.9;
					c.setcolor(red/M, green/M, blue/M, redblack/M, greenblack/M, blueblack/M); 
					c.fill(blox[i,j,k]);
					blox[i,j,k]:=c;
					p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
					c.strokerec(p, resolution,nextscale, voxel);
				END
			ELSE
				NEW(c);
				c.lighting := c.lighting*0.9;
				c.setcolor(red/M,green/M,blue/M,redblack/M,greenblack/M,blueblack/M); 
				blox[i,j,k]:=c;
				p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
				c.strokerec(p, resolution,nextscale, voxel);
			END
		END
	END
END strokerec;

PROCEDURE line*(a,b: PT; resolution: INTEGER; v: Voxel);
VAR
	tx,ty,tz, dxdt, dydt, dzdt: REAL;
	t: INTEGER;
	delta: REAL;
	n: INTEGER;
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

PROCEDURE FRaster*( f: FR; resolution: INTEGER);
VAR
	origin: PT;
BEGIN
	origin.x:=0; origin.y:=0; origin.z:=0;
	IF f#NIL THEN
		FRasterrec(f,resolution,origin,1)
	END;  (* origin is (0,0,0) *)
END FRaster;

PROCEDURE FRasterrec(f: FR; resolution: INTEGER; origin: PT; scale: INTEGER); (*origin is always in world space*)
VAR
	i,j,k: INTEGER;
	o,p:PT;
	d2s,MS,TWOMS,CRDS,CRDNS:REAL;
	nextscale: INTEGER;
	v: Voxel;
	newcell: cell;
BEGIN
	code:="NM10"; (* if this cell was born from a name, it is changed now and will be engrained accordingly *)
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
					newcell.setcolor(red/M,green/M,blue/M, redblack/M,greenblack/M,blueblack/M);
					blox[i,j,k]:=newcell;
					IF f.normaltf(p) THEN
						newcell.nposterTF:=TRUE;
						newcell.nposter.normal:=f.getnormal(p)
					END;
					newcell.nposter.color:=f.color(p);
					newcell.imposter:=f.getimposter(p);
					newcell.FRasterrec(f,resolution,o,nextscale);
				ELSE
				 	v:=blox[i,j,k];
				 	IF v IS cell THEN
				 		WITH v:cell DO
				 			v.imposter:=f.getimposter(p);
							v.nposterTF:=TRUE;
							v.nposter.normal:=f.getnormal(p);
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
				v:=f.voxel(p);
				IF v=NIL THEN
					IF f.strokeTF(p) THEN
						nbloxTF[i,j,k]:=TRUE;	
						nblox[i,j,k].normal:=f.getnormal(p);
						IF d2s<0 THEN
							nblox[i,j,k].color:=f.getcolor(p);
						ELSE
							nblox[i,j,k].color:=f.getsidecolor(p)
						END
					END
				ELSE
					blox[i,j,k]:=v;
				END
			END END END
		END END
END FRasterrec;

PROCEDURE FRasterSolid*( f: FR; resolution: INTEGER);
VAR
	origin: PT;
BEGIN
	origin.x:=0; origin.y:=0; origin.z:=0;
	FRasterrecSolid(f,resolution,origin,1);   (* origin is (0,0,0) *)
END FRasterSolid;

PROCEDURE FRasterrecSolid(f: FR; resolution: INTEGER; origin: PT; scale: INTEGER);
VAR
	i,j,k,ii,jj,kk: INTEGER;
	o,p:PT;
	d2s,MS,TWOMS,CRDS,CRDNS:REAL;
	nextscale: INTEGER;
	v: Voxel;
	color: Color;
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
					newcell.setcolor(red/M,green/M,blue/M, redblack/M,greenblack/M,blueblack/M);
					newcell.imposter:=f.voxel(p);
					newcell.nposterTF:=TRUE;
					newcell.nposter.normal:=f.getnormal(p);
					newcell.nposter.color:=f.color(p);
					newcell.FRasterrecSolid(f,resolution,o,nextscale);
					blox[i,j,k]:=newcell				
				ELSE
				 	v:=blox[i,j,k];
				 	IF v IS cell THEN
				 		WITH v:cell DO
				 			v.imposter:=f.voxel(p);
							v.nposterTF:=TRUE;
							v.nposter.normal:=f.getnormal(p);
							v.nposter.color:=f.color(p);
							v.FRasterrecSolid(f,resolution,o,nextscale)
				 		END
				 	END
				 END
			ELSIF d2s<0 THEN
				nbloxTF[i,j,k]:=TRUE;
				nblox[i,j,k].color:=f.color(p);
				nblox[i,j,k].normal:=f.getnormal(p);
				blox[i,j,k]:=f.voxel(p);
			END
		END END END
	ELSE
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS;
			d2s:=f.d2s(p);
			IF ABS(d2s) < CRDNS THEN
				nbloxTF[i,j,k]:=TRUE;	
				IF d2s>0 THEN
					nblox[i,j,k].color:=f.getcolor(p);
				ELSE
					nblox[i,j,k].color:=f.getsidecolor(p)
				END;
				nblox[i,j,k].normal:=f.getnormal(p);
				blox[i,j,k]:=f.voxel(p);
			END
		END END END
	END;
END FRasterrecSolid;

PROCEDURE copy():Voxel;
VAR c: cell;
	i,j,k: INTEGER;
BEGIN
	NEW(c);
	c.setcolor(red,green,blue,redblack,greenblack,blueblack);
	c.nbloxTF:=nbloxTF;
	c.nblox:=nblox;
	c.passable:=passable;
	FOR i:=0 TO MMO DO
		FOR j := 0 TO MMO DO
			FOR k := 0 TO MMO DO
				IF blox[i,j,k] # NIL THEN
					IF c.blox[i,j,k].lockTF THEN
						c.blox[i,j,k] := blox[i,j,k];
					ELSE
						c.blox[i,j,k] := blox[i,j,k].copy();
					END
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
	code:=ncode; (* if this voxel has been rezzed from another module, make it NM3 *)
	copymarker:=TRUE;
	NEW(c);
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		c.nbloxTF[i,j,k]:=nbloxTF[i,j,k];
		c.nblox[i,j,k]:=nblox[i,j,k];
		c.blox[i,j,k]:=blox[i,j,k];
		c.red:=red; c.green:=green; c.blue:=blue;
		c.redblack:=redblack; c.greenblack:=greenblack; c.blueblack:=blueblack;
		child:=c.blox[i,j,k];
		IF (child#NIL) THEN
			IF child.copyonstroke OR child.copymarker  THEN
				c.blox[i,j,k]:=child
			ELSE
				c.blox[i,j,k]:=child.deepcopy() 
			END
		END
	END END END;
	copymarker:=FALSE;
	RETURN c;
END deepcopy;

PROCEDURE count*(level: INTEGER):INTEGER;
VAR
	c: INTEGER;
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
"NM3"|red|green|blue|TRUE|child0.engrain|FALSE|TRUE|child1.engrain|....
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
 	IF (code=ncode) THEN	
		w.Bytes(code,0,NL);
		w.RawLReal(red);
		w.RawLReal(green);
		w.RawLReal(blue);
		w.RawLReal(redblack);
		w.RawLReal(greenblack);
		w.RawLReal(blueblack);
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			IF (blox[i,j,k]#NIL) THEN
				w.RawBool(TRUE);
				blox[i,j,k].engrain(w)
			ELSE
				w.RawBool(FALSE);
			END;
		END END END;
	ELSE
	 	w.Bytes(code,0,NL);
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
	len: SIZE;
BEGIN
	IF (code=ncode) THEN	
		r.RawLReal(red);
		r.RawLReal(green);
		r.RawLReal(blue);
		r.RawLReal(redblack);
		r.RawLReal(greenblack);
		r.RawLReal(blueblack);
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			r.RawBool(b);
			IF b THEN
				r.Bytes(name,0,NL,len);
				blox[i,j,k]:=Base.VoxelFromName(name);
				IF blox[i,j,k]#NIL THEN blox[i,j,k].sprout(r) END
			END;
		END END END
	ELSE
	END;
END sprout;

END cell;

PROCEDURE thisvox*():Voxel;
VAR
	v: cell;
BEGIN
	NEW(v);
	RETURN v
END thisvox;

BEGIN
END NM10.
