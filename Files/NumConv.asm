TITLE Convert Number
;****************************************************************************
;* Title:   Convert Number                                                  *
;* Purpose: This program asks a name and converts numbers to binary and hex *
;****************************************************************************

        .MODEL  small
        STACK   256

;****************************************************************************
;* Equates Section                                                          *
;****************************************************************************

EOS     EQU     0												        ; End of string
maxLen  EQU     40														; Maximum entry string length

;****************************************************************************
;* Data Section                                                             *
;****************************************************************************
        .DATA

exCode   db     0														; DOS error code

prompt1	 db	'Welcome to the Super-Duper Number Converter!',EOS			; First text
prompt2	 db	'Please enter your name: ',EOS								; Second text
prompt3	 db	'Hi ',EOS													; Third text
prompt4	 db	'!',EOS														; Fourth text
prompt5	 db	'Please enter a decimal number from 0 to 65535: ',EOS		; Fifth text
prompt68 db	' decimal = ',EOS											; Sixth and Eighth text
prompt7	 db	' binary',EOS												; Seventh text
prompt9	 db	' hex',EOS													; Ninth text
redo	 db	', would you like to do another conversion (Y or N)? ',EOS	; Redo text
bye		 db	'Good bye ',EOS												; End text
period	 db	'.',EOS														; End End text

buffer	 db	maxLen dup (?)												; Input/Output buffer

thename	 db	20 DUP(?)													; The name entered
number	 dw	0															; The number entered

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
	call	NewLine						; Start new display line
	call	NewLine						; Start new display line
	mov	di, OFFSET prompt1				; Super Duper num conv
	call	StrWrite					; Write text

	call	NewLine						; Start new display line
	mov	di, OFFSET prompt2				; What your name
	call	StrWrite					; Write text

	mov	di, OFFSET thename				; Point to the name
	call	StrRead						; Get entry from keyboard

	jmp		Second						; Dialog continues

Second:
	call	NewLine						; Start new display line
	mov	di, OFFSET prompt3				; Hi insert name here
	call	StrWrite					; Write text

	mov	di, OFFSET thename				; Point to name
	call	StrWrite					; Write text

	mov	di, OFFSET prompt4				; !
	call	StrWrite					; Write text

	;call	NewLine						; Start new display line
	call	NewLine						; Start new display line
	mov	di, OFFSET prompt5				; What favorite number
	call	StrWrite					; Write text

	mov	di, OFFSET buffer				; Buffer will get user's entry
	mov	cx, maxLen						; Maximum string length
	call	StrRead						; Get entry from keyboard
	mov		number, ax					; Save number into variable
	call	AscToBin					; Convert string to binary
	mov		number, ax					; Save value into variable
	jmp		Third						; Dialog continues

Third:

	call	NewLine						; Start new display line
	mov	di, OFFSET buffer				; Point to buffer string
	mov	ax, number						; Get the number
	call	StrWrite					; Write text

	mov	di, OFFSET prompt68				; this equals text
	call	StrWrite					; Write text

	mov	di, OFFSET buffer				; Point to buffer
	mov	cx, 16							; String length of 16
	mov	ax, number						; Get number
	call	BinToAscBin					; Convert binary to binary
	call	StrWrite					; Write text

	mov	di, OFFSET prompt7				; binary
	call	StrWrite					; Write text

	call	NewLine						; Start new display line
	mov	di, OFFSET buffer				; Point to buffer string
	mov	ax, number						; Get the number
	mov	cx, 0							; String length
	call	BinToAscDec					; Convert binary to decimal
	call	StrWrite					; Write text

	mov	di, OFFSET prompt68				; this equals text
	call	StrWrite					; Write text

	mov	di, OFFSET buffer				; Point to buffer
	mov	ax, number						; Get number
	mov	cx, 4							; String length of 4
	call	BinToAscHex					; Convert binary to hex
	call	StrWrite					; Write text

	mov	di, OFFSET prompt9				; hex
	call	StrWrite					; Write text

	jmp		StartOver					; Main dialog ends basically

StartOver:
	call	NewLine						; Start new display line
	call	NewLine						; Start new display line
	mov di, OFFSET thename				; Point to name
	call	StrWrite					; Write text
	mov	di, OFFSET redo					; asks fo a redo
	call	StrWrite					; Write text

	mov	di, OFFSET buffer				; Point to buffer
	mov cx, 2							; Text limiting to 2
	call StrRead						; Get keyboard input
	cmp buffer, 'y'						; Check if the input is y
	jnz Next							; Continue on if true
	jmp First							; Jump to the begining

Next:
	jmp Done							; End Program
       
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