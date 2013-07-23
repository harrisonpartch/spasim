MODULE XNXLGL;

IMPORT
	XNXLBase, XNXLBloom, S := SYSTEM, GL:=OpenGL, GLC := OpenGLConst, Out:=KernelLog;

CONST
	TTP=1048576;
	CN=10000
TYPE 
	Voxel=XNXLBase.Voxel;
	PT=XNXLBase.PT;
	Texture=XNXLBase.Texture;
	
TYPE Stipples=ARRAY [*] OF CHAR;

TYPE Cube=RECORD
	xyz:PT;
	scale:REAL;
	texture: Texture
END;

TYPE NCube=RECORD
	xyz:PT;
	scale:REAL;
	normal:PT;
	texture: Texture
END;

TYPE DLCube=RECORD  (*not really a cube*)
	xyz:PT;
	scale:REAL;
	rot: REAL;
	dlist: LONGINT
END;

TYPE Cubes=OBJECT
VAR
	q:ARRAY CN OF Cube;
	index,dlist*: LONGINT;

PROCEDURE flush;
BEGIN
	index:=0;
END flush;
	
PROCEDURE push(p:PT; scale:REAL; texture:Texture);
VAR
	a,b,c,d:LONGINT;
BEGIN{EXCLUSIVE}
	a:=ENTIER(p.x*TTP);
	b:=ENTIER(p.y*TTP);	
	c:=ENTIER(p.z*TTP);	
	IF ~filter.probe(a,b,c,scale) THEN
		filter.hash(a,b,c,scale);
		q[index].xyz:=p;
		q[index].scale:=scale;		
		q[index].texture:=texture;	
		INC(index);
		index:=index MOD CN
	END
END push;

PROCEDURE draw;
VAR
	i:LONGINT;
	scale:REAL;
