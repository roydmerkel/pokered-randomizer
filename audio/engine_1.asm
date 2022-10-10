; The first of three duplicated sound engines.

Music2_UpdateMusic:: ; 0x9103
	ld c, CHAN1
.loop
	ld b, 0
	ld hl, wChannelSoundIDs
	add hl, bc
	ld a, [hl]
	and a
	jr z, .nextChannel
	ld a, c
	cp CHAN5
	jr nc, .asm_912e ; if sfx channel
	ld a, [wMuteAudioAndPauseMusic]
	and a
	jr z, .asm_912e
	bit 7, a
	jr nz, .nextChannel
	set 7, a
	ld [wMuteAudioAndPauseMusic], a
	xor a
	ldh [rNR51], a
	ldh [rNR30], a
	ld a, $80
	ldh [rNR30], a
	jr .nextChannel
.asm_912e
	call Music2_ApplyMusicAffects
.nextChannel
	ld a, c
	inc c ; inc channel number
	cp CHAN8
	jr nz, .loop
	ret

; this routine checks flags for music effects currently applied
; to the channel and calls certain functions based on flags.
; known flags for wChannelFlags1:
;	0: toggleperfectpitch has been used
;	1: call has been used
;	3: a toggle used only by this routine for vibrato
;	4: pitchbend flag
;	6: dutycycle flag
Music2_ApplyMusicAffects: ; 0x9138
	ld b, $0
	ld hl, wChannelNoteDelayCounters ; delay until next note
	add hl, bc
	ld a, [hl]
	cp 1 ; if the delay is 1, play next note
	jp z, Music2_PlayNextNote
	dec a ; otherwise, decrease the delay timer
	ld [hl], a
	ld a, c
	cp CHAN5
	jr nc, .startChecks ; if a sfx channel
	ld hl, wc02a
	add hl, bc
	ld a, [hl]
	and a
	jr z, .startChecks
	ret
.startChecks
	ld hl, wChannelFlags1
	add hl, bc
	bit BIT_ROTATE_DUTY_CYCLE, [hl] ; dutycycle
	jr z, .checkForExecuteMusic
	call Music2_ApplyDutyCycle
.checkForExecuteMusic
	ld b, 0
	ld hl, wChannelFlags2
	add hl, bc
	bit BIT_EXECUTE_MUSIC, [hl]
	jr nz, .checkForPitchBend
	ld hl, wChannelFlags1
	add hl, bc
	bit BIT_NOISE_OR_SFX, [hl]
	jr nz, .disablePitchBendVibrato
.checkForPitchBend
	ld hl, wChannelFlags1
	add hl, bc
	bit BIT_PITCH_SLIDE_ON, [hl] ; pitchbend
	jr z, .checkVibratoDelay
	jp Music2_ApplyPitchBend
.checkVibratoDelay
	ld hl, wChannelVibratoDelayCounters ; vibrato delay
	add hl, bc
	ld a, [hl]
	and a ; check if delay is over
	jr z, .checkForVibrato
	dec [hl] ; otherwise, dec delay
.disablePitchBendVibrato
	ret
.checkForVibrato
	ld hl, wChannelVibratoExtents ; vibrato rate
	add hl, bc
	ld a, [hl]
	and a
	jr nz, .vibrato
	ret ; no vibrato
.vibrato
	ld d, a
	ld hl, wChannelVibratoRates
	add hl, bc
	ld a, [hl]
	and $f
	and a
	jr z, .vibratoAlreadyDone
	dec [hl] ; apply vibrato pitch change
	ret
.vibratoAlreadyDone
	ld a, [hl]
	swap [hl]
	or [hl]
	ld [hl], a ; reset the vibrato value and start again
	ld hl, wChannelFrequencyLowBytes
	add hl, bc
	ld e, [hl] ; get note pitch
	ld hl, wChannelFlags1
	add hl, bc
	bit BIT_VIBRATO_DIRECTION, [hl] ; this is the only code that sets/resets bit three so
	jr z, .unset ; it continuously alternates which path it takes
	res BIT_VIBRATO_DIRECTION, [hl]
	ld a, d
	and $f
	ld d, a
	ld a, e
	sub d
	jr nc, .noCarry
	ld a, 0
.noCarry
	jr .done
.unset
	set BIT_VIBRATO_DIRECTION, [hl]
	ld a, d
	and $f0
	swap a
	add e
	jr nc, .done
	ld a, $ff
.done
	ld d, a
	ld b, REG_FREQUENCY_LO
	call Func_9838
	ld [hl], d
	ret

; this routine executes all music commands that take up no time,
; like tempo changes, duty changes etc. and doesn't return
; until the first note is reached
Music2_PlayNextNote ; 0x91d0
	ld hl, wChannelVibratoDelayCounterReloadValues
	add hl, bc
	ld a, [hl]
	ld hl, wChannelVibratoDelayCounters
	add hl, bc
	ld [hl], a
	ld hl, wChannelFlags1
	add hl, bc
	res BIT_PITCH_SLIDE_ON, [hl]
	res BIT_PITCH_SLIDE_DECREASING, [hl]
	call Music2_endchannel
	ret

Music2_endchannel: ; 0x91e6
	call Music2_GetNextMusicByte
	ld d, a
	cp $ff ; is this command an endchannel?
	jp nz, Music2_callchannel ; no
	ld b, 0 ; yes
	ld hl, wChannelFlags1
	add hl, bc
	bit BIT_SOUND_CALL, [hl]
	jr nz, .returnFromCall
	ld a, c
	cp CHAN4
	jr nc, .noiseOrSfxChannel
	jr .asm_923f
