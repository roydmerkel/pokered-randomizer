FarCopyData::
; Copy bc bytes from a:hl to de.
	ld [wBuffer], a
	ldh a, [H_LOADEDROMBANK]
	push af
	ld a, [wBuffer]
	ldh [H_LOADEDROMBANK], a
	ld [MBC1RomBank], a
	call CopyData
	pop af
	ldh [H_LOADEDROMBANK], a
	ld [MBC1RomBank], a
	ret

CopyData::
; Copy bc bytes from hl to de.
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, CopyData
	ret

FarCopyData2::
; Identical to FarCopyData, but uses $ff8b
; as temp space instead of wBuffer.
	ldh [$ff8b],a
	ldh a,[H_LOADEDROMBANK]
	push af
	ldh a,[$ff8b]
	ldh [H_LOADEDROMBANK],a
	ld [MBC1RomBank],a
	call CopyData
	pop af
	ldh [H_LOADEDROMBANK],a
	ld [MBC1RomBank],a
	ret

