MODULE GLShadersBuild; (** AUTHOR "fnecati"; PURPOSE "opengl shader program syntax checker"; *)

IMPORT Modules, Strings, WMComponents, WMMessages, WMRestorable, WMEditors, Commands,
	WM:=WMWindowManager, WMGraphics, WMStandardComponents, WMDocumentEditor,
	UndoManager, XML, KernelLog, Streams, TextUtilities, Texts,
	gl := OpenGL, glc := OpenGLConst, GLContext;

TYPE
	Uint = gl.Uint;

CONST
	WindowWidth = 670; WindowHeight = 530;

TYPE

	KillerMsg = OBJECT
	END KillerMsg;

	Window = OBJECT(WMComponents.FormWindow)
	VAR
		fsEditor, vsEditor: WMDocumentEditor.Editor;
		logEditor: WMEditors.Editor;
		buildBut, vertBut, fragBut: WMStandardComponents.Button;
 		um: UndoManager.UndoManager;
     		program: Uint;       (* shader program *)

	PROCEDURE CreateForm(): WMComponents.VisualComponent;
	VAR
		(* label : WMStandardComponents.Label;*)
		panel, tpanel : WMStandardComponents.Panel; (* main and editor panel *)
		toolbar, statusbar: WMStandardComponents.Panel;
		vsizer : WMStandardComponents.Resizer;
		grpanel: WMStandardComponents.GroupPanel; (* groupbox panel *)
	BEGIN
		(*  Main Panel holding the tabs, toolbar and contents  *)

		NEW(panel); panel.alignment.Set(WMComponents.AlignClient); panel.fillColor.Set(0FFFFFFFFH);
		panel.takesFocus.Set(TRUE);


		NEW(toolbar); toolbar.bounds.SetHeight(25); toolbar.alignment.Set(WMComponents.AlignTop);
		toolbar.fillColor.Set(0DDDDDDFFH);
		panel.AddContent(toolbar);

		(* build button *)
		NEW(buildBut); buildBut.bounds.SetWidth(120); buildBut.caption.SetAOC("Build All");
		buildBut.alignment.Set(WMComponents.AlignLeft);
		buildBut.onClick.Add(GLBuild);
		toolbar.AddContent(buildBut);


		(* compile vertex button *)
		NEW(vertBut); vertBut.bounds.SetWidth(120); vertBut.caption.SetAOC("Compile Vertex");
		vertBut.alignment.Set(WMComponents.AlignLeft);
		vertBut.onClick.Add(CompileVertex);
		toolbar.AddContent(vertBut);

		(* compile fragment button *)
		NEW(fragBut); fragBut.bounds.SetWidth(120); fragBut.caption.SetAOC("Compile Fragment");
		fragBut.alignment.Set(WMComponents.AlignLeft);
		fragBut.onClick.Add(CompileFragment);
		toolbar.AddContent(fragBut);

		(* Editor area*)
		NEW(tpanel); tpanel.alignment.Set(WMComponents.AlignClient);
		tpanel.fillColor.Set(0FFDFFH);
		panel.AddContent(tpanel);



