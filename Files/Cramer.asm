TITLE Cramer's Rule
;****************************************************************************
;* Title:   Cramer's Rule                                                   *
;* Purpose: This program does math with Cramer's rule                       *
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

exCode	db 0													; DOS error code
buffer	dw 255 dup (?)											; buffer

Aval	dw	0													; a value
Bval	dw	0													; b value
Cval	dw	0													; c value
Dval	dw	0													; d value
Eval	dw	0													; e value
Fval	dw	0													; f value

Dvar	dw	0													; D variable
DXvar	dw  0													; DX variable
DYvar	dw	0													; DY variable
Xvar	dw	0													; X variable
Yvar	dw	0													; Y variable

prompt1 db 'The Fantastic Systems of Equations Solver!', EOS	; Text
prompt2 db 'Please enter the coefficient values:', EOS			; Text
prompt3 db 'Here is the solution: x = ', EOS					; Text
prompt4 db ', y = ', EOS										; Text
prompt5 db 'This system has no single solution.', EOS			; Text
redo	db 'Solve another system? (Y or N) ', EOS				; Text
exitTxt db 'Exiting program.', EOS								; Text

giveA	db 'a = ',EOS											; Text
giveB	db 'b = ',EOS											; Text
giveC	db 'c = ',EOS											; Text
giveD	db 'd = ',EOS											; Text
giveE	db 'e = ',EOS											; Text
giveF	db 'f = ',EOS											; Text

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

Greeting:
		call	NewLine					; Skip to a new line
		mov		di, OFFSET prompt1		; Pull up the text
		call	StrWrite				; Write the text
		call	NewLine					; Skip to a new line
		mov		cx,	maxLen				; Make the text limit maximum

GetNums:
		call	NewLine					; Skip to a new line
		mov		di, OFFSET prompt2		; Pull up the text
		call	StrWrite				; Write the text
		call	NewLine					; Skip to a new line

; Get the values for a, b, c, d, e, and f
; Get a
		call	NewLine					; Skip to a new line
		mov		di, OFFSET giveA		; Pull up the text
		call	StrWrite				; Write the text
		mov		di, OFFSET buffer		; Pull up the buffer
		call	StrRead					; Put the user input in buffer
		call	AscToBin				; Covert the input to binary
		mov		Aval, ax				; Move al to the variable

; Get b
		call	NewLine					; Skip to a new line
		mov		di, OFFSET giveB		; Pull up the text
		call	StrWrite				; Write the text
		mov		di, OFFSET buffer		; Pull up the buffer
		call	StrRead					; Put the user input in buffer
		call	AscToBin				; Covert the input to binary
		mov		Bval, ax				; Move al to the variable

; Get c
		call	NewLine					; Skip to a new line
		mov		di, OFFSET giveC		; Pull up the text
		call	StrWrite				; Write the text
		mov		di, OFFSET buffer		; Pull up the buffer
		call	StrRead					; Put the user input in buffer
		call	AscToBin				; Covert the input to binary
		mov		Cval, ax				; Move al to the variable
		
; Get d
		call	NewLine					; Skip to a new line
		mov		di, OFFSET giveD		; Pull up the text
		call	StrWrite				; Write the text
		mov		di, OFFSET buffer		; Pull up the buffer
		call	StrRead					; Put the user input in buffer
		call	AscToBin				; Covert the input to binary
		mov		Dval, ax				; Move al to the variable

; Get e
		call	NewLine					; Skip to a new line
		mov		di, OFFSET giveE		; Pull up the text
		call	StrWrite				; Write the text
		mov		di, OFFSET buffer		; Pull up the buffer
		call	StrRead					; Put the user input in buffer
		call	AscToBin				; Covert the input to binary
		mov		Eval, ax				; Move al to the variable

