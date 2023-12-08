TITLE Computer Guess
;****************************************************************************
;* Title:   Computer Guess												    *
;* Purpose: The computer guesses the number you input using binary search   *
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

namestr	db 50 dup (?)															; String for the name
number	dw 50																	; The number guessed
lowv	dw 0																	; The low value
highv	dw 0																	; The high value
counter dw 0																	; The guess counter
ftable	db 11 dup (?)															; The frequency table
hotcold db 2 dup (?)															; The answer for whether the guess is low high or correct
buffer	dw maxLen dup (?)														; Buffer
row		dw 0																	; The row number for ftable

prompt1  db 'Welcome to the Number Guessing Game - Reverse!',EOS				; Text
prompt2  db 'Hello, my name is Hal. What',EOS									; Text
apostrophe db "'",EOS															; Text
prompt25 db 's your name? ',EOS													; Text
prompt3  db 'OK ',EOS															; Text
prompt4  db ', I',EOS															; Text
prompt45 db 'm ready to guess you number between 1 and 100.',EOS				; Text
prompt5  db 'Is your number ',EOS												; Text
prompt6  db '?',EOS																; Text
prompt7  db 'L = too low, H = too high, C = correct : ',EOS						; Text
prompt8  db 'It took me ',EOS													; Text
prompt9  db ' guesses.',EOS														; Text
prompt10 db 'Can we play again ',EOS											; Text
prompt11 db '? (Y or N) : ',EOS													; Text
prompt12 db 'Game Summary',EOS													; Text
prompt13 db 'Number of Guesses  Frequency',EOS									; Text
spaces	 db '       ',EOS														; Text
spaces2  db '               ',EOS												; Text

error    db 'I don',EOS															; Text
error2	 db 't understand that response',EOS									; Text
error3	 db 'Error, this is going out of bounds, the boundary is 1 - 100',EOS	; Text

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
		mov		di, OFFSET prompt1		; program intro
		call	StrWrite				; Write the text

		call	NewLine					; Skip to a new line
		mov		di, OFFSET prompt2		; Greeting
		call	StrWrite				; Write the text
		mov		di, OFFSET apostrophe	; Apostrophe
		call	StrWrite				; Write text
		mov		di, OFFSET prompt25		; Greeting end text
		call	StrWrite				; Write text

		mov		di, OFFSET namestr		; Point to the name
		call	StrRead					; Read the user's entry
		call	NewLine					; Skip to a new line

; Zero out freqtable
		mov		cx, 11					; Set the looping limit for zOut
		mov		si, 0					; Set the index to 0

zOut:
		mov		ftable[si], 0			; Set whatever the index points to, to 0
		inc		si						; Increase the counter by 1
		loop	zOut					; Loop this until you reach the limit
		mov		si, 0					; Set the index to 0

; The start of guessing
StartGuess:
		call	NewLine					; Start new display line
		mov		counter, 0				; Reset the counter
		mov		number, 50				; Reset the guess
		mov		ax, number				; Move into ax, number
		mov		lowv, 1					; Move into previous1, ax
		mov		highv, 100				; Move into previous2, ax

		mov		di, OFFSET prompt3		; Ok
		call	StrWrite				; Print the string
		mov		di, OFFSET namestr		; Get the name
		call	StrWrite				; Write the text
		mov		di, OFFSET prompt4		; I text
		call	StrWrite				; Write the text
		mov		di, OFFSET apostrophe	; Apostrophe
		call	StrWrite				; Write the text
		mov		di, OFFSET prompt45		; ready text
		call	StrWrite				; Write the text

; Computer starts guessing
Guessing:
		call	NewLine					; Start new display line
		mov		di, OFFSET prompt5		; Is your number text
		call	StrWrite				; Write text
		mov		di, OFFSET buffer		; Point to the buffer
		mov		cx, 1					; Make the print limit 1
		mov		ax, number				; Move the number into ax
		call	BinToAscDec				; Convert to Decimal
		call	StrWrite				; Write the tex
		mov		di, OFFSET prompt6		; ? text
		call	StrWrite				; Write the text

; Too low/high
HotColdFunction:
		call	NewLine					; Start new display line
		mov		di, OFFSET prompt7		; Intructions text
		call	StrWrite				; Write the text
		mov		di, OFFSET hotcold		; Point to hotcold
		call	StrRead					; Read the user's entry

		mov	al, hotcold
		and al, 11011111b				; Force caps

		cmp al, 'L'						; Check if the input is L
		jz		Cold					; Go to the compare section

		cmp al, 'H'						; Check if the input is H
		jz		Hot						; Go to the compare section

		cmp al, 'C'						; Check if the input is C
		jz		Correct					; Go to the compare section

		call	NewLine					; Start new display line
		mov di, OFFSET error			; Error text
		call	StrWrite				; Write text
		mov		di, OFFSET apostrophe	; Apostrophe
		call	StrWrite				; Write text
		mov		di, OFFSET error2		; The rest of the error text
		call	StrWrite				; Write text
		jmp		HotColdFunction			; Retry this function

