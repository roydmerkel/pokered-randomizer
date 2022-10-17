RemoveGuardDrink: ; 5a59f (16:659f)
	ld hl, GuardDrinksList
.drinkLoop
	ld a, [hli]
	ldh [$ffdb], a
	and a
	ret z
	push hl
	ld b, a
	call IsItemInBag
	pop hl
	jr z, .drinkLoop
	ld b, BANK(RemoveItemByID)
	ld hl, RemoveItemByID
	jp Bankswitch

GuardDrinksList: ; 5a5b7 (16:65b7)
	db FRESH_WATER, SODA_POP, LEMONADE, $00
