PPU_CTRL_REG1         = $2000
PPU_CTRL_REG2         = $2001
PPU_STATUS            = $2002
PPU_SPR_ADDR          = $2003
PPU_SPR_DATA          = $2004
PPU_SCROLL_REG        = $2005
PPU_ADDRESS           = $2006
PPU_DATA              = $2007

SND_REGISTER          = $4000
SND_SQUARE1_REG       = $4000
SND_SQUARE2_REG       = $4004
SND_TRIANGLE_REG      = $4008
SND_NOISE_REG         = $400c
SND_DELTA_REG         = $4010
SND_MASTERCTRL_REG    = $4015
SND_VOLENV_REG        = $4080
SND_FDS0_REG          = $4040
SND_FDS1_REG          = $4041
SND_PULSE_4002_REG    = $4002
SND_PULSE_4003_REG    = $4003
SND_PULSE_4004_REG    = $4004
SND_PULSE_4005_REG    = $4005
SND_PULSE_4006_REG    = $4006
SND_TRIANGLE_400A_REG = $400A
SND_TRIANGLE_400B_REG = $400B
SND_NOISE_400E_REG    = $400E
SND_NOISE_400F_REG    = $400F

SPR_DMA               = $4014
JOYPAD_PORT           = $4016
JOYPAD_PORT1          = $4016
JOYPAD_PORT2          = $4017

; GAME SPECIFIC DEFINES

ObjectOffset          = $08

FrameCounter          = $09

SavedJoypadBits       = $06fc
SavedJoypad1Bits      = $06fc
SavedJoypad2Bits      = $06fd
JoypadBitMask         = $074a
JoypadOverride        = $0758

A_B_Buttons           = $0a
PreviousA_B_Buttons   = $0d
Up_Down_Buttons       = $0b
Left_Right_Buttons    = $0c

GameEngineSubroutine  = $0e

Mirror_PPU_CTRL_REG1  = $0778
Mirror_PPU_CTRL_REG2  = $0779

OperMode              = $0770
OperMode_Task         = $0772
ScreenRoutineTask     = $073c

GamePauseStatus       = $0776
GamePauseTimer        = $0777

DemoAction            = $0717
DemoActionTimer       = $0718

TimerControl          = $0747
IntervalTimerControl  = $077f

Timers                = $0780
SelectTimer           = $0780
PlayerAnimTimer       = $0781
JumpSwimTimer         = $0782
RunningTimer          = $0783
BlockBounceTimer      = $0784
SideCollisionTimer    = $0785
JumpspringTimer       = $0786
GameTimerCtrlTimer    = $0787
ClimbSideTimer        = $0789
EnemyFrameTimer       = $078a
FrenzyEnemyTimer      = $078f
BowserFireBreathTimer = $0790
StompTimer            = $0791
AirBubbleTimer        = $0792
ScrollIntervalTimer   = $0795
EnemyIntervalTimer    = $0796
BrickCoinTimer        = $079d
InjuryTimer           = $079e
StarInvincibleTimer   = $079f
ScreenTimer           = $07a0
WorldEndTimer         = $07a1
DemoTimer             = $07a2

Sprite_Data           = $0200

Sprite_Y_Position     = $0200
Sprite_Tilenumber     = $0201
Sprite_Attributes     = $0202
Sprite_X_Position     = $0203

ScreenEdge_PageLoc    = $071a
ScreenEdge_X_Pos      = $071c
ScreenLeft_PageLoc    = $071a
ScreenRight_PageLoc   = $071b
ScreenLeft_X_Pos      = $071c
ScreenRight_X_Pos     = $071d

PlayerFacingDir       = $33
DestinationPageLoc    = $34
VictoryWalkControl    = $35
ScrollFractional      = $0768
PrimaryMsgCounter     = $0719
SecondaryMsgCounter   = $0749

HorizontalScroll      = $073f
VerticalScroll        = $0740
ScrollLock            = $0723
ScrollThirtyTwo       = $073d
Player_X_Scroll       = $06ff
Player_Pos_ForScroll  = $0755
ScrollAmount          = $0775

AreaData              = $e7
AreaDataLow           = $e7
AreaDataHigh          = $e8
EnemyData             = $e9
EnemyDataLow          = $e9
EnemyDataHigh         = $ea