; Too low
Cold:
		xor		dx, dx					; Clear dx
		mov		ax, number				; Move the number into ax
		inc		ax						; Increase ax by 1
		mov		lowv, ax				; Move ax into the low

		mov		bx, 2					; Move 2 into bx
		mov		ax, highv				; Move high into ax
		sub		ax, lowv				; Subtract low from ax
		div		bx						; Divide by bx
		add		ax, lowv				; Add low to ax
		mov		number, ax				; Move ax into the number
		inc		counter					; Increase counter by 1

		cmp		number, 1				; See if the number is too low
		jl		BoundaryLow				; Go to the error thing
		jmp		Guessing				; Go back to guessing

; Too high
Hot:	
		xor		dx, dx					; Clear dx
		mov		ax, number				; Move the number into ax
		dec		ax						; Increase ax by 1
		mov		highv, ax				; Move ax into the high

		mov		bx, 2					; Move 2 into bx
		mov		ax, highv				; Move high into ax
		sub		ax, lowv				; Subtract low from ax
		div		bx						; Divide by bx
		add		ax, lowv				; Add low to ax
		mov		number, ax				; Move ax into the number
		inc		counter					; Increase counter by 1

		cmp		number, 100				; See if the number is too high
		jg		BoundaryHigh			; Go to error thing
		jmp		Guessing				; Go back to guessing

BoundaryHigh:
		mov		di, OFFSET error3		; Error text
		call	StrWrite				; Write the text
		jmp		Retry					; Go to retry

BoundaryLow:
		mov		di, OFFSET error3		; Error text
		call	StrWrite				; Write the text
		jmp		Retry					; Go to retry

; Correct
Correct:
		inc		counter					; Increase the counter by 1
		call	NewLine					; Start new display line
		mov		di, OFFSET prompt8		; It took me text
		call	StrWrite				; Write text
		mov		di, OFFSET buffer		; Point to the buffer
		mov		cx, 1					; Set the print limit to 1
		mov		ax, counter				; Move counter into ax
		call	BinToAscDec				; Convert to decimal
		call	StrWrite				; Write text
		mov		di, OFFSET prompt9		; guesses text
		call	StrWrite				; Write text
		mov		di, counter				; Set di to the current count
		inc		ftable[di]				; Increase the frequency for this count by 1

; Retry the program
Retry:
		call	NewLine					; Start new display line

		mov		di, OFFSET prompt10		; Retry?
		call	StrWrite				; Print the string
		mov		di, OFFSET namestr		; Get the name
		call	StrWrite				; Write the text
		mov		di, OFFSET prompt11		; end of retry text
		call	StrWrite				; Write the text

		mov		di, OFFSET buffer		; Set the buffer
		mov		cx, 2					; Set the character limit
		call	StrRead					; Get the user's entry
		call	NewLine					; Start new display line
		mov		ax, buffer				; Set al equal to the user's entry
		and		ax, 11011111b			; Force it to uppercase

		cmp		ax, 'N'					; Check if it's N
		je		BeforePrint				; If N, print a table and finish the program
		jmp		CheckY					; Check for Y

; Check if there is a "Y" for the retry
CheckY:
		cmp		ax, 'Y'					; Check if it's y
		jnz		Retry					; Retry input
		jmp		StartGuess				; If Y, go back to the begining

; Print a table and end the program
BeforePrint:
		call	NewLine					; Skip to the next line
		mov		di, OFFSET prompt12		; Game summary text
		call	StrWrite				; Write the text
		call	NewLine					; Skip to the next line
		mov		di, OFFSET prompt13		; Num of guess frequency text
		call	StrWrite				; Write the text
		call	NewLine					; Skip to the next line

; Print the frequency table
Print:
; Print the spaces and count
		mov		di, OFFSET spaces		; Point to those spaces
		call	StrWrite				; Print the string
		mov		di, OFFSET buffer		; Point to the buffer
		mov		ax, row					; Put row in ax
		inc		ax						; Increase ax by 1 (row is 0 by default)
		mov		cx, 1
		call	BinToAscDec
		call	StrWrite				; Write the row number

; Print the frequency
		mov		di, OFFSET spaces2		; Point to those spaces
		call	StrWrite				; Print the string
		mov		si, row					; Set the index to row
		inc		si						; Increase the index by 1 (row is 0 by default)
		mov		al, ftable[si]			; Set al equal to the value in freqtable that si is pointing to
		mov		ah, 0					; Set ah to 0
		mov		di, OFFSET buffer		; Point to the buffer
		mov		cx, 1					; Set the print limit to 1
		call	BinToAscDec				; Convert the value from ASCII to Binary
		call	StrWrite				; Print the string

; Increment for next row
		call	NewLine					; Skip to the next line
		inc		row						; Increment row by 1
		cmp		row, 10					; Compare row to 10
		jae		Done					; Finish the program if there are no more numbers
		jmp		Print					; Jump back to printLoop otherwise
       
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