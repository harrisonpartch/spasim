MODULE NM30;
IMPORT Base, XNXLE, XNXLNoise, XNXLFRep, Math, Out := KernelLog, Debugging, Streams,Strings;

CONST M=30;
	MMO=M-1;
	CUBERADIUS=0.65;   (*change to sqrt(3)/2 ???*)
	NCODE="NM3";
	NL=Base.NL;

TYPE PT = Base.PT;
	Color = Base.Color;
	Ray = Base.Ray;
	Voxel = Base.Voxel;
	FR = Base.FR;
	Name = Base.Name;
 	NCube=Base.NCube;
 	LCube=Base.LightCube;

TYPE cell = OBJECT(Voxel);
VAR
	blox*: ARRAY M,M,M OF Voxel;
	nbloxTF*: ARRAY M,M,M OF BOOLEAN;
	nblox*: ARRAY M,M,M OF NCube; 
	lblox*: ARRAY M,M,M OF LCube;
	nposterTF*:BOOLEAN;
	nposter*: NCube;	

PROCEDURE Shade (VAR ray: Ray);
VAR
	pushxyz, newxyz, xyz: Base.PT;
	ijk: Base.IPT;
	drx, dry, drz, dr,rr,gr,br,blr,bla: REAL;
	scaleInv:REAL; 
	out,shadenil,A,B,C: BOOLEAN;
	v: Voxel;
	vdepth: REAL;
	last:BOOLEAN;
	dtl:REAL;