(* --------------vertext shader -------------- *)


		(* group panel, source *)
		NEW(grpanel); grpanel.alignment.Set(WMComponents.AlignTop); grpanel.bounds.SetHeight(200);
		grpanel.fillColor.Set(0FFFFFFFFH); grpanel.caption.SetAOC("vertex shader source:");
		tpanel.AddContent(grpanel);

		(* opengl source fsEditor *)
		NEW(vsEditor);
		vsEditor.alignment.Set(WMComponents.AlignClient);
		(* fsEditor.SetToolbar(WMDocumentEditor.All-WMDocumentEditor.FormatButton);*)
		vsEditor.SetToolbar(WMDocumentEditor.All);
		vsEditor.editor.highlighting.SetAOC("C"); (*? or  put cl types to SytaxHighlighter.XML, Configuration.XML *)
		vsEditor.editor.tv.showLineNumbers.Set(TRUE);
		vsEditor.editor.tv.showBorder.Set(TRUE);
		grpanel.AddContent(vsEditor);



	(* --------------fragment shader -------------- *)
		(* resizer *)
		NEW(vsizer); vsizer.alignment.Set(WMComponents.AlignBottom);	vsizer.bounds.SetHeight(4);
		 vsizer.clDefault.Set(0FFFF00FFH);
		grpanel.AddContent(vsizer);
		(* ---------------- *)

		(* group panel, source *)
		NEW(grpanel); grpanel.alignment.Set(WMComponents.AlignTop); grpanel.bounds.SetHeight(200);
		grpanel.fillColor.Set(0FFFFFFFFH); grpanel.caption.SetAOC("fragment shader source:");
		tpanel.AddContent(grpanel);

		(* opengl source fsEditor *)
		NEW(fsEditor);
		fsEditor.alignment.Set(WMComponents.AlignClient);
		(* fsEditor.SetToolbar(WMDocumentEditor.All-WMDocumentEditor.FormatButton);*)
		fsEditor.SetToolbar(WMDocumentEditor.All);
		fsEditor.editor.highlighting.SetAOC("C"); (*? or  put cl types to SytaxHighlighter.XML, Configuration.XML *)
		fsEditor.editor.tv.showLineNumbers.Set(TRUE);
		fsEditor.editor.tv.showBorder.Set(TRUE);
		grpanel.AddContent(fsEditor);

		(* resizer *)
		NEW(vsizer); vsizer.alignment.Set(WMComponents.AlignBottom);	vsizer.bounds.SetHeight(4);
		 vsizer.clDefault.Set(0FFFF00FFH);
		grpanel.AddContent(vsizer);
		(* ---------------- *)


(*		NEW(statusbar); statusbar.alignment.Set(WMComponents.AlignTop);
		statusbar.fillColor.Set(0FF0FFDFFH); statusbar.bounds.SetHeight(7);

		tpanel.AddContent(statusbar);

		(* resizer *)
		NEW(vsizer); vsizer.alignment.Set(WMComponents.AlignTop);	vsizer.bounds.SetHeight(4);
		 vsizer.clDefault.Set(0FFFF00FFH);
		tpanel.AddContent(vsizer);
*)

