MODULE WMGLWindow; (** AUTHOR "fnecati"; PURPOSE "an OpenGL Context enabled WM.Window using GLXPixmap for LinuxAos"; *)
IMPORT
	WM := WMWindowManager, KernelLog, GLContext := GLContext, WMMessages;

CONST debug = TRUE;

TYPE Context = GLContext.Context;

TYPE
	Window* =  OBJECT(WM.DoubleBufferWindow)
	VAR
		context {UNTRACED} : Context;

		PROCEDURE &Init*(w, h: LONGINT; alpha: BOOLEAN);
		BEGIN
			Init^(w, h, alpha); (* use alpha, for 32bpp img *)
			NEW(context);
			context.Init( w, h);
		END Init;

		(** *)
		PROCEDURE Close*();
		BEGIN
			context.Close();
			context := NIL;
			Close^;
		END Close;

		PROCEDURE MakeCurrent*();
		BEGIN
			context.MakeCurrent();
		(*	GLShaderUtils.PrintOpenGLError("ERROR Context.MakeCurrent: "); *)
		END MakeCurrent;

		PROCEDURE DeActivate*();
		BEGIN
			context.DeActivate();
		END DeActivate;

		PROCEDURE SwapGLBuffer*();
		BEGIN
			context.RenderInto(backImg);
		END SwapGLBuffer;

		PROCEDURE Reshape*(w,h: LONGINT);
		END Reshape;

		PROCEDURE UpdateImage*();
		END UpdateImage;

		PROCEDURE MyResized(w, h: LONGINT);
		BEGIN
			IF (backImg = NIL) OR (backImg.adr = NIL) THEN RETURN END;

			ReInit(w, h);
			IF context.Resize(w, h) THEN

				Reshape(w, h);
				UpdateImage;
			(*	KernelLog.String("WMGLWindow Resized TRUE"); KernelLog.Ln; *)
			ELSE
(*				KernelLog.String("WMGLWindow Resized FALSE"); KernelLog.Ln; *)
			END;
		END MyResized;

		PROCEDURE Handle*(VAR m : WMMessages.Message);
		BEGIN
			IF m.msgType = WMMessages.MsgResized THEN
				MyResized(m.x, m.y);
			ELSE
				Handle^(m);
			END;
		END Handle;

		PROCEDURE GetDisplay*(): LONGWORD;
		BEGIN
			RETURN context.GetDisplay();
		END GetDisplay;

		PROCEDURE GetContext*(): LONGWORD;
		BEGIN
			RETURN context.GetContext();
		END GetContext;

		PROCEDURE GetScreen*(): LONGINT;
		BEGIN
			RETURN 0; (*context.glWin.screen *)
		END GetScreen;

	END Window;

BEGIN
END WMGLWindow.

System.Free WMGLWindow ~

System.FreeDownTo OpenGL ~ 