MODULE OpenALinfo; (** AUTHOR "fnecati"; PURPOSE "show OpenAL device infos"; *)

IMPORT  AL:=OpenAL, EFX:=OpenALefx, SYSTEM, Files, Strings,  KernelLog;
CONST
	openalPlayFile ="openalplay.ini"; (* configuration file for available list of play devices *) 
	openalCapFile ="openalcap.ini"    (* configuration file for available list of capture devices *) 
	
TYPE PString256 = AL.PString256;

VAR 
	str: Strings.String;
	err: AL.ALCenum;
	device : AL.ALCdevice;
	context : AL.ALCcontext;
	res: AL.ALboolean;
	
PROCEDURE checkALErrors(linenum: LONGINT): AL.ALenum;
BEGIN
     err := AL.alGetError();
    IF (err # AL.AL_NO_ERROR) THEN
       KernelLog.String("OpenAL Error: ");
       str := AL.ALGetString(err);
       KernelLog.String(str^); KernelLog.String(",  @ "); KernelLog.Int(linenum, 0); KernelLog.Ln; 
    END;    
    RETURN err;
END checkALErrors;


PROCEDURE  checkALCErrors( device: AL.ALCdevice): AL.ALCenum;
BEGIN
     err := AL.alcGetError(device);
    IF err # AL.ALC_NO_ERROR THEN
       KernelLog.String("ALC Error: ");
       str := AL.ALCGetString(device, err);
       KernelLog.String(str^);  KernelLog.Ln; 
    END;          
    RETURN err;
END checkALCErrors;     

PROCEDURE printALCInfo(device: AL.ALCdevice );
VAR
    major, minor: AL.ALCint;    
BEGIN
    AL.alcGetIntegerv(device, AL.ALC_MAJOR_VERSION, 1, SYSTEM.ADR(major));
    AL.alcGetIntegerv(device, AL.ALC_MINOR_VERSION, 1, SYSTEM.ADR(minor));
    IF (checkALCErrors(device) = AL.ALC_NO_ERROR) THEN
        KernelLog.String("ALC version: "); KernelLog.Int(major, 0); KernelLog.String(".");  KernelLog.Int(minor, 0); KernelLog.Ln; 
    END;
        
    IF device # 0 THEN   
        KernelLog.String("ALC extensions: "); 
        str := AL.ALCGetString(device, AL.ALC_EXTENSIONS);
        KernelLog.String(str^); KernelLog.Ln; 
        err := checkALCErrors(device);
   END;
   KernelLog.Ln; 
END printALCInfo;

PROCEDURE printALInfo();
BEGIN

    KernelLog.String("OpenAL vendor string: ");  str := AL.ALGetString(AL.AL_VENDOR); KernelLog.String(str^); KernelLog.Ln; 
     KernelLog.String("OpenAL renderer string: "); str := AL.ALGetString(AL.AL_RENDERER); KernelLog.String(str^); KernelLog.Ln; 
     KernelLog.String("OpenAL version string: "); str := AL.ALGetString(AL.AL_VERSION); KernelLog.String(str^); KernelLog.Ln; 
     KernelLog.String("OpenAL extensions:  "); str := AL.ALGetString(AL.AL_EXTENSIONS); KernelLog.String(str^); KernelLog.Ln; 
     
    err := checkALErrors(1);
    KernelLog.Ln; 
END printALInfo;


PROCEDURE printEFXInfo(device: AL.ALCdevice );
TYPE String32=ARRAY 32 OF CHAR;
VAR
    major, minor, sends: AL.ALCint;
    obj: AL.ALuint ;
    i:LONGINT;
    filters, effects : ARRAY [*] OF AL.ALenum;
    filterNames: ARRAY 4 OF String32;
    effectNames: ARRAY 14 OF String32;
BEGIN    
    filters :=[ EFX.AL_FILTER_LOWPASS, EFX.AL_FILTER_HIGHPASS, EFX.AL_FILTER_BANDPASS,
        EFX.AL_FILTER_NULL];
        filterNames[0] := "Low-Pass";
	filterNames[1] := "High-Pass";
	filterNames[2] := "Band-Pass";
	filterNames[3] := "";
   
    effects := [
        EFX.AL_EFFECT_EAXREVERB, EFX.AL_EFFECT_REVERB, EFX.AL_EFFECT_CHORUS,
        EFX.AL_EFFECT_DISTORTION, EFX.AL_EFFECT_ECHO, EFX.AL_EFFECT_FLANGER,
        EFX.AL_EFFECT_FREQUENCY_SHIFTER, EFX.AL_EFFECT_VOCAL_MORPHER,
        EFX.AL_EFFECT_PITCH_SHIFTER, EFX.AL_EFFECT_RING_MODULATOR, EFX.AL_EFFECT_AUTOWAH,
        EFX.AL_EFFECT_COMPRESSOR, EFX.AL_EFFECT_EQUALIZER, EFX.AL_EFFECT_NULL
    ];
    	effectNames[0] := "EAX Reverb";
    	effectNames[1] := "Reverb";
    	effectNames[2] := "Chorus";
    	effectNames[3] := "Distortion";
    	effectNames[4] := "Echo";
    	effectNames[5] := "Flanger";
    	effectNames[6] := "Frequency Shifter";
    	effectNames[7] := "Vocal Morpher";
    	effectNames[8] := "Pitch Shifter";
    	effectNames[9] := "Ring Modulator";
    	effectNames[10] := "Autowah";
    	effectNames[11] := "Compressor";
    	effectNames[12] := "Equalizer";
    	effectNames[13] := "";

    IF ~AL.alcIsExtensionPresent(device, "ALC_EXT_EFX") THEN   
        KernelLog.String("EFX not available"); KernelLog.Ln; 
        RETURN;
   END;

    AL.alcGetIntegerv(device, EFX.ALC_EFX_MAJOR_VERSION, 1, SYSTEM.ADR(major));
    AL.alcGetIntegerv(device, EFX.ALC_EFX_MINOR_VERSION, 1, SYSTEM.ADR(minor));
    IF (checkALCErrors(device) = AL.ALC_NO_ERROR) THEN
        KernelLog.String("EFX version: "); KernelLog.Int(major, 0); KernelLog.String("."); KernelLog.Int(minor, 0); KernelLog.Ln; 
    END;    

    AL.alcGetIntegerv(device, EFX.ALC_MAX_AUXILIARY_SENDS, 1, SYSTEM.ADR(sends));
    IF (checkALCErrors(device) = AL.ALC_NO_ERROR) THEN
        KernelLog.String("Max auxiliary sends: "); KernelLog.Int(sends, 0); KernelLog.Ln; 
    END;
 
IF (checkALErrors(2) # AL.AL_NO_ERROR)       OR 
       (EFX.alGenFilters = NIL) OR (EFX.alDeleteFilters = NIL) OR (EFX.alFilteri= NIL)  OR
       (EFX.alGenEffects= NIL) OR (EFX.alDeleteEffects= NIL) OR (EFX.alEffecti= NIL) THEN
    
        KernelLog.String("!!! Missing EFX functions !!!"); KernelLog.Ln; 
        RETURN
 END;   
 
(* *************************** *)
	EFX.alGenFilters(1, SYSTEM.ADR(obj));
	IF (checkALErrors(3) = AL.AL_NO_ERROR) THEN
		FOR i := 0 TO LEN(filters,0)-1 DO
			EFX.alFilteri(obj, EFX.AL_FILTER_TYPE, filters[i]);
			IF (AL.alGetError() # AL.AL_NO_ERROR) THEN filterNames[i] := "-"; END;
		END;    
		EFX.alDeleteFilters(1, SYSTEM.ADR(obj));
		i := checkALErrors(4);

		KernelLog.String("Supported filters:"); KernelLog.Ln; 
		FOR i:=0 TO LEN(filterNames,0)-2 DO
			IF filterNames[i] # "-" THEN KernelLog.String(filterNames[i]); KernelLog.String(", "); END;
		END;
		KernelLog.Ln; 
	END;
	
	(* *************************** *)
	EFX.alGenEffects(1, SYSTEM.ADR(obj));
	IF (checkALErrors(5) = AL.AL_NO_ERROR) THEN
		FOR i := 0 TO LEN(effects,0)-1 DO
			EFX.alEffecti(obj, EFX.AL_EFFECT_TYPE, effects[i]);
			IF (AL.alGetError() # AL.AL_NO_ERROR) THEN effectNames[i] := "-"; END;
		END;	
		EFX.alDeleteEffects(1, SYSTEM.ADR(obj));
		i:= checkALErrors(6);

		KernelLog.String("Supported effects:"); KernelLog.Ln; 
		FOR i:=0 TO LEN(effectNames,0)-2 DO
			IF effectNames[i] # "-" THEN KernelLog.String(effectNames[i]); KernelLog.String(", "); END;
		END;
		KernelLog.Ln;        
	 END;
END printEFXInfo;



PROCEDURE Do*;
VAR  
  i : LONGINT;
  dname: ARRAY 64 OF CHAR;	
  dynstr: PString256;
  file: Files.File;
  fwr: Files.Writer;
BEGIN
 
 file := Files.New(openalPlayFile);
 Files.OpenWriter(fwr, file, 0);
 
 KernelLog.String("*****************************************"); KernelLog.Ln; 
 KernelLog.String("Available playback devices: "); KernelLog.Ln; 
 
  IF AL.alcIsExtensionPresent(0, "ALC_ENUMERATE_ALL_EXT")  THEN
  	dynstr :=AL.ALCGetDeviceList(0, AL.ALC_ALL_DEVICES_SPECIFIER);
  	   FOR i:=0 TO LEN(dynstr)-1 DO   
		   KernelLog.Int(i, 0); KernelLog.String(": ");  KernelLog.String(dynstr[i]); KernelLog.Ln;
		   fwr.String("#"); fwr.String(dynstr[i]); fwr.Ln;
	  END;
  ELSE
  	dynstr := AL.ALCGetDeviceList(0, AL.ALC_DEVICE_SPECIFIER);
  	   FOR i:=0 TO LEN(dynstr)-1 DO   
		   KernelLog.Int(i, 0); KernelLog.String(": ");  KernelLog.String(dynstr[i]); KernelLog.Ln;
		    fwr.String("#"); fwr.String(dynstr[i]); fwr.Ln;
	  END;
  END;
  fwr.Update;
  Files.Register(file);
  
 KernelLog.String("*****************************************"); KernelLog.Ln;         

 file := Files.New(openalCapFile);
 Files.OpenWriter(fwr, file, 0);
  	    
  KernelLog.String("Available capture devices: "); KernelLog.Ln; 
  dynstr := AL.ALCGetDeviceList(0, AL.ALC_CAPTURE_DEVICE_SPECIFIER);
  	   FOR i:=0 TO LEN(dynstr)-1 DO   
		   KernelLog.Int(i, 0); KernelLog.String(": ");  KernelLog.String(dynstr[i]); KernelLog.Ln;
		   fwr.String("#"); fwr.String(dynstr[i]); fwr.Ln;
	  END;
  fwr.Update;
  Files.Register(file);
	  
 KernelLog.String("*****************************************"); KernelLog.Ln;
    
 KernelLog.String("Default playback device: ");
 str := AL.ALCGetString(0, AL.ALC_DEFAULT_DEVICE_SPECIFIER);
 KernelLog.String(str^); KernelLog.Ln;
  
 KernelLog.String("Default capture device: ");
 str := AL.ALCGetString(0, AL.ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
 KernelLog.String(str^); KernelLog.Ln;
 
 printALCInfo(0);
 
  device := AL.alcOpenDevice(""); (* use default *)
  IF device = 0 THEN 
	KernelLog.String("!!! Failed to open ");
	KernelLog.String(dname); KernelLog.String(" default device !!!"); KernelLog.Ln; 
	RETURN
  END;  

   str := AL.ALCGetString(device,   AL.ALC_DEVICE_SPECIFIER);
   KernelLog.String("** Info for device "); KernelLog.String(str^); KernelLog.String(" **"); KernelLog.Ln; 
   
  printALCInfo(device);
  
    context := AL.alcCreateContext(device, 0);
    
    IF (context = 0) OR  (~ AL.alcMakeContextCurrent(context) ) THEN    
	        IF context # 0 THEN   AL.alcDestroyContext(context); END;
        res := AL.alcCloseDevice(device);
        KernelLog.String("!!! Failed to set a context !!!"); KernelLog.Ln; KernelLog.Ln; 
        RETURN;
   END;

    printALInfo();
    
   printEFXInfo(device); 

    res := AL.alcMakeContextCurrent(0);
    AL.alcDestroyContext(context);
    res := AL.alcCloseDevice(device);

END Do;

BEGIN

END OpenALinfo.


OpenALinfo.Do ~

SystemTools.FreeDownTo OpenAL~ 

