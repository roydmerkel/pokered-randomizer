_GetSpritePosition1: ; 567f9 (15:67f9)
	ld hl, wSpriteStateData1
	ld de, $4
	ld a, [wSpriteIndex]
	ldh [hSpriteIndex], a
	call GetSpriteDataPointer
	ld a, [hli]
	ldh [$ffeb], a
	inc hl
	ld a, [hl]
	ldh [$ffec], a
	ld de, $fe
	add hl, de
	ld a, [hli]
	ldh [$ffed], a
	ld a, [hl]
	ldh [$ffee], a
	ret

_GetSpritePosition2: ; 56819 (15:6819)
	ld hl, wSpriteStateData1
	ld de, $4
	ld a, [wSpriteIndex]
	ldh [hSpriteIndex], a
	call GetSpriteDataPointer
	ld a, [hli] ; c1x4 (screen Y pos)
	ld [wd130], a
	inc hl
	ld a, [hl] ; c1x6 (screen X pos)
	ld [wd131], a
	ld de, $104 - $6
	add hl, de
	ld a, [hli] ; c2x4 (map Y pos)
	ld [wd132], a
	ld a, [hl] ; c2x5 (map X pos)
	ld [wd133], a
	ret

_SetSpritePosition1: ; 5683d (15:683d)
	ld hl, wSpriteStateData1
	ld de, $4
	ld a, [wSpriteIndex]
	ldh [hSpriteIndex], a
	call GetSpriteDataPointer
	ldh a, [$ffeb] ; c1x4 (screen Y pos)
	ld [hli], a
	inc hl
	ldh a, [$ffec] ; c1x6 (screen X pos)
	ld [hl], a
	ld de, $104 - $6
	add hl, de
	ldh a, [$ffed] ; c2x4 (map Y pos)
	ld [hli], a
	ldh a, [$ffee] ; c2x5 (map X pos)
	ld [hl], a
	ret

_SetSpritePosition2: ; 5685d (15:685d)
	ld hl, wSpriteStateData1
	ld de, $0004
	ld a, [wSpriteIndex]
	ldh [hSpriteIndex], a
	call GetSpriteDataPointer
	ld a, [wd130]
	ld [hli], a
	inc hl
	ld a, [wd131]
	ld [hl], a
	ld de, $00fe
	add hl, de
	ld a, [wd132]
	ld [hli], a
	ld a, [wd133]
	ld [hl], a
	ret

TrainerWalkUpToPlayer: ; 56881 (15:6881)
	ld a, [wSpriteIndex]
	swap a
	ld [wTrainerSpriteOffset], a ; wWhichTrade
	call ReadTrainerScreenPosition
	ld a, [wTrainerFacingDirection]
	and a
	jr z, .facingDown
	cp $4
	jr z, .facingUp
	cp $8
	jr z, .facingLeft
	jr .facingRight
.facingDown
	ld a, [wTrainerScreenY]
	ld b, a
	ld a, $3c           ; (fixed) player screen Y pos
	call CalcDifference
	cp $10              ; trainer is right above player
	ret z
	swap a
	dec a
	ld c, a             ; bc = steps yet to go to reach player
	xor a
	ld b, a           ; a = direction to go to
	jr .writeWalkScript
.facingUp
	ld a, [wTrainerScreenY]
	ld b, a
	ld a, $3c           ; (fixed) player screen Y pos
	call CalcDifference
	cp $10              ; trainer is right below player
	ret z
	swap a
	dec a
	ld c, a             ; bc = steps yet to go to reach player
	ld b, $0
	ld a, $40           ; a = direction to go to
	jr .writeWalkScript
.facingRight
	ld a, [wTrainerScreenX]
	ld b, a
	ld a, $40           ; (fixed) player screen X pos
	call CalcDifference
	cp $10              ; trainer is directly left of player
	ret z
	swap a
	dec a
	ld c, a             ; bc = steps yet to go to reach player
	ld b, $0
	ld a, $c0           ; a = direction to go to
	jr .writeWalkScript
.facingLeft
	ld a, [wTrainerScreenX]
	ld b, a
	ld a, $40           ; (fixed) player screen X pos
	call CalcDifference
	cp $10              ; trainer is directly right of player
	ret z
	swap a
	dec a
	ld c, a             ; bc = steps yet to go to reach player
	ld b, $0
	ld a, $80           ; a = direction to go to
.writeWalkScript
	ld hl, wNPCMovementDirections2
	ld de, wNPCMovementDirections2
	call FillMemory     ; write the necessary steps to reach player
	ld [hl], $ff        ; write end of list sentinel
	ld a, [wSpriteIndex]
	ldh [hSpriteIndex], a
	jp MoveSprite_

; input: de = offset within sprite entry
; output: de = pointer to sprite data
GetSpriteDataPointer: ; 56903 (15:6903)
	push de
	add hl, de
	ldh a, [hSpriteIndex]
	swap a
	ld d, $0
	ld e, a
	add hl, de
	pop de
	ret

; tests if this trainer is in the right position to engage the player and do so if she is.
TrainerEngage: ; 5690f (15:690f)
	push hl
	push de
	ld a, [wTrainerSpriteOffset] ; wWhichTrade
	add $2
	ld d, $0
	ld e, a
	ld hl, wSpriteStateData1
	add hl, de
	ld a, [hl]             ; c1x2: sprite image index
	sub $ff
	jr nz, .spriteOnScreen ; test if sprite is on screen
	jp .noEngage
