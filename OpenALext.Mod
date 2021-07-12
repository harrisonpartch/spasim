MODULE OpenALext; (** AUTHOR "fnecati"; PURPOSE "OpenAL extensions"; *)
IMPORT AL := OpenAL, Strings;

TYPE 
	ALboolean = AL.ALboolean;
	ALchar = AL.ALchar;
	ALint = AL.ALint;
	ALuint = AL.ALuint;
	ALenum = AL.ALenum;
	
	ALsizei = AL.ALsizei;
	ALvoid = AL.ALvoid;

	PALfloat = AL.PALfloat;
	ALdouble = AL.ALdouble;
	PALdouble = AL.PALdouble;

	ALCboolean = AL.ALCboolean;
	ALCenum = AL.ALCenum;
	ALCsizei = AL.ALCsizei;
	ALCvoid = AL. ALCvoid;
	ALCdevice = AL.ALCdevice;
	ALCcontext = AL.ALCcontext;

	
CONST
	(* AL_LOKI_IMA_ADPCM_format extension *)
	AL_FORMAT_IMA_ADPCM_MONO16_EXT* = 10000H;
	AL_FORMAT_IMA_ADPCM_STEREO16_EXT* = 10001H;

	(* AL_LOKI_WAVE_format extension *)
	AL_FORMAT_WAVE_EXT* = 10002H;

	(* AL_EXT_vorbis extension *)
	AL_FORMAT_VORBIS_EXT* = 10003H;

	(* AL_LOKI_quadriphonic extension *)
	AL_FORMAT_QUAD8_LOKI* = 10004H;
	AL_FORMAT_QUAD16_LOKI* = 10005H;

	(* AL_EXT_float32 extension *)
	AL_FORMAT_MONO_FLOAT32* = 10010H;
	AL_FORMAT_STEREO_FLOAT32* = 10011H;

	(* AL_EXT_double extension *)
	AL_FORMAT_MONO_DOUBLE_EXT* = 10012H;
	AL_FORMAT_STEREO_DOUBLE_EXT* = 10013H;

	(* AL_EXT_MULAW *)
	AL_FORMAT_MONO_MULAW_EXT* = 10014H;
	AL_FORMAT_STEREO_MULAW_EXT* = 10015H;

	(* AL_EXT_ALAW *)
	AL_FORMAT_MONO_ALAW_EXT* = 10016H;
	AL_FORMAT_STEREO_ALAW_EXT* = 10017H;

	(* ALC_LOKI_audio_channel extension *)
	ALC_CHAN_MAIN_LOKI* = 500001H;
	ALC_CHAN_PCM_LOKI* = 500002H;
	ALC_CHAN_CD_LOKI* = 500003H;

	(* AL_EXT_MCFORMATS extension *)
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

	(* AL_EXT_MULAW_MCFORMATS *)
	AL_FORMAT_MONO_MULAW* = 10014H;
	AL_FORMAT_STEREO_MULAW* = 10015H;
	AL_FORMAT_QUAD_MULAW* = 10021H;
	AL_FORMAT_REAR_MULAW* = 10022H;
	AL_FORMAT_51CHN_MULAW* =10023H;
	AL_FORMAT_61CHN_MULAW* = 10024H;
	AL_FORMAT_71CHN_MULAW*  = 10025H;

	(* AL_EXT_IMA4 extension *)
	AL_FORMAT_MONO_IMA4* = 1300H;
	AL_FORMAT_STEREO_IMA4* = 1301H;

	(* AL_EXT_STATIC_BUFFER extension *)
TYPE 
	TalBufferDataStatic* = PROCEDURE {PlatformCC} (buffer: ALint; format: ALenum; data: ALvoid; size, freq: ALsizei);
VAR 
	alBufferDataStatic-: TalBufferDataStatic;

CONST
	(* ALC_EXT_disconnect extension *)
	ALC_CONNECTED* = 0313H;

TYPE
	(* ALC_EXT_thread_local_context extension *)
	TalcSetThreadContext* = PROCEDURE {PlatformCC} (context: ALCcontext): ALCboolean;  
	TalcGetThreadContext* = PROCEDURE {PlatformCC} (): ALCcontext;  

