
	.include "shared.inc"
	.include "mario.inc"
	.include "macros.inc"
	.include "text.inc"

	.org $8000
	.segment "bank4"

	.ifndef ENABLE_SFX
      .define ENABLE_SFX 1
    .endif

    .ifndef ENABLE_MUSIC
      .define ENABLE_MUSIC 1
    .endif

Start:	; Dummy
NonMaskableInterrupt: ; Dummy

	.include "utils.inc"
	.include "sound.asm"
	.include "sound-ll.asm"
	.include "game.asm"
	.include "pausemenu.asm"
	.include "practice.asm"

	.export EndOfCastle
	.export RenderIntermediateTime
	.export FrameToTime
	.export PracticeInit
	.export InitializeWRAM
	.export ForceUpdateSockHash
	.export PracticeOnFrame
	.export PracticeTitleMenu
	.export SoundEngineExternal
	.export ProcessLevelLoad
	.export LoadPhysicsData
	.export LoadMarioPhysics
	.export RedrawUserVars
	.export RedrawAll
	.export UpdateFrameRule
	.export WritePracticeTop
	.export RedrawFrameNumbers
	.export RedrawSockTimer
	.export SetDefaultWRAM
	.export FactoryResetWRAM
	.export UpdateGameTimer

practice_callgate
control_bank
