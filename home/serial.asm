Serial:: ; 2125 (0:2125)
	push af
	push bc
	push de
	push hl
	ldh a, [hSerialConnectionStatus]
	inc a
	jr z, .asm_2142
	ldh a, [rSB]
	ldh [hSerialReceiveData], a
	ldh a, [hSerialSendData]
	ldh [rSB], a
	ldh a, [hSerialConnectionStatus]
	cp $2
	jr z, .asm_2162
	ld a, $80
	ldh [rSC], a
	jr .asm_2162
.asm_2142
	ldh a, [rSB]
	ldh [hSerialReceiveData], a
	ldh [hSerialConnectionStatus], a
	cp $2
	jr z, .asm_215f
	xor a
	ldh [rSB], a
	ld a, $3
	ldh [rDIV], a ; $ff04
.asm_2153
	ldh a, [rDIV] ; $ff04
	bit 7, a
	jr nz, .asm_2153
	ld a, $80
	ldh [rSC], a
	jr .asm_2162
.asm_215f
	xor a
	ldh [rSB], a
.asm_2162
	ld a, $1
	ldh [hSerialReceivedNewData], a
	ld a, $fe
	ldh [hSerialSendData], a
	pop hl
	pop de
	pop bc
	pop af
	reti

Func_216f:: ; 216f (0:216f)
	ld a, 1
	ldh [hSerialIgnoringInitialData], a
.asm_2173
	ld a, [hl]
	ldh [hSerialSendData], a
	call Func_219a
	push bc
	ld b, a
	inc hl
	ld a, 48
.asm_217e
	dec a
	jr nz, .asm_217e
	ldh a, [hSerialIgnoringInitialData]
	and a
	ld a, b
	pop bc
	jr z, .asm_2192
	dec hl
	cp $fd
	jr nz, .asm_2173
	xor a
	ldh [hSerialIgnoringInitialData], a
	jr .asm_2173
.asm_2192
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .asm_2173
	ret

Func_219a:: ; 219a (0:219a)
	xor a
	ldh [hSerialReceivedNewData], a
	ldh a, [hSerialConnectionStatus]
	cp $2
	jr nz, .asm_21a7
	ld a, $81
	ldh [rSC], a
.asm_21a7
	ldh a, [hSerialReceivedNewData]
	and a
	jr nz, .asm_21f1
	ldh a, [hSerialConnectionStatus]
	cp $1
	jr nz, .asm_21cc
	call Func_2237
	jr z, .asm_21cc
	call Func_2231
	push hl
	ld hl, wcc48
	inc [hl]
	jr nz, .asm_21c3
	dec hl
	inc [hl]
.asm_21c3
	pop hl
	call Func_2237
	jr nz, .asm_21a7
	jp Func_223f
.asm_21cc
	ldh a, [rIE] ; $ffff
	and $f
	cp $8
	jr nz, .asm_21a7
	ld a, [W_NUMHITS] ; wd074
	dec a
	ld [W_NUMHITS], a ; wd074
	jr nz, .asm_21a7
	ld a, [wd075]
	dec a
	ld [wd075], a
	jr nz, .asm_21a7
	ldh a, [hSerialConnectionStatus]
	cp $1
	jr z, .asm_21f1
	ld a, 255
.asm_21ee
	dec a
	jr nz, .asm_21ee
.asm_21f1
	xor a
	ldh [hSerialReceivedNewData], a
	ldh a, [rIE] ; $ffff
	and $f
	sub $8
	jr nz, .asm_2204
	ld [W_NUMHITS], a ; wd074
	ld a, $50
	ld [wd075], a
.asm_2204
	ldh a, [hSerialReceiveData]
	cp $fe
	ret nz
	call Func_2237
	jr z, .asm_221f
	push hl
	ld hl, wcc48
	ld a, [hl]
	dec a
	ld [hld], a
	inc a
	jr nz, .asm_2219
	dec [hl]
.asm_2219
	pop hl
	call Func_2237
	jr z, Func_223f
.asm_221f
	ldh a, [rIE] ; $ffff
	and $f
	cp $8
	ld a, $fe
	ret z
	ld a, [hl]
	ldh [hSerialSendData], a
	call DelayFrame
	jp Func_219a

Func_2231:: ; 2231 (0:2231)
	ld a, 15
.asm_2233
	dec a
	jr nz, .asm_2233
	ret

Func_2237:: ; 2237 (0:2237)
	push hl
	ld hl, wcc47
	ld a, [hli]
	or [hl]
	pop hl
	ret

Func_223f:: ; 223f (0:223f)
	dec a
	ld [wcc47], a
	ld [wcc48], a
	ret

Func_2247:: ; 2247 (0:2247)
	ld hl, wcc42
	ld de, wcc3d
	ld c, 2
	ld a, 1
	ldh [hSerialIgnoringInitialData], a
.asm_2253
	call DelayFrame
	ld a, [hl]
	ldh [hSerialSendData], a
	call Func_219a
	ld b, a
	inc hl
	ldh a, [hSerialIgnoringInitialData]
	and a
	ld a, 0
	ldh [hSerialIgnoringInitialData], a
	jr nz, .asm_2253
	ld a, b
	ld [de], a
	inc de
	dec c
	jr nz, .asm_2253
	ret

Func_226e:: ; 226e (0:226e)
	call SaveScreenTilesToBuffer1
	callab PrintWaitingText
	call Func_227f
	jp LoadScreenTilesFromBuffer1

Func_227f:: ; 227f (0:227f)
	ld a, $ff
	ld [wcc3e], a
.asm_2284
	call Func_22c3
	call DelayFrame
	call Func_2237
	jr z, .asm_22a0
	push hl
	ld hl, wcc48
	dec [hl]
	jr nz, .asm_229f
	dec hl
	dec [hl]
	jr nz, .asm_229f
	pop hl
	xor a
	jp Func_223f
.asm_229f
	pop hl
.asm_22a0
	ld a, [wcc3e]
	inc a
	jr z, .asm_2284
	ld b, 10
.asm_22a8
	call DelayFrame
	call Func_22c3
	dec b
	jr nz, .asm_22a8
	ld b, 10
.asm_22b3
	call DelayFrame
	call Func_22ed
	dec b
	jr nz, .asm_22b3
	ld a, [wcc3e]
	ld [wcc3d], a
	ret

Func_22c3:: ; 22c3 (0:22c3)
	call asm_22d7
	ld a, [wcc42]
	add $60
	ldh [hSerialSendData], a
	ldh a, [hSerialConnectionStatus]
	cp $2
	jr nz, asm_22d7
	ld a, $81
	ldh [rSC], a
asm_22d7:: ; 22d7 (0:22d7)
	ldh a, [hSerialReceiveData]
	ld [wcc3d], a
	and $f0
	cp $60
	ret nz
	xor a
	ldh [hSerialReceiveData], a
	ld a, [wcc3d]
	and $f
	ld [wcc3e], a
	ret

Func_22ed:: ; 22ed (0:22ed)
	xor a
	ldh [hSerialSendData], a
	ldh a, [hSerialConnectionStatus]
	cp $2
	ret nz
	ld a, $81
	ldh [rSC], a
	ret

Func_22fa:: ; 22fa (0:22fa)
	ld a, $2
	ldh [rSB], a
	xor a
	ldh [hSerialReceiveData], a
	ld a, $80
	ldh [rSC], a
	ret