.spriteOnScreen
	ld a, [wTrainerSpriteOffset] ; wWhichTrade
	add $9
	ld d, $0
	ld e, a
	ld hl, wSpriteStateData1
	add hl, de
	ld a, [hl]             ; c1x9: facing direction
	ld [wTrainerFacingDirection], a
	call ReadTrainerScreenPosition
	ld a, [wTrainerScreenY]          ; sprite screen Y pos
	ld b, a
	ld a, $3c
	cp b
	jr z, .linedUpY
	ld a, [wTrainerScreenX]          ; sprite screen X pos
	ld b, a
	ld a, $40
	cp b
	jr z, .linedUpX
	xor a
	jp .noEngage
.linedUpY
	ld a, [wTrainerScreenX]        ; sprite screen X pos
	ld b, a
	ld a, $40            ; (fixed) player X position
	call CalcDifference  ; calc distance
	jr z, .noEngage      ; exact same position as player
	call CheckSpriteCanSeePlayer
	jr c, .engage
	xor a
	jr .noEngage
.linedUpX
	ld a, [wTrainerScreenY]        ; sprite screen Y pos
	ld b, a
	ld a, $3c            ; (fixed) player Y position
	call CalcDifference  ; calc distance
	jr z, .noEngage      ; exact same position as player
	call CheckSpriteCanSeePlayer
	jr c, .engage
	xor a
	jp .noEngage
.engage
	call CheckPlayerIsInFrontOfSprite
	ld a, [wTrainerSpriteOffset] ; wWhichTrade
	and a
	jr z, .noEngage
	ld hl, wFlags_0xcd60
	set 0, [hl]
	call EngageMapTrainer
	ld a, $ff
.noEngage: ; 56988 (15:6988)
	ld [wTrainerSpriteOffset], a ; wWhichTrade
	pop de
	pop hl
	ret

; reads trainer's Y position to wTrainerScreenY and X position to wTrainerScreenX
ReadTrainerScreenPosition: ; 5698e (15:698e)
	ld a, [wTrainerSpriteOffset] ; wWhichTrade
	add $4
	ld d, $0
	ld e, a
	ld hl, wSpriteStateData1
	add hl, de
	ld a, [hl]
	ld [wTrainerScreenY], a
	ld a, [wTrainerSpriteOffset] ; wWhichTrade
	add $6
	ld d, $0
	ld e, a
	ld hl, wSpriteStateData1
	add hl, de
	ld a, [hl]
	ld [wTrainerScreenX], a
	ret

; checks if the sprite is properly lined up with the player with respect to the direction it's looking. Also checks the distance between player and sprite
; note that this does not necessarily mean the sprite is seeing the player, he could be behind it's back
; a: distance player to sprite
CheckSpriteCanSeePlayer: ; 569af (15:69af)
	ld b, a
	ld a, [wTrainerEngageDistance]  ; sprite line of sight (engage distance)
	cp b
	jr nc, .checkIfLinedUp
	jr .notInLine         ; player too far away
.checkIfLinedUp
	ld a, [wTrainerFacingDirection]         ; sprite facing direction
	cp $0                 ; down
	jr z, .checkXCoord
	cp $4                 ; up
	jr z, .checkXCoord
	cp $8                 ; left
	jr z, .checkYCoord
	cp $c                 ; right
	jr z, .checkYCoord
	jr .notInLine
.checkXCoord
	ld a, [wTrainerScreenX]         ; sprite screen X position
	ld b, a
	cp $40
	jr z, .inLine
	jr .notInLine
.checkYCoord
	ld a, [wTrainerScreenY]         ; sprite screen Y position
	ld b, a
	cp $3c
	jr nz, .notInLine
.inLine
	scf
	ret
.notInLine
	and a
	ret

; tests if the player is in front of the sprite (rather than behind it)
CheckPlayerIsInFrontOfSprite: ; 569e3 (15:69e3)
	ld a, [W_CURMAP] ; W_CURMAP
	cp POWER_PLANT
	jp z, .engage       ; XXX not sure why bypass this for power plant (maybe to get voltorb fake items to work?)
	ld a, [wTrainerSpriteOffset] ; wWhichTrade
	add $4
	ld d, $0
	ld e, a
	ld hl, wSpriteStateData1
	add hl, de
	ld a, [hl]          ; c1x4 (sprite screen Y pos)
	cp $fc
	jr nz, .notOnTopmostTile ; special case if sprite is on topmost tile (Y = $fc (-4)), make it come down a block
	ld a, $c
.notOnTopmostTile
	ld [wTrainerScreenY], a
	ld a, [wTrainerSpriteOffset] ; wWhichTrade
	add $6
	ld d, $0
	ld e, a
	ld hl, wSpriteStateData1
	add hl, de
	ld a, [hl]          ; c1x6 (sprite screen X pos)
	ld [wTrainerScreenX], a
	ld a, [wTrainerFacingDirection]       ; facing direction
	cp $0
	jr nz, .notFacingDown
	ld a, [wTrainerScreenY]       ; sprite screen Y pos
	cp $3c
	jr c, .engage       ; sprite above player
	jr .noEngage        ; sprite below player
.notFacingDown
	cp $4
	jr nz, .notFacingUp
	ld a, [wTrainerScreenY]       ; sprite screen Y pos
	cp $3c
	jr nc, .engage      ; sprite below player
	jr .noEngage        ; sprite above player
.notFacingUp
	cp $8
	jr nz, .notFacingLeft
	ld a, [wTrainerScreenX]       ; sprite screen X pos
	cp $40
	jr nc, .engage      ; sprite right of player
	jr .noEngage        ; sprite left of player
.notFacingLeft
	ld a, [wTrainerScreenX]       ; sprite screen X pos
	cp $40
	jr nc, .noEngage    ; sprite right of player
.engage
	ld a, $ff
	jr .done
.noEngage
	xor a
.done
	ld [wTrainerSpriteOffset], a ; wWhichTrade
	ret
