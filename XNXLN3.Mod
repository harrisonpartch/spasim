MODULE XNXLN3;
IMPORT Base:=XNXLBase, XNXLE, XNXLFRep, Out := KernelLog, Streams;

CONST   M=3;
        MMO=M-1;
        CUBERADIUS=0.75;   (*change to sqrt(3)/2 ???*)
        AIR=0;
        WATER=1;        

TYPE PT = Base.PT;
TYPE Color = Base.Color;
TYPE Ray = Base.Ray;
TYPE Voxel = Base.Voxel;
TYPE FR = Base.FR;
TYPE Name = Base.Name;

TYPE NCUBE=RECORD
        normal: PT; 
        color: Color;
END;

TYPE BA=ARRAY M,M,M OF BOOLEAN;
TYPE VA=ARRAY M,M,M OF Voxel;
TYPE NA=ARRAY M,M,M OF NCUBE;

TYPE cell* = OBJECT(Base.Cell);
VAR
        blox*: VA;
        nTF*: BA;
        N: NA;
        red*,green*,blue*,black*: REAL;
        colored:BOOLEAN;

PROCEDURE Shade (VAR ray: Ray);
VAR
       pushxyz, newxyz, xyz: Base.PT;
       ijk: Base.IPT;
       drx, dry, drz, dr,rr,gr,br,blr: REAL;
	scaleInv:REAL;      
       out,shadenil,A,B,C: BOOLEAN;
       v: Voxel;
       vdepth: REAL;
       last:BOOLEAN;
       dtl: REAL;