.noiseOrSfxChannel
	res BIT_NOISE_OR_SFX, [hl]
	ld hl, wChannelFlags2
	add hl, bc
	res BIT_EXECUTE_MUSIC, [hl]
	cp CHAN7
	jr nz, .notSfxChannel3
	ld a, $0
	ldh [rNR30], a
	ld a, $80
	ldh [rNR30], a
.notSfxChannel3
	jr nz, .asm_9222
	ld a, [wDisableChannelOutputWhenSfxEnds]
	and a
	jr z, .asm_9222
	xor a
	ld [wDisableChannelOutputWhenSfxEnds], a
	jr .asm_923f
.asm_9222
	jr .asm_9248
.returnFromCall
	res 1, [hl]
	ld d, $0
	ld a, c
	add a
	ld e, a
	ld hl, wChannelCommandPointers
	add hl, de
	push hl ; store current channel address
	ld hl, wChannelReturnAddresses
	add hl, de
	ld e, l
	ld d, h
	pop hl
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hl], a ; loads channel address to return to
	jp Music2_endchannel
.asm_923f
	ld hl, Unknown_9b1f
	add hl, bc
	ldh a, [rNR51]
	and [hl]
	ldh [rNR51], a
.asm_9248
	ld a, [wc02a]
	cp CRY_SFX_START
	jr nc, .asm_9251
	jr .asm_926e
.asm_9251
	ld a, [wc02a]
	cp CRY_SFX_END
	jr z, .asm_926e
	jr c, .asm_925c
	jr .asm_926e
.asm_925c
	ld a, c
	cp CHAN5
	jr z, .asm_9265
	call Func_96c7
	ret c
.asm_9265
	ld a, [wSavedVolume]
	ldh [rNR50], a
	xor a
	ld [wSavedVolume], a
.asm_926e
	ld hl, wChannelSoundIDs
	add hl, bc
	ld [hl], b
	ret

Music2_callchannel: ; 0x9274
	cp $fd ; is this command a callchannel?
	jp nz, Music2_loopchannel ; no
	call Music2_GetNextMusicByte ; yes
	push af
	call Music2_GetNextMusicByte
	ld d, a
	pop af
	ld e, a
	push de ; store pointer
	ld d, $0
	ld a, c
	add a
	ld e, a
	ld hl, wChannelCommandPointers
	add hl, de
	push hl
	ld hl, wChannelReturnAddresses
	add hl, de
	ld e, l
	ld d, h
	pop hl
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hld]
	ld [de], a ; copy current channel address
	pop de
	ld [hl], e
	inc hl
	ld [hl], d ; overwrite current address with pointer
	ld b, $0
	ld hl, wChannelFlags1
	add hl, bc
	set BIT_SOUND_CALL, [hl] ; set the call flag
	jp Music2_endchannel

Music2_loopchannel: ; 0x92a9
	cp $fe ; is this command a loopchannel?
	jp nz, Music2_notetype ; no
	call Music2_GetNextMusicByte ; yes
	ld e, a
	and a
	jr z, .infiniteLoop
	ld b, 0
	ld hl, wChannelLoopCounters
	add hl, bc
	ld a, [hl]
	cp e
	jr nz, .loopAgain
	ld a, $1 ; if no more loops to make,
	ld [hl], a
	call Music2_GetNextMusicByte ; skip pointer
	call Music2_GetNextMusicByte
	jp Music2_endchannel
.loopAgain ; inc loop count
	inc a
	ld [hl], a
	; fall through
.infiniteLoop ; overwrite current address with pointer
	call Music2_GetNextMusicByte
	push af
	call Music2_GetNextMusicByte
	ld b, a
	ld d, $0
	ld a, c
	add a
	ld e, a
	ld hl, wChannelCommandPointers
	add hl, de
	pop af
	ld [hli], a
	ld [hl], b
	jp Music2_endchannel

Music2_notetype: ; 0x92e4
	and $f0
	cp $d0 ; is this command a notetype?
	jp nz, Music2_toggleperfectpitch ; no
	ld a, d ; yes
	and $f
	ld b, $0
	ld hl, wChannelNoteSpeeds
	add hl, bc
	ld [hl], a ; store low nibble as speed
	ld a, c
	cp CHAN4
	jr z, .noiseChannel ; noise channel has 0 params
	call Music2_GetNextMusicByte
	ld d, a
	ld a, c
	cp CHAN3
	jr z, .musicChannel3
	cp CHAN7
	jr nz, .notChannel3
	ld hl, wSfxWaveInstrument
	jr .sfxChannel3
.musicChannel3
	ld hl, wMusicWaveInstrument
.sfxChannel3
	ld a, d
	and $f
	ld [hl], a ; store low nibble of param as duty
	ld a, d
	and $30
	sla a
	ld d, a
	; fall through

	; if channel 3, store high nibble as volume
	; else, store volume (high nibble) and fade (low nibble)
.notChannel3
	ld b, 0
	ld hl, wChannelVolumes
	add hl, bc
	ld [hl], d
.noiseChannel
	jp Music2_endchannel

Music2_toggleperfectpitch: ; 0x9323
	ld a, d
	cp $e8 ; is this command a toggleperfectpitch?
	jr nz, Music2_vibrato ; no
	ld b, 0 ; yes
	ld hl, wChannelFlags1
	add hl, bc
	ld a, [hl]
	xor $1
	ld [hl], a ; flip bit 0 of wChannelFlags1
	jp Music2_endchannel

