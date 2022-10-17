_Joypad::
	ldh a, [hJoyInput]
	cp A_BUTTON + B_BUTTON + SELECT + START ; soft reset
	jp z, TrySoftReset
	ld b, a
	ldh a, [hJoyHeldLast]
	ld e, a
	xor b
	ld d, a
	and e
	ldh [hJoyReleased], a
	ld a, d
	and b
	ldh [hJoyPressed], a
	ld a, b
	ldh [hJoyHeldLast], a
	ld a, [wd730]
	bit 5, a
	jr nz, DiscardButtonPresses
	ldh a, [hJoyHeldLast]
	ldh [hJoyHeld], a
	ld a, [wJoyIgnore]
	and a
	ret z
	cpl
	ld b, a
	ldh a, [hJoyHeld]
	and b
	ldh [hJoyHeld], a
	ldh a, [hJoyPressed]
	and b
	ldh [hJoyPressed], a
	ret

DiscardButtonPresses:
	xor a
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ret

TrySoftReset:
	call DelayFrame
	; reset joypad (to make sure the
	; player is really trying to reset)
	ld a, $30
	ldh [rJOYP], a
	ld hl, hSoftReset
	dec [hl]
	jp z, SoftReset
	jp Joypad