AreaParserTaskNum     = $071f
ColumnSets            = $071e
CurrentPageLoc        = $0725
CurrentColumnPos      = $0726
BackloadingFlag       = $0728
BehindAreaParserFlag  = $0729
AreaObjectPageLoc     = $072a
AreaObjectPageSel     = $072b
AreaDataOffset        = $072c
AreaObjOffsetBuffer   = $072d
AreaObjectLength      = $0730
StaircaseControl      = $0734
AreaObjectHeight      = $0735
MushroomLedgeHalfLen  = $0736
EnemyDataOffset       = $0739
EnemyObjectPageLoc    = $073a
EnemyObjectPageSel    = $073b
MetatileBuffer        = $06a1
BlockBufferColumnPos  = $06a0
CurrentNTAddr_Low     = $0721
CurrentNTAddr_High    = $0720
AttributeBuffer       = $03f9

LoopCommand           = $0745

DisplayDigits         = $07d7
TopScoreDisplay       = $07d7
ScoreAndCoinDisplay   = $07dd
PlayerScoreDisplay    = $07dd
GameTimerDisplay      = $07f8
DigitModifier         = $0134

VerticalFlipFlag      = $0109
FloateyNum_Control    = $0110
ShellChainCounter     = $0125
FloateyNum_Timer      = $012c
FloateyNum_X_Pos      = $0117
FloateyNum_Y_Pos      = $011e
FlagpoleFNum_Y_Pos    = $010d
FlagpoleFNum_YMFDummy = $010e
FlagpoleScore         = $010f
FlagpoleCollisionYPos = $070f
StompChainCounter     = $0484

VRAM_Buffer1_Offset   = $0300
VRAM_Buffer1          = $0301
VRAM_Buffer2_Offset   = $0340
VRAM_Buffer2          = $0341
VRAM_Buffer_AddrCtrl  = $0773
Sprite0HitDetectFlag  = $0722
DisableScreenFlag     = $0774
DisableIntermediate   = $0769
ColorRotateOffset     = $06d4

TerrainControl        = $0727
AreaStyle             = $0733
ForegroundScenery     = $0741
BackgroundScenery     = $0742
CloudTypeOverride     = $0743
BackgroundColorCtrl   = $0744
AreaType              = $074e
AreaAddrsLOffset      = $074f
AreaPointer           = $0750

PlayerEntranceCtrl    = $0710
GameTimerSetting      = $0715
AltEntranceControl    = $0752
EntrancePage          = $0751
NumberOfPlayers       = $077a
WarpZoneControl       = $06d6
ChangeAreaTimer       = $06de

MultiLoopCorrectCntr  = $06d9
MultiLoopPassCntr     = $06da

FetchNewGameTimerFlag = $0757
GameTimerExpiredFlag  = $0759

PrimaryHardMode       = $076a
SecondaryHardMode     = $06cc
WorldSelectNumber     = $076b
WorldSelectEnableFlag = $07fc
ContinueWorld         = $07fd

.define IsPlayingLuigi CurrentPlayer

CurrentPlayer         = $0753
PlayerSize            = $0754
PlayerStatus          = $0756

;OnscreenPlayerInfo    = $075a
;NumberofLives         = $075a ;used by current player
HalfwayPage           = $075b
LevelNumber           = $075c ;the actual dash number
Hidden1UpFlag         = $075d
CoinTally             = $075e
WorldNumber           = $075f
AreaNumber            = $0760 ;internal number used to find areas

CoinTallyFor1Ups      = $0748

OffscreenPlayerInfo   = $0761
OffScr_NumberofLives  = $0761 ;used by offscreen player
OffScr_HalfwayPage    = $0762
OffScr_LevelNumber    = $0763
OffScr_Hidden1UpFlag  = $0764
OffScr_CoinTally      = $0765
OffScr_WorldNumber    = $0766
OffScr_AreaNumber     = $0767

BalPlatformAlignment  = $03a0
Platform_X_Scroll     = $03a1
PlatformCollisionFlag = $03a2
YPlatformTopYPos      = $0401
YPlatformCenterYPos   = $58

BrickCoinTimerFlag    = $06bc
StarFlagTaskControl   = $0746

PseudoRandomBitReg    = $07a7

SprShuffleAmtOffset   = $06e0
SprShuffleAmt         = $06e1
SprDataOffset         = $06e4
Player_SprDataOffset  = $06e4
Enemy_SprDataOffset   = $06e5
Block_SprDataOffset   = $06ec
Alt_SprDataOffset     = $06ec
Bubble_SprDataOffset  = $06ee
FBall_SprDataOffset   = $06f1
Misc_SprDataOffset    = $06f3
SprDataOffset_Ctrl    = $03ee

