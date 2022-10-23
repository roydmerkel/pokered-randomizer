_Multiply: ; 37d41 (d:7d41)
	ld a, $8
	ld b, a
	xor a
	ldh [hProduct], a ; $ff95 (aliases: hProduct, hPastLeadingZeros, hQuotient)
	ldh [hMultiplyBuffer], a
	ldh [hMultiplyBuffer+1], a ; $ff9c
	ldh [hMultiplyBuffer+2], a
	ldh [hMultiplyBuffer+3], a
.asm_37d4f
	ldh a, [hMultiplier] ; $ff99 (aliases: hDivisor, hMultiplier, hPowerOf10)
	srl a
	ldh [hMultiplier], a ; $ff99 (aliases: hDivisor, hMultiplier, hPowerOf10)
	jr nc, .asm_37d77
	ldh a, [hMultiplyBuffer+3]
	ld c, a
	ldh a, [hMultiplicand+2]
	add c
	ldh [hMultiplyBuffer+3], a
	ldh a, [hMultiplyBuffer+2]
	ld c, a
	ldh a, [hMultiplicand+1]
	adc c
	ldh [hMultiplyBuffer+2], a
	ldh a, [hMultiplyBuffer+1] ; $ff9c
	ld c, a
	ldh a, [hMultiplicand] ; $ff96 (aliases: hMultiplicand)
	adc c
	ldh [hMultiplyBuffer+1], a ; $ff9c
	ldh a, [hMultiplyBuffer]
	ld c, a
	ldh a, [hProduct] ; $ff95 (aliases: hProduct, hPastLeadingZeros, hQuotient)
	adc c
	ldh [hMultiplyBuffer], a
.asm_37d77
	dec b
	jr z, .asm_37d94
	ldh a, [hMultiplicand+2]
	sla a
	ldh [hMultiplicand+2], a
	ldh a, [hMultiplicand+1]
	rl a
	ldh [hMultiplicand+1], a
	ldh a, [hMultiplicand] ; $ff96 (aliases: hMultiplicand)
	rl a
	ldh [hMultiplicand], a ; $ff96 (aliases: hMultiplicand)
	ldh a, [hProduct] ; $ff95 (aliases: hProduct, hPastLeadingZeros, hQuotient)
	rl a
	ldh [hProduct], a ; $ff95 (aliases: hProduct, hPastLeadingZeros, hQuotient)
	jr .asm_37d4f
.asm_37d94
	ldh a, [hMultiplyBuffer+3]
	ldh [hProduct+3], a
	ldh a, [hMultiplyBuffer+2]
	ldh [hProduct+2], a
	ldh a, [hMultiplyBuffer+1] ; $ff9c
	ldh [hProduct+1], a ; $ff96 (aliases: hMultiplicand)
	ldh a, [hMultiplyBuffer]
	ldh [hProduct], a ; $ff95 (aliases: hProduct, hPastLeadingZeros, hQuotient)
	ret

_Divide: ; 37da5 (d:7da5)
	xor a
	ldh [hDivideBuffer], a
	ldh [hDivideBuffer+1], a
	ldh [hDivideBuffer+2], a ; $ff9c
	ldh [hDivideBuffer+3], a
	ldh [hDivideBuffer+4], a
	ld a, $9
	ld e, a
.asm_37db3
	ldh a, [hDivideBuffer]
	ld c, a
	ldh a, [hDividend+1] ; $ff96 (aliases: hMultiplicand)
	sub c
	ld d, a
	ldh a, [hDivisor] ; $ff99 (aliases: hDivisor, hMultiplier, hPowerOf10)
	ld c, a
	ldh a, [hDividend] ; $ff95 (aliases: hProduct, hPastLeadingZeros, hQuotient)
	sbc c
	jr c, .asm_37dce
	ldh [hDividend], a ; $ff95 (aliases: hProduct, hPastLeadingZeros, hQuotient)
	ld a, d
	ldh [hDividend+1], a ; $ff96 (aliases: hMultiplicand)
	ldh a, [hDivideBuffer+4]
	inc a
	ldh [hDivideBuffer+4], a
	jr .asm_37db3
.asm_37dce
	ld a, b
	cp $1
	jr z, .asm_37e18
	ldh a, [hDivideBuffer+4]
	sla a
	ldh [hDivideBuffer+4], a
	ldh a, [hDivideBuffer+3]
	rl a
	ldh [hDivideBuffer+3], a
	ldh a, [hDivideBuffer+2] ; $ff9c
	rl a
	ldh [hDivideBuffer+2], a ; $ff9c
	ldh a, [hDivideBuffer+1]
	rl a
	ldh [hDivideBuffer+1], a
	dec e
	jr nz, .asm_37e04
	ld a, $8
	ld e, a
	ldh a, [hDivideBuffer]
	ldh [hDivisor], a ; $ff99 (aliases: hDivisor, hMultiplier, hPowerOf10)
	xor a
	ldh [hDivideBuffer], a
	ldh a, [hDividend+1] ; $ff96 (aliases: hMultiplicand)
	ldh [hDividend], a ; $ff95 (aliases: hProduct, hPastLeadingZeros, hQuotient)
	ldh a, [hDividend+2]
	ldh [hDividend+1], a ; $ff96 (aliases: hMultiplicand)
	ldh a, [hDividend+3]
	ldh [hDividend+2], a
.asm_37e04
	ld a, e
	cp $1
	jr nz, .asm_37e0a
	dec b
.asm_37e0a
	ldh a, [hDivisor] ; $ff99 (aliases: hDivisor, hMultiplier, hPowerOf10)
	srl a
	ldh [hDivisor], a ; $ff99 (aliases: hDivisor, hMultiplier, hPowerOf10)
	ldh a, [hDivideBuffer]
	rr a
	ldh [hDivideBuffer], a
	jr .asm_37db3
.asm_37e18
	ldh a, [hDividend+1] ; $ff96 (aliases: hMultiplicand)
	ldh [hRemainder], a ; $ff99 (aliases: hDivisor, hMultiplier, hPowerOf10)
	ldh a, [hDivideBuffer+4]
	ldh [hQuotient+3], a
	ldh a, [hDivideBuffer+3]
	ldh [hQuotient+2], a
	ldh a, [hDivideBuffer+2] ; $ff9c
	ldh [hQuotient+1], a ; $ff96 (aliases: hMultiplicand)
	ldh a, [hDivideBuffer+1]
	ldh [hDividend], a ; $ff95 (aliases: hProduct, hPastLeadingZeros, hQuotient)
	ret
