
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



hSpriteOffset2 EQU $FF8F
hOAMBufferOffset EQU $FF90
hSpriteScreenX EQU $FF91
hSpriteScreenY EQU $FF92


hFF8F EQU $FF8F
hFF90 EQU $FF90
hFF91 EQU $FF91
hFF92 EQU $FF92


hTilePlayerStandingOn EQU $FF93

hSpritePriority EQU $FF94


; Multiplcation and division variables are meant
; to overlap for back-to-back usage. Big endian.


hMultiplicand EQU $FF96 ; 3 bytes
hMultiplier   EQU $FF99 ; 1 byte

hMultiplyBuffer EQU $FF9B ; 4 bytes

hProduct      EQU $FF95 ; 4 bytes

hDividend     EQU $FF95 ; 4 bytes
hDivisor      EQU $FF99 ; 1 byte
hDivideBuffer EQU $FF9A ; 5 bytes

hQuotient     EQU $FF95 ; 4 bytes
hRemainder    EQU $FF99 ; 1 byte

; PrintNumber (big endian).
hPastLeadingZeros EQU $FF95 ; last char printed
hNumToPrint        EQU $FF96 ; 3 bytes
hPowerOf10        EQU $FF99 ; 3 bytes
hSavedNumToPrint   EQU $FF9C ; 3 bytes


hNPCMovementDirections2Index EQU $FF95
hNPCSpriteOffset EQU $FF95
; distance in steps between NPC and player
hNPCPlayerYDistance EQU $FF95

hNPCPlayerXDistance EQU $FF96

hFindPathNumSteps EQU $FF97
; bit 0: set when the end of the path's Y coordinate matches the target's
; bit 1: set when the end of the path's X coordinate matches the target's
; When both bits are set, the end of the path is at the target's position
; (i.e. the path has been found).
hFindPathFlags EQU $FF98
hFindPathYProgress EQU $FF99
hFindPathXProgress EQU $FF9A
; 0 = from player to NPC
; 1 = from NPC to player
hNPCPlayerRelativePosPerspective EQU $FF9B

; bit 0:
; 0 = target is to the south or aligned
; 1 = target is to the north
; bit 1:
; 0 = target is to the east or aligned
; 1 = target is to the west
hNPCPlayerRelativePosFlags EQU $FF9D


hSwapItemID EQU $FF95
hSwapItemQuantity EQU $FF96

hSignCoordPointer EQU $FF95






hMutateWY EQU $FF96
hMutateWX EQU $FF97


; temp value used when swapping bytes or words
hSwapTemp EQU $FF95
hExperience EQU $FF96 ; bytes



hMoney EQU $FF9F ; 3 byes FFA0 FFA1

; some code zeroes this for no reason when writing a coin amount
hUnusedCoinsByte EQU $FF9F
hCoins EQU $FFA0 ; 2 bytes FFA1


hDivideBCDDivisor EQU $FFA2
hDivideBCDQuotient EQU $FFA2 ; 3 bytes A3 A4

hDivideBCDBuffer EQU $FFA5 ; 3 bytes A6 A7




hSerialReceivedNewData EQU $FFA9
; $01 = using external clock
; $02 = using internal clock
; $ff = establishing connection
hSerialConnectionStatus EQU $FFAA
hSerialIgnoringInitialData EQU $FFAB
hSerialSendData EQU $FFAC
hSerialReceiveData EQU $FFAD

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