Player_State          = $1d
Enemy_State           = $1e
Fireball_State        = $24
Block_State           = $26
Misc_State            = $2a

Player_MovingDir      = $45
Enemy_MovingDir       = $46

SprObject_X_Speed     = $57
Player_X_Speed        = $57
Enemy_X_Speed         = $58
Fireball_X_Speed      = $5e
Block_X_Speed         = $60
Misc_X_Speed          = $64

Jumpspring_FixedYPos  = $58
JumpspringAnimCtrl    = $070e
JumpspringForce       = $06db

SprObject_PageLoc     = $6d
Player_PageLoc        = $6d
Enemy_PageLoc         = $6e
Fireball_PageLoc      = $74
Block_PageLoc         = $76
Misc_PageLoc          = $7a
Bubble_PageLoc        = $83

SprObject_X_Position  = $86
Player_X_Position     = $86
Enemy_X_Position      = $87
Fireball_X_Position   = $8d
Block_X_Position      = $8f
Misc_X_Position       = $93
Bubble_X_Position     = $9c

SprObject_Y_Speed     = $9f
Player_Y_Speed        = $9f
Enemy_Y_Speed         = $a0
Fireball_Y_Speed      = $a6
Block_Y_Speed         = $a8
Misc_Y_Speed          = $ac

SprObject_Y_HighPos   = $b5
Player_Y_HighPos      = $b5
Enemy_Y_HighPos       = $b6
Fireball_Y_HighPos    = $bc
Block_Y_HighPos       = $be
Misc_Y_HighPos        = $c2
Bubble_Y_HighPos      = $cb

SprObject_Y_Position  = $ce
Player_Y_Position     = $ce
Enemy_Y_Position      = $cf
Fireball_Y_Position   = $d5
Block_Y_Position      = $d7
Misc_Y_Position       = $db
Bubble_Y_Position     = $e4

SprObject_Rel_XPos    = $03ad
Player_Rel_XPos       = $03ad
Enemy_Rel_XPos        = $03ae
Fireball_Rel_XPos     = $03af
Bubble_Rel_XPos       = $03b0
Block_Rel_XPos        = $03b1
Misc_Rel_XPos         = $03b3

SprObject_Rel_YPos    = $03b8
Player_Rel_YPos       = $03b8
Enemy_Rel_YPos        = $03b9
Fireball_Rel_YPos     = $03ba
Bubble_Rel_YPos       = $03bb
Block_Rel_YPos        = $03bc
Misc_Rel_YPos         = $03be

SprObject_SprAttrib   = $03c4
Player_SprAttrib      = $03c4
Enemy_SprAttrib       = $03c5

SprObject_X_MoveForce = $0400
Enemy_X_MoveForce     = $0401

SprObject_YMF_Dummy   = $0416
Player_YMF_Dummy      = $0416
Enemy_YMF_Dummy       = $0417
Bubble_YMF_Dummy      = $042c

SprObject_Y_MoveForce = $0433
Player_Y_MoveForce    = $0433
Enemy_Y_MoveForce     = $0434
Block_Y_MoveForce     = $043c

DisableCollisionDet   = $0716
Player_CollisionBits  = $0490
Enemy_CollisionBits   = $0491

SprObj_BoundBoxCtrl   = $0499
Player_BoundBoxCtrl   = $0499
Enemy_BoundBoxCtrl    = $049a
Fireball_BoundBoxCtrl = $04a0
Misc_BoundBoxCtrl     = $04a2

EnemyFrenzyBuffer     = $06cb
EnemyFrenzyQueue      = $06cd
Enemy_Flag            = $0f
Enemy_ID              = $16

PlayerGfxOffset       = $06d5
Player_XSpeedAbsolute = $0700
FrictionAdderHigh     = $0701
FrictionAdderLow      = $0702
RunningSpeed          = $0703
SwimmingFlag          = $0704
Player_X_MoveForce    = $0705
DiffToHaltJump        = $0706
JumpOrigin_Y_HighPos  = $0707
JumpOrigin_Y_Position = $0708
VerticalForce         = $0709
VerticalForceDown     = $070a
PlayerChangeSizeFlag  = $070b
PlayerAnimTimerSet    = $070c
PlayerAnimCtrl        = $070d
DeathMusicLoaded      = $0712
FlagpoleSoundQueue    = $0713
CrouchingFlag         = $0714
MaximumLeftSpeed      = $0450
MaximumRightSpeed     = $0456

