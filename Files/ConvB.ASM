TITLE Convert number with base
;****************************************************************************
;* Title:   Convert number with base                                        *
;* Purpose: This program converts a number from a specific base to another  *
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

exCode   db     0                                       ; DOS error code
prompt1	 db		'Enter the number     : ', EOS
prompt2	 db		'Enter the from base  : ', EOS
prompt3	 db		'Enter the to base3   : ', EOS
prompt4	 db		'Do another number? (Y/N) : ', EOS
errMsg1	 db		'Invalid input string - Reenter.', EOS
inputStr db		100 dup (?)
buffer	 db		100 dup (?)
fromBase dw		0
tobase	 dw		0
theNumber dw	0

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

; Subroutine AscToBinBase
; di - pointer to input string
; bx - number base
; ax - return value
; cf - set to 1 on invalid input string

AscToBinBase:

		.DATA
power	dw 0
value	dw 0

		.CODE
		mov		power, 1				; Set the power to 1
		mov		value, 0				; Set the value to 0

		mov		cx, 0					; Set the counter to 0
loop1:									; Count the amount of numbers in the input
		mov		al, [di]				; Make the number equal to the pointer
		cmp		al, EOS					; See if it's at the end of the string
		je		foundEOS				; If it is, go to found EOS
		inc		di						; Otherwise increase the pointer's value by 1
		inc		cx						; Increase the counter by 1
		jmp		loop1					; jump back to the begining of loop1

foundEOS:
		dec		di						; Back the point up out of the EOS
nextDigit:
		mov		al, [di]				; Make the number equal to the pointer
		sub		al, '0'					; Turns ASCII code into decimal???
		cmp		al, bl					; Compare al with bl
		jae		theError				; Catches anything resulting as negative

		mov		ah, 0
		mul		power					; Multiply the number by the power
		add		value, ax

		mov		ax, power				; ax is now equal to power
		mul		bx						; Multiply the base with ax
		mov		power, ax				; Power is now equal to ax

		dec		di						; Decrease the pointer's value by 1
		dec		cx						; Decrease the counter by 1
		jnz		nextDigit				; If cx isn't 0 go back to the top

		mov		ax, value				; ax is now equal to value
		clc								; Clear the carry flag
		jmp		subRet					; Go to subRet

theError:
		stc								; Set the carry flag

subRet:
		ret								; Return

; Subroutine BinToAscBase
; di - pointer to output string
; ax - binary value
; bx - to base

BinToAscBase:
		.DATA

		.CODE
		push	di						; Count the number of things that get pushed onto the stack
		mov		cx, 0					; That counter
divloop:
		mov		dx, 0					; Make the whole pointer equal to 0
		div		bx						; dx:ax / bx
		push	dx						; Count the number of things that get pushed onto the stack
		inc		cx						; Increase the counter by 1
		cmp		ax, 0					; Check if ax is 0
		jne		divloop					; Go back to the top if no

outloop:
		pop		ax						; Take the number from the stack
		add		al, '0'					; Turns decimal into ASCII code???
		mov		[di], al				; The pointer is now equal to the number
		inc		di						; Increase the pointer by 1
		loop	outloop					; Loop this until the counter is 0

		mov		al, EOS					; The number is now equal to the EOS
		mov		[di], al				; The pointer is now equal to the number

		pop		di						; Take the pointer from the stack
		ret								; Return


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
GetTheNumbers:

		call	NewLine					; Skip a line
		call	NewLine					; Skip another line

; Get the input number
		mov		di, OFFSET prompt1		; Point to the first prompt
		call	StrWrite				; Print that
		mov		di, OFFSET inputStr		; Point to the input string
		mov		cx, 17					; Set the character limit
		call	StrRead					; Get the user input

; Get the from base
		call	Newline					; Skip a line
		mov		di, OFFSET prompt2		; Point to the second prompt
		call	StrWrite				; Print that
		mov		di, OFFSET buffer		; Point to the buffer
		mov		cx, 3					; Set the character limit
		call	StrRead					; Get the user input
		call	AscToBin				; Do the AscToBin subroutine
		mov		fromBase, ax			; Make fromBase = ax

; Print input number in decimal
		call	NewLine					; Skip a line
		mov		di, OFFSET inputStr		; Point to inputStr
		mov		bx, fromBase			; Make bx = fromBase
		call	AscToBinBase			; Do the AscToBinBase subroutine
		jnc		InputOK					; Go to InputOK if you can calculate this alright

		mov		di, OFFSET errMsg1		; Otherwise point to the error message
		call	StrWrite				; Print it
		jmp		GetTheNumbers			; Go back to the top

InputOK:
		mov		theNumber, ax			; Save ax into theNumber

		mov		di, OFFSET buffer		; Point to the buffer
		mov		cx, 1					; Set the character limit
		call	BinToAscDec				; Do the BinToAscDec subroutine
		call	StrWrite				; Print the result

; Get the to base
		call	NewLine					; Skip a line
		mov		di, OFFSET prompt3		; Point to the third prompt
		call	StrWrite				; Print that

		mov		di, OFFSET buffer		; Point to the buffer
		mov		cx, 3					; Set the character limit
		call	StrRead					; Get the user input
		call	AscToBin				; Do the AscToBin subroutine
		mov		toBase, ax				; Make toBase = ax

; Print the number in to base
		call	NewLine					; Skip a line
		mov		ax, theNumber			; Make ax = theNumber
		mov		bx, toBase				; Make bx = toBase
		mov		di, OFFSET buffer		; Point to the buffer
		call	BinToAscBase			; Do the BinToAscBase subroutine
		call	StrWrite				; Print that

; Do it again?
		call	NewLine					; Skip a line
		call	NewLine					; Skip another line
		mov		di, OFFSET prompt4		; Point to the fourth prompt
		call	StrWrite				; Print that
		mov		di, OFFSET buffer		; Point to the buffer
		mov		cx, 2					; Set the character limit
		call	StrRead					; Get the user input

		mov		al, buffer				; Make al = buffer
		and		al, 11011111b			; Force uppercase
		cmp		al, 'Y'					; See if it's a Y
		jne		Done					; If not, end the program
		jmp		GetTheNumbers			; If yes, restart

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
