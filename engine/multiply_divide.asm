_Multiply: ; 37d41 (d:7d41)
	ld a, $8
	ld b, a
	xor a
	ldh [H_DIVIDEND], a ; $ff95 (aliases: H_PRODUCT, H_PASTLEADINGZEROES, H_QUOTIENT)
	ldh [$ff9b], a
	ldh [H_SAVEDNUMTOPRINT], a ; $ff9c
	ldh [$ff9d], a
	ldh [$ff9e], a
.asm_37d4f
	ldh a, [H_REMAINDER] ; $ff99 (aliases: H_DIVISOR, H_MULTIPLIER, H_POWEROFTEN)
	srl a
	ldh [H_REMAINDER], a ; $ff99 (aliases: H_DIVISOR, H_MULTIPLIER, H_POWEROFTEN)
	jr nc, .asm_37d77
	ldh a, [$ff9e]
	ld c, a
	ldh a, [$ff98]
	add c
	ldh [$ff9e], a
	ldh a, [$ff9d]
	ld c, a
	ldh a, [$ff97]
	adc c
	ldh [$ff9d], a
	ldh a, [H_SAVEDNUMTOPRINT] ; $ff9c
	ld c, a
	ldh a, [H_NUMTOPRINT] ; $ff96 (aliases: H_MULTIPLICAND)
	adc c
	ldh [H_SAVEDNUMTOPRINT], a ; $ff9c
	ldh a, [$ff9b]
	ld c, a
	ldh a, [H_DIVIDEND] ; $ff95 (aliases: H_PRODUCT, H_PASTLEADINGZEROES, H_QUOTIENT)
	adc c
	ldh [$ff9b], a
.asm_37d77
	dec b
	jr z, .asm_37d94
	ldh a, [$ff98]
	sla a
	ldh [$ff98], a
	ldh a, [$ff97]
	rl a
	ldh [$ff97], a
	ldh a, [H_NUMTOPRINT] ; $ff96 (aliases: H_MULTIPLICAND)
	rl a
	ldh [H_NUMTOPRINT], a ; $ff96 (aliases: H_MULTIPLICAND)
	ldh a, [H_DIVIDEND] ; $ff95 (aliases: H_PRODUCT, H_PASTLEADINGZEROES, H_QUOTIENT)
	rl a
	ldh [H_DIVIDEND], a ; $ff95 (aliases: H_PRODUCT, H_PASTLEADINGZEROES, H_QUOTIENT)
	jr .asm_37d4f
.asm_37d94
	ldh a, [$ff9e]
	ldh [$ff98], a
	ldh a, [$ff9d]
	ldh [$ff97], a
	ldh a, [H_SAVEDNUMTOPRINT] ; $ff9c
	ldh [H_NUMTOPRINT], a ; $ff96 (aliases: H_MULTIPLICAND)
	ldh a, [$ff9b]
	ldh [H_DIVIDEND], a ; $ff95 (aliases: H_PRODUCT, H_PASTLEADINGZEROES, H_QUOTIENT)
	ret

_Divide: ; 37da5 (d:7da5)
	xor a
	ldh [$ff9a], a
	ldh [$ff9b], a
	ldh [H_SAVEDNUMTOPRINT], a ; $ff9c
	ldh [$ff9d], a
	ldh [$ff9e], a
	ld a, $9
	ld e, a
.asm_37db3
	ldh a, [$ff9a]
	ld c, a
	ldh a, [H_NUMTOPRINT] ; $ff96 (aliases: H_MULTIPLICAND)
	sub c
	ld d, a
	ldh a, [H_REMAINDER] ; $ff99 (aliases: H_DIVISOR, H_MULTIPLIER, H_POWEROFTEN)
	ld c, a
	ldh a, [H_DIVIDEND] ; $ff95 (aliases: H_PRODUCT, H_PASTLEADINGZEROES, H_QUOTIENT)
	sbc c
	jr c, .asm_37dce
	ldh [H_DIVIDEND], a ; $ff95 (aliases: H_PRODUCT, H_PASTLEADINGZEROES, H_QUOTIENT)
	ld a, d
	ldh [H_NUMTOPRINT], a ; $ff96 (aliases: H_MULTIPLICAND)
	ldh a, [$ff9e]
	inc a
	ldh [$ff9e], a
	jr .asm_37db3
.asm_37dce
	ld a, b
	cp $1
	jr z, .asm_37e18
	ldh a, [$ff9e]
	sla a
	ldh [$ff9e], a
	ldh a, [$ff9d]
	rl a
	ldh [$ff9d], a
	ldh a, [H_SAVEDNUMTOPRINT] ; $ff9c
	rl a
	ldh [H_SAVEDNUMTOPRINT], a ; $ff9c
	ldh a, [$ff9b]
	rl a
	ldh [$ff9b], a
	dec e
	jr nz, .asm_37e04
	ld a, $8
	ld e, a
	ldh a, [$ff9a]
	ldh [H_REMAINDER], a ; $ff99 (aliases: H_DIVISOR, H_MULTIPLIER, H_POWEROFTEN)
	xor a
	ldh [$ff9a], a
	ldh a, [H_NUMTOPRINT] ; $ff96 (aliases: H_MULTIPLICAND)
	ldh [H_DIVIDEND], a ; $ff95 (aliases: H_PRODUCT, H_PASTLEADINGZEROES, H_QUOTIENT)
	ldh a, [$ff97]
	ldh [H_NUMTOPRINT], a ; $ff96 (aliases: H_MULTIPLICAND)
	ldh a, [$ff98]
	ldh [$ff97], a
.asm_37e04
	ld a, e
	cp $1
	jr nz, .asm_37e0a
	dec b
.asm_37e0a
	ldh a, [H_REMAINDER] ; $ff99 (aliases: H_DIVISOR, H_MULTIPLIER, H_POWEROFTEN)
	srl a
	ldh [H_REMAINDER], a ; $ff99 (aliases: H_DIVISOR, H_MULTIPLIER, H_POWEROFTEN)
	ldh a, [$ff9a]
	rr a
	ldh [$ff9a], a
	jr .asm_37db3
.asm_37e18
	ldh a, [H_NUMTOPRINT] ; $ff96 (aliases: H_MULTIPLICAND)
	ldh [H_REMAINDER], a ; $ff99 (aliases: H_DIVISOR, H_MULTIPLIER, H_POWEROFTEN)
	ldh a, [$ff9e]
	ldh [$ff98], a
	ldh a, [$ff9d]
	ldh [$ff97], a
	ldh a, [H_SAVEDNUMTOPRINT] ; $ff9c
	ldh [H_NUMTOPRINT], a ; $ff96 (aliases: H_MULTIPLICAND)
	ldh a, [$ff9b]
	ldh [H_DIVIDEND], a ; $ff95 (aliases: H_PRODUCT, H_PASTLEADINGZEROES, H_QUOTIENT)
	ret
