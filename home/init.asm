SoftReset::
	call StopAllSounds
	call GBPalWhiteOut
	ld c, 32
	call DelayFrames
	; fallthrough

Init::
;  Program init.

rLCDC_DEFAULT EQU %11100011
; * LCD enabled
; * Window tile map at $9C00
; * Window display enabled
; * BG and window tile data at $8800
; * BG tile map at $9800
; * 8x8 OBJ size
; * OBJ display enabled
; * BG display enabled

	di

	xor a
	ldh [rIF], a
	ldh [rIE], a
	ldh [rSCX], a
	ldh [rSCY], a
	ldh [rSB], a
	ldh [rSC], a
	ldh [rWX], a
	ldh [rWY], a
	ldh [rTMA], a
	ldh [rTAC], a
	ldh [rBGP], a
	; only commenting these out because I need some space lol
	;ldh [rOBP0], a
	;ldh [rOBP1], a

	ld a, rLCDC_ENABLE_MASK
	ldh [rLCDC], a
	call DisableLCD

	ld sp, wStack

	ld hl, $c000 ; start of WRAM
	ld bc, $2000 ; size of WRAM
.loop
	ld [hl], 0
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .loop

	call ClearVram

	ld hl, $ff80
	ld bc, $ffff - $ff80
	call FillMemory

	call ClearSprites

	ld a, Bank(WriteDMACodeToHRAM)
	ldh [H_LOADEDROMBANK], a
	ld [MBC1RomBank], a
	call WriteDMACodeToHRAM

	xor a
	ldh [hTilesetType], a
	ldh [rSTAT], a
	ldh [hSCX], a
	ldh [hSCY], a
	ldh [rIF], a
	ld a, 1 << VBLANK + 1 << TIMER + 1 << SERIAL
	ldh [rIE], a

	ld a, 144 ; move the window off-screen
	ldh [hWY], a
	ldh [rWY], a
	ld a, 7
	ldh [rWX], a

	ld a, $ff
	ldh [hSerialConnectionStatus], a

	ld h, vBGMap0 / $100
	call ClearBgMap
	ld h, vBGMap1 / $100
	call ClearBgMap

	ld a, rLCDC_DEFAULT
	ldh [rLCDC], a
	ld a, 16
	ldh [hSoftReset], a
	call StopAllSounds

	ei

	predef LoadSGB

	ld a, 0 ; BANK(SFX_1f_67)
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a
	ld a, $9c
	ldh [$ffbd], a
	xor a
	ldh [$ffbc], a
	dec a
	ld [wUpdateSpritesEnabled], a
	predef PlayIntro

	call DisableLCD
	call ClearVram
	call GBPalNormal
	call ClearSprites
	ld a, rLCDC_DEFAULT
	ldh [rLCDC], a

	jp SetDefaultNamesBeforeTitlescreen

ClearVram:
	ld hl, $8000
	ld bc, $2000
	xor a
	jp FillMemory


StopAllSounds::
    call OpenSRAMForSound
    ld hl, MusicPlaying
	ld bc, (wChannelSelectorSwitches+8) - Crysaudio
	call FillMemory
    
    
    
	ld a, 0 ; BANK(Music2_UpdateMusic)
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a
	xor a
	ld [wMusicHeaderPointer], a
	ld [wNewSoundID], a
	ld [wcfca], a
	dec a
	jp PlaySound