VAR
	alcSetThreadContext- : TalcSetThreadContext;
	alcGetThreadContext-:  TalcGetThreadContext;


CONST	AL_SOURCE_DISTANCE_MODEL* = 200H;
TYPE
	TalBufferSubDataSOFT* = PROCEDURE{PlatformCC}(buffer: ALuint; format: ALenum; data: ALvoid; offset: ALsizei; lengthx: ALsizei);
VAR 
	alBufferSubDataSOFT- : TalBufferSubDataSOFT;

CONST 
	AL_LOOP_POINTS_SOFT* = 2015H;

	(* AL_EXT_FOLDBACK *)
	AL_EXT_FOLDBACK_NAME* = "AL_EXT_FOLDBACK";
	AL_FOLDBACK_EVENT_BLOCK* = 4112H;
	AL_FOLDBACK_EVENT_START* = 4111H;
	AL_FOLDBACK_EVENT_STOP* = 4113H;
	AL_FOLDBACK_MODE_MONO* = 4101H;
	AL_FOLDBACK_MODE_STEREO* = 4102H;

TYPE
	TFoldbackallbackProc = PROCEDURE {PlatformCC}(a: ALenum; b: ALsizei);
	TalRequestFoldbackStart* = PROCEDURE {PlatformCC} (mode: ALenum; count: ALsizei; length: ALsizei; mem: PALfloat; callback: TFoldbackallbackProc );
	TalRequestFoldbackStop* = PROCEDURE {PlatformCC}(void: ALvoid);
VAR
	alRequestFoldbackStart-: TalRequestFoldbackStart;
	alRequestFoldbackStop- : TalRequestFoldbackStop;
	
CONST
	(* ALC_EXT_DEDICATED *)
	AL_DEDICATED_GAIN* = 0001H;
	AL_EFFECT_DEDICATED_DIALOGUE* = 9001H;
	AL_EFFECT_DEDICATED_LOW_FREQUENCY_EFFECT* = 9000H;

	(* AL_SOFT_buffer_samples *)
	(* Channel configurations *)
	AL_MONO_SOFT* = 1500H;
	AL_STEREO_SOFT* = 1501H;
	AL_REAR_SOFT* = 1502H;
	AL_QUAD_SOFT* = 1503H;
	AL_5POINT1_SOFT* = 1504H;
	AL_6POINT1_SOFT* = 1505H;
	AL_7POINT1_SOFT* = 1506H;

	(* Sample types *)
	AL_BYTE_SOFT* = 1400H;
	AL_UNSIGNED_BYTE_SOFT* = 1401H;
	AL_SHORT_SOFT* = 1402H;
	AL_UNSIGNED_SHORT_SOFT* = 1403H;
	AL_INT_SOFT* = 1404H;
	AL_UNSIGNED_INT_SOFT* = 1405H;
	AL_FLOAT_SOFT* = 1406H;
	AL_DOUBLE_SOFT* = 1407H;
	AL_BYTE3_SOFT* = 1408H;
	AL_UNSIGNED_BYTE3_SOFT* = 1409H;

	(* Storage formats *)
	AL_MONO8_SOFT* = 1100H;
	AL_MONO16_SOFT* = 1101H;
	AL_MONO32F_SOFT* = 10010H;
	AL_STEREO8_SOFT* = 1102H;
	AL_STEREO16_SOFT* = 1103H;
	AL_STEREO32F_SOFT* = 10011H;
	AL_QUAD8_SOFT* = 1204H;
	AL_QUAD16_SOFT* = 1205H;
	AL_QUAD32F_SOFT* = 1206H;
	AL_REAR8_SOFT* = 1207H;
	AL_REAR16_SOFT* = 1208H;
	AL_REAR32F_SOFT* = 1209H;
	AL_5POINT1_8_SOFT* = 120AH;
	AL_5POINT1_16_SOFT* = 120BH;
	AL_5POINT1_32F_SOFT* = 120CH;
	AL_6POINT1_8_SOFT* = 120DH;
	AL_6POINT1_16_SOFT* = 120EH;
	AL_6POINT1_32F_SOFT* = 120FH;
	AL_7POINT1_8_SOFT* = 1210H;
	AL_7POINT1_16_SOFT* = 1211H;
	AL_7POINT1_32F_SOFT* = 1212H;

	(* Buffer attributes *)
	AL_INTERNAL_FORMAT_SOFT* = 2008H;
	AL_BYTE_LENGTH_SOFT* = 2009H;
	AL_SAMPLE_LENGTH_SOFT* = 200AH;
	AL_SEC_LENGTH_SOFT* = 200BH;