Music2_vibrato: ; 0x9335
	cp $ea ; is this command a vibrato?
	jr nz, Music2_pitchbend ; no
	call Music2_GetNextMusicByte ; yes
	ld b, 0
	ld hl, wChannelVibratoDelayCounters
	add hl, bc
	ld [hl], a ; store delay
	ld hl, wChannelVibratoDelayCounterReloadValues
	add hl, bc
	ld [hl], a ; store delay
	call Music2_GetNextMusicByte
	ld d, a
	and $f0
	swap a
	ld b, 0
	ld hl, wChannelVibratoExtents
	add hl, bc
	srl a
	ld e, a
	adc b
	swap a
	or e
	ld [hl], a ; store rate as both high and low nibbles
	ld a, d
	and $f
	ld d, a
	ld hl, wChannelVibratoRates
	add hl, bc
	swap a
	or d
	ld [hl], a ; store depth as both high and low nibbles
	jp Music2_endchannel

Music2_pitchbend: ; 0x936d
	cp $eb ; is this command a pitchbend?
	jr nz, Music2_duty ; no
	call Music2_GetNextMusicByte ; yes
	ld b, 0
	ld hl, wChannelPitchSlideLengthModifiers
	add hl, bc
	ld [hl], a ; store first param
	call Music2_GetNextMusicByte
	ld d, a
	and $f0
	swap a
	ld b, a
	ld a, d
	and $f
	call Func_9858
	ld b, 0
	ld hl, wChannelPitchSlideTargetFrequencyHighBytes
	add hl, bc
	ld [hl], d ; store unknown part of second param
	ld hl, wChannelPitchSlideTargetFrequencyLowBytes
	add hl, bc
	ld [hl], e ; store unknown part of second param
	ld b, 0
	ld hl, wChannelFlags1
	add hl, bc
	set BIT_PITCH_SLIDE_ON, [hl] ; set pitchbend flag
	call Music2_GetNextMusicByte
	ld d, a
	jp Music2_notelength

Music2_duty: ; 0x93a5
	cp $ec ; is this command a duty?
	jr nz, Music2_tempo ; no
	call Music2_GetNextMusicByte ; yes
	rrca
	rrca
	and $c0
	ld b, 0
	ld hl, wChannelDutyCycles
	add hl, bc
	ld [hl], a ; store duty
	jp Music2_endchannel

Music2_tempo: ; 0x93ba
	cp $ed ; is this command a tempo?
	jr nz, Music2_stereopanning ; no
	ld a, c ; yes
	cp CHAN5
	jr nc, .sfxChannel
	call Music2_GetNextMusicByte
	ld [wMusicTempo], a ; store first param
	call Music2_GetNextMusicByte
	ld [wc0e9], a ; store second param
	xor a
	ld [wChannelNoteDelayCountersFractionalPart], a ; clear RAM
	ld [wc0cf], a
	ld [wc0d0], a
	ld [wc0d1], a
	jr .musicChannelDone
.sfxChannel
	call Music2_GetNextMusicByte
	ld [wSfxTempo], a ; store first param
	call Music2_GetNextMusicByte
	ld [wc0eb], a ; store second param
	xor a
	ld [wc0d2], a ; clear RAM
	ld [wc0d3], a
	ld [wc0d4], a
	ld [wc0d5], a
.musicChannelDone
	jp Music2_endchannel

Music2_stereopanning: ; 0x93fa
	cp $ee ; is this command a stereopanning?
	jr nz, Music2_unknownmusic0xef ; no
	call Music2_GetNextMusicByte ; yes
	ld [wStereoPanning], a ; store panning
	jp Music2_endchannel

; this appears to never be used
Music2_unknownmusic0xef ; 0x9407
	cp $ef ; is this command an unknownmusic0xef?
	jr nz, Music2_dutycycle ; no
	call Music2_GetNextMusicByte ; yes
	push bc
	call Func_9876
	pop bc
	ld a, [wDisableChannelOutputWhenSfxEnds]
	and a
	jr nz, .skip
	ld a, [wc02d]
	ld [wDisableChannelOutputWhenSfxEnds], a
	xor a
	ld [wc02d], a
.skip
	jp Music2_endchannel

Music2_dutycycle: ; 0x9426
	cp $fc ; is this command a dutycycle?
	jr nz, Music2_volume ; no
	call Music2_GetNextMusicByte ; yes
	ld b, 0
	ld hl, wChannelDutyCyclePatterns
	add hl, bc
	ld [hl], a ; store full cycle
	and $c0
	ld hl, wChannelDutyCycles
	add hl, bc
	ld [hl], a ; store first duty
	ld hl, wChannelFlags1
	add hl, bc
	set BIT_ROTATE_DUTY_CYCLE, [hl] ; set dutycycle flag
	jp Music2_endchannel

Music2_volume: ; 0x9444
	cp $f0 ; is this command a volume?
	jr nz, Music2_executemusic ; no
	call Music2_GetNextMusicByte ; yes
	ldh [rNR50], a ; store volume
	jp Music2_endchannel

Music2_executemusic: ; 0x9450
	cp $f8 ; is this command an executemusic?
	jr nz, Music2_octave ; no
	ld b, $0 ; yes
	ld hl, wChannelFlags2
	add hl, bc
	set BIT_EXECUTE_MUSIC, [hl]
	jp Music2_endchannel

Music2_octave: ; 0x945f
	and $f0
	cp $e0 ; is this command an octave?
	jr nz, Music2_unknownsfx0x20 ; no
	ld hl, wChannelOctaves ; yes
	ld b, 0
	add hl, bc
	ld a, d
	and $f
	ld [hl], a ; store low nibble as octave
	jp Music2_endchannel