SprObject_OffscrBits  = $03d0
Player_OffscreenBits  = $03d0
Enemy_OffscreenBits   = $03d1
FBall_OffscreenBits   = $03d2
Bubble_OffscreenBits  = $03d3
Block_OffscreenBits   = $03d4
Misc_OffscreenBits    = $03d6
EnemyOffscrBitsMasked = $03d8

Cannon_Offset         = $046a
Cannon_PageLoc        = $046b
Cannon_X_Position     = $0471
Cannon_Y_Position     = $0477
Cannon_Timer          = $047d

Whirlpool_Offset      = $046a
Whirlpool_PageLoc     = $046b
Whirlpool_LeftExtent  = $0471
Whirlpool_Length      = $0477
Whirlpool_Flag        = $047d

VineFlagOffset        = $0398
VineHeight            = $0399
VineObjOffset         = $039a
VineStart_Y_Position  = $039d

Block_Orig_YPos       = $03e4
Block_BBuf_Low        = $03e6
Block_Metatile        = $03e8
Block_PageLoc2        = $03ea
Block_RepFlag         = $03ec
Block_ResidualCounter = $03f0
Block_Orig_XPos       = $03f1

BoundingBox_UL_XPos   = $04ac
BoundingBox_UL_YPos   = $04ad
BoundingBox_DR_XPos   = $04ae
BoundingBox_DR_YPos   = $04af
BoundingBox_UL_Corner = $04ac
BoundingBox_LR_Corner = $04ae
EnemyBoundingBoxCoord = $04b0

PowerUpType           = $39

FireballBouncingFlag  = $3a
FireballCounter       = $06ce
FireballThrowingTimer = $0711

HammerEnemyOffset     = $06ae
JumpCoinMiscOffset    = $06b7

Block_Buffer_1        = $0500
Block_Buffer_2        = $05d0

HammerThrowingTimer   = $03a2
HammerBroJumpTimer    = $3c
Misc_Collision_Flag   = $06be

RedPTroopaOrigXPos    = $0401
RedPTroopaCenterYPos  = $58

XMovePrimaryCounter   = $a0
XMoveSecondaryCounter = $58

CheepCheepMoveMFlag   = $58
CheepCheepOrigYPos    = $0434
BitMFilter            = $06dd

LakituReappearTimer   = $06d1
LakituMoveSpeed       = $58
LakituMoveDirection   = $a0

FirebarSpinState_Low  = $58
FirebarSpinState_High = $a0
FirebarSpinSpeed      = $0388
FirebarSpinDirection  = $34

DuplicateObj_Offset   = $06cf
NumberofGroupEnemies  = $06d3

BlooperMoveCounter    = $a0
BlooperMoveSpeed      = $58

BowserBodyControls    = $0363
BowserFeetCounter     = $0364
BowserMovementSpeed   = $0365
BowserOrigXPos        = $0366
BowserFlameTimerCtrl  = $0367
BowserFront_Offset    = $0368
BridgeCollapseOffset  = $0369
BowserGfxFlag         = $036a
BowserHitPoints       = $0483
MaxRangeFromOrigin    = $06dc

BowserFlamePRandomOfs = $0417

PiranhaPlantUpYPos    = $0417
PiranhaPlantDownYPos  = $0434
PiranhaPlant_Y_Speed  = $58
PiranhaPlant_MoveFlag = $a0

FireworksCounter      = $06d7
ExplosionGfxCounter   = $58
ExplosionTimerCounter = $a0

;sound related defines
Squ2_NoteLenBuffer    = $07b3
Squ2_NoteLenCounter   = $07b4
Squ2_EnvelopeDataCtrl = $07b5
Squ1_NoteLenCounter   = $07b6
Squ1_EnvelopeDataCtrl = $07b7
Tri_NoteLenBuffer     = $07b8
Tri_NoteLenCounter    = $07b9
Noise_BeatLenCounter  = $07ba
Squ1_SfxLenCounter    = $07bb
Squ2_SfxLenCounter    = $07bd
Sfx_SecondaryCounter  = $07be
Noise_SfxLenCounter   = $07bf

