MODULE OpenALext;
IMPORT AL := OpenAL, SYSTEM;

TYPE 

(* AL_LOKI_IMA_ADPCM_format extension *)
CONST
	AL_FORMAT_IMA_ADPCM_MONO16_EXT* = 10000H;
	AL_FORMAT_IMA_ADPCM_STEREO16_EXT* = 10001H;

(* AL_LOKI_WAVE_format extension *)
CONST
	AL_FORMAT_WAVE_EXT* = 10002H;

(* AL_EXT_vorbis extension *)
CONST
	AL_FORMAT_VORBIS_EXT* = 10003H;

(* AL_LOKI_quadriphonic extension *)
CONST
	AL_FORMAT_QUAD8_LOKI* = 10004H;
	AL_FORMAT_QUAD16_LOKI* = 10005H;

(* AL_EXT_float32 extension *)
CONST
	AL_FORMAT_MONO_FLOAT32* = 10010H;
	AL_FORMAT_STEREO_FLOAT32* = 10011H;

(* AL_EXT_double extension *)
CONST
	AL_FORMAT_MONO_DOUBLE_EXT* = 10012H;
	AL_FORMAT_STEREO_DOUBLE_EXT* = 10013H;

(* ALC_LOKI_audio_channel extension *)
CONST
	ALC_CHAN_MAIN_LOKI* = 500001H;
	ALC_CHAN_PCM_LOKI* = 500002H;
	ALC_CHAN_CD_LOKI* = 500003H;

(* ALC_ENUMERATE_ALL_EXT extension *)
CONST
	ALC_DEFAULT_ALL_DEVICES_SPECIFIER* = 1012H;
	ALC_ALL_DEVICES_SPECIFIER* = 1013H;

(* AL_EXT_MCFORMATS extension *)
CONST
	AL_FORMAT_QUAD8* = 1204H;
	AL_FORMAT_QUAD16* = 1205H;
	AL_FORMAT_QUAD32* = 1206H;
	AL_FORMAT_REAR8* = 1207H;
	AL_FORMAT_REAR16* = 1208H;
	AL_FORMAT_REAR32* = 1209H;
	AL_FORMAT_51CHN8* = 120AH;
	AL_FORMAT_51CHN16* = 120BH;
	AL_FORMAT_51CHN32* = 120CH;
	AL_FORMAT_61CHN8* = 120DH;
	AL_FORMAT_61CHN16* = 120EH;
	AL_FORMAT_61CHN32* = 120FH;
	AL_FORMAT_71CHN8* = 1210H;
	AL_FORMAT_71CHN16* = 1211H;
	AL_FORMAT_71CHN32* = 1212H;

(* AL_EXT_IMA4 extension *)
CONST
	AL_FORMAT_MONO_IMA4* = 1300H;
	AL_FORMAT_STEREO_IMA4* = 1301H;

(* AL_EXT_buffer_sub_data extension *)
CONST
	AL_BYTE_RW_OFFSETS_EXT* = 1031H;
	AL_SAMPLE_RW_OFFSETS_EXT* = 1032H;
	AL_SEC_RW_OFFSETS_EXT* = 1033H;
   
TYPE 
	TalBufferSubDataEXT = PROCEDURE { WINAPI } (buffer :AL.ALuint; format :AL.ALenum; data :ADDRESS; offset :AL.ALsizei; length :AL.ALsizei);  
VAR  
	alBufferDataStatic-: TalBufferDataStatic;
 
(* AL_EXT_STATIC_BUFFER extension *)
TYPE 
	TalBufferDataStatic = PROCEDURE { WINAPI } (buffer :AL.ALint; format :AL.ALenum; data :ADDRESS; size, freq :AL.ALsizei);  
VAR 
	alBufferSubDataEXT-: TalBufferSubDataEXT;

 
(* AL_EXT_sample_buffer_object extension *)
CONST
	AL_SAMPLE_SOURCE_EXT* = 1040H;
	AL_SAMPLE_SINK_EXT* = 1041H;
	AL_READ_ONLY_EXT* = 1042H;
	AL_WRITE_ONLY_EXT* = 1043H;
	AL_READ_WRITE_EXT* = 1044H;
	AL_STREAM_WRITE_EXT* = 1045H;
	AL_STREAM_READ_EXT* = 1046H;
	AL_STREAM_COPY_EXT* = 1047H;
	AL_STATIC_WRITE_EXT* = 1048H;
	AL_STATIC_READ_EXT* = 1049H;
	AL_STATIC_COPY_EXT* = 104AH;
	AL_DYNAMIC_WRITE_EXT* = 104BH;
	AL_DYNAMIC_READ_EXT* = 104CH;
	AL_DYNAMIC_COPY_EXT* = 104DH;
   
