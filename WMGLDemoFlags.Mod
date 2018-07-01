MODULE WMGLDemoFlags; (** AUTHOR "fnecati"; PURPOSE "Flags simulation demo"; *)
(*  translation from HeNe lesson11a: *)
IMPORT
	WMRectangles, WMGraphics, Strings, Kernel, Raster, Math, Modules,
	WM := WMWindowManager,  WMMessages,
	GL := OpenGL, GLC := OpenGLConst, GLU, WMGL:=WMGLWindow;

CONST
		waittime=50;

TYPE
	KillerMsg = OBJECT
	END KillerMsg;

	Points=ARRAY 45, 45, 3 OF GL.Float;

	GLWindow =  OBJECT(WMGL.Window)
	VAR
		 timer: Kernel.MilliTimer;

		alive, animated: BOOLEAN;

		xrot: GL.Float;                 (* Rotate v about x *)
 		yrot: GL.Float;                    (* Rotate v about y *)
 		zrot: GL.Float;                    (* Rotate v about z *)
		texture, texture2:  GL.Uint;  (*  handles for texture *)
		wigglecount, wigglecount2: LONGINT;        (* Rychlost vln*)
		hold: GL.Float;                    (* Pomocnk zajilynulosti pohybu *)
		points, points2:  Points;  (* flag vertice points *)

	PROCEDURE &New(w, h: LONGINT);
	BEGIN
		Init(w, h, FALSE); (* use alpha, for 32bpp img *)
		WM.DefaultAddWindow(SELF);
		SetTitle(Strings.NewString("WMGLDemoFlags: Flags"));

		wigglecount := 0; wigglecount2 := 0;
		animated := FALSE;
		alive := TRUE;

		initGL;
		Reshape(w, h);
		UpdateImage;
		IncCount
	  END New;

	PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
	BEGIN
		IF  ucs = ORD("q") THEN Close;
		ELSIF  ucs = ORD("a") THEN BEGIN {EXCLUSIVE} animated := ~ animated; END;
		ELSE
		END;
	END KeyEvent;

	PROCEDURE WheelMove(dz : LONGINT);
	BEGIN
		Reshape(GetWidth(), GetHeight());
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
		BEGIN {EXCLUSIVE} alive := FALSE; animated := FALSE END;
		Close^;
		DecCount
	END Close;

	PROCEDURE UpdateImage;
	BEGIN
		MakeCurrent();
			displayCB();
			SwapGLBuffer();
		DeActivate();
		Swap();
		Invalidate(WMRectangles.MakeRect(0, 0, GetWidth(), GetHeight()));
	END UpdateImage;

	PROCEDURE Reshape(w, h: LONGINT);
	BEGIN
		  MakeCurrent();
		  GL.Viewport(0, 0, w, h);
		  (* Resetuje aktuastaven  *)
		  GL.MatrixMode(GLC.GL_PROJECTION);     (* projection matrix *)
		  GL.LoadIdentity();                                       (* Reset matrix *)
		  GLU.Perspective(45.0, 1.0 ,0.1,100.0);           (*  perspective view *)

		  GL.MatrixMode(GLC.GL_MODELVIEW);   (* model view matrix *)
		  GL.LoadIdentity;        (* Reset matix *)
		  DeActivate();
	END Reshape;

	PROCEDURE initGL();
	VAR x, y: LONGINT;
	BEGIN
		MakeCurrent();

		texture := LoadTexture("opengloberon/europe.png");

		texture2 := LoadTexture("opengloberon/turkiye.png");


		GL.Enable(GLC.GL_TEXTURE_2D);                          (* Zapne mapov textur*)
		GL.ShadeModel(GLC.GL_SMOOTH);			                    (* Povolemntv*)
		GL.ClearColor(0.0, 0.0, 0.0, 0.5);	  	            (* rnozad  *)
		GL.ClearDepth(1.0);				                        (* Nastavenloubkov bufferu*)
		GL.Enable(GLC.GL_DEPTH_TEST);			                    (* Povolloubkovestov*)
		GL.DepthFunc(GLC.GL_LEQUAL);				                    (* Typ hloubkov testov *)
		GL.Hint(GLC.GL_PERSPECTIVE_CORRECTION_HINT, GLC.GL_NICEST); (* Nejleppektivnorekce *)
		GL.PolygonMode(GLC.GL_BACK, GLC.GL_FILL);                  (* P strana vypln polygony *)
		(*GL.PolygonMode(GLC.GL_FRONT, GLC.GL_LINE);*)                 (* Zadntrana vypln mu *)
		GL.PolygonMode(GLC.GL_FRONT, GLC.GL_FILL);
		FOR x:=0 TO 44 DO                                 (* initialize vertices *)
			FOR y:=0 TO 44 DO
				points[x,y,0] := x/5 - 4.5;
				points[x,y,1] := y/5 - 4.5;
				points[x,y,2] := Math.sin((((x/5)*40)/360)*2*Math.pi);
			END;
		END;

		FOR x:=0 TO 44 DO                                 (* initialize vertices *)
			FOR y:=0 TO 44 DO
				points2[x,y,0] := x/5 - 1.5;
				points2[x,y,1] := y/5 - 1.5;
				points2[x,y,2] := Math.sin((((x/5)*40)/360)*2*Math.pi);
			END;
		END;
		DeActivate();
	END initGL;

	PROCEDURE LoadTexture(CONST fname: ARRAY OF CHAR): GL.Uint;
	VAR teximg: Raster.Image;
		tex: GL.Uint;
	BEGIN
		teximg := WMGraphics.LoadImage(fname, FALSE);
		ASSERT(teximg # NIL, 220 );

	 	GL.GenTextures(1, ADDRESSOF(tex));
	 	GL.BindTexture(GLC.GL_TEXTURE_2D, tex);
	 	GL.TexImage2D(GLC.GL_TEXTURE_2D, 0, GLC.GL_RGBA, teximg.width, teximg.height, 0, GLC.GL_BGRA, GLC.GL_UNSIGNED_BYTE, teximg.adr);
	 	GL.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MAG_FILTER, GLC.GL_LINEAR);
	 	GL.TexParameteri(GLC.GL_TEXTURE_2D, GLC.GL_TEXTURE_MIN_FILTER, GLC.GL_LINEAR);
	 	RETURN tex;
	END LoadTexture;

	PROCEDURE displayEurope;
	VAR
		x, y: LONGINT;
		float_x, float_y, float_xb, float_yb: GL.Float;
	 BEGIN
		GL.Clear(GLC.GL_COLOR_BUFFER_BIT + GLC.GL_DEPTH_BUFFER_BIT);  (* Smazovku a hloubkover *)

		GL.LoadIdentity();	                                    (* Reset matix *)

		GL.Translatef(0.0,0.0,-12.0);                          (* Posunuto obrazovky *)
		GL.Rotatef(xrot,1.0,0.0,0.0);                          (* Rotace na ose x *)
		GL.Rotatef(yrot,0.0,1.0,0.0);                          (* Rotace na ose y *)
		GL.Rotatef(zrot,0.0,0.0,1.0);                          (* Rotace na ose z *)


		GL.BindTexture(GLC.GL_TEXTURE_2D, texture);              (* Vextury *)
		GL.Begin(GLC.GL_QUADS);                                    (* Zaek kreslentverc  *)
		FOR x:=0 TO 43 DO                                   (* Cykly prochjole *)
			FOR y:=0 TO 43 DO
				float_x := x/44;                                (* Vypo texturovordin *)
				float_y := y/44;
				float_xb := (x+1)/44;
				float_yb := (y+1)/44;

				GL.TexCoord2f(float_x, float_y);                  (* Zad jednotlivd  *)
				GL.Vertex3f(points[x,y,0], points[x,y,1], points[x,y,2]);
				GL.TexCoord2f(float_x, float_yb);
				GL.Vertex3f(points[x,y+1,0], points[x,y+1,1], points[x,y+1,2]);
				GL.TexCoord2f(float_xb, float_yb);
				GL.Vertex3f(points[x+1, y+1,0], points[x+1,y+1,1], points[x+1,y+1,2]);
				GL.TexCoord2f(float_xb, float_y);
				GL.Vertex3f(points[x+1,y,0], points[x+1,y,1], points[x+1,y,2]);

			END;
		END;
		GL.End();                                              (* Konec kreslentverc *)

		IF wigglecount = 2 THEN                             (* Pro snnychlosti pohybu *)
			FOR y:=0 TO 44 DO                                   (* Proch hodnoty na y *)
				hold := points[0,y,2];                            (* Ulo vlny *)
				FOR x:=0 TO 43 DO points[x,y,2] := points[x+1,y,2]; END; (* Peno sousedn prvku *)
				points[44,y,2] := hold;                           (* Uloaj bude na druhtran *)
			END;;
			wigglecount := 0;                                  (* Nulov poadla vykreslov *)
	  	ELSE wigglecount := wigglecount + 1;              (* Inkrementace poadla *)
	  	END;
	END displayEurope;

	PROCEDURE displayTurkiye();
	VAR
		x, y: LONGINT;
		float_x, float_y, float_xb, float_yb: GL.Float;
	 BEGIN

		GL.LoadIdentity();	                                    (* Reset matix *)

		GL.Translatef(2.0,0.0,-22.0);                          (* Posunuto obrazovky *)
		GL.Rotatef(xrot,1.0,0.0,0.0);                          (* Rotace na ose x *)
		GL.Rotatef(yrot,0.0,1.0,0.0);                          (* Rotace na ose y *)
		GL.Rotatef(zrot,0.0,0.0,1.0);                          (* Rotace na ose z *)


		GL.BindTexture(GLC.GL_TEXTURE_2D, texture2);              (* Vextury *)
		GL.Begin(GLC.GL_QUADS);                                    (* Zaek kreslentverc  *)
		FOR x:=0 TO 43 DO                                   (* Cykly prochjole *)
			FOR y:=0 TO 43 DO
				float_x := x/44;                                (* Vypo texturovordin *)
				float_y := y/44;
	 			float_xb := (x+1)/44;
	 			float_yb := (y+1)/44;

	 			GL.TexCoord2f(float_x, float_y);                  (* Zad jednotlivd  *)
	 			GL.Vertex3f(points2[x,y,0], points2[x,y,1], points2[x,y,2]);
	 			GL.TexCoord2f(float_x, float_yb);
	 			GL.Vertex3f(points2[x,y+1,0], points2[x,y+1,1], points2[x,y+1,2]);
	 			GL.TexCoord2f(float_xb, float_yb);
	 			GL.Vertex3f(points2[x+1, y+1,0], points2[x+1,y+1,1], points2[x+1,y+1,2]);
	 			GL.TexCoord2f(float_xb, float_y);
	 			GL.Vertex3f(points2[x+1,y,0], points2[x+1,y,1], points2[x+1,y,2]);

	 		END;
	 	END;
	 	GL.End();                                              (* Konec kreslentverc *)

	 	 IF wigglecount2 = 2 THEN                             (* Pro snnychlosti pohybu *)
	 		FOR y:=0 TO 44 DO                                   (* Proch hodnoty na y *)
	 			hold := points2[0,y,2];                            (* Ulo vlny *)
	 			FOR x:=0 TO 43 DO points2[x,y,2] := points2[x+1,y,2]; END; (* Peno sousedn prvku *)
	 			points2[44,y,2] := hold;                           (* Uloaj bude na druhtran *)
	 		END;;
	 		wigglecount2 := 0;                                  (* Nulov poadla vykreslov *)
	 	ELSE wigglecount2 := wigglecount2 + 1;              (* Inkrementace poadla *)
	 	END;
	END displayTurkiye;

	PROCEDURE displayCB();
	BEGIN

		displayEurope;
		xrot := xrot + 0.3;
		yrot := yrot + 0.2;
		zrot := zrot + 0.4;
		displayTurkiye;
	END displayCB;

BEGIN  { ACTIVE }
	Kernel.SetTimer(timer, waittime);
	WHILE alive DO
		BEGIN {EXCLUSIVE} AWAIT(animated) END;
		 IF Kernel.Expired(timer) THEN
		 	 UpdateImage();
			Kernel.SetTimer(timer, waittime);
		END;
	END;
END GLWindow;

VAR
	nofWindows : LONGINT;

PROCEDURE Open*;
VAR
	window: GLWindow;
BEGIN
	NEW(window, 256, 256) ;
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
END WMGLDemoFlags.

System.Free  WMGLDemoFlags  ~

WMGLDemoFlags.Open  ~
