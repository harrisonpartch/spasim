MODULE X11KeySymDef;

	(* #include keysymdef.h *)
	(***********************************************************
	Copyright 1987, 1994, 1998  The Open Group

	Permission to use, copy, modify, distribute, and sell this software and its
	documentation for any purpose is hereby granted without fee, provided that
	the above copyright notice appear in all copies and that both that
	copyright notice and this permission notice appear in supporting
	documentation.

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR
	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.

	Except as contained in this notice, the name of The Open Group shall
	not be used in advertising or otherwise to promote the sale, use or
	other dealings in this Software without prior written authorization
	from The Open Group.


	Copyright 1987 by Digital Equipment Corporation, Maynard, Massachusetts

	                        All Rights Reserved

	Permission to use, copy, modify, and distribute this software and its
	documentation for any purpose and without fee is hereby granted,
	provided that the above copyright notice appear in all copies and that
	both that copyright notice and this permission notice appear in
	supporting documentation, and that the name of Digital not be
	used in advertising or publicity pertaining to distribution of the
	software without specific, written prior permission.

	DIGITAL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING
	ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL
	DIGITAL BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR
	ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
	WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
	ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
	SOFTWARE.

	******************************************************************)

	(*
	 * The "X11 Window System Protocol" standard defines in Appendix A the
	 * keysym codes. These 29-bit integer values identify characters or
	 * functions associated with each key (e.g., via the visible
	 * engraving) of a keyboard layout. This file assigns mnemonic macro
	 * names for these keysyms.
	 *
	 * This file is also compiled (by src/util/makekeys.c in libX11) into
	 * hash tables that can be accessed with X11 library functions such as
	 * XStringToKeysym() and XKeysymToString().
	 *
	 * Where a keysym corresponds one-to-one to an ISO 10646 / Unicode
	 * character, this is noted in a comment that provides both the U+xxxx
	 * Unicode position, as well as the official Unicode name of the
	 * character.
	 *
	 * Where the correspondence is either not one-to-one or semantically
	 * unclear, the Unicode position and name are enclosed in
	 * parentheses. Such legacy keysyms should be considered deprecated
	 * and are not recommended for use in future keyboard mappings.
	 *
	 * For any future extension of the keysyms with characters already
	 * found in ISO 10646 / Unicode, the following algorithm shall be
	 * used. The new keysym code position will simply be the character's
	 * Unicode number plus 0x01000000. The keysym values in the range
	 * 0x01000100 to 0x0110ffff are reserved to represent Unicode
	 * characters in the range U+0100 to U+10FFFF.
	 *
	 * While most newer Unicode-based X11 clients do already accept
	 * Unicode-mapped keysyms in the range 0x01000100 to 0x0110ffff, it
	 * will remain necessary for clients -- in the interest of
	 * compatibility with existing servers -- to also understand the
	 * existing legacy keysym values in the range 0x0100 to 0x20ff.
	 *
	 * Where several mnemonic names are defined for the same keysym in this
	 * file, all but the first one listed should be considered deprecated.
	 *
	 * Mnemonic names for keysyms are defined in this file with lines
	 * that match one of these Perl regular expressions:
	 *

	 *
	 * Before adding new keysyms, please do consider the following: In
	 * addition to the keysym names defined in this file, the
	 * XStringToKeysym() and XKeysymToString() functions will also handle
	 * any keysym string of the form "U0020" to "U007E" and "U00A0" to
	 * "U10FFFF" for all possible Unicode characters. In other words,
	 * every possible Unicode character has already a keysym string
	 * defined algorithmically, even if it is not listed here. Therefore,
	 * defining an additional keysym macro is only necessary where a
	 * non-hexadecimal mnemonic name is needed, or where the new keysym
	 * does not represent any existing Unicode character.
	 *
	 * When adding new keysyms to this file, do not forget to also update the
	 * following:
	 *
	 *   - the mappings in src/KeyBind.c in the repo
	 *     git://anongit.freedesktop.org/xorg/lib/libX11
	 *
	 *   - the protocol specification in specs/XProtocol/X11.keysyms
	 *     in the repo git://anongit.freedesktop.org/xorg/doc/xorg-docs
	 *
	 *)

	CONST
	 XK_VoidSymbol* = 0FFFFFFH;  (* Void symbol *)

	(* #ifdef XK_MISCELLANY *)
	(*
	 * TTY function keys, cleverly chosen to map to ASCII, for convenience of
	 * programming, but could have been arbitrary (at the cost of lookup
	 * tables in client code).
	 *)

	 XK_BackSpace* = 0FF08H;  (* Back space, back char *)
	 XK_Tab* = 0FF09H;
	 XK_Linefeed* = 0FF0AH;  (* Linefeed, LF *)
	 XK_Clear* = 0FF0BH;
	 XK_Return* = 0FF0DH;  (* Return, enter *)
	 XK_Pause* = 0FF13H;  (* Pause, hold *)
	 XK_Scroll_Lock* = 0FF14H;
	 XK_Sys_Req* = 0FF15H;
	 XK_Escape* = 0FF1BH;
	 XK_Delete* = 0FFFFH;  (* Delete, rubout *)



	(* International & multi-key character composition *)

	 XK_Multi_key* = 0FF20H;  (* Multi-key character compose *)
	 XK_Codeinput* = 0FF37H;
	 XK_SingleCandidate* = 0FF3CH;
	 XK_MultipleCandidate* = 0FF3DH;
	 XK_PreviousCandidate* = 0FF3EH;

	(* Japanese keyboard support *)

	 XK_Kanji* = 0FF21H;  (* Kanji, Kanji convert *)
	 XK_Muhenkan* = 0FF22H;  (* Cancel Conversion *)
	 XK_Henkan_Mode* = 0FF23H;  (* Start/Stop Conversion *)
	 XK_Henkan* = 0FF23H;  (* Alias for Henkan_Mode *)
	 XK_Romaji* = 0FF24H;  (* to Romaji *)
	 XK_Hiragana* = 0FF25H;  (* to Hiragana *)
	 XK_Katakana* = 0FF26H;  (* to Katakana *)
	 XK_Hiragana_Katakana* = 0FF27H;  (* Hiragana/Katakana toggle *)
	 XK_Zenkaku* = 0FF28H;  (* to Zenkaku *)
	 XK_Hankaku* = 0FF29H;  (* to Hankaku *)
	 XK_Zenkaku_Hankaku* = 0FF2AH;  (* Zenkaku/Hankaku toggle *)
	 XK_Touroku* = 0FF2BH;  (* Add to Dictionary *)
	 XK_Massyo* = 0FF2CH;  (* Delete from Dictionary *)
	 XK_Kana_Lock* = 0FF2DH;  (* Kana Lock *)
	 XK_Kana_Shift* = 0FF2EH;  (* Kana Shift *)
	 XK_Eisu_Shift* = 0FF2FH;  (* Alphanumeric Shift *)
	 XK_Eisu_toggle* = 0FF30H;  (* Alphanumeric toggle *)
	 XK_Kanji_Bangou* = 0FF37H;  (* Codeinput *)
	 XK_Zen_Koho* = 0FF3DH;  (* Multiple/All Candidate(s) *)
	 XK_Mae_Koho* = 0FF3EH;  (* Previous Candidate *)

	(* 0xff31 thru 0xff3f are under XK_KOREAN *)

	(* Cursor control & motion *)

	 XK_Home* = 0FF50H;
	 XK_Left* = 0FF51H;  (* Move left, left arrow *)
	 XK_Up* = 0FF52H;  (* Move up, up arrow *)
	 XK_Right* = 0FF53H;  (* Move right, right arrow *)
	 XK_Down* = 0FF54H;  (* Move down, down arrow *)
	 XK_Prior* = 0FF55H;  (* Prior, previous *)
	 XK_Page_Up* = 0FF55H;
	 XK_Next* = 0FF56H;  (* Next *)
	 XK_Page_Down* = 0FF56H;
	 XK_End* = 0FF57H;  (* EOL *)
	 XK_Begin* = 0FF58H;  (* BOL *)


	(* Misc functions *)

	 XK_Select* = 0FF60H;  (* Select, mark *)
	 XK_Print* = 0FF61H;
	 XK_Execute* = 0FF62H;  (* Execute, run, do *)
	 XK_Insert* = 0FF63H;  (* Insert, insert here *)
	 XK_Undo* = 0FF65H;
	 XK_Redo* = 0FF66H;  (* Redo, again *)
	 XK_Menu* = 0FF67H;
	 XK_Find* = 0FF68H;  (* Find, search *)
	 XK_Cancel* = 0FF69H;  (* Cancel, stop, abort, exit *)
	 XK_Help* = 0FF6AH;  (* Help *)
	 XK_Break* = 0FF6BH;
	 XK_Mode_switch* = 0FF7EH;  (* Character set switch *)
	 XK_script_switch* = 0FF7EH;  (* Alias for mode_switch *)
	 XK_Num_Lock* = 0FF7FH;

	(* Keypad functions, keypad numbers cleverly chosen to map to ASCII *)

	 XK_KP_Space* = 0FF80H;  (* Space *)
	 XK_KP_Tab* = 0FF89H;
	 XK_KP_Enter* = 0FF8DH;  (* Enter *)
	 XK_KP_F1* = 0FF91H;  (* PF1, KP_A, ... *)
	 XK_KP_F2* = 0FF92H;
	 XK_KP_F3* = 0FF93H;
	 XK_KP_F4* = 0FF94H;
	 XK_KP_Home* = 0FF95H;
	 XK_KP_Left* = 0FF96H;
	 XK_KP_Up* = 0FF97H;
	 XK_KP_Right* = 0FF98H;
	 XK_KP_Down* = 0FF99H;
	 XK_KP_Prior* = 0FF9AH;
	 XK_KP_Page_Up* = 0FF9AH;
	 XK_KP_Next* = 0FF9BH;
	 XK_KP_Page_Down* = 0FF9BH;
	 XK_KP_End* = 0FF9CH;
	 XK_KP_Begin* = 0FF9DH;
	 XK_KP_Insert* = 0FF9EH;
	 XK_KP_Delete* = 0FF9FH;
	 XK_KP_Equal* = 0FFBDH;  (* Equals *)
	 XK_KP_Multiply* = 0FFAAH;
	 XK_KP_Add* = 0FFABH;
	 XK_KP_Separator* = 0FFACH;  (* Separator, often comma *)
	 XK_KP_Subtract* = 0FFADH;
	 XK_KP_Decimal* = 0FFAEH;
	 XK_KP_Divide* = 0FFAFH;

	 XK_KP_0* = 0FFB0H;
	 XK_KP_1* = 0FFB1H;
	 XK_KP_2* = 0FFB2H;
	 XK_KP_3* = 0FFB3H;
	 XK_KP_4* = 0FFB4H;
	 XK_KP_5* = 0FFB5H;
	 XK_KP_6* = 0FFB6H;
	 XK_KP_7* = 0FFB7H;
	 XK_KP_8* = 0FFB8H;
	 XK_KP_9* = 0FFB9H;



	(*
	 * Auxiliary functions; note the duplicate definitions for left and right
	 * function keys;  Sun keyboards and a few other manufacturers have such
	 * function key groups on the left and/or right sides of the keyboard.
	 * We've not found a keyboard with more than 35 function keys total.
	 *)

	 XK_F1* = 0FFBEH;
	 XK_F2* = 0FFBFH;
	 XK_F3* = 0FFC0H;
	 XK_F4* = 0FFC1H;
	 XK_F5* = 0FFC2H;
	 XK_F6* = 0FFC3H;
	 XK_F7* = 0FFC4H;
	 XK_F8* = 0FFC5H;
	 XK_F9* = 0FFC6H;
	 XK_F10* = 0FFC7H;
	 XK_F11* = 0FFC8H;
	 XK_L1* = 0FFC8H;
	 XK_F12* = 0FFC9H;
	 XK_L2* = 0FFC9H;
	 XK_F13* = 0FFCAH;
	 XK_L3* = 0FFCAH;
	 XK_F14* = 0FFCBH;
	 XK_L4* = 0FFCBH;
	 XK_F15* = 0FFCCH;
	 XK_L5* = 0FFCCH;
	 XK_F16* = 0FFCDH;
	 XK_L6* = 0FFCDH;
	 XK_F17* = 0FFCEH;
	 XK_L7* = 0FFCEH;
	 XK_F18* = 0FFCFH;
	 XK_L8* = 0FFCFH;
	 XK_F19* = 0FFD0H;
	 XK_L9* = 0FFD0H;
	 XK_F20* = 0FFD1H;
	 XK_L10* = 0FFD1H;
	 XK_F21* = 0FFD2H;
	 XK_R1* = 0FFD2H;
	 XK_F22* = 0FFD3H;
	 XK_R2* = 0FFD3H;
	 XK_F23* = 0FFD4H;
	 XK_R3* = 0FFD4H;
	 XK_F24* = 0FFD5H;
	 XK_R4* = 0FFD5H;
	 XK_F25* = 0FFD6H;
	 XK_R5* = 0FFD6H;
	 XK_F26* = 0FFD7H;
	 XK_R6* = 0FFD7H;
	 XK_F27* = 0FFD8H;
	 XK_R7* = 0FFD8H;
	 XK_F28* = 0FFD9H;
	 XK_R8* = 0FFD9H;
	 XK_F29* = 0FFDAH;
	 XK_R9* = 0FFDAH;
	 XK_F30* = 0FFDBH;
	 XK_R10* = 0FFDBH;
	 XK_F31* = 0FFDCH;
	 XK_R11* = 0FFDCH;
	 XK_F32* = 0FFDDH;
	 XK_R12* = 0FFDDH;
	 XK_F33* = 0FFDEH;
	 XK_R13* = 0FFDEH;
	 XK_F34* = 0FFDFH;
	 XK_R14* = 0FFDFH;
	 XK_F35* = 0FFE0H;
	 XK_R15* = 0FFE0H;

	(* Modifiers *)

	 XK_Shift_L* = 0FFE1H;  (* Left shift *)
	 XK_Shift_R* = 0FFE2H;  (* Right shift *)
	 XK_Control_L* = 0FFE3H;  (* Left control *)
	 XK_Control_R* = 0FFE4H;  (* Right control *)
	 XK_Caps_Lock* = 0FFE5H;  (* Caps lock *)
	 XK_Shift_Lock* = 0FFE6H;  (* Shift lock *)

	 XK_Meta_L* = 0FFE7H;  (* Left meta *)
	 XK_Meta_R* = 0FFE8H;  (* Right meta *)
	 XK_Alt_L* = 0FFE9H;  (* Left alt *)
	 XK_Alt_R* = 0FFEAH;  (* Right alt *)
	 XK_Super_L* = 0FFEBH;  (* Left super *)
	 XK_Super_R* = 0FFECH;  (* Right super *)
	 XK_Hyper_L* = 0FFEDH;  (* Left hyper *)
	 XK_Hyper_R* = 0FFEEH;  (* Right hyper *)
	(* #endif *) (* XK_MISCELLANY *)

	(*
	 * Keyboard (XKB) Extension function and modifier keys
	 * (from Appendix C of "The X Keyboard Extension: Protocol Specification")
	 * Byte 3* = 0xfe
	 *)

	(* #ifdef XK_XKB_KEYS *)
	 XK_ISO_Lock* = 0FE01H;
	 XK_ISO_Level2_Latch* = 0FE02H;
	 XK_ISO_Level3_Shift* = 0FE03H;
	 XK_ISO_Level3_Latch* = 0FE04H;
	 XK_ISO_Level3_Lock* = 0FE05H;
	 XK_ISO_Level5_Shift* = 0FE11H;
	 XK_ISO_Level5_Latch* = 0FE12H;
	 XK_ISO_Level5_Lock* = 0FE13H;
	 XK_ISO_Group_Shift* = 0FF7EH;  (* Alias for mode_switch *)
	 XK_ISO_Group_Latch* = 0FE06H;
	 XK_ISO_Group_Lock* = 0FE07H;
	 XK_ISO_Next_Group* = 0FE08H;
	 XK_ISO_Next_Group_Lock* = 0FE09H;
	 XK_ISO_Prev_Group* = 0FE0AH;
	 XK_ISO_Prev_Group_Lock* = 0FE0BH;
	 XK_ISO_First_Group* = 0FE0CH;
	 XK_ISO_First_Group_Lock* = 0FE0DH;
	 XK_ISO_Last_Group* = 0FE0EH;
	 XK_ISO_Last_Group_Lock* = 0FE0FH;

	 XK_ISO_Left_Tab* = 0FE20H;
	 XK_ISO_Move_Line_Up* = 0FE21H;
	 XK_ISO_Move_Line_Down* = 0FE22H;
	 XK_ISO_Partial_Line_Up* = 0FE23H;
	 XK_ISO_Partial_Line_Down* = 0FE24H;
	 XK_ISO_Partial_Space_Left* = 0FE25H;
	 XK_ISO_Partial_Space_Right* = 0FE26H;
	 XK_ISO_Set_Margin_Left* = 0FE27H;
	 XK_ISO_Set_Margin_Right* = 0FE28H;
	 XK_ISO_Release_Margin_Left* = 0FE29H;
	 XK_ISO_Release_Margin_Right* = 0FE2AH;
	 XK_ISO_Release_Both_Margins* = 0FE2BH;
	 XK_ISO_Fast_Cursor_Left* = 0FE2CH;
	 XK_ISO_Fast_Cursor_Right* = 0FE2DH;
	 XK_ISO_Fast_Cursor_Up* = 0FE2EH;
	 XK_ISO_Fast_Cursor_Down* = 0FE2FH;
	 XK_ISO_Continuous_Underline* = 0FE30H;
	 XK_ISO_Discontinuous_Underline* = 0FE31H;
	 XK_ISO_Emphasize* = 0FE32H;
	 XK_ISO_Center_Object* = 0FE33H;
	 XK_ISO_Enter* = 0FE34H;

	 XK_dead_grave* = 0FE50H;
	 XK_dead_acute* = 0FE51H;
	 XK_dead_circumflex* = 0FE52H;
	 XK_dead_tilde* = 0FE53H;
	 XK_dead_perispomeni* = 0FE53H;  (* alias for dead_tilde *)
	 XK_dead_macron* = 0FE54H;
	 XK_dead_breve* = 0FE55H;
	 XK_dead_abovedot* = 0FE56H;
	 XK_dead_diaeresis* = 0FE57H;
	 XK_dead_abovering* = 0FE58H;
	 XK_dead_doubleacute* = 0FE59H;
	 XK_dead_caron* = 0FE5AH;
	 XK_dead_cedilla* = 0FE5BH;
	 XK_dead_ogonek* = 0FE5CH;
	 XK_dead_iota* = 0FE5DH;
	 XK_dead_voiced_sound* = 0FE5EH;
	 XK_dead_semivoiced_sound* = 0FE5FH;
	 XK_dead_belowdot* = 0FE60H;
	 XK_dead_hook* = 0FE61H;
	 XK_dead_horn* = 0FE62H;
	 XK_dead_stroke* = 0FE63H;
	 XK_dead_abovecomma* = 0FE64H;
	 XK_dead_psili* = 0FE64H;  (* alias for dead_abovecomma *)
	 XK_dead_abovereversedcomma* = 0FE65H;
	 XK_dead_dasia* = 0FE65H;  (* alias for dead_abovereversedcomma *)
	 XK_dead_doublegrave* = 0FE66H;
	 XK_dead_belowring* = 0FE67H;
	 XK_dead_belowmacron* = 0FE68H;
	 XK_dead_belowcircumflex* = 0FE69H;
	 XK_dead_belowtilde* = 0FE6AH;
	 XK_dead_belowbreve* = 0FE6BH;
	 XK_dead_belowdiaeresis* = 0FE6CH;
	 XK_dead_invertedbreve* = 0FE6DH;
	 XK_dead_belowcomma* = 0FE6EH;
	 XK_dead_currency* = 0FE6FH;

	(* dead vowels for universal syllable entry *)
	 XK_dead_a1* = 0FE80H;
	 XK_dead_A* = 0FE81H;
	 XK_dead_e1* = 0FE82H;
	 XK_dead_E* = 0FE83H;
	 XK_dead_i1* = 0FE84H;
	 XK_dead_I* = 0FE85H;
	 XK_dead_o1* = 0FE86H;
	 XK_dead_O* = 0FE87H;
	 XK_dead_u1* = 0FE88H;
	 XK_dead_U* = 0FE89H;
	 XK_dead_small_schwa* = 0FE8AH;
	 XK_dead_capital_schwa* = 0FE8BH;

	 XK_First_Virtual_Screen* = 0FED0H;
	 XK_Prev_Virtual_Screen* = 0FED1H;
	 XK_Next_Virtual_Screen* = 0FED2H;
	 XK_Last_Virtual_Screen* = 0FED4H;
	 XK_Terminate_Server* = 0FED5H;

	 XK_AccessX_Enable* = 0FE70H;
	 XK_AccessX_Feedback_Enable* = 0FE71H;
	 XK_RepeatKeys_Enable* = 0FE72H;
	 XK_SlowKeys_Enable* = 0FE73H;
	 XK_BounceKeys_Enable* = 0FE74H;
	 XK_StickyKeys_Enable* = 0FE75H;
	 XK_MouseKeys_Enable* = 0FE76H;
	 XK_MouseKeys_Accel_Enable* = 0FE77H;
	 XK_Overlay1_Enable* = 0FE78H;
	 XK_Overlay2_Enable* = 0FE79H;
	 XK_AudibleBell_Enable* = 0FE7AH;

	 XK_Pointer_Left* = 0FEE0H;
	 XK_Pointer_Right* = 0FEE1H;
	 XK_Pointer_Up* = 0FEE2H;
	 XK_Pointer_Down* = 0FEE3H;
	 XK_Pointer_UpLeft* = 0FEE4H;
	 XK_Pointer_UpRight* = 0FEE5H;
	 XK_Pointer_DownLeft* = 0FEE6H;
	 XK_Pointer_DownRight* = 0FEE7H;
	 XK_Pointer_Button_Dflt* = 0FEE8H;
	 XK_Pointer_Button1* = 0FEE9H;
	 XK_Pointer_Button2* = 0FEEAH;
	 XK_Pointer_Button3* = 0FEEBH;
	 XK_Pointer_Button4* = 0FEECH;
	 XK_Pointer_Button5* = 0FEEDH;
	 XK_Pointer_DblClick_Dflt* = 0FEEEH;
	 XK_Pointer_DblClick1* = 0FEEFH;
	 XK_Pointer_DblClick2* = 0FEF0H;
	 XK_Pointer_DblClick3* = 0FEF1H;
	 XK_Pointer_DblClick4* = 0FEF2H;
	 XK_Pointer_DblClick5* = 0FEF3H;
	 XK_Pointer_Drag_Dflt* = 0FEF4H;
	 XK_Pointer_Drag1* = 0FEF5H;
	 XK_Pointer_Drag2* = 0FEF6H;
	 XK_Pointer_Drag3* = 0FEF7H;
	 XK_Pointer_Drag4* = 0FEF8H;
	 XK_Pointer_Drag5* = 0FEFDH;

	 XK_Pointer_EnableKeys* = 0FEF9H;
	 XK_Pointer_Accelerate* = 0FEFAH;
	 XK_Pointer_DfltBtnNext* = 0FEFBH;
	 XK_Pointer_DfltBtnPrev* = 0FEFCH;

	(* #endif *) (* XK_XKB_KEYS *)

	(*
	 * 3270 Terminal Keys
	 * Byte 3* = 0xfd
	 *)

	(* #ifdef XK_3270 *)
	 XK_3270_Duplicate* = 0FD01H;
	 XK_3270_FieldMark* = 0FD02H;
	 XK_3270_Right2* = 0FD03H;
	 XK_3270_Left2* = 0FD04H;
	 XK_3270_BackTab* = 0FD05H;
	 XK_3270_EraseEOF* = 0FD06H;
	 XK_3270_EraseInput* = 0FD07H;
	 XK_3270_Reset* = 0FD08H;
	 XK_3270_Quit* = 0FD09H;
	 XK_3270_PA1* = 0FD0AH;
	 XK_3270_PA2* = 0FD0BH;
	 XK_3270_PA3* = 0FD0CH;
	 XK_3270_Test* = 0FD0DH;
	 XK_3270_Attn* = 0FD0EH;
	 XK_3270_CursorBlink* = 0FD0FH;
	 XK_3270_AltCursor* = 0FD10H;
	 XK_3270_KeyClick* = 0FD11H;
	 XK_3270_Jump* = 0FD12H;
	 XK_3270_Ident* = 0FD13H;
	 XK_3270_Rule* = 0FD14H;
	 XK_3270_Copy* = 0FD15H;
	 XK_3270_Play* = 0FD16H;
	 XK_3270_Setup* = 0FD17H;
	 XK_3270_Record* = 0FD18H;
	 XK_3270_ChangeScreen* = 0FD19H;
	 XK_3270_DeleteWord* = 0FD1AH;
	 XK_3270_ExSelect* = 0FD1BH;
	 XK_3270_CursorSelect* = 0FD1CH;
	 XK_3270_PrintScreen* = 0FD1DH;
	 XK_3270_Enter* = 0FD1EH;
	(* #endif *) (* XK_3270 *)

	(*
	 * Latin 1
	 * (ISO/IEC 8859-1* = Unicode U+0020..U+00FF)
	 * Byte 3* = 0
	 *)
	(* #ifdef XK_LATIN1 *)
	 XK_space* = 00020H;  (* U+0020 SPACE *)
	 XK_exclam* = 00021H;  (* U+0021 EXCLAMATION MARK *)
	 XK_quotedbl* = 00022H;  (* U+0022 QUOTATION MARK *)
	 XK_numbersign* = 00023H;  (* U+0023 NUMBER SIGN *)
	 XK_dollar* = 00024H;  (* U+0024 DOLLAR SIGN *)
	 XK_percent* = 00025H;  (* U+0025 PERCENT SIGN *)
	 XK_ampersand* = 00026H;  (* U+0026 AMPERSAND *)
	 XK_apostrophe* = 00027H;  (* U+0027 APOSTROPHE *)
	 XK_quoteright* = 00027H;  (* deprecated *)
	 XK_parenleft* = 00028H;  (* U+0028 LEFT PARENTHESIS *)
	 XK_parenright* = 00029H;  (* U+0029 RIGHT PARENTHESIS *)
	 XK_asterisk* = 0002AH;  (* U+002A ASTERISK *)
	 XK_plus* = 0002BH;  (* U+002B PLUS SIGN *)
	 XK_comma* = 0002CH;  (* U+002C COMMA *)
	 XK_minus* = 0002DH;  (* U+002D HYPHEN-MINUS *)
	 XK_period* = 0002EH;  (* U+002E FULL STOP *)
	 XK_slash* = 0002FH;  (* U+002F SOLIDUS *)
	 XK_0* = 00030H;  (* U+0030 DIGIT ZERO *)
	 XK_1* = 00031H;  (* U+0031 DIGIT ONE *)
	 XK_2* = 00032H;  (* U+0032 DIGIT TWO *)
	 XK_3* = 00033H;  (* U+0033 DIGIT THREE *)
	 XK_4* = 00034H;  (* U+0034 DIGIT FOUR *)
	 XK_5* = 00035H;  (* U+0035 DIGIT FIVE *)
	 XK_6* = 00036H;  (* U+0036 DIGIT SIX *)
	 XK_7* = 00037H;  (* U+0037 DIGIT SEVEN *)
	 XK_8* = 00038H;  (* U+0038 DIGIT EIGHT *)
	 XK_9* = 00039H;  (* U+0039 DIGIT NINE *)
	 XK_colon* = 0003AH;  (* U+003A COLON *)
	 XK_semicolon* = 0003BH;  (* U+003B SEMICOLON *)
	 XK_less* = 0003CH;  (* U+003C LESS-THAN SIGN *)
	 XK_equal* = 0003DH;  (* U+003D EQUALS SIGN *)
	 XK_greater* = 0003EH;  (* U+003E GREATER-THAN SIGN *)
	 XK_question* = 0003FH;  (* U+003F QUESTION MARK *)
	 XK_at* = 00040H;  (* U+0040 COMMERCIAL AT *)
	 XK_A* = 00041H;  (* U+0041 LATIN CAPITAL LETTER A *)
	 XK_B* = 00042H;  (* U+0042 LATIN CAPITAL LETTER B *)
	 XK_C* = 00043H;  (* U+0043 LATIN CAPITAL LETTER C *)
	 XK_D* = 00044H;  (* U+0044 LATIN CAPITAL LETTER D *)
	 XK_E* = 00045H;  (* U+0045 LATIN CAPITAL LETTER E *)
	 XK_F* = 00046H;  (* U+0046 LATIN CAPITAL LETTER F *)
	 XK_G* = 00047H;  (* U+0047 LATIN CAPITAL LETTER G *)
	 XK_H* = 00048H;  (* U+0048 LATIN CAPITAL LETTER H *)
	 XK_I* = 00049H;  (* U+0049 LATIN CAPITAL LETTER I *)
	 XK_J* = 0004AH;  (* U+004A LATIN CAPITAL LETTER J *)
	 XK_K* = 0004BH;  (* U+004B LATIN CAPITAL LETTER K *)
	 XK_L* = 0004CH;  (* U+004C LATIN CAPITAL LETTER L *)
	 XK_M* = 0004DH;  (* U+004D LATIN CAPITAL LETTER M *)
	 XK_N* = 0004EH;  (* U+004E LATIN CAPITAL LETTER N *)
	 XK_O* = 0004FH;  (* U+004F LATIN CAPITAL LETTER O *)
	 XK_P* = 00050H;  (* U+0050 LATIN CAPITAL LETTER P *)
	 XK_Q* = 00051H;  (* U+0051 LATIN CAPITAL LETTER Q *)
	 XK_R* = 00052H;  (* U+0052 LATIN CAPITAL LETTER R *)
	 XK_S* = 00053H;  (* U+0053 LATIN CAPITAL LETTER S *)
	 XK_T* = 00054H;  (* U+0054 LATIN CAPITAL LETTER T *)
	 XK_U* = 00055H;  (* U+0055 LATIN CAPITAL LETTER U *)
	 XK_V* = 00056H;  (* U+0056 LATIN CAPITAL LETTER V *)
	 XK_W* = 00057H;  (* U+0057 LATIN CAPITAL LETTER W *)
	 XK_X* = 00058H;  (* U+0058 LATIN CAPITAL LETTER X *)
	 XK_Y* = 00059H;  (* U+0059 LATIN CAPITAL LETTER Y *)
	 XK_Z* = 0005AH;  (* U+005A LATIN CAPITAL LETTER Z *)
	 XK_bracketleft* = 0005BH;  (* U+005B LEFT SQUARE BRACKET *)
	 XK_backslash* = 0005CH;  (* U+005C REVERSE SOLIDUS *)
	 XK_bracketright* = 0005DH;  (* U+005D RIGHT SQUARE BRACKET *)
	 XK_asciicircum* = 0005EH;  (* U+005E CIRCUMFLEX ACCENT *)
	 XK_underscore* = 0005FH;  (* U+005F LOW LINE *)
	 XK_grave* = 00060H;  (* U+0060 GRAVE ACCENT *)
	 XK_quoteleft* = 00060H;  (* deprecated *)
	 XK_a1* = 00061H;  (* U+0061 LATIN SMALL LETTER A *)
	 XK_b1* = 00062H;  (* U+0062 LATIN SMALL LETTER B *)
	 XK_c1* = 00063H;  (* U+0063 LATIN SMALL LETTER C *)
	 XK_d1* = 00064H;  (* U+0064 LATIN SMALL LETTER D *)
	 XK_e1* = 00065H;  (* U+0065 LATIN SMALL LETTER E *)
	 XK_f1* = 00066H;  (* U+0066 LATIN SMALL LETTER F *)
	 XK_g1* = 00067H;  (* U+0067 LATIN SMALL LETTER G *)
	 XK_h1* = 00068H;  (* U+0068 LATIN SMALL LETTER H *)
	 XK_i1* = 00069H;  (* U+0069 LATIN SMALL LETTER I *)
	 XK_j1* = 0006AH;  (* U+006A LATIN SMALL LETTER J *)
	 XK_k1* = 0006BH;  (* U+006B LATIN SMALL LETTER K *)
	 XK_l1* = 0006CH;  (* U+006C LATIN SMALL LETTER L *)
	 XK_m1* = 0006DH;  (* U+006D LATIN SMALL LETTER M *)
	 XK_n1* = 0006EH;  (* U+006E LATIN SMALL LETTER N *)
	 XK_o1* = 0006FH;  (* U+006F LATIN SMALL LETTER O *)
	 XK_p1* = 00070H;  (* U+0070 LATIN SMALL LETTER P *)
	 XK_q1* = 00071H;  (* U+0071 LATIN SMALL LETTER Q *)
	 XK_r1* = 00072H;  (* U+0072 LATIN SMALL LETTER R *)
	 XK_s1* = 00073H;  (* U+0073 LATIN SMALL LETTER S *)
	 XK_t1* = 00074H;  (* U+0074 LATIN SMALL LETTER T *)
	 XK_u1* = 00075H;  (* U+0075 LATIN SMALL LETTER U *)
	 XK_v1* = 00076H;  (* U+0076 LATIN SMALL LETTER V *)
	 XK_w1* = 00077H;  (* U+0077 LATIN SMALL LETTER W *)
	 XK_x1* = 00078H;  (* U+0078 LATIN SMALL LETTER X *)
	 XK_y1* = 00079H;  (* U+0079 LATIN SMALL LETTER Y *)
	 XK_z1* = 0007AH;  (* U+007A LATIN SMALL LETTER Z *)
	 XK_braceleft* = 0007BH;  (* U+007B LEFT CURLY BRACKET *)
	 XK_bar* = 0007CH;  (* U+007C VERTICAL LINE *)
	 XK_braceright* = 0007DH;  (* U+007D RIGHT CURLY BRACKET *)
	 XK_asciitilde* = 0007EH;  (* U+007E TILDE *)

	 XK_nobreakspace* = 000A0H;  (* U+00A0 NO-BREAK SPACE *)
	 XK_exclamdown* = 000A1H;  (* U+00A1 INVERTED EXCLAMATION MARK *)
	 XK_cent* = 000A2H;  (* U+00A2 CENT SIGN *)
	 XK_sterling* = 000A3H;  (* U+00A3 POUND SIGN *)
	 XK_currency* = 000A4H;  (* U+00A4 CURRENCY SIGN *)
	 XK_yen* = 000A5H;  (* U+00A5 YEN SIGN *)
	 XK_brokenbar* = 000A6H;  (* U+00A6 BROKEN BAR *)
	 XK_section* = 000A7H;  (* U+00A7 SECTION SIGN *)
	 XK_diaeresis* = 000A8H;  (* U+00A8 DIAERESIS *)
	 XK_copyright* = 000A9H;  (* U+00A9 COPYRIGHT SIGN *)
	 XK_ordfeminine* = 000AAH;  (* U+00AA FEMININE ORDINAL INDICATOR *)
	 XK_guillemotleft* = 000ABH;  (* U+00AB LEFT-POINTING DOUBLE ANGLE QUOTATION MARK *)
	 XK_notsign* = 000ACH;  (* U+00AC NOT SIGN *)
	 XK_hyphen* = 000ADH;  (* U+00AD SOFT HYPHEN *)
	 XK_registered* = 000AEH;  (* U+00AE REGISTERED SIGN *)
	 XK_macron* = 000AFH;  (* U+00AF MACRON *)
	 XK_degree* = 000B0H;  (* U+00B0 DEGREE SIGN *)
	 XK_plusminus* = 000B1H;  (* U+00B1 PLUS-MINUS SIGN *)
	 XK_twosuperior* = 000B2H;  (* U+00B2 SUPERSCRIPT TWO *)
	 XK_threesuperior* = 000B3H;  (* U+00B3 SUPERSCRIPT THREE *)
	 XK_acute* = 000B4H;  (* U+00B4 ACUTE ACCENT *)
	 XK_mu* = 000B5H;  (* U+00B5 MICRO SIGN *)
	 XK_paragraph* = 000B6H;  (* U+00B6 PILCROW SIGN *)
	 XK_periodcentered* = 000B7H;  (* U+00B7 MIDDLE DOT *)
	 XK_cedilla* = 000B8H;  (* U+00B8 CEDILLA *)
	 XK_onesuperior* = 000B9H;  (* U+00B9 SUPERSCRIPT ONE *)
	 XK_masculine* = 000BAH;  (* U+00BA MASCULINE ORDINAL INDICATOR *)
	 XK_guillemotright* = 000BBH;  (* U+00BB RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK *)
	 XK_onequarter* = 000BCH;  (* U+00BC VULGAR FRACTION ONE QUARTER *)
	 XK_onehalf* = 000BDH;  (* U+00BD VULGAR FRACTION ONE HALF *)
	 XK_threequarters* = 000BEH;  (* U+00BE VULGAR FRACTION THREE QUARTERS *)
	 XK_questiondown* = 000BFH;  (* U+00BF INVERTED QUESTION MARK *)
	 XK_Agrave* = 000C0H;  (* U+00C0 LATIN CAPITAL LETTER A WITH GRAVE *)
	 XK_Aacute* = 000C1H;  (* U+00C1 LATIN CAPITAL LETTER A WITH ACUTE *)
	 XK_Acircumflex* = 000C2H;  (* U+00C2 LATIN CAPITAL LETTER A WITH CIRCUMFLEX *)
	 XK_Atilde* = 000C3H;  (* U+00C3 LATIN CAPITAL LETTER A WITH TILDE *)
	 XK_Adiaeresis* = 000C4H;  (* U+00C4 LATIN CAPITAL LETTER A WITH DIAERESIS *)
	 XK_Aring* = 000C5H;  (* U+00C5 LATIN CAPITAL LETTER A WITH RING ABOVE *)
	 XK_AE* = 000C6H;  (* U+00C6 LATIN CAPITAL LETTER AE *)
	 XK_Ccedilla* = 000C7H;  (* U+00C7 LATIN CAPITAL LETTER C WITH CEDILLA *)
	 XK_Egrave* = 000C8H;  (* U+00C8 LATIN CAPITAL LETTER E WITH GRAVE *)
	 XK_Eacute* = 000C9H;  (* U+00C9 LATIN CAPITAL LETTER E WITH ACUTE *)
	 XK_Ecircumflex* = 000CAH;  (* U+00CA LATIN CAPITAL LETTER E WITH CIRCUMFLEX *)
	 XK_Ediaeresis* = 000CBH;  (* U+00CB LATIN CAPITAL LETTER E WITH DIAERESIS *)
	 XK_Igrave* = 000CCH;  (* U+00CC LATIN CAPITAL LETTER I WITH GRAVE *)
	 XK_Iacute* = 000CDH;  (* U+00CD LATIN CAPITAL LETTER I WITH ACUTE *)
	 XK_Icircumflex* = 000CEH;  (* U+00CE LATIN CAPITAL LETTER I WITH CIRCUMFLEX *)
	 XK_Idiaeresis* = 000CFH;  (* U+00CF LATIN CAPITAL LETTER I WITH DIAERESIS *)
	 XK_ETH* = 000D0H;  (* U+00D0 LATIN CAPITAL LETTER ETH *)
	 XK_Eth1* = 000D0H;  (* deprecated *)
	 XK_Ntilde* = 000D1H;  (* U+00D1 LATIN CAPITAL LETTER N WITH TILDE *)
	 XK_Ograve* = 000D2H;  (* U+00D2 LATIN CAPITAL LETTER O WITH GRAVE *)
	 XK_Oacute* = 000D3H;  (* U+00D3 LATIN CAPITAL LETTER O WITH ACUTE *)
	 XK_Ocircumflex* = 000D4H;  (* U+00D4 LATIN CAPITAL LETTER O WITH CIRCUMFLEX *)
	 XK_Otilde* = 000D5H;  (* U+00D5 LATIN CAPITAL LETTER O WITH TILDE *)
	 XK_Odiaeresis* = 000D6H;  (* U+00D6 LATIN CAPITAL LETTER O WITH DIAERESIS *)
	 XK_multiply* = 000D7H;  (* U+00D7 MULTIPLICATION SIGN *)
	 XK_Oslash* = 000D8H;  (* U+00D8 LATIN CAPITAL LETTER O WITH STROKE *)
	 XK_Ooblique* = 000D8H;  (* U+00D8 LATIN CAPITAL LETTER O WITH STROKE *)
	 XK_Ugrave* = 000D9H;  (* U+00D9 LATIN CAPITAL LETTER U WITH GRAVE *)
	 XK_Uacute* = 000DAH;  (* U+00DA LATIN CAPITAL LETTER U WITH ACUTE *)
	 XK_Ucircumflex* = 000DBH;  (* U+00DB LATIN CAPITAL LETTER U WITH CIRCUMFLEX *)
	 XK_Udiaeresis* = 000DCH;  (* U+00DC LATIN CAPITAL LETTER U WITH DIAERESIS *)
	 XK_Yacute* = 000DDH;  (* U+00DD LATIN CAPITAL LETTER Y WITH ACUTE *)
	 XK_THORN* = 000DEH;  (* U+00DE LATIN CAPITAL LETTER THORN *)
	 XK_Thorn1* = 000DEH;  (* deprecated *)
	 XK_ssharp* = 000DFH;  (* U+00DF LATIN SMALL LETTER SHARP S *)
	 XK_agrave1* = 000E0H;  (* U+00E0 LATIN SMALL LETTER A WITH GRAVE *)
	 XK_aacute1* = 000E1H;  (* U+00E1 LATIN SMALL LETTER A WITH ACUTE *)
	 XK_acircumflex1* = 000E2H;  (* U+00E2 LATIN SMALL LETTER A WITH CIRCUMFLEX *)
	 XK_atilde1* = 000E3H;  (* U+00E3 LATIN SMALL LETTER A WITH TILDE *)
	 XK_adiaeresis1* = 000E4H;  (* U+00E4 LATIN SMALL LETTER A WITH DIAERESIS *)
	 XK_aring1* = 000E5H;  (* U+00E5 LATIN SMALL LETTER A WITH RING ABOVE *)
	 XK_ae1* = 000E6H;  (* U+00E6 LATIN SMALL LETTER AE *)
	 XK_ccedilla1* = 000E7H;  (* U+00E7 LATIN SMALL LETTER C WITH CEDILLA *)
	 XK_egrave1* = 000E8H;  (* U+00E8 LATIN SMALL LETTER E WITH GRAVE *)
	 XK_eacute1* = 000E9H;  (* U+00E9 LATIN SMALL LETTER E WITH ACUTE *)
	 XK_ecircumflex1* = 000EAH;  (* U+00EA LATIN SMALL LETTER E WITH CIRCUMFLEX *)
	 XK_ediaeresis1* = 000EBH;  (* U+00EB LATIN SMALL LETTER E WITH DIAERESIS *)
	 XK_igrave1* = 000ECH;  (* U+00EC LATIN SMALL LETTER I WITH GRAVE *)
	 XK_iacute1* = 000EDH;  (* U+00ED LATIN SMALL LETTER I WITH ACUTE *)
	 XK_icircumflex1* = 000EEH;  (* U+00EE LATIN SMALL LETTER I WITH CIRCUMFLEX *)
	 XK_idiaeresis1* = 000EFH;  (* U+00EF LATIN SMALL LETTER I WITH DIAERESIS *)
	 XK_eth2* = 000F0H;  (* U+00F0 LATIN SMALL LETTER ETH *)
	 XK_ntilde1* = 000F1H;  (* U+00F1 LATIN SMALL LETTER N WITH TILDE *)
	 XK_ograve1* = 000F2H;  (* U+00F2 LATIN SMALL LETTER O WITH GRAVE *)
	 XK_oacute1* = 000F3H;  (* U+00F3 LATIN SMALL LETTER O WITH ACUTE *)
	 XK_ocircumflex1* = 000F4H;  (* U+00F4 LATIN SMALL LETTER O WITH CIRCUMFLEX *)
	 XK_otilde1* = 000F5H;  (* U+00F5 LATIN SMALL LETTER O WITH TILDE *)
	 XK_odiaeresis1* = 000F6H;  (* U+00F6 LATIN SMALL LETTER O WITH DIAERESIS *)
	 XK_division* = 000F7H;  (* U+00F7 DIVISION SIGN *)
	 XK_oslash1* = 000F8H;  (* U+00F8 LATIN SMALL LETTER O WITH STROKE *)
	 XK_ooblique1* = 000F8H;  (* U+00F8 LATIN SMALL LETTER O WITH STROKE *)
	 XK_ugrave1* = 000F9H;  (* U+00F9 LATIN SMALL LETTER U WITH GRAVE *)
	 XK_uacute1* = 000FAH;  (* U+00FA LATIN SMALL LETTER U WITH ACUTE *)
	 XK_ucircumflex1* = 000FBH;  (* U+00FB LATIN SMALL LETTER U WITH CIRCUMFLEX *)
	 XK_udiaeresis1* = 000FCH;  (* U+00FC LATIN SMALL LETTER U WITH DIAERESIS *)
	 XK_yacute1* = 000FDH;  (* U+00FD LATIN SMALL LETTER Y WITH ACUTE *)
	 XK_thorn2* = 000FEH;  (* U+00FE LATIN SMALL LETTER THORN *)
	 XK_ydiaeresis1* = 000FFH;  (* U+00FF LATIN SMALL LETTER Y WITH DIAERESIS *)
	(* #endif *) (* XK_LATIN1 *)

	(*
	 * Latin 2
	 * Byte 3* = 1
	 *)

	(* #ifdef XK_LATIN2 *)
	 XK_Aogonek* = 001A1H;  (* U+0104 LATIN CAPITAL LETTER A WITH OGONEK *)
	 XK_breve* = 001A2H;  (* U+02D8 BREVE *)
	 XK_Lstroke* = 001A3H;  (* U+0141 LATIN CAPITAL LETTER L WITH STROKE *)
	 XK_Lcaron* = 001A5H;  (* U+013D LATIN CAPITAL LETTER L WITH CARON *)
	 XK_Sacute* = 001A6H;  (* U+015A LATIN CAPITAL LETTER S WITH ACUTE *)
	 XK_Scaron* = 001A9H;  (* U+0160 LATIN CAPITAL LETTER S WITH CARON *)
	 XK_Scedilla* = 001AAH;  (* U+015E LATIN CAPITAL LETTER S WITH CEDILLA *)
	 XK_Tcaron* = 001ABH;  (* U+0164 LATIN CAPITAL LETTER T WITH CARON *)
	 XK_Zacute* = 001ACH;  (* U+0179 LATIN CAPITAL LETTER Z WITH ACUTE *)
	 XK_Zcaron* = 001AEH;  (* U+017D LATIN CAPITAL LETTER Z WITH CARON *)
	 XK_Zabovedot* = 001AFH;  (* U+017B LATIN CAPITAL LETTER Z WITH DOT ABOVE *)
	 XK_aogonek1* = 001B1H;  (* U+0105 LATIN SMALL LETTER A WITH OGONEK *)
	 XK_ogonek* = 001B2H;  (* U+02DB OGONEK *)
	 XK_lstroke1* = 001B3H;  (* U+0142 LATIN SMALL LETTER L WITH STROKE *)
	 XK_lcaron1* = 001B5H;  (* U+013E LATIN SMALL LETTER L WITH CARON *)
	 XK_sacute1* = 001B6H;  (* U+015B LATIN SMALL LETTER S WITH ACUTE *)
	 XK_caron* = 001B7H;  (* U+02C7 CARON *)
	 XK_scaron1* = 001B9H;  (* U+0161 LATIN SMALL LETTER S WITH CARON *)
	 XK_scedilla1* = 001BAH;  (* U+015F LATIN SMALL LETTER S WITH CEDILLA *)
	 XK_tcaron1* = 001BBH;  (* U+0165 LATIN SMALL LETTER T WITH CARON *)
	 XK_zacute1* = 001BCH;  (* U+017A LATIN SMALL LETTER Z WITH ACUTE *)
	 XK_doubleacute* = 001BDH;  (* U+02DD DOUBLE ACUTE ACCENT *)
	 XK_zcaron1* = 001BEH;  (* U+017E LATIN SMALL LETTER Z WITH CARON *)
	 XK_zabovedot1* = 001BFH;  (* U+017C LATIN SMALL LETTER Z WITH DOT ABOVE *)
	 XK_Racute* = 001C0H;  (* U+0154 LATIN CAPITAL LETTER R WITH ACUTE *)
	 XK_Abreve* = 001C3H;  (* U+0102 LATIN CAPITAL LETTER A WITH BREVE *)
	 XK_Lacute* = 001C5H;  (* U+0139 LATIN CAPITAL LETTER L WITH ACUTE *)
	 XK_Cacute* = 001C6H;  (* U+0106 LATIN CAPITAL LETTER C WITH ACUTE *)
	 XK_Ccaron* = 001C8H;  (* U+010C LATIN CAPITAL LETTER C WITH CARON *)
	 XK_Eogonek* = 001CAH;  (* U+0118 LATIN CAPITAL LETTER E WITH OGONEK *)
	 XK_Ecaron* = 001CCH;  (* U+011A LATIN CAPITAL LETTER E WITH CARON *)
	 XK_Dcaron* = 001CFH;  (* U+010E LATIN CAPITAL LETTER D WITH CARON *)
	 XK_Dstroke* = 001D0H;  (* U+0110 LATIN CAPITAL LETTER D WITH STROKE *)
	 XK_Nacute* = 001D1H;  (* U+0143 LATIN CAPITAL LETTER N WITH ACUTE *)
	 XK_Ncaron* = 001D2H;  (* U+0147 LATIN CAPITAL LETTER N WITH CARON *)
	 XK_Odoubleacute* = 001D5H;  (* U+0150 LATIN CAPITAL LETTER O WITH DOUBLE ACUTE *)
	 XK_Rcaron* = 001D8H;  (* U+0158 LATIN CAPITAL LETTER R WITH CARON *)
	 XK_Uring* = 001D9H;  (* U+016E LATIN CAPITAL LETTER U WITH RING ABOVE *)
	 XK_Udoubleacute* = 001DBH;  (* U+0170 LATIN CAPITAL LETTER U WITH DOUBLE ACUTE *)
	 XK_Tcedilla* = 001DEH;  (* U+0162 LATIN CAPITAL LETTER T WITH CEDILLA *)
	 XK_racute1* = 001E0H;  (* U+0155 LATIN SMALL LETTER R WITH ACUTE *)
	 XK_abreve1* = 001E3H;  (* U+0103 LATIN SMALL LETTER A WITH BREVE *)
	 XK_lacute1* = 001E5H;  (* U+013A LATIN SMALL LETTER L WITH ACUTE *)
	 XK_cacute1* = 001E6H;  (* U+0107 LATIN SMALL LETTER C WITH ACUTE *)
	 XK_ccaron1* = 001E8H;  (* U+010D LATIN SMALL LETTER C WITH CARON *)
	 XK_eogonek1* = 001EAH;  (* U+0119 LATIN SMALL LETTER E WITH OGONEK *)
	 XK_ecaron1* = 001ECH;  (* U+011B LATIN SMALL LETTER E WITH CARON *)
	 XK_dcaron1* = 001EFH;  (* U+010F LATIN SMALL LETTER D WITH CARON *)
	 XK_dstroke1* = 001F0H;  (* U+0111 LATIN SMALL LETTER D WITH STROKE *)
	 XK_nacute1* = 001F1H;  (* U+0144 LATIN SMALL LETTER N WITH ACUTE *)
	 XK_ncaron1* = 001F2H;  (* U+0148 LATIN SMALL LETTER N WITH CARON *)
	 XK_odoubleacute1* = 001F5H;  (* U+0151 LATIN SMALL LETTER O WITH DOUBLE ACUTE *)
	 XK_udoubleacute1* = 001FBH;  (* U+0171 LATIN SMALL LETTER U WITH DOUBLE ACUTE *)
	 XK_rcaron1* = 001F8H;  (* U+0159 LATIN SMALL LETTER R WITH CARON *)
	 XK_uring1* = 001F9H;  (* U+016F LATIN SMALL LETTER U WITH RING ABOVE *)
	 XK_tcedilla1* = 001FEH;  (* U+0163 LATIN SMALL LETTER T WITH CEDILLA *)
	 XK_abovedot* = 001FFH;  (* U+02D9 DOT ABOVE *)
	(* #endif *) (* XK_LATIN2 *)

	(*
	 * Latin 3
	 * Byte 3* = 2
	 *)

	(* #ifdef XK_LATIN3 *)
	 XK_Hstroke* = 002A1H;  (* U+0126 LATIN CAPITAL LETTER H WITH STROKE *)
	 XK_Hcircumflex* = 002A6H;  (* U+0124 LATIN CAPITAL LETTER H WITH CIRCUMFLEX *)
	 XK_Iabovedot* = 002A9H;  (* U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE *)
	 XK_Gbreve* = 002ABH;  (* U+011E LATIN CAPITAL LETTER G WITH BREVE *)
	 XK_Jcircumflex* = 002ACH;  (* U+0134 LATIN CAPITAL LETTER J WITH CIRCUMFLEX *)
	 XK_hstroke1* = 002B1H;  (* U+0127 LATIN SMALL LETTER H WITH STROKE *)
	 XK_hcircumflex1* = 002B6H;  (* U+0125 LATIN SMALL LETTER H WITH CIRCUMFLEX *)
	 XK_idotless* = 002B9H;  (* U+0131 LATIN SMALL LETTER DOTLESS I *)
	 XK_gbreve1* = 002BBH;  (* U+011F LATIN SMALL LETTER G WITH BREVE *)
	 XK_jcircumflex1* = 002BCH;  (* U+0135 LATIN SMALL LETTER J WITH CIRCUMFLEX *)
	 XK_Cabovedot* = 002C5H;  (* U+010A LATIN CAPITAL LETTER C WITH DOT ABOVE *)
	 XK_Ccircumflex* = 002C6H;  (* U+0108 LATIN CAPITAL LETTER C WITH CIRCUMFLEX *)
	 XK_Gabovedot* = 002D5H;  (* U+0120 LATIN CAPITAL LETTER G WITH DOT ABOVE *)
	 XK_Gcircumflex* = 002D8H;  (* U+011C LATIN CAPITAL LETTER G WITH CIRCUMFLEX *)
	 XK_Ubreve* = 002DDH;  (* U+016C LATIN CAPITAL LETTER U WITH BREVE *)
	 XK_Scircumflex* = 002DEH;  (* U+015C LATIN CAPITAL LETTER S WITH CIRCUMFLEX *)
	 XK_cabovedot1* = 002E5H;  (* U+010B LATIN SMALL LETTER C WITH DOT ABOVE *)
	 XK_ccircumflex1* = 002E6H;  (* U+0109 LATIN SMALL LETTER C WITH CIRCUMFLEX *)
	 XK_gabovedot1* = 002F5H;  (* U+0121 LATIN SMALL LETTER G WITH DOT ABOVE *)
	 XK_gcircumflex1* = 002F8H;  (* U+011D LATIN SMALL LETTER G WITH CIRCUMFLEX *)
	 XK_ubreve1* = 002FDH;  (* U+016D LATIN SMALL LETTER U WITH BREVE *)
	 XK_scircumflex1* = 002FEH;  (* U+015D LATIN SMALL LETTER S WITH CIRCUMFLEX *)
	(* #endif *) (* XK_LATIN3 *)


	(*
	 * Latin 4
	 * Byte 3* = 3
	 *)

	(* #ifdef XK_LATIN4 *)
	 XK_kra* = 003A2H;  (* U+0138 LATIN SMALL LETTER KRA *)
	 XK_kappa* = 003A2H;  (* deprecated *)
	 XK_Rcedilla* = 003A3H;  (* U+0156 LATIN CAPITAL LETTER R WITH CEDILLA *)
	 XK_Itilde* = 003A5H;  (* U+0128 LATIN CAPITAL LETTER I WITH TILDE *)
	 XK_Lcedilla* = 003A6H;  (* U+013B LATIN CAPITAL LETTER L WITH CEDILLA *)
	 XK_Emacron* = 003AAH;  (* U+0112 LATIN CAPITAL LETTER E WITH MACRON *)
	 XK_Gcedilla* = 003ABH;  (* U+0122 LATIN CAPITAL LETTER G WITH CEDILLA *)
	 XK_Tslash* = 003ACH;  (* U+0166 LATIN CAPITAL LETTER T WITH STROKE *)
	 XK_rcedilla1* = 003B3H;  (* U+0157 LATIN SMALL LETTER R WITH CEDILLA *)
	 XK_itilde1* = 003B5H;  (* U+0129 LATIN SMALL LETTER I WITH TILDE *)
	 XK_lcedilla1* = 003B6H;  (* U+013C LATIN SMALL LETTER L WITH CEDILLA *)
	 XK_emacron1* = 003BAH;  (* U+0113 LATIN SMALL LETTER E WITH MACRON *)
	 XK_gcedilla1* = 003BBH;  (* U+0123 LATIN SMALL LETTER G WITH CEDILLA *)
	 XK_tslash1* = 003BCH;  (* U+0167 LATIN SMALL LETTER T WITH STROKE *)
	 XK_ENG* = 003BDH;  (* U+014A LATIN CAPITAL LETTER ENG *)
	 XK_eng1* = 003BFH;  (* U+014B LATIN SMALL LETTER ENG *)
	 XK_Amacron* = 003C0H;  (* U+0100 LATIN CAPITAL LETTER A WITH MACRON *)
	 XK_Iogonek* = 003C7H;  (* U+012E LATIN CAPITAL LETTER I WITH OGONEK *)
	 XK_Eabovedot* = 003CCH;  (* U+0116 LATIN CAPITAL LETTER E WITH DOT ABOVE *)
	 XK_Imacron* = 003CFH;  (* U+012A LATIN CAPITAL LETTER I WITH MACRON *)
	 XK_Ncedilla* = 003D1H;  (* U+0145 LATIN CAPITAL LETTER N WITH CEDILLA *)
	 XK_Omacron* = 003D2H;  (* U+014C LATIN CAPITAL LETTER O WITH MACRON *)
	 XK_Kcedilla* = 003D3H;  (* U+0136 LATIN CAPITAL LETTER K WITH CEDILLA *)
	 XK_Uogonek* = 003D9H;  (* U+0172 LATIN CAPITAL LETTER U WITH OGONEK *)
	 XK_Utilde* = 003DDH;  (* U+0168 LATIN CAPITAL LETTER U WITH TILDE *)
	 XK_Umacron* = 003DEH;  (* U+016A LATIN CAPITAL LETTER U WITH MACRON *)
	 XK_amacron1* = 003E0H;  (* U+0101 LATIN SMALL LETTER A WITH MACRON *)
	 XK_iogonek1* = 003E7H;  (* U+012F LATIN SMALL LETTER I WITH OGONEK *)
	 XK_eabovedot1* = 003ECH;  (* U+0117 LATIN SMALL LETTER E WITH DOT ABOVE *)
	 XK_imacron1* = 003EFH;  (* U+012B LATIN SMALL LETTER I WITH MACRON *)
	 XK_ncedilla1* = 003F1H;  (* U+0146 LATIN SMALL LETTER N WITH CEDILLA *)
	 XK_omacron1* = 003F2H;  (* U+014D LATIN SMALL LETTER O WITH MACRON *)
	 XK_kcedilla1* = 003F3H;  (* U+0137 LATIN SMALL LETTER K WITH CEDILLA *)
	 XK_uogonek1* = 003F9H;  (* U+0173 LATIN SMALL LETTER U WITH OGONEK *)
	 XK_utilde1* = 003FDH;  (* U+0169 LATIN SMALL LETTER U WITH TILDE *)
	 XK_umacron1* = 003FEH;  (* U+016B LATIN SMALL LETTER U WITH MACRON *)
	(* #endif *) (* XK_LATIN4 *)

	(*
	 * Latin 8
	 *)
	(* #ifdef XK_LATIN8 *)
	 XK_Babovedot* = 01001E02H;  (* U+1E02 LATIN CAPITAL LETTER B WITH DOT ABOVE *)
	 XK_babovedot1* = 01001E03H;  (* U+1E03 LATIN SMALL LETTER B WITH DOT ABOVE *)
	 XK_Dabovedot* = 01001E0AH;  (* U+1E0A LATIN CAPITAL LETTER D WITH DOT ABOVE *)
	 XK_Wgrave* = 01001E80H;  (* U+1E80 LATIN CAPITAL LETTER W WITH GRAVE *)
	 XK_Wacute* = 01001E82H;  (* U+1E82 LATIN CAPITAL LETTER W WITH ACUTE *)
	 XK_dabovedot1* = 01001E0BH;  (* U+1E0B LATIN SMALL LETTER D WITH DOT ABOVE *)
	 XK_Ygrave* = 01001EF2H;  (* U+1EF2 LATIN CAPITAL LETTER Y WITH GRAVE *)
	 XK_Fabovedot* = 01001E1EH;  (* U+1E1E LATIN CAPITAL LETTER F WITH DOT ABOVE *)
	 XK_fabovedot1* = 01001E1FH;  (* U+1E1F LATIN SMALL LETTER F WITH DOT ABOVE *)
	 XK_Mabovedot* = 01001E40H;  (* U+1E40 LATIN CAPITAL LETTER M WITH DOT ABOVE *)
	 XK_mabovedot1* = 01001E41H;  (* U+1E41 LATIN SMALL LETTER M WITH DOT ABOVE *)
	 XK_Pabovedot* = 01001E56H;  (* U+1E56 LATIN CAPITAL LETTER P WITH DOT ABOVE *)
	 XK_wgrave1* = 01001E81H;  (* U+1E81 LATIN SMALL LETTER W WITH GRAVE *)
	 XK_pabovedot1* = 01001E57H;  (* U+1E57 LATIN SMALL LETTER P WITH DOT ABOVE *)
	 XK_wacute1* = 01001E83H;  (* U+1E83 LATIN SMALL LETTER W WITH ACUTE *)
	 XK_Sabovedot* = 01001E60H;  (* U+1E60 LATIN CAPITAL LETTER S WITH DOT ABOVE *)
	 XK_ygrave1* = 01001EF3H;  (* U+1EF3 LATIN SMALL LETTER Y WITH GRAVE *)
	 XK_Wdiaeresis* = 01001E84H;  (* U+1E84 LATIN CAPITAL LETTER W WITH DIAERESIS *)
	 XK_wdiaeresis1* = 01001E85H;  (* U+1E85 LATIN SMALL LETTER W WITH DIAERESIS *)
	 XK_sabovedot1* = 01001E61H;  (* U+1E61 LATIN SMALL LETTER S WITH DOT ABOVE *)
	 XK_Wcircumflex* = 01000174H;  (* U+0174 LATIN CAPITAL LETTER W WITH CIRCUMFLEX *)
	 XK_Tabovedot* = 01001E6AH;  (* U+1E6A LATIN CAPITAL LETTER T WITH DOT ABOVE *)
	 XK_Ycircumflex* = 01000176H;  (* U+0176 LATIN CAPITAL LETTER Y WITH CIRCUMFLEX *)
	 XK_wcircumflex1* = 01000175H;  (* U+0175 LATIN SMALL LETTER W WITH CIRCUMFLEX *)
	 XK_tabovedot1* = 01001E6BH;  (* U+1E6B LATIN SMALL LETTER T WITH DOT ABOVE *)
	 XK_ycircumflex1* = 01000177H;  (* U+0177 LATIN SMALL LETTER Y WITH CIRCUMFLEX *)
	(* #endif *) (* XK_LATIN8 *)

	(*
	 * Latin 9
	 * Byte 3* = 0x13
	 *)

	(* #ifdef XK_LATIN9 *)
	 XK_OE* = 013BCH;  (* U+0152 LATIN CAPITAL LIGATURE OE *)
	 XK_oe1* = 013BDH;  (* U+0153 LATIN SMALL LIGATURE OE *)
	 XK_Ydiaeresis* = 013BEH;  (* U+0178 LATIN CAPITAL LETTER Y WITH DIAERESIS *)
	(* #endif *) (* XK_LATIN9 *)

	(*
	 * Katakana
	 * Byte 3* = 4
	 *)

	(* #ifdef XK_KATAKANA *)
	 XK_overline* = 0047EH;  (* U+203E OVERLINE *)
	 XK_kana_fullstop* = 004A1H;  (* U+3002 IDEOGRAPHIC FULL STOP *)
	 XK_kana_openingbracket* = 004A2H;  (* U+300C LEFT CORNER BRACKET *)
	 XK_kana_closingbracket* = 004A3H;  (* U+300D RIGHT CORNER BRACKET *)
	 XK_kana_comma* = 004A4H;  (* U+3001 IDEOGRAPHIC COMMA *)
	 XK_kana_conjunctive* = 004A5H;  (* U+30FB KATAKANA MIDDLE DOT *)
	 XK_kana_middledot* = 004A5H;  (* deprecated *)
	 XK_kana_WO* = 004A6H;  (* U+30F2 KATAKANA LETTER WO *)
	 XK_kana_a1* = 004A7H;  (* U+30A1 KATAKANA LETTER SMALL A *)
	 XK_kana_i1* = 004A8H;  (* U+30A3 KATAKANA LETTER SMALL I *)
	 XK_kana_u1* = 004A9H;  (* U+30A5 KATAKANA LETTER SMALL U *)
	 XK_kana_e1* = 004AAH;  (* U+30A7 KATAKANA LETTER SMALL E *)
	 XK_kana_o1* = 004ABH;  (* U+30A9 KATAKANA LETTER SMALL O *)
	 XK_kana_ya1* = 004ACH;  (* U+30E3 KATAKANA LETTER SMALL YA *)
	 XK_kana_yu1* = 004ADH;  (* U+30E5 KATAKANA LETTER SMALL YU *)
	 XK_kana_yo1* = 004AEH;  (* U+30E7 KATAKANA LETTER SMALL YO *)
	 XK_kana_tsu1* = 004AFH;  (* U+30C3 KATAKANA LETTER SMALL TU *)
	 XK_kana_tu1* = 004AFH;  (* deprecated *)
	 XK_prolongedsound* = 004B0H;  (* U+30FC KATAKANA-HIRAGANA PROLONGED SOUND MARK *)
	 XK_kana_A* = 004B1H;  (* U+30A2 KATAKANA LETTER A *)
	 XK_kana_I* = 004B2H;  (* U+30A4 KATAKANA LETTER I *)
	 XK_kana_U* = 004B3H;  (* U+30A6 KATAKANA LETTER U *)
	 XK_kana_E* = 004B4H;  (* U+30A8 KATAKANA LETTER E *)
	 XK_kana_O* = 004B5H;  (* U+30AA KATAKANA LETTER O *)
	 XK_kana_KA* = 004B6H;  (* U+30AB KATAKANA LETTER KA *)
	 XK_kana_KI* = 004B7H;  (* U+30AD KATAKANA LETTER KI *)
	 XK_kana_KU* = 004B8H;  (* U+30AF KATAKANA LETTER KU *)
	 XK_kana_KE* = 004B9H;  (* U+30B1 KATAKANA LETTER KE *)
	 XK_kana_KO* = 004BAH;  (* U+30B3 KATAKANA LETTER KO *)
	 XK_kana_SA* = 004BBH;  (* U+30B5 KATAKANA LETTER SA *)
	 XK_kana_SHI* = 004BCH;  (* U+30B7 KATAKANA LETTER SI *)
	 XK_kana_SU* = 004BDH;  (* U+30B9 KATAKANA LETTER SU *)
	 XK_kana_SE* = 004BEH;  (* U+30BB KATAKANA LETTER SE *)
	 XK_kana_SO* = 004BFH;  (* U+30BD KATAKANA LETTER SO *)
	 XK_kana_TA* = 004C0H;  (* U+30BF KATAKANA LETTER TA *)
	 XK_kana_CHI* = 004C1H;  (* U+30C1 KATAKANA LETTER TI *)
	 XK_kana_TI* = 004C1H;  (* deprecated *)
	 XK_kana_TSU* = 004C2H;  (* U+30C4 KATAKANA LETTER TU *)
	 XK_kana_TU* = 004C2H;  (* deprecated *)
	 XK_kana_TE* = 004C3H;  (* U+30C6 KATAKANA LETTER TE *)
	 XK_kana_TO* = 004C4H;  (* U+30C8 KATAKANA LETTER TO *)
	 XK_kana_NA* = 004C5H;  (* U+30CA KATAKANA LETTER NA *)
	 XK_kana_NI* = 004C6H;  (* U+30CB KATAKANA LETTER NI *)
	 XK_kana_NU* = 004C7H;  (* U+30CC KATAKANA LETTER NU *)
	 XK_kana_NE* = 004C8H;  (* U+30CD KATAKANA LETTER NE *)
	 XK_kana_NO* = 004C9H;  (* U+30CE KATAKANA LETTER NO *)
	 XK_kana_HA* = 004CAH;  (* U+30CF KATAKANA LETTER HA *)
	 XK_kana_HI* = 004CBH;  (* U+30D2 KATAKANA LETTER HI *)
	 XK_kana_FU* = 004CCH;  (* U+30D5 KATAKANA LETTER HU *)
	 XK_kana_HU* = 004CCH;  (* deprecated *)
	 XK_kana_HE* = 004CDH;  (* U+30D8 KATAKANA LETTER HE *)
	 XK_kana_HO* = 004CEH;  (* U+30DB KATAKANA LETTER HO *)
	 XK_kana_MA* = 004CFH;  (* U+30DE KATAKANA LETTER MA *)
	 XK_kana_MI* = 004D0H;  (* U+30DF KATAKANA LETTER MI *)
	 XK_kana_MU* = 004D1H;  (* U+30E0 KATAKANA LETTER MU *)
	 XK_kana_ME* = 004D2H;  (* U+30E1 KATAKANA LETTER ME *)
	 XK_kana_MO* = 004D3H;  (* U+30E2 KATAKANA LETTER MO *)
	 XK_kana_YA* = 004D4H;  (* U+30E4 KATAKANA LETTER YA *)
	 XK_kana_YU* = 004D5H;  (* U+30E6 KATAKANA LETTER YU *)
	 XK_kana_YO* = 004D6H;  (* U+30E8 KATAKANA LETTER YO *)
	 XK_kana_RA* = 004D7H;  (* U+30E9 KATAKANA LETTER RA *)
	 XK_kana_RI* = 004D8H;  (* U+30EA KATAKANA LETTER RI *)
	 XK_kana_RU* = 004D9H;  (* U+30EB KATAKANA LETTER RU *)
	 XK_kana_RE* = 004DAH;  (* U+30EC KATAKANA LETTER RE *)
	 XK_kana_RO* = 004DBH;  (* U+30ED KATAKANA LETTER RO *)
	 XK_kana_WA* = 004DCH;  (* U+30EF KATAKANA LETTER WA *)
	 XK_kana_N* = 004DDH;  (* U+30F3 KATAKANA LETTER N *)
	 XK_voicedsound* = 004DEH;  (* U+309B KATAKANA-HIRAGANA VOICED SOUND MARK *)
	 XK_semivoicedsound* = 004DFH;  (* U+309C KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK *)
	 XK_kana_switch* = 0FF7EH;  (* Alias for mode_switch *)
	(* #endif *) (* XK_KATAKANA *)

	(*
	 * Arabic
	 * Byte 3* = 5
	 *)

	(* #ifdef XK_ARABIC *)
	 XK_Farsi_0* = 010006F0H;  (* U+06F0 EXTENDED ARABIC-INDIC DIGIT ZERO *)
	 XK_Farsi_1* = 010006F1H;  (* U+06F1 EXTENDED ARABIC-INDIC DIGIT ONE *)
	 XK_Farsi_2* = 010006F2H;  (* U+06F2 EXTENDED ARABIC-INDIC DIGIT TWO *)
	 XK_Farsi_3* = 010006F3H;  (* U+06F3 EXTENDED ARABIC-INDIC DIGIT THREE *)
	 XK_Farsi_4* = 010006F4H;  (* U+06F4 EXTENDED ARABIC-INDIC DIGIT FOUR *)
	 XK_Farsi_5* = 010006F5H;  (* U+06F5 EXTENDED ARABIC-INDIC DIGIT FIVE *)
	 XK_Farsi_6* = 010006F6H;  (* U+06F6 EXTENDED ARABIC-INDIC DIGIT SIX *)
	 XK_Farsi_7* = 010006F7H;  (* U+06F7 EXTENDED ARABIC-INDIC DIGIT SEVEN *)
	 XK_Farsi_8* = 010006F8H;  (* U+06F8 EXTENDED ARABIC-INDIC DIGIT EIGHT *)
	 XK_Farsi_9* = 010006F9H;  (* U+06F9 EXTENDED ARABIC-INDIC DIGIT NINE *)
	 XK_Arabic_percent* = 0100066AH;  (* U+066A ARABIC PERCENT SIGN *)
	 XK_Arabic_superscript_alef* = 01000670H;  (* U+0670 ARABIC LETTER SUPERSCRIPT ALEF *)
	 XK_Arabic_tteh* = 01000679H;  (* U+0679 ARABIC LETTER TTEH *)
	 XK_Arabic_peh* = 0100067EH;  (* U+067E ARABIC LETTER PEH *)
	 XK_Arabic_tcheh* = 01000686H;  (* U+0686 ARABIC LETTER TCHEH *)
	 XK_Arabic_ddal* = 01000688H;  (* U+0688 ARABIC LETTER DDAL *)
	 XK_Arabic_rreh* = 01000691H;  (* U+0691 ARABIC LETTER RREH *)
	 XK_Arabic_comma* = 005ACH;  (* U+060C ARABIC COMMA *)
	 XK_Arabic_fullstop* = 010006D4H;  (* U+06D4 ARABIC FULL STOP *)
	 XK_Arabic_0* = 01000660H;  (* U+0660 ARABIC-INDIC DIGIT ZERO *)
	 XK_Arabic_1* = 01000661H;  (* U+0661 ARABIC-INDIC DIGIT ONE *)
	 XK_Arabic_2* = 01000662H;  (* U+0662 ARABIC-INDIC DIGIT TWO *)
	 XK_Arabic_3* = 01000663H;  (* U+0663 ARABIC-INDIC DIGIT THREE *)
	 XK_Arabic_4* = 01000664H;  (* U+0664 ARABIC-INDIC DIGIT FOUR *)
	 XK_Arabic_5* = 01000665H;  (* U+0665 ARABIC-INDIC DIGIT FIVE *)
	 XK_Arabic_6* = 01000666H;  (* U+0666 ARABIC-INDIC DIGIT SIX *)
	 XK_Arabic_7* = 01000667H;  (* U+0667 ARABIC-INDIC DIGIT SEVEN *)
	 XK_Arabic_8* = 01000668H;  (* U+0668 ARABIC-INDIC DIGIT EIGHT *)
	 XK_Arabic_9* = 01000669H;  (* U+0669 ARABIC-INDIC DIGIT NINE *)
	 XK_Arabic_semicolon* = 005BBH;  (* U+061B ARABIC SEMICOLON *)
	 XK_Arabic_question_mark* = 005BFH;  (* U+061F ARABIC QUESTION MARK *)
	 XK_Arabic_hamza* = 005C1H;  (* U+0621 ARABIC LETTER HAMZA *)
	 XK_Arabic_maddaonalef* = 005C2H;  (* U+0622 ARABIC LETTER ALEF WITH MADDA ABOVE *)
	 XK_Arabic_hamzaonalef* = 005C3H;  (* U+0623 ARABIC LETTER ALEF WITH HAMZA ABOVE *)
	 XK_Arabic_hamzaonwaw* = 005C4H;  (* U+0624 ARABIC LETTER WAW WITH HAMZA ABOVE *)
	 XK_Arabic_hamzaunderalef* = 005C5H;  (* U+0625 ARABIC LETTER ALEF WITH HAMZA BELOW *)
	 XK_Arabic_hamzaonyeh* = 005C6H;  (* U+0626 ARABIC LETTER YEH WITH HAMZA ABOVE *)
	 XK_Arabic_alef* = 005C7H;  (* U+0627 ARABIC LETTER ALEF *)
	 XK_Arabic_beh* = 005C8H;  (* U+0628 ARABIC LETTER BEH *)
	 XK_Arabic_tehmarbuta* = 005C9H;  (* U+0629 ARABIC LETTER TEH MARBUTA *)
	 XK_Arabic_teh* = 005CAH;  (* U+062A ARABIC LETTER TEH *)
	 XK_Arabic_theh* = 005CBH;  (* U+062B ARABIC LETTER THEH *)
	 XK_Arabic_jeem* = 005CCH;  (* U+062C ARABIC LETTER JEEM *)
	 XK_Arabic_hah* = 005CDH;  (* U+062D ARABIC LETTER HAH *)
	 XK_Arabic_khah* = 005CEH;  (* U+062E ARABIC LETTER KHAH *)
	 XK_Arabic_dal* = 005CFH;  (* U+062F ARABIC LETTER DAL *)
	 XK_Arabic_thal* = 005D0H;  (* U+0630 ARABIC LETTER THAL *)
	 XK_Arabic_ra* = 005D1H;  (* U+0631 ARABIC LETTER REH *)
	 XK_Arabic_zain* = 005D2H;  (* U+0632 ARABIC LETTER ZAIN *)
	 XK_Arabic_seen* = 005D3H;  (* U+0633 ARABIC LETTER SEEN *)
	 XK_Arabic_sheen* = 005D4H;  (* U+0634 ARABIC LETTER SHEEN *)
	 XK_Arabic_sad* = 005D5H;  (* U+0635 ARABIC LETTER SAD *)
	 XK_Arabic_dad* = 005D6H;  (* U+0636 ARABIC LETTER DAD *)
	 XK_Arabic_tah* = 005D7H;  (* U+0637 ARABIC LETTER TAH *)
	 XK_Arabic_zah* = 005D8H;  (* U+0638 ARABIC LETTER ZAH *)
	 XK_Arabic_ain* = 005D9H;  (* U+0639 ARABIC LETTER AIN *)
	 XK_Arabic_ghain* = 005DAH;  (* U+063A ARABIC LETTER GHAIN *)
	 XK_Arabic_tatweel* = 005E0H;  (* U+0640 ARABIC TATWEEL *)
	 XK_Arabic_feh* = 005E1H;  (* U+0641 ARABIC LETTER FEH *)
	 XK_Arabic_qaf* = 005E2H;  (* U+0642 ARABIC LETTER QAF *)
	 XK_Arabic_kaf* = 005E3H;  (* U+0643 ARABIC LETTER KAF *)
	 XK_Arabic_lam* = 005E4H;  (* U+0644 ARABIC LETTER LAM *)
	 XK_Arabic_meem* = 005E5H;  (* U+0645 ARABIC LETTER MEEM *)
	 XK_Arabic_noon* = 005E6H;  (* U+0646 ARABIC LETTER NOON *)
	 XK_Arabic_ha* = 005E7H;  (* U+0647 ARABIC LETTER HEH *)
	 XK_Arabic_heh* = 005E7H;  (* deprecated *)
	 XK_Arabic_waw* = 005E8H;  (* U+0648 ARABIC LETTER WAW *)
	 XK_Arabic_alefmaksura* = 005E9H;  (* U+0649 ARABIC LETTER ALEF MAKSURA *)
	 XK_Arabic_yeh* = 005EAH;  (* U+064A ARABIC LETTER YEH *)
	 XK_Arabic_fathatan* = 005EBH;  (* U+064B ARABIC FATHATAN *)
	 XK_Arabic_dammatan* = 005ECH;  (* U+064C ARABIC DAMMATAN *)
	 XK_Arabic_kasratan* = 005EDH;  (* U+064D ARABIC KASRATAN *)
	 XK_Arabic_fatha* = 005EEH;  (* U+064E ARABIC FATHA *)
	 XK_Arabic_damma* = 005EFH;  (* U+064F ARABIC DAMMA *)
	 XK_Arabic_kasra* = 005F0H;  (* U+0650 ARABIC KASRA *)
	 XK_Arabic_shadda* = 005F1H;  (* U+0651 ARABIC SHADDA *)
	 XK_Arabic_sukun* = 005F2H;  (* U+0652 ARABIC SUKUN *)
	 XK_Arabic_madda_above* = 01000653H;  (* U+0653 ARABIC MADDAH ABOVE *)
	 XK_Arabic_hamza_above* = 01000654H;  (* U+0654 ARABIC HAMZA ABOVE *)
	 XK_Arabic_hamza_below* = 01000655H;  (* U+0655 ARABIC HAMZA BELOW *)
	 XK_Arabic_jeh* = 01000698H;  (* U+0698 ARABIC LETTER JEH *)
	 XK_Arabic_veh* = 010006A4H;  (* U+06A4 ARABIC LETTER VEH *)
	 XK_Arabic_keheh* = 010006A9H;  (* U+06A9 ARABIC LETTER KEHEH *)
	 XK_Arabic_gaf* = 010006AFH;  (* U+06AF ARABIC LETTER GAF *)
	 XK_Arabic_noon_ghunna* = 010006BAH;  (* U+06BA ARABIC LETTER NOON GHUNNA *)
	 XK_Arabic_heh_doachashmee* = 010006BEH;  (* U+06BE ARABIC LETTER HEH DOACHASHMEE *)
	 XK_Farsi_yeh* = 010006CCH;  (* U+06CC ARABIC LETTER FARSI YEH *)
	 XK_Arabic_farsi_yeh* = 010006CCH;  (* U+06CC ARABIC LETTER FARSI YEH *)
	 XK_Arabic_yeh_baree* = 010006D2H;  (* U+06D2 ARABIC LETTER YEH BARREE *)
	 XK_Arabic_heh_goal* = 010006C1H;  (* U+06C1 ARABIC LETTER HEH GOAL *)
	 XK_Arabic_switch* = 0FF7EH;  (* Alias for mode_switch *)
	(* #endif *) (* XK_ARABIC *)

	(*
	 * Cyrillic
	 * Byte 3* = 6
	 *)
	(* #ifdef XK_CYRILLIC *)
	 XK_Cyrillic_GHE_bar* = 01000492H;  (* U+0492 CYRILLIC CAPITAL LETTER GHE WITH STROKE *)
	 XK_Cyrillic_ghe_bar1* = 01000493H;  (* U+0493 CYRILLIC SMALL LETTER GHE WITH STROKE *)
	 XK_Cyrillic_ZHE_descender* = 01000496H;  (* U+0496 CYRILLIC CAPITAL LETTER ZHE WITH DESCENDER *)
	 XK_Cyrillic_zhe_descender1* = 01000497H;  (* U+0497 CYRILLIC SMALL LETTER ZHE WITH DESCENDER *)
	 XK_Cyrillic_KA_descender* = 0100049AH;  (* U+049A CYRILLIC CAPITAL LETTER KA WITH DESCENDER *)
	 XK_Cyrillic_ka_descender1* = 0100049BH;  (* U+049B CYRILLIC SMALL LETTER KA WITH DESCENDER *)
	 XK_Cyrillic_KA_vertstroke* = 0100049CH;  (* U+049C CYRILLIC CAPITAL LETTER KA WITH VERTICAL STROKE *)
	 XK_Cyrillic_ka_vertstroke1* = 0100049DH;  (* U+049D CYRILLIC SMALL LETTER KA WITH VERTICAL STROKE *)
	 XK_Cyrillic_EN_descender* = 010004A2H;  (* U+04A2 CYRILLIC CAPITAL LETTER EN WITH DESCENDER *)
	 XK_Cyrillic_en_descender1* = 010004A3H;  (* U+04A3 CYRILLIC SMALL LETTER EN WITH DESCENDER *)
	 XK_Cyrillic_U_straight* = 010004AEH;  (* U+04AE CYRILLIC CAPITAL LETTER STRAIGHT U *)
	 XK_Cyrillic_u_straight1* = 010004AFH;  (* U+04AF CYRILLIC SMALL LETTER STRAIGHT U *)
	 XK_Cyrillic_U_straight_bar* = 010004B0H;  (* U+04B0 CYRILLIC CAPITAL LETTER STRAIGHT U WITH STROKE *)
	 XK_Cyrillic_u_straight_bar1* = 010004B1H;  (* U+04B1 CYRILLIC SMALL LETTER STRAIGHT U WITH STROKE *)
	 XK_Cyrillic_HA_descender* = 010004B2H;  (* U+04B2 CYRILLIC CAPITAL LETTER HA WITH DESCENDER *)
	 XK_Cyrillic_ha_descender1* = 010004B3H;  (* U+04B3 CYRILLIC SMALL LETTER HA WITH DESCENDER *)
	 XK_Cyrillic_CHE_descender* = 010004B6H;  (* U+04B6 CYRILLIC CAPITAL LETTER CHE WITH DESCENDER *)
	 XK_Cyrillic_che_descender1* = 010004B7H;  (* U+04B7 CYRILLIC SMALL LETTER CHE WITH DESCENDER *)
	 XK_Cyrillic_CHE_vertstroke* = 010004B8H;  (* U+04B8 CYRILLIC CAPITAL LETTER CHE WITH VERTICAL STROKE *)
	 XK_Cyrillic_che_vertstroke1* = 010004B9H;  (* U+04B9 CYRILLIC SMALL LETTER CHE WITH VERTICAL STROKE *)
	 XK_Cyrillic_SHHA* = 010004BAH;  (* U+04BA CYRILLIC CAPITAL LETTER SHHA *)
	 XK_Cyrillic_shha1* = 010004BBH;  (* U+04BB CYRILLIC SMALL LETTER SHHA *)

	 XK_Cyrillic_SCHWA* = 010004D8H;  (* U+04D8 CYRILLIC CAPITAL LETTER SCHWA *)
	 XK_Cyrillic_schwa1* = 010004D9H;  (* U+04D9 CYRILLIC SMALL LETTER SCHWA *)
	 XK_Cyrillic_I_macron* = 010004E2H;  (* U+04E2 CYRILLIC CAPITAL LETTER I WITH MACRON *)
	 XK_Cyrillic_i_macron1* = 010004E3H;  (* U+04E3 CYRILLIC SMALL LETTER I WITH MACRON *)
	 XK_Cyrillic_O_bar* = 010004E8H;  (* U+04E8 CYRILLIC CAPITAL LETTER BARRED O *)
	 XK_Cyrillic_o_bar1* = 010004E9H;  (* U+04E9 CYRILLIC SMALL LETTER BARRED O *)
	 XK_Cyrillic_U_macron* = 010004EEH;  (* U+04EE CYRILLIC CAPITAL LETTER U WITH MACRON *)
	 XK_Cyrillic_u_macron1* = 010004EFH;  (* U+04EF CYRILLIC SMALL LETTER U WITH MACRON *)

	 XK_Serbian_dje1* = 006A1H;  (* U+0452 CYRILLIC SMALL LETTER DJE *)
	 XK_Macedonia_gje1* = 006A2H;  (* U+0453 CYRILLIC SMALL LETTER GJE *)
	 XK_Cyrillic_io1* = 006A3H;  (* U+0451 CYRILLIC SMALL LETTER IO *)
	 XK_Ukrainian_ie1* = 006A4H;  (* U+0454 CYRILLIC SMALL LETTER UKRAINIAN IE *)
	 XK_Ukranian_je1* = 006A4H;  (* deprecated *)
	 XK_Macedonia_dse1* = 006A5H;  (* U+0455 CYRILLIC SMALL LETTER DZE *)
	 XK_Ukrainian_i1* = 006A6H;  (* U+0456 CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I *)
	 XK_Ukranian_i1* = 006A6H;  (* deprecated *)
	 XK_Ukrainian_yi1* = 006A7H;  (* U+0457 CYRILLIC SMALL LETTER YI *)
	 XK_Ukranian_yi1* = 006A7H;  (* deprecated *)
	 XK_Cyrillic_je1* = 006A8H;  (* U+0458 CYRILLIC SMALL LETTER JE *)
	 XK_Serbian_je1* = 006A8H;  (* deprecated *)
	 XK_Cyrillic_lje1* = 006A9H;  (* U+0459 CYRILLIC SMALL LETTER LJE *)
	 XK_Serbian_lje1* = 006A9H;  (* deprecated *)
	 XK_Cyrillic_nje1* = 006AAH;  (* U+045A CYRILLIC SMALL LETTER NJE *)
	 XK_Serbian_nje1* = 006AAH;  (* deprecated *)
	 XK_Serbian_tshe1* = 006ABH;  (* U+045B CYRILLIC SMALL LETTER TSHE *)
	 XK_Macedonia_kje1* = 006ACH;  (* U+045C CYRILLIC SMALL LETTER KJE *)
	 XK_Ukrainian_ghe_with_upturn1* = 006ADH;  (* U+0491 CYRILLIC SMALL LETTER GHE WITH UPTURN *)
	 XK_Byelorussian_shortu1* = 006AEH;  (* U+045E CYRILLIC SMALL LETTER SHORT U *)
	 XK_Cyrillic_dzhe1* = 006AFH;  (* U+045F CYRILLIC SMALL LETTER DZHE *)
	 XK_Serbian_dze1* = 006AFH;  (* deprecated *)
	 XK_numerosign* = 006B0H;  (* U+2116 NUMERO SIGN *)
	 XK_Serbian_DJE* = 006B1H;  (* U+0402 CYRILLIC CAPITAL LETTER DJE *)
	 XK_Macedonia_GJE* = 006B2H;  (* U+0403 CYRILLIC CAPITAL LETTER GJE *)
	 XK_Cyrillic_IO* = 006B3H;  (* U+0401 CYRILLIC CAPITAL LETTER IO *)
	 XK_Ukrainian_IE* = 006B4H;  (* U+0404 CYRILLIC CAPITAL LETTER UKRAINIAN IE *)
	 XK_Ukranian_JE* = 006B4H;  (* deprecated *)
	 XK_Macedonia_DSE* = 006B5H;  (* U+0405 CYRILLIC CAPITAL LETTER DZE *)
	 XK_Ukrainian_I* = 006B6H;  (* U+0406 CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I *)
	 XK_Ukranian_I* = 006B6H;  (* deprecated *)
	 XK_Ukrainian_YI* = 006B7H;  (* U+0407 CYRILLIC CAPITAL LETTER YI *)
	 XK_Ukranian_YI* = 006B7H;  (* deprecated *)
	 XK_Cyrillic_JE* = 006B8H;  (* U+0408 CYRILLIC CAPITAL LETTER JE *)
	 XK_Serbian_JE* = 006B8H;  (* deprecated *)
	 XK_Cyrillic_LJE* = 006B9H;  (* U+0409 CYRILLIC CAPITAL LETTER LJE *)
	 XK_Serbian_LJE* = 006B9H;  (* deprecated *)
	 XK_Cyrillic_NJE* = 006BAH;  (* U+040A CYRILLIC CAPITAL LETTER NJE *)
	 XK_Serbian_NJE* = 006BAH;  (* deprecated *)
	 XK_Serbian_TSHE* = 006BBH;  (* U+040B CYRILLIC CAPITAL LETTER TSHE *)
	 XK_Macedonia_KJE* = 006BCH;  (* U+040C CYRILLIC CAPITAL LETTER KJE *)
	 XK_Ukrainian_GHE_WITH_UPTURN* = 006BDH;  (* U+0490 CYRILLIC CAPITAL LETTER GHE WITH UPTURN *)
	 XK_Byelorussian_SHORTU* = 006BEH;  (* U+040E CYRILLIC CAPITAL LETTER SHORT U *)
	 XK_Cyrillic_DZHE* = 006BFH;  (* U+040F CYRILLIC CAPITAL LETTER DZHE *)
	 XK_Serbian_DZE* = 006BFH;  (* deprecated *)
	 XK_Cyrillic_yu1* = 006C0H;  (* U+044E CYRILLIC SMALL LETTER YU *)
	 XK_Cyrillic_a1* = 006C1H;  (* U+0430 CYRILLIC SMALL LETTER A *)
	 XK_Cyrillic_be1* = 006C2H;  (* U+0431 CYRILLIC SMALL LETTER BE *)
	 XK_Cyrillic_tse1* = 006C3H;  (* U+0446 CYRILLIC SMALL LETTER TSE *)
	 XK_Cyrillic_de1* = 006C4H;  (* U+0434 CYRILLIC SMALL LETTER DE *)
	 XK_Cyrillic_ie1* = 006C5H;  (* U+0435 CYRILLIC SMALL LETTER IE *)
	 XK_Cyrillic_ef1* = 006C6H;  (* U+0444 CYRILLIC SMALL LETTER EF *)
	 XK_Cyrillic_ghe1* = 006C7H;  (* U+0433 CYRILLIC SMALL LETTER GHE *)
	 XK_Cyrillic_ha1* = 006C8H;  (* U+0445 CYRILLIC SMALL LETTER HA *)
	 XK_Cyrillic_i1* = 006C9H;  (* U+0438 CYRILLIC SMALL LETTER I *)
	 XK_Cyrillic_shorti1* = 006CAH;  (* U+0439 CYRILLIC SMALL LETTER SHORT I *)
	 XK_Cyrillic_ka1* = 006CBH;  (* U+043A CYRILLIC SMALL LETTER KA *)
	 XK_Cyrillic_el1* = 006CCH;  (* U+043B CYRILLIC SMALL LETTER EL *)
	 XK_Cyrillic_em1* = 006CDH;  (* U+043C CYRILLIC SMALL LETTER EM *)
	 XK_Cyrillic_en1* = 006CEH;  (* U+043D CYRILLIC SMALL LETTER EN *)
	 XK_Cyrillic_o1* = 006CFH;  (* U+043E CYRILLIC SMALL LETTER O *)
	 XK_Cyrillic_pe1* = 006D0H;  (* U+043F CYRILLIC SMALL LETTER PE *)
	 XK_Cyrillic_ya1* = 006D1H;  (* U+044F CYRILLIC SMALL LETTER YA *)
	 XK_Cyrillic_er1* = 006D2H;  (* U+0440 CYRILLIC SMALL LETTER ER *)
	 XK_Cyrillic_es1* = 006D3H;  (* U+0441 CYRILLIC SMALL LETTER ES *)
	 XK_Cyrillic_te1* = 006D4H;  (* U+0442 CYRILLIC SMALL LETTER TE *)
	 XK_Cyrillic_u1* = 006D5H;  (* U+0443 CYRILLIC SMALL LETTER U *)
	 XK_Cyrillic_zhe1* = 006D6H;  (* U+0436 CYRILLIC SMALL LETTER ZHE *)
	 XK_Cyrillic_ve1* = 006D7H;  (* U+0432 CYRILLIC SMALL LETTER VE *)
	 XK_Cyrillic_softsign1* = 006D8H;  (* U+044C CYRILLIC SMALL LETTER SOFT SIGN *)
	 XK_Cyrillic_yeru1* = 006D9H;  (* U+044B CYRILLIC SMALL LETTER YERU *)
	 XK_Cyrillic_ze1* = 006DAH;  (* U+0437 CYRILLIC SMALL LETTER ZE *)
	 XK_Cyrillic_sha1* = 006DBH;  (* U+0448 CYRILLIC SMALL LETTER SHA *)
	 XK_Cyrillic_e1* = 006DCH;  (* U+044D CYRILLIC SMALL LETTER E *)
	 XK_Cyrillic_shcha1* = 006DDH;  (* U+0449 CYRILLIC SMALL LETTER SHCHA *)
	 XK_Cyrillic_che1* = 006DEH;  (* U+0447 CYRILLIC SMALL LETTER CHE *)
	 XK_Cyrillic_hardsign1* = 006DFH;  (* U+044A CYRILLIC SMALL LETTER HARD SIGN *)
	 XK_Cyrillic_YU* = 006E0H;  (* U+042E CYRILLIC CAPITAL LETTER YU *)
	 XK_Cyrillic_A* = 006E1H;  (* U+0410 CYRILLIC CAPITAL LETTER A *)
	 XK_Cyrillic_BE* = 006E2H;  (* U+0411 CYRILLIC CAPITAL LETTER BE *)
	 XK_Cyrillic_TSE* = 006E3H;  (* U+0426 CYRILLIC CAPITAL LETTER TSE *)
	 XK_Cyrillic_DE* = 006E4H;  (* U+0414 CYRILLIC CAPITAL LETTER DE *)
	 XK_Cyrillic_IE* = 006E5H;  (* U+0415 CYRILLIC CAPITAL LETTER IE *)
	 XK_Cyrillic_EF* = 006E6H;  (* U+0424 CYRILLIC CAPITAL LETTER EF *)
	 XK_Cyrillic_GHE* = 006E7H;  (* U+0413 CYRILLIC CAPITAL LETTER GHE *)
	 XK_Cyrillic_HA* = 006E8H;  (* U+0425 CYRILLIC CAPITAL LETTER HA *)
	 XK_Cyrillic_I* = 006E9H;  (* U+0418 CYRILLIC CAPITAL LETTER I *)
	 XK_Cyrillic_SHORTI* = 006EAH;  (* U+0419 CYRILLIC CAPITAL LETTER SHORT I *)
	 XK_Cyrillic_KA* = 006EBH;  (* U+041A CYRILLIC CAPITAL LETTER KA *)
	 XK_Cyrillic_EL* = 006ECH;  (* U+041B CYRILLIC CAPITAL LETTER EL *)
	 XK_Cyrillic_EM* = 006EDH;  (* U+041C CYRILLIC CAPITAL LETTER EM *)
	 XK_Cyrillic_EN* = 006EEH;  (* U+041D CYRILLIC CAPITAL LETTER EN *)
	 XK_Cyrillic_O* = 006EFH;  (* U+041E CYRILLIC CAPITAL LETTER O *)
	 XK_Cyrillic_PE* = 006F0H;  (* U+041F CYRILLIC CAPITAL LETTER PE *)
	 XK_Cyrillic_YA* = 006F1H;  (* U+042F CYRILLIC CAPITAL LETTER YA *)
	 XK_Cyrillic_ER* = 006F2H;  (* U+0420 CYRILLIC CAPITAL LETTER ER *)
	 XK_Cyrillic_ES* = 006F3H;  (* U+0421 CYRILLIC CAPITAL LETTER ES *)
	 XK_Cyrillic_TE* = 006F4H;  (* U+0422 CYRILLIC CAPITAL LETTER TE *)
	 XK_Cyrillic_U* = 006F5H;  (* U+0423 CYRILLIC CAPITAL LETTER U *)
	 XK_Cyrillic_ZHE* = 006F6H;  (* U+0416 CYRILLIC CAPITAL LETTER ZHE *)
	 XK_Cyrillic_VE* = 006F7H;  (* U+0412 CYRILLIC CAPITAL LETTER VE *)
	 XK_Cyrillic_SOFTSIGN* = 006F8H;  (* U+042C CYRILLIC CAPITAL LETTER SOFT SIGN *)
	 XK_Cyrillic_YERU* = 006F9H;  (* U+042B CYRILLIC CAPITAL LETTER YERU *)
	 XK_Cyrillic_ZE* = 006FAH;  (* U+0417 CYRILLIC CAPITAL LETTER ZE *)
	 XK_Cyrillic_SHA* = 006FBH;  (* U+0428 CYRILLIC CAPITAL LETTER SHA *)
	 XK_Cyrillic_E* = 006FCH;  (* U+042D CYRILLIC CAPITAL LETTER E *)
	 XK_Cyrillic_SHCHA* = 006FDH;  (* U+0429 CYRILLIC CAPITAL LETTER SHCHA *)
	 XK_Cyrillic_CHE* = 006FEH;  (* U+0427 CYRILLIC CAPITAL LETTER CHE *)
	 XK_Cyrillic_HARDSIGN* = 006FFH;  (* U+042A CYRILLIC CAPITAL LETTER HARD SIGN *)
	(* #endif *) (* XK_CYRILLIC *)

	(*
	 * Greek
	 * (based on an early draft of, and not quite identical to, ISO/IEC 8859-7)
	 * Byte 3* = 7
	 *)

	(* #ifdef XK_GREEK *)
	 XK_Greek_ALPHAaccent* = 007A1H;  (* U+0386 GREEK CAPITAL LETTER ALPHA WITH TONOS *)
	 XK_Greek_EPSILONaccent* = 007A2H;  (* U+0388 GREEK CAPITAL LETTER EPSILON WITH TONOS *)
	 XK_Greek_ETAaccent* = 007A3H;  (* U+0389 GREEK CAPITAL LETTER ETA WITH TONOS *)
	 XK_Greek_IOTAaccent* = 007A4H;  (* U+038A GREEK CAPITAL LETTER IOTA WITH TONOS *)
	 XK_Greek_IOTAdieresis* = 007A5H;  (* U+03AA GREEK CAPITAL LETTER IOTA WITH DIALYTIKA *)
	 XK_Greek_IOTAdiaeresis* = 007A5H;  (* old typo *)
	 XK_Greek_OMICRONaccent* = 007A7H;  (* U+038C GREEK CAPITAL LETTER OMICRON WITH TONOS *)
	 XK_Greek_UPSILONaccent* = 007A8H;  (* U+038E GREEK CAPITAL LETTER UPSILON WITH TONOS *)
	 XK_Greek_UPSILONdieresis* = 007A9H;  (* U+03AB GREEK CAPITAL LETTER UPSILON WITH DIALYTIKA *)
	 XK_Greek_OMEGAaccent* = 007ABH;  (* U+038F GREEK CAPITAL LETTER OMEGA WITH TONOS *)
	 XK_Greek_accentdieresis* = 007AEH;  (* U+0385 GREEK DIALYTIKA TONOS *)
	 XK_Greek_horizbar* = 007AFH;  (* U+2015 HORIZONTAL BAR *)
	 XK_Greek_alphaaccent1* = 007B1H;  (* U+03AC GREEK SMALL LETTER ALPHA WITH TONOS *)
	 XK_Greek_epsilonaccent1* = 007B2H;  (* U+03AD GREEK SMALL LETTER EPSILON WITH TONOS *)
	 XK_Greek_etaaccent1* = 007B3H;  (* U+03AE GREEK SMALL LETTER ETA WITH TONOS *)
	 XK_Greek_iotaaccent1* = 007B4H;  (* U+03AF GREEK SMALL LETTER IOTA WITH TONOS *)
	 XK_Greek_iotadieresis1* = 007B5H;  (* U+03CA GREEK SMALL LETTER IOTA WITH DIALYTIKA *)
	 XK_Greek_iotaaccentdieresis* = 007B6H;  (* U+0390 GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS *)
	 XK_Greek_omicronaccent1* = 007B7H;  (* U+03CC GREEK SMALL LETTER OMICRON WITH TONOS *)
	 XK_Greek_upsilonaccent1* = 007B8H;  (* U+03CD GREEK SMALL LETTER UPSILON WITH TONOS *)
	 XK_Greek_upsilondieresis1* = 007B9H;  (* U+03CB GREEK SMALL LETTER UPSILON WITH DIALYTIKA *)
	 XK_Greek_upsilonaccentdieresis* = 007BAH;  (* U+03B0 GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONOS *)
	 XK_Greek_omegaaccent1* = 007BBH;  (* U+03CE GREEK SMALL LETTER OMEGA WITH TONOS *)
	 XK_Greek_ALPHA* = 007C1H;  (* U+0391 GREEK CAPITAL LETTER ALPHA *)
	 XK_Greek_BETA* = 007C2H;  (* U+0392 GREEK CAPITAL LETTER BETA *)
	 XK_Greek_GAMMA* = 007C3H;  (* U+0393 GREEK CAPITAL LETTER GAMMA *)
	 XK_Greek_DELTA* = 007C4H;  (* U+0394 GREEK CAPITAL LETTER DELTA *)
	 XK_Greek_EPSILON* = 007C5H;  (* U+0395 GREEK CAPITAL LETTER EPSILON *)
	 XK_Greek_ZETA* = 007C6H;  (* U+0396 GREEK CAPITAL LETTER ZETA *)
	 XK_Greek_ETA* = 007C7H;  (* U+0397 GREEK CAPITAL LETTER ETA *)
	 XK_Greek_THETA* = 007C8H;  (* U+0398 GREEK CAPITAL LETTER THETA *)
	 XK_Greek_IOTA* = 007C9H;  (* U+0399 GREEK CAPITAL LETTER IOTA *)
	 XK_Greek_KAPPA* = 007CAH;  (* U+039A GREEK CAPITAL LETTER KAPPA *)
	 XK_Greek_LAMDA* = 007CBH;  (* U+039B GREEK CAPITAL LETTER LAMDA *)
	 XK_Greek_LAMBDA* = 007CBH;  (* U+039B GREEK CAPITAL LETTER LAMDA *)
	 XK_Greek_MU* = 007CCH;  (* U+039C GREEK CAPITAL LETTER MU *)
	 XK_Greek_NU* = 007CDH;  (* U+039D GREEK CAPITAL LETTER NU *)
	 XK_Greek_XI* = 007CEH;  (* U+039E GREEK CAPITAL LETTER XI *)
	 XK_Greek_OMICRON* = 007CFH;  (* U+039F GREEK CAPITAL LETTER OMICRON *)
	 XK_Greek_PI* = 007D0H;  (* U+03A0 GREEK CAPITAL LETTER PI *)
	 XK_Greek_RHO* = 007D1H;  (* U+03A1 GREEK CAPITAL LETTER RHO *)
	 XK_Greek_SIGMA* = 007D2H;  (* U+03A3 GREEK CAPITAL LETTER SIGMA *)
	 XK_Greek_TAU* = 007D4H;  (* U+03A4 GREEK CAPITAL LETTER TAU *)
	 XK_Greek_UPSILON* = 007D5H;  (* U+03A5 GREEK CAPITAL LETTER UPSILON *)
	 XK_Greek_PHI* = 007D6H;  (* U+03A6 GREEK CAPITAL LETTER PHI *)
	 XK_Greek_CHI* = 007D7H;  (* U+03A7 GREEK CAPITAL LETTER CHI *)
	 XK_Greek_PSI* = 007D8H;  (* U+03A8 GREEK CAPITAL LETTER PSI *)
	 XK_Greek_OMEGA* = 007D9H;  (* U+03A9 GREEK CAPITAL LETTER OMEGA *)
	 XK_Greek_alpha* = 007E1H;  (* U+03B1 GREEK SMALL LETTER ALPHA *)
	 XK_Greek_beta* = 007E2H;  (* U+03B2 GREEK SMALL LETTER BETA *)
	 XK_Greek_gamma* = 007E3H;  (* U+03B3 GREEK SMALL LETTER GAMMA *)
	 XK_Greek_delta* = 007E4H;  (* U+03B4 GREEK SMALL LETTER DELTA *)
	 XK_Greek_epsilon* = 007E5H;  (* U+03B5 GREEK SMALL LETTER EPSILON *)
	 XK_Greek_zeta* = 007E6H;  (* U+03B6 GREEK SMALL LETTER ZETA *)
	 XK_Greek_eta* = 007E7H;  (* U+03B7 GREEK SMALL LETTER ETA *)
	 XK_Greek_theta* = 007E8H;  (* U+03B8 GREEK SMALL LETTER THETA *)
	 XK_Greek_iota* = 007E9H;  (* U+03B9 GREEK SMALL LETTER IOTA *)
	 XK_Greek_kappa* = 007EAH;  (* U+03BA GREEK SMALL LETTER KAPPA *)
	 XK_Greek_lamda* = 007EBH;  (* U+03BB GREEK SMALL LETTER LAMDA *)
	 XK_Greek_lambda* = 007EBH;  (* U+03BB GREEK SMALL LETTER LAMDA *)
	 XK_Greek_mu* = 007ECH;  (* U+03BC GREEK SMALL LETTER MU *)
	 XK_Greek_nu* = 007EDH;  (* U+03BD GREEK SMALL LETTER NU *)
	 XK_Greek_xi* = 007EEH;  (* U+03BE GREEK SMALL LETTER XI *)
	 XK_Greek_omicron* = 007EFH;  (* U+03BF GREEK SMALL LETTER OMICRON *)
	 XK_Greek_pi* = 007F0H;  (* U+03C0 GREEK SMALL LETTER PI *)
	 XK_Greek_rho* = 007F1H;  (* U+03C1 GREEK SMALL LETTER RHO *)
	 XK_Greek_sigma* = 007F2H;  (* U+03C3 GREEK SMALL LETTER SIGMA *)
	 XK_Greek_finalsmallsigma* = 007F3H;  (* U+03C2 GREEK SMALL LETTER FINAL SIGMA *)
	 XK_Greek_tau* = 007F4H;  (* U+03C4 GREEK SMALL LETTER TAU *)
	 XK_Greek_upsilon* = 007F5H;  (* U+03C5 GREEK SMALL LETTER UPSILON *)
	 XK_Greek_phi* = 007F6H;  (* U+03C6 GREEK SMALL LETTER PHI *)
	 XK_Greek_chi* = 007F7H;  (* U+03C7 GREEK SMALL LETTER CHI *)
	 XK_Greek_psi* = 007F8H;  (* U+03C8 GREEK SMALL LETTER PSI *)
	 XK_Greek_omega* = 007F9H;  (* U+03C9 GREEK SMALL LETTER OMEGA *)
	 XK_Greek_switch* = 0FF7EH;  (* Alias for mode_switch *)
	(* #endif *) (* XK_GREEK *)

	(*
	 * Technical
	 * (from the DEC VT330/VT420 Technical Character Set, http://vt100.net/charsets/technical.html)
	 * Byte 3* = 8
	 *)

	(* #ifdef XK_TECHNICAL *)
	 XK_leftradical* = 008A1H;  (* U+23B7 RADICAL SYMBOL BOTTOM *)
	 XK_topleftradical* = 008A2H;  (*(U+250C BOX DRAWINGS LIGHT DOWN AND RIGHT)*)
	 XK_horizconnector* = 008A3H;  (*(U+2500 BOX DRAWINGS LIGHT HORIZONTAL)*)
	 XK_topintegral* = 008A4H;  (* U+2320 TOP HALF INTEGRAL *)
	 XK_botintegral* = 008A5H;  (* U+2321 BOTTOM HALF INTEGRAL *)
	 XK_vertconnector* = 008A6H;  (*(U+2502 BOX DRAWINGS LIGHT VERTICAL)*)
	 XK_topleftsqbracket* = 008A7H;  (* U+23A1 LEFT SQUARE BRACKET UPPER CORNER *)
	 XK_botleftsqbracket* = 008A8H;  (* U+23A3 LEFT SQUARE BRACKET LOWER CORNER *)
	 XK_toprightsqbracket* = 008A9H;  (* U+23A4 RIGHT SQUARE BRACKET UPPER CORNER *)
	 XK_botrightsqbracket* = 008AAH;  (* U+23A6 RIGHT SQUARE BRACKET LOWER CORNER *)
	 XK_topleftparens* = 008ABH;  (* U+239B LEFT PARENTHESIS UPPER HOOK *)
	 XK_botleftparens* = 008ACH;  (* U+239D LEFT PARENTHESIS LOWER HOOK *)
	 XK_toprightparens* = 008ADH;  (* U+239E RIGHT PARENTHESIS UPPER HOOK *)
	 XK_botrightparens* = 008AEH;  (* U+23A0 RIGHT PARENTHESIS LOWER HOOK *)
	 XK_leftmiddlecurlybrace* = 008AFH;  (* U+23A8 LEFT CURLY BRACKET MIDDLE PIECE *)
	 XK_rightmiddlecurlybrace* = 008B0H;  (* U+23AC RIGHT CURLY BRACKET MIDDLE PIECE *)
	 XK_topleftsummation* = 008B1H;
	 XK_botleftsummation* = 008B2H;
	 XK_topvertsummationconnector* = 008B3H;
	 XK_botvertsummationconnector* = 008B4H;
	 XK_toprightsummation* = 008B5H;
	 XK_botrightsummation* = 008B6H;
	 XK_rightmiddlesummation* = 008B7H;
	 XK_lessthanequal* = 008BCH;  (* U+2264 LESS-THAN OR EQUAL TO *)
	 XK_notequal* = 008BDH;  (* U+2260 NOT EQUAL TO *)
	 XK_greaterthanequal* = 008BEH;  (* U+2265 GREATER-THAN OR EQUAL TO *)
	 XK_integral* = 008BFH;  (* U+222B INTEGRAL *)
	 XK_therefore* = 008C0H;  (* U+2234 THEREFORE *)
	 XK_variation* = 008C1H;  (* U+221D PROPORTIONAL TO *)
	 XK_infinity* = 008C2H;  (* U+221E INFINITY *)
	 XK_nabla* = 008C5H;  (* U+2207 NABLA *)
	 XK_approximate* = 008C8H;  (* U+223C TILDE OPERATOR *)
	 XK_similarequal* = 008C9H;  (* U+2243 ASYMPTOTICALLY EQUAL TO *)
	 XK_ifonlyif* = 008CDH;  (* U+21D4 LEFT RIGHT DOUBLE ARROW *)
	 XK_implies* = 008CEH;  (* U+21D2 RIGHTWARDS DOUBLE ARROW *)
	 XK_identical* = 008CFH;  (* U+2261 IDENTICAL TO *)
	 XK_radical* = 008D6H;  (* U+221A SQUARE ROOT *)
	 XK_includedin* = 008DAH;  (* U+2282 SUBSET OF *)
	 XK_includes* = 008DBH;  (* U+2283 SUPERSET OF *)
	 XK_intersection* = 008DCH;  (* U+2229 INTERSECTION *)
	 XK_union* = 008DDH;  (* U+222A UNION *)
	 XK_logicaland* = 008DEH;  (* U+2227 LOGICAL AND *)
	 XK_logicalor* = 008DFH;  (* U+2228 LOGICAL OR *)
	 XK_partialderivative* = 008EFH;  (* U+2202 PARTIAL DIFFERENTIAL *)
	 XK_function* = 008F6H;  (* U+0192 LATIN SMALL LETTER F WITH HOOK *)
	 XK_leftarrow* = 008FBH;  (* U+2190 LEFTWARDS ARROW *)
	 XK_uparrow* = 008FCH;  (* U+2191 UPWARDS ARROW *)
	 XK_rightarrow* = 008FDH;  (* U+2192 RIGHTWARDS ARROW *)
	 XK_downarrow* = 008FEH;  (* U+2193 DOWNWARDS ARROW *)
	(* #endif *) (* XK_TECHNICAL *)

	(*
	 * Special
	 * (from the DEC VT100 Special Graphics Character Set)
	 * Byte 3* = 9
	 *)

	(* #ifdef XK_SPECIAL *)
	 XK_blank* = 009DFH;
	 XK_soliddiamond* = 009E0H;  (* U+25C6 BLACK DIAMOND *)
	 XK_checkerboard* = 009E1H;  (* U+2592 MEDIUM SHADE *)
	 XK_ht* = 009E2H;  (* U+2409 SYMBOL FOR HORIZONTAL TABULATION *)
	 XK_ff* = 009E3H;  (* U+240C SYMBOL FOR FORM FEED *)
	 XK_cr* = 009E4H;  (* U+240D SYMBOL FOR CARRIAGE RETURN *)
	 XK_lf* = 009E5H;  (* U+240A SYMBOL FOR LINE FEED *)
	 XK_nl* = 009E8H;  (* U+2424 SYMBOL FOR NEWLINE *)
	 XK_vt* = 009E9H;  (* U+240B SYMBOL FOR VERTICAL TABULATION *)
	 XK_lowrightcorner* = 009EAH;  (* U+2518 BOX DRAWINGS LIGHT UP AND LEFT *)
	 XK_uprightcorner* = 009EBH;  (* U+2510 BOX DRAWINGS LIGHT DOWN AND LEFT *)
	 XK_upleftcorner* = 009ECH;  (* U+250C BOX DRAWINGS LIGHT DOWN AND RIGHT *)
	 XK_lowleftcorner* = 009EDH;  (* U+2514 BOX DRAWINGS LIGHT UP AND RIGHT *)
	 XK_crossinglines* = 009EEH;  (* U+253C BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL *)
	 XK_horizlinescan1* = 009EFH;  (* U+23BA HORIZONTAL SCAN LINE-1 *)
	 XK_horizlinescan3* = 009F0H;  (* U+23BB HORIZONTAL SCAN LINE-3 *)
	 XK_horizlinescan5* = 009F1H;  (* U+2500 BOX DRAWINGS LIGHT HORIZONTAL *)
	 XK_horizlinescan7* = 009F2H;  (* U+23BC HORIZONTAL SCAN LINE-7 *)
	 XK_horizlinescan9* = 009F3H;  (* U+23BD HORIZONTAL SCAN LINE-9 *)
	 XK_leftt* = 009F4H;  (* U+251C BOX DRAWINGS LIGHT VERTICAL AND RIGHT *)
	 XK_rightt* = 009F5H;  (* U+2524 BOX DRAWINGS LIGHT VERTICAL AND LEFT *)
	 XK_bott* = 009F6H;  (* U+2534 BOX DRAWINGS LIGHT UP AND HORIZONTAL *)
	 XK_topt* = 009F7H;  (* U+252C BOX DRAWINGS LIGHT DOWN AND HORIZONTAL *)
	 XK_vertbar* = 009F8H;  (* U+2502 BOX DRAWINGS LIGHT VERTICAL *)
	(* #endif *) (* XK_SPECIAL *)

	(*
	 * Publishing
	 * (these are probably from a long forgotten DEC Publishing
	 * font that once shipped with DECwrite)
	 * Byte 3* = 0x0a
	 *)

	(* #ifdef XK_PUBLISHING *)
	 XK_emspace* = 00AA1H;  (* U+2003 EM SPACE *)
	 XK_enspace* = 00AA2H;  (* U+2002 EN SPACE *)
	 XK_em3space* = 00AA3H;  (* U+2004 THREE-PER-EM SPACE *)
	 XK_em4space* = 00AA4H;  (* U+2005 FOUR-PER-EM SPACE *)
	 XK_digitspace* = 00AA5H;  (* U+2007 FIGURE SPACE *)
	 XK_punctspace* = 00AA6H;  (* U+2008 PUNCTUATION SPACE *)
	 XK_thinspace* = 00AA7H;  (* U+2009 THIN SPACE *)
	 XK_hairspace* = 00AA8H;  (* U+200A HAIR SPACE *)
	 XK_emdash* = 00AA9H;  (* U+2014 EM DASH *)
	 XK_endash* = 00AAAH;  (* U+2013 EN DASH *)
	 XK_signifblank* = 00AACH;  (*(U+2423 OPEN BOX)*)
	 XK_ellipsis* = 00AAEH;  (* U+2026 HORIZONTAL ELLIPSIS *)
	 XK_doubbaselinedot* = 00AAFH;  (* U+2025 TWO DOT LEADER *)
	 XK_onethird* = 00AB0H;  (* U+2153 VULGAR FRACTION ONE THIRD *)
	 XK_twothirds* = 00AB1H;  (* U+2154 VULGAR FRACTION TWO THIRDS *)
	 XK_onefifth* = 00AB2H;  (* U+2155 VULGAR FRACTION ONE FIFTH *)
	 XK_twofifths* = 00AB3H;  (* U+2156 VULGAR FRACTION TWO FIFTHS *)
	 XK_threefifths* = 00AB4H;  (* U+2157 VULGAR FRACTION THREE FIFTHS *)
	 XK_fourfifths* = 00AB5H;  (* U+2158 VULGAR FRACTION FOUR FIFTHS *)
	 XK_onesixth* = 00AB6H;  (* U+2159 VULGAR FRACTION ONE SIXTH *)
	 XK_fivesixths* = 00AB7H;  (* U+215A VULGAR FRACTION FIVE SIXTHS *)
	 XK_careof* = 00AB8H;  (* U+2105 CARE OF *)
	 XK_figdash* = 00ABBH;  (* U+2012 FIGURE DASH *)
	 XK_leftanglebracket* = 00ABCH;  (*(U+27E8 MATHEMATICAL LEFT ANGLE BRACKET)*)
	 XK_decimalpoint* = 00ABDH;  (*(U+002E FULL STOP)*)
	 XK_rightanglebracket* = 00ABEH;  (*(U+27E9 MATHEMATICAL RIGHT ANGLE BRACKET)*)
	 XK_marker* = 00ABFH;
	 XK_oneeighth* = 00AC3H;  (* U+215B VULGAR FRACTION ONE EIGHTH *)
	 XK_threeeighths* = 00AC4H;  (* U+215C VULGAR FRACTION THREE EIGHTHS *)
	 XK_fiveeighths* = 00AC5H;  (* U+215D VULGAR FRACTION FIVE EIGHTHS *)
	 XK_seveneighths* = 00AC6H;  (* U+215E VULGAR FRACTION SEVEN EIGHTHS *)
	 XK_trademark* = 00AC9H;  (* U+2122 TRADE MARK SIGN *)
	 XK_signaturemark* = 00ACAH;  (*(U+2613 SALTIRE)*)
	 XK_trademarkincircle* = 00ACBH;
	 XK_leftopentriangle* = 00ACCH;  (*(U+25C1 WHITE LEFT-POINTING TRIANGLE)*)
	 XK_rightopentriangle* = 00ACDH;  (*(U+25B7 WHITE RIGHT-POINTING TRIANGLE)*)
	 XK_emopencircle* = 00ACEH;  (*(U+25CB WHITE CIRCLE)*)
	 XK_emopenrectangle* = 00ACFH;  (*(U+25AF WHITE VERTICAL RECTANGLE)*)
	 XK_leftsinglequotemark* = 00AD0H;  (* U+2018 LEFT SINGLE QUOTATION MARK *)
	 XK_rightsinglequotemark* = 00AD1H;  (* U+2019 RIGHT SINGLE QUOTATION MARK *)
	 XK_leftdoublequotemark* = 00AD2H;  (* U+201C LEFT DOUBLE QUOTATION MARK *)
	 XK_rightdoublequotemark* = 00AD3H;  (* U+201D RIGHT DOUBLE QUOTATION MARK *)
	 XK_prescription* = 00AD4H;  (* U+211E PRESCRIPTION TAKE *)
	 XK_minutes* = 00AD6H;  (* U+2032 PRIME *)
	 XK_seconds* = 00AD7H;  (* U+2033 DOUBLE PRIME *)
	 XK_latincross* = 00AD9H;  (* U+271D LATIN CROSS *)
	 XK_hexagram* = 00ADAH;
	 XK_filledrectbullet* = 00ADBH;  (*(U+25AC BLACK RECTANGLE)*)
	 XK_filledlefttribullet* = 00ADCH;  (*(U+25C0 BLACK LEFT-POINTING TRIANGLE)*)
	 XK_filledrighttribullet* = 00ADDH;  (*(U+25B6 BLACK RIGHT-POINTING TRIANGLE)*)
	 XK_emfilledcircle* = 00ADEH;  (*(U+25CF BLACK CIRCLE)*)
	 XK_emfilledrect* = 00ADFH;  (*(U+25AE BLACK VERTICAL RECTANGLE)*)
	 XK_enopencircbullet* = 00AE0H;  (*(U+25E6 WHITE BULLET)*)
	 XK_enopensquarebullet* = 00AE1H;  (*(U+25AB WHITE SMALL SQUARE)*)
	 XK_openrectbullet* = 00AE2H;  (*(U+25AD WHITE RECTANGLE)*)
	 XK_opentribulletup* = 00AE3H;  (*(U+25B3 WHITE UP-POINTING TRIANGLE)*)
	 XK_opentribulletdown* = 00AE4H;  (*(U+25BD WHITE DOWN-POINTING TRIANGLE)*)
	 XK_openstar* = 00AE5H;  (*(U+2606 WHITE STAR)*)
	 XK_enfilledcircbullet* = 00AE6H;  (*(U+2022 BULLET)*)
	 XK_enfilledsqbullet* = 00AE7H;  (*(U+25AA BLACK SMALL SQUARE)*)
	 XK_filledtribulletup* = 00AE8H;  (*(U+25B2 BLACK UP-POINTING TRIANGLE)*)
	 XK_filledtribulletdown* = 00AE9H;  (*(U+25BC BLACK DOWN-POINTING TRIANGLE)*)
	 XK_leftpointer* = 00AEAH;  (*(U+261C WHITE LEFT POINTING INDEX)*)
	 XK_rightpointer* = 00AEBH;  (*(U+261E WHITE RIGHT POINTING INDEX)*)
	 XK_club* = 00AECH;  (* U+2663 BLACK CLUB SUIT *)
	 XK_diamond* = 00AEDH;  (* U+2666 BLACK DIAMOND SUIT *)
	 XK_heart* = 00AEEH;  (* U+2665 BLACK HEART SUIT *)
	 XK_maltesecross* = 00AF0H;  (* U+2720 MALTESE CROSS *)
	 XK_dagger* = 00AF1H;  (* U+2020 DAGGER *)
	 XK_doubledagger* = 00AF2H;  (* U+2021 DOUBLE DAGGER *)
	 XK_checkmark* = 00AF3H;  (* U+2713 CHECK MARK *)
	 XK_ballotcross* = 00AF4H;  (* U+2717 BALLOT X *)
	 XK_musicalsharp* = 00AF5H;  (* U+266F MUSIC SHARP SIGN *)
	 XK_musicalflat* = 00AF6H;  (* U+266D MUSIC FLAT SIGN *)
	 XK_malesymbol* = 00AF7H;  (* U+2642 MALE SIGN *)
	 XK_femalesymbol* = 00AF8H;  (* U+2640 FEMALE SIGN *)
	 XK_telephone* = 00AF9H;  (* U+260E BLACK TELEPHONE *)
	 XK_telephonerecorder* = 00AFAH;  (* U+2315 TELEPHONE RECORDER *)
	 XK_phonographcopyright* = 00AFBH;  (* U+2117 SOUND RECORDING COPYRIGHT *)
	 XK_caret* = 00AFCH;  (* U+2038 CARET *)
	 XK_singlelowquotemark* = 00AFDH;  (* U+201A SINGLE LOW-9 QUOTATION MARK *)
	 XK_doublelowquotemark* = 00AFEH;  (* U+201E DOUBLE LOW-9 QUOTATION MARK *)
	 XK_cursor* = 00AFFH;
	(* #endif *) (* XK_PUBLISHING *)

	(*
	 * APL
	 * Byte 3* = 0x0b
	 *)

	(* #ifdef XK_APL *)
	 XK_leftcaret* = 00BA3H;  (*(U+003C LESS-THAN SIGN)*)
	 XK_rightcaret* = 00BA6H;  (*(U+003E GREATER-THAN SIGN)*)
	 XK_downcaret* = 00BA8H;  (*(U+2228 LOGICAL OR)*)
	 XK_upcaret* = 00BA9H;  (*(U+2227 LOGICAL AND)*)
	 XK_overbar* = 00BC0H;  (*(U+00AF MACRON)*)
	 XK_downtack* = 00BC2H;  (* U+22A4 DOWN TACK *)
	 XK_upshoe* = 00BC3H;  (*(U+2229 INTERSECTION)*)
	 XK_downstile* = 00BC4H;  (* U+230A LEFT FLOOR *)
	 XK_underbar* = 00BC6H;  (*(U+005F LOW LINE)*)
	 XK_jot* = 00BCAH;  (* U+2218 RING OPERATOR *)
	 XK_quad* = 00BCCH;  (* U+2395 APL FUNCTIONAL SYMBOL QUAD *)
	 XK_uptack* = 00BCEH;  (* U+22A5 UP TACK *)
	 XK_circle* = 00BCFH;  (* U+25CB WHITE CIRCLE *)
	 XK_upstile* = 00BD3H;  (* U+2308 LEFT CEILING *)
	 XK_downshoe* = 00BD6H;  (*(U+222A UNION)*)
	 XK_rightshoe* = 00BD8H;  (*(U+2283 SUPERSET OF)*)
	 XK_leftshoe* = 00BDAH;  (*(U+2282 SUBSET OF)*)
	 XK_lefttack* = 00BDCH;  (* U+22A3 LEFT TACK *)
	 XK_righttack* = 00BFCH;  (* U+22A2 RIGHT TACK *)
	(* #endif *) (* XK_APL *)

	(*
	 * Hebrew
	 * Byte 3* = 0x0c
	 *)

	(* #ifdef XK_HEBREW *)
	 XK_hebrew_doublelowline* = 00CDFH;  (* U+2017 DOUBLE LOW LINE *)
	 XK_hebrew_aleph* = 00CE0H;  (* U+05D0 HEBREW LETTER ALEF *)
	 XK_hebrew_bet* = 00CE1H;  (* U+05D1 HEBREW LETTER BET *)
	 XK_hebrew_beth* = 00CE1H;  (* deprecated *)
	 XK_hebrew_gimel* = 00CE2H;  (* U+05D2 HEBREW LETTER GIMEL *)
	 XK_hebrew_gimmel* = 00CE2H;  (* deprecated *)
	 XK_hebrew_dalet* = 00CE3H;  (* U+05D3 HEBREW LETTER DALET *)
	 XK_hebrew_daleth* = 00CE3H;  (* deprecated *)
	 XK_hebrew_he* = 00CE4H;  (* U+05D4 HEBREW LETTER HE *)
	 XK_hebrew_waw* = 00CE5H;  (* U+05D5 HEBREW LETTER VAV *)
	 XK_hebrew_zain* = 00CE6H;  (* U+05D6 HEBREW LETTER ZAYIN *)
	 XK_hebrew_zayin* = 00CE6H;  (* deprecated *)
	 XK_hebrew_chet* = 00CE7H;  (* U+05D7 HEBREW LETTER HET *)
	 XK_hebrew_het* = 00CE7H;  (* deprecated *)
	 XK_hebrew_tet* = 00CE8H;  (* U+05D8 HEBREW LETTER TET *)
	 XK_hebrew_teth* = 00CE8H;  (* deprecated *)
	 XK_hebrew_yod* = 00CE9H;  (* U+05D9 HEBREW LETTER YOD *)
	 XK_hebrew_finalkaph* = 00CEAH;  (* U+05DA HEBREW LETTER FINAL KAF *)
	 XK_hebrew_kaph* = 00CEBH;  (* U+05DB HEBREW LETTER KAF *)
	 XK_hebrew_lamed* = 00CECH;  (* U+05DC HEBREW LETTER LAMED *)
	 XK_hebrew_finalmem* = 00CEDH;  (* U+05DD HEBREW LETTER FINAL MEM *)
	 XK_hebrew_mem* = 00CEEH;  (* U+05DE HEBREW LETTER MEM *)
	 XK_hebrew_finalnun* = 00CEFH;  (* U+05DF HEBREW LETTER FINAL NUN *)
	 XK_hebrew_nun* = 00CF0H;  (* U+05E0 HEBREW LETTER NUN *)
	 XK_hebrew_samech* = 00CF1H;  (* U+05E1 HEBREW LETTER SAMEKH *)
	 XK_hebrew_samekh* = 00CF1H;  (* deprecated *)
	 XK_hebrew_ayin* = 00CF2H;  (* U+05E2 HEBREW LETTER AYIN *)
	 XK_hebrew_finalpe* = 00CF3H;  (* U+05E3 HEBREW LETTER FINAL PE *)
	 XK_hebrew_pe* = 00CF4H;  (* U+05E4 HEBREW LETTER PE *)
	 XK_hebrew_finalzade* = 00CF5H;  (* U+05E5 HEBREW LETTER FINAL TSADI *)
	 XK_hebrew_finalzadi* = 00CF5H;  (* deprecated *)
	 XK_hebrew_zade* = 00CF6H;  (* U+05E6 HEBREW LETTER TSADI *)
	 XK_hebrew_zadi* = 00CF6H;  (* deprecated *)
	 XK_hebrew_qoph* = 00CF7H;  (* U+05E7 HEBREW LETTER QOF *)
	 XK_hebrew_kuf* = 00CF7H;  (* deprecated *)
	 XK_hebrew_resh* = 00CF8H;  (* U+05E8 HEBREW LETTER RESH *)
	 XK_hebrew_shin* = 00CF9H;  (* U+05E9 HEBREW LETTER SHIN *)
	 XK_hebrew_taw* = 00CFAH;  (* U+05EA HEBREW LETTER TAV *)
	 XK_hebrew_taf* = 00CFAH;  (* deprecated *)
	 XK_Hebrew_switch* = 0FF7EH;  (* Alias for mode_switch *)
	(* #endif *) (* XK_HEBREW *)

	(*
	 * Thai
	 * Byte 3* = 0x0d
	 *)

	(* #ifdef XK_THAI *)
	 XK_Thai_kokai* = 00DA1H;  (* U+0E01 THAI CHARACTER KO KAI *)
	 XK_Thai_khokhai* = 00DA2H;  (* U+0E02 THAI CHARACTER KHO KHAI *)
	 XK_Thai_khokhuat* = 00DA3H;  (* U+0E03 THAI CHARACTER KHO KHUAT *)
	 XK_Thai_khokhwai* = 00DA4H;  (* U+0E04 THAI CHARACTER KHO KHWAI *)
	 XK_Thai_khokhon* = 00DA5H;  (* U+0E05 THAI CHARACTER KHO KHON *)
	 XK_Thai_khorakhang* = 00DA6H;  (* U+0E06 THAI CHARACTER KHO RAKHANG *)
	 XK_Thai_ngongu* = 00DA7H;  (* U+0E07 THAI CHARACTER NGO NGU *)
	 XK_Thai_chochan* = 00DA8H;  (* U+0E08 THAI CHARACTER CHO CHAN *)
	 XK_Thai_choching* = 00DA9H;  (* U+0E09 THAI CHARACTER CHO CHING *)
	 XK_Thai_chochang* = 00DAAH;  (* U+0E0A THAI CHARACTER CHO CHANG *)
	 XK_Thai_soso* = 00DABH;  (* U+0E0B THAI CHARACTER SO SO *)
	 XK_Thai_chochoe* = 00DACH;  (* U+0E0C THAI CHARACTER CHO CHOE *)
	 XK_Thai_yoying* = 00DADH;  (* U+0E0D THAI CHARACTER YO YING *)
	 XK_Thai_dochada* = 00DAEH;  (* U+0E0E THAI CHARACTER DO CHADA *)
	 XK_Thai_topatak* = 00DAFH;  (* U+0E0F THAI CHARACTER TO PATAK *)
	 XK_Thai_thothan* = 00DB0H;  (* U+0E10 THAI CHARACTER THO THAN *)
	 XK_Thai_thonangmontho* = 00DB1H;  (* U+0E11 THAI CHARACTER THO NANGMONTHO *)
	 XK_Thai_thophuthao* = 00DB2H;  (* U+0E12 THAI CHARACTER THO PHUTHAO *)
	 XK_Thai_nonen* = 00DB3H;  (* U+0E13 THAI CHARACTER NO NEN *)
	 XK_Thai_dodek* = 00DB4H;  (* U+0E14 THAI CHARACTER DO DEK *)
	 XK_Thai_totao* = 00DB5H;  (* U+0E15 THAI CHARACTER TO TAO *)
	 XK_Thai_thothung* = 00DB6H;  (* U+0E16 THAI CHARACTER THO THUNG *)
	 XK_Thai_thothahan* = 00DB7H;  (* U+0E17 THAI CHARACTER THO THAHAN *)
	 XK_Thai_thothong* = 00DB8H;  (* U+0E18 THAI CHARACTER THO THONG *)
	 XK_Thai_nonu* = 00DB9H;  (* U+0E19 THAI CHARACTER NO NU *)
	 XK_Thai_bobaimai* = 00DBAH;  (* U+0E1A THAI CHARACTER BO BAIMAI *)
	 XK_Thai_popla* = 00DBBH;  (* U+0E1B THAI CHARACTER PO PLA *)
	 XK_Thai_phophung* = 00DBCH;  (* U+0E1C THAI CHARACTER PHO PHUNG *)
	 XK_Thai_fofa* = 00DBDH;  (* U+0E1D THAI CHARACTER FO FA *)
	 XK_Thai_phophan* = 00DBEH;  (* U+0E1E THAI CHARACTER PHO PHAN *)
	 XK_Thai_fofan* = 00DBFH;  (* U+0E1F THAI CHARACTER FO FAN *)
	 XK_Thai_phosamphao* = 00DC0H;  (* U+0E20 THAI CHARACTER PHO SAMPHAO *)
	 XK_Thai_moma* = 00DC1H;  (* U+0E21 THAI CHARACTER MO MA *)
	 XK_Thai_yoyak* = 00DC2H;  (* U+0E22 THAI CHARACTER YO YAK *)
	 XK_Thai_rorua* = 00DC3H;  (* U+0E23 THAI CHARACTER RO RUA *)
	 XK_Thai_ru* = 00DC4H;  (* U+0E24 THAI CHARACTER RU *)
	 XK_Thai_loling* = 00DC5H;  (* U+0E25 THAI CHARACTER LO LING *)
	 XK_Thai_lu* = 00DC6H;  (* U+0E26 THAI CHARACTER LU *)
	 XK_Thai_wowaen* = 00DC7H;  (* U+0E27 THAI CHARACTER WO WAEN *)
	 XK_Thai_sosala* = 00DC8H;  (* U+0E28 THAI CHARACTER SO SALA *)
	 XK_Thai_sorusi* = 00DC9H;  (* U+0E29 THAI CHARACTER SO RUSI *)
	 XK_Thai_sosua* = 00DCAH;  (* U+0E2A THAI CHARACTER SO SUA *)
	 XK_Thai_hohip* = 00DCBH;  (* U+0E2B THAI CHARACTER HO HIP *)
	 XK_Thai_lochula* = 00DCCH;  (* U+0E2C THAI CHARACTER LO CHULA *)
	 XK_Thai_oang* = 00DCDH;  (* U+0E2D THAI CHARACTER O ANG *)
	 XK_Thai_honokhuk* = 00DCEH;  (* U+0E2E THAI CHARACTER HO NOKHUK *)
	 XK_Thai_paiyannoi* = 00DCFH;  (* U+0E2F THAI CHARACTER PAIYANNOI *)
	 XK_Thai_saraa* = 00DD0H;  (* U+0E30 THAI CHARACTER SARA A *)
	 XK_Thai_maihanakat* = 00DD1H;  (* U+0E31 THAI CHARACTER MAI HAN-AKAT *)
	 XK_Thai_saraaa* = 00DD2H;  (* U+0E32 THAI CHARACTER SARA AA *)
	 XK_Thai_saraam* = 00DD3H;  (* U+0E33 THAI CHARACTER SARA AM *)
	 XK_Thai_sarai* = 00DD4H;  (* U+0E34 THAI CHARACTER SARA I *)
	 XK_Thai_saraii* = 00DD5H;  (* U+0E35 THAI CHARACTER SARA II *)
	 XK_Thai_saraue* = 00DD6H;  (* U+0E36 THAI CHARACTER SARA UE *)
	 XK_Thai_sarauee* = 00DD7H;  (* U+0E37 THAI CHARACTER SARA UEE *)
	 XK_Thai_sarau* = 00DD8H;  (* U+0E38 THAI CHARACTER SARA U *)
	 XK_Thai_sarauu* = 00DD9H;  (* U+0E39 THAI CHARACTER SARA UU *)
	 XK_Thai_phinthu* = 00DDAH;  (* U+0E3A THAI CHARACTER PHINTHU *)
	 XK_Thai_maihanakat_maitho* = 00DDEH;
	 XK_Thai_baht* = 00DDFH;  (* U+0E3F THAI CURRENCY SYMBOL BAHT *)
	 XK_Thai_sarae* = 00DE0H;  (* U+0E40 THAI CHARACTER SARA E *)
	 XK_Thai_saraae* = 00DE1H;  (* U+0E41 THAI CHARACTER SARA AE *)
	 XK_Thai_sarao* = 00DE2H;  (* U+0E42 THAI CHARACTER SARA O *)
	 XK_Thai_saraaimaimuan* = 00DE3H;  (* U+0E43 THAI CHARACTER SARA AI MAIMUAN *)
	 XK_Thai_saraaimaimalai* = 00DE4H;  (* U+0E44 THAI CHARACTER SARA AI MAIMALAI *)
	 XK_Thai_lakkhangyao* = 00DE5H;  (* U+0E45 THAI CHARACTER LAKKHANGYAO *)
	 XK_Thai_maiyamok* = 00DE6H;  (* U+0E46 THAI CHARACTER MAIYAMOK *)
	 XK_Thai_maitaikhu* = 00DE7H;  (* U+0E47 THAI CHARACTER MAITAIKHU *)
	 XK_Thai_maiek* = 00DE8H;  (* U+0E48 THAI CHARACTER MAI EK *)
	 XK_Thai_maitho* = 00DE9H;  (* U+0E49 THAI CHARACTER MAI THO *)
	 XK_Thai_maitri* = 00DEAH;  (* U+0E4A THAI CHARACTER MAI TRI *)
	 XK_Thai_maichattawa* = 00DEBH;  (* U+0E4B THAI CHARACTER MAI CHATTAWA *)
	 XK_Thai_thanthakhat* = 00DECH;  (* U+0E4C THAI CHARACTER THANTHAKHAT *)
	 XK_Thai_nikhahit* = 00DEDH;  (* U+0E4D THAI CHARACTER NIKHAHIT *)
	 XK_Thai_leksun* = 00DF0H;  (* U+0E50 THAI DIGIT ZERO *)
	 XK_Thai_leknung* = 00DF1H;  (* U+0E51 THAI DIGIT ONE *)
	 XK_Thai_leksong* = 00DF2H;  (* U+0E52 THAI DIGIT TWO *)
	 XK_Thai_leksam* = 00DF3H;  (* U+0E53 THAI DIGIT THREE *)
	 XK_Thai_leksi* = 00DF4H;  (* U+0E54 THAI DIGIT FOUR *)
	 XK_Thai_lekha* = 00DF5H;  (* U+0E55 THAI DIGIT FIVE *)
	 XK_Thai_lekhok* = 00DF6H;  (* U+0E56 THAI DIGIT SIX *)
	 XK_Thai_lekchet* = 00DF7H;  (* U+0E57 THAI DIGIT SEVEN *)
	 XK_Thai_lekpaet* = 00DF8H;  (* U+0E58 THAI DIGIT EIGHT *)
	 XK_Thai_lekkao* = 00DF9H;  (* U+0E59 THAI DIGIT NINE *)
	(* #endif *) (* XK_THAI *)

	(*
	 * Korean
	 * Byte 3* = 0x0e
	 *)

	(* #ifdef XK_KOREAN *)

	 XK_Hangul* = 0FF31H;  (* Hangul start/stop(toggle) *)
	 XK_Hangul_Start* = 0FF32H;  (* Hangul start *)
	 XK_Hangul_End* = 0FF33H;  (* Hangul end, English start *)
	 XK_Hangul_Hanja* = 0FF34H;  (* Start Hangul->Hanja Conversion *)
	 XK_Hangul_Jamo* = 0FF35H;  (* Hangul Jamo mode *)
	 XK_Hangul_Romaja* = 0FF36H;  (* Hangul Romaja mode *)
	 XK_Hangul_Codeinput* = 0FF37H;  (* Hangul code input mode *)
	 XK_Hangul_Jeonja* = 0FF38H;  (* Jeonja mode *)
	 XK_Hangul_Banja* = 0FF39H;  (* Banja mode *)
	 XK_Hangul_PreHanja* = 0FF3AH;  (* Pre Hanja conversion *)
	 XK_Hangul_PostHanja* = 0FF3BH;  (* Post Hanja conversion *)
	 XK_Hangul_SingleCandidate* = 0FF3CH;  (* Single candidate *)
	 XK_Hangul_MultipleCandidate* = 0FF3DH;  (* Multiple candidate *)
	 XK_Hangul_PreviousCandidate* = 0FF3EH;  (* Previous candidate *)
	 XK_Hangul_Special* = 0FF3FH;  (* Special symbols *)
	 XK_Hangul_switch* = 0FF7EH;  (* Alias for mode_switch *)

	(* Hangul Consonant Characters *)
	 XK_Hangul_Kiyeog* = 00EA1H;
	 XK_Hangul_SsangKiyeog* = 00EA2H;
	 XK_Hangul_KiyeogSios* = 00EA3H;
	 XK_Hangul_Nieun* = 00EA4H;
	 XK_Hangul_NieunJieuj* = 00EA5H;
	 XK_Hangul_NieunHieuh* = 00EA6H;
	 XK_Hangul_Dikeud* = 00EA7H;
	 XK_Hangul_SsangDikeud* = 00EA8H;
	 XK_Hangul_Rieul* = 00EA9H;
	 XK_Hangul_RieulKiyeog* = 00EAAH;
	 XK_Hangul_RieulMieum* = 00EABH;
	 XK_Hangul_RieulPieub* = 00EACH;
	 XK_Hangul_RieulSios* = 00EADH;
	 XK_Hangul_RieulTieut* = 00EAEH;
	 XK_Hangul_RieulPhieuf* = 00EAFH;
	 XK_Hangul_RieulHieuh* = 00EB0H;
	 XK_Hangul_Mieum* = 00EB1H;
	 XK_Hangul_Pieub* = 00EB2H;
	 XK_Hangul_SsangPieub* = 00EB3H;
	 XK_Hangul_PieubSios* = 00EB4H;
	 XK_Hangul_Sios* = 00EB5H;
	 XK_Hangul_SsangSios* = 00EB6H;
	 XK_Hangul_Ieung* = 00EB7H;
	 XK_Hangul_Jieuj* = 00EB8H;
	 XK_Hangul_SsangJieuj* = 00EB9H;
	 XK_Hangul_Cieuc* = 00EBAH;
	 XK_Hangul_Khieuq* = 00EBBH;
	 XK_Hangul_Tieut* = 00EBCH;
	 XK_Hangul_Phieuf* = 00EBDH;
	 XK_Hangul_Hieuh* = 00EBEH;

	(* Hangul Vowel Characters *)
	 XK_Hangul_A* = 00EBFH;
	 XK_Hangul_AE* = 00EC0H;
	 XK_Hangul_YA* = 00EC1H;
	 XK_Hangul_YAE* = 00EC2H;
	 XK_Hangul_EO* = 00EC3H;
	 XK_Hangul_E* = 00EC4H;
	 XK_Hangul_YEO* = 00EC5H;
	 XK_Hangul_YE* = 00EC6H;
	 XK_Hangul_O* = 00EC7H;
	 XK_Hangul_WA* = 00EC8H;
	 XK_Hangul_WAE* = 00EC9H;
	 XK_Hangul_OE* = 00ECAH;
	 XK_Hangul_YO* = 00ECBH;
	 XK_Hangul_U* = 00ECCH;
	 XK_Hangul_WEO* = 00ECDH;
	 XK_Hangul_WE* = 00ECEH;
	 XK_Hangul_WI* = 00ECFH;
	 XK_Hangul_YU* = 00ED0H;
	 XK_Hangul_EU* = 00ED1H;
	 XK_Hangul_YI* = 00ED2H;
	 XK_Hangul_I* = 00ED3H;

	(* Hangul syllable-final (JongSeong) Characters *)
	 XK_Hangul_J_Kiyeog* = 00ED4H;
	 XK_Hangul_J_SsangKiyeog* = 00ED5H;
	 XK_Hangul_J_KiyeogSios* = 00ED6H;
	 XK_Hangul_J_Nieun* = 00ED7H;
	 XK_Hangul_J_NieunJieuj* = 00ED8H;
	 XK_Hangul_J_NieunHieuh* = 00ED9H;
	 XK_Hangul_J_Dikeud* = 00EDAH;
	 XK_Hangul_J_Rieul* = 00EDBH;
	 XK_Hangul_J_RieulKiyeog* = 00EDCH;
	 XK_Hangul_J_RieulMieum* = 00EDDH;
	 XK_Hangul_J_RieulPieub* = 00EDEH;
	 XK_Hangul_J_RieulSios* = 00EDFH;
	 XK_Hangul_J_RieulTieut* = 00EE0H;
	 XK_Hangul_J_RieulPhieuf* = 00EE1H;
	 XK_Hangul_J_RieulHieuh* = 00EE2H;
	 XK_Hangul_J_Mieum* = 00EE3H;
	 XK_Hangul_J_Pieub* = 00EE4H;
	 XK_Hangul_J_PieubSios* = 00EE5H;
	 XK_Hangul_J_Sios* = 00EE6H;
	 XK_Hangul_J_SsangSios* = 00EE7H;
	 XK_Hangul_J_Ieung* = 00EE8H;
	 XK_Hangul_J_Jieuj* = 00EE9H;
	 XK_Hangul_J_Cieuc* = 00EEAH;
	 XK_Hangul_J_Khieuq* = 00EEBH;
	 XK_Hangul_J_Tieut* = 00EECH;
	 XK_Hangul_J_Phieuf* = 00EEDH;
	 XK_Hangul_J_Hieuh* = 00EEEH;

	(* Ancient Hangul Consonant Characters *)
	 XK_Hangul_RieulYeorinHieuh* = 00EEFH;
	 XK_Hangul_SunkyeongeumMieum* = 00EF0H;
	 XK_Hangul_SunkyeongeumPieub* = 00EF1H;
	 XK_Hangul_PanSios* = 00EF2H;
	 XK_Hangul_KkogjiDalrinIeung* = 00EF3H;
	 XK_Hangul_SunkyeongeumPhieuf* = 00EF4H;
	 XK_Hangul_YeorinHieuh* = 00EF5H;

	(* Ancient Hangul Vowel Characters *)
	 XK_Hangul_AraeA* = 00EF6H;
	 XK_Hangul_AraeAE* = 00EF7H;

	(* Ancient Hangul syllable-final (JongSeong) Characters *)
	 XK_Hangul_J_PanSios* = 00EF8H;
	 XK_Hangul_J_KkogjiDalrinIeung* = 00EF9H;
	 XK_Hangul_J_YeorinHieuh* = 00EFAH;

	(* Korean currency symbol *)
	 XK_Korean_Won* = 00EFFH;  (*(U+20A9 WON SIGN)*)

	(* #endif *) (* XK_KOREAN *)

	(*
	 * Armenian
	 *)

	(* #ifdef XK_ARMENIAN *)
	 XK_Armenian_ligature_ew* = 01000587H;  (* U+0587 ARMENIAN SMALL LIGATURE ECH YIWN *)
	 XK_Armenian_full_stop* = 01000589H;  (* U+0589 ARMENIAN FULL STOP *)
	 XK_Armenian_verjaket* = 01000589H;  (* U+0589 ARMENIAN FULL STOP *)
	 XK_Armenian_separation_mark* = 0100055DH;  (* U+055D ARMENIAN COMMA *)
	 XK_Armenian_but* = 0100055DH;  (* U+055D ARMENIAN COMMA *)
	 XK_Armenian_hyphen* = 0100058AH;  (* U+058A ARMENIAN HYPHEN *)
	 XK_Armenian_yentamna* = 0100058AH;  (* U+058A ARMENIAN HYPHEN *)
	 XK_Armenian_exclam* = 0100055CH;  (* U+055C ARMENIAN EXCLAMATION MARK *)
	 XK_Armenian_amanak* = 0100055CH;  (* U+055C ARMENIAN EXCLAMATION MARK *)
	 XK_Armenian_accent* = 0100055BH;  (* U+055B ARMENIAN EMPHASIS MARK *)
	 XK_Armenian_shesht* = 0100055BH;  (* U+055B ARMENIAN EMPHASIS MARK *)
	 XK_Armenian_question* = 0100055EH;  (* U+055E ARMENIAN QUESTION MARK *)
	 XK_Armenian_paruyk* = 0100055EH;  (* U+055E ARMENIAN QUESTION MARK *)
	 XK_Armenian_AYB* = 01000531H;  (* U+0531 ARMENIAN CAPITAL LETTER AYB *)
	 XK_Armenian_ayb* = 01000561H;  (* U+0561 ARMENIAN SMALL LETTER AYB *)
	 XK_Armenian_BEN* = 01000532H;  (* U+0532 ARMENIAN CAPITAL LETTER BEN *)
	 XK_Armenian_ben* = 01000562H;  (* U+0562 ARMENIAN SMALL LETTER BEN *)
	 XK_Armenian_GIM* = 01000533H;  (* U+0533 ARMENIAN CAPITAL LETTER GIM *)
	 XK_Armenian_gim* = 01000563H;  (* U+0563 ARMENIAN SMALL LETTER GIM *)
	 XK_Armenian_DA* = 01000534H;  (* U+0534 ARMENIAN CAPITAL LETTER DA *)
	 XK_Armenian_da* = 01000564H;  (* U+0564 ARMENIAN SMALL LETTER DA *)
	 XK_Armenian_YECH* = 01000535H;  (* U+0535 ARMENIAN CAPITAL LETTER ECH *)
	 XK_Armenian_yech* = 01000565H;  (* U+0565 ARMENIAN SMALL LETTER ECH *)
	 XK_Armenian_ZA* = 01000536H;  (* U+0536 ARMENIAN CAPITAL LETTER ZA *)
	 XK_Armenian_za* = 01000566H;  (* U+0566 ARMENIAN SMALL LETTER ZA *)
	 XK_Armenian_E* = 01000537H;  (* U+0537 ARMENIAN CAPITAL LETTER EH *)
	 XK_Armenian_e* = 01000567H;  (* U+0567 ARMENIAN SMALL LETTER EH *)
	 XK_Armenian_AT* = 01000538H;  (* U+0538 ARMENIAN CAPITAL LETTER ET *)
	 XK_Armenian_at* = 01000568H;  (* U+0568 ARMENIAN SMALL LETTER ET *)
	 XK_Armenian_TO* = 01000539H;  (* U+0539 ARMENIAN CAPITAL LETTER TO *)
	 XK_Armenian_to* = 01000569H;  (* U+0569 ARMENIAN SMALL LETTER TO *)
	 XK_Armenian_ZHE* = 0100053AH;  (* U+053A ARMENIAN CAPITAL LETTER ZHE *)
	 XK_Armenian_zhe* = 0100056AH;  (* U+056A ARMENIAN SMALL LETTER ZHE *)
	 XK_Armenian_INI* = 0100053BH;  (* U+053B ARMENIAN CAPITAL LETTER INI *)
	 XK_Armenian_ini* = 0100056BH;  (* U+056B ARMENIAN SMALL LETTER INI *)
	 XK_Armenian_LYUN* = 0100053CH;  (* U+053C ARMENIAN CAPITAL LETTER LIWN *)
	 XK_Armenian_lyun* = 0100056CH;  (* U+056C ARMENIAN SMALL LETTER LIWN *)
	 XK_Armenian_KHE* = 0100053DH;  (* U+053D ARMENIAN CAPITAL LETTER XEH *)
	 XK_Armenian_khe* = 0100056DH;  (* U+056D ARMENIAN SMALL LETTER XEH *)
	 XK_Armenian_TSA* = 0100053EH;  (* U+053E ARMENIAN CAPITAL LETTER CA *)
	 XK_Armenian_tsa* = 0100056EH;  (* U+056E ARMENIAN SMALL LETTER CA *)
	 XK_Armenian_KEN* = 0100053FH;  (* U+053F ARMENIAN CAPITAL LETTER KEN *)
	 XK_Armenian_ken* = 0100056FH;  (* U+056F ARMENIAN SMALL LETTER KEN *)
	 XK_Armenian_HO* = 01000540H;  (* U+0540 ARMENIAN CAPITAL LETTER HO *)
	 XK_Armenian_ho* = 01000570H;  (* U+0570 ARMENIAN SMALL LETTER HO *)
	 XK_Armenian_DZA* = 01000541H;  (* U+0541 ARMENIAN CAPITAL LETTER JA *)
	 XK_Armenian_dza* = 01000571H;  (* U+0571 ARMENIAN SMALL LETTER JA *)
	 XK_Armenian_GHAT* = 01000542H;  (* U+0542 ARMENIAN CAPITAL LETTER GHAD *)
	 XK_Armenian_ghat* = 01000572H;  (* U+0572 ARMENIAN SMALL LETTER GHAD *)
	 XK_Armenian_TCHE* = 01000543H;  (* U+0543 ARMENIAN CAPITAL LETTER CHEH *)
	 XK_Armenian_tche* = 01000573H;  (* U+0573 ARMENIAN SMALL LETTER CHEH *)
	 XK_Armenian_MEN* = 01000544H;  (* U+0544 ARMENIAN CAPITAL LETTER MEN *)
	 XK_Armenian_men* = 01000574H;  (* U+0574 ARMENIAN SMALL LETTER MEN *)
	 XK_Armenian_HI* = 01000545H;  (* U+0545 ARMENIAN CAPITAL LETTER YI *)
	 XK_Armenian_hi* = 01000575H;  (* U+0575 ARMENIAN SMALL LETTER YI *)
	 XK_Armenian_NU* = 01000546H;  (* U+0546 ARMENIAN CAPITAL LETTER NOW *)
	 XK_Armenian_nu* = 01000576H;  (* U+0576 ARMENIAN SMALL LETTER NOW *)
	 XK_Armenian_SHA* = 01000547H;  (* U+0547 ARMENIAN CAPITAL LETTER SHA *)
	 XK_Armenian_sha* = 01000577H;  (* U+0577 ARMENIAN SMALL LETTER SHA *)
	 XK_Armenian_VO* = 01000548H;  (* U+0548 ARMENIAN CAPITAL LETTER VO *)
	 XK_Armenian_vo* = 01000578H;  (* U+0578 ARMENIAN SMALL LETTER VO *)
	 XK_Armenian_CHA* = 01000549H;  (* U+0549 ARMENIAN CAPITAL LETTER CHA *)
	 XK_Armenian_cha* = 01000579H;  (* U+0579 ARMENIAN SMALL LETTER CHA *)
	 XK_Armenian_PE* = 0100054AH;  (* U+054A ARMENIAN CAPITAL LETTER PEH *)
	 XK_Armenian_pe* = 0100057AH;  (* U+057A ARMENIAN SMALL LETTER PEH *)
	 XK_Armenian_JE* = 0100054BH;  (* U+054B ARMENIAN CAPITAL LETTER JHEH *)
	 XK_Armenian_je* = 0100057BH;  (* U+057B ARMENIAN SMALL LETTER JHEH *)
	 XK_Armenian_RA* = 0100054CH;  (* U+054C ARMENIAN CAPITAL LETTER RA *)
	 XK_Armenian_ra* = 0100057CH;  (* U+057C ARMENIAN SMALL LETTER RA *)
	 XK_Armenian_SE* = 0100054DH;  (* U+054D ARMENIAN CAPITAL LETTER SEH *)
	 XK_Armenian_se* = 0100057DH;  (* U+057D ARMENIAN SMALL LETTER SEH *)
	 XK_Armenian_VEV* = 0100054EH;  (* U+054E ARMENIAN CAPITAL LETTER VEW *)
	 XK_Armenian_vev* = 0100057EH;  (* U+057E ARMENIAN SMALL LETTER VEW *)
	 XK_Armenian_TYUN* = 0100054FH;  (* U+054F ARMENIAN CAPITAL LETTER TIWN *)
	 XK_Armenian_tyun* = 0100057FH;  (* U+057F ARMENIAN SMALL LETTER TIWN *)
	 XK_Armenian_RE* = 01000550H;  (* U+0550 ARMENIAN CAPITAL LETTER REH *)
	 XK_Armenian_re* = 01000580H;  (* U+0580 ARMENIAN SMALL LETTER REH *)
	 XK_Armenian_TSO* = 01000551H;  (* U+0551 ARMENIAN CAPITAL LETTER CO *)
	 XK_Armenian_tso* = 01000581H;  (* U+0581 ARMENIAN SMALL LETTER CO *)
	 XK_Armenian_VYUN* = 01000552H;  (* U+0552 ARMENIAN CAPITAL LETTER YIWN *)
	 XK_Armenian_vyun* = 01000582H;  (* U+0582 ARMENIAN SMALL LETTER YIWN *)
	 XK_Armenian_PYUR* = 01000553H;  (* U+0553 ARMENIAN CAPITAL LETTER PIWR *)
	 XK_Armenian_pyur* = 01000583H;  (* U+0583 ARMENIAN SMALL LETTER PIWR *)
	 XK_Armenian_KE* = 01000554H;  (* U+0554 ARMENIAN CAPITAL LETTER KEH *)
	 XK_Armenian_ke* = 01000584H;  (* U+0584 ARMENIAN SMALL LETTER KEH *)
	 XK_Armenian_O* = 01000555H;  (* U+0555 ARMENIAN CAPITAL LETTER OH *)
	 XK_Armenian_o* = 01000585H;  (* U+0585 ARMENIAN SMALL LETTER OH *)
	 XK_Armenian_FE* = 01000556H;  (* U+0556 ARMENIAN CAPITAL LETTER FEH *)
	 XK_Armenian_fe* = 01000586H;  (* U+0586 ARMENIAN SMALL LETTER FEH *)
	 XK_Armenian_apostrophe* = 0100055AH;  (* U+055A ARMENIAN APOSTROPHE *)
	(* #endif *) (* XK_ARMENIAN *)

	(*
	 * Georgian
	 *)

	(* #ifdef XK_GEORGIAN *)
	 XK_Georgian_an* = 010010D0H;  (* U+10D0 GEORGIAN LETTER AN *)
	 XK_Georgian_ban* = 010010D1H;  (* U+10D1 GEORGIAN LETTER BAN *)
	 XK_Georgian_gan* = 010010D2H;  (* U+10D2 GEORGIAN LETTER GAN *)
	 XK_Georgian_don* = 010010D3H;  (* U+10D3 GEORGIAN LETTER DON *)
	 XK_Georgian_en* = 010010D4H;  (* U+10D4 GEORGIAN LETTER EN *)
	 XK_Georgian_vin* = 010010D5H;  (* U+10D5 GEORGIAN LETTER VIN *)
	 XK_Georgian_zen* = 010010D6H;  (* U+10D6 GEORGIAN LETTER ZEN *)
	 XK_Georgian_tan* = 010010D7H;  (* U+10D7 GEORGIAN LETTER TAN *)
	 XK_Georgian_in* = 010010D8H;  (* U+10D8 GEORGIAN LETTER IN *)
	 XK_Georgian_kan* = 010010D9H;  (* U+10D9 GEORGIAN LETTER KAN *)
	 XK_Georgian_las* = 010010DAH;  (* U+10DA GEORGIAN LETTER LAS *)
	 XK_Georgian_man* = 010010DBH;  (* U+10DB GEORGIAN LETTER MAN *)
	 XK_Georgian_nar* = 010010DCH;  (* U+10DC GEORGIAN LETTER NAR *)
	 XK_Georgian_on* = 010010DDH;  (* U+10DD GEORGIAN LETTER ON *)
	 XK_Georgian_par* = 010010DEH;  (* U+10DE GEORGIAN LETTER PAR *)
	 XK_Georgian_zhar* = 010010DFH;  (* U+10DF GEORGIAN LETTER ZHAR *)
	 XK_Georgian_rae* = 010010E0H;  (* U+10E0 GEORGIAN LETTER RAE *)
	 XK_Georgian_san* = 010010E1H;  (* U+10E1 GEORGIAN LETTER SAN *)
	 XK_Georgian_tar* = 010010E2H;  (* U+10E2 GEORGIAN LETTER TAR *)
	 XK_Georgian_un* = 010010E3H;  (* U+10E3 GEORGIAN LETTER UN *)
	 XK_Georgian_phar* = 010010E4H;  (* U+10E4 GEORGIAN LETTER PHAR *)
	 XK_Georgian_khar* = 010010E5H;  (* U+10E5 GEORGIAN LETTER KHAR *)
	 XK_Georgian_ghan* = 010010E6H;  (* U+10E6 GEORGIAN LETTER GHAN *)
	 XK_Georgian_qar* = 010010E7H;  (* U+10E7 GEORGIAN LETTER QAR *)
	 XK_Georgian_shin* = 010010E8H;  (* U+10E8 GEORGIAN LETTER SHIN *)
	 XK_Georgian_chin* = 010010E9H;  (* U+10E9 GEORGIAN LETTER CHIN *)
	 XK_Georgian_can* = 010010EAH;  (* U+10EA GEORGIAN LETTER CAN *)
	 XK_Georgian_jil* = 010010EBH;  (* U+10EB GEORGIAN LETTER JIL *)
	 XK_Georgian_cil* = 010010ECH;  (* U+10EC GEORGIAN LETTER CIL *)
	 XK_Georgian_char* = 010010EDH;  (* U+10ED GEORGIAN LETTER CHAR *)
	 XK_Georgian_xan* = 010010EEH;  (* U+10EE GEORGIAN LETTER XAN *)
	 XK_Georgian_jhan* = 010010EFH;  (* U+10EF GEORGIAN LETTER JHAN *)
	 XK_Georgian_hae* = 010010F0H;  (* U+10F0 GEORGIAN LETTER HAE *)
	 XK_Georgian_he* = 010010F1H;  (* U+10F1 GEORGIAN LETTER HE *)
	 XK_Georgian_hie* = 010010F2H;  (* U+10F2 GEORGIAN LETTER HIE *)
	 XK_Georgian_we* = 010010F3H;  (* U+10F3 GEORGIAN LETTER WE *)
	 XK_Georgian_har* = 010010F4H;  (* U+10F4 GEORGIAN LETTER HAR *)
	 XK_Georgian_hoe* = 010010F5H;  (* U+10F5 GEORGIAN LETTER HOE *)
	 XK_Georgian_fi* = 010010F6H;  (* U+10F6 GEORGIAN LETTER FI *)
	(* #endif *) (* XK_GEORGIAN *)

	(*
	 * Azeri (and other Turkic or Caucasian languages)
	 *)

	(* #ifdef XK_CAUCASUS *)
	(* latin *)
	 XK_Xabovedot* = 01001E8AH;  (* U+1E8A LATIN CAPITAL LETTER X WITH DOT ABOVE *)
	 XK_Ibreve* = 0100012CH;  (* U+012C LATIN CAPITAL LETTER I WITH BREVE *)
	 XK_Zstroke* = 010001B5H;  (* U+01B5 LATIN CAPITAL LETTER Z WITH STROKE *)
	 XK_Gcaron* = 010001E6H;  (* U+01E6 LATIN CAPITAL LETTER G WITH CARON *)
	 XK_Ocaron* = 010001D1H;  (* U+01D2 LATIN CAPITAL LETTER O WITH CARON *)
	 XK_Obarred* = 0100019FH;  (* U+019F LATIN CAPITAL LETTER O WITH MIDDLE TILDE *)
	 XK_xabovedot* = 01001E8BH;  (* U+1E8B LATIN SMALL LETTER X WITH DOT ABOVE *)
	 XK_ibreve* = 0100012DH;  (* U+012D LATIN SMALL LETTER I WITH BREVE *)
	 XK_zstroke* = 010001B6H;  (* U+01B6 LATIN SMALL LETTER Z WITH STROKE *)
	 XK_gcaron* = 010001E7H;  (* U+01E7 LATIN SMALL LETTER G WITH CARON *)
	 XK_ocaron* = 010001D2H;  (* U+01D2 LATIN SMALL LETTER O WITH CARON *)
	 XK_obarred* = 01000275H;  (* U+0275 LATIN SMALL LETTER BARRED O *)
	 XK_SCHWA* = 0100018FH;  (* U+018F LATIN CAPITAL LETTER SCHWA *)
	 XK_schwa* = 01000259H;  (* U+0259 LATIN SMALL LETTER SCHWA *)
	(* those are not really Caucasus *)
	(* For Inupiak *)
	 XK_Lbelowdot* = 01001E36H;  (* U+1E36 LATIN CAPITAL LETTER L WITH DOT BELOW *)
	 XK_lbelowdot* = 01001E37H;  (* U+1E37 LATIN SMALL LETTER L WITH DOT BELOW *)
	(* #endif *) (* XK_CAUCASUS *)

	(*
	 * Vietnamese
	 *)

	(* #ifdef XK_VIETNAMESE *)
	 XK_Abelowdot* = 01001EA0H;  (* U+1EA0 LATIN CAPITAL LETTER A WITH DOT BELOW *)
	 XK_abelowdot* = 01001EA1H;  (* U+1EA1 LATIN SMALL LETTER A WITH DOT BELOW *)
	 XK_Ahook* = 01001EA2H;  (* U+1EA2 LATIN CAPITAL LETTER A WITH HOOK ABOVE *)
	 XK_ahook* = 01001EA3H;  (* U+1EA3 LATIN SMALL LETTER A WITH HOOK ABOVE *)
	 XK_Acircumflexacute* = 01001EA4H;  (* U+1EA4 LATIN CAPITAL LETTER A WITH CIRCUMFLEX AND ACUTE *)
	 XK_acircumflexacute* = 01001EA5H;  (* U+1EA5 LATIN SMALL LETTER A WITH CIRCUMFLEX AND ACUTE *)
	 XK_Acircumflexgrave* = 01001EA6H;  (* U+1EA6 LATIN CAPITAL LETTER A WITH CIRCUMFLEX AND GRAVE *)
	 XK_acircumflexgrave* = 01001EA7H;  (* U+1EA7 LATIN SMALL LETTER A WITH CIRCUMFLEX AND GRAVE *)
	 XK_Acircumflexhook* = 01001EA8H;  (* U+1EA8 LATIN CAPITAL LETTER A WITH CIRCUMFLEX AND HOOK ABOVE *)
	 XK_acircumflexhook* = 01001EA9H;  (* U+1EA9 LATIN SMALL LETTER A WITH CIRCUMFLEX AND HOOK ABOVE *)
	 XK_Acircumflextilde* = 01001EAAH;  (* U+1EAA LATIN CAPITAL LETTER A WITH CIRCUMFLEX AND TILDE *)
	 XK_acircumflextilde* = 01001EABH;  (* U+1EAB LATIN SMALL LETTER A WITH CIRCUMFLEX AND TILDE *)
	 XK_Acircumflexbelowdot* = 01001EACH;  (* U+1EAC LATIN CAPITAL LETTER A WITH CIRCUMFLEX AND DOT BELOW *)
	 XK_acircumflexbelowdot* = 01001EADH;  (* U+1EAD LATIN SMALL LETTER A WITH CIRCUMFLEX AND DOT BELOW *)
	 XK_Abreveacute* = 01001EAEH;  (* U+1EAE LATIN CAPITAL LETTER A WITH BREVE AND ACUTE *)
	 XK_abreveacute* = 01001EAFH;  (* U+1EAF LATIN SMALL LETTER A WITH BREVE AND ACUTE *)
	 XK_Abrevegrave* = 01001EB0H;  (* U+1EB0 LATIN CAPITAL LETTER A WITH BREVE AND GRAVE *)
	 XK_abrevegrave* = 01001EB1H;  (* U+1EB1 LATIN SMALL LETTER A WITH BREVE AND GRAVE *)
	 XK_Abrevehook* = 01001EB2H;  (* U+1EB2 LATIN CAPITAL LETTER A WITH BREVE AND HOOK ABOVE *)
	 XK_abrevehook* = 01001EB3H;  (* U+1EB3 LATIN SMALL LETTER A WITH BREVE AND HOOK ABOVE *)
	 XK_Abrevetilde* = 01001EB4H;  (* U+1EB4 LATIN CAPITAL LETTER A WITH BREVE AND TILDE *)
	 XK_abrevetilde* = 01001EB5H;  (* U+1EB5 LATIN SMALL LETTER A WITH BREVE AND TILDE *)
	 XK_Abrevebelowdot* = 01001EB6H;  (* U+1EB6 LATIN CAPITAL LETTER A WITH BREVE AND DOT BELOW *)
	 XK_abrevebelowdot* = 01001EB7H;  (* U+1EB7 LATIN SMALL LETTER A WITH BREVE AND DOT BELOW *)
	 XK_Ebelowdot* = 01001EB8H;  (* U+1EB8 LATIN CAPITAL LETTER E WITH DOT BELOW *)
	 XK_ebelowdot* = 01001EB9H;  (* U+1EB9 LATIN SMALL LETTER E WITH DOT BELOW *)
	 XK_Ehook* = 01001EBAH;  (* U+1EBA LATIN CAPITAL LETTER E WITH HOOK ABOVE *)
	 XK_ehook* = 01001EBBH;  (* U+1EBB LATIN SMALL LETTER E WITH HOOK ABOVE *)
	 XK_Etilde* = 01001EBCH;  (* U+1EBC LATIN CAPITAL LETTER E WITH TILDE *)
	 XK_etilde* = 01001EBDH;  (* U+1EBD LATIN SMALL LETTER E WITH TILDE *)
	 XK_Ecircumflexacute* = 01001EBEH;  (* U+1EBE LATIN CAPITAL LETTER E WITH CIRCUMFLEX AND ACUTE *)
	 XK_ecircumflexacute* = 01001EBFH;  (* U+1EBF LATIN SMALL LETTER E WITH CIRCUMFLEX AND ACUTE *)
	 XK_Ecircumflexgrave* = 01001EC0H;  (* U+1EC0 LATIN CAPITAL LETTER E WITH CIRCUMFLEX AND GRAVE *)
	 XK_ecircumflexgrave* = 01001EC1H;  (* U+1EC1 LATIN SMALL LETTER E WITH CIRCUMFLEX AND GRAVE *)
	 XK_Ecircumflexhook* = 01001EC2H;  (* U+1EC2 LATIN CAPITAL LETTER E WITH CIRCUMFLEX AND HOOK ABOVE *)
	 XK_ecircumflexhook* = 01001EC3H;  (* U+1EC3 LATIN SMALL LETTER E WITH CIRCUMFLEX AND HOOK ABOVE *)
	 XK_Ecircumflextilde* = 01001EC4H;  (* U+1EC4 LATIN CAPITAL LETTER E WITH CIRCUMFLEX AND TILDE *)
	 XK_ecircumflextilde* = 01001EC5H;  (* U+1EC5 LATIN SMALL LETTER E WITH CIRCUMFLEX AND TILDE *)
	 XK_Ecircumflexbelowdot* = 01001EC6H;  (* U+1EC6 LATIN CAPITAL LETTER E WITH CIRCUMFLEX AND DOT BELOW *)
	 XK_ecircumflexbelowdot* = 01001EC7H;  (* U+1EC7 LATIN SMALL LETTER E WITH CIRCUMFLEX AND DOT BELOW *)
	 XK_Ihook* = 01001EC8H;  (* U+1EC8 LATIN CAPITAL LETTER I WITH HOOK ABOVE *)
	 XK_ihook* = 01001EC9H;  (* U+1EC9 LATIN SMALL LETTER I WITH HOOK ABOVE *)
	 XK_Ibelowdot* = 01001ECAH;  (* U+1ECA LATIN CAPITAL LETTER I WITH DOT BELOW *)
	 XK_ibelowdot* = 01001ECBH;  (* U+1ECB LATIN SMALL LETTER I WITH DOT BELOW *)
	 XK_Obelowdot* = 01001ECCH;  (* U+1ECC LATIN CAPITAL LETTER O WITH DOT BELOW *)
	 XK_obelowdot* = 01001ECDH;  (* U+1ECD LATIN SMALL LETTER O WITH DOT BELOW *)
	 XK_Ohook* = 01001ECEH;  (* U+1ECE LATIN CAPITAL LETTER O WITH HOOK ABOVE *)
	 XK_ohook* = 01001ECFH;  (* U+1ECF LATIN SMALL LETTER O WITH HOOK ABOVE *)
	 XK_Ocircumflexacute* = 01001ED0H;  (* U+1ED0 LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND ACUTE *)
	 XK_ocircumflexacute* = 01001ED1H;  (* U+1ED1 LATIN SMALL LETTER O WITH CIRCUMFLEX AND ACUTE *)
	 XK_Ocircumflexgrave* = 01001ED2H;  (* U+1ED2 LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND GRAVE *)
	 XK_ocircumflexgrave* = 01001ED3H;  (* U+1ED3 LATIN SMALL LETTER O WITH CIRCUMFLEX AND GRAVE *)
	 XK_Ocircumflexhook* = 01001ED4H;  (* U+1ED4 LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND HOOK ABOVE *)
	 XK_ocircumflexhook* = 01001ED5H;  (* U+1ED5 LATIN SMALL LETTER O WITH CIRCUMFLEX AND HOOK ABOVE *)
	 XK_Ocircumflextilde* = 01001ED6H;  (* U+1ED6 LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND TILDE *)
	 XK_ocircumflextilde* = 01001ED7H;  (* U+1ED7 LATIN SMALL LETTER O WITH CIRCUMFLEX AND TILDE *)
	 XK_Ocircumflexbelowdot* = 01001ED8H;  (* U+1ED8 LATIN CAPITAL LETTER O WITH CIRCUMFLEX AND DOT BELOW *)
	 XK_ocircumflexbelowdot* = 01001ED9H;  (* U+1ED9 LATIN SMALL LETTER O WITH CIRCUMFLEX AND DOT BELOW *)
	 XK_Ohornacute* = 01001EDAH;  (* U+1EDA LATIN CAPITAL LETTER O WITH HORN AND ACUTE *)
	 XK_ohornacute* = 01001EDBH;  (* U+1EDB LATIN SMALL LETTER O WITH HORN AND ACUTE *)
	 XK_Ohorngrave* = 01001EDCH;  (* U+1EDC LATIN CAPITAL LETTER O WITH HORN AND GRAVE *)
	 XK_ohorngrave* = 01001EDDH;  (* U+1EDD LATIN SMALL LETTER O WITH HORN AND GRAVE *)
	 XK_Ohornhook* = 01001EDEH;  (* U+1EDE LATIN CAPITAL LETTER O WITH HORN AND HOOK ABOVE *)
	 XK_ohornhook* = 01001EDFH;  (* U+1EDF LATIN SMALL LETTER O WITH HORN AND HOOK ABOVE *)
	 XK_Ohorntilde* = 01001EE0H;  (* U+1EE0 LATIN CAPITAL LETTER O WITH HORN AND TILDE *)
	 XK_ohorntilde* = 01001EE1H;  (* U+1EE1 LATIN SMALL LETTER O WITH HORN AND TILDE *)
	 XK_Ohornbelowdot* = 01001EE2H;  (* U+1EE2 LATIN CAPITAL LETTER O WITH HORN AND DOT BELOW *)
	 XK_ohornbelowdot* = 01001EE3H;  (* U+1EE3 LATIN SMALL LETTER O WITH HORN AND DOT BELOW *)
	 XK_Ubelowdot* = 01001EE4H;  (* U+1EE4 LATIN CAPITAL LETTER U WITH DOT BELOW *)
	 XK_ubelowdot* = 01001EE5H;  (* U+1EE5 LATIN SMALL LETTER U WITH DOT BELOW *)
	 XK_Uhook* = 01001EE6H;  (* U+1EE6 LATIN CAPITAL LETTER U WITH HOOK ABOVE *)
	 XK_uhook* = 01001EE7H;  (* U+1EE7 LATIN SMALL LETTER U WITH HOOK ABOVE *)
	 XK_Uhornacute* = 01001EE8H;  (* U+1EE8 LATIN CAPITAL LETTER U WITH HORN AND ACUTE *)
	 XK_uhornacute* = 01001EE9H;  (* U+1EE9 LATIN SMALL LETTER U WITH HORN AND ACUTE *)
	 XK_Uhorngrave* = 01001EEAH;  (* U+1EEA LATIN CAPITAL LETTER U WITH HORN AND GRAVE *)
	 XK_uhorngrave* = 01001EEBH;  (* U+1EEB LATIN SMALL LETTER U WITH HORN AND GRAVE *)
	 XK_Uhornhook* = 01001EECH;  (* U+1EEC LATIN CAPITAL LETTER U WITH HORN AND HOOK ABOVE *)
	 XK_uhornhook* = 01001EEDH;  (* U+1EED LATIN SMALL LETTER U WITH HORN AND HOOK ABOVE *)
	 XK_Uhorntilde* = 01001EEEH;  (* U+1EEE LATIN CAPITAL LETTER U WITH HORN AND TILDE *)
	 XK_uhorntilde* = 01001EEFH;  (* U+1EEF LATIN SMALL LETTER U WITH HORN AND TILDE *)
	 XK_Uhornbelowdot* = 01001EF0H;  (* U+1EF0 LATIN CAPITAL LETTER U WITH HORN AND DOT BELOW *)
	 XK_uhornbelowdot* = 01001EF1H;  (* U+1EF1 LATIN SMALL LETTER U WITH HORN AND DOT BELOW *)
	 XK_Ybelowdot* = 01001EF4H;  (* U+1EF4 LATIN CAPITAL LETTER Y WITH DOT BELOW *)
	 XK_ybelowdot* = 01001EF5H;  (* U+1EF5 LATIN SMALL LETTER Y WITH DOT BELOW *)
	 XK_Yhook* = 01001EF6H;  (* U+1EF6 LATIN CAPITAL LETTER Y WITH HOOK ABOVE *)
	 XK_yhook* = 01001EF7H;  (* U+1EF7 LATIN SMALL LETTER Y WITH HOOK ABOVE *)
	 XK_Ytilde* = 01001EF8H;  (* U+1EF8 LATIN CAPITAL LETTER Y WITH TILDE *)
	 XK_ytilde* = 01001EF9H;  (* U+1EF9 LATIN SMALL LETTER Y WITH TILDE *)
	 XK_Ohorn* = 010001A0H;  (* U+01A0 LATIN CAPITAL LETTER O WITH HORN *)
	 XK_ohorn* = 010001A1H;  (* U+01A1 LATIN SMALL LETTER O WITH HORN *)
	 XK_Uhorn* = 010001AFH;  (* U+01AF LATIN CAPITAL LETTER U WITH HORN *)
	 XK_uhorn* = 010001B0H;  (* U+01B0 LATIN SMALL LETTER U WITH HORN *)

	(* #endif *) (* XK_VIETNAMESE *)

	(* #ifdef XK_CURRENCY *)
	 XK_EcuSign* = 010020A0H;  (* U+20A0 EURO-CURRENCY SIGN *)
	 XK_ColonSign* = 010020A1H;  (* U+20A1 COLON SIGN *)
	 XK_CruzeiroSign* = 010020A2H;  (* U+20A2 CRUZEIRO SIGN *)
	 XK_FFrancSign* = 010020A3H;  (* U+20A3 FRENCH FRANC SIGN *)
	 XK_LiraSign* = 010020A4H;  (* U+20A4 LIRA SIGN *)
	 XK_MillSign* = 010020A5H;  (* U+20A5 MILL SIGN *)
	 XK_NairaSign* = 010020A6H;  (* U+20A6 NAIRA SIGN *)
	 XK_PesetaSign* = 010020A7H;  (* U+20A7 PESETA SIGN *)
	 XK_RupeeSign* = 010020A8H;  (* U+20A8 RUPEE SIGN *)
	 XK_WonSign* = 010020A9H;  (* U+20A9 WON SIGN *)
	 XK_NewSheqelSign* = 010020AAH;  (* U+20AA NEW SHEQEL SIGN *)
	 XK_DongSign* = 010020ABH;  (* U+20AB DONG SIGN *)
	 XK_EuroSign* = 020ACH;  (* U+20AC EURO SIGN *)
	(* #endif *) (* XK_CURRENCY *)

	(* #ifdef XK_MATHEMATICAL *)
	(* one, two and three are defined above. *)
	 XK_zerosuperior* = 01002070H;  (* U+2070 SUPERSCRIPT ZERO *)
	 XK_foursuperior* = 01002074H;  (* U+2074 SUPERSCRIPT FOUR *)
	 XK_fivesuperior* = 01002075H;  (* U+2075 SUPERSCRIPT FIVE *)
	 XK_sixsuperior* = 01002076H;  (* U+2076 SUPERSCRIPT SIX *)
	 XK_sevensuperior* = 01002077H;  (* U+2077 SUPERSCRIPT SEVEN *)
	 XK_eightsuperior* = 01002078H;  (* U+2078 SUPERSCRIPT EIGHT *)
	 XK_ninesuperior* = 01002079H;  (* U+2079 SUPERSCRIPT NINE *)
	 XK_zerosubscript* = 01002080H;  (* U+2080 SUBSCRIPT ZERO *)
	 XK_onesubscript* = 01002081H;  (* U+2081 SUBSCRIPT ONE *)
	 XK_twosubscript* = 01002082H;  (* U+2082 SUBSCRIPT TWO *)
	 XK_threesubscript* = 01002083H;  (* U+2083 SUBSCRIPT THREE *)
	 XK_foursubscript* = 01002084H;  (* U+2084 SUBSCRIPT FOUR *)
	 XK_fivesubscript* = 01002085H;  (* U+2085 SUBSCRIPT FIVE *)
	 XK_sixsubscript* = 01002086H;  (* U+2086 SUBSCRIPT SIX *)
	 XK_sevensubscript* = 01002087H;  (* U+2087 SUBSCRIPT SEVEN *)
	 XK_eightsubscript* = 01002088H;  (* U+2088 SUBSCRIPT EIGHT *)
	 XK_ninesubscript* = 01002089H;  (* U+2089 SUBSCRIPT NINE *)
	 XK_partdifferential* = 01002202H;  (* U+2202 PARTIAL DIFFERENTIAL *)
	 XK_emptyset* = 01002205H;  (* U+2205 NULL SET *)
	 XK_elementof* = 01002208H;  (* U+2208 ELEMENT OF *)
	 XK_notelementof* = 01002209H;  (* U+2209 NOT AN ELEMENT OF *)
	 XK_containsas* = 0100220BH;  (* U+220B CONTAINS AS MEMBER *)
	 XK_squareroot* = 0100221AH;  (* U+221A SQUARE ROOT *)
	 XK_cuberoot* = 0100221BH;  (* U+221B CUBE ROOT *)
	 XK_fourthroot* = 0100221CH;  (* U+221C FOURTH ROOT *)
	 XK_dintegral* = 0100222CH;  (* U+222C DOUBLE INTEGRAL *)
	 XK_tintegral* = 0100222DH;  (* U+222D TRIPLE INTEGRAL *)
	 XK_because* = 01002235H;  (* U+2235 BECAUSE *)
	 XK_approxeq* = 01002248H;  (* U+2245 ALMOST EQUAL TO *)
	 XK_notapproxeq* = 01002247H;  (* U+2247 NOT ALMOST EQUAL TO *)
	 XK_notidentical* = 01002262H;  (* U+2262 NOT IDENTICAL TO *)
	 XK_stricteq* = 01002263H;  (* U+2263 STRICTLY EQUIVALENT TO *)
	(* #endif *) (* XK_MATHEMATICAL *)

	(* #ifdef XK_BRAILLE *)
	 XK_braille_dot_1* = 0FFF1H;
	 XK_braille_dot_2* = 0FFF2H;
	 XK_braille_dot_3* = 0FFF3H;
	 XK_braille_dot_4* = 0FFF4H;
	 XK_braille_dot_5* = 0FFF5H;
	 XK_braille_dot_6* = 0FFF6H;
	 XK_braille_dot_7* = 0FFF7H;
	 XK_braille_dot_8* = 0FFF8H;
	 XK_braille_dot_9* = 0FFF9H;
	 XK_braille_dot_10* = 0FFFAH;
	 XK_braille_blank* = 01002800H;  (* U+2800 BRAILLE PATTERN BLANK *)
	 XK_braille_dots_1* = 01002801H;  (* U+2801 BRAILLE PATTERN DOTS-1 *)
	 XK_braille_dots_2* = 01002802H;  (* U+2802 BRAILLE PATTERN DOTS-2 *)
	 XK_braille_dots_12* = 01002803H;  (* U+2803 BRAILLE PATTERN DOTS-12 *)
	 XK_braille_dots_3* = 01002804H;  (* U+2804 BRAILLE PATTERN DOTS-3 *)
	 XK_braille_dots_13* = 01002805H;  (* U+2805 BRAILLE PATTERN DOTS-13 *)
	 XK_braille_dots_23* = 01002806H;  (* U+2806 BRAILLE PATTERN DOTS-23 *)
	 XK_braille_dots_123* = 01002807H;  (* U+2807 BRAILLE PATTERN DOTS-123 *)
	 XK_braille_dots_4* = 01002808H;  (* U+2808 BRAILLE PATTERN DOTS-4 *)
	 XK_braille_dots_14* = 01002809H;  (* U+2809 BRAILLE PATTERN DOTS-14 *)
	 XK_braille_dots_24* = 0100280AH;  (* U+280a BRAILLE PATTERN DOTS-24 *)
	 XK_braille_dots_124* = 0100280BH;  (* U+280b BRAILLE PATTERN DOTS-124 *)
	 XK_braille_dots_34* = 0100280CH;  (* U+280c BRAILLE PATTERN DOTS-34 *)
	 XK_braille_dots_134* = 0100280DH;  (* U+280d BRAILLE PATTERN DOTS-134 *)
	 XK_braille_dots_234* = 0100280EH;  (* U+280e BRAILLE PATTERN DOTS-234 *)
	 XK_braille_dots_1234* = 0100280FH;  (* U+280f BRAILLE PATTERN DOTS-1234 *)
	 XK_braille_dots_5* = 01002810H;  (* U+2810 BRAILLE PATTERN DOTS-5 *)
	 XK_braille_dots_15* = 01002811H;  (* U+2811 BRAILLE PATTERN DOTS-15 *)
	 XK_braille_dots_25* = 01002812H;  (* U+2812 BRAILLE PATTERN DOTS-25 *)
	 XK_braille_dots_125* = 01002813H;  (* U+2813 BRAILLE PATTERN DOTS-125 *)
	 XK_braille_dots_35* = 01002814H;  (* U+2814 BRAILLE PATTERN DOTS-35 *)
	 XK_braille_dots_135* = 01002815H;  (* U+2815 BRAILLE PATTERN DOTS-135 *)
	 XK_braille_dots_235* = 01002816H;  (* U+2816 BRAILLE PATTERN DOTS-235 *)
	 XK_braille_dots_1235* = 01002817H;  (* U+2817 BRAILLE PATTERN DOTS-1235 *)
	 XK_braille_dots_45* = 01002818H;  (* U+2818 BRAILLE PATTERN DOTS-45 *)
	 XK_braille_dots_145* = 01002819H;  (* U+2819 BRAILLE PATTERN DOTS-145 *)
	 XK_braille_dots_245* = 0100281AH;  (* U+281a BRAILLE PATTERN DOTS-245 *)
	 XK_braille_dots_1245* = 0100281BH;  (* U+281b BRAILLE PATTERN DOTS-1245 *)
	 XK_braille_dots_345* = 0100281CH;  (* U+281c BRAILLE PATTERN DOTS-345 *)
	 XK_braille_dots_1345* = 0100281DH;  (* U+281d BRAILLE PATTERN DOTS-1345 *)
	 XK_braille_dots_2345* = 0100281EH;  (* U+281e BRAILLE PATTERN DOTS-2345 *)
	 XK_braille_dots_12345* = 0100281FH;  (* U+281f BRAILLE PATTERN DOTS-12345 *)
	 XK_braille_dots_6* = 01002820H;  (* U+2820 BRAILLE PATTERN DOTS-6 *)
	 XK_braille_dots_16* = 01002821H;  (* U+2821 BRAILLE PATTERN DOTS-16 *)
	 XK_braille_dots_26* = 01002822H;  (* U+2822 BRAILLE PATTERN DOTS-26 *)
	 XK_braille_dots_126* = 01002823H;  (* U+2823 BRAILLE PATTERN DOTS-126 *)
	 XK_braille_dots_36* = 01002824H;  (* U+2824 BRAILLE PATTERN DOTS-36 *)
	 XK_braille_dots_136* = 01002825H;  (* U+2825 BRAILLE PATTERN DOTS-136 *)
	 XK_braille_dots_236* = 01002826H;  (* U+2826 BRAILLE PATTERN DOTS-236 *)
	 XK_braille_dots_1236* = 01002827H;  (* U+2827 BRAILLE PATTERN DOTS-1236 *)
	 XK_braille_dots_46* = 01002828H;  (* U+2828 BRAILLE PATTERN DOTS-46 *)
	 XK_braille_dots_146* = 01002829H;  (* U+2829 BRAILLE PATTERN DOTS-146 *)
	 XK_braille_dots_246* = 0100282AH;  (* U+282a BRAILLE PATTERN DOTS-246 *)
	 XK_braille_dots_1246* = 0100282BH;  (* U+282b BRAILLE PATTERN DOTS-1246 *)
	 XK_braille_dots_346* = 0100282CH;  (* U+282c BRAILLE PATTERN DOTS-346 *)
	 XK_braille_dots_1346* = 0100282DH;  (* U+282d BRAILLE PATTERN DOTS-1346 *)
	 XK_braille_dots_2346* = 0100282EH;  (* U+282e BRAILLE PATTERN DOTS-2346 *)
	 XK_braille_dots_12346* = 0100282FH;  (* U+282f BRAILLE PATTERN DOTS-12346 *)
	 XK_braille_dots_56* = 01002830H;  (* U+2830 BRAILLE PATTERN DOTS-56 *)
	 XK_braille_dots_156* = 01002831H;  (* U+2831 BRAILLE PATTERN DOTS-156 *)
	 XK_braille_dots_256* = 01002832H;  (* U+2832 BRAILLE PATTERN DOTS-256 *)
	 XK_braille_dots_1256* = 01002833H;  (* U+2833 BRAILLE PATTERN DOTS-1256 *)
	 XK_braille_dots_356* = 01002834H;  (* U+2834 BRAILLE PATTERN DOTS-356 *)
	 XK_braille_dots_1356* = 01002835H;  (* U+2835 BRAILLE PATTERN DOTS-1356 *)
	 XK_braille_dots_2356* = 01002836H;  (* U+2836 BRAILLE PATTERN DOTS-2356 *)
	 XK_braille_dots_12356* = 01002837H;  (* U+2837 BRAILLE PATTERN DOTS-12356 *)
	 XK_braille_dots_456* = 01002838H;  (* U+2838 BRAILLE PATTERN DOTS-456 *)
	 XK_braille_dots_1456* = 01002839H;  (* U+2839 BRAILLE PATTERN DOTS-1456 *)
	 XK_braille_dots_2456* = 0100283AH;  (* U+283a BRAILLE PATTERN DOTS-2456 *)
	 XK_braille_dots_12456* = 0100283BH;  (* U+283b BRAILLE PATTERN DOTS-12456 *)
	 XK_braille_dots_3456* = 0100283CH;  (* U+283c BRAILLE PATTERN DOTS-3456 *)
	 XK_braille_dots_13456* = 0100283DH;  (* U+283d BRAILLE PATTERN DOTS-13456 *)
	 XK_braille_dots_23456* = 0100283EH;  (* U+283e BRAILLE PATTERN DOTS-23456 *)
	 XK_braille_dots_123456* = 0100283FH;  (* U+283f BRAILLE PATTERN DOTS-123456 *)
	 XK_braille_dots_7* = 01002840H;  (* U+2840 BRAILLE PATTERN DOTS-7 *)
	 XK_braille_dots_17* = 01002841H;  (* U+2841 BRAILLE PATTERN DOTS-17 *)
	 XK_braille_dots_27* = 01002842H;  (* U+2842 BRAILLE PATTERN DOTS-27 *)
	 XK_braille_dots_127* = 01002843H;  (* U+2843 BRAILLE PATTERN DOTS-127 *)
	 XK_braille_dots_37* = 01002844H;  (* U+2844 BRAILLE PATTERN DOTS-37 *)
	 XK_braille_dots_137* = 01002845H;  (* U+2845 BRAILLE PATTERN DOTS-137 *)
	 XK_braille_dots_237* = 01002846H;  (* U+2846 BRAILLE PATTERN DOTS-237 *)
	 XK_braille_dots_1237* = 01002847H;  (* U+2847 BRAILLE PATTERN DOTS-1237 *)
	 XK_braille_dots_47* = 01002848H;  (* U+2848 BRAILLE PATTERN DOTS-47 *)
	 XK_braille_dots_147* = 01002849H;  (* U+2849 BRAILLE PATTERN DOTS-147 *)
	 XK_braille_dots_247* = 0100284AH;  (* U+284a BRAILLE PATTERN DOTS-247 *)
	 XK_braille_dots_1247* = 0100284BH;  (* U+284b BRAILLE PATTERN DOTS-1247 *)
	 XK_braille_dots_347* = 0100284CH;  (* U+284c BRAILLE PATTERN DOTS-347 *)
	 XK_braille_dots_1347* = 0100284DH;  (* U+284d BRAILLE PATTERN DOTS-1347 *)
	 XK_braille_dots_2347* = 0100284EH;  (* U+284e BRAILLE PATTERN DOTS-2347 *)
	 XK_braille_dots_12347* = 0100284FH;  (* U+284f BRAILLE PATTERN DOTS-12347 *)
	 XK_braille_dots_57* = 01002850H;  (* U+2850 BRAILLE PATTERN DOTS-57 *)
	 XK_braille_dots_157* = 01002851H;  (* U+2851 BRAILLE PATTERN DOTS-157 *)
	 XK_braille_dots_257* = 01002852H;  (* U+2852 BRAILLE PATTERN DOTS-257 *)
	 XK_braille_dots_1257* = 01002853H;  (* U+2853 BRAILLE PATTERN DOTS-1257 *)
	 XK_braille_dots_357* = 01002854H;  (* U+2854 BRAILLE PATTERN DOTS-357 *)
	 XK_braille_dots_1357* = 01002855H;  (* U+2855 BRAILLE PATTERN DOTS-1357 *)
	 XK_braille_dots_2357* = 01002856H;  (* U+2856 BRAILLE PATTERN DOTS-2357 *)
	 XK_braille_dots_12357* = 01002857H;  (* U+2857 BRAILLE PATTERN DOTS-12357 *)
	 XK_braille_dots_457* = 01002858H;  (* U+2858 BRAILLE PATTERN DOTS-457 *)
	 XK_braille_dots_1457* = 01002859H;  (* U+2859 BRAILLE PATTERN DOTS-1457 *)
	 XK_braille_dots_2457* = 0100285AH;  (* U+285a BRAILLE PATTERN DOTS-2457 *)
	 XK_braille_dots_12457* = 0100285BH;  (* U+285b BRAILLE PATTERN DOTS-12457 *)
	 XK_braille_dots_3457* = 0100285CH;  (* U+285c BRAILLE PATTERN DOTS-3457 *)
	 XK_braille_dots_13457* = 0100285DH;  (* U+285d BRAILLE PATTERN DOTS-13457 *)
	 XK_braille_dots_23457* = 0100285EH;  (* U+285e BRAILLE PATTERN DOTS-23457 *)
	 XK_braille_dots_123457* = 0100285FH;  (* U+285f BRAILLE PATTERN DOTS-123457 *)
	 XK_braille_dots_67* = 01002860H;  (* U+2860 BRAILLE PATTERN DOTS-67 *)
	 XK_braille_dots_167* = 01002861H;  (* U+2861 BRAILLE PATTERN DOTS-167 *)
	 XK_braille_dots_267* = 01002862H;  (* U+2862 BRAILLE PATTERN DOTS-267 *)
	 XK_braille_dots_1267* = 01002863H;  (* U+2863 BRAILLE PATTERN DOTS-1267 *)
	 XK_braille_dots_367* = 01002864H;  (* U+2864 BRAILLE PATTERN DOTS-367 *)
	 XK_braille_dots_1367* = 01002865H;  (* U+2865 BRAILLE PATTERN DOTS-1367 *)
	 XK_braille_dots_2367* = 01002866H;  (* U+2866 BRAILLE PATTERN DOTS-2367 *)
	 XK_braille_dots_12367* = 01002867H;  (* U+2867 BRAILLE PATTERN DOTS-12367 *)
	 XK_braille_dots_467* = 01002868H;  (* U+2868 BRAILLE PATTERN DOTS-467 *)
	 XK_braille_dots_1467* = 01002869H;  (* U+2869 BRAILLE PATTERN DOTS-1467 *)
	 XK_braille_dots_2467* = 0100286AH;  (* U+286a BRAILLE PATTERN DOTS-2467 *)
	 XK_braille_dots_12467* = 0100286BH;  (* U+286b BRAILLE PATTERN DOTS-12467 *)
	 XK_braille_dots_3467* = 0100286CH;  (* U+286c BRAILLE PATTERN DOTS-3467 *)
	 XK_braille_dots_13467* = 0100286DH;  (* U+286d BRAILLE PATTERN DOTS-13467 *)
	 XK_braille_dots_23467* = 0100286EH;  (* U+286e BRAILLE PATTERN DOTS-23467 *)
	 XK_braille_dots_123467* = 0100286FH;  (* U+286f BRAILLE PATTERN DOTS-123467 *)
	 XK_braille_dots_567* = 01002870H;  (* U+2870 BRAILLE PATTERN DOTS-567 *)
	 XK_braille_dots_1567* = 01002871H;  (* U+2871 BRAILLE PATTERN DOTS-1567 *)
	 XK_braille_dots_2567* = 01002872H;  (* U+2872 BRAILLE PATTERN DOTS-2567 *)
	 XK_braille_dots_12567* = 01002873H;  (* U+2873 BRAILLE PATTERN DOTS-12567 *)
	 XK_braille_dots_3567* = 01002874H;  (* U+2874 BRAILLE PATTERN DOTS-3567 *)
	 XK_braille_dots_13567* = 01002875H;  (* U+2875 BRAILLE PATTERN DOTS-13567 *)
	 XK_braille_dots_23567* = 01002876H;  (* U+2876 BRAILLE PATTERN DOTS-23567 *)
	 XK_braille_dots_123567* = 01002877H;  (* U+2877 BRAILLE PATTERN DOTS-123567 *)
	 XK_braille_dots_4567* = 01002878H;  (* U+2878 BRAILLE PATTERN DOTS-4567 *)
	 XK_braille_dots_14567* = 01002879H;  (* U+2879 BRAILLE PATTERN DOTS-14567 *)
	 XK_braille_dots_24567* = 0100287AH;  (* U+287a BRAILLE PATTERN DOTS-24567 *)
	 XK_braille_dots_124567* = 0100287BH;  (* U+287b BRAILLE PATTERN DOTS-124567 *)
	 XK_braille_dots_34567* = 0100287CH;  (* U+287c BRAILLE PATTERN DOTS-34567 *)
	 XK_braille_dots_134567* = 0100287DH;  (* U+287d BRAILLE PATTERN DOTS-134567 *)
	 XK_braille_dots_234567* = 0100287EH;  (* U+287e BRAILLE PATTERN DOTS-234567 *)
	 XK_braille_dots_1234567* = 0100287FH;  (* U+287f BRAILLE PATTERN DOTS-1234567 *)
	 XK_braille_dots_8* = 01002880H;  (* U+2880 BRAILLE PATTERN DOTS-8 *)
	 XK_braille_dots_18* = 01002881H;  (* U+2881 BRAILLE PATTERN DOTS-18 *)
	 XK_braille_dots_28* = 01002882H;  (* U+2882 BRAILLE PATTERN DOTS-28 *)
	 XK_braille_dots_128* = 01002883H;  (* U+2883 BRAILLE PATTERN DOTS-128 *)
	 XK_braille_dots_38* = 01002884H;  (* U+2884 BRAILLE PATTERN DOTS-38 *)
	 XK_braille_dots_138* = 01002885H;  (* U+2885 BRAILLE PATTERN DOTS-138 *)
	 XK_braille_dots_238* = 01002886H;  (* U+2886 BRAILLE PATTERN DOTS-238 *)
	 XK_braille_dots_1238* = 01002887H;  (* U+2887 BRAILLE PATTERN DOTS-1238 *)
	 XK_braille_dots_48* = 01002888H;  (* U+2888 BRAILLE PATTERN DOTS-48 *)
	 XK_braille_dots_148* = 01002889H;  (* U+2889 BRAILLE PATTERN DOTS-148 *)
	 XK_braille_dots_248* = 0100288AH;  (* U+288a BRAILLE PATTERN DOTS-248 *)
	 XK_braille_dots_1248* = 0100288BH;  (* U+288b BRAILLE PATTERN DOTS-1248 *)
	 XK_braille_dots_348* = 0100288CH;  (* U+288c BRAILLE PATTERN DOTS-348 *)
	 XK_braille_dots_1348* = 0100288DH;  (* U+288d BRAILLE PATTERN DOTS-1348 *)
	 XK_braille_dots_2348* = 0100288EH;  (* U+288e BRAILLE PATTERN DOTS-2348 *)
	 XK_braille_dots_12348* = 0100288FH;  (* U+288f BRAILLE PATTERN DOTS-12348 *)
	 XK_braille_dots_58* = 01002890H;  (* U+2890 BRAILLE PATTERN DOTS-58 *)
	 XK_braille_dots_158* = 01002891H;  (* U+2891 BRAILLE PATTERN DOTS-158 *)
	 XK_braille_dots_258* = 01002892H;  (* U+2892 BRAILLE PATTERN DOTS-258 *)
	 XK_braille_dots_1258* = 01002893H;  (* U+2893 BRAILLE PATTERN DOTS-1258 *)
	 XK_braille_dots_358* = 01002894H;  (* U+2894 BRAILLE PATTERN DOTS-358 *)
	 XK_braille_dots_1358* = 01002895H;  (* U+2895 BRAILLE PATTERN DOTS-1358 *)
	 XK_braille_dots_2358* = 01002896H;  (* U+2896 BRAILLE PATTERN DOTS-2358 *)
	 XK_braille_dots_12358* = 01002897H;  (* U+2897 BRAILLE PATTERN DOTS-12358 *)
	 XK_braille_dots_458* = 01002898H;  (* U+2898 BRAILLE PATTERN DOTS-458 *)
	 XK_braille_dots_1458* = 01002899H;  (* U+2899 BRAILLE PATTERN DOTS-1458 *)
	 XK_braille_dots_2458* = 0100289AH;  (* U+289a BRAILLE PATTERN DOTS-2458 *)
	 XK_braille_dots_12458* = 0100289BH;  (* U+289b BRAILLE PATTERN DOTS-12458 *)
	 XK_braille_dots_3458* = 0100289CH;  (* U+289c BRAILLE PATTERN DOTS-3458 *)
	 XK_braille_dots_13458* = 0100289DH;  (* U+289d BRAILLE PATTERN DOTS-13458 *)
	 XK_braille_dots_23458* = 0100289EH;  (* U+289e BRAILLE PATTERN DOTS-23458 *)
	 XK_braille_dots_123458* = 0100289FH;  (* U+289f BRAILLE PATTERN DOTS-123458 *)
	 XK_braille_dots_68* = 010028A0H;  (* U+28a0 BRAILLE PATTERN DOTS-68 *)
	 XK_braille_dots_168* = 010028A1H;  (* U+28a1 BRAILLE PATTERN DOTS-168 *)
	 XK_braille_dots_268* = 010028A2H;  (* U+28a2 BRAILLE PATTERN DOTS-268 *)
	 XK_braille_dots_1268* = 010028A3H;  (* U+28a3 BRAILLE PATTERN DOTS-1268 *)
	 XK_braille_dots_368* = 010028A4H;  (* U+28a4 BRAILLE PATTERN DOTS-368 *)
	 XK_braille_dots_1368* = 010028A5H;  (* U+28a5 BRAILLE PATTERN DOTS-1368 *)
	 XK_braille_dots_2368* = 010028A6H;  (* U+28a6 BRAILLE PATTERN DOTS-2368 *)
	 XK_braille_dots_12368* = 010028A7H;  (* U+28a7 BRAILLE PATTERN DOTS-12368 *)
	 XK_braille_dots_468* = 010028A8H;  (* U+28a8 BRAILLE PATTERN DOTS-468 *)
	 XK_braille_dots_1468* = 010028A9H;  (* U+28a9 BRAILLE PATTERN DOTS-1468 *)
	 XK_braille_dots_2468* = 010028AAH;  (* U+28aa BRAILLE PATTERN DOTS-2468 *)
	 XK_braille_dots_12468* = 010028ABH;  (* U+28ab BRAILLE PATTERN DOTS-12468 *)
	 XK_braille_dots_3468* = 010028ACH;  (* U+28ac BRAILLE PATTERN DOTS-3468 *)
	 XK_braille_dots_13468* = 010028ADH;  (* U+28ad BRAILLE PATTERN DOTS-13468 *)
	 XK_braille_dots_23468* = 010028AEH;  (* U+28ae BRAILLE PATTERN DOTS-23468 *)
	 XK_braille_dots_123468* = 010028AFH;  (* U+28af BRAILLE PATTERN DOTS-123468 *)
	 XK_braille_dots_568* = 010028B0H;  (* U+28b0 BRAILLE PATTERN DOTS-568 *)
	 XK_braille_dots_1568* = 010028B1H;  (* U+28b1 BRAILLE PATTERN DOTS-1568 *)
	 XK_braille_dots_2568* = 010028B2H;  (* U+28b2 BRAILLE PATTERN DOTS-2568 *)
	 XK_braille_dots_12568* = 010028B3H;  (* U+28b3 BRAILLE PATTERN DOTS-12568 *)
	 XK_braille_dots_3568* = 010028B4H;  (* U+28b4 BRAILLE PATTERN DOTS-3568 *)
	 XK_braille_dots_13568* = 010028B5H;  (* U+28b5 BRAILLE PATTERN DOTS-13568 *)
	 XK_braille_dots_23568* = 010028B6H;  (* U+28b6 BRAILLE PATTERN DOTS-23568 *)
	 XK_braille_dots_123568* = 010028B7H;  (* U+28b7 BRAILLE PATTERN DOTS-123568 *)
	 XK_braille_dots_4568* = 010028B8H;  (* U+28b8 BRAILLE PATTERN DOTS-4568 *)
	 XK_braille_dots_14568* = 010028B9H;  (* U+28b9 BRAILLE PATTERN DOTS-14568 *)
	 XK_braille_dots_24568* = 010028BAH;  (* U+28ba BRAILLE PATTERN DOTS-24568 *)
	 XK_braille_dots_124568* = 010028BBH;  (* U+28bb BRAILLE PATTERN DOTS-124568 *)
	 XK_braille_dots_34568* = 010028BCH;  (* U+28bc BRAILLE PATTERN DOTS-34568 *)
	 XK_braille_dots_134568* = 010028BDH;  (* U+28bd BRAILLE PATTERN DOTS-134568 *)
	 XK_braille_dots_234568* = 010028BEH;  (* U+28be BRAILLE PATTERN DOTS-234568 *)
	 XK_braille_dots_1234568* = 010028BFH;  (* U+28bf BRAILLE PATTERN DOTS-1234568 *)
	 XK_braille_dots_78* = 010028C0H;  (* U+28c0 BRAILLE PATTERN DOTS-78 *)
	 XK_braille_dots_178* = 010028C1H;  (* U+28c1 BRAILLE PATTERN DOTS-178 *)
	 XK_braille_dots_278* = 010028C2H;  (* U+28c2 BRAILLE PATTERN DOTS-278 *)
	 XK_braille_dots_1278* = 010028C3H;  (* U+28c3 BRAILLE PATTERN DOTS-1278 *)
	 XK_braille_dots_378* = 010028C4H;  (* U+28c4 BRAILLE PATTERN DOTS-378 *)
	 XK_braille_dots_1378* = 010028C5H;  (* U+28c5 BRAILLE PATTERN DOTS-1378 *)
	 XK_braille_dots_2378* = 010028C6H;  (* U+28c6 BRAILLE PATTERN DOTS-2378 *)
	 XK_braille_dots_12378* = 010028C7H;  (* U+28c7 BRAILLE PATTERN DOTS-12378 *)
	 XK_braille_dots_478* = 010028C8H;  (* U+28c8 BRAILLE PATTERN DOTS-478 *)
	 XK_braille_dots_1478* = 010028C9H;  (* U+28c9 BRAILLE PATTERN DOTS-1478 *)
	 XK_braille_dots_2478* = 010028CAH;  (* U+28ca BRAILLE PATTERN DOTS-2478 *)
	 XK_braille_dots_12478* = 010028CBH;  (* U+28cb BRAILLE PATTERN DOTS-12478 *)
	 XK_braille_dots_3478* = 010028CCH;  (* U+28cc BRAILLE PATTERN DOTS-3478 *)
	 XK_braille_dots_13478* = 010028CDH;  (* U+28cd BRAILLE PATTERN DOTS-13478 *)
	 XK_braille_dots_23478* = 010028CEH;  (* U+28ce BRAILLE PATTERN DOTS-23478 *)
	 XK_braille_dots_123478* = 010028CFH;  (* U+28cf BRAILLE PATTERN DOTS-123478 *)
	 XK_braille_dots_578* = 010028D0H;  (* U+28d0 BRAILLE PATTERN DOTS-578 *)
	 XK_braille_dots_1578* = 010028D1H;  (* U+28d1 BRAILLE PATTERN DOTS-1578 *)
	 XK_braille_dots_2578* = 010028D2H;  (* U+28d2 BRAILLE PATTERN DOTS-2578 *)
	 XK_braille_dots_12578* = 010028D3H;  (* U+28d3 BRAILLE PATTERN DOTS-12578 *)
	 XK_braille_dots_3578* = 010028D4H;  (* U+28d4 BRAILLE PATTERN DOTS-3578 *)
	 XK_braille_dots_13578* = 010028D5H;  (* U+28d5 BRAILLE PATTERN DOTS-13578 *)
	 XK_braille_dots_23578* = 010028D6H;  (* U+28d6 BRAILLE PATTERN DOTS-23578 *)
	 XK_braille_dots_123578* = 010028D7H;  (* U+28d7 BRAILLE PATTERN DOTS-123578 *)
	 XK_braille_dots_4578* = 010028D8H;  (* U+28d8 BRAILLE PATTERN DOTS-4578 *)
	 XK_braille_dots_14578* = 010028D9H;  (* U+28d9 BRAILLE PATTERN DOTS-14578 *)
	 XK_braille_dots_24578* = 010028DAH;  (* U+28da BRAILLE PATTERN DOTS-24578 *)
	 XK_braille_dots_124578* = 010028DBH;  (* U+28db BRAILLE PATTERN DOTS-124578 *)
	 XK_braille_dots_34578* = 010028DCH;  (* U+28dc BRAILLE PATTERN DOTS-34578 *)
	 XK_braille_dots_134578* = 010028DDH;  (* U+28dd BRAILLE PATTERN DOTS-134578 *)
	 XK_braille_dots_234578* = 010028DEH;  (* U+28de BRAILLE PATTERN DOTS-234578 *)
	 XK_braille_dots_1234578* = 010028DFH;  (* U+28df BRAILLE PATTERN DOTS-1234578 *)
	 XK_braille_dots_678* = 010028E0H;  (* U+28e0 BRAILLE PATTERN DOTS-678 *)
	 XK_braille_dots_1678* = 010028E1H;  (* U+28e1 BRAILLE PATTERN DOTS-1678 *)
	 XK_braille_dots_2678* = 010028E2H;  (* U+28e2 BRAILLE PATTERN DOTS-2678 *)
	 XK_braille_dots_12678* = 010028E3H;  (* U+28e3 BRAILLE PATTERN DOTS-12678 *)
	 XK_braille_dots_3678* = 010028E4H;  (* U+28e4 BRAILLE PATTERN DOTS-3678 *)
	 XK_braille_dots_13678* = 010028E5H;  (* U+28e5 BRAILLE PATTERN DOTS-13678 *)
	 XK_braille_dots_23678* = 010028E6H;  (* U+28e6 BRAILLE PATTERN DOTS-23678 *)
	 XK_braille_dots_123678* = 010028E7H;  (* U+28e7 BRAILLE PATTERN DOTS-123678 *)
	 XK_braille_dots_4678* = 010028E8H;  (* U+28e8 BRAILLE PATTERN DOTS-4678 *)
	 XK_braille_dots_14678* = 010028E9H;  (* U+28e9 BRAILLE PATTERN DOTS-14678 *)
	 XK_braille_dots_24678* = 010028EAH;  (* U+28ea BRAILLE PATTERN DOTS-24678 *)
	 XK_braille_dots_124678* = 010028EBH;  (* U+28eb BRAILLE PATTERN DOTS-124678 *)
	 XK_braille_dots_34678* = 010028ECH;  (* U+28ec BRAILLE PATTERN DOTS-34678 *)
	 XK_braille_dots_134678* = 010028EDH;  (* U+28ed BRAILLE PATTERN DOTS-134678 *)
	 XK_braille_dots_234678* = 010028EEH;  (* U+28ee BRAILLE PATTERN DOTS-234678 *)
	 XK_braille_dots_1234678* = 010028EFH;  (* U+28ef BRAILLE PATTERN DOTS-1234678 *)
	 XK_braille_dots_5678* = 010028F0H;  (* U+28f0 BRAILLE PATTERN DOTS-5678 *)
	 XK_braille_dots_15678* = 010028F1H;  (* U+28f1 BRAILLE PATTERN DOTS-15678 *)
	 XK_braille_dots_25678* = 010028F2H;  (* U+28f2 BRAILLE PATTERN DOTS-25678 *)
	 XK_braille_dots_125678* = 010028F3H;  (* U+28f3 BRAILLE PATTERN DOTS-125678 *)
	 XK_braille_dots_35678* = 010028F4H;  (* U+28f4 BRAILLE PATTERN DOTS-35678 *)
	 XK_braille_dots_135678* = 010028F5H;  (* U+28f5 BRAILLE PATTERN DOTS-135678 *)
	 XK_braille_dots_235678* = 010028F6H;  (* U+28f6 BRAILLE PATTERN DOTS-235678 *)
	 XK_braille_dots_1235678* = 010028F7H;  (* U+28f7 BRAILLE PATTERN DOTS-1235678 *)
	 XK_braille_dots_45678* = 010028F8H;  (* U+28f8 BRAILLE PATTERN DOTS-45678 *)
	 XK_braille_dots_145678* = 010028F9H;  (* U+28f9 BRAILLE PATTERN DOTS-145678 *)
	 XK_braille_dots_245678* = 010028FAH;  (* U+28fa BRAILLE PATTERN DOTS-245678 *)
	 XK_braille_dots_1245678* = 010028FBH;  (* U+28fb BRAILLE PATTERN DOTS-1245678 *)
	 XK_braille_dots_345678* = 010028FCH;  (* U+28fc BRAILLE PATTERN DOTS-345678 *)
	 XK_braille_dots_1345678* = 010028FDH;  (* U+28fd BRAILLE PATTERN DOTS-1345678 *)
	 XK_braille_dots_2345678* = 010028FEH;  (* U+28fe BRAILLE PATTERN DOTS-2345678 *)
	 XK_braille_dots_12345678* = 010028FFH;  (* U+28ff BRAILLE PATTERN DOTS-12345678 *)
	(* #endif *) (* XK_BRAILLE *)

	(*
	 * Sinhala (http://unicode.org/charts/PDF/U0D80.pdf)
	 * http://www.nongnu.org/sinhala/doc/transliteration/sinhala-transliteration_6.html
	 *)

	(* #ifdef XK_SINHALA *)

	 XK_Sinh_ng* = 01000D82H;  (* U+0D82 SINHALA ANUSVARAYA *)
	 XK_Sinh_h2* = 01000D83H;  (* U+0D83 SINHALA VISARGAYA *)
	 XK_Sinh_a* = 01000D85H;  (* U+0D85 SINHALA AYANNA *)
	 XK_Sinh_aa* = 01000D86H;  (* U+0D86 SINHALA AAYANNA *)
	 XK_Sinh_ae* = 01000D87H;  (* U+0D87 SINHALA AEYANNA *)
	 XK_Sinh_aee* = 01000D88H;  (* U+0D88 SINHALA AEEYANNA *)
	 XK_Sinh_i* = 01000D89H;  (* U+0D89 SINHALA IYANNA *)
	 XK_Sinh_ii* = 01000D8AH;  (* U+0D8A SINHALA IIYANNA *)
	 XK_Sinh_u* = 01000D8BH;  (* U+0D8B SINHALA UYANNA *)
	 XK_Sinh_uu* = 01000D8CH;  (* U+0D8C SINHALA UUYANNA *)
	 XK_Sinh_ri* = 01000D8DH;  (* U+0D8D SINHALA IRUYANNA *)
	 XK_Sinh_rii* = 01000D8EH;  (* U+0D8E SINHALA IRUUYANNA *)
	 XK_Sinh_lu* = 01000D8FH;  (* U+0D8F SINHALA ILUYANNA *)
	 XK_Sinh_luu* = 01000D90H;  (* U+0D90 SINHALA ILUUYANNA *)
	 XK_Sinh_e* = 01000D91H;  (* U+0D91 SINHALA EYANNA *)
	 XK_Sinh_ee* = 01000D92H;  (* U+0D92 SINHALA EEYANNA *)
	 XK_Sinh_ai* = 01000D93H;  (* U+0D93 SINHALA AIYANNA *)
	 XK_Sinh_o* = 01000D94H;  (* U+0D94 SINHALA OYANNA *)
	 XK_Sinh_oo* = 01000D95H;  (* U+0D95 SINHALA OOYANNA *)
	 XK_Sinh_au* = 01000D96H;  (* U+0D96 SINHALA AUYANNA *)
	 XK_Sinh_ka* = 01000D9AH;  (* U+0D9A SINHALA KAYANNA *)
	 XK_Sinh_kha* = 01000D9BH;  (* U+0D9B SINHALA MAHA. KAYANNA *)
	 XK_Sinh_ga* = 01000D9CH;  (* U+0D9C SINHALA GAYANNA *)
	 XK_Sinh_gha* = 01000D9DH;  (* U+0D9D SINHALA MAHA. GAYANNA *)
	 XK_Sinh_ng2* = 01000D9EH;  (* U+0D9E SINHALA KANTAJA NAASIKYAYA *)
	 XK_Sinh_nga* = 01000D9FH;  (* U+0D9F SINHALA SANYAKA GAYANNA *)
	 XK_Sinh_ca* = 01000DA0H;  (* U+0DA0 SINHALA CAYANNA *)
	 XK_Sinh_cha* = 01000DA1H;  (* U+0DA1 SINHALA MAHA. CAYANNA *)
	 XK_Sinh_ja* = 01000DA2H;  (* U+0DA2 SINHALA JAYANNA *)
	 XK_Sinh_jha* = 01000DA3H;  (* U+0DA3 SINHALA MAHA. JAYANNA *)
	 XK_Sinh_nya* = 01000DA4H;  (* U+0DA4 SINHALA TAALUJA NAASIKYAYA *)
	 XK_Sinh_jnya* = 01000DA5H;  (* U+0DA5 SINHALA TAALUJA SANYOOGA NAASIKYAYA *)
	 XK_Sinh_nja* = 01000DA6H;  (* U+0DA6 SINHALA SANYAKA JAYANNA *)
	 XK_Sinh_tta* = 01000DA7H;  (* U+0DA7 SINHALA TTAYANNA *)
	 XK_Sinh_ttha* = 01000DA8H;  (* U+0DA8 SINHALA MAHA. TTAYANNA *)
	 XK_Sinh_dda* = 01000DA9H;  (* U+0DA9 SINHALA DDAYANNA *)
	 XK_Sinh_ddha* = 01000DAAH;  (* U+0DAA SINHALA MAHA. DDAYANNA *)
	 XK_Sinh_nna* = 01000DABH;  (* U+0DAB SINHALA MUURDHAJA NAYANNA *)
	 XK_Sinh_ndda* = 01000DACH;  (* U+0DAC SINHALA SANYAKA DDAYANNA *)
	 XK_Sinh_tha* = 01000DADH;  (* U+0DAD SINHALA TAYANNA *)
	 XK_Sinh_thha* = 01000DAEH;  (* U+0DAE SINHALA MAHA. TAYANNA *)
	 XK_Sinh_dha* = 01000DAFH;  (* U+0DAF SINHALA DAYANNA *)
	 XK_Sinh_dhha* = 01000DB0H;  (* U+0DB0 SINHALA MAHA. DAYANNA *)
	 XK_Sinh_na* = 01000DB1H;  (* U+0DB1 SINHALA DANTAJA NAYANNA *)
	 XK_Sinh_ndha* = 01000DB3H;  (* U+0DB3 SINHALA SANYAKA DAYANNA *)
	 XK_Sinh_pa* = 01000DB4H;  (* U+0DB4 SINHALA PAYANNA *)
	 XK_Sinh_pha* = 01000DB5H;  (* U+0DB5 SINHALA MAHA. PAYANNA *)
	 XK_Sinh_ba* = 01000DB6H;  (* U+0DB6 SINHALA BAYANNA *)
	 XK_Sinh_bha* = 01000DB7H;  (* U+0DB7 SINHALA MAHA. BAYANNA *)
	 XK_Sinh_ma* = 01000DB8H;  (* U+0DB8 SINHALA MAYANNA *)
	 XK_Sinh_mba* = 01000DB9H;  (* U+0DB9 SINHALA AMBA BAYANNA *)
	 XK_Sinh_ya* = 01000DBAH;  (* U+0DBA SINHALA YAYANNA *)
	 XK_Sinh_ra* = 01000DBBH;  (* U+0DBB SINHALA RAYANNA *)
	 XK_Sinh_la* = 01000DBDH;  (* U+0DBD SINHALA DANTAJA LAYANNA *)
	 XK_Sinh_va* = 01000DC0H;  (* U+0DC0 SINHALA VAYANNA *)
	 XK_Sinh_sha* = 01000DC1H;  (* U+0DC1 SINHALA TAALUJA SAYANNA *)
	 XK_Sinh_ssha* = 01000DC2H;  (* U+0DC2 SINHALA MUURDHAJA SAYANNA *)
	 XK_Sinh_sa* = 01000DC3H;  (* U+0DC3 SINHALA DANTAJA SAYANNA *)
	 XK_Sinh_ha* = 01000DC4H;  (* U+0DC4 SINHALA HAYANNA *)
	 XK_Sinh_lla* = 01000DC5H;  (* U+0DC5 SINHALA MUURDHAJA LAYANNA *)
	 XK_Sinh_fa* = 01000DC6H;  (* U+0DC6 SINHALA FAYANNA *)
	 XK_Sinh_al* = 01000DCAH;  (* U+0DCA SINHALA AL-LAKUNA *)
	 XK_Sinh_aa2* = 01000DCFH;  (* U+0DCF SINHALA AELA-PILLA *)
	 XK_Sinh_ae2* = 01000DD0H;  (* U+0DD0 SINHALA AEDA-PILLA *)
	 XK_Sinh_aee2* = 01000DD1H;  (* U+0DD1 SINHALA DIGA AEDA-PILLA *)
	 XK_Sinh_i2* = 01000DD2H;  (* U+0DD2 SINHALA IS-PILLA *)
	 XK_Sinh_ii2* = 01000DD3H;  (* U+0DD3 SINHALA DIGA IS-PILLA *)
	 XK_Sinh_u2* = 01000DD4H;  (* U+0DD4 SINHALA PAA-PILLA *)
	 XK_Sinh_uu2* = 01000DD6H;  (* U+0DD6 SINHALA DIGA PAA-PILLA *)
	 XK_Sinh_ru2* = 01000DD8H;  (* U+0DD8 SINHALA GAETTA-PILLA *)
	 XK_Sinh_e2* = 01000DD9H;  (* U+0DD9 SINHALA KOMBUVA *)
	 XK_Sinh_ee2* = 01000DDAH;  (* U+0DDA SINHALA DIGA KOMBUVA *)
	 XK_Sinh_ai2* = 01000DDBH;  (* U+0DDB SINHALA KOMBU DEKA *)
	 XK_Sinh_o2* = 01000DDCH;  (* U+0DDC SINHALA KOMBUVA HAA AELA-PILLA*)
	 XK_Sinh_oo2* = 01000DDDH;  (* U+0DDD SINHALA KOMBUVA HAA DIGA AELA-PILLA*)
	 XK_Sinh_au2* = 01000DDEH;  (* U+0DDE SINHALA KOMBUVA HAA GAYANUKITTA *)
	 XK_Sinh_lu2* = 01000DDFH;  (* U+0DDF SINHALA GAYANUKITTA *)
	 XK_Sinh_ruu2* = 01000DF2H;  (* U+0DF2 SINHALA DIGA GAETTA-PILLA *)
	 XK_Sinh_luu2* = 01000DF3H;  (* U+0DF3 SINHALA DIGA GAYANUKITTA *)
	 XK_Sinh_kunddaliya* = 01000DF4H;  (* U+0DF4 SINHALA KUNDDALIYA *)
	(* #endif *) (* XK_SINHALA *)



END X11KeySymDef.