BEGIN
	GL.SetFCR();
	GL.glEnable(GLC.GL_LIGHTING);
	GL.glEnable( GLC.GL_TEXTURE_2D);
	GL.glDisable( GLC.GL_BLEND);
	FOR i:=0 TO index-1 DO	
		GL.DelFCR();
		scale:=1/q[i].scale;
		GL.SetFCR();
		GL.glPushMatrix;
		GL.glTranslatef(q[i].xyz.x, q[i].xyz.z, q[i].xyz.y); 
		GL.glScalef(scale,scale,scale);
		GL.glBindTexture( GLC.GL_TEXTURE_2D, q[i].texture[0]); 
		GL.glBegin( GLC.GL_QUADS);		
  		GL.glNormal3f( 0.0, 0.0, 1.0);
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f(  1.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f(  1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	
	  	GL.glNormal3f( 0.0, 0.0, -1.0);
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f(  1.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f(  1.0, 0.0, 0.0 );

	  	GL.glNormal3f( 0.0, 1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f(  1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f(  1.0,  1.0, 0.0 );
	  	
	  	GL.glNormal3f( 0.0, -1.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f(  1.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f(  1.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  		
	  	GL.glNormal3f( 1.0, 0.0, 0.0);
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 1.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 1.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 1.0, 0.0,  1.0 );
  	
	  	GL.glNormal3f( -1.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );	
	  	GL.glEnd;
		GL.glPopMatrix;
	END;
	 GL.DelFCR()	
END draw;

END Cubes;

TYPE alphaCubes=OBJECT
VAR
	q:ARRAY CN OF Cube;
	index,dlist*: LONGINT;
		
PROCEDURE flush;
BEGIN
	index:=0;
END flush;
	
PROCEDURE push(p:PT; scale:REAL; texture:Texture);
VAR
	a,b,c,d:LONGINT;
BEGIN{EXCLUSIVE}
	a:=ENTIER(p.x*TTP);
	b:=ENTIER(p.y*TTP);	
	c:=ENTIER(p.z*TTP);	
	IF ~alphafilter.probe(a,b,c,scale) THEN
		alphafilter.hash(a,b,c,scale);
		q[index].xyz:=p;
		q[index].scale:=scale;		
	;	q[index].texture:=texture;	
		INC(index);
		index:=index MOD CN
	END
END push;

PROCEDURE draw;
VAR
	i:LONGINT;
	scale:REAL;
BEGIN
	GL.SetFCR();
	GL.glEnable( GLC.GL_BLEND);
	GL.glEnable( GLC.GL_POLYGON_STIPPLE);
	GL.glPolygonStipple (S.ADR(halftone[0]));
 	 FOR i:=0 TO index-1 DO	
		GL.DelFCR();
		scale:=1/q[i].scale;
		GL.SetFCR();
		GL.glPushMatrix;
		GL.glTranslatef(q[i].xyz.x, q[i].xyz.z, q[i].xyz.y); 
		GL.glScalef(scale,scale,scale);
		GL.glBindTexture( GLC.GL_TEXTURE_2D, q[i].texture[0]); 
		GL.glBegin( GLC.GL_QUADS);		
  		GL.glNormal3f( 0.0, 0.0, 1.0);
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f(  1.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f(  1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	
	  	GL.glNormal3f( 0.0, 0.0, -1.0);
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f(  1.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f(  1.0, 0.0, 0.0 );

	  	GL.glNormal3f( 0.0, 1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f(  1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f(  1.0,  1.0, 0.0 );
	  	
	  	GL.glNormal3f( 0.0, -1.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f(  1.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f(  1.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  		
	  	GL.glNormal3f( 1.0, 0.0, 0.0);
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 1.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 1.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 1.0, 0.0,  1.0 );
  	
	  	GL.glNormal3f( -1.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );	
	  	GL.glEnd;
		GL.glPopMatrix;
	END;
	GL.glDisable( GLC.GL_POLYGON_STIPPLE);
	GL.DelFCR()
END draw;

END alphaCubes;

TYPE fleetingCubes=OBJECT
VAR
	q:ARRAY 1000 OF Cube;
	index,dlist*: LONGINT;

PROCEDURE flush;
BEGIN
	index:=0;
END flush;
	
PROCEDURE push(p:PT; scale:REAL; texture:Texture);
VAR
	a,b,c,d:LONGINT;
BEGIN{EXCLUSIVE}
	a:=ENTIER(p.x*TTP);
	b:=ENTIER(p.y*TTP);	
	c:=ENTIER(p.z*TTP);	
	IF ~fleetingfilter.probe(a,b,c,scale) THEN
		fleetingfilter.hash(a,b,c,scale);
		q[index].xyz:=p;
		q[index].scale:=scale;		
		q[index].texture:=texture;	
		INC(index);
	END
END push;

PROCEDURE draw;
VAR
	i:LONGINT;
	scale:REAL;
BEGIN
	GL.SetFCR();
	GL.glEnable(GLC.GL_LIGHTING);
	GL.glEnable( GLC.GL_TEXTURE_2D);
	GL.glDisable( GLC.GL_BLEND);
	GL.glEnable(GLC.GL_CULL_FACE); 
	FOR i:=0 TO index-1 DO	
		GL.DelFCR();
		scale:=1/q[i].scale;
		GL.SetFCR();
		GL.glPushMatrix;		
		GL.glTranslatef(q[i].xyz.x, q[i].xyz.z, q[i].xyz.y); 
		GL.glScalef(scale,scale,scale);
		GL.glBindTexture( GLC.GL_TEXTURE_2D, q[i].texture[0]); 
		GL.glBegin( GLC.GL_QUADS);		
  		GL.glNormal3f( 0.0, 0.0, 1.0);
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f(  1.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f(  1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	
	  	GL.glNormal3f( 0.0, 0.0, -1.0);
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f(  1.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f(  1.0, 0.0, 0.0 );

	  	GL.glNormal3f( 0.0, 1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f(  1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f(  1.0,  1.0, 0.0 );
	  	
	  	GL.glNormal3f( 0.0, -1.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f(  1.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f(  1.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  		
	  	GL.glNormal3f( 1.0, 0.0, 0.0);
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 1.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 1.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 1.0, 0.0,  1.0 );
  	
	  	GL.glNormal3f( -1.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );	
	  	GL.glEnd;
		GL.glPopMatrix;
	END;
	 GL.DelFCR()	
END draw;

END fleetingCubes;

TYPE NCubes=OBJECT
VAR
	q:ARRAY 100000 OF NCube;
	index,dlist*: LONGINT;

PROCEDURE flush;
BEGIN
	index:=0;
END flush;
	
PROCEDURE push(p:PT; scale:REAL; normal: PT; texture:Texture);
VAR
	a,b,c,d:LONGINT;
BEGIN{EXCLUSIVE}
	a:=ENTIER(p.x*TTP);
	b:=ENTIER(p.y*TTP);	
	c:=ENTIER(p.z*TTP);	
	IF ~filter.probe(a,b,c,scale) THEN
		filter.hash(a,b,c,scale);
		q[index].xyz:=p;
		q[index].scale:=scale;		
		q[index].normal:=normal;		
		q[index].texture:=texture;	
		INC(index);
	END
END push;

PROCEDURE draw;
VAR
	i:LONGINT;
	scale:REAL;
BEGIN
	GL.SetFCR();
		GL.glEnable(GLC.GL_LIGHTING);
		GL.glEnable( GLC.GL_TEXTURE_2D);
		GL.glDisable( GLC.GL_BLEND);
	FOR i:=0 TO index-1 DO	
		GL.DelFCR();
		scale:=1/q[i].scale;
		GL.SetFCR();
		GL.glPushMatrix;
		GL.glTranslatef(q[i].xyz.x, q[i].xyz.z, q[i].xyz.y); 
		GL.glScalef(scale,scale,scale);
		GL.glBindTexture( GLC.GL_TEXTURE_2D, q[i].texture[0]); 
		GL.glBegin( GLC.GL_QUADS);		
  		GL.glNormal3f( q[i].normal.x,q[i].normal.y,q[i].normal.z);
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f(  1.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f(  1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f(  1.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f(  1.0, 0.0, 0.0 );
	  	
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f(  1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f(  1.0,  1.0, 0.0 );
	  	

	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f(  1.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f(  1.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  		
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 1.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 1.0,  1.0, 0.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 1.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 1.0, 0.0,  1.0 );
  	
	  	GL.glTexCoord2f( 1.0, 0.0 ); GL.glVertex3f( 0.0, 0.0, 0.0 );
	  	GL.glTexCoord2f( 0.0, 0.0 ); GL.glVertex3f( 0.0, 0.0,  1.0 );
	  	GL.glTexCoord2f( 0.0, 1.0 ); GL.glVertex3f( 0.0,  1.0,  1.0 );
	  	GL.glTexCoord2f( 1.0, 1.0 ); GL.glVertex3f( 0.0,  1.0, 0.0 );	
	  	GL.glEnd;
		GL.glPopMatrix;
	END;
	GL.DelFCR()
END draw;

END NCubes;

TYPE Dllist=OBJECT
VAR
	q:ARRAY CN OF DLCube;
	index: LONGINT;

PROCEDURE flush;
BEGIN
	index:=0;
END flush;

PROCEDURE push(p:PT;  scale,rot: REAL; dlist: LONGINT);
VAR
	a,b,c,d:LONGINT;
BEGIN{EXCLUSIVE}
	a:=ENTIER(p.x*TTP);
	b:=ENTIER(p.y*TTP);	
	c:=ENTIER(p.z*TTP);	
	q[index].xyz:=p;
	q[index].scale:=scale;
	q[index].rot:=rot;	
	q[index].dlist:=dlist;					
	INC(index);
	index:=index MOD CN
END push;

PROCEDURE draw;
VAR
	i:LONGINT;
	scale:REAL;
BEGIN
	GL.SetFCR();
	GL.glEnable(GLC.GL_CULL_FACE); 
	GL.glColor4f(0.9,0.5,0.95,0.7);
	GL.glEnable(GLC.GL_BLEND);
	GL.glBlendFunc(GLC.GL_SRC_ALPHA, GLC.GL_ONE_MINUS_SRC_ALPHA);
	FOR i:=0 TO index-1 DO	
		GL.DelFCR();
		scale:=1/q[i].scale;
		GL.SetFCR();
		GL.glPushMatrix;
		GL.glTranslatef(q[i].xyz.x, q[i].xyz.z, q[i].xyz.y); 
		GL.glScalef(scale,scale,scale);
		GL.glRotatef(q[i].rot, 0,1,0);
		GL.glCallList(q[i].dlist);
		GL.glPopMatrix;
	END;
	GL.glDisable(GLC.GL_BLEND);
	GL.glEnable(GLC.GL_CULL_FACE); 		
	GL.DelFCR()
END draw;
	
END Dllist;

VAR
	persistentcubes: ARRAY 67 OF Cubes;		
	npersistentcubes: ARRAY 67 OF NCubes;	
	alphacubes: alphaCubes;
	fleetingcubes: fleetingCubes;
	i: INTEGER;
	dllist: Dllist;
	filter, alphafilter, fleetingfilter: XNXLBloom.Filter;
	frame, n: INTEGER;
	fly, halftone: Stipples;
		
PROCEDURE push*(p:PT; scale:REAL; texture:Texture);
BEGIN
	persistentcubes[n].push(p,scale,texture) 
END push;

PROCEDURE alphapush*(p:PT; scale:REAL; texture:Texture);
BEGIN
	alphacubes.push(p,scale,texture)
END alphapush;

PROCEDURE fleetingpush*(p:PT; scale:REAL; texture:Texture);
BEGIN
	fleetingcubes.push(p,scale,texture)
END fleetingpush;

PROCEDURE npush*(p:PT; scale:REAL; normal: PT; texture:Texture);
BEGIN
	npersistentcubes[n].push(p,scale,normal,texture)
END npush;

PROCEDURE dlpush*(p:PT; scale:REAL; rot: REAL; dlist: LONGINT);
BEGIN
	dllist.push(p,scale,rot, dlist)
END dlpush;

PROCEDURE draw*;
BEGIN
	FOR i:=0 TO 16 DO
		persistentcubes[i].draw;
		npersistentcubes[i].draw
	END;
	fleetingdraw;		
	alphadraw;
	INC(frame);
	frame:=frame MOD 17;
	persistentcubes[frame].flush;	
	npersistentcubes[frame].flush;	
	IF frame=0 THEN filter.flush END;
END draw;

PROCEDURE alphadraw*;
BEGIN
	alphacubes.draw;		
	alphacubes.flush;
	alphafilter.flush;		
END alphadraw;		

PROCEDURE fleetingdraw*;
BEGIN
	fleetingcubes.draw;		
	fleetingcubes.flush;
	fleetingfilter.flush;		
END fleetingdraw;		

BEGIN
				fly := [ 0X,  0X,  0X,  0X,  0X,  0X,  0X,  0X,
				03X,  80X,  01X,  0C0X,  06X,  0C0X,  03X,  60X, 
 				04X,  60X,  06X,  20X,  04X,  30X,  0CX,  20X, 
 				04X,  18X,  18X,  20X,  04X,  0CX,  30X,  20X,
 				04X,  06X,  60X,  20X,  44X,  03X,  0C0X,  22X, 
 				44X,  01X,  80X,  22X,  44X,  01X,  80X,  22X, 
 				44X,  01X,  80X,  22X,  44X,  01X,  80X,  22X,
 				44X,  01X,  80X,  22X,  44X,  01X,  80X,  22X, 
 				66X,  01X,  80X,  66X,  33X,  01X,  80X,  0CCX, 
 				19X,  81X,  81X,  98X,  0CX,  0C1X,  83X,  30X,
 				07X,  0E1X,  87X,  0E0X,  03X,  3FX,  0FCX,  0C0X, 
 				03X,  31X,  8CX,  0C0X,  03X,  33X,  0CCX,  0C0X, 
				06X,  64X,  26X,  60X,  0CX,  0CCX,  33X,  30X,
 				18X,  0CCX,  33X,  18X,  10X,  0C4X,  23X,  08X, 
 				10X,  63X,  0C6X,  08X,  10X,  30X,  0CX,  08X, 
 				10X,  18X,  18X,  08X,  10X,  00X,  00X,  08X];

			 halftone := [   0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
 				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X, 
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X,
				0AAX,  0AAX,  0AAX,  0AAX,  55X,  55X,  55X,  55X];
				
	FOR i:=0 TO 16 DO
		NEW(persistentcubes[i]);
		NEW(npersistentcubes[i]);
	END;
	NEW(alphacubes);	
	NEW(fleetingcubes);
	NEW(dllist);
	NEW(filter);
	NEW(fleetingfilter);
	NEW(alphafilter);
	frame:=0;
	n:=0	
END XNXLGL.