TYPE
	TalBufferSamplesSOFT* = PROCEDURE {PlatformCC}(buffer: ALuint; samplerate: ALuint; internalformat: ALenum;  samples: ALsizei; channels: ALenum; type: ALenum; data: ALvoid);
	TalBufferSubSamplesSOFT* = PROCEDURE {PlatformCC} (buffer: ALuint; offset: ALsizei; samples: ALsizei; channels: ALenum; type: ALenum; data: ALvoid);
	TalGetBufferSamplesSOFT* = PROCEDURE {PlatformCC}(buffer: ALuint; offset: ALsizei; samples: ALsizei; channels: ALenum; type: ALenum; data: ALvoid);
	TalIsBufferFormatSupportedSOFT* = PROCEDURE {PlatformCC}(format: ALenum): ALboolean;

VAR 
	alBufferSamplesSOFT-: TalBufferSamplesSOFT;
	alBufferSubSamplesSOFT-: TalBufferSubSamplesSOFT;
	alGetBufferSamplesSOFT-: TalGetBufferSamplesSOFT;
	alIsBufferFormatSupportedSOFT- : TalIsBufferFormatSupportedSOFT;

CONST
	(* AL_SOFT_direct_channels *)
	AL_DIRECT_CHANNELS_SOFT* = 1033H;

	(* ALC_SOFT_loopback *)
	ALC_FORMAT_CHANNELS_SOFT* = 1990H;
	ALC_FORMAT_TYPE_SOFT* = 1991H;

	(* Sample types *)
	ALC_BYTE_SOFT* = 1400H;
	ALC_UNSIGNED_BYTE_SOFT* = 1401H;
	ALC_SHORT_SOFT* = 1402H;
	ALC_UNSIGNED_SHORT_SOFT* = 1403H;
	ALC_INT_SOFT* = 1404H;
	ALC_UNSIGNED_INT_SOFT* = 1405H;
	ALC_FLOAT_SOFT* = 1406H;

	(* Channel configurations *)
	ALC_MONO_SOFT* = 1500H;
	ALC_STEREO_SOFT* = 1501H;
	ALC_QUAD_SOFT* = 1503H;
	ALC_5POINT1_SOFT* = 1504H;
	ALC_6POINT1_SOFT* = 1505H;
	ALC_7POINT1_SOFT* = 1506H;


TYPE
	TalcLoopbackOpenDeviceSOFT* = PROCEDURE {PlatformCC}(CONST  devicename: ARRAY OF ALchar): ALCdevice;
	TalcIsRenderFormatSupportedSOFT* = PROCEDURE {PlatformCC}(device: ALCdevice; freq: ALCsizei; channels: ALCenum; type: ALCenum): ALCboolean;
	TalcRenderSamplesSOFT* = PROCEDURE {PlatformCC}(device: ALCdevice; buffer: ALCvoid; samples: ALCsizei);
VAR 
	alcLoopbackOpenDeviceSOFT- : TalcLoopbackOpenDeviceSOFT;
	alcIsRenderFormatSupportedSOFT-: TalcIsRenderFormatSupportedSOFT;
	alcRenderSamplesSOFT-: TalcRenderSamplesSOFT;

CONST
	(* AL_EXT_STEREO_ANGLES *)
	AL_STEREO_ANGLES* = 1030H;

	(* AL_EXT_SOURCE_RADIUS *)
	AL_SOURCE_RADIUS* = 1031H;

	(* AL_SOFT_source_latency *)
	AL_SAMPLE_OFFSET_LATENCY_SOFT* = 1200H;
	AL_SEC_OFFSET_LATENCY_SOFT* = 1201H;


