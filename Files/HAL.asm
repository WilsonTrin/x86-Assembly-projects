TITLE HAL
;****************************************************************************
;* Title:   HAL				                                                *
;* Purpose: This program asks some questions to the user in the form of HAL *
;****************************************************************************

        .MODEL  small
        STACK   256

;****************************************************************************
;* Equates Section                                                          *
;****************************************************************************

EOS     EQU     0                       ; End of string
maxLen  EQU     40                      ; Maximum entry string length

;****************************************************************************
;* Data Section                                                             *
;****************************************************************************
        .DATA

exCode   db     0												; DOS error code

prompt1	 db	'Hello, my name is HAL. What is your name? ',EOS	; First text
prompt2	 db	'Hello ',EOS										; Second text
prompt3	 db	' How do you feel today? ',EOS						; Third text
prompt4	 db	'I', "'", 'm glad to know that you feel ',EOS		; Fourth text
period	 db	'.',EOS												; Period text
prompt5	 db	'What is your favorite number ',EOS					; Fifth text
qmark	 db	'? ',EOS											; Question mark text
prompt6	 db	'Thank you.',EOS									; Sixth text
prompt7	 db	"'",'s favorite number is ',EOS						; Seventh text
prompt8	 db	' decimal in binary is ',EOS						; Eigth text
prompt9	 db	' decimal in hex is ',EOS							; Ninth text
redo	 db	'Do you want another analysis ',EOS					; Redo text
rqmark	 db	'? (y/n) ',EOS										; The end of the redo text

buffer	 db	maxLen dup (?)										; Input/Output buffer

thename	 db	20 DUP(?)											; The name entered
feeling	 dw	20													; The feeling entered
number	 dw	0													; The number entered

;****************************************************************************
;* Code Section                                                             *
;****************************************************************************
        .CODE

;****************************************************************************
;* External procedures from STRINGS.OBJ & STRIO.OBJ                         *
;****************************************************************************

        EXTRN   StrLength:proc, StrRead:proc
        EXTRN   StrWrite:proc, NewLine:proc

;****************************************************************************
;* External procedures from BINASC.OBJ                                      *
;****************************************************************************

        EXTRN   BinToAscHex:proc, SBinToAscDec:proc, BinToAscDec:proc
        EXTRN   BinToAscBin:proc, AscToBin:proc

;****************************************************************************
;* Main entry point of program.                                             *
;****************************************************************************

Start:  
        mov     ax, @data               ; Initialize DS to address
        mov     ds, ax                  ;  of data segment
        mov     es, ax                  ; Make es = ds

;****************************************************************************
;* Start of Program                                                         *
;****************************************************************************

First:
	call	NewLine			; Start new display line
	call	NewLine			; Start new display line
	mov	di, OFFSET prompt1	; My name is HAL
	call	StrWrite		; Write text

	mov	di, OFFSET thename	; Point to the name
	call	StrRead			; Get entry from keyboard

	jmp		Second			; Dialog continues

Second:
	call	NewLine			; Start new display line
	mov	di, OFFSET prompt2	; Hello insert name here
	call	StrWrite		; Write text

	mov	di, OFFSET thename	; Point to name
	call	StrWrite		; Send buffer to screen

	mov	di, OFFSET period	; a period
	call	StrWrite		; Write text
	mov	di, OFFSET prompt3	; How do you feel?
	call	StrWrite		; Write text

	mov	di, OFFSET buffer	; Buffer will get user's entry
	mov	cx, maxLen			; Maximum string length
	call	StrRead			; Get entry from keyboard
	mov		feeling, ax		; Save feeling into variable
	jmp		Third			; Dialog continues

Third:

	call	NewLine			; Start new display line
	mov	di, OFFSET prompt4	; Glad to know what you feel
	call	StrWrite		; Write text

	mov	di, OFFSET buffer	; Point to buffer string
	mov	ax, feeling			; Resurface your feelings
	call	StrWrite		; Write text

	mov	di, OFFSET period	; a period
	call	StrWrite		; Write text
	call	NewLine			; Start new display line
	mov	di, OFFSET prompt5	; Your favorite number
	call	StrWrite		; Write text

	mov	di, OFFSET thename	; Point to name
	call	StrWrite		; Write text

	mov	di, OFFSET qmark	; a question mark
	call	StrWrite		; Write text

	mov	di, OFFSET buffer	; Buffer will get user's entry
	mov	cx, maxLen			; Maximum string length
	call	StrRead			; Get entry from keyboard
	call	AscToBin		; Convert string to binary
	mov		number, ax		; Save value into variable

	call	NewLine			; Start new display line
	mov	di, OFFSET prompt6	; Thank you text
	call	StrWrite		; Write text
	jmp		Fourth			; Dialog continues

Fourth:
	call	NewLine			; Start new display line
	call	NewLine			; Start new display line
	mov	di, OFFSET thename	; Point to name
	call	StrWrite		; Send buffer to screen

	mov	di, OFFSET prompt7	; your favorite number is
	call	StrWrite		; Write text

	mov	di, OFFSET buffer	; Point to buffer
	mov	ax, number			; Get number
	call	BinToAscDec		; Convert binary to decimal
	call	StrWrite		; Write text

	mov	di, OFFSET period	; a period
	call	StrWrite		; Write text

	call	NewLine			; Start new display line
	mov	di, OFFSET buffer	; Point to buffer
	mov	ax, number			; Get number
	call	BinToAscDec		; Convert binary to decimal
	call	StrWrite		; Write text

	mov	di, OFFSET prompt8	; decimal in binary
	call	StrWrite		; Write text

	mov	di, OFFSET buffer	; Point to buffer
	mov cx, 0				; limit digits
	mov	ax, number			; Get number
	call	BinToAscDec		; Convert binary to decimal
	call	StrWrite		; Write text

	mov	di, OFFSET period	; a period
	call	StrWrite		; Write text

	call	NewLine			; Start new display line
	mov	di, OFFSET buffer	; Point to buffer
	mov	ax, number			; Get number
	
	call	StrWrite		; Write text
	call	BinToAscBin		; Convert string to Binary
	mov	di, OFFSET prompt9	; decimal in hex
	call	StrWrite		; Write text

	mov	di, OFFSET buffer	; Point to buffer string
	mov cx, 4				; limit to 4 digits
	mov	ax, number			; Get number
	call	BinToAscHex		; Convert binary to hex
	call	StrWrite		; Write text

	mov	di, OFFSET period	; a period
	call	StrWrite		; Write text
	jmp		StartOver		; Main dialog ends basically

StartOver:
	call	NewLine			; Start new display line
	call	NewLine			; Start new display line
	mov	di, OFFSET redo		; HAL asks fo a redo
	call	StrWrite		; Write text
	mov di, OFFSET thename  ; Point to name
	call	StrWrite		; Write text
	mov di, OFFSET rqmark	; End of this text basically
	call	StrWrite		; Write text

	mov	di, OFFSET buffer	; Point to buffer
	mov cx, 2				; Text limiting to 2
	call StrRead			; Get keyboard input
	cmp buffer, 'y'			; Check if the input is y
	jnz Next				; Continue on if true
	jmp First				; Jump to the begining

Next:
	jmp Done
       
;****************************************************************************
;* End of Program.                                                          *
;****************************************************************************
Done:

;****************************************************************************
;* Program termination code.                                                *
;****************************************************************************
        mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, exCode              ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

        END     Start                   ; End of program / entry point