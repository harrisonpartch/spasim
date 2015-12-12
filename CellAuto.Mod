MODULE CellAuto;
IMPORT Base, Objects,Out:=KernelLog;

TYPE 	PT=Base.PT;
		Ray = Base.Ray;
		Path=Base.Path;
		Voxel = Base.Voxel;
		Name = Base.Name;
		
CONST
	GREEN='g';
	BLUE='b';
	RED='r';
	N=1000;

TYPE CAVox*=OBJECT(Voxel)
VAR
	center*: PT;		(* in world coordinates! *)
	delta*: REAL;

PROCEDURE step;	
END step;
END CAVox;

TYPE FuseVox*=OBJECT(CAVox)
VAR
	greenf,burning1*, burning2*, burnt*: BOOLEAN;
	color:CHAR;

PROCEDURE set(p:PT; size: LONGINT); 
BEGIN
	color:=GREEN;
	greenf:=TRUE;	
	center.x:=(ENTIER(p.x*size))/size + 1/(2*size);
	center.y:=(ENTIER(p.y*size))/size + 1/(2*size);	
	center.z:=(ENTIER(p.z*size))/size + 1/(2*size);		
	delta:=0.55/size;
END set;

PROCEDURE fire*;
BEGIN
	IF greenf THEN
		greenf:=FALSE;
		burning1:=TRUE;
		Engine.push(SELF)
	END;
END fire;

PROCEDURE probe*(p:PT; resolution: LONGINT):Voxel;
BEGIN
	fire;
	Out.String("fire!");
	RETURN(SELF)
END probe;

PROCEDURE passprobe*(p: PT):BOOLEAN;
BEGIN
	fire;
	RETURN(FALSE);
END passprobe;

PROCEDURE stroke*(p:PT; resolution: LONGINT; VAR path: Path; voxel,voxundo:Voxel);
BEGIN
	fire
END stroke;

PROCEDURE step*;	
VAR
	v: Voxel
BEGIN
	IF burning1 THEN
		v:=Base.world.probe(Base.mkPT(center.x+delta,center.y,center.z),1000);
		v:=Base.world.probe(Base.mkPT(center.x-delta,center.y,center.z),1000);
		v:=Base.world.probe(Base.mkPT(center.x,center.y+delta,center.z),1000);
		v:=Base.world.probe(Base.mkPT(center.x,center.y-delta,center.z),1000);
		v:=Base.world.probe(Base.mkPT(center.x,center.y,center.z+delta),1000);
		v:=Base.world.probe(Base.mkPT(center.x,center.y,center.z-delta),1000);
		burning1:=FALSE;
		burning2:=TRUE;	
		color:=RED;
		anonyhook;
		Engine.push(SELF);	
	ELSIF burning2 THEN
		burning2:=FALSE;
		color:=GREEN;
		greenf:=TRUE
	END;	
END step;


PROCEDURE Shade*(VAR ray: Ray);
BEGIN
	CASE color OF
			GREEN:	gren.Shade(ray)
		| 	RED:	rd.Shade(ray)
		|	BLUE: 	blu.Shade(ray)
	ELSE
		gren.Shade(ray)
	END
END Shade;

PROCEDURE anonyhook;
BEGIN
	
END anonyhook;

END FuseVox;

TYPE GroVox*=OBJECT(FuseVox)
PROCEDURE anonyhook;	
VAR
	v: Voxel;
	g:GroVox;
	path: Path;
BEGIN
	v:=Base.world.probe(Base.mkPT(center.x,center.y,center.z-delta),1000);
	IF (v=NIL) OR v.passable THEN
		NEW(g);
		center.z:=center.z-delta;
		g.set(center,Base.avatarsize);
		g.burning2:=TRUE;
		Base.world.stroke(center,Base.avatarsize, path, g,v);
	END
END anonyhook;
END GroVox;


TYPE GateFuseVox*=OBJECT(FuseVox)
PROCEDURE step;	
VAR
	v: Voxel
BEGIN
	IF burning1 THEN
		v:=Base.world.probe(Base.mkPT(center.x+delta,center.y,center.z),1000);;
		burning1:=FALSE;
		burning2:=TRUE;	
		CASE color OF
				GREEN:	color:=RED
			| 	RED:	color:=BLUE
			|	BLUE: 	color:=GREEN
		END;
		Engine.push(SELF)	
	ELSIF burning2 THEN
		burning2:=FALSE;
		greenf:=TRUE
	END
END step;
PROCEDURE Shade (VAR ray: Ray);
BEGIN
	CASE color OF
			RED:	gren.Shade(ray)
		| 	BLUE:	rd.Shade(ray)
		|	GREEN: blu.Shade(ray)
	END
END Shade;

END GateFuseVox;

TYPE CAEngine=OBJECT
VAR
	Front, F2: ARRAY N OF CAVox;
	fn,i: LONGINT;
	
PROCEDURE push(v: CAVox);
BEGIN
	IF fn<N-1 THEN F2[fn]:=v; INC(fn) END
END push;

PROCEDURE tick*;
VAR i,n: LONGINT;
BEGIN
	FOR i:=0 TO fn-1 DO
		Front[i]:=F2[i]
	END;
	n:=fn;
	fn:=0;
	FOR i:=0 TO n-1 DO	
		Front[i].step;
	END;
END tick
	 
END CAEngine;

VAR
	Engine*: CAEngine;
	gren,blu,rd: Voxel;
BEGIN
	NEW(Engine);
	gren:=Base.VoxelFromName("Ndiffuseblue"); 
	blu:=Base.VoxelFromName("NznGx2ySiHIGrO5t9Pzcw5Q"); 
	rd:=Base.VoxelFromName("NnviGAernhjFK40xASZZVoQ"); 
END CellAuto.