Music2_unknownsfx0x20: ; 0x9472
	cp $20 ; is this command an unknownsfx0x20?
	jr nz, Music2_unknownsfx0x10 ; no
	ld a, c
	cp CHAN4 ; is this a noise or sfx channel?
	jr c, Music2_unknownsfx0x10 ; no
	ld b, 0
	ld hl, wChannelFlags2
	add hl, bc
	bit BIT_EXECUTE_MUSIC, [hl]
	jr nz, Music2_unknownsfx0x10 ; no
	call Music2_notelength ; yes
	ld d, a
	ld b, 0
	ld hl, wChannelDutyCycles
	add hl, bc
	ld a, [hl]
	or d
	ld d, a
	ld b, REG_DUTY_SOUND_LEN
	call Func_9838
	ld [hl], d
	call Music2_GetNextMusicByte
	ld d, a
	ld b, REG_VOLUME_ENVELOPE
	call Func_9838
	ld [hl], d
	call Music2_GetNextMusicByte
	ld e, a
	ld a, c
	cp CHAN8
	ld a, 0
	jr z, .sfxNoiseChannel ; only two params for noise channel
	push de
	call Music2_GetNextMusicByte
	pop de
.sfxNoiseChannel
	ld d, a
	push de
	call Func_9629
	call Func_95f8
	pop de
	call Func_964b
	ret

Music2_unknownsfx0x10:
	ld a, c
	cp CHAN5
	jr c, Music2_note ; if not a sfx
	ld a, d
	cp $10 ; is this command a unknownsfx0x10?
	jr nz, Music2_note ; no
	ld b, $0
	ld hl, wChannelFlags2
	add hl, bc
	bit BIT_EXECUTE_MUSIC, [hl]
	jr nz, Music2_note ; no
	call Music2_GetNextMusicByte ; yes
	ldh [rNR10], a
	jp Music2_endchannel

Music2_note:
	ld a, c
	cp CHAN4
	jr nz, Music2_notelength ; if not noise channel
	ld a, d
	and $f0
	cp $b0 ; is this command a dnote?
	jr z, Music2_dnote ; yes
	jr nc, Music2_notelength ; no
	swap a
	ld b, a
	ld a, d
	and $f
	ld d, a
	ld a, b
	push de
	push bc
	jr asm_94fd

Music2_dnote:
	ld a, d
	and $f
	push af
	push bc
	call Music2_GetNextMusicByte ; get dnote instrument
asm_94fd
	ld d, a
	ld a, [wDisableChannelOutputWhenSfxEnds]
	and a
	jr nz, .asm_9508
	ld a, d
	call Func_9876
.asm_9508
	pop bc
	pop de

Music2_notelength: ; 0x950a
	ld a, d
	push af
	and $f
	inc a
	ld b, 0
	ld e, a  ; store note length (in 16ths)
	ld d, b
	ld hl, wChannelNoteSpeeds
	add hl, bc
	ld a, [hl]
	ld l, b
	call Func_9847
	ld a, c
	cp CHAN5
	jr nc, .sfxChannel
	ld a, [wMusicTempo]
	ld d, a
	ld a, [wc0e9]
	ld e, a
	jr .skip
.sfxChannel
	ld d, $1
	ld e, $0
	cp CHAN8
	jr z, .skip ; if noise channel
	call Func_9693
	ld a, [wSfxTempo]
	ld d, a
	ld a, [wc0eb]
	ld e, a
.skip
	ld a, l
	ld b, 0
	ld hl, wChannelNoteDelayCountersFractionalPart
	add hl, bc
	ld l, [hl]
	call Func_9847
	ld e, l
	ld d, h
	ld hl, wChannelNoteDelayCountersFractionalPart
	add hl, bc
	ld [hl], e
	ld a, d
	ld hl, wChannelNoteDelayCounters
	add hl, bc
	ld [hl], a
	ld hl, wChannelFlags2
	add hl, bc
	bit BIT_EXECUTE_MUSIC, [hl]
	jr nz, Music2_notepitch
	ld hl, wChannelFlags1
	add hl, bc
	bit BIT_NOISE_OR_SFX, [hl]
	jr z, Music2_notepitch
	pop hl
	ret

Music2_notepitch: ; 0x9568
	pop af
	and $f0
	cp $c0 ; compare to rest
	jr nz, .notRest
	ld a, c
	cp CHAN5
	jr nc, .sfxChannel
	ld hl, wc02a
	add hl, bc
	ld a, [hl]
	and a
	jr nz, .done
	; fall through
.sfxChannel
	ld a, c
	cp CHAN3
	jr z, .musicChannel3
	cp CHAN7
	jr nz, .notSfxChannel3
.musicChannel3
	ld b, 0
	ld hl, Unknown_9b1f
	add hl, bc
	ldh a, [rNR51]
	and [hl]
	ldh [rNR51], a
	jr .done
.notSfxChannel3
	ld b, REG_VOLUME_ENVELOPE
	call Func_9838
	ld a, $8
	ld [hli], a
	inc hl
	ld a, $80
	ld [hl], a
.done
	ret
.notRest
	swap a
	ld b, 0
	ld hl, wChannelOctaves
	add hl, bc
	ld b, [hl]
	call Func_9858
	ld b, 0
	ld hl, wChannelFlags1
	add hl, bc
	bit BIT_PITCH_SLIDE_ON, [hl]
	jr z, .asm_95b8
	call Func_978f
.asm_95b8
	push de
	ld a, c
	cp CHAN5
	jr nc, .skip ; if sfx channel
	ld hl, wc02a
	ld d, 0
	ld e, a
	add hl, de
	ld a, [hl]
	and a
	jr nz, .asm_95cb
	jr .skip
.asm_95cb
	pop de
	ret
.skip
	ld b, 0
	ld hl, wChannelVolumes
	add hl, bc
	ld d, [hl]
	ld b, REG_VOLUME_ENVELOPE
	call Func_9838
	ld [hl], d
	call Func_9629
	call Func_95f8
	pop de
	ld b, $0
	ld hl, wChannelFlags1
	add hl, bc
	bit BIT_PERFECT_PITCH, [hl]   ; has toggleperfectpitch been used?
	jr z, .skip2
	inc e         ; if yes, increment the pitch by 1
	jr nc, .skip2
	inc d