BEGIN
        IF colored THEN 
                ray.cellred:=red;
                ray.cellgreen:=green;
                ray.cellblue:=blue;
                ray.cellblack:=black
        END;
        ray.scale := ray.scale*M;
        scaleInv := 1/ray.scale;
 	xyz.x := ABS(ray.lxyz.x-offset.x) * M  - ray.ddxyz.x;  (* ray.lxyz could be renamed to ray.pushxyz *)
	xyz.y := ABS(ray.lxyz.y-offset.y) * M  - ray.ddxyz.y;		
	xyz.z := ABS(ray.lxyz.z-offset.z)* M  - ray.ddxyz.z; 
        dtl:=ray.length*ray.scale;
        IF (dtl>Base.DTL)&(imposter#NIL) THEN
                imposter.Shade(ray)     
        ELSE            
        pushxyz:=xyz;
        XNXLE.E(xyz,ijk);
        bounds(ijk.i,ijk.j,ijk.k,out);
        IF ~out THEN
                v:= blox[ijk.i,ijk.j,ijk.k];
                IF (v#NIL) THEN
                        ray.lxyz.x := ABS(xyz.x - ijk.i);  
                        ray.lxyz.y := ABS(xyz.y - ijk.j);
                        ray.lxyz.z := ABS(xyz.z - ijk.k);
                        ray.popdelta := Base.Origin; 
                        v.Shade(ray);                                   
                        xyz.x := xyz.x + ray.popdelta.x;    
                        xyz.y := xyz.y + ray.popdelta.y;
                        xyz.z := xyz.z + ray.popdelta.z
                ELSIF nTF[ijk.i,ijk.j,ijk.k] THEN               
                        ncolor(ray,N[ijk.i,ijk.j,ijk.k]);
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
                                        ray.face := 1; ray.normal:= Base.Face[0] 
                                ELSE 
                                        INC(ijk.i, -1);
                                        ray.face := 4; ray.normal:= Base.Face[3] 
                                END;
                                newxyz.x := xyz.x + drx * ray.dxyz.x; newxyz.y := xyz.y + drx * ray.dxyz.y; newxyz.z  := xyz.z + drx * ray.dxyz.z       
                        ELSIF A&~B THEN
                                dr := drz;
                                IF ray.dk THEN 
                                        INC(ijk.k, 1);
                                        ray.face := 3; ray.normal:= Base.Face[2] 
                                ELSE
                                        INC(ijk.k, -1);
                                        ray.face := 6; ray.normal:= Base.Face[5]
                                END;
                                newxyz.x := xyz.x + drz * ray.dxyz.x; newxyz.y := xyz.y + drz * ray.dxyz.y; newxyz.z  := xyz.z + drz * ray.dxyz.z
                        ELSIF C THEN
                                dr := dry;
                                IF ray.dj THEN 
                                        INC(ijk.j, 1);
                                        ray.face := 2; ray.normal:= Base.Face[1] 
                                ELSE 
                                        INC(ijk.j, -1);
                                        ray.face := 5; ray.normal:= Base.Face[4] 
                                END;
                                newxyz.x := xyz.x + dry * ray.dxyz.x; newxyz.y := xyz.y + dry * ray.dxyz.y; newxyz.z  := xyz.z+ dry * ray.dxyz.z
                        ELSE
                                dr := drz;              
                                IF ray.dk  THEN 
                                        INC(ijk.k, 1);
                                        ray.face := 3; ray.normal:= Base.Face[2] 
                                ELSE
                                        INC(ijk.k, -1);
                                        ray.face := 6; ray.normal:= Base.Face[5]
                                END;
                                newxyz.x := xyz.x + drz * ray.dxyz.x; newxyz.y := xyz.y + drz * ray.dxyz.y; newxyz.z  := xyz.z + drz * ray.dxyz.z
                        END;
			vdepth:=Base.distance(newxyz,xyz)*scaleInv;
			ray.xyz.x:=ray.xyz.x +((newxyz.x-xyz.x)+ray.ddxyz.x)*scaleInv;
			ray.xyz.y:=ray.xyz.y +((newxyz.y-xyz.y)+ray.ddxyz.y)*scaleInv;			
			ray.xyz.z:=ray.xyz.z +((newxyz.z-xyz.z)+ray.ddxyz.z)*scaleInv;			
                        xyz:=newxyz;
                        ray.length:=ray.length+vdepth;
                        IF TRUE THEN
                                rr := ray.cellred*vdepth*ray.ra; gr := ray.cellgreen*vdepth*ray.ga; br := ray.cellblue*vdepth*ray.ba; blr:=ray.cellblack*vdepth;
                                ray.r := ray.r+rr;
                                ray.g:= ray.g+gr;
                                ray.b := ray.b+br; 
                                ray.ra := (ray.ra-rr)-blr;
                                ray.ga := (ray.ga-gr)-blr;
                                ray.ba := (ray.ba-br)-blr;      
                        END;                    
                        bounds(ijk.i,ijk.j,ijk.k, out);
                        IF ~out  THEN
                                IF (ray.length*ray.length*ray.length*ray.scale>Base.DTL) THEN
                                        v:=imposter
                                ELSE    
                                        v:= blox[ijk.i,ijk.j,ijk.k]
                                END;    
                                IF nTF[ijk.i,ijk.j,ijk.k] THEN ray.normal:=N[ijk.i,ijk.j,ijk.k].normal END;     
                                v := blox[ijk.i,ijk.j,ijk.k];                                           
                                IF (v#NIL) THEN
                                        ray.lxyz.x := ABS(xyz.x - ijk.i);  
                                        ray.lxyz.y := ABS(xyz.y - ijk.j);
                                        ray.lxyz.z := ABS(xyz.z - ijk.k);
                                        ray.popdelta := Base.Origin; (* because many shaders don't set it and it *)
                                        v.Shade(ray);                                   (* must be (0,0,0) in that case       *)
                                        xyz.x := xyz.x + ray.popdelta.x;    
                                        xyz.y := xyz.y + ray.popdelta.y;
                                        xyz.z := xyz.z + ray.popdelta.z;        
                                ELSIF nTF[ijk.i,ijk.j,ijk.k] THEN               
                                        ncolor(ray,N[ijk.i,ijk.j,ijk.k]);
                                        xyz.x := xyz.x + ray.popdelta.x;    
                                        xyz.y := xyz.y + ray.popdelta.y;
                                        xyz.z := xyz.z + ray.popdelta.z                 
                                END
                        END; 
                        IF (ray.ra<0.1)&(ray.ga<0.1)&(ray.ba<0.1) THEN ray.terminate:=TRUE END;
                UNTIL  ray.terminate OR out;
        END     
        END;
        ray.popdelta.x := (xyz.x-pushxyz.x)/M;
        ray.popdelta.y := (xyz.y-pushxyz.y)/M;
        ray.popdelta.z := (xyz.z-pushxyz.z)/M;
        ray.scale := ray.scale/M;
END Shade;

PROCEDURE tick*;
BEGIN
	offset.z:=offset.z+0.01;
	IF offset.z>0.99 THEN offset.z:=0 END;
END tick;

PROCEDURE ncolor(VAR ray: Ray; cube:NCUBE);
VAR
        dot,omm,r,g,b,bl: REAL; 
BEGIN
        dot:= ABS(cube.normal.x*ray.dxyz.x + cube.normal.y*ray.dxyz.y+ cube.normal.z*ray.dxyz.z);
        ray.r := ray.r + cube.color.red * ray.ra*dot;
        ray.g := ray.g + cube.color.green * ray.ga*dot;
        ray.b := ray.b + cube.color.blue * ray.ba*dot;          
        ray.terminate:=TRUE
END ncolor;

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
        code:="NEmb7fXmcxu1apgyZ8VRovg"
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
	FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
		v:=blox[i,j,k];
		IF v#NIL THEN
			IF v IS Base.Cell THEN
				IF ~v.copymarker THEN
					WITH v: Base.Cell DO
						v.setcolorrec(r,g,b,bl,a);
					END
				END
			END
		END
	END END END	
END setcolorrec;

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
                blox[i,j,k] := v
        END END END
END fill;

PROCEDURE probe(p:PT; resolution:LONGINT):Voxel;
VAR
	X,Y,Z: REAL;
	i,j,k: LONGINT;
BEGIN
	RETURN proberec(p,resolution,1);
END probe;

PROCEDURE proberec(p:PT; resolution,scale:LONGINT):Voxel;
VAR
	X,Y,Z: REAL;
	v: Voxel;
	i,j,k: LONGINT;
BEGIN
	Base.clamPT(p);
	scale:=scale*M;
	X := p.x*M; Y := p.y*M; Z := p.z*M;
	i := ENTIER(X); 
	j := ENTIER(Y);
	k := ENTIER(Z);
	v:=blox[i,j,k];
	IF scale>=resolution THEN 
		RETURN (v)
	ELSIF  v IS Base.Cell THEN 
		p.x:=X-i; p.y:=Y-j; p.z:=Z-k;
		WITH v:Base.Cell  DO
			RETURN(v.proberec(p,resolution,scale)) 
		END
	ELSE RETURN(NIL)
	END	
END proberec;

PROCEDURE passprobe*(p:PT):BOOLEAN;
VAR
	X,Y,Z: REAL;	
	i,j,k: LONGINT;
BEGIN
	Base.clamPT(p);
	X := p.x*M; Y := p.y*M; Z := p.z*M;
	i := ENTIER(X); 
	j := ENTIER(Y);
	k := ENTIER(Z);
	IF (~nTF[i,j,k]) & (blox[i,j,k]=NIL) THEN 
		RETURN TRUE
	ELSIF blox[i,j,k]#NIL THEN
		RETURN(blox[i,j,k].passprobe(Base.mkPT(X-i, Y-j, Z-k))) 
	END;
	RETURN FALSE
END passprobe;

PROCEDURE stroke*(p:PT; resolution:LONGINT; voxel:Voxel);
VAR
        i,j,k: LONGINT;
        c: cell;
        v:Voxel;
BEGIN
        Base.clamPT(p);
         strokerec(p,resolution,1,voxel);
END stroke;

PROCEDURE strokerec(p:PT; resolution,scale:LONGINT; voxel:Voxel);
VAR
	i,j,k,nextscale: LONGINT;
	v:Voxel;
	c: cell;
BEGIN
	IF ~lockTF THEN
		nextscale:=scale*M;
		p.x:=p.x*M;
		p.y:=p.y*M;
		p.z:=p.z*M;
		i := ENTIER(p.x); j := ENTIER(p.y); k := ENTIER(p.z);	
		IF nextscale>resolution THEN	
			blox[i,j,k]:=voxel
		ELSE
			IF blox[i,j,k]#NIL THEN 
				IF (*~blox[i,j,k].lockTF &*)(blox[i,j,k] IS cell) THEN
					v:=blox[i,j,k];
					WITH v: cell DO c:=v END
				ELSE
					NEW(c);
					c.imposter:=blox[i,j,k];	
					c.fill(blox[i,j,k]);
				END;
				c.setcolor(red,green,blue,black,alpha);
				blox[i,j,k]:=c;
				p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
				c.strokerec(p, resolution,nextscale,voxel);
			ELSE
				NEW(c);
				c.setcolor(red,green,blue,black,alpha);
				blox[i,j,k]:=c;
				p.x:=p.x-i; p.y:=p.y-j; p.z:=p.z-k;
				c.strokerec(p, resolution,nextscale,voxel);
			END
		END
	END
END strokerec;

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
                n := ENTIER(Base.distance(a,b)/delta);
                tx := b.x; ty := b.y; tz := b.z;
                dxdt := (a.x-b.x)/n; dydt := (a.y-b.y)/n; dzdt := (a.z-b.z)/n; 
                FOR t := 0 TO n DO
                        Base.setPT(p,tx, ty, tz);
                        stroke(p, level,v);
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
                n := ENTIER(Base.distance(a,b)/delta);
                tx := b.x; ty := b.y; tz := b.z;
                dxdt := (a.x-b.x)/n; dydt := (a.y-b.y)/n; dzdt := (a.z-b.z)/n; 
                FOR t := 0 TO n DO
                        Base.setPT(p,tx, ty, tz);
                        stroke(p, level,v);
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
                                        blox[i,j,k]:=newcell;
                                        newcell.setcolor(red,green,blue,black,alpha);
                                        newcell.imposter:=f.getimposter(p);
                                        newcell.FRasterrec(f,resolution,o,nextscale);
                                ELSE
                                        v:=blox[i,j,k];  (* compiler disallows type tests and guards on array elements *)
                                        IF v IS Base.Cell THEN
				 			WITH v:Base.Cell DO
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
                                        (* IF v IS cell THEN v:=v.deepcopy() END; *)
                                        blox[i,j,k]:=v; 
                                        IF f.normaltf(p) THEN
                                                nTF[i,j,k]:=TRUE;
                                                N[i,j,k].normal:=f.normal(p);
                                                N[i,j,k].color:=f.getcolor(p)
                                        END                     
                                ELSE
                                        nTF[i,j,k]:=TRUE;
                                        N[i,j,k].normal:=f.normal(p);
                                        N[i,j,k].color:=f.getcolor(p);
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
                                blox[i,j,k]:=f.getimposter(p)
                        ELSIF d2s<CRDS THEN  (* at surface *)                           
                                o.x:=p.x-1/TWOMS; o.y:=p.y-1/TWOMS; o.z:=p.z-1/TWOMS; (* p is center, o is corner *)
                                IF blox[i,j,k]=NIL THEN
                                        NEW(newcell);
                                        blox[i,j,k]:=newcell;
                                        newcell.setcolor(red,green,blue,black,alpha);
                                        newcell.imposter:=f.getimposter(p);
                                        newcell.FRasterrecSolid(f,resolution,o,nextscale);
					ELSE
                                        v:=blox[i,j,k];  (* compiler disallows type tests and guards on array elements *)
                    			IF v IS Base.Cell THEN
				 			WITH v:Base.Cell DO
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
                                        (* IF v IS cell THEN v:=v.deepcopy() END; *)
                                        blox[i,j,k]:=v;
                                        IF f.normaltf(p) THEN
                                                nTF[i,j,k]:=TRUE;
                                                N[i,j,k].normal:=f.normal(p);
                                                N[i,j,k].color:=f.getcolor(p)
                                        END                     
                                ELSE 
                                        nTF[i,j,k]:=TRUE;
                                        N[i,j,k].normal:=f.normal(p);
                                        N[i,j,k].color:=f.getcolor(p);
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
        c.setcolor(red,green,blue,black,alpha);
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
        copymarker:=TRUE;
        NEW(c);
        c.red:=red; c.green:=green; c.blue:=blue; c.black:=black;
        FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
                child:=blox[i,j,k]; 
                IF (child#NIL)&~child.copymarker THEN
                        c.blox[i,j,k]:=child.deepcopy();
                END
        END END END;    
        copyclear;
        RETURN(c)
END deepcopy;

(*PROCEDURE engrain*(w: Streams.Writer);
VAR
        i,j,k: INTEGER;
BEGIN
       IF ~copymarker THEN
                w.Bytes(code,0,24);      
                copymarker:=TRUE;
                FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
                        IF blox[i,j,k]#NIL THEN
                                w.RawBool(TRUE);
                                blox[i,j,k].engrain(w) 
                        ELSE
                                w.RawBool(FALSE);
                        END
                END END END 
        END
END engrain;

PROCEDURE sprout(r: Streams.Reader);
VAR
        i,j,k: INTEGER;
        b: BOOLEAN;
        name: Name;
        len: LONGINT;
BEGIN
        Out.String("m3cell ");
        FOR i := 0 TO MMO DO FOR j := 0 TO MMO DO FOR k:= 0 TO MMO DO
                r.RawBool(b);
                IF b THEN
                        r.Bytes(name,0,24,len);
                        Out.String(name);
                        IF name#"" THEN blox[i,j,k]:=Base.VoxelFromName(name) END;
                        IF blox[i,j,k]#NIL THEN blox[i,j,k].sprout(r) END
(*              ELSE
                        blox[i,j,k]:=NIL; *)
                END
        END END END             
END sprout;
*)
END cell;

END XNXLN3.