; Get f
		call	NewLine					; Skip to a new line
		mov		di, OFFSET giveF		; Pull up the text
		call	StrWrite				; Write the text
		mov		di, OFFSET buffer		; Pull up the buffer
		call	StrRead					; Put the user input in buffer
		call	AscToBin				; Covert the input to binary
		mov		Fval, ax				; Move al to the variable

DoCalc:
; Get the D variable with ae - bd
		mov		ax, Bval				; Move Bval into ax
		mul		Dval					; Multiply Dval by ax
		mov		bx, ax					; Move ax into bx

		mov		ax, Aval				; Move Aval into ax
		mul		Eval					; Multiply Eval by ax

		sub		ax, bx					; Subtract bx from ax
		mov		Dvar, ax				; Move the final result into Dvar

; Get the DX variable with ce - bf
		mov		ax, Bval				; Move Bval into ax
		mul		Fval					; Multiply Fval by ax
		mov		bx, ax					; Move ax into bx

		mov		ax, Cval				; Move Aval into ax
		mul		Eval					; Multiply Eval by ax

		sub		ax, bx					; Subtract bx from ax
		mov		DXvar, ax				; Move the final result into DXvar

; Get the DY variable with af - cd
		mov		ax, Cval				; Move Bval into ax
		mul		Dval					; Multiply Dval by ax
		mov		bx, ax					; Move ax into bx

		mov		ax, Aval				; Move Aval into ax
		mul		Fval					; Multiply Fval by ax

		sub		ax, bx					; Subtract bx from ax
		mov		DYvar, ax				; Move the final result into DYvar

; Compare to X with DX/D
		xor		dx,	dx					; Clear dx so that the program doesn't freeze
		mov		ax, DXvar				; Move DXvar into ax
		idiv		Dvar					; Divide by Dvar
		mov		Xvar, ax				; Move the result into Xvar

; Compare to Y with DY/D
		xor		dx, dx					; Clear dx so that the program doesn't freeze
		mov		ax, DYvar				; Move DYvar into ax
		idiv		Dvar					; Divide by Dvar ********************************************************
		mov		Yvar, ax				; Move the result into Yvar

; Print the solution
YesSolution:
		call	NewLine					; Skip to a new line
		mov		di, OFFSET prompt3		; Pull up the text
		call	StrWrite				; Write the text

		mov		cx, 1					; Set the print limit
		mov		ax, Xvar				; Move the X varible into ax
		call	SBinToAscDec			; Convert to a signed decimal
		call	StrWrite				; Write the text

		mov		di, OFFSET prompt4		; Pull up the text
		call	StrWrite				; Write the text

		mov		cx, 1					; Set the print limit
		mov		ax, Yvar				; Move the Y varible into ax
		call	SBinToAscDec			; Convert to a signed decimal
		call	StrWrite				; Write the text

		jmp		Retry					; Go to Retry

; No Solution error
NoSolution:
		call	NewLine					; Skip to a new line
		mov		di, OFFSET prompt5		; Pull up the text **********************************************************
		call	StrWrite				; Write the text

; Retry the program
Retry:
		call	NewLine					; Start new display line

		mov		di, OFFSET redo			; Retry?
		call	StrWrite				; Print the string
		mov		di, OFFSET buffer		; Set the buffer
		mov		cx, 2					; Set the character limit
		call	StrRead					; Get the user's entry
		call	NewLine					; Start new display line
		mov		ax, buffer				; Set al equal to the user's entry
		and		ax, 11011111b			; Force it to uppercase

		cmp		ax, 'N'					; Check if it's N
		je		Next					; If N, finish the program
		jmp		CheckY					; Check for Y

; Check if there is a "Y" for the retry
CheckY:
		cmp		ax, 'Y'					; Check if it's y
		jnz		Retry					; Retry input
		jmp		GetNums					; If Y, go back to the begining

; End the program
Next:
		call	NewLine					; Start new display line
		mov		di, OFFSET exitTxt		; Exiting
		call	StrWrite				; Write text
		call	NewLine					; Start a new display line

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