.skip2
	ld hl, wChannelFrequencyLowBytes
	add hl, bc
	ld [hl], e
	call Func_964b
	ret

Func_95f8: ; 0x95f8
	ld b, 0
	ld hl, Unknown_9b27
	add hl, bc
	ldh a, [rNR51]
	or [hl]
	ld d, a
	ld a, c
	cp CHAN8
	jr z, .sfxNoiseChannel
	cp CHAN5
	jr nc, .skip ; if sfx channel
	ld hl, wc02a
	add hl, bc
	ld a, [hl]
	and a
	jr nz, .skip
.sfxNoiseChannel
	ld a, [wStereoPanning]
	ld hl, Unknown_9b27
	add hl, bc
	and [hl]
	ld d, a
	ldh a, [rNR51]
	ld hl, Unknown_9b1f
	add hl, bc
	and [hl]
	or d
	ld d, a
.skip
	ld a, d
	ldh [rNR51], a
	ret

Func_9629: ; 0x9629
	ld b, 0
	ld hl, wChannelNoteDelayCounters
	add hl, bc
	ld d, [hl]
	ld a, c
	cp CHAN3
	jr z, .channel3 ; if music channel 3
	cp CHAN7
	jr z, .channel3 ; if sfx channel 3
	ld a, d
	and $3f
	ld d, a
	ld hl, wChannelDutyCycles
	add hl, bc
	ld a, [hl]
	or d
	ld d, a
.channel3
	ld b, REG_DUTY_SOUND_LEN
	call Func_9838
	ld [hl], d
	ret

Func_964b: ; 0x964b
	ld a, c
	cp CHAN3
	jr z, .channel3
	cp CHAN7
	jr nz, .notSfxChannel3
	; fall through
.channel3
	push de
	ld de, wMusicWaveInstrument
	cp CHAN3
	jr z, .musicChannel3
	ld de, wSfxWaveInstrument
.musicChannel3
	ld a, [de]
	add a
	ld d, 0
	ld e, a
	ld hl, Music2_WavePointers
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, rWave_0
	ld b, $f
	ld a, $0
	ldh [rNR30], a
.loop
	ld a, [de]
	inc de
	ld [hli], a
	ld a, b
	dec b
	and a
	jr nz, .loop
	ld a, $80
	ldh [rNR30], a
	pop de
.notSfxChannel3
	ld a, d
	or $80
	and $c7
	ld d, a
	ld b, REG_FREQUENCY_LO
	call Func_9838
	ld [hl], e
	inc hl
	ld [hl], d
	call Func_96b5
	ret

Func_9693: ; 0x9693
	call Func_96e5
	jr nc, .asm_96ab
	ld d, 0
	ld a, [wTempoModifier]
	add $80
	jr nc, .asm_96a2
	inc d
.asm_96a2
	ld [wc0eb], a
	ld a, d
	ld [wSfxTempo], a
	jr .asm_96b4
.asm_96ab
	xor a
	ld [wc0eb], a
	ld a, $1
	ld [wSfxTempo], a
.asm_96b4
	ret

Func_96b5: ; 0x96b5
	call Func_96e5
	jr nc, .asm_96c6
	ld a, [wFrequencyModifier]
	add e
	jr nc, .asm_96c1
	inc d
.asm_96c1
	dec hl
	ld e, a
	ld [hl], e
	inc hl
	ld [hl], d
.asm_96c6
	ret

Func_96c7: ; 0x96c7
	call Func_96e5
	jr nc, .asm_96e2
	ld hl, wChannelCommandPointers
	ld e, c
	ld d, 0
	sla e
	rl d
	add hl, de
	ld a, [hl]
	sub 1
	ld [hl], a
	inc hl
	ld a, [hl]
	sbc 0
	ld [hl], a
	scf
	ret
.asm_96e2
	scf
	ccf
	ret

Func_96e5: ; 0x96e5
	ld a, [wc02a]
	cp CRY_SFX_START
	jr nc, .asm_96ee
	jr .asm_96f4
.asm_96ee
	cp CRY_SFX_END
	jr z, .asm_96f4
	jr c, .asm_96f7
.asm_96f4
	scf
	ccf
	ret
.asm_96f7
	scf
	ret

Music2_ApplyPitchBend: ; 0x96f9
	ld hl, wChannelFlags1
	add hl, bc
	bit BIT_PITCH_SLIDE_DECREASING, [hl]
	jp nz, .asm_9740
	ld hl, wChannelPitchSlideCurrentFrequencyLowBytes
	add hl, bc
	ld e, [hl]
	ld hl, wChannelPitchSlideCurrentFrequencyHighBytes
	add hl, bc
	ld d, [hl]
	ld hl, wChannelPitchSlideFrequencySteps
	add hl, bc
	ld l, [hl]
	ld h, b
	add hl, de
	ld d, h
	ld e, l
	ld hl, wChannelPitchSlideCurrentFrequencyFractionalPart
	add hl, bc
	push hl
	ld hl, wChannelPitchSlideFrequencyStepsFractionalPart
	add hl, bc
	ld a, [hl]
	pop hl
	add [hl]
	ld [hl], a
	ld a, 0
	adc e
	ld e, a
	ld a, 0
	adc d
	ld d, a
	ld hl, wChannelPitchSlideTargetFrequencyHighBytes
	add hl, bc
	ld a, [hl]
	cp d
	jp c, .asm_9786
	jr nz, .asm_9773
	ld hl, wChannelPitchSlideTargetFrequencyLowBytes
	add hl, bc
	ld a, [hl]
	cp e
	jp c, .asm_9786
	jr .asm_9773
