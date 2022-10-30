VBlank::

	push af
	push bc
	push de
	push hl

	ldh a, [hLoadedROMBank]
	ld [wd122], a

	ldh a, [hSCX]
	ldh [rSCX], a
	ldh a, [hSCY]
	ldh [rSCY], a

	ld a, [wd0a0]
	and a
	jr nz, .ok
	ldh a, [hWY]
	ldh [rWY], a
.ok

	call AutoBgMapTransfer
	call VBlankCopyBgMap
	call RedrawExposedScreenEdge
	call VBlankCopy
	call VBlankCopyDouble
	call UpdateMovingBgTiles
	call $ff80 ; hOAMDMA
	ld a, Bank(PrepareOAMData)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	call PrepareOAMData

	; VBlank-sensitive operations end.

	call Random

	ldh a, [H_VBLANKOCCURRED]
	and a
	jr z, .vblanked
	xor a
	ldh [H_VBLANKOCCURRED], a
.vblanked

	ldh a, [H_FRAMECOUNTER]
	and a
	jr z, .decced
	dec a
	ldh [H_FRAMECOUNTER], a
.decced

	;call Func_28cb


    call UpdateSound
;	ld a, [wAudioROMBank] ; music ROM bank
;	ldh [hLoadedROMBank], a
;	ld [MBC1RomBank], a
;
;	cp BANK(Music2_UpdateMusic)
;	jr nz, .notbank2
;.bank2
;	call Music2_UpdateMusic
;	jr .afterMusic
;.notbank2
;	cp BANK(Music8_UpdateMusic)
;	jr nz, .bank1F
;.bank8
;	call Func_2136e
;	call Music8_UpdateMusic
;	jr .afterMusic
;.bank1F
;	call Music1f_UpdateMusic
.afterMusic

	callba TrackPlayTime ; keep track of time played

	ldh a, [$fff9]
	and a
	call z, ReadJoypad

	ld a, [wd122]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a

	pop hl
	pop de
	pop bc
	pop af
	reti


DelayFrame::
; Wait for the next vblank interrupt.
; As a bonus, this saves battery.

NOT_VBLANKED EQU 1

	ld a, NOT_VBLANKED
	ldh [H_VBLANKOCCURRED], a
.halt
	halt
	ldh a, [H_VBLANKOCCURRED]
	and a
	jr nz, .halt
	ret
