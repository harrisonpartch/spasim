MODULE WMGLWindow; (** AUTHOR "fnecati"; PURPOSE "an OpenGL Context enabled WM.Window using GLXPixmap for LinuxAos"; *)
IMPORT
	WM := WMWindowManager, KernelLog, GLContext;

CONST debug = FALSE;

TYPE Context = GLContext.Context;

TYPE
	Window* =  OBJECT(WM.DoubleBufferWindow)
	VAR
		context : Context;

		PROCEDURE &Init*(w, h: SIZE; alpha: BOOLEAN);
		BEGIN
			Init^(w, h, alpha); (* use alpha, for 32bpp img *)
			NEW(context);
			context.Init( w, h);
		END Init;

		(** *)
		PROCEDURE Close*();
		BEGIN
			context.Close();
			(* context := NIL; *)
			Close^;
		END Close;

		PROCEDURE MakeCurrent*();
		BEGIN
			context.MakeCurrent();
		END MakeCurrent;

		PROCEDURE DeActivate*();
		BEGIN
			context.DeActivate();
		END DeActivate;

		PROCEDURE SwapGLBuffer*();
		BEGIN 
			context.RenderInto(backImg);
		END SwapGLBuffer;

		PROCEDURE Reshape*(w,h: SIZE);
		END Reshape;

		PROCEDURE UpdateImage*();
		END UpdateImage;

		PROCEDURE Resized(w, h: SIZE);
		BEGIN
			IF debug THEN 
				KernelLog.String("wmglwindow.resized w, h = "); KernelLog.Int(w, 0); KernelLog.Int(h, 10); KernelLog.Ln;
			END;
			context.Resize(w, h);
			ReInit(w, h);
			Reshape(w, h);
			UpdateImage;
		END Resized;

		PROCEDURE GetDisplay*(): ADDRESS;
		BEGIN
			RETURN context.GetDisplay();
		END GetDisplay;

		PROCEDURE GetContext*(): ADDRESS;
		BEGIN
			RETURN context.GetContext();
		END GetContext;

		PROCEDURE GetScreen*(): SIGNED32;
		BEGIN
			RETURN 0; (*context.glWin.screen *)
		END GetScreen;

	END Window;

BEGIN
END WMGLWindow.

System.Free WMGLWindow ~

System.FreeDownTo OpenGL ~ 