.asm_9740
	ld hl, wChannelPitchSlideCurrentFrequencyLowBytes
	add hl, bc
	ld a, [hl]
	ld hl, wChannelPitchSlideCurrentFrequencyHighBytes
	add hl, bc
	ld d, [hl]
	ld hl, wChannelPitchSlideFrequencySteps
	add hl, bc
	ld e, [hl]
	sub e
	ld e, a
	ld a, d
	sbc b
	ld d, a
	ld hl, wChannelPitchSlideFrequencyStepsFractionalPart
	add hl, bc
	ld a, [hl]
	add a
	ld [hl], a
	ld a, e
	sbc b
	ld e, a
	ld a, d
	sbc b
	ld d, a
	ld hl, wChannelPitchSlideTargetFrequencyHighBytes
	add hl, bc
	ld a, d
	cp [hl]
	jr c, .asm_9786
	jr nz, .asm_9773
	ld hl, wChannelPitchSlideTargetFrequencyLowBytes
	add hl, bc
	ld a, e
	cp [hl]
	jr c, .asm_9786
.asm_9773
	ld hl, wChannelPitchSlideCurrentFrequencyLowBytes
	add hl, bc
	ld [hl], e
	ld hl, wChannelPitchSlideCurrentFrequencyHighBytes
	add hl, bc
	ld [hl], d
	ld b, REG_FREQUENCY_LO
	call Func_9838
	ld a, e
	ld [hli], a
	ld [hl], d
	ret
.asm_9786
	ld hl, wChannelFlags1
	add hl, bc
	res BIT_PITCH_SLIDE_ON, [hl]
	res BIT_PITCH_SLIDE_DECREASING, [hl]
	ret

Func_978f: ; 0x978f
	ld hl, wChannelPitchSlideCurrentFrequencyHighBytes
	add hl, bc
	ld [hl], d
	ld hl, wChannelPitchSlideCurrentFrequencyLowBytes
	add hl, bc
	ld [hl], e
	ld hl, wChannelNoteDelayCounters
	add hl, bc
	ld a, [hl]
	ld hl, wChannelPitchSlideLengthModifiers
	add hl, bc
	sub [hl]
	jr nc, .asm_97a7
	ld a, 1
.asm_97a7
	ld [hl], a
	ld hl, wChannelPitchSlideTargetFrequencyLowBytes
	add hl, bc
	ld a, e
	sub [hl]
	ld e, a
	ld a, d
	sbc b
	ld hl, wChannelPitchSlideTargetFrequencyHighBytes
	add hl, bc
	sub [hl]
	jr c, .asm_97c3
	ld d, a
	ld b, 0
	ld hl, wChannelFlags1
	add hl, bc
	set BIT_PITCH_SLIDE_DECREASING, [hl]
	jr .asm_97e6
.asm_97c3
	ld hl, wChannelPitchSlideCurrentFrequencyHighBytes
	add hl, bc
	ld d, [hl]
	ld hl, wChannelPitchSlideCurrentFrequencyLowBytes
	add hl, bc
	ld e, [hl]
	ld hl, wChannelPitchSlideTargetFrequencyLowBytes
	add hl, bc
	ld a, [hl]
	sub e
	ld e, a
	ld a, d
	sbc b
	ld d, a
	ld hl, wChannelPitchSlideTargetFrequencyHighBytes
	add hl, bc
	ld a, [hl]
	sub d
	ld d, a
	ld b, 0
	ld hl, wChannelFlags1
	add hl, bc
	res BIT_PITCH_SLIDE_DECREASING, [hl]
.asm_97e6
	ld hl, wChannelPitchSlideLengthModifiers
	add hl, bc
.asm_97ea
	inc b
	ld a, e
	sub [hl]
	ld e, a
	jr nc, .asm_97ea
	ld a, d
	and a
	jr z, .asm_97f8
	dec a
	ld d, a
	jr .asm_97ea
.asm_97f8
	ld a, e
	add [hl]
	ld d, b
	ld b, 0
	ld hl, wChannelPitchSlideFrequencySteps
	add hl, bc
	ld [hl], d
	ld hl, wChannelPitchSlideFrequencyStepsFractionalPart
	add hl, bc
	ld [hl], a
	ld hl, wChannelPitchSlideCurrentFrequencyFractionalPart
	add hl, bc
	ld [hl], a
	ret

Music2_ApplyDutyCycle: ; 0x980d
	ld b, 0
	ld hl, wChannelDutyCyclePatterns
	add hl, bc
	ld a, [hl]
	rlca
	rlca
	ld [hl], a
	and $c0
	ld d, a
	ld b, REG_DUTY_SOUND_LEN
	call Func_9838
	ld a, [hl]
	and $3f
	or d
	ld [hl], a
	ret

Music2_GetNextMusicByte: ; 0x9825
	ld d, 0
	ld a, c
	add a
	ld e, a
	ld hl, wChannelCommandPointers
	add hl, de
	ld a, [hli]
	ld e, a
	ld a, [hld]
	ld d, a
	ld a, [de] ; get next music command
	inc de
	ld [hl], e ; store address of next command
	inc hl
	ld [hl], d
	ret

Func_9838: ; 0x9838
	ld a, c
	ld hl, Unknown_9b17
	add l
	jr nc, .noCarry
	inc h
.noCarry
	ld l, a
	ld a, [hl]
	add b
	ld l, a
	ld h, $ff
	ret

Func_9847: ; 0x9847
	ld h, 0
.loop
	srl a
	jr nc, .noCarry
	add hl, de
.noCarry
	sla e
	rl d
	and a
	jr z, .done
	jr .loop
.done
	ret

Func_9858: ; 0x9858
	ld h, 0
	ld l, a
	add hl, hl
	ld d, h
	ld e, l
	ld hl, Music2_Pitches
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, b
.loop
	cp 7
	jr z, .done
	sra d
	rr e
	inc a
	jr .loop