TYPE
	TalGenDatabuffersEXT = PROCEDURE { WINAPI } (n:AL.ALsizei; puiBuffers: AL.PALuint);  
	TalDeleteDatabuffersEXT = PROCEDURE { WINAPI } (n:AL.ALsizei; puiBuffers: AL.PALuint);  
	TalIsDatabufferEXT = PROCEDURE { WINAPI }  (uiBuffer:AL.ALuint):AL.ALboolean;  
	TalDatabufferDataEXT = PROCEDURE { WINAPI } (buffer:AL.ALuint; data: ADDRESS; size:AL.ALsizei; usage:AL.ALenum);  
	TalDatabufferSubDataEXT = PROCEDURE { WINAPI } (buffer:AL.ALuint; start:AL.ALuint; length:AL.ALsizei; data:ADDRESS);  
	TalGetDatabufferSubDataEXT = PROCEDURE { WINAPI } (buffer:AL.ALuint; start:AL.ALuint; length:AL.ALsizei; data:ADDRESS);  
	TalDatabufferfEXT = PROCEDURE { WINAPI } (buffer:AL.ALuint; eParam:AL.ALenum; flValue:AL.ALfloat);  
	TalDatabufferfvEXT= PROCEDURE { WINAPI } (buffer:AL.ALuint; eParam:AL.ALenum; flValues:AL.PALfloat);  
	TalDatabufferiEXT = PROCEDURE { WINAPI } (buffer:AL.ALuint; eParam:AL.ALenum; lValue:AL.ALint);  
	TalDatabufferivEXT = PROCEDURE { WINAPI } (buffer:AL.ALuint; eParam:AL.ALenum; plValues:AL.PALint);  
	TalGetDatabufferfEXT = PROCEDURE { WINAPI } (buffer:AL.ALuint; eParam:AL.ALenum; VAR pflValue:AL.ALfloat);  
	TalGetDatabufferfvEXT = PROCEDURE { WINAPI } (buffer:AL.ALuint; eParam:AL.ALenum; pflValues:AL.PALfloat);  
	TalGetDatabufferiEXT = PROCEDURE { WINAPI } (buffer:AL.ALuint; eParam:AL.ALenum; VAR plValue:AL.ALint);  
	TalGetDatabufferivEXT = PROCEDURE { WINAPI } (buffer:AL.ALuint; eParam:AL.ALenum; plValues:AL.PALint);  
	TalSelectDatabufferEXT = PROCEDURE { WINAPI } (target:AL.ALenum; uiBuffer:AL.ALuint);  
	TalMapDatabufferEXT = PROCEDURE { WINAPI }  (uiBuffer:AL.ALuint; start:AL.ALuint; length:AL.ALsizei; access:AL.ALenum):ADDRESS;  
	TalUnmapDatabufferEXT = PROCEDURE { WINAPI } (uiBuffer:AL.ALuint);  

VAR
	alGenDatabuffersEXT-: TalGenDatabuffersEXT;
	alDeleteDatabuffersEXT-: TalDeleteDatabuffersEXT;
	alIsDatabufferEXT-: TalIsDatabufferEXT;
	alDatabufferDataEXT-: TalDatabufferDataEXT;
	alDatabufferSubDataEXT-: TalDatabufferSubDataEXT;
	alGetDatabufferSubDataEXT-: TalGetDatabufferSubDataEXT;
	alDatabufferfEXT-: TalDatabufferfEXT;
	alDatabufferfvEXT-: TalDatabufferfvEXT;
	alDatabufferiEXT-: TalDatabufferiEXT;
	alDatabufferivEXT-: TalDatabufferivEXT;
	alGetDatabufferfEXT-: TalGetDatabufferfEXT;
	alGetDatabufferfvEXT-: TalGetDatabufferfvEXT;
	alGetDatabufferiEXT-: TalGetDatabufferiEXT;
	alGetDatabufferivEXT-: TalGetDatabufferivEXT;
	alSelectDatabufferEXT-: TalSelectDatabufferEXT;
	alMapDatabufferEXT-: TalMapDatabufferEXT;
	alUnmapDatabufferEXT-: TalUnmapDatabufferEXT;

