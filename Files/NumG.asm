TITLE Number Guessing Game
;****************************************************************************
;* Title:   The Number Guessing Game                                        *
;* Purpose: This program thinks of a number and asks a user to guess it.    *
;****************************************************************************

        .MODEL  small
        STACK   256

;****************************************************************************
;* Equates Section                                                          *
;****************************************************************************

EOS     EQU 0					; End of string
maxLen  EQU 40					; Maximum entry string length

;****************************************************************************
;* Data Section                                                             *
;****************************************************************************
        .DATA

exCode   db 0                   ; DOS error code


answers  db 53,27,91,1,4        ; List of numbers to guess
gamectr  dw 0                   ; Game counter

answer   db (?)                 ; Holder for current correct answer
guess    db (?)                 ; Holder for user guess
howmany  dw (?)                 ; How many guesses did it take?

buffer	 db	maxLen dup (?)		; Input/Output buffer

prompt1	 db	'Welcome to the Number Guessing Game.',EOS	        ; Text
prompt2	 db	'Game #',EOS	                                    ; Text
prompt3	 db	'.',EOS	                                            ; Text
prompt4	 db	'I am thinking of a number from 1 to 100.',EOS	    ; Text
prompt5	 db	'What is your guess? ',EOS	                        ; Text
prompt6	 db	'That guess was too low',EOS	                    ; Text
prompt7	 db	'That guess was too high',EOS                   	; Text
prompt8	 db	'Correct! It took you ',EOS	                        ; Text
prompt9	 db	' guesses.',EOS	                                    ; Text
prompt10 db	'Would you like to play again? (Y/N)',EOS	        ; Text
prompt11 db	'Thank you for playing with me.',EOS				; Text
prompt12 db	'That answer is out of range, enter again. ',EOS	; Text



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
        mov     ax, @data           ; Initialize DS to address
        mov     ds, ax              ;  of data segment
        mov     es, ax              ; Make es = ds

;****************************************************************************
;* Print welcome message.                                                   *
;****************************************************************************

Welcome:
        call	NewLine			    ; Start new display line
	    call	NewLine			    ; Start new display line
	    mov	    di, OFFSET prompt1  ; Welcome
    	call	StrWrite		    ; Write text

		jmp		Newgame

;****************************************************************************
;* Prepare for new game.                                                    *
;*  - Increment game counter (gamectr)                                      *
;*  - Get next correct answer                                               *
;*  - Reset guess counter to zero (howmany)                                 *
;****************************************************************************

Newgame:
        inc     gamectr             ; Increment game counter and 
        mov     si, gamectr         ;   set source index register(si)
        dec     si                  ; Adjust for zero based list
        mov     al, answers[si]     ; Get next correct number from list
        mov     answer, al          ; Save it to answer
        mov     howmany, 0          ; Reset guess counter

		jmp		GameStart

;****************************************************************************
;* Print the start game messages                                            *
;****************************************************************************

GameStart:
        call	NewLine			    ; Start new display line
	    call	NewLine			    ; Start new display line
       	mov	    di, OFFSET prompt2	; Game #
	    call	StrWrite		    ; Write text

        mov	    di, OFFSET gamectr	; Get the game number
		call	AscToBin
	    call	StrWrite		    ; Print counter number

        mov	    di, OFFSET prompt3	; A period
	    call	StrWrite		    ; Write text

		call	NewLine			    ; Start new display line
        mov	    di, OFFSET prompt4	; Thinking of a number from 1 to 100
	    call	StrWrite		    ; Write text

        jmp	    GetGuess			; Jump to GetGuess

;****************************************************************************
;* Ask the user for his/her guess.                                          *
;****************************************************************************

GetGuess:
        call	NewLine			    ; Start new display line
        mov	    di, OFFSET prompt5	; What is your guess?
	    call	StrWrite			; Write text

		mov		di, OFFSET guess	; Guess gets user entry
	    call	StrRead				; Get entry from keyboard
		call	AscToBin

        jmp		CheckValid			; Jump to CheckValid

;****************************************************************************
;* Convert ascii input to binary                                            *
;*  - If user enter's invalid number, print error message and get another   *
;*       guess.                                                             *
;*  - 16 bit result will be in ax, but we only need the low 8 bits.         *
;*       So move al into guess.                                             *
;****************************************************************************

CheckValid:
		mov		al, guess
        cmp		al, 100
		jg		Invalid

		cmp		al, 1
		jl		Invalid
        jmp	    CheckCorrect		; Go to CheckCorrect if not invalid

Invalid:
		call	NewLine			    ; Start new display line
		mov		di, OFFSET prompt12	; Invalid answer
		call	StrWrite			; Write text

		jmp		GetGuess			; Jump to GetGuess

;****************************************************************************
;*  Check user's guess against correct answer.                              *
;*  - Add one to howmany (the guess counter)                                *
;*  - Compare user's guess and the correct answer                           *
;*  - Jump to the appropriate program section                               *
;****************************************************************************

CheckCorrect:
		mov		al, guess
        cmp     al, answer		; Compare the 1guess and the answer
		
		je		Correct				; Guess is correct path
        ja		TooHigh			    ; Guess is too high path
        jb		TooLow		        ; Guess is too low path

;****************************************************************************
;* Come here if guess is too high.                                          *
;****************************************************************************

TooHigh:
		call	NewLine			    ; Start new display line
        mov	    di, OFFSET prompt7	; Too high
	    call	StrWrite		    ; Write text
		inc		howmany				; Increase guesses counter

        jmp		GetGuess			; Guess again

;****************************************************************************
;* Come here if guess is too low.                                           *
;****************************************************************************

TooLow:
		call	NewLine			    ; Start new display line
        mov	    di, OFFSET prompt6	; Too low
	    call	StrWrite			; Write text
		inc		howmany				; Increase guesses counter

        jmp		GetGuess			; Guess again

;****************************************************************************
;* Come here if guess is correct.                                           *
;****************************************************************************

Correct:
		call	NewLine			    ; Start new display line
        mov	    di, OFFSET prompt8	; Correct
	    call	StrWrite			; Write text

        mov		ax, howmany			; Number of guesses
	    call	StrWrite			; Write text

        mov	    di, OFFSET prompt9	; Correct end
	    call	StrWrite			; Write text

        jmp		Redo				; Replay the game jump

;****************************************************************************
;* Ask if player wants another game.                                        *
;****************************************************************************

Redo:
		call	NewLine			    ; Start new display line
        mov	    di, OFFSET prompt10	; Replay?
	    call	StrWrite			; Write text

		mov		di, OFFSET buffer	; Point to buffer
		mov		cx, 2				; Text limiting to 2
		call	StrRead				; Get keyboard input
		cmp		buffer, 'Y'			; Check if the input is Y
		jnz		Redo2				; Continue on if true, jump to Redo2 if false
		jmp		NewGame				; Jump to the begining

Redo2:
		cmp		buffer, 'y'			; Check if the input is y
		jnz		Done				; Continue on if true, jump to exit if false
		jmp		NewGame				; Jump to the begining

;****************************************************************************
;* Program termination code.                                                *
;****************************************************************************

Done:
        mov     ah, 04Ch			; DOS function: Exit program
        mov     al, exCode			; Return exit code value
        int     21h					; Call DOS. Terminate program

        END     Start				; End of program / entry point