TYPE
	ALint64SOFT* =  SIGNED64;
	ALuint64SOFT* = UNSIGNED64;
	PALint64SOFT* = ADDRESS;
	PALuint64SOFT* = ADDRESS;
	
	TalSourcedSOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum; value: ALdouble);
	TalSource3dSOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum; value1, value2, value3: ALdouble);
	TalSourcedvSOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum; values: PALdouble);
	TalGetSourcedSOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum; VAR value: ALdouble);
	TalGetSource3dSOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum; VAR value1, value2, value3: ALdouble);
	TalGetSourcedvSOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum; values: PALdouble);
	TalSourcei64SOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum; value: ALint64SOFT);
	TalSource3i64SOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum; value1, value2, value3: ALint64SOFT);
	TalSourcei64vSOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum; values: PALint64SOFT);
	TalGetSourcei64SOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum; VAR value: ALint64SOFT);
	TalGetSource3i64SOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum;  VAR value1, value2, value3: ALint64SOFT);
	TalGetSourcei64vSOFT* = PROCEDURE {PlatformCC}(source: ALuint; param: ALenum;  values: PALint64SOFT);

VAR

	alSourcedSOFT-: TalSourcedSOFT;
	alSource3dSOFT-: TalSource3dSOFT;
	alSourcedvSOFT-: TalSourcedvSOFT;
	alGetSourcedSOFT-: TalGetSourcedSOFT;
	alGetSource3dSOFT-: TalGetSource3dSOFT;
	alGetSourcedvSOFT-: TalGetSourcedvSOFT;
	alSourcei64SOFT-: TalSourcei64SOFT;
	alSource3i64SOFT-: TalSource3i64SOFT;
	alSourcei64vSOFT-: TalSourcei64vSOFT;
	alGetSourcei64SOFT-: TalGetSourcei64SOFT;
	alGetSource3i64SOFT-: TalGetSource3i64SOFT;
	alGetSourcei64vSOFT-: TalGetSourcei64vSOFT;
	
CONST
	(* ALC_EXT_DEFAULT_FILTER_ORDER *)
	ALC_DEFAULT_FILTER_ORDER* =1100H;

	(* AL_SOFT_deferred_updates *)
	AL_DEFERRED_UPDATES_SOFT* = 0C002H;

TYPE
	TalDeferUpdatesSOFT* = PROCEDURE {PlatformCC} (void: ALvoid);
	TalProcessUpdatesSOFT* = PROCEDURE {PlatformCC}(void: ALvoid);
VAR
	alDeferUpdatesSOFT- : TalDeferUpdatesSOFT;
	alProcessUpdatesSOFT- : TalProcessUpdatesSOFT;
	
CONST
	(* AL_SOFT_block_alignment *)
	AL_UNPACK_BLOCK_ALIGNMENT_SOFT* = 200CH;
	AL_PACK_BLOCK_ALIGNMENT_SOFT* = 200DH;

	(* AL_SOFT_MSADPCM *)
	AL_FORMAT_MONO_MSADPCM_SOFT* = 1302H;
	AL_FORMAT_STEREO_MSADPCM_SOFT* = 1303H;

	(* AL_SOFT_source_length *)
(* 	AL_BYTE_LENGTH_SOFT* = 2009H;
	AL_SAMPLE_LENGTH_SOFT* = 200AH;
	AL_SEC_LENGTH_SOFT* = 200BH;
*)

	(* ALC_SOFT_pause_device *)
TYPE 
	TalcDevicePauseSOFT* = PROCEDURE {PlatformCC} (device: ALCdevice);
	TalcDeviceResumeSOFT* = PROCEDURE {PlatformCC} (device: ALCdevice);
VAR
	alcDevicePauseSOFT-: TalcDevicePauseSOFT;
	alcDeviceResumeSOFT- : TalcDeviceResumeSOFT;

