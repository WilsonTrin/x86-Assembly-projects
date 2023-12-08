TITLE Calculator
;****************************************************************************
;* Title:   Calculator                                                      *
;* Purpose: This program acts as a basic calculator                         *
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

exCode   db     0													; DOS error code

buffer db maxLen dup (?)											; Buffer value

op1 dw 255															; Operand 1
op2 dw 255															; Operand 2
operation db 2 dup (?)												; Operation symbol
result dw 0															; The result

openingPrompt db 'My Calculator',EOS								; Text
prompt1 db 'Enter first number       : ',EOS						; Text
prompt2 db 'Enter second number      : ',EOS						; Text
prompt3 db 'Enter operation (+, -, C): ',EOS						; Text
prompt4 db 'The result is            : ',EOS						; Text
prompt5 db 'Do another calculation? (Y or N) ',EOS					; Text
prompt6 db '*** Invaid operation. Please re-enter. ***',EOS			; Text
prompt7 db 'Error - Signed result is too large.',EOS				; Text
prompt8 db '*** Invalid numeric input. Please re-enter. ***',EOS	; Text
prompt9 db 'The first number is larger than the second number',EOS	; Text
prompt10 db 'The second number is larger than the first number',EOS	; Text
prompt11 db 'These numbers are equal',EOS							; Text
prompt12 db 'Thank you.',EOS										; Text

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

; Print the title
Greeting:
	call	NewLine					; Start new display line
	call	NewLine					; Start new display line
	mov	di, OFFSET openingPrompt	; Title text
	call	StrWrite				; Write text

; Get the first number
GetEntry1:
	call	NewLine					; Start new display line
	mov di, OFFSET prompt1			; Enter first val
	call	StrWrite				; Write text

	mov	di, OFFSET buffer			; Buffer will get user's entry
	mov	cx, maxLen					; Maximum string length
	call	StrRead					; Get entry from keyboard

	call	AscToBin				; Convert the input to binary
	jnc		OK1						; Go to OK1 if it is a valid input (can't detect b, d, or h)
	call	NewLine					; Start a new display line
	mov	di, OFFSET prompt8			; Error text
	call	StrWrite				; Write the text
	jmp		GetEntry1				; Go back and get the input again

; Save value number 1
OK1:
	mov		op1, ax					; Save value 1

; Get the second value
GetEntry2:
	call	NewLine					; Start new display line
	mov di, OFFSET prompt2			; Enter second val
	call	StrWrite				; Write text

	mov	di, OFFSET buffer			; Buffer will get user's entry
	mov	cx, maxLen					; Maximum string length
	call	StrRead					; Get entry from keyboard

	call	AscToBin				; Convert the input to binary
	jnc		OK2						; Go to OK2 if it is a valid input (can't detect b, d, or h)
	call	NewLine					; Start a new display line
	mov	di, OFFSET prompt8			; Error text
	call	StrWrite				; Write the text
	jmp		GetEntry2				; Go back and get the input again

; Save value number 1
OK2:
	mov		op2, ax					; Save value 2

; Get the operation
GetEntry3:
	call	NewLine					; Start new display line
	mov di, OFFSET prompt3			; Enter the operation
	call	StrWrite				; Write text

	mov	di, OFFSET operation		; Point to operation var
	mov	cx, 2						; Limit the input to 2
	call	StrRead					; Get entry from keyboard

; Find what the operation is
CheckOper:
	cmp operation, '+'				; Check if the input is +
	jz		Adding					; Go to the add section

	cmp operation, '-'				; Check if the input is -
	jz		Subtract				; Go to the subtract section

	mov	al, operation

	and al, 11011111b				; Force caps
	cmp al, 'C'						; Check if the input is C
	jz		Compare					; Go to the compare section

	call	NewLine					; Start new display line
	mov di, OFFSET prompt6			; Error text
	call	StrWrite				; Write text
	jmp		GetEntry3				; Go to operation entry

; Add the numbers
Adding:
	mov ax, op1						; Make ax value 1
	add ax, op2						; Add ax to value 2
	jo		Overflow				; Go to redo
	mov	result, ax					; Put what is in ax into result

	call	NewLine					; Start new display line
	mov di, OFFSET prompt4			; Point to result text
	call	StrWrite				; Write text
	mov di, OFFSET buffer			; Point to result
	mov cx, 1						; Limit digits
	mov ax, result					; Move the result into ax
	call	SBinToAscDec			; Convert ASCII to decimal
	call	StrWrite				; Write text

	jmp		Redo					; Go to redo

; Subtract the numbers
Subtract:
	mov ax, op1						; Make ax value 1
	sub ax, op2						; Subtract ax with value 2
	jo		Overflow				; Go to redo
	mov result, ax					; Put what is in ax into result

	call	NewLine					; Start new display line
	mov di, OFFSET prompt4			; Point to result text
	call	StrWrite				; Write text
	mov di, OFFSET buffer			; Point to result
	mov cx, 1						; Limit digits
	mov ax, result					; Move result in ax	
	call	SBinToAscDec			; Convert ASCII to decimal
	call	StrWrite				; Write text

	jmp		Redo					; Go to redo

; Compare the numbers
Compare:
	mov	di, OFFSET buffer			; Point to buffer
	mov ax, op1						; Make ax value 1
	cmp ax, op2						; Compare values

	jg		C1						; First is bigger than second
	jl		C2						; Second is bigger than first
	je		C3						; Equal values
	jmp		Redo

; If the first number is bigger than the second
C1:
	call	NewLine					; Start new display line
	mov di, OFFSET prompt9			; Point to result text
	call	StrWrite				; Write text
	jmp		Redo					; Go to redo

; If the second number is bigger than the first
C2:
	call	NewLine					; Start new display line
	mov di, OFFSET prompt10			; Point to result text
	call	StrWrite				; Write text
	jmp		Redo					; Go to redo

; If both of the numbers are equal
C3:
	call	NewLine					; Start new display line
	mov di, OFFSET prompt11			; Point to result text
	call	StrWrite				; Write text
	jmp		Redo					; Go to redo4

; The overflow error
Overflow:
	call	NewLine					; Start new display line
	mov di, OFFSET prompt7			; Error text
	call	StrWrite				; Write text
	jmp		Redo					; Go to redo

; The retry prompt
Redo:
	call	NewLine					; Start new display line

	mov di, OFFSET prompt5			; Point to the prompt's string
	call	StrWrite				; Print the string
	mov di, OFFSET buffer			; Get the user's entry
	mov cx, 2						; Set the character limit
	call	StrRead					; Read it
	call	NewLine					; Start new display line
	mov al, buffer					; Set al equal to the user's entry
	and al, 11011111b				; Force it to uppercase

	cmp al, 'N'						; Check if it's N
	je		Next					; If N, finish the program
	jmp		CheckY					; Check for Y

; Check if there is a "Y" for the retry
CheckY:
	cmp al, 'Y'						; Check if it's y
	jnz		Redo					; Retry input
	jmp		GetEntry1				; If Y, go back to the begining

; Thank the user and end the program
Next:
	call	NewLine					; Start new display line
	mov	di, OFFSET prompt12			; Thank you
	call	StrWrite				; Write text
	call	NewLine					; Start new display line
	jmp		Done					; Finish program



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