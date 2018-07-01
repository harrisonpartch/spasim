MODULE WMGLDemo2; (** AUTHOR "fnecati"; PURPOSE " axolotl-felix opengl implemetation in Oberon"; *)
 (*  	http://code.google.com/p/axolotl-felix/ *)

IMPORT
	Raster, WMRectangles, Strings, Modules, WMGraphics,
	WM := WMWindowManager,  WMMessages, KernelLog,
	GL := OpenGL, GLC := OpenGLConst, GLU, WMGL:=WMGLWindow;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	GLWindow =  OBJECT(WMGL.Window)
	VAR
		drawMode:LONGINT; (* fill, lines, points *)
		texture: ARRAY 3 OF GL.Uint;  (* Storage For 3 Textures  *)
		LightAmbient, LightDiffuse, LightPosition: ARRAY [4] OF GL.Float;
		xrot, yrot: REAL;  (* X, Y  rotation *)
		z : REAL; (* depth into the screen *)
		xspeed, yspeed: REAL;
		light, blend: BOOLEAN; (* Whether or not lighting is on,  Whether or not blending is on *)
		filter: LONGINT; (* type of filter *)

		PROCEDURE &New(w, h: LONGINT);
		BEGIN
			Init(w, h, FALSE); (* use alpha, for 32bpp img *)
			WM.DefaultAddWindow(SELF);
			SetTitle(Strings.NewString("WMGLDemo2: axolotl"));
			IncCount;

			IF ~InitGL() THEN Close() END;
		 	Reshape(w, h);
			UpdateImage;

		  END New;

		PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
		BEGIN
			CASE CHR(ucs) OF
				 "t" : Testspeed;
				| "d": drawMode := (drawMode+1) MOD 3; DrawMode(drawMode); UpdateImage;
				| "f": filter := (filter +1) MOD 3; 	UpdateImage;
				| "x" : xrot := xrot - 5.0; UpdateImage;
				| "X" : xrot := xrot+ 5.0; UpdateImage;
				| "y" : yrot := yrot - 5.0; UpdateImage;
				| "Y" : yrot := yrot+ 5.0; UpdateImage;

				| "l": light := ~ light;
						MakeCurrent();
						IF light THEN GL.Enable(GLC.GL_LIGHTING ); ELSE  GL.Disable(GLC.GL_LIGHTING ); END;
						DeActivate();
						UpdateImage;

				| "b": blend := ~blend;
						MakeCurrent();
						IF blend THEN
					          GL.Enable( GLC.GL_BLEND );
							GL.Disable( GLC.GL_DEPTH_TEST );
						ELSE
							GL.Disable( GLC.GL_BLEND );
							GL.Enable( GLC.GL_DEPTH_TEST );
						END;
						DeActivate();
						UpdateImage;

				| "q" : Close;
			ELSE

			END;
		END KeyEvent;

		PROCEDURE WheelMove(dz : LONGINT);
		BEGIN
			z := z + dz;
			UpdateImage;
		END WheelMove;

		PROCEDURE Handle(VAR m: WMMessages.Message);
		BEGIN
			IF (m.msgType = WMMessages.MsgExt) & (m.ext # NIL) & (m.ext IS KillerMsg) THEN
				Close;
			ELSE Handle^(m)
			END
		END Handle;

		PROCEDURE Close;
		BEGIN
			Close^;
			DecCount
		END Close;

		PROCEDURE UpdateImage;
		BEGIN
			MakeCurrent();
				Drawing;
			SwapGLBuffer();
			DeActivate();
			Swap();
			Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
		END UpdateImage;

		(* function to load in bitmap as a GL texture *)
		PROCEDURE LoadGLTextures(CONST fname: ARRAY OF CHAR ): BOOLEAN;
		VAR teximg: Raster.Image;
			 res: GL.Int;
		BEGIN
			(* Create storage space for the texture *)
			teximg := WMGraphics.LoadImage(fname, FALSE);
			IF teximg = NIL THEN
				KernelLog.String("Can not load texture file: "); KernelLog.String(fname); KernelLog.Ln;
				RETURN FALSE
		 	END;

		 	(*? image needs to be flipped vertically *)


		 	(* Create The Texture *)
		 	GL.GenTextures( 3, ADDRESSOF(texture[0]) );

		 	(* Typical Texture Generation Using Data From The Bitmap *)
		 	GL.BindTexture( GLC.GL_TEXTURE_2D, texture[0] );

		 	(* Generate The Texture *)
		 	GL.TexImage2D( GLC.GL_TEXTURE_2D, 0, 4, teximg.width, teximg.height, 0,GLC. GL_RGBA,
		 	GLC.GL_UNSIGNED_BYTE, teximg.adr );

		 	(* Linear Filtering *)
		 	GL.TexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_NEAREST);
		 	GL.TexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_NEAREST );

		 	GL.BindTexture(GLC. GL_TEXTURE_2D, texture[1] );

		 	(* Linear Filtering *)
		 	GL.TexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR );
		 	GL.TexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR );

		 	(* Generate The Texture *)
		 	GL.TexImage2D( GLC.GL_TEXTURE_2D, 0, 4, teximg.width,
		 					teximg.height, 0, GLC.GL_RGBA, GLC.GL_UNSIGNED_BYTE, teximg.adr );

		 	GL.BindTexture( GLC.GL_TEXTURE_2D, texture[2] );

		 	(* Linear Filtering *)
		 	GL.TexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR_MIPMAP_NEAREST );
		 	GL.TexParameteri( GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR_MIPMAP_NEAREST );

		 	(* Generate The MipMapped Texture  *)
		 	res := GLU.Build2DMipmaps(GLC.GL_TEXTURE_2D, 4, teximg.width, teximg.height,
		 									GLC.GL_RGBA, GLC.GL_UNSIGNED_BYTE, teximg.adr);

		 	(* Free up any memory we may have used *)
		 	teximg := NIL;
		 	RETURN TRUE;
		END LoadGLTextures;

		PROCEDURE Reshape(w, h: LONGINT);
		BEGIN
			MakeCurrent();
			GL.Viewport(0, 0, w, h);

			GL.MatrixMode(GLC.GL_PROJECTION);
			GL.LoadIdentity();
			GLU.Perspective(45.0, 1.0, 0.1, 100.0);

			GL.MatrixMode(GLC.GL_MODELVIEW);
			GL.LoadIdentity();
			GLU.LookAt(0.0, 0.0, 2.0, 0., 0., 0., 0., 1., 0.);
			DeActivate();
		END Reshape;

		PROCEDURE InitGL(): BOOLEAN;
		BEGIN
			light := FALSE; blend := FALSE;
			xrot := 30.0; yrot := 30.0; z := -10.0;
			xspeed := 0.0; yspeed := 0.0;

			filter := 0;

			LightAmbient :=  [0.5, 0.5, 0.5, 1.0];
			LightDiffuse  := [1.0, 1.0, 1.0, 1.0];
			LightPosition := [0.0, 0.0, 2.0, 1.0];

			(*
			LightAmbient[0] := 0.5; LightAmbient[1] := 0.5; LightAmbient[2] := 0.5; LightAmbient[3] := 1.0;
			LightDiffuse[0] := 1.0; LightDiffuse[1] := 1.0; LightDiffuse[2] := 1.0; LightDiffuse[3] := 1.0;
			LightPosition[0]:= 0.0; LightPosition[1]:= 0.0; LightPosition[2]:= 0.2; LightPosition[3]:= 1.0;
			*)
			MakeCurrent();

			(* Enable Texture Mapping ( NEW ) *)
			GL.Enable( GLC.GL_TEXTURE_2D );

			(* Enable smooth shading *)
			GL.ShadeModel( GLC.GL_SMOOTH );

			(* Set the background black *)
			GL.ClearColor( 0.0, 1.0, 1.0, 0.0 );

			(* Depth buffer setup *)
			GL.ClearDepth( 1.0 );

			(* Enables Depth Testing *)
			GL.Enable( GLC.GL_DEPTH_TEST );

			(* The Type Of Depth Test To Do *)
			GL.DepthFunc( GLC.GL_LEQUAL );

			(* Really Nice Perspective Calculations *)
			GL.Hint( GLC.GL_PERSPECTIVE_CORRECTION_HINT, GLC.GL_NICEST );

			(* Setup The Ambient Light *)
			GL.Lightfv( GLC.GL_LIGHT1, GLC.GL_AMBIENT, LightAmbient );

			(* Setup The Diffuse Light *)
			GL.Lightfv( GLC.GL_LIGHT1, GLC.GL_DIFFUSE, LightDiffuse );

			(* Position The Light *)
			GL.Lightfv( GLC.GL_LIGHT1, GLC.GL_POSITION, LightPosition );

			(* Enable Light One *)
			GL.Enable( GLC.GL_LIGHT1 );

			(* Full Brightness, 50% Alpha ( NEW ) *)
			GL.Color4f( 1.0, 1.0, 1.0, 0.5);

			(* Blending Function For Translucency Based On Source Alpha Value  *)
			GL.BlendFunc( GLC.GL_SRC_ALPHA, GLC.GL_ONE );
			IF ~LoadGLTextures("opengloberon/axolotl.png") THEN RETURN FALSE END;

			DeActivate();
			RETURN TRUE;
		END InitGL;

		PROCEDURE DrawMode(dm: LONGINT);
		VAR drawMode: LONGINT;
		BEGIN
			drawMode := dm;
			MakeCurrent();
			IF drawMode = 0 THEN       (* fill mode*)
				GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_FILL);
				GL.Enable(GLC.GL_DEPTH_TEST);
				GL.Enable(GLC.GL_CULL_FACE);
			ELSIF drawMode = 1 THEN  (* wireframe mode *)
				GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_LINE);
				GL.Disable(GLC.GL_DEPTH_TEST);
				GL.Disable(GLC.GL_CULL_FACE);
			ELSE    (* point mode *)

				GL.PolygonMode(GLC.GL_FRONT_AND_BACK, GLC.GL_POINT);
				GL.Disable(GLC.GL_DEPTH_TEST);
				GL.Disable(GLC.GL_CULL_FACE);
			END;
			DeActivate();
		END DrawMode;

		PROCEDURE Drawing;
		BEGIN
			GL.Clear( GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT );
			GL.LoadIdentity( );
			GL.Translatef( 0.0, 0.0, z );
			GL.Rotatef( xrot, 1.0, 0.0, 0.0);
			GL.Rotatef( yrot, 0.0, 1.0, 0.0);
			GL.BindTexture( GLC.GL_TEXTURE_2D, texture[filter] );

			Cube();

			GL.LoadIdentity( );
			GL.Translatef( 1.5, -1.5, z + 2.0);
			GL.Rotatef( yrot, 1.0, 0.0, 0.0);
			GL.Rotatef( xrot, 0.0, 1.0, 0.0);

			Cube();

			GL.LoadIdentity( );
			GL.Translatef( 1.5, 1.5, z );
			GL.Rotatef( yrot, 1.0, 1.0, 0.0);
			GL.Rotatef( xrot, 0.0, 1.0, 0.0);

			Cube();
		END Drawing;

		PROCEDURE Cube();
		BEGIN
			(* MakeCurrent(); *)

			GL.Begin( GLC.GL_QUADS );
			GL.Normal3f( 0.0, 0.0, 1.0 );
			GL.TexCoord2f( 1.0, 0.0 ); GL.Vertex3f( -1.0, -1.0,  1.0 );
			GL.TexCoord2f( 0.0, 0.0 ); GL.Vertex3f(  1.0, -1.0,  1.0 );
			GL.TexCoord2f( 0.0, 1.0 ); GL.Vertex3f(  1.0,  1.0,  1.0 );
			GL.TexCoord2f( 1.0, 1.0 ); GL.Vertex3f( -1.0,  1.0,  1.0 );

			GL.Normal3f( 0.0, 0.0, -1.0);
			GL.TexCoord2f( 0.0, 0.0 ); GL.Vertex3f( -1.0, -1.0, -1.0 );
			GL.TexCoord2f( 0.0, 1.0 ); GL.Vertex3f( -1.0,  1.0, -1.0 );
			GL.TexCoord2f( 1.0, 1.0 ); GL.Vertex3f(  1.0,  1.0, -1.0 );
			GL.TexCoord2f( 1.0, 0.0 ); GL.Vertex3f(  1.0, -1.0, -1.0 );

			GL.Normal3f( 0.0, 1.0, 0.0 );
			GL.TexCoord2f( 1.0, 1.0 ); GL.Vertex3f( -1.0,  1.0, -1.0 );
			GL.TexCoord2f( 1.0, 0.0 ); GL.Vertex3f( -1.0,  1.0,  1.0 );
			GL.TexCoord2f( 0.0, 0.0 ); GL.Vertex3f(  1.0,  1.0,  1.0 );
			GL.TexCoord2f( 0.0, 1.0 ); GL.Vertex3f(  1.0,  1.0, -1.0 );

			GL.Normal3f( 0.0, -1.0, 0.0 );
			GL.TexCoord2f( 0.0, 1.0 ); GL.Vertex3f( -1.0, -1.0, -1.0 );
			GL.TexCoord2f( 1.0, 1.0 ); GL.Vertex3f(  1.0, -1.0, -1.0 );
			GL.TexCoord2f( 1.0, 0.0 ); GL.Vertex3f(  1.0, -1.0,  1.0 );
			GL.TexCoord2f( 0.0, 0.0 ); GL.Vertex3f( -1.0, -1.0,  1.0 );

			GL.Normal3f( 1.0, 0.0, 0.0);

			GL.TexCoord2f( 0.0, 0.0 ); GL.Vertex3f( 1.0, -1.0, -1.0 );
			GL.TexCoord2f( 0.0, 1.0 ); GL.Vertex3f( 1.0,  1.0, -1.0 );
			GL.TexCoord2f( 1.0, 1.0 ); GL.Vertex3f( 1.0,  1.0,  1.0 );
			GL.TexCoord2f( 1.0, 0.0 ); GL.Vertex3f( 1.0, -1.0,  1.0 );

			GL.Normal3f( -1.0, 0.0, 0.0 );
			GL.TexCoord2f( 1.0, 0.0 ); GL.Vertex3f( -1.0, -1.0, -1.0 );
			GL.TexCoord2f( 0.0, 0.0 ); GL.Vertex3f( -1.0, -1.0,  1.0 );
			GL.TexCoord2f( 0.0, 1.0 ); GL.Vertex3f( -1.0,  1.0,  1.0 );
			GL.TexCoord2f( 1.0, 1.0 ); GL.Vertex3f( -1.0,  1.0, -1.0 );
			GL.End();
		END Cube;

		PROCEDURE Testspeed;
		VAR i: LONGINT;
		BEGIN
			FOR i:=1 TO 360 DO
				xrot := xrot + 2;
				UpdateImage;
			END;
		END Testspeed;

	BEGIN

	END GLWindow;

VAR
	nofWindows : LONGINT;

PROCEDURE Open*;
VAR
	window : GLWindow;
BEGIN
	NEW(window, 256, 256);
END Open;

PROCEDURE IncCount;
BEGIN {EXCLUSIVE}
	INC(nofWindows)
END IncCount;

PROCEDURE DecCount;
BEGIN {EXCLUSIVE}
	DEC(nofWindows)
END DecCount;

PROCEDURE Cleanup;
VAR die : KillerMsg;
	 msg : WMMessages.Message;
	 m : WM.WindowManager;
BEGIN {EXCLUSIVE}
	NEW(die);
	msg.ext := die;
	msg.msgType := WMMessages.MsgExt;
	m := WM.GetDefaultManager();
	m.Broadcast(msg);
	AWAIT(nofWindows = 0)
END Cleanup;

BEGIN
	Modules.InstallTermHandler(Cleanup)
END WMGLDemo2.

System.Free  WMGLDemo2   ~

WMGLDemo2.Open ~