.done
	ld a, 8
	add d
	ld d, a
	ret

Func_9876:: ; 0x9876
	ld [wSoundID], a
	cp SFX_STOP_ALL_MUSIC
	jp z, Func_9a34
	cp MAX_SFX_ID_1
	jp z, Func_994e
	jp c, Func_994e
	cp $fe
	jr z, .asm_988d
	jp nc, Func_994e
.asm_988d
	xor a
	ld [wUnusedC000], a
	ld [wDisableChannelOutputWhenSfxEnds], a
	ld [wc0e9], a
	ld [wMusicWaveInstrument], a
	ld [wSfxWaveInstrument], a
	ld d, NUM_CHANNELS
	ld hl, wChannelReturnAddresses
	call FillMusicRAM2
	ld hl, wChannelCommandPointers
	call FillMusicRAM2
	ld d, NUM_MUSIC_CHANS
	ld hl, wChannelSoundIDs
	call FillMusicRAM2
	ld hl, wChannelFlags1
	call FillMusicRAM2
	ld hl, wChannelDutyCycles
	call FillMusicRAM2
	ld hl, wChannelDutyCyclePatterns
	call FillMusicRAM2
	ld hl, wChannelVibratoDelayCounters
	call FillMusicRAM2
	ld hl, wChannelVibratoExtents
	call FillMusicRAM2
	ld hl, wChannelVibratoRates
	call FillMusicRAM2
	ld hl, wChannelFrequencyLowBytes
	call FillMusicRAM2
	ld hl, wChannelVibratoDelayCounterReloadValues
	call FillMusicRAM2
	ld hl, wChannelFlags2
	call FillMusicRAM2
	ld hl, wChannelPitchSlideLengthModifiers
	call FillMusicRAM2
	ld hl, wChannelPitchSlideFrequencySteps
	call FillMusicRAM2
	ld hl, wChannelPitchSlideFrequencyStepsFractionalPart
	call FillMusicRAM2
	ld hl, wChannelPitchSlideCurrentFrequencyFractionalPart
	call FillMusicRAM2
	ld hl, wChannelPitchSlideCurrentFrequencyHighBytes
	call FillMusicRAM2
	ld hl, wChannelPitchSlideCurrentFrequencyLowBytes
	call FillMusicRAM2
	ld hl, wChannelPitchSlideTargetFrequencyHighBytes
	call FillMusicRAM2
	ld hl, wChannelPitchSlideTargetFrequencyLowBytes
	call FillMusicRAM2
	ld a, $1
	ld hl, wChannelLoopCounters
	call FillMusicRAM2
	ld hl, wChannelNoteDelayCounters
	call FillMusicRAM2
	ld hl, wChannelNoteSpeeds
	call FillMusicRAM2
	ld [wMusicTempo], a
	ld a, $ff
	ld [wStereoPanning], a
	xor a
	ldh [rNR50], a
	ld a, $8
	ldh [rNR10], a
	ld a, 0
	ldh [rNR51], a
	xor a
	ldh [rNR30], a
	ld a, $80
	ldh [rNR30], a
	ld a, $77
	ldh [rNR50], a
	jp Func_9a8f

Func_994e: ; 0x994e
	ld l, a
	ld e, a
	ld h, 0
	ld d, h
	add hl, hl
	add hl, de
	ld de, SFX_Headers_02
	add hl, de
	ld a, h
	ld [wSfxHeaderPointer], a
	ld a, l
	ld [wc0ed], a
	ld a, [hl]
	and $c0
	rlca
	rlca
	ld c, a
.asm_9967
	ld d, c
	ld a, c
	add a
	add c
	ld c, a
	ld b, 0
	ld a, [wSfxHeaderPointer]
	ld h, a
	ld a, [wc0ed]
	ld l, a
	add hl, bc
	ld c, d
	ld a, [hl]
	and $f
	ld e, a
	ld d, 0
	ld hl, wChannelSoundIDs
	add hl, de
	ld a, [hl]
	and a
	jr z, .asm_99a3
	ld a, e
	cp CHAN8
	jr nz, .asm_999a
	ld a, [wSoundID]
	cp NOISE_INSTRUMENTS_END
	jr nc, .asm_9993
	ret
.asm_9993
	ld a, [hl]
	cp NOISE_INSTRUMENTS_END
	jr z, .asm_99a3
	jr c, .asm_99a3
.asm_999a
	ld a, [wSoundID]
	cp [hl]
	jr z, .asm_99a3
	jr c, .asm_99a3
	ret