BEGIN
	ray.scale := ray.scale*M;
	scaleInv := 1/ray.scale;
	xyz.x := ABS(ray.lxyz.x-offset.x) * M;  
	xyz.y := ABS(ray.lxyz.y-offset.y) * M;		
	xyz.z := ABS(ray.lxyz.z-offset.z)* M;	
	pushxyz:=xyz;	
	IF (ray.length*ray.scale>ray.dtl) THEN
		IF imposter#NIL THEN
			imposter.Shade(ray)
		END	
	ELSE	
	XNXLE.E(xyz,ijk);
	bounds(ijk.i,ijk.j,ijk.k,out);
	IF ~out THEN
		v:= blox[ijk.i,ijk.j,ijk.k];
		IF nbloxTF[ijk.i,ijk.j,ijk.k] THEN ray.normal:=nblox[ijk.i,ijk.j,ijk.k].normal; ray.normalTF:= TRUE ELSE ray.normal:=ray.fnormal; ray.normalTF:=FALSE  END;
		IF (v#NIL) THEN
			ray.lxyz.x := ABS(xyz.x - ijk.i);  
			ray.lxyz.y := ABS(xyz.y - ijk.j);
			ray.lxyz.z := ABS(xyz.z - ijk.k);
			ray.popdelta := Base.Origin; 
			ray.normalTF:=nbloxTF[ijk.i,ijk.j,ijk.k];
			v.Shade(ray);	
			xyz.x := xyz.x + ray.popdelta.x;    
			xyz.y := xyz.y + ray.popdelta.y;
			xyz.z := xyz.z + ray.popdelta.z;
		ELSIF nbloxTF[ijk.i,ijk.j,ijk.k] THEN
			nshade(nblox[ijk.i,ijk.j,ijk.k],ray);
		END
	END;	 
	IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;	
	IF ~ray.terminate THEN
		REPEAT		
			newxyz.x := xyz.x + ray.dxyz.x/2; newxyz.y := xyz.y +  ray.dxyz.y/2; newxyz.z  := xyz.z + ray.dxyz.z/2;
			ijk.i:=SHORT(ENTIER(newxyz.x*M)); 
			ijk.j:=SHORT(ENTIER(newxyz.y*M)); 
			ijk.k:=SHORT(ENTIER(newxyz.z*M)); 
			vdepth:=1/(M*2);
			
			ray.xyz:=xyz;
			xyz:=newxyz;
			ray.length:=ray.length+vdepth;
			blr:=black*vdepth;
			ray.bla := ray.bla-blr; 		
			rr := red*vdepth*ray.ra; 
			gr := green*vdepth*ray.ga; 
			br := blue*vdepth*ray.ba; 	
			ray.r := ray.r+rr;
			ray.g:= ray.g+gr;
			ray.b := ray.b+br; 
			ray.ra := (ray.ra-rr)-blr;
			ray.ga := (ray.ga-gr)-blr;
			ray.ba := (ray.ba-br)-blr; 
			bounds(ijk.i,ijk.j,ijk.k, out);
			IF ~out THEN
				v := blox[ijk.i,ijk.j,ijk.k];		
				IF (v#NIL) THEN
					ray.lxyz.x := ABS(xyz.x - ijk.i);  
					ray.lxyz.y := ABS(xyz.y - ijk.j);
					ray.lxyz.z := ABS(xyz.z - ijk.k);
					ray.popdelta := Base.Origin; (* because many shaders don't set it and it *)
					ray.normalTF:=nbloxTF[ijk.i,ijk.j,ijk.k];
					v.Shade(ray);	
					xyz.x := xyz.x + ray.popdelta.x;    
					xyz.y := xyz.y + ray.popdelta.y;
					xyz.z := xyz.z + ray.popdelta.z
				END
			END;
		IF (ray.bla<0.1) THEN ray.terminate:=TRUE END;
		UNTIL  out  OR ray.terminate;
	END 	
	END;
	ray.popdelta.x := (xyz.x-pushxyz.x)/M;
	ray.popdelta.y := (xyz.y-pushxyz.y)/M;
	ray.popdelta.z := (xyz.z-pushxyz.z)/M; 
(*	ray.scale := ray.scale/M; *)
END Shade;

PROCEDURE nshade*(CONST nc: NCube; VAR ray: Ray);
VAR
	dr,dg,db,mix,dot,dot1,dot2: REAL;
	light: Base.Light;	
BEGIN
	dot1:= ABS(nc.normal.x*ray.dxyz.x + nc.normal.y*ray.dxyz.y+ nc.normal.z*ray.dxyz.z); 
	dot2:= ABS(ray.fnormal.x*ray.dxyz.x + ray.fnormal.y*ray.dxyz.y+ ray.fnormal.z*ray.dxyz.z);
	dot2:=dot2*0.7+0.3;
	IF ray.length*ray.scale<3 THEN mix:=1-(ray.length*ray.scale/6) ELSE mix:=0 END;
	dot:=mix*dot2+(1-mix)*dot1;
	dr:=nc.color.red*dot*ray.ra;
	dg:=nc.color.green*dot*ray.ga;
	db:=nc.color.blue*dot*ray.ba;	
	ray.r := ray.r + dr;
	ray.g := ray.g + dg;
	ray.b := ray.b + db;	
	ray.ra:=ray.ra-dr;
	ray.ga:=ray.ga-dg;
	ray.ba:=ray.ba-db;
	ray.r := ray.r + nc.color.red * ray.ra*dot;
	ray.g := ray.g + nc.color.green * ray.ga*dot;
	ray.b := ray.b + nc.color.blue * ray.ba*dot; 	
	ray.terminate:=TRUE
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
	ray.hitdxyz:=ray.dxyz;
	ray.changed := TRUE;
	ray.mirrortf:=TRUE;	
	reflect(ray.dxyz, ray.normal);	
	IF ray.dxyz.x < 0 THEN ray.di := FALSE  ELSE ray.di := TRUE END; 
	IF ray.dxyz.y < 0 THEN ray.dj := FALSE  ELSE ray.dj := TRUE END;
	IF ray.dxyz.z < 0 THEN ray.dk := FALSE  ELSE ray.dk := TRUE END;	
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
	DTL:=Base.DTL;
	setcolor(0,0,1,1,0);
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
		IF (blox[i,j,k]#NIL)&blox[i,j,k].copymarker THEN
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

PROCEDURE setcolorrec (r,g,b,bl,a: REAL); 
VAR
	v: Voxel;
	i,j,k: INTEGER;
BEGIN
	copymarker:=TRUE;
	colored:=TRUE;	
	red:= r;
	green := g;
	blue := b;
	black:= bl;
	alpha:=a;
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		v:=blox[i,j,k];
		IF v#NIL THEN
			IF v IS Voxel THEN
				IF ~v.copymarker THEN
					WITH v: Voxel DO
						v.setcolorrec(r,g,b,bl,a);
					END
				END
			END
		END
	END END END	
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
	IF probelock THEN RETURN FALSE END;
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

PROCEDURE stroke(p:PT; resolution:LONGINT; voxel,voxundo:Voxel);
VAR
	i,j,k: LONGINT;
BEGIN
	Base.clamPT(p);
	IF voxel#NIL THEN
		strokerec(p,resolution,1,voxel,voxundo);
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

PROCEDURE strokerec(p:PT; resolution,scale:LONGINT; voxel,voxundo:Voxel);
VAR
	i,j,k,ii,jj,kk,nextscale: LONGINT;
	v,vv:Voxel;
	c,c2: Voxel;	
	copy,vu: Voxel;
	code: Base.Name;
BEGIN
	IF ~lockTF THEN
		nextscale:=scale*M;
		p.x:=p.x*M;
		p.y:=p.y*M;
		p.z:=p.z*M;
		i := ENTIER(p.x)MOD M; j := ENTIER(p.y)MOD M; k := ENTIER(p.z)MOD M;	
		IF nextscale>=resolution THEN	
			blox[i,j,k]:=voxel
		ELSE
			IF blox[i,j,k]#NIL THEN 
				IF voxundo= NIL THEN voxundo:=blox[i,j,k] END;  
				IF blox[i,j,k].copyonstroke THEN 
					copy:=Base.VoxelFromName(v.code);
					copy.copyonstroke:=FALSE;
					blox[i,j,k]:=copy;
				END;
				blox[i,j,k].strokerec(p, resolution,nextscale,voxel,vu)	
			ELSE
				c:=Base.VoxelFromName("NM3");
				c.setcolor(red,green,blue,black,alpha);
				blox[i,j,k]:=c;
				p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
				c.stroke(p, resolution DIV nextscale,voxel,vu);
			END;	
		END
	END
END strokerec;

PROCEDURE line*(a,b: PT; resolution: LONGINT; v: Voxel);
VAR
	tx,ty,tz, dxdt, dydt, dzdt: REAL;
	t: LONGINT;
	delta: REAL;
	n: LONGINT;
	p: PT;
	vu: Voxel

BEGIN
	n := ENTIER(Base.distance(a,b)*resolution*M);
	IF n > 0 THEN
		tx := b.x; ty := b.y; tz := b.z;;
		dxdt := (a.x-b.x)/n; dydt := (a.y-b.y)/n; dzdt := (a.z-b.z)/n; 
		FOR t := 0 TO n DO
			Base.setPT(p,tx, ty, tz);
			stroke(p, resolution,v,vu);
			tx := tx + dxdt; ty := ty + dydt; tz := tz+dzdt;
		END
	END		
END line;

PROCEDURE FRasterrec(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT); (*origin is always in world space*)
VAR
	i,j,k: INTEGER;
	o,p:PT;
	d2s,MS,TWOMS,CRDS,CRDNS:REAL;
	nextscale: LONGINT;
	v: Voxel;
	newcell: Voxel; 
BEGIN
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
					newcell:=Base.VoxelFromName("NM3");
					blox[i,j,k]:=newcell;
					newcell.setcolor(red,green,blue,black,alpha);
					newcell.imposter:=f.getimposter(p);
					newcell.FRasterrec(f,resolution,o,nextscale);
				ELSE
				 	v:=blox[i,j,k];  (* compiler disallows type tests and guards on array elements *)
				 	IF v IS Voxel THEN
				 		WITH v:Voxel DO
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
					nblox[i,j,k].normal:=f.normal(p);
					nbloxTF[i,j,k]:=TRUE;
					blox[i,j,k]:=v;	
				ELSE
					nbloxTF[i,j,k]:=TRUE;
					nblox[i,j,k].normal:=f.normal(p);
					nblox[i,j,k].color:=f.color(p);
				END
			END	
		END END END
	END; 
END FRasterrec;

PROCEDURE FRasterrecSolid(f: FR; resolution: LONGINT; origin: PT; scale: LONGINT); (*origin is always in world space*)
VAR
	i,j,k,ii,jj,kk: INTEGER;
	o,p:PT;
	d2s,MS,TWOMS,CRDS,CRDNS:REAL;
	nextscale: LONGINT;
	v: Voxel;
	newcell: Voxel;
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
					newcell:=Base.VoxelFromName("NM3");
					IF f.in(p) THEN 
						newcell.imposter:=f.getimposter(p);
						newcell.FRasterrecSolid(f,resolution,o,nextscale)
					END;	
					blox[i,j,k]:=newcell
				ELSE
				 	v:=blox[i,j,k];  (* compiler disallows type tests and guards on array elements *)
				 	IF v IS Voxel THEN
				 		WITH v:Voxel DO
				 			v.FRasterrecSolid(f,resolution,o,nextscale);
				 		END
				 	END
				 END
			END	
		END END END
	END;
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			p.x:=origin.x+(i+1/2)/MS; p.y:=origin.y+(j+1/2)/MS; p.z:=origin.z+(k+1/2)/MS;
			d2s:=f.d2s(p);		
			IF ABS(d2s)<CRDNS THEN 
				v:=f.voxel(p);
			IF v#NIL THEN 
					(* IF v IS cell THEN v:=v.deepcopy() END; *)
					blox[i,j,k]:=v;	
				ELSE
					nbloxTF[i,j,k]:=TRUE;
					nblox[i,j,k].normal:=f.normal(p);
					nblox[i,j,k].color:=f.color(p);
				END
			END 	
		END END END
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
	child:Voxel;
	i,j,k: INTEGER;
BEGIN
	copyclear;
	RETURN deepcopyrec()
END deepcopy;

PROCEDURE deepcopyrec*():Voxel;
VAR	
	c:cell;
	child:Voxel;
	i,j,k: INTEGER;
BEGIN
	NEW(c);
	IF (~copymarker) & (code=NCODE)  THEN
		copymarker:=TRUE;
		NEW(c);
		c.red:=red; c.green:=green; c.blue:=blue; c.black:=black; c.alpha:=alpha;
		c.nbloxTF:=nbloxTF;
		c.nblox:=nblox;
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			child:=blox[i,j,k]; 
			IF (child#NIL) THEN
				IF child.complex & (child.code = child.ncode) THEN 
					 c.blox[i,j,k]:=child.deepcopy() 
				ELSE
					c.blox[i,j,k]:=child
				END
			END
		END END END;	
	END;
	RETURN c
END deepcopyrec;

PROCEDURE engrain(w: Streams.Writer); 
VAR
	i,j,k: INTEGER;
BEGIN
	w.Bytes(code,0,NL);	 
	IF (code=NCODE)  &(~copymarker) THEN	
		copymarker:=TRUE;
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
				IF (blox[i,j,k]#NIL)  THEN
					w.RawBool(TRUE);
					blox[i,j,k].engrain(w) 				
				ELSE
					w.RawBool(FALSE);
				END;			
		END END END; 
	END
END engrain;

PROCEDURE sprout(r: Streams.Reader);
VAR
	i,j,k: INTEGER;
	b: BOOLEAN;
	name: Name;
	len: LONGINT;
BEGIN
	IF code=NCODE THEN
		FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
			r.RawBool(b);
			IF b THEN
				r.Bytes(name,0,NL,len);
				blox[i,j,k]:=Base.VoxelFromName(name);
				IF blox[i,j,k]#NIL THEN blox[i,j,k].sprout(r) END		
			END;	
		END END END	
	END					
END sprout;

END cell;


PROCEDURE thisvox*():Voxel;
VAR
	v: cell;  
BEGIN
	NEW(v);
	RETURN v
END thisvox;

END NM30.