(* ALC_EXT_disconnect extension *)
CONST
	ALC_CONNECTED* = 0313H;

(* ALC_EXT_thread_local_context extension *)
TYPE
	TalcMakeCurrent = PROCEDURE { WINAPI } (context :AL.ALCcontext) :AL.ALCboolean;  
	TalcGetThreadContext = PROCEDURE { WINAPI } () :AL.ALCcontext;  

VAR
	alcMakeCurrent- : TalcMakeCurrent;
	alcGetThreadContext-:  TalcGetThreadContext;

(* AL_EXT_source_distance_model extension *)
CONST
	AL_SOURCE_DISTANCE_MODEL* = 0200H;

 PROCEDURE Init;
 BEGIN
	alBufferDataStatic :=  SYSTEM.VAL(TalBufferDataStatic, AL.alGetProcAddress("alBufferDataStatic"));
	alBufferSubDataEXT := SYSTEM.VAL(TalBufferSubDataEXT, AL.alGetProcAddress("alBufferSubDataEXT"));
	alGenDatabuffersEXT := SYSTEM.VAL(TalGenDatabuffersEXT, AL.alGetProcAddress("alGenDatabuffersEXT"));
	alDeleteDatabuffersEXT := SYSTEM.VAL(TalDeleteDatabuffersEXT, AL.alGetProcAddress("alDeleteDatabuffersEXT"));
	alIsDatabufferEXT := SYSTEM.VAL(TalIsDatabufferEXT, AL.alGetProcAddress("alIsDatabufferEXT"));
	alDatabufferDataEXT := SYSTEM.VAL(TalDatabufferDataEXT, AL.alGetProcAddress("alDatabufferDataEXT"));	
	alDatabufferSubDataEXT := SYSTEM.VAL(TalDatabufferSubDataEXT, AL.alGetProcAddress("alDatabufferSubDataEXT"));
	alGetDatabufferSubDataEXT := SYSTEM.VAL(TalGetDatabufferSubDataEXT, AL.alGetProcAddress("alGetDatabufferSubDataEXT"));
	alDatabufferfEXT := SYSTEM.VAL(TalDatabufferfEXT, AL.alGetProcAddress("alDatabufferfEXT"));
	alDatabufferfvEXT := SYSTEM.VAL(TalDatabufferfvEXT, AL.alGetProcAddress("alDatabufferfvEXT"));
	alDatabufferiEXT := SYSTEM.VAL(TalDatabufferiEXT, AL.alGetProcAddress("alDatabufferiEXT"));
	alDatabufferivEXT := SYSTEM.VAL(TalDatabufferivEXT, AL.alGetProcAddress("alDatabufferivEXT"));
	alGetDatabufferfEXT := SYSTEM.VAL(TalGetDatabufferfEXT, AL.alGetProcAddress("alGetDatabufferfEXT"));
	alGetDatabufferfvEXT := SYSTEM.VAL(TalGetDatabufferfvEXT, AL.alGetProcAddress("alGetDatabufferfvEXT"));
	alGetDatabufferiEXT := SYSTEM.VAL(TalGetDatabufferiEXT, AL.alGetProcAddress("alGetDatabufferiEXT"));
	alGetDatabufferivEXT := SYSTEM.VAL(TalGetDatabufferivEXT, AL.alGetProcAddress("alGetDatabufferivEXT"));
	alSelectDatabufferEXT := SYSTEM.VAL(TalSelectDatabufferEXT, AL.alGetProcAddress("alSelectDatabufferEXT"));
	alMapDatabufferEXT := SYSTEM.VAL(TalMapDatabufferEXT, AL.alGetProcAddress("alMapDatabufferEXT"));
	alUnmapDatabufferEXT :=  SYSTEM.VAL(TalUnmapDatabufferEXT, AL.alGetProcAddress("alUnmapDatabufferEXT"));
	alcMakeCurrent :=  SYSTEM.VAL(TalcMakeCurrent, AL.alGetProcAddress("alcMakeCurrent"));
	alcGetThreadContext :=  SYSTEM.VAL(TalcGetThreadContext, AL.alGetProcAddress("alcGetThreadContext"));
 END Init;
 
BEGIN
	Init;
END OpenALext.