.asm_99a3
	xor a
	push de
	ld h, d
	ld l, e
	add hl, hl
	ld d, h
	ld e, l
	ld hl, wChannelReturnAddresses
	add hl, de
	ld [hli], a
	ld [hl], a
	ld hl, wChannelCommandPointers
	add hl, de
	ld [hli], a
	ld [hl], a
	pop de
	ld hl, wChannelSoundIDs
	add hl, de
	ld [hl], a
	ld hl, wChannelFlags1
	add hl, de
	ld [hl], a
	ld hl, wChannelDutyCycles
	add hl, de
	ld [hl], a
	ld hl, wChannelDutyCyclePatterns
	add hl, de
	ld [hl], a
	ld hl, wChannelVibratoDelayCounters
	add hl, de
	ld [hl], a
	ld hl, wChannelVibratoExtents
	add hl, de
	ld [hl], a
	ld hl, wChannelVibratoRates
	add hl, de
	ld [hl], a
	ld hl, wChannelFrequencyLowBytes
	add hl, de
	ld [hl], a
	ld hl, wChannelVibratoDelayCounterReloadValues
	add hl, de
	ld [hl], a
	ld hl, wChannelPitchSlideLengthModifiers
	add hl, de
	ld [hl], a
	ld hl, wChannelPitchSlideFrequencySteps
	add hl, de
	ld [hl], a
	ld hl, wChannelPitchSlideFrequencyStepsFractionalPart
	add hl, de
	ld [hl], a
	ld hl, wChannelPitchSlideCurrentFrequencyFractionalPart
	add hl, de
	ld [hl], a
	ld hl, wChannelPitchSlideCurrentFrequencyHighBytes
	add hl, de
	ld [hl], a
	ld hl, wChannelPitchSlideCurrentFrequencyLowBytes
	add hl, de
	ld [hl], a
	ld hl, wChannelPitchSlideTargetFrequencyHighBytes
	add hl, de
	ld [hl], a
	ld hl, wChannelPitchSlideTargetFrequencyLowBytes
	add hl, de
	ld [hl], a
	ld hl, wChannelFlags2
	add hl, de
	ld [hl], a
	ld a, $1
	ld hl, wChannelLoopCounters
	add hl, de
	ld [hl], a
	ld hl, wChannelNoteDelayCounters
	add hl, de
	ld [hl], a
	ld hl, wChannelNoteSpeeds
	add hl, de
	ld [hl], a
	ld a, e
	cp CHAN5
	jr nz, .asm_9a2b
	ld a, $8
	ldh [rNR10], a
.asm_9a2b
	ld a, c
	and a
	jp z, Func_9a8f
	dec c
	jp .asm_9967

Func_9a34: ; 0x9a34
	ld a, $80
	ldh [rNR52], a
	ldh [rNR30], a
	xor a
	ldh [rNR51], a
	ldh [rNR32], a
	ld a, $8
	ldh [rNR10], a
	ldh [rNR12], a
	ldh [rNR22], a
	ldh [rNR42], a
	ld a, $40
	ldh [rNR14], a
	ldh [rNR24], a
	ldh [rNR44], a
	ld a, $77
	ldh [rNR50], a
	xor a
	ld [wUnusedC000], a
	ld [wDisableChannelOutputWhenSfxEnds], a
	ld [wMuteAudioAndPauseMusic], a
	ld [wc0e9], a
	ld [wc0eb], a
	ld [wMusicWaveInstrument], a
	ld [wSfxWaveInstrument], a
	ld d, $a0
	ld hl, wChannelCommandPointers
	call FillMusicRAM2
	ld a, $1
	ld d, $18
	ld hl, wChannelNoteDelayCounters
	call FillMusicRAM2
	ld [wMusicTempo], a
	ld [wSfxTempo], a
	ld a, $ff
	ld [wStereoPanning], a
	ret

; fills d bytes at hl with a
FillMusicRAM2: ; 0x9a89
	ld b, d
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ret

Func_9a8f: ; 0x9a8f
	ld a, [wSoundID]
	ld l, a
	ld e, a
	ld h, 0
	ld d, h
	add hl, hl
	add hl, de
	ld de, SFX_Headers_02
	add hl, de
	ld e, l
	ld d, h
	ld hl, wChannelCommandPointers
	ld a, [de] ; get channel number
	ld b, a
	rlca
	rlca
	and $3
	ld c, a
	ld a, b
	and $f
	ld b, c
	inc b
	inc de
	ld c, 0
.asm_9ab1
	cp c
	jr z, .asm_9ab9
	inc c
	inc hl
	inc hl
	jr .asm_9ab1
.asm_9ab9
	push hl
	push bc
	push af
	ld b, 0
	ld c, a
	ld hl, wChannelSoundIDs
	add hl, bc
	ld a, [wSoundID]
	ld [hl], a
	pop af
	cp CHAN4
	jr c, .asm_9ad2
	ld hl, wChannelFlags1
	add hl, bc
	set BIT_NOISE_OR_SFX, [hl]
.asm_9ad2
	pop bc
	pop hl
	ld a, [de] ; get channel pointer
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	inc c
	dec b
	ld a, b
	and a
	ld a, [de]
	inc de
	jr nz, .asm_9ab1
	ld a, [wSoundID]
	cp CRY_SFX_START
	jr nc, .asm_9aeb
	jr .asm_9b15
.asm_9aeb
	ld a, [wSoundID]
	cp CRY_SFX_END
	jr z, .asm_9b15
	jr c, .asm_9af6
	jr .asm_9b15
.asm_9af6
	ld hl, wc02a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld hl, wc012 ; sfx noise channel pointer
	ld de, Noise2_endchannel
	ld [hl], e
	inc hl
	ld [hl], d ; overwrite pointer to point to endchannel
	ld a, [wSavedVolume]
	and a
	jr nz, .asm_9b15
	ldh a, [rNR50]
	ld [wSavedVolume], a
	ld a, $77
	ldh [rNR50], a
.asm_9b15
	ret

Noise2_endchannel: ; 0x9b16
	endchannel

Unknown_9b17: ; 0x9b17
	db $10, $15, $1A, $1F ; channels 0-3
	db $10, $15, $1A, $1F ; channels 4-7

Unknown_9b1f: ; 0x9b1f
	db $EE, $DD, $BB, $77 ; channels 0-3
	db $EE, $DD, $BB, $77 ; channels 4-7

Unknown_9b27: ; 0x9b27
	db $11, $22, $44, $88 ; channels 0-3
	db $11, $22, $44, $88 ; channels 4-7

Music2_Pitches: ; 0x9b2f
	dw $F82C ; C_
	dw $F89D ; C#
	dw $F907 ; D_
	dw $F96B ; D#
	dw $F9CA ; E_
	dw $FA23 ; F_
	dw $FA77 ; F#
	dw $FAC7 ; G_
	dw $FB12 ; G#
	dw $FB58 ; A_
	dw $FB9B ; A#
	dw $FBDA ; B_


