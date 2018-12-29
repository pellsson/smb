BANK_SELECTED = $07ff

.define PF_SockMode $01

TITLE_INIT		= $01

BANK_LOADER		= 0
BANK_CHR		= 2
BANK_ORG		= 4
BANK_COMMON		= 6
BANK_SCEN		= 8
BANK_SCEN_DATA	= 10
BANK_SMBLL		= 12

CHR_INTRO	= 0
CHR_ORG		= 1
CHR_SCEN	= 2
CHR_LOST	= 3

SavedRule = $07d9
RuleIndex = $0717 ; Previously DemoAction (can be changed to temp?)
PowerUps = $07e3 ; Previously unused?

.ifndef LOAD_GAME_BUTTONS
	.define LOAD_GAME_BUTTONS Select_Button|Up_Dir
.endif

.ifndef RESTART_GAME_BUTTONS
	.define RESTART_GAME_BUTTONS Select_Button|Down_Dir
.endif