CONST
	(* AL_EXT_BFORMAT *)

	AL_FORMAT_BFORMAT2D_8* = 20021H;
	AL_FORMAT_BFORMAT2D_16* = 20022H;
	AL_FORMAT_BFORMAT2D_FLOAT32* = 20023H;
	AL_FORMAT_BFORMAT3D_8* = 20031H;
	AL_FORMAT_BFORMAT3D_16* = 20032H;
	AL_FORMAT_BFORMAT3D_FLOAT32* = 20033H;

	(* AL_EXT_MULAW_BFORMAT *)
	AL_FORMAT_BFORMAT2D_MULAW* = 10031H;
	AL_FORMAT_BFORMAT3D_MULAW* = 10032H;

	(* ALC_SOFT_HRTF *)
	ALC_HRTF_SOFT* = 1992H;
	ALC_DONT_CARE_SOFT* = 0002H;
	ALC_HRTF_STATUS_SOFT* = 1993H;
	ALC_HRTF_DISABLED_SOFT* = 0000H;
	ALC_HRTF_ENABLED_SOFT* = 0001H;
	ALC_HRTF_DENIED_SOFT* = 0002H;
	ALC_HRTF_REQUIRED_SOFT* = 0003H;
	ALC_HRTF_HEADPHONES_DETECTED_SOFT* = 0004H;
	ALC_HRTF_UNSUPPORTED_FORMAT_SOFT* = 0005H;
	ALC_NUM_HRTF_SPECIFIERS_SOFT* = 1994H;
	ALC_HRTF_SPECIFIER_SOFT* = 1995H;
	ALC_HRTF_ID_SOFT* = 1996H;
	
TYPE
	TalcGetStringiSOFT* = PROCEDURE {PlatformCC} (device: ALCdevice; paramName: ALCenum; index: ALCsizei): ADDRESS;
	TalcResetDeviceSOFT* = PROCEDURE {PlatformCC} (device: ALCdevice; attribs: ADDRESS (* array of ALCint *)): ALCboolean;
	
	TalGetStringiSOFT* = PROCEDURE {PlatformCC} (paramName: ALCenum; index: ALCsizei): ADDRESS;
VAR 
	xalcGetStringiSOFT : TalcGetStringiSOFT;
	alcResetDeviceSOFT- : TalcResetDeviceSOFT;
	xalGetStringiSOFT : TalGetStringiSOFT;
	
	(* wrapper for xalcGetStringiSOFT *)
	PROCEDURE alcGetStringiSOFT* (device: ALCdevice; paramName: ALCenum; index: ALCsizei): Strings.String;
	VAR sadr: ADDRESS;
	BEGIN
		sadr := xalcGetStringiSOFT(device, paramName, index);
		RETURN AL.GetStringFromAddr(sadr);
	END alcGetStringiSOFT;

	PROCEDURE alGetStringiSOFT* (paramName: ALCenum; index: ALCsizei): Strings.String;
	VAR sadr: ADDRESS;
	BEGIN
		sadr := xalGetStringiSOFT(paramName, index);
		RETURN AL.GetStringFromAddr(sadr);
	END alGetStringiSOFT;

CONST
	AL_GAIN_LIMIT_SOFT* = 0x200E;
	
	AL_NUM_RESAMPLERS_SOFT* = 0x1210;
	AL_DEFAULT_RESAMPLER_SOFT* = 0x1211;
	AL_SOURCE_RESAMPLER_SOFT* = 0x1212;
	AL_RESAMPLER_NAME_SOFT* =  0x1213;


	AL_SOURCE_SPATIALIZE_SOFT* =  0x1214;
	AL_AUTO_SOFT* =   0x0002;

	ALC_OUTPUT_LIMITER_SOFT* =  0x199A;

