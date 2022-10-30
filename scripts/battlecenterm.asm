BattleCenterMScript: ; 4fd10 (13:7d10)
	call EnableAutoTextBoxDrawing
	ldh a, [hSerialConnectionStatus]
	cp $2
	ld a, $8
	jr z, .asm_4fd1d ; 0x4fd19 $2
	ld a, $c
.asm_4fd1d
	ldh [hSpriteFacingDirection], a
	ld a, $1
	ldh [hSpriteIndex], a
	call SetSpriteFacingDirection
	ld hl, wd72d
	bit 0, [hl]
	set 0, [hl]
	ret nz
	ld hl, wSpriteStateData2 + $14
	ld a, 8
	ld [hli], a
	ld a, 10
	ld [hl], a
	ld a, $8
	ld [wSpriteStateData1 + $19], a
	ldh a, [hSerialConnectionStatus]
	cp $2
	ret z
	ld a, 7
	ld [wSpriteStateData2 + $15], a
	ld a, $c
	ld [wSpriteStateData1 + $19], a
	ret

BattleCenterMTextPointers: ; 4fd4c (13:7d4c)
	dw BattleCenterMText1

BattleCenterMText1: ; 4fd4e (13:7d4e)
	TX_FAR _BattleCenterMText1
	db "@"