(*
		NEW(statusbar); statusbar.alignment.Set(WMComponents.AlignBottom);
		statusbar.fillColor.Set(0FFDFFH); statusbar.bounds.SetHeight(130);

		grpanel.AddContent(statusbar);

		(* resizer *)
		NEW(vsizer); vsizer.alignment.Set(WMComponents.AlignTop);	vsizer.bounds.SetHeight(4);
		 vsizer.clDefault.Set(0FFFF00FFH);
		statusbar.AddContent(vsizer);

*)
		NEW(grpanel); grpanel.bounds.SetHeight(50); grpanel.alignment.Set(WMComponents.AlignTop);
		grpanel.bounds.SetHeight(100);
		grpanel.fillColor.Set(0DDDDDDDDH); grpanel.caption.SetAOC("Build Log:");
		tpanel.AddContent(grpanel);



		(* build result log editor *)
		NEW(logEditor);
		logEditor.alignment.Set(WMComponents.AlignClient);
		logEditor.tv.showBorder.Set(TRUE);

		logEditor.multiLine.Set(TRUE);
		grpanel.AddContent(logEditor);

		RETURN panel
	END CreateForm;

	PROCEDURE &New(c : WMRestorable.Context);
	VAR
		vc : WMComponents.VisualComponent;
	BEGIN
		IncCount;
		 vc := CreateForm();
			IF (c # NIL) THEN
				Init(c.r - c.l, c.b - c.t, FALSE);
			ELSE
				Init(WindowWidth, WindowHeight, FALSE);
			END;

		 SetContent(vc);
		SetTitle(Strings.NewString("GLShadersBuild"));
		(* SetIcon(WMGraphics.LoadImage("OpenCL.png", TRUE)); *)
		SetIcon(WMGraphics.LoadImage("WMBuilder.tar://structure.png", TRUE));

		IF c # NIL THEN (* restore *)
			WMRestorable.AddByContext(SELF, c);
			IF c.appData # NIL THEN
				vsEditor.FromXml(c.appData(XML.Element));
				fsEditor.FromXml(c.appData(XML.Element));
				(*Resized(GetWidth(), GetHeight())*)
			END;
			vc.Invalidate;
		ELSE
			WM.DefaultAddWindow(SELF) ;
		END;
		NEW(um, 1001, TRUE);
		fsEditor.editor.text.SetUndoManager(um);
		fsEditor.editor.SetUndoManager(um);
		context.MakeCurrent();
		context.DeActivate();
	END New;


	PROCEDURE LoadVertexShaderFile(filename: ARRAY OF CHAR);
	BEGIN
		vsEditor.Load(filename, "UTF-8");
		vsEditor.editor.text.SetUndoManager(um)
	END LoadVertexShaderFile;

	PROCEDURE LoadFragmentShaderFile(filename: ARRAY OF CHAR);
	BEGIN
		fsEditor.Load(filename, "UTF-8");
		fsEditor.editor.text.SetUndoManager(um)
	END LoadFragmentShaderFile;

	(* create simple empty shader *)
	PROCEDURE NewEmptyShader*();
	VAR tw: TextUtilities.TextWriter;
		mtext: Texts.Text;
	BEGIN
		(* vertex shader *)
		NEW(mtext);
		mtext.AcquireWrite;
		NEW(tw, mtext);
		tw.String("void main() {"); tw.Ln;
		tw.String("    gl_Position = ftransform();"); tw.Ln;
		tw.String("}"); tw.Ln; tw.Ln; tw.Update;
		mtext.ReleaseWrite;
		vsEditor.editor.SetText(mtext);

		(* fragment shader *)
		NEW(mtext);
		mtext.AcquireWrite;
		NEW(tw, mtext);

		tw.String("void main() {"); tw.Ln;
		tw.String("    "); tw.Ln;
		tw.String("}"); tw.Ln; tw.Ln; tw.Update;

		fsEditor.editor.SetText(mtext);

		mtext.ReleaseWrite;
	END NewEmptyShader;


	PROCEDURE PrintShaderInfoLog(CONST tit: ARRAY OF CHAR; obj: Uint);
	VAR infologLength, charsWritten: LONGINT;
		logInfo: Strings.String;
		info: Strings.String;

	BEGIN
		infologLength := 0;
		charsWritten  := 0;
		gl.GetShaderiv(obj, glc.GL_INFO_LOG_LENGTH, ADDRESSOF(infologLength));
		IF infologLength > 0 THEN
			NEW(info, infologLength);
			gl.GetShaderInfoLog(obj, infologLength, charsWritten, ADDRESSOF(info[0]));

			NEW(logInfo, infologLength + Strings.Length(tit) + 3);
			Strings.Append(logInfo^, tit); Strings.AppendChar(logInfo^, 0AX);
			Strings.Append(logInfo^, info^);
			logEditor.SetAsString(logInfo^);
			info := NIL;
			logInfo := NIL;
		END;
	END PrintShaderInfoLog;

	PROCEDURE PrintProgramInfoLog(obj: Uint);
	VAR infologLength, charsWritten: LONGINT;
		infoLog: Strings.String;
	BEGIN
		infologLength := 0;
		charsWritten  := 0;
		gl.GetProgramiv(obj, glc.GL_INFO_LOG_LENGTH, ADDRESSOF(infologLength));
		IF infologLength > 0 THEN
			NEW(infoLog, infologLength);
			gl.GetProgramInfoLog(obj, infologLength, charsWritten, ADDRESSOF(infoLog[0]));
			logEditor.SetAsString(infoLog^);
			infoLog := NIL;
		END;
	END PrintProgramInfoLog;

	PROCEDURE CompileVertexShader(vertshader : Strings.String): Uint;
	VAR
		vs: Uint;
		vertcompiled: Uint;
		adr : ADDRESS;
		vss: Strings.String;
	BEGIN
		IF vertshader = NIL THEN RETURN -1 END;
		vs := gl.CreateShader(glc.GL_VERTEX_SHADER);
		vss := vertshader;
		(* Load source code strings into shaders *)
		adr := ADDRESSOF(vss[0]);
		gl.ShaderSource(vs, 1, ADDRESSOF(adr), 0);

		gl.CompileShader(vs);
		gl.GetShaderiv(vs, glc.GL_COMPILE_STATUS, ADDRESSOF(vertcompiled));

		IF vertcompiled = glc.GL_FALSE THEN
				PrintShaderInfoLog("Vertex Shader:",  vs);
				gl.DeleteShader(vs);
				RETURN -1;
		END;
		logEditor.SetAsString("SUCCESS");
		RETURN vs;
	END CompileVertexShader;

	PROCEDURE CompileFragmentShader(fragshader: Strings.String): Uint;
	VAR
		fs: Uint;
		fragcompiled: Uint;
		adr: ADDRESS;
	BEGIN
		IF fragshader = NIL THEN RETURN -1 END;
		fs := gl.CreateShader(glc.GL_FRAGMENT_SHADER);
		adr := ADDRESSOF(fragshader[0]);
		gl.ShaderSource(fs, 1, ADDRESSOF(adr), 0);

		 (* Compile the fragment shader and print out the compiler log *)
		gl.CompileShader(fs);
		gl.GetShaderiv(fs, glc.GL_COMPILE_STATUS, ADDRESSOF(fragcompiled));

		IF fragcompiled = glc.GL_FALSE THEN
			PrintShaderInfoLog("Fragment Shader:", fs);
			gl.DeleteShader(fs);
			RETURN -1;
		END;

		logEditor.SetAsString("SUCCESS");
		RETURN fs;
	END CompileFragmentShader;

	PROCEDURE AttachAndLinkProgram(prog, vs, fs: Uint): BOOLEAN;
	VAR 	linked: Uint;
	BEGIN
		gl.AttachShader(prog, vs);
		gl.AttachShader(prog, fs);

		gl.LinkProgram(prog);
		gl.GetProgramiv(prog, glc.GL_LINK_STATUS, ADDRESSOF(linked));
		IF  linked = glc.GL_FALSE THEN

			PrintProgramInfoLog(prog);
		END;

		gl.DeleteShader(fs);
		gl.DeleteShader(vs);

		RETURN linked # glc.GL_FALSE;
	END AttachAndLinkProgram;

	PROCEDURE CompileVertex(sender, data : ANY);
	VAR
	      vss: Strings.String;
	      vs: Uint;
	BEGIN
		logEditor.SetAsString("");
	 	vsEditor.editor.GetAsString(buf^);
	 	vss := Strings.NewString(buf^);

		context.MakeCurrent();
			vs := CompileVertexShader(vss);
		context.DeActivate();
	END CompileVertex;

	PROCEDURE CompileFragment(sender, data : ANY);
	VAR
	      fss: Strings.String;
	      fs: Uint;
	BEGIN
		logEditor.SetAsString("");
	 	fsEditor.editor.GetAsString(buf^);
	 	fss := Strings.NewString(buf^);

	 	context.MakeCurrent();
			fs := CompileFragmentShader(fss);
		context.DeActivate();
	END CompileFragment;

	PROCEDURE GLBuild(sender, data : ANY);
	VAR
	      vss, fss: Strings.String;
	      vs, fs: Uint;
	      attached: BOOLEAN;
	BEGIN
	 	fsEditor.editor.GetAsString(buf^);
	 	fss := Strings.NewString(buf^);

	 	vsEditor.editor.GetAsString(buf^);
	 	vss := Strings.NewString(buf^);

		context.MakeCurrent();
		IF program # 0 THEN gl.DeleteProgram(program); END;

		vs := CompileVertexShader(vss);
		IF vs =-1 THEN
			KernelLog.String("ERROR: VertexShader is not compiled"); KernelLog.Ln;
			RETURN
		END;

		fs := CompileFragmentShader(fss);
		IF fs =-1 THEN
			KernelLog.String("ERROR: FragmentShader is not compiled"); KernelLog.Ln;
			RETURN
		END;

		program := gl.CreateProgram();
		attached := AttachAndLinkProgram(program, vs, fs);

		IF ~attached THEN
			gl.DeleteProgram(program);
			KernelLog.String("ERROR: Program is not attached"); KernelLog.Ln;
			RETURN;
		END;

		logEditor.SetAsString("SUCCESS");
		context.DeActivate();
	END GLBuild;

	PROCEDURE Close;
	BEGIN
		context.MakeCurrent();
		gl.DeleteProgram(program);
		Close^;
		DecCount;
	END Close;

	PROCEDURE Handle(VAR x: WMMessages.Message);
	VAR data, velem, felem : WMRestorable.XmlElement;
	BEGIN
		IF (x.msgType = WMMessages.MsgExt) & (x.ext # NIL) THEN
			IF (x.ext IS KillerMsg) THEN Close
			ELSIF (x.ext IS WMRestorable.Storage) THEN

		(*		NEW(data); data.SetName("ShaderSources");


				NEW(velem); velem.SetName("VertexShader");
				vsEditor.ToXml(velem);
				data.AddContent(velem);

				NEW(felem); felem.SetName("FragmentShader");
				fsEditor.ToXml(felem);
				data.AddContent(felem);

				x.ext(WMRestorable.Storage).Add("GLShadersBuild", "GLShadersBuild.Restore", SELF, data)
			*)
			ELSE Handle^(x)
			END
		ELSE Handle^(x)
		END
		END Handle;

	BEGIN

	END Window;

VAR
	nofWindows : LONGINT;
	context: GLContext.Context; (* opengl context *)


	buf: Strings.String; (* 16Kb, if kernel size is not enough increase size, look at the module body  *)

PROCEDURE Open*(context : Commands.Context); (** [ [vertexFilename] | [fragmentFilename] ] ~ *)
VAR
	wind: Window;
	filename : ARRAY 256 OF CHAR;
BEGIN
	NEW(wind, NIL);
	IF context.arg.GetString(filename) THEN
		wind.LoadVertexShaderFile(filename);
		IF context.arg.GetString(filename) THEN
			wind.LoadFragmentShaderFile(filename);
		END;
	ELSE
		wind.NewEmptyShader();
	END;
END Open;


PROCEDURE Restore*(context : WMRestorable.Context);
VAR
	winstance: Window;
BEGIN
	NEW(winstance, context)
END Restore;

PROCEDURE Cleanup;
VAR die : KillerMsg;
	 msg : WMMessages.Message;
	 m : WM.WindowManager;
BEGIN

	BEGIN {EXCLUSIVE}


	NEW(die);
	msg.ext := die;
	msg.msgType := WMMessages.MsgExt;
	m := WM.GetDefaultManager();
	m.Broadcast(msg);
	AWAIT(nofWindows = 0);
	END;

	context.Close;


END Cleanup;

PROCEDURE IncCount;
BEGIN {EXCLUSIVE}
	INC(nofWindows)
END IncCount;

PROCEDURE DecCount;
BEGIN {EXCLUSIVE}
	DEC(nofWindows)
END DecCount;

BEGIN
	NEW(buf, 16384); (* buffer for reading texts from shader editors *)

	Modules.InstallTermHandler(Cleanup);
	NEW(context); (* gl context required for compiling shaders, no rendering *)
	context.Init(100,100);
END GLShadersBuild.

GLShadersBuild.Open MyDemos/mycd4.vert MyDemos/mycd4.frag ~

GLShadersBuild.Open ~

System.Free GLShadersBuild ~

System.FreeDownTo OpenGL ~

