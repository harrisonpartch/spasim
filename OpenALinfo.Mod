MODULE OpenALinfo; (** AUTHOR "fnecati"; PURPOSE "show OpenAL device infos"; *)
(* adapted from openal-soft/utils/openal-info.c *)

IMPORT  Commands, AL:=OpenAL, EFX:=OpenALefx, EXT:=OpenALext, Files, Strings,  KernelLog;

CONST
	openalPlayFile ="openalplay.ini"; (* configuration file for available list of play devices *) 
	openalCapFile ="openalcap.ini"    (* configuration file for available list of capture devices *) 
	
TYPE StringArray = AL.StringArray;

VAR 
	str: Strings.String;
	err: AL.ALCenum;
	device : AL.ALCdevice;
	context : AL.ALCcontext;
	res: AL.ALboolean;
	
PROCEDURE checkALErrors(linenum := 0: SIGNED32): AL.ALenum;
BEGIN
	err := AL.alGetError();
	IF (err # AL.AL_NO_ERROR) THEN
		KernelLog.String("OpenAL Error: ");
		str := AL.alGetString(err);
		KernelLog.String(str^); KernelLog.String(", "); KernelLog.Hex(err, -4); 
		KernelLog.String(" @ "); KernelLog.Int(linenum, 0); KernelLog.Ln; 
	END;    
	RETURN err;
END checkALErrors;

PROCEDURE  checkALCErrors(device: AL.ALCdevice; linenum := 0: SIGNED32): AL.ALCenum;
BEGIN
	err := AL.alcGetError(device);
	IF err # AL.ALC_NO_ERROR THEN
		KernelLog.String("ALC Error: ");
		str := AL.alcGetString(device, err);
		KernelLog.String(str^);  KernelLog.String(", "); KernelLog.Hex(err, -4); 
		KernelLog.String(" @ "); KernelLog.Int(linenum, 0); KernelLog.Ln; 
	END;          
	RETURN err;
END checkALCErrors;     

PROCEDURE printALCInfo(device: AL.ALCdevice );
VAR
	major, minor: AL.ALCint;
	devname: Strings.String;
BEGIN
	IF device # NIL THEN
		KernelLog.Ln; 
		IF AL.alcIsExtensionPresent(device, "ALC_ENUMERATE_ALL_EXT") THEN
			devname := AL.alcGetString(device, AL.ALC_ALL_DEVICES_SPECIFIER);			
		END;
		IF checkALCErrors(device) # AL.ALC_NO_ERROR THEN
			devname := AL.alcGetString(device, AL.ALC_DEVICE_SPECIFIER);
		END;
		KernelLog.String("** Info for device ");  KernelLog.String(devname^); 
		KernelLog.String(" **"); KernelLog.Ln; 
	END;
	
	AL.alcGetIntegerv(device, AL.ALC_MAJOR_VERSION, 1, ADDRESSOF(major));
	AL.alcGetIntegerv(device, AL.ALC_MINOR_VERSION, 1, ADDRESSOF(minor));
	IF (checkALCErrors(device) = AL.ALC_NO_ERROR) THEN
		KernelLog.String("ALC version: "); KernelLog.Int(major, 0); KernelLog.String(".");  KernelLog.Int(minor, 0); KernelLog.Ln; 
	END;
    IF device # NIL THEN   
        KernelLog.String("ALC extensions: "); 
        str := AL.alcGetString(device, AL.ALC_EXTENSIONS);
        KernelLog.String(str^); KernelLog.Ln; 
        err := checkALCErrors(device);
   END;
   KernelLog.Ln; 
END printALCInfo;

PROCEDURE printHRTFInfo(device: AL.ALCdevice );
VAR numhrtf, i: AL.ALCint;
	alcGetStringiSOFT: EXT.TalcGetStringiSOFT;
	name : Strings.String;
	nameadr: ADDRESS;
	er: AL.ALCenum;
BEGIN
	IF ~AL.alcIsExtensionPresent(device, "ALC_SOFT_HRTF") THEN
		KernelLog.String("HRTF extension not available"); KernelLog.Ln; 
		RETURN;
	END;
	
	AL.alcGetProcAddress(device, "alcGetStringiSOFT", ADDRESSOF(alcGetStringiSOFT));
	AL.alcGetIntegerv(device, EXT.ALC_NUM_HRTF_SPECIFIERS_SOFT, 1, ADDRESSOF(numhrtf));
	IF numhrtf = 0 THEN
		KernelLog.String("No HRTFs found"); KernelLog.Ln; 
	ELSE
		KernelLog.String("Available HRTFs:"); KernelLog.Ln; 
		FOR i:=0 TO numhrtf-1 DO
			nameadr := alcGetStringiSOFT(device, EXT.ALC_HRTF_SPECIFIER_SOFT, i);
			name := AL.GetStringFromAddr(nameadr);
			KernelLog.String("          "); KernelLog.String(name^); KernelLog.Ln; 
		END;	
	END;
	er := checkALCErrors(device);
END printHRTFInfo;

PROCEDURE printALInfo();
BEGIN
	KernelLog.String("OpenAL vendor string: ");  str := AL.alGetString(AL.AL_VENDOR); KernelLog.String(str^); KernelLog.Ln;
     KernelLog.String("OpenAL renderer string: "); str := AL.alGetString(AL.AL_RENDERER); KernelLog.String(str^); KernelLog.Ln;
     KernelLog.String("OpenAL version string: "); str := AL.alGetString(AL.AL_VERSION); KernelLog.String(str^); KernelLog.Ln;
     KernelLog.String("OpenAL extensions:  "); str := AL.alGetString(AL.AL_EXTENSIONS); KernelLog.String(str^); KernelLog.Ln;     
	err := checkALErrors();
	KernelLog.Ln; 
END printALInfo;

PROCEDURE printResamplerInfo;
VAR
    num_resamplers, def_resampler: AL.ALint;
    i: SIGNED32;
    name: Strings.String;
BEGIN
    IF ~AL.alIsExtensionPresent("AL_SOFT_source_resampler") THEN
        KernelLog.String("Resampler info not available"); KernelLog.Ln;
        RETURN
    END;

    num_resamplers := AL.alGetInteger(EXT.AL_NUM_RESAMPLERS_SOFT);
    def_resampler := AL.alGetInteger(EXT.AL_DEFAULT_RESAMPLER_SOFT);

    IF num_resamplers = 0 THEN
        KernelLog.String("!!! No resamplers found !!!"); KernelLog.Ln; 
    ELSE
        KernelLog.String("Available resamplers:"); KernelLog.Ln; 
        FOR i := 0 TO num_resamplers-1 DO
            name := EXT.alGetStringiSOFT(EXT.AL_RESAMPLER_NAME_SOFT, i);
            KernelLog.String("    "); KernelLog.String(name^); 
            IF i = def_resampler THEN KernelLog.String(" *");  END;
            KernelLog.Ln; 
         END;
    END;
    i := checkALErrors();
END printResamplerInfo;

PROCEDURE printEFXInfo(device: AL.ALCdevice );
TYPE String64 = ARRAY 64 OF CHAR;
VAR
	major, minor, sends: AL.ALCint;
	val: AL.ALenum;	
	i: SIGNED32;

	filters: ARRAY 3 OF String64;
	filterNames: ARRAY 3 OF String64;
	
	effects : ARRAY 13 OF String64;
	effectNames: ARRAY 16 OF String64;
	dedeffects: ARRAY 2 OF String64;
BEGIN    

 	filters[0]  := "AL_FILTER_LOWPASS";
	filters[1]  := "AL_FILTER_HIGHPASS";
	filters[2]  := "AL_FILTER_BANDPASS";
 	
     filterNames[0] := "Low-Pass";
	filterNames[1] := "High-Pass";
	filterNames[2] := "Band-Pass";
	
    effects[0] := "AL_EFFECT_EAXREVERB";               effects[1] := "AL_EFFECT_REVERB"; 
    effects[2] := "AL_EFFECT_CHORUS";                    effects[3] := "AL_EFFECT_DISTORTION"; 
    effects[4] := "AL_EFFECT_ECHO";                        effects[5] := "AL_EFFECT_FLANGER";
    effects[6] := "AL_EFFECT_FREQUENCY_SHIFTER"; effects[7] := "AL_EFFECT_VOCAL_MORPHER";
    effects[8] := "AL_EFFECT_PITCH_SHIFTER";        effects[9] := "AL_EFFECT_RING_MODULATOR"; 
    effects[10] := "AL_EFFECT_AUTOWAH";                 effects[11] := "AL_EFFECT_COMPRESSOR";
    effects[12] := "AL_EFFECT_EQUALIZER"; 
      
    dedeffects[0] := "AL_EFFECT_DEDICATED_DIALOGUE";
    dedeffects[1] := "AL_EFFECT_DEDICATED_LOW_FREQUENCY_EFFECT";

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
    	effectNames[13] := "Dediacated Dialog";
    	effectNames[14] := "Dedicated LFE";
  
    IF ~AL.alcIsExtensionPresent(device, "ALC_EXT_EFX") THEN   
        KernelLog.String("EFX not available"); KernelLog.Ln; 
        RETURN;
   END;

    AL.alcGetIntegerv(device, EFX.ALC_EFX_MAJOR_VERSION, 1, ADDRESSOF(major));
    AL.alcGetIntegerv(device, EFX.ALC_EFX_MINOR_VERSION, 1, ADDRESSOF(minor));
    IF (checkALCErrors(device) = AL.ALC_NO_ERROR) THEN
        KernelLog.String("EFX version: "); KernelLog.Int(major, 0); KernelLog.String("."); KernelLog.Int(minor, 0); KernelLog.Ln; 
    END;    

    AL.alcGetIntegerv(device, EFX.ALC_MAX_AUXILIARY_SENDS, 1, ADDRESSOF(sends));
    IF (checkALCErrors(device) = AL.ALC_NO_ERROR) THEN
        KernelLog.String("Max auxiliary sends: "); KernelLog.Int(sends, 0); KernelLog.Ln; 
    END;

	FOR i := 0 TO LEN(filters) - 1 DO
		val := AL.alGetEnumValue(filters[i]);
		IF (AL.alGetError() # AL.AL_NO_ERROR) OR (val = 0) OR (val = -1) THEN filterNames[i] := "-"; END;
	END;    

	KernelLog.String("Supported filters:"); KernelLog.Ln; 
	FOR i:=0 TO LEN(filterNames)-1 DO
		IF filterNames[i] # "-" THEN KernelLog.String(filterNames[i]); KernelLog.String(", "); END;
	END;
	KernelLog.Ln; 

	FOR i := 0 TO LEN(effects) - 1 DO
		val := AL.alGetEnumValue(effects[i]);
		IF (AL.alGetError() # AL.AL_NO_ERROR) OR (val =0) OR (val = -1) THEN effectNames[i] := "-"; END;
	END;	

	KernelLog.String("Supported effects:"); KernelLog.Ln; 
	FOR i:=0 TO LEN(effects)-1 DO
		IF effectNames[i] # "-" THEN KernelLog.String(effectNames[i]); KernelLog.String(", "); END;
	END;
	
	IF AL.alcIsExtensionPresent(device, "ALC_EXT_DEDICATED") THEN
		FOR i := 0 TO LEN(dedeffects) - 1 DO
			val := AL.alGetEnumValue(dedeffects[i]);
			IF (AL.alGetError() # AL.AL_NO_ERROR) OR (val =0) OR (val = -1) THEN effectNames[LEN(effects)+i] := "-"; END;
		END;
		FOR i:=0 TO LEN(dedeffects)-1 DO
			IF effectNames[LEN(effects)+i] # "-" THEN KernelLog.String(effectNames[LEN(effects)+i]); KernelLog.String(", "); END;
		END;		
	 END; 
	 KernelLog.Ln; 
END printEFXInfo;

PROCEDURE Do*(cmd: Commands.Context);
VAR  
	i : SIZE;
	dname: ARRAY 64 OF CHAR;	
	dynstr: StringArray;
	file: Files.File;
	fwr: Files.Writer;
BEGIN
 
	file := Files.New(openalPlayFile);
	Files.OpenWriter(fwr, file, 0);
 
	KernelLog.String("*****************************************"); KernelLog.Ln; 
	KernelLog.String("Available playback devices: "); KernelLog.Ln; 
 
	IF AL.alcIsExtensionPresent(NIL, "ALC_ENUMERATE_ALL_EXT")  THEN
		dynstr :=AL.ALCGetDeviceList(NIL, AL.ALC_ALL_DEVICES_SPECIFIER);
		IF dynstr # NIL THEN
			FOR i:=0 TO LEN(dynstr)-1 DO   
				KernelLog.Int(i, 0); KernelLog.String(": ");  KernelLog.String(dynstr[i]^); KernelLog.Ln;
				fwr.String("#"); fwr.String(dynstr[i]^); fwr.Ln;
		 	END;
	 	END;
	ELSE
		dynstr := AL.ALCGetDeviceList(NIL, AL.ALC_DEVICE_SPECIFIER);
		IF dynstr # NIL THEN
			FOR i:=0 TO LEN(dynstr)-1 DO   
				KernelLog.Int(i, 0); KernelLog.String(": ");  KernelLog.String(dynstr[i]^); KernelLog.Ln;
				fwr.String("#"); fwr.String(dynstr[i]^); fwr.Ln;
		 	END;
	 	END;
	END;
	
	fwr.Update;
	Files.Register(file);
  
	KernelLog.String("*****************************************"); KernelLog.Ln;         

	file := Files.New(openalCapFile);
	Files.OpenWriter(fwr, file, 0);
  	    
	KernelLog.String("Available capture devices: "); KernelLog.Ln; 
	dynstr := AL.ALCGetDeviceList(NIL, AL.ALC_CAPTURE_DEVICE_SPECIFIER);
	IF dynstr # NIL THEN
		FOR i:=0 TO LEN(dynstr)-1 DO   
			KernelLog.Int(i, 0); KernelLog.String(": ");  KernelLog.String(dynstr[i]^); KernelLog.Ln;
			fwr.String("#"); fwr.String(dynstr[i]^); fwr.Ln;
		END;
	END;
	fwr.Update;
	Files.Register(file);
	  
	KernelLog.String("*****************************************"); KernelLog.Ln;
    
	KernelLog.String("Default playback device: ");
	IF AL.alcIsExtensionPresent(NIL, "ALC_ENUMERATE_ALL_EXT") THEN
		str := AL.alcGetString(NIL, AL.ALC_DEFAULT_ALL_DEVICES_SPECIFIER);
	ELSE
		str := AL.alcGetString(NIL, AL.ALC_DEFAULT_DEVICE_SPECIFIER);
	END; 
	KernelLog.String(str^); KernelLog.Ln;
  
	KernelLog.String("Default capture device: ");
	str := AL.alcGetString(NIL, AL.ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
	KernelLog.String(str^); KernelLog.Ln;
 
 	printALCInfo(NIL);
	
 	(* if a device name is given, use it *)
	IF cmd.arg.GetString(dname) THEN
		device := AL.alcOpenDevice(dname); (* use given name *)
	ELSE
		device := AL.alcOpenDevice(""); (* use default *)
	END;
	
	IF device = NIL THEN 
		KernelLog.String("!!! Failed to open ");
		KernelLog.String(dname); KernelLog.String(" default device !!!"); KernelLog.Ln; 
		RETURN
	END;  

	printALCInfo(device);
	printHRTFInfo(device);
  
	context := AL.alcCreateContext(device, NIL);
    
	IF (context = NIL) OR  (~ AL.alcMakeContextCurrent(context) ) THEN    
		IF context # NIL THEN AL.alcDestroyContext(context); END;
		res := AL.alcCloseDevice(device);
		KernelLog.String("!!! Failed to set a context !!!"); KernelLog.Ln; KernelLog.Ln; 
		RETURN;
	END;

	printALInfo();
	printResamplerInfo();
	printEFXInfo(device); 

	res := AL.alcMakeContextCurrent(0);
	AL.alcDestroyContext(context);
	res := AL.alcCloseDevice(device);
END Do;

BEGIN

END OpenALinfo.


OpenALinfo.Do ~
OpenALinfo.Do "HDA Intel, ALC883 Analog (CARD=Intel,DEV=0)" ~ 
OpenALinfo.Do "HDA Intel, ALC883 Digital (CARD=Intel,DEV=1)"~

System.FreeDownTo OpenAL~ 

