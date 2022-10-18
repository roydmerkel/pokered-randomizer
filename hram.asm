
; Initialized to 16.
; Decremented each input iteration if the player
; presses the reset sequence (A+B+SEL+START).
; Soft reset when 0 is reached.
hSoftReset EQU $FF8A


hBaseTileID EQU $FF8B
hDexWeight EQU $FF8B
hWarpDestinationMap EQU $FF8B
hOAMTile EQU $FF8B
hROMBankTemp EQU $FF8B
hPreviousTileset EQU $FF8B
hRLEByteValue EQU $FF8B


; DisplayTextID's argument
hSpriteIndexOrTextID EQU $FF8C
hPartyMonIndex EQU $FF8C


hVRAMSlot EQU $FF8D


hFourTileSpriteCount EQU $FF8E
hHalveItemPrices EQU $FF8E



hItemPrice EQU $FF8B


hSlideAmount EQU $FF8B

; the total number of tiles being shifted each time the pic slides by one tile
hSlidingRegionSize EQU $FF8C

; -1 = left
;  0 = right
hSlideDirection EQU $FF8D


hSpriteInterlaceCounter EQU $FF8B
hSpriteWidth EQU $FF8B
hSpriteHeight EQU $FF8C
hSpriteOffset EQU $FF8D


; counters for blinking down arrow
hDownArrowBlinkCount1 EQU $FF8B
hDownArrowBlinkCount2 EQU $FF8C


hMapStride EQU $FF8B
hEastWestConnectedMapWidth EQU $FF8B
hNorthSouthConnectionStripWidth EQU $FF8B

hMapWidth EQU $FF8C
hNorthSouthConnectedMapWidth EQU $FF8C



hSpriteDataOffset EQU $FF8B
hSpriteIndex      EQU $FF8C
hSpriteImageIndex EQU $FF8D
hSpriteFacingDirection EQU $FF8D
hSpriteMovementByte2 EQU $ff8D




hLoadSpriteTemp1 EQU $FF8D
hLoadSpriteTemp2 EQU $FF8E



hEnemySpeed EQU $FF8D
; Multiplcation and division variables are meant
; to overlap for back-to-back usage. Big endian.

H_MULTIPLICAND EQU $FF96 ; 3 bytes
H_MULTIPLIER   EQU $FF99 ; 1 byte
H_PRODUCT      EQU $FF95 ; 4 bytes

H_DIVIDEND     EQU $FF95 ; 4 bytes
H_DIVISOR      EQU $FF99 ; 1 byte
H_QUOTIENT     EQU $FF95 ; 4 bytes
H_REMAINDER    EQU $FF99 ; 1 byte

; PrintNumber (big endian).
H_PASTLEADINGZEROES EQU $FF95 ; last char printed
H_NUMTOPRINT        EQU $FF96 ; 3 bytes
H_POWEROFTEN        EQU $FF99 ; 3 bytes
H_SAVEDNUMTOPRINT   EQU $FF9C ; 3 bytes

; these values are copied to SCX, SCY, and WY during V-blank
hSCX EQU $FFAE
hSCY EQU $FFAF
hWY  EQU $FFB0

hJoyHeldLast EQU $FFB1
hJoyReleased EQU $FFB2
hJoyPressed  EQU $FFB3
hJoyHeld     EQU $FFB4
hJoy5        EQU $FFB5
hJoy6        EQU $FFB6
hJoy7        EQU $FFB7

H_LOADEDROMBANK     EQU $FFB8
hROMBank            EQU $ffb8

; is automatic background transfer during V-blank enabled?
; if nonzero, yes
; if zero, no
H_AUTOBGTRANSFERENABLED EQU $FFBA

TRANSFERTOP    EQU 0
TRANSFERMIDDLE EQU 1
TRANSFERBOTTOM EQU 2

; 00 = top third of background
; 01 = middle third of background
; 02 = bottom third of background
H_AUTOBGTRANSFERPORTION EQU $FFBB

; the destination address of the automatic background transfer
H_AUTOBGTRANSFERDEST EQU $FFBC ; 2 bytes

; temporary storage for stack pointer during memory transfers that use pop
; to increase speed
H_SPTEMP EQU $FFBF ; 2 bytes

; source address for VBlankCopyBgMap function
; the first byte doubles as the byte that enabled the transfer.
; if it is 0, the transfer is disabled
; if it is not 0, the transfer is enabled
; this means that XX00 is not a valid source address
H_VBCOPYBGSRC EQU $FFC1 ; 2 bytes

; destination address for VBlankCopyBgMap function
H_VBCOPYBGDEST EQU $FFC3 ; 2 bytes

; number of rows for VBlankCopyBgMap to copy
H_VBCOPYBGNUMROWS EQU $FFC5

; size of VBlankCopy transfer in 16-byte units
H_VBCOPYSIZE EQU $FFC6

; source address for VBlankCopy function
H_VBCOPYSRC EQU $FFC7

; destination address for VBlankCopy function
H_VBCOPYDEST EQU $FFC9

; size of source data for VBlankCopyDouble in 8-byte units
H_VBCOPYDOUBLESIZE EQU $FFCB

; source address for VBlankCopyDouble function
H_VBCOPYDOUBLESRC EQU $FFCC

; destination address for VBlankCopyDouble function
H_VBCOPYDOUBLEDEST EQU $FFCE

; controls whether a row or column of 2x2 tile blocks is redrawn in V-blank
; 00 = no redraw
; 01 = redraw column
; 02 = redraw row
H_SCREENEDGEREDRAW EQU $FFD0

REDRAWCOL EQU 1
REDRAWROW EQU 2

H_SCREENEDGEREDRAWADDR EQU $FFD1

hRandomAdd EQU $FFD3
hRandomSub EQU $FFD4

H_FRAMECOUNTER EQU $FFD5 ; decremented every V-blank (used for delays)

; V-blank sets this to 0 each time it runs.
; So, by setting it to a nonzero value and waiting for it to become 0 again,
; you can detect that the V-blank handler has run since then.
H_VBLANKOCCURRED EQU $FFD6

; 00 = indoor
; 01 = cave
; 02 = outdoor
; this is often set to 00 in order to turn off water and flower BG tile animations
hTilesetType EQU $FFD7

H_CURRENTSPRITEOFFSET EQU $FFDA ; multiple of $10

H_WHOSETURN EQU $FFF3 ; 0 on player’s turn, 1 on enemy’s turn

hJoyInput EQU $FFF8

