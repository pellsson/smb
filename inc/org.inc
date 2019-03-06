CHR_SMB = 0
CHR_PRACTICE = 2
CHR_FPG = 4
CHR_LOADER = 6

;
; FPG vars
;
FpgRuleset = $0717		; DemoAction
FpgSelected = $075a		; NumberOfLives
FpgFlags  = $0761		; OffScr_NumberofLives
FpgLastInput = $0762	; OffScr_HalfwayPage
FpgScrollTo = $07d7 	; TopScoreDisplay+0
FpgError = $07d8		; TopScoreDisplay+1
FpgErrorParam = $07d9	; TopScoreDisplay+2
FpgOldFlags = $07da		; TopScoreDisplay+3

;
; Practice vars
;
;
; RAM vars
;
PowerUpFrames				= $04	; Anywhere thats temporary
LastInputBits				= $075a ; Previously NumberOfLives
MenuSelection				= $077a ; Previously NumberOfPlayers
FrameRuleData				= $07df ; Previously in score somewhere
;SaveStateFlags				= $07fc ; Previously WorldSelectEnableFlag
SavedEnterTimer				= $07f7

STATUS_BAR_OFFSET = $02
RULE_COUNT_OFFSET = $0b
FRAME_NUMBER_OFFSET = $15
FRAMES_REMAIN_OFFSET = $0e
POSITION_OFFSET = $12