PROCEDURE Init;
BEGIN
	AL.alGetProcAddress( 'alBufferDataStatic' , ADDRESSOF( alBufferDataStatic ));
	AL.alGetProcAddress( 'alcSetThreadContext' , ADDRESSOF( alcSetThreadContext ));
	AL.alGetProcAddress( 'alcGetThreadContext' , ADDRESSOF( alcGetThreadContext ));
		
	AL.alGetProcAddress( 'alBufferSubDataSOFT' , ADDRESSOF( alBufferSubDataSOFT ));
	
	AL.alGetProcAddress( 'alRequestFoldbackStart' , ADDRESSOF( alRequestFoldbackStart ));
	AL.alGetProcAddress( 'alRequestFoldbackStop' , ADDRESSOF( alRequestFoldbackStop ));
	
	AL.alGetProcAddress( 'alBufferSamplesSOFT' , ADDRESSOF( alBufferSamplesSOFT ));
	AL.alGetProcAddress( 'alBufferSubSamplesSOFT' , ADDRESSOF( alBufferSubSamplesSOFT ));
	AL.alGetProcAddress( 'alGetBufferSamplesSOFT' , ADDRESSOF( alGetBufferSamplesSOFT ));
	AL.alGetProcAddress( 'alIsBufferFormatSupportedSOFT' , ADDRESSOF( alIsBufferFormatSupportedSOFT ));
	
	AL.alGetProcAddress( 'alcLoopbackOpenDeviceSOFT' , ADDRESSOF( alcLoopbackOpenDeviceSOFT ));
	AL.alGetProcAddress( 'alcIsRenderFormatSupportedSOFT' , ADDRESSOF( alcIsRenderFormatSupportedSOFT ));
	AL.alGetProcAddress( 'alcRenderSamplesSOFT' , ADDRESSOF( alcRenderSamplesSOFT ));
	
	AL.alGetProcAddress( 'alSourcedSOFT' , ADDRESSOF( alSourcedSOFT ));
	AL.alGetProcAddress( 'alSource3dSOFT' , ADDRESSOF( alSource3dSOFT ));
	AL.alGetProcAddress( 'alSourcedvSOFT' , ADDRESSOF( alSourcedvSOFT ));
	AL.alGetProcAddress( 'alGetSourcedSOFT' , ADDRESSOF( alGetSourcedSOFT ));
	AL.alGetProcAddress( 'alGetSource3dSOFT' , ADDRESSOF( alGetSource3dSOFT ));
	AL.alGetProcAddress( 'alGetSourcedvSOFT' , ADDRESSOF( alGetSourcedvSOFT ));
	AL.alGetProcAddress( 'alSourcei64SOFT' , ADDRESSOF( alSourcei64SOFT ));
	AL.alGetProcAddress( 'alSource3i64SOFT' , ADDRESSOF( alSource3i64SOFT ));
	AL.alGetProcAddress( 'alSourcei64vSOFT' , ADDRESSOF( alSourcei64vSOFT ));
	AL.alGetProcAddress( 'alGetSourcei64SOFT' , ADDRESSOF( alGetSourcei64SOFT ));
	AL.alGetProcAddress( 'alGetSource3i64SOFT' , ADDRESSOF( alGetSource3i64SOFT ));
	AL.alGetProcAddress( 'alGetSourcei64vSOFT' , ADDRESSOF( alGetSourcei64vSOFT ));

	AL.alGetProcAddress( 'alDeferUpdatesSOFT' , ADDRESSOF( alDeferUpdatesSOFT ));
	AL.alGetProcAddress( 'alProcessUpdatesSOFT' , ADDRESSOF( alProcessUpdatesSOFT ));
	AL.alGetProcAddress( 'alcDevicePauseSOFT' , ADDRESSOF( alcDevicePauseSOFT ));
	AL.alGetProcAddress( 'alcDeviceResumeSOFT' , ADDRESSOF( alcDeviceResumeSOFT ));

	AL.alGetProcAddress( 'alcGetStringiSOFT' , ADDRESSOF( xalcGetStringiSOFT ));
	AL.alGetProcAddress( 'alcResetDeviceSOFT' , ADDRESSOF( alcResetDeviceSOFT ));

	AL.alGetProcAddress( 'alGetStringiSOFT' , ADDRESSOF( xalGetStringiSOFT ));
END Init;

BEGIN
	Init;
END OpenALext.
