TITLE Frequency Count
;****************************************************************************
;* Title:   Frequency Count                                                 *
;* Purpose: This program count letter frequencies in sentences              *
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

exCode   db     0																; DOS error code
titlestr db		'Frequency Count Program', EOS									; Text
prompt1	 db		'Enter a sentence.', EOS										; Text
prompt2	 db		'Your sentence is:', EOS										; Text
prompt3	 db		'Do you wish to process another string (Y/N)? ', EOS			; Text
header	 db		'Character    Frequency         Character    Frequency', EOS	; Text
lines	 db		'---------    ---------         ---------    ---------', EOS	; Text
spaces	 db		'            ', EOS												; Some spaces
spaces2	 db		'    ', EOS														; Some more spaces

buffer	  db		255 dup (?)													; The buffer
freqtable db		26  dup (?)													; The table
row		  dw		0															; A counter for the rows

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
;****************************************************************************
;* Start of Program                                                         *
;****************************************************************************
Start:  
        mov     ax, @data               ; Initialize DS to address
        mov     ds, ax                  ;  of data segment
        mov     es, ax                  ; Make es = ds

;	Print the title of the program
		call	NewLine					; Skip to the next line
		mov		di, OFFSET titlestr		; Get the header string
		call	StrWrite				; Print the string
		call	NewLine					; Skip to the next line

;	Get the string input
GetString:
		call	NewLine					; Skip to the next line
		mov		di, OFFSET prompt1		; Get the question string
		call	StrWrite				; Print the string
		call	NewLine					; Skip to the next line

		mov		di, OFFSET buffer		; Point to the user's entry
		mov		cx, 255					; Set the character limit
		call	StrRead					; Read the input

		call	NewLine					; Skip to the next line
		call	NewLine					; Skip to the next line again
		mov		di, OFFSET prompt2		; Point to some text
		call	StrWrite				; Print the string

		call	NewLine					; Skip to the next line
		mov		di, OFFSET buffer		; Point to the user's entry
		call	StrWrite				; Print the string
		call	NewLine					; Skip to the next line

;	Zero out freqtable
		mov		cx, 26					; Set the looping limit for zOut
		mov		si, 0					; Set the index to 0
		jmp		zOut					; Go to the zeroing loop

zOut:
		mov		freqtable[si], 0		; Set whatever the index points to, to 0
		inc		si						; Increase the counter by 1
		loop	zOut					; Loop this until you reach the limit

;	Build the frequency table
		mov		si, 0					; Set the index to 0

BuildTable:
		mov		al, buffer[si]			; al is now whatever letter si is pointing to
		cmp		al, EOS					; Check if al is at the end of the string
		je		startPrint				; If so, jump to the printing part

		and		al, 11011111b			; Force the letter to be capitalized
		sub		al, 'A'					; Subtract it with A
		cmp		al, 25					; Check if this is a letter
		ja		NextLetter				; Go to NextLetter if it's not a letter
		mov		ah, 0					; Set ah to 0
		mov		di, ax					; Set di to the current letter in ax
		inc		freqtable[di]			; Increase the count for this letter by 1

NextLetter:
		inc		si						; Increase the counter by 1
		jmp		BuildTable				; Go back to BuildTable
		
startPrint:
;	Print the headers
		call	NewLine					; Skip to the next line
		mov		di, OFFSET header		; Point to the tabhead string
		call	StrWrite				; Print the string
		call	NewLine					; Skip to the next line
		mov		di, OFFSET lines		; Point to the dashes string
		call	StrWrite				; Print the string
		call	NewLine					; Skip to the next line

;	Table Rows
		mov		row, 0					; Set row to 0

printLoop:
;	Do the left side
;	Print the letter
		mov		di, OFFSET spaces2		; Point some spaces
		call	StrWrite				; Print it
		mov		ax, row					; Set ax to the current letter's number
		add		al, 'A'					; Add al with an A
		mov		buffer, al				; Set the user entry to what's in al
		mov		buffer + 1, EOS			; Set the entry plus 1 to the EOS so nothing weird prints out
		mov		di, OFFSET buffer		; Point to the user's entry
		call	StrWrite				; Print the string

;	Print the spaces
		mov		di, OFFSET spaces		; Point to those spaces
		call	StrWrite				; Print the string

;	Print the count
		mov		si, row					; Set the index to row
		mov		al, freqtable[si]		; Set al equal to the value in freqtable that si is pointing to
		mov		ah, 0					; Set ah to 0
		mov		di, OFFSET buffer		; Point to the user's entry
		mov		cx, 1					; Set the print limit to 1
		call	BinToAscDec				; Convert the value from ASCII to Binary
		call	StrWrite				; Print the string

;	Do the right side
		mov		di, OFFSET spaces		; Point to those spaces
		call	StrWrite				; Print them
		mov		di, OFFSET spaces2		; Point to the smaller thing of spaces
		call	StrWrite				; Print that too

;	Print the letter
		mov		ax, row					; Set ax to the current letter's number
		add		ax, 13					; Add ax to 13 for the second half of letters
		add		al, 'A'					; Add al with A
		mov		buffer, al				; Set the user's entry equal to al
		mov		buffer + 1, EOS			; Set the entry plus 1 to EOS so nothing weird prints out
		mov		di, OFFSET buffer		; Point to the user's entry
		call	StrWrite				; Print the string
		
;	Print the spaces
		mov		di, OFFSET spaces		; Point to those spaces
		call	StrWrite				; Print the string

;	Print the count
		mov		si, row					; Set the index to row
		add		si, 13					; Add to 13 for the second half of letters
		mov		al, freqtable[si]		; Set al equal to the value in freqtable that si is pointing to
		mov		ah, 0					; Set ah to 0
		mov		di, OFFSET buffer		; Point to the user's entry
		mov		cx, 1					; Set the print limit to 1
		call	BinToAscDec				; Convert the value from ASCII to Decimal
		call	StrWrite				; Print the string

;	Increment for next row
		call	NewLine					; Skip to the next line
		inc		row						; Increment row by 1
		cmp		row, 13					; Compare row to the next 13 letter
		jae		Redo					; Go to the Replay section if there are no more letters
		jmp		printLoop				; Jump back to printLoop otherwise

Redo:
		call	NewLine					; Skip to the next line
		call	NewLine					; Skip to the next line again

;	Replay?
		mov		di, OFFSET prompt3		; Point to the prompt's string
		call	StrWrite				; Print the string
		mov		di, OFFSET buffer		; Get the user's entry
		mov		cx, 2					; Set the character limit
		call	StrRead					; Read it
		call	NewLine					; Skip to the next line
		mov		al, buffer				; Set al equal to the user's entry
		and		al, 11011111b			; Force it to uppercase

		cmp		al, 'N'					; Check if it's N
		je		Next					; If N, finish the program
		jmp		CheckY					; Check for Y

CheckY:
		cmp		al, 'Y'					; Check if it's y
		jnz		Redo					; Retry input
		jmp		GetString				; If Y, go back to the begining

Next:
		jmp		Done




       
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