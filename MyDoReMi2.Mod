MODULE MyDoReMi2; (** AUTHOR "fnecati"; PURPOSE "simple usage of OpenAL, sound buttons"; *)

IMPORT
	AL := OpenAL, ALUT := OpenALUtil, Strings, Math, Modules,
	WM := WMWindowManager, WMRectangles, WMComponents, WMStandardComponents;

TYPE PianoWindow= OBJECT(WMComponents.FormWindow)
	VAR 
		buttons: ARRAY 8 OF WMStandardComponents.Button;

		allbut: WMStandardComponents.Button;
		
	PROCEDURE CreateForm():WMComponents.VisualComponent;
	VAR panel: WMStandardComponents.Panel; 
		i: LONGINT;
		ids : ARRAY 4 OF CHAR;
	BEGIN
		
		(* main panel *)
		NEW(panel);
		panel.alignment.Set(WMComponents.AlignClient); 
		panel.fillColor.Set(0CCCCCCFFFH);
								
		CreateButtons();
		FOR i:=0 TO LEN(buttons)-1  DO
			panel.AddContent(buttons[i]);
		END;
		
			NEW(allbut); allbut.bounds.SetWidth(70); 
			allbut.alignment.Set(WMComponents.AlignLeft);
			allbut.caption.SetAOC("ALL");
			allbut.onClick.Add(ProcessButton);
			Strings.IntToStr(10, ids);
			allbut.id.SetAOC(ids);
			panel.AddContent(allbut);
		RETURN panel;
	END CreateForm;
	
	PROCEDURE CreateButtons;
	VAR i: LONGINT;
		ids: ARRAY 4 OF CHAR;
  		rec: WMRectangles.Rectangle;
	BEGIN
		rec := WMRectangles.MakeRect(2, 2, 2, 2);
		FOR i:=0 TO LEN(buttons)-1 DO
			NEW(buttons[i]); buttons[i].bounds.SetWidth(50); 
			buttons[i].alignment.Set(WMComponents.AlignLeft);
			buttons[i].caption.SetAOC("DO");
			buttons[i].onClick.Add(ProcessButton);
			Strings.IntToStr(i, ids);
			buttons[i].id.SetAOC(ids);
			buttons[i].bearing.Set(rec);
			
		END;
		buttons[0].caption.SetAOC("DO");
		buttons[1].caption.SetAOC("RE");
		buttons[2].caption.SetAOC("MI");
		buttons[3].caption.SetAOC("FA");
		buttons[4].caption.SetAOC("SO");
		buttons[5].caption.SetAOC("LA");
		buttons[6].caption.SetAOC("SI");
		buttons[7].caption.SetAOC("DO");

	END CreateButtons;
		
	PROCEDURE &New*(w, h: LONGINT);
	VAR vc : WMComponents.VisualComponent;
	BEGIN
		Init(w, h, FALSE);
		SetTitle(Strings.NewString("Piano"));
		 vc := CreateForm();
		SetContent(vc);
		WM.DefaultAddWindow(SELF);
	END New;


	PROCEDURE KeyEvent (ucs: LONGINT; flags: SET; keysym: LONGINT);
	BEGIN
		(* simulate button press from keyboard, how? *)
		CASE CHR(ucs) OF
			"1" : 	buttons[0].Click(NIL, NIL);
			| "2" : 	buttons[1].Click(NIL, NIL); 
			| "3": 	buttons[2].Click(NIL, NIL); 
			| "4":  	buttons[3].Click(NIL, NIL); 
			| "5" : 	buttons[4].Click(NIL, NIL); 
			| "6":  	buttons[5].Click(NIL, NIL); 
			| "7": 	buttons[6].Click(NIL, NIL); 
			| "8": 	buttons[7].Click(NIL, NIL); 
			| "0": 	allbut.Click(NIL, NIL); 
			| "x": Close;
		ELSE

		END;
	END KeyEvent;		

	PROCEDURE ProcessButton(sender, data: ANY);
	VAR but: WMStandardComponents.Button;
		  id: LONGINT;
		  ids : Strings.String;
	BEGIN
		but := sender(WMStandardComponents.Button);
		ids := but.id.Get();
		Strings.StrToInt(ids^, id);
		IF id = 10 THEN (*  play all button *)
			ALUT.Playv(sourceobj);
		ELSIF (id >= 0)  & (id < 8) THEN
			ALUT.Play(sourceobj[id]);
		END;
	END ProcessButton;
			
	END PianoWindow;


VAR win: PianoWindow;
	  sourceobj, bufferobj: ARRAY 8 OF AL.ALuint;;	  
	  octaveFreqs: ARRAY 8 OF REAL;
	  listenerPos: ARRAY 3 OF REAL;
	  		
PROCEDURE CreateTones;
VAR
	bufferdata: POINTER TO ARRAY OF INTEGER;
	j, z : LONGINT;
	y: REAL;

	sizeBytes,  freq: AL.ALsizei;
	srcPos: ARRAY 3 OF AL.ALfloat;
	envelope: REAL;
	N: LONGINT;
BEGIN
	AL.alGenBuffers(8, ADDRESSOF(bufferobj[0]));
	AL.alGenSources(8, ADDRESSOF(sourceobj[0]));
	srcPos := [0.0, 0.0, 0.0];

 	 N := 10000; (* number of samples *)
 	 
	 NEW(bufferdata, N);
	 
	 (* octave 4, C-B *)
	 octaveFreqs := [261.626, 293.665, 311.127, 329.628, 349.228, 391.995, 440.0, 493.883];

	freq := 44100; (*11024;*)

	sizeBytes := N*SIZEOF(INTEGER);
	
	 FOR j := 0 TO 7 DO
		FOR z := 0 TO N-1 DO
			(*envelope :=  Math.exp(-z/1000); *)
			envelope := Math.exp(-(z- N /2)*(z- N /2)/1000000); 
(*			envelope := Math.sin(Math.pi*z/N);*)
			y := envelope* Math.sin(2.0*Math.pi*z*octaveFreqs[j]/freq);

			bufferdata[z] := SHORT(ENTIER(y*16380+0.5 ))
		END;  
    
		AL.alBufferData(bufferobj[j], AL.AL_FORMAT_MONO16, ADDRESSOF(bufferdata[0]), sizeBytes, freq);

		AL.alSourcef(sourceobj[j], AL.AL_PITCH, 1.0);
		AL.alSourcef(sourceobj[j], AL.AL_GAIN, 1.0);
		AL.alSourcefv(sourceobj[j], AL.AL_POSITION, ADDRESSOF(srcPos[0]));
		AL.alSourcei(sourceobj[j], AL.AL_BUFFER, bufferobj[j]);
	END;
	
	(* only one llistener required *)
	 listenerPos := [0.0, 0.0, 0.0];
	 AL.alListenerfv(AL.AL_POSITION, ADDRESSOF(listenerPos[0]));
END CreateTones;

PROCEDURE OnClose;
BEGIN
	(* delete all sources and buffers *)
	AL.alDeleteSources(LEN(sourceobj), ADDRESSOF(sourceobj[0]));
	AL.alDeleteBuffers(LEN(bufferobj), ADDRESSOF(bufferobj[0]));
END OnClose;

PROCEDURE Open*;
BEGIN
	NEW(win, 500, 150);
END Open;

BEGIN
	CreateTones();
	Modules.InstallTermHandler(OnClose);	
END MyDoReMi2.

MyDoReMi2.Open ~

SystemTools.Free MyDoReMi2 ~ 

SystemTools.FreeDownTo OpenAL ~ 

