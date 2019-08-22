;
; eeprom_rw.asm
;
; Created: 21/08/2019 10:02:06
; Author : Lucian Hanga
; Description:
;		Small POC on writting and reading from the EEPROM memory. Also in this poc there are other techniques
;		used such as reading from the PROG flash and initializing variables in the DATA iram
;
; Note:
;		Still have no clue why the EEPROM is not written with the initialization values from the .ESEG
;		need to investigate more how can the EEPROM be written when the debugging starts.


.include "m328def.inc"

.ESEG 
; constants in the EEPROM memory
evar1:		.db		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f
			.db		0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff

.DSEG
; variables in the data segment
var:		.byte	1			; reserve 1 byte for the variable 'value'
var2:		.byte	1			; reserve 1 byte for the value which will be read from EEPROM
.CSEG
		rjmp	start

cvar:		.db		0x12, 0x34		; constant for the 'value' initialization value

start:
		; initialize the variables
		; initialze the var with the constant from the code segment
		ldi		ZL, low(2*cvar)		; the prog FLASH is addressed as 16bit addresses. This is the reason the address should be
		ldi		ZH, high(2*cvar)	; multiplied with 2.
		lpm
		; load the value which should be written into EEPROM:0x0000 in the eeprom data register EEDR
		ldi		ZL, low(var)		; load in the Z register (r31:r30) the address of the variable
		ldi		ZH, high(var)		;
		st		Z, r0
 
;
;
; POC for the EEPRO write routine
;
;

EEPROM_write:
		;
		; wait for the completion of the previous write
		; EECR - eeprom control register.  0x1F - if addressed with LD/ST add 0x20
		; EEPE - EECR eeprom write enable bit mask 0b00000001
		sbic	EECR, EEPE			; skip next instruction when the bit EEPE cleared in EECR (I/O registers)
		rjmp	EEPROM_write		; relative jump. loop to wait for EEPE from EECR to be cleared
		; setup the address in the EEPROM the address where to write the value of the variable var
		ldi		r18, 0x00			; load the address 0x0000 to the (r18:r17) registers
		ldi		r17, 0x00
		out		EEARH, r18			; write in the EEARH:EEARL the address 0x0000
		out		EEARL, r17
		; load in r0 register the value which has to be written to EEPROM
		ldi		ZL, low(var)		; load in the Z register (r31:r30) the address of the variable
		ldi		ZH, high(var)		;
		ld		r0, Z				; load the value of the variable 'value' into the r1 register
		out		EEDR, r0			; write the value in the eeprom data register EEDR
		; trigger the writing of the EEPROM
		cli							; mask the interrupt flag; so the write process is not interrupted
		sbi		EECR, EEMPE			; set the eeprom master write enable EEMPE bit. set the bit with mask 0b00000100
		sbi		EECR, EEPE			; set the eeprom write to trigger the writting
EEPROM_writting_in_progress:
		nop
		sbic	EECR, EEPE			; skip next instruction when the bit EEPE cleared in EECR (I/O registers)
		rjmp	EEPROM_writting_in_progress
EEPROM_endwrite:
		sei							; reneable interrupts; NOTE: not sure yet if it should be here or imediatelly after the 'sbi EECR, EEPE' command
		; if the interupts were disbled enable them back


;
;
; POC for the EEPROM read routine
;
;
.equ	eeprom_read_address = 0x0000	; define the address in the EEPROM from where the value should be read

EEPROM_ready_read:
		sbic	EECR, EEPE		; check if any write is in progress. if the EEPE bit is cleared skip next instuction
		rjmp	EEPROM_ready_read
		ldi		r18, high(eeprom_read_address)	; load in the registers (r18:r17) of the EEPROM address
 		ldi		r17, low(eeprom_read_address)
		out		EEARH, r18		; load the address in the EEPROM Adress Register 
		out		EEARL, r17
		cli						; mask all the interrupts
		sbi		EECR, EERE		; set the bit for reading from EEPROM; after this instruction the data should be read into the EEDR
		in		r1, EEDR		; get the data into the r1 register 
		sei						; enable interrupts
		ldi		ZL, low(var2)	; load the address of hte var2 into the Z register
		ldi		ZH, high(var2)	;
		st		Z, r1			; write the data from the register at the Z address