PauseSoundQueue       = $fa
Square1SoundQueue     = $ff
Square2SoundQueue     = $fe
NoiseSoundQueue       = $fd
AreaMusicQueue        = $fb
EventMusicQueue       = $fc

Square1SoundBuffer    = $f1
Square2SoundBuffer    = $f2
NoiseSoundBuffer      = $f3
AreaMusicBuffer       = $f4
EventMusicBuffer      = $07b1
PauseSoundBuffer      = $07b2

MusicData             = $f5
MusicDataLow          = $f5
MusicDataHigh         = $f6
MusicOffset_Square2   = $f7
MusicOffset_Square1   = $f8
MusicOffset_Triangle  = $f9
MusicOffset_Noise     = $07b0

NoteLenLookupTblOfs   = $f0
DAC_Counter           = $07c0
NoiseDataLoopbackOfs  = $07c1
NoteLengthTblAdder    = $07c4
AreaMusicBuffer_Alt   = $07c5
PauseModeFlag         = $07c6
GroundMusicHeaderOfs  = $07c7
AltRegContentFlag     = $07ca

;-------------------------------------------------------------------------------------
;CONSTANTS

;sound effects constants
Sfx_SmallJump         = %10000000
Sfx_Flagpole          = %01000000
Sfx_Fireball          = %00100000
Sfx_PipeDown_Injury   = %00010000
Sfx_EnemySmack        = %00001000
Sfx_EnemyStomp        = %00000100
Sfx_Bump              = %00000010
Sfx_BigJump           = %00000001

Sfx_BowserFall        = %10000000
Sfx_ExtraLife         = %01000000
Sfx_PowerUpGrab       = %00100000
Sfx_TimerTick         = %00010000
Sfx_Blast             = %00001000
Sfx_GrowVine          = %00000100
Sfx_GrowPowerUp       = %00000010
Sfx_CoinGrab          = %00000001

Sfx_BowserFlame       = %00000010
Sfx_BrickShatter      = %00000001

;music constants
Silence               = %10000000

StarPowerMusic        = %01000000
PipeIntroMusic        = %00100000
CloudMusic            = %00010000
CastleMusic           = %00001000
UndergroundMusic      = %00000100
WaterMusic            = %00000010
GroundMusic           = %00000001

TimeRunningOutMusic   = %01000000
EndOfLevelMusic       = %00100000
AltGameOverMusic      = %00010000
EndOfCastleMusic      = %00001000
VictoryMusic          = %00000100
GameOverMusic         = %00000010
DeathMusic            = %00000001

;enemy object constants 
GreenKoopa            = $00
BuzzyBeetle           = $02
RedKoopa              = $03
HammerBro             = $05
Goomba                = $06
Bloober               = $07
BulletBill_FrenzyVar  = $08
GreyCheepCheep        = $0a
RedCheepCheep         = $0b
Podoboo               = $0c
PiranhaPlant          = $0d
GreenParatroopaJump   = $0e
RedParatroopa         = $0f
GreenParatroopaFly    = $10
Lakitu                = $11
Spiny                 = $12
FlyCheepCheepFrenzy   = $14
FlyingCheepCheep      = $14
BowserFlame           = $15
Fireworks             = $16
BBill_CCheep_Frenzy   = $17
Stop_Frenzy           = $18
Bowser                = $2d
PowerUpObject         = $2e
VineObject            = $2f
FlagpoleFlagObject    = $30
StarFlagObject        = $31
JumpspringObject      = $32
BulletBill_CannonVar  = $33
RetainerObject        = $35
TallEnemy             = $09

;other constants
World1 = 0
World2 = 1
World3 = 2
World4 = 3
World5 = 4
World6 = 5
World7 = 6
World8 = 7
Level1 = 0
Level2 = 1
Level3 = 2
Level4 = 3

WarmBootOffset        = <$07d6
ColdBootOffset        = <$07fe
TitleScreenDataOffset = $1ec0
SoundMemory           = $07b0

.define SwimTileRepOffset		PlayerGraphicsTable + $9e
.define MusicHeaderOffsetData	MusicHeaderData - 1
.define MHD 					MusicHeaderData

A_Button              = %10000000
B_Button              = %01000000
Select_Button         = %00100000
Start_Button          = %00010000
Up_Dir                = %00001000
Down_Dir              = %00000100
Left_Dir              = %00000010
Right_Dir             = %00000001

TitleScreenModeValue  = 0
GameModeValue         = 1
VictoryModeValue      = 2
GameOverModeValue     = 3