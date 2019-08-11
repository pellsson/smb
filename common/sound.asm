
;
; Bank for all sound-related stuff
;
SoundEngineExternal:
        jsr SoundEngine
        jmp ReturnBank

SoundEngine:
         lda OperMode              ;are we in title screen mode?
         bne SndOn
         sta SND_MASTERCTRL_REG    ;if so, disable sound and leave
         rts
SndOn:   lda #$ff
         sta JOYPAD_PORT2          ;disable irqs and set frame counter mode???
         lda #$0f
         sta SND_MASTERCTRL_REG    ;enable first four channels
         lda PauseModeFlag         ;is sound already in pause mode?
         bne InPause
         lda PauseSoundQueue       ;if not, check pause sfx queue    
         cmp #$01
         bne RunSoundSubroutines   ;if queue is empty, skip pause mode routine
InPause: lda PauseSoundBuffer      ;check pause sfx buffer
         bne ContPau
         lda PauseSoundQueue       ;check pause queue
         beq SkipSoundSubroutines
         sta PauseSoundBuffer      ;if queue full, store in buffer and activate
         sta PauseModeFlag         ;pause mode to interrupt game sounds
         lda #$00                  ;disable sound and clear sfx buffers
         sta SND_MASTERCTRL_REG
         sta Square1SoundBuffer
         sta Square2SoundBuffer
         sta NoiseSoundBuffer
         lda #$0f
         sta SND_MASTERCTRL_REG    ;enable sound again
         lda #$2a                  ;store length of sound in pause counter
         sta Squ1_SfxLenCounter
PTone1F: lda #$44                  ;play first tone
         bne PTRegC                ;unconditional branch
ContPau: lda Squ1_SfxLenCounter    ;check pause length left
         cmp #$24                  ;time to play second?
         beq PTone2F
         cmp #$1e                  ;time to play first again?
         beq PTone1F
         cmp #$18                  ;time to play second again?
         bne DecPauC               ;only load regs during times, otherwise skip
PTone2F: lda #$64                  ;store reg contents and play the pause sfx
PTRegC:  ldx #$84
         ldy #$7f
         jsr PlaySqu1Sfx
DecPauC: dec Squ1_SfxLenCounter    ;decrement pause sfx counter
         bne SkipSoundSubroutines
         lda #$00                  ;disable sound if in pause mode and
         sta SND_MASTERCTRL_REG    ;not currently playing the pause sfx
         lda PauseSoundBuffer      ;if no longer playing pause sfx, check to see
         cmp #$02                  ;if we need to be playing sound again
         bne SkipPIn
         lda #$00                  ;clear pause mode to allow game sounds again
         sta PauseModeFlag
SkipPIn: lda #$00                  ;clear pause sfx buffer
         sta PauseSoundBuffer
         beq SkipSoundSubroutines

RunSoundSubroutines:
         lda WRAM_DisableSound
         bne @nosound
         jsr Square1SfxHandler  ;play sfx on square channel 1
         jsr Square2SfxHandler  ; ''  ''  '' square channel 2
         jsr NoiseSfxHandler    ; ''  ''  '' noise channel
@nosound:
         lda WRAM_DisableMusic
         bne @nomusic
         jsr MusicHandler       ;play music on all channels
@nomusic:
         lda #$00               ;clear the music queues
         sta AreaMusicQueue
         sta EventMusicQueue

SkipSoundSubroutines:
          lda #$00               ;clear the sound effects queues
          sta Square1SoundQueue
          sta Square2SoundQueue
          sta NoiseSoundQueue
          sta PauseSoundQueue
          ldy DAC_Counter        ;load some sort of counter 
          lda AreaMusicBuffer
          and #%00000011         ;check for specific music
          beq NoIncDAC
          inc DAC_Counter        ;increment and check counter
          cpy #$30
          bcc StrWave            ;if not there yet, just store it
NoIncDAC: tya
          beq StrWave            ;if we are at zero, do not decrement 
          dec DAC_Counter        ;decrement counter
StrWave:  sty SND_DELTA_REG+1    ;store into DMC load register (??)
          rts                    ;we are done here

Dump_Squ1_Regs:
      sty SND_SQUARE1_REG+1  ;dump the contents of X and Y into square 1's control regs
      stx SND_SQUARE1_REG
      rts
      
PlaySqu1Sfx:
      jsr Dump_Squ1_Regs     ;do sub to set ctrl regs for square 1, then set frequency regs

SetFreq_Squ1:
      ldx #$00               ;set frequency reg offset for square 1 sound channel

Dump_Freq_Regs:
        tay
        lda FreqRegLookupTbl+1,y  ;use previous contents of A for sound reg offset
        beq NoTone                ;if zero, then do not load
        sta SND_REGISTER+2,x      ;first byte goes into LSB of frequency divider
        lda FreqRegLookupTbl,y    ;second byte goes into 3 MSB plus extra bit for 
        ora #%00001000            ;length counter
        sta SND_REGISTER+3,x
NoTone: rts

Dump_Sq2_Regs:
      stx SND_SQUARE2_REG    ;dump the contents of X and Y into square 2's control regs
      sty SND_SQUARE2_REG+1
      rts

PlaySqu2Sfx:
      jsr Dump_Sq2_Regs      ;do sub to set ctrl regs for square 2, then set frequency regs

SetFreq_Squ2:
      ldx #$04               ;set frequency reg offset for square 2 sound channel
      bne Dump_Freq_Regs     ;unconditional branch

SetFreq_Tri:
      ldx #$08               ;set frequency reg offset for triangle sound channel
      bne Dump_Freq_Regs     ;unconditional branch

;--------------------------------
SwimStompEnvelopeData:
      .byte $9f, $9b, $98, $96, $95, $94, $92, $90
      .byte $90, $9a, $97, $95, $93, $92

PlayFlagpoleSlide:
       lda #$40               ;store length of flagpole sound
       sta Squ1_SfxLenCounter
       lda #$62               ;load part of reg contents for flagpole sound
       jsr SetFreq_Squ1
       ldx #$99               ;now load the rest
       bne FPS2nd

PlaySmallJump:
       lda #$26               ;branch here for small mario jumping sound
       bne JumpRegContents

PlayBigJump:
       lda #$18               ;branch here for big mario jumping sound

JumpRegContents:
       ldx #$82               ;note that small and big jump borrow each others' reg contents
       ldy #$a7               ;anyway, this loads the first part of mario's jumping sound
       jsr PlaySqu1Sfx
       lda #$28               ;store length of sfx for both jumping sounds
       sta Squ1_SfxLenCounter ;then continue on here

ContinueSndJump:
          lda Squ1_SfxLenCounter ;jumping sounds seem to be composed of three parts
          cmp #$25               ;check for time to play second part yet
          bne N2Prt
          ldx #$5f               ;load second part
          ldy #$f6
          bne DmpJpFPS           ;unconditional branch
N2Prt:    cmp #$20               ;check for third part
          bne DecJpFPS
          ldx #$48               ;load third part
FPS2nd:   ldy #$bc               ;the flagpole slide sound shares part of third part
DmpJpFPS: jsr Dump_Squ1_Regs
          bne DecJpFPS           ;unconditional branch outta here

PlayFireballThrow:
        lda #$05
        ldy #$99                 ;load reg contents for fireball throw sound
        bne Fthrow               ;unconditional branch

PlayBump:
          lda #$0a                ;load length of sfx and reg contents for bump sound
          ldy #$93
Fthrow:   ldx #$9e                ;the fireball sound shares reg contents with the bump sound
          sta Squ1_SfxLenCounter
          lda #$0c                ;load offset for bump sound
          jsr PlaySqu1Sfx

ContinueBumpThrow:    
          lda Squ1_SfxLenCounter  ;check for second part of bump sound
          cmp #$06   
          bne DecJpFPS
          lda #$bb                ;load second part directly
          sta SND_SQUARE1_REG+1
DecJpFPS: bne BranchToDecLength1  ;unconditional branch


Square1SfxHandler:
       ldy Square1SoundQueue   ;check for sfx in queue
       beq CheckSfx1Buffer
       sty Square1SoundBuffer  ;if found, put in buffer
       bmi PlaySmallJump       ;small jump
       lsr Square1SoundQueue
       bcs PlayBigJump         ;big jump
       lsr Square1SoundQueue
       bcs PlayBump            ;bump
       lsr Square1SoundQueue
       bcs PlaySwimStomp       ;swim/stomp
       lsr Square1SoundQueue
       bcs PlaySmackEnemy      ;smack enemy
       lsr Square1SoundQueue
       bcs PlayPipeDownInj     ;pipedown/injury
       lsr Square1SoundQueue
       bcs PlayFireballThrow   ;fireball throw
       lsr Square1SoundQueue
       bcs PlayFlagpoleSlide   ;slide flagpole

CheckSfx1Buffer:
       lda Square1SoundBuffer   ;check for sfx in buffer 
       beq ExS1H                ;if not found, exit sub
       bmi ContinueSndJump      ;small mario jump 
       lsr
       bcs ContinueSndJump      ;big mario jump 
       lsr
       bcs ContinueBumpThrow    ;bump
       lsr
       bcs ContinueSwimStomp    ;swim/stomp
       lsr
       bcs ContinueSmackEnemy   ;smack enemy
       lsr
       bcs ContinuePipeDownInj  ;pipedown/injury
       lsr
       bcs ContinueBumpThrow    ;fireball throw
       lsr
       bcs DecrementSfx1Length  ;slide flagpole
ExS1H: rts

PlaySwimStomp:
      lda #$0e               ;store length of swim/stomp sound
      sta Squ1_SfxLenCounter
      ldy #$9c               ;store reg contents for swim/stomp sound
      ldx #$9e
      lda #$26
      jsr PlaySqu1Sfx

ContinueSwimStomp: 
      ldy Squ1_SfxLenCounter        ;look up reg contents in data section based on
      lda SwimStompEnvelopeData-1,y ;length of sound left, used to control sound's
      sta SND_SQUARE1_REG           ;envelope
      cpy #$06   
      bne BranchToDecLength1
      lda #$9e                      ;when the length counts down to a certain point, put this
      sta SND_SQUARE1_REG+2         ;directly into the LSB of square 1's frequency divider

BranchToDecLength1: 
      bne DecrementSfx1Length  ;unconditional branch (regardless of how we got here)

PlaySmackEnemy:
      lda #$0e                 ;store length of smack enemy sound
      ldy #$cb
      ldx #$9f
      sta Squ1_SfxLenCounter
      lda #$28                 ;store reg contents for smack enemy sound
      jsr PlaySqu1Sfx
      bne DecrementSfx1Length  ;unconditional branch

ContinueSmackEnemy:
        ldy Squ1_SfxLenCounter  ;check about halfway through
        cpy #$08
        bne SmSpc
        lda #$a0                ;if we're at the about-halfway point, make the second tone
        sta SND_SQUARE1_REG+2   ;in the smack enemy sound
        lda #$9f
        bne SmTick
SmSpc:  lda #$90                ;this creates spaces in the sound, giving it its distinct noise
SmTick: sta SND_SQUARE1_REG

DecrementSfx1Length:
      dec Squ1_SfxLenCounter    ;decrement length of sfx
      bne ExSfx1

StopSquare1Sfx:
        ldx #$00                ;if end of sfx reached, clear buffer
        stx $f1                 ;and stop making the sfx
        ldx #$0e
        stx SND_MASTERCTRL_REG
        ldx #$0f
        stx SND_MASTERCTRL_REG
ExSfx1: rts

PlayPipeDownInj:  
      lda #$2f                ;load length of pipedown sound
      sta Squ1_SfxLenCounter

ContinuePipeDownInj:
         lda Squ1_SfxLenCounter  ;some bitwise logic, forces the regs
         lsr                     ;to be written to only during six specific times
         bcs NoPDwnL             ;during which d3 must be set and d1-0 must be clear
         lsr
         bcs NoPDwnL
         and #%00000010
         beq NoPDwnL
         ldy #$91                ;and this is where it actually gets written in
         ldx #$9a
         lda #$44
         jsr PlaySqu1Sfx
NoPDwnL: jmp DecrementSfx1Length

;--------------------------------

ExtraLifeFreqData:
      .byte $58, $02, $54, $56, $4e, $44

PowerUpGrabFreqData:
      .byte $4c, $52, $4c, $48, $3e, $36, $3e, $36, $30
      .byte $28, $4a, $50, $4a, $64, $3c, $32, $3c, $32
      .byte $2c, $24, $3a, $64, $3a, $34, $2c, $22, $2c

;residual frequency data
      .byte $22, $1c, $14

PUp_VGrow_FreqData:
      .byte $14, $04, $22, $24, $16, $04, $24, $26 ;used by both
      .byte $18, $04, $26, $28, $1a, $04, $28, $2a
      .byte $1c, $04, $2a, $2c, $1e, $04, $2c, $2e ;used by vinegrow
      .byte $20, $04, $2e, $30, $22, $04, $30, $32

PlayCoinGrab:
        lda #$35             ;load length of coin grab sound
        ldx #$8d             ;and part of reg contents
        bne CGrab_TTickRegL

PlayTimerTick:
        lda #$06             ;load length of timer tick sound
        ldx #$98             ;and part of reg contents

CGrab_TTickRegL:
        sta Squ2_SfxLenCounter 
        ldy #$7f                ;load the rest of reg contents 
        lda #$42                ;of coin grab and timer tick sound
        jsr PlaySqu2Sfx

ContinueCGrabTTick:
        lda Squ2_SfxLenCounter  ;check for time to play second tone yet
        cmp #$30                ;timer tick sound also executes this, not sure why
        bne N2Tone
        lda #$54                ;if so, load the tone directly into the reg
        sta SND_SQUARE2_REG+2
N2Tone: bne DecrementSfx2Length

PlayBlast:
        lda #$20                ;load length of fireworks/gunfire sound
        sta Squ2_SfxLenCounter
        ldy #$94                ;load reg contents of fireworks/gunfire sound
        lda #$5e
        bne SBlasJ

ContinueBlast:
        lda Squ2_SfxLenCounter  ;check for time to play second part
        cmp #$18
        bne DecrementSfx2Length
        ldy #$93                ;load second part reg contents then
        lda #$18
SBlasJ: bne BlstSJp             ;unconditional branch to load rest of reg contents

PlayPowerUpGrab:
        lda #$36                    ;load length of power-up grab sound
        sta Squ2_SfxLenCounter

ContinuePowerUpGrab:   
        lda Squ2_SfxLenCounter      ;load frequency reg based on length left over
        lsr                         ;divide by 2
        bcs DecrementSfx2Length     ;alter frequency every other frame
        tay
        lda PowerUpGrabFreqData-1,y ;use length left over / 2 for frequency offset
        ldx #$5d                    ;store reg contents of power-up grab sound
        ldy #$7f

LoadSqu2Regs:
        jsr PlaySqu2Sfx

DecrementSfx2Length:
        dec Squ2_SfxLenCounter   ;decrement length of sfx
        bne ExSfx2

EmptySfx2Buffer:
        ldx #$00                ;initialize square 2's sound effects buffer
        stx Square2SoundBuffer

StopSquare2Sfx:
        ldx #$0d                ;stop playing the sfx
        stx SND_MASTERCTRL_REG 
        ldx #$0f
        stx SND_MASTERCTRL_REG
ExSfx2: rts

Square2SfxHandler:
        lda Square2SoundBuffer ;special handling for the 1-up sound to keep it
        and #Sfx_ExtraLife     ;from being interrupted by other sounds on square 2
        bne ContinueExtraLife
        ldy Square2SoundQueue  ;check for sfx in queue
        beq CheckSfx2Buffer
        sty Square2SoundBuffer ;if found, put in buffer and check for the following
        bmi PlayBowserFall     ;bowser fall
        lsr Square2SoundQueue
        bcs PlayCoinGrab       ;coin grab
        lsr Square2SoundQueue
        bcs PlayGrowPowerUp    ;power-up reveal
        lsr Square2SoundQueue
        bcs PlayGrowVine       ;vine grow
        lsr Square2SoundQueue
        bcs PlayBlast          ;fireworks/gunfire
        lsr Square2SoundQueue
        bcs PlayTimerTick      ;timer tick
        lsr Square2SoundQueue
        bcs PlayPowerUpGrab    ;power-up grab
        lsr Square2SoundQueue
        bcs PlayExtraLife      ;1-up

CheckSfx2Buffer:
        lda Square2SoundBuffer   ;check for sfx in buffer
        beq ExS2H                ;if not found, exit sub
        bmi ContinueBowserFall   ;bowser fall
        lsr
        bcs Cont_CGrab_TTick     ;coin grab
        lsr
        bcs ContinueGrowItems    ;power-up reveal
        lsr
        bcs ContinueGrowItems    ;vine grow
        lsr
        bcs ContinueBlast        ;fireworks/gunfire
        lsr
        bcs Cont_CGrab_TTick     ;timer tick
        lsr
        bcs ContinuePowerUpGrab  ;power-up grab
        lsr
        bcs ContinueExtraLife    ;1-up
ExS2H:  rts

Cont_CGrab_TTick:
        jmp ContinueCGrabTTick

JumpToDecLength2:
        jmp DecrementSfx2Length

PlayBowserFall:    
         lda #$38                ;load length of bowser defeat sound
         sta Squ2_SfxLenCounter
         ldy #$c4                ;load contents of reg for bowser defeat sound
         lda #$18
BlstSJp: bne PBFRegs

ContinueBowserFall:
          lda Squ2_SfxLenCounter   ;check for almost near the end
          cmp #$08
          bne DecrementSfx2Length
          ldy #$a4                 ;if so, load the rest of reg contents for bowser defeat sound
          lda #$5a
PBFRegs:  ldx #$9f                 ;the fireworks/gunfire sound shares part of reg contents here
EL_LRegs: bne LoadSqu2Regs         ;this is an unconditional branch outta here

PlayExtraLife:
        lda #$30                  ;load length of 1-up sound
        sta Squ2_SfxLenCounter

ContinueExtraLife:
          lda Squ2_SfxLenCounter   
          ldx #$03                  ;load new tones only every eight frames
DivLLoop: lsr
          bcs JumpToDecLength2      ;if any bits set here, branch to dec the length
          dex
          bne DivLLoop              ;do this until all bits checked, if none set, continue
          tay
          lda ExtraLifeFreqData-1,y ;load our reg contents
          ldx #$82
          ldy #$7f
          bne EL_LRegs              ;unconditional branch

PlayGrowPowerUp:
        lda #$10                ;load length of power-up reveal sound
        bne GrowItemRegs

PlayGrowVine:
        lda #$20                ;load length of vine grow sound

GrowItemRegs:
        sta Squ2_SfxLenCounter   
        lda #$7f                  ;load contents of reg for both sounds directly
        sta SND_SQUARE2_REG+1
        lda #$00                  ;start secondary counter for both sounds
        sta Sfx_SecondaryCounter

ContinueGrowItems:
        inc Sfx_SecondaryCounter  ;increment secondary counter for both sounds
        lda Sfx_SecondaryCounter  ;this sound doesn't decrement the usual counter
        lsr                       ;divide by 2 to get the offset
        tay
        cpy Squ2_SfxLenCounter    ;have we reached the end yet?
        beq StopGrowItems         ;if so, branch to jump, and stop playing sounds
        lda #$9d                  ;load contents of other reg directly
        sta SND_SQUARE2_REG
        lda PUp_VGrow_FreqData,y  ;use secondary counter / 2 as offset for frequency regs
        jsr SetFreq_Squ2
        rts

StopGrowItems:
        jmp EmptySfx2Buffer       ;branch to stop playing sounds

;--------------------------------

BrickShatterFreqData:
        .byte $01, $0e, $0e, $0d, $0b, $06, $0c, $0f
        .byte $0a, $09, $03, $0d, $08, $0d, $06, $0c

PlayBrickShatter:
        lda #$20                 ;load length of brick shatter sound
        sta Noise_SfxLenCounter

ContinueBrickShatter:
        lda Noise_SfxLenCounter  
        lsr                         ;divide by 2 and check for bit set to use offset
        bcc DecrementSfx3Length
        tay
        ldx BrickShatterFreqData,y  ;load reg contents of brick shatter sound
        lda BrickShatterEnvData,y

PlayNoiseSfx:
        sta SND_NOISE_REG        ;play the sfx
        stx SND_NOISE_REG+2
        lda #$18
        sta SND_NOISE_REG+3

DecrementSfx3Length:
        dec Noise_SfxLenCounter  ;decrement length of sfx
        bne ExSfx3
        lda #$f0                 ;if done, stop playing the sfx
        sta SND_NOISE_REG
        lda #$00
        sta NoiseSoundBuffer
ExSfx3: rts

NoiseSfxHandler:
        ldy NoiseSoundQueue   ;check for sfx in queue
        beq CheckNoiseBuffer
        sty NoiseSoundBuffer  ;if found, put in buffer
        lsr NoiseSoundQueue
        bcs PlayBrickShatter  ;brick shatter
        lsr NoiseSoundQueue
        bcs PlayBowserFlame   ;bowser flame

CheckNoiseBuffer:
        lda NoiseSoundBuffer      ;check for sfx in buffer
        beq ExNH                  ;if not found, exit sub
        lsr
        bcs ContinueBrickShatter  ;brick shatter
        lsr
        bcs ContinueBowserFlame   ;bowser flame
ExNH:   rts

PlayBowserFlame:
        lda #$40                    ;load length of bowser flame sound
        sta Noise_SfxLenCounter

ContinueBowserFlame:
        lda Noise_SfxLenCounter
        lsr
        tay
        ldx #$0f                    ;load reg contents of bowser flame sound
        lda BowserFlameEnvData-1,y
        bne PlayNoiseSfx            ;unconditional branch here

;--------------------------------

ContinueMusic:
        jmp HandleSquare2Music  ;if we have music, start with square 2 channel

MusicHandler:
        lda EventMusicQueue     ;check event music queue
        bne LoadEventMusic
        lda AreaMusicQueue      ;check area music queue
        bne LoadAreaMusic
        lda EventMusicBuffer    ;check both buffers
        ora AreaMusicBuffer
        bne ContinueMusic 
        rts                     ;no music, then leave

LoadEventMusic:
           sta EventMusicBuffer      ;copy event music queue contents to buffer
           cmp #DeathMusic           ;is it death music?
           bne NoStopSfx             ;if not, jump elsewhere
           jsr StopSquare1Sfx        ;stop sfx in square 1 and 2
           jsr StopSquare2Sfx        ;but clear only square 1's sfx buffer
NoStopSfx: ldx AreaMusicBuffer
           stx AreaMusicBuffer_Alt   ;save current area music buffer to be re-obtained later
           ldy #$00
           sty NoteLengthTblAdder    ;default value for additional length byte offset
           sty AreaMusicBuffer       ;clear area music buffer
           cmp #TimeRunningOutMusic  ;is it time running out music?
           bne FindEventMusicHeader
           ldx #$08                  ;load offset to be added to length byte of header
           stx NoteLengthTblAdder
           bne FindEventMusicHeader  ;unconditional branch

LoadAreaMusic:
         cmp #$04                  ;is it underground music?
         bne NoStop1               ;no, do not stop square 1 sfx
         jsr StopSquare1Sfx
NoStop1: ldy #$10                  ;start counter used only by ground level music
GMLoopB: sty GroundMusicHeaderOfs

HandleAreaMusicLoopB:
         ldy #$00                  ;clear event music buffer
         sty EventMusicBuffer
         sta AreaMusicBuffer       ;copy area music queue contents to buffer
         cmp #$01                  ;is it ground level music?
         bne FindAreaMusicHeader
         inc GroundMusicHeaderOfs  ;increment but only if playing ground level music
         ldy GroundMusicHeaderOfs  ;is it time to loopback ground level music?
         cpy #$32
         bne LoadHeader            ;branch ahead with alternate offset
         ldy #$11
         bne GMLoopB               ;unconditional branch

FindAreaMusicHeader:
        ldy #$08                   ;load Y for offset of area music
        sty MusicOffset_Square2    ;residual instruction here

FindEventMusicHeader:
        iny                       ;increment Y pointer based on previously loaded queue contents
        lsr                       ;bit shift and increment until we find a set bit for music
        bcc FindEventMusicHeader

LoadHeader:
        lda MusicHeaderOffsetData,y  ;load offset for header
        tay
        lda MusicHeaderData,y        ;now load the header
        sta NoteLenLookupTblOfs
        lda MusicHeaderData+1,y
        sta MusicDataLow
        lda MusicHeaderData+2,y
        sta MusicDataHigh
        lda MusicHeaderData+3,y
        sta MusicOffset_Triangle
        lda MusicHeaderData+4,y
        sta MusicOffset_Square1
        lda MusicHeaderData+5,y
        sta MusicOffset_Noise
        sta NoiseDataLoopbackOfs
        lda #$01                     ;initialize music note counters
        sta Squ2_NoteLenCounter
        sta Squ1_NoteLenCounter
        sta Tri_NoteLenCounter
        sta Noise_BeatLenCounter
        lda #$00                     ;initialize music data offset for square 2
        sta MusicOffset_Square2
        sta AltRegContentFlag        ;initialize alternate control reg data used by square 1
        lda #$0b                     ;disable triangle channel and reenable it
        sta SND_MASTERCTRL_REG
        lda #$0f
        sta SND_MASTERCTRL_REG

HandleSquare2Music:
        dec Squ2_NoteLenCounter  ;decrement square 2 note length
        bne MiscSqu2MusicTasks   ;is it time for more data?  if not, branch to end tasks
        ldy MusicOffset_Square2  ;increment square 2 music offset and fetch data
        inc MusicOffset_Square2
        lda (MusicData),y
        beq EndOfMusicData       ;if zero, the data is a null terminator
        bpl Squ2NoteHandler      ;if non-negative, data is a note
        bne Squ2LengthHandler    ;otherwise it is length data

EndOfMusicData:
        lda EventMusicBuffer     ;check secondary buffer for time running out music
        cmp #TimeRunningOutMusic
        bne NotTRO
        lda AreaMusicBuffer_Alt  ;load previously saved contents of primary buffer
        bne MusicLoopBack        ;and start playing the song again if there is one
NotTRO: and #VictoryMusic        ;check for victory music (the only secondary that loops)
        bne VictoryMLoopBack
        lda AreaMusicBuffer      ;check primary buffer for any music except pipe intro
        and #%01011111
        bne MusicLoopBack        ;if any area music except pipe intro, music loops
        lda #$00                 ;clear primary and secondary buffers and initialize
        sta AreaMusicBuffer      ;control regs of square and triangle channels
        sta EventMusicBuffer
        sta SND_TRIANGLE_REG
        lda #$90    
        sta SND_SQUARE1_REG
        sta SND_SQUARE2_REG
        rts

MusicLoopBack:
        jmp HandleAreaMusicLoopB

VictoryMLoopBack:
        jmp LoadEventMusic

Squ2LengthHandler:
        jsr ProcessLengthData    ;store length of note
        sta Squ2_NoteLenBuffer
        ldy MusicOffset_Square2  ;fetch another byte (MUST NOT BE LENGTH BYTE!)
        inc MusicOffset_Square2
        lda (MusicData),y

Squ2NoteHandler:
          ldx Square2SoundBuffer     ;is there a sound playing on this channel?
          bne SkipFqL1
          jsr SetFreq_Squ2           ;no, then play the note
          beq Rest                   ;check to see if note is rest
          jsr LoadControlRegs        ;if not, load control regs for square 2
Rest:     sta Squ2_EnvelopeDataCtrl  ;save contents of A
          jsr Dump_Sq2_Regs          ;dump X and Y into square 2 control regs
SkipFqL1: lda Squ2_NoteLenBuffer     ;save length in square 2 note counter
          sta Squ2_NoteLenCounter

MiscSqu2MusicTasks:
           lda Square2SoundBuffer     ;is there a sound playing on square 2?
           bne HandleSquare1Music
           lda EventMusicBuffer       ;check for death music or d4 set on secondary buffer
           and #%10010001             ;note that regs for death music or d4 are loaded by default
           bne HandleSquare1Music
           ldy Squ2_EnvelopeDataCtrl  ;check for contents saved from LoadControlRegs
           beq NoDecEnv1
           dec Squ2_EnvelopeDataCtrl  ;decrement unless already zero
NoDecEnv1: jsr LoadEnvelopeData       ;do a load of envelope data to replace default
           sta SND_SQUARE2_REG        ;based on offset set by first load unless playing
           ldx #$7f                   ;death music or d4 set on secondary buffer
           stx SND_SQUARE2_REG+1

HandleSquare1Music:
        ldy MusicOffset_Square1    ;is there a nonzero offset here?
        beq HandleTriangleMusic    ;if not, skip ahead to the triangle channel
        dec Squ1_NoteLenCounter    ;decrement square 1 note length
        bne MiscSqu1MusicTasks     ;is it time for more data?

FetchSqu1MusicData:
        ldy MusicOffset_Square1    ;increment square 1 music offset and fetch data
        inc MusicOffset_Square1
        lda (MusicData),y
        bne Squ1NoteHandler        ;if nonzero, then skip this part
        lda #$83
        sta SND_SQUARE1_REG        ;store some data into control regs for square 1
        lda #$94                   ;and fetch another byte of data, used to give
        sta SND_SQUARE1_REG+1      ;death music its unique sound
        sta AltRegContentFlag
        bne FetchSqu1MusicData     ;unconditional branch

Squ1NoteHandler:
           jsr AlternateLengthHandler
           sta Squ1_NoteLenCounter    ;save contents of A in square 1 note counter
           ldy Square1SoundBuffer     ;is there a sound playing on square 1?
           bne HandleTriangleMusic
           txa
           and #%00111110             ;change saved data to appropriate note format
           jsr SetFreq_Squ1           ;play the note
           beq SkipCtrlL
           jsr LoadControlRegs
SkipCtrlL: sta Squ1_EnvelopeDataCtrl  ;save envelope offset
           jsr Dump_Squ1_Regs

MiscSqu1MusicTasks:
              lda Square1SoundBuffer     ;is there a sound playing on square 1?
              bne HandleTriangleMusic
              lda EventMusicBuffer       ;check for death music or d4 set on secondary buffer
              and #%10010001
              bne DeathMAltReg
              ldy Squ1_EnvelopeDataCtrl  ;check saved envelope offset
              beq NoDecEnv2
              dec Squ1_EnvelopeDataCtrl  ;decrement unless already zero
NoDecEnv2:    jsr LoadEnvelopeData       ;do a load of envelope data
              sta SND_SQUARE1_REG        ;based on offset set by first load
DeathMAltReg: lda AltRegContentFlag      ;check for alternate control reg data
              bne DoAltLoad
              lda #$7f                   ;load this value if zero, the alternate value
DoAltLoad:    sta SND_SQUARE1_REG+1      ;if nonzero, and let's move on

HandleTriangleMusic:
        lda MusicOffset_Triangle
        dec Tri_NoteLenCounter    ;decrement triangle note length
        bne HandleNoiseMusic      ;is it time for more data?
        ldy MusicOffset_Triangle  ;increment square 1 music offset and fetch data
        inc MusicOffset_Triangle
        lda (MusicData),y
        beq LoadTriCtrlReg        ;if zero, skip all this and move on to noise 
        bpl TriNoteHandler        ;if non-negative, data is note
        jsr ProcessLengthData     ;otherwise, it is length data
        sta Tri_NoteLenBuffer     ;save contents of A
        lda #$1f
        sta SND_TRIANGLE_REG      ;load some default data for triangle control reg
        ldy MusicOffset_Triangle  ;fetch another byte
        inc MusicOffset_Triangle
        lda (MusicData),y
        beq LoadTriCtrlReg        ;check once more for nonzero data

TriNoteHandler:
          jsr SetFreq_Tri
          ldx Tri_NoteLenBuffer   ;save length in triangle note counter
          stx Tri_NoteLenCounter
          lda EventMusicBuffer
          and #%01101110          ;check for death music or d4 set on secondary buffer
          bne NotDOrD4            ;if playing any other secondary, skip primary buffer check
          lda AreaMusicBuffer     ;check primary buffer for water or castle level music
          and #%00001010
          beq HandleNoiseMusic    ;if playing any other primary, or death or d4, go on to noise routine
NotDOrD4: txa                     ;if playing water or castle music or any secondary
          cmp #$12                ;besides death music or d4 set, check length of note
          bcs LongN
          lda EventMusicBuffer    ;check for win castle music again if not playing a long note
          and #EndOfCastleMusic
          beq MediN
          lda #$0f                ;load value $0f if playing the win castle music and playing a short
          bne LoadTriCtrlReg      ;note, load value $1f if playing water or castle level music or any
MediN:    lda #$1f                ;secondary besides death and d4 except win castle or win castle and playing
          bne LoadTriCtrlReg      ;a short note, and load value $ff if playing a long note on water, castle
LongN:    lda #$ff                ;or any secondary (including win castle) except death and d4

LoadTriCtrlReg:           
        sta SND_TRIANGLE_REG      ;save final contents of A into control reg for triangle

HandleNoiseMusic:
        lda AreaMusicBuffer       ;check if playing underground or castle music
        and #%11110011
        beq ExitMusicHandler      ;if so, skip the noise routine
        dec Noise_BeatLenCounter  ;decrement noise beat length
        bne ExitMusicHandler      ;is it time for more data?

FetchNoiseBeatData:
        ldy MusicOffset_Noise       ;increment noise beat offset and fetch data
        inc MusicOffset_Noise
        lda (MusicData),y           ;get noise beat data, if nonzero, branch to handle
        bne NoiseBeatHandler
        lda NoiseDataLoopbackOfs    ;if data is zero, reload original noise beat offset
        sta MusicOffset_Noise       ;and loopback next time around
        bne FetchNoiseBeatData      ;unconditional branch

NoiseBeatHandler:
        jsr AlternateLengthHandler
        sta Noise_BeatLenCounter    ;store length in noise beat counter
        txa
        and #%00111110              ;reload data and erase length bits
        beq SilentBeat              ;if no beat data, silence
        cmp #$30                    ;check the beat data and play the appropriate
        beq LongBeat                ;noise accordingly
        cmp #$20
        beq StrongBeat
        and #%00010000  
        beq SilentBeat
        lda #$1c        ;short beat data
        ldx #$03
        ldy #$18
        bne PlayBeat

StrongBeat:
        lda #$1c        ;strong beat data
        ldx #$0c
        ldy #$18
        bne PlayBeat

LongBeat:
        lda #$1c        ;long beat data
        ldx #$03
        ldy #$58
        bne PlayBeat

SilentBeat:
        lda #$10        ;silence

PlayBeat:
        sta SND_NOISE_REG    ;load beat data into noise regs
        stx SND_NOISE_REG+2
        sty SND_NOISE_REG+3

ExitMusicHandler:
        rts

AlternateLengthHandler:
        tax            ;save a copy of original byte into X
        ror            ;save LSB from original byte into carry
        txa            ;reload original byte and rotate three times
        rol            ;turning xx00000x into 00000xxx, with the
        rol            ;bit in carry as the MSB here
        rol

ProcessLengthData:
        and #%00000111              ;clear all but the three LSBs
        clc
        adc $f0                     ;add offset loaded from first header byte
        adc NoteLengthTblAdder      ;add extra if time running out music
        tay
        lda MusicLengthLookupTbl,y  ;load length
        rts

LoadControlRegs:
           lda EventMusicBuffer  ;check secondary buffer for win castle music
           and #EndOfCastleMusic
           beq NotECstlM
           lda #$04              ;this value is only used for win castle music
           bne AllMus            ;unconditional branch
NotECstlM: lda AreaMusicBuffer
           and #%01111101        ;check primary buffer for water music
           beq WaterMus
           lda #$08              ;this is the default value for all other music
           bne AllMus
WaterMus:  lda #$28              ;this value is used for water music and all other event music
AllMus:    ldx #$82              ;load contents of other sound regs for square 2
           ldy #$7f
           rts

LoadEnvelopeData:
        lda EventMusicBuffer           ;check secondary buffer for win castle music
        and #EndOfCastleMusic
        beq LoadUsualEnvData
        lda EndOfCastleMusicEnvData,y  ;load data from offset for win castle music
        rts

LoadUsualEnvData:
        lda AreaMusicBuffer            ;check primary buffer for water music
        and #%01111101
        beq LoadWaterEventMusEnvData
        lda AreaMusicEnvData,y         ;load default data from offset for all other music
        rts

LoadWaterEventMusEnvData:
        lda WaterEventMusEnvData,y     ;load data from offset for water music and all other event music
        rts

;--------------------------------

;music header offsets

MusicHeaderData:
      .byte DeathMusHdr-MHD           ;event music
      .byte GameOverMusHdr-MHD
      .byte VictoryMusHdr-MHD
      .byte WinCastleMusHdr-MHD
      .byte GameOverMusHdr-MHD
      .byte EndOfLevelMusHdr-MHD
      .byte TimeRunningOutHdr-MHD
      .byte SilenceHdr-MHD

      .byte GroundLevelPart1Hdr-MHD   ;area music
      .byte WaterMusHdr-MHD
      .byte UndergroundMusHdr-MHD
      .byte CastleMusHdr-MHD
      .byte Star_CloudHdr-MHD
      .byte GroundLevelLeadInHdr-MHD
      .byte Star_CloudHdr-MHD
      .byte SilenceHdr-MHD

      .byte GroundLevelLeadInHdr-MHD  ;ground level music layout
      .byte GroundLevelPart1Hdr-MHD, GroundLevelPart1Hdr-MHD
      .byte GroundLevelPart2AHdr-MHD, GroundLevelPart2BHdr-MHD, GroundLevelPart2AHdr-MHD, GroundLevelPart2CHdr-MHD
      .byte GroundLevelPart2AHdr-MHD, GroundLevelPart2BHdr-MHD, GroundLevelPart2AHdr-MHD, GroundLevelPart2CHdr-MHD
      .byte GroundLevelPart3AHdr-MHD, GroundLevelPart3BHdr-MHD, GroundLevelPart3AHdr-MHD, GroundLevelLeadInHdr-MHD
      .byte GroundLevelPart1Hdr-MHD, GroundLevelPart1Hdr-MHD
      .byte GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD
      .byte GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD
      .byte GroundLevelPart3AHdr-MHD, GroundLevelPart3BHdr-MHD, GroundLevelPart3AHdr-MHD, GroundLevelLeadInHdr-MHD
      .byte GroundLevelPart4AHdr-MHD, GroundLevelPart4BHdr-MHD, GroundLevelPart4AHdr-MHD, GroundLevelPart4CHdr-MHD

;music headers
;header format is as follows: 
;1 byte - length byte offset
;2 bytes -  music data address
;1 byte - triangle data offset
;1 byte - square 1 data offset
;1 byte - noise data offset (not used by secondary music)

TimeRunningOutHdr:    .byte $08, <TimeRunOutMusData, >TimeRunOutMusData, $27, $18
Star_CloudHdr:        .byte $20, <Star_CloudMData, >Star_CloudMData, $2e, $1a, $40
EndOfLevelMusHdr:     .byte $20, <WinLevelMusData, >WinLevelMusData, $3d, $21
ResidualHeaderData:   .byte $20, $c4, $fc, $3f, $1d
UndergroundMusHdr:    .byte $18, <UndergroundMusData, >UndergroundMusData, $00, $00
SilenceHdr:           .byte $08, <SilenceData, >SilenceData, $00
CastleMusHdr:         .byte $00, <CastleMusData, >CastleMusData, $93, $62
VictoryMusHdr:        .byte $10, <VictoryMusData, >VictoryMusData, $24, $14
GameOverMusHdr:       .byte $18, <GameOverMusData, >GameOverMusData, $1e, $14
WaterMusHdr:          .byte $08, <WaterMusData, >WaterMusData, $a0, $70, $68
WinCastleMusHdr:      .byte $08, <EndOfCastleMusData, >EndOfCastleMusData, $4c, $24
GroundLevelPart1Hdr:  .byte $18, <GroundM_P1Data, >GroundM_P1Data, $2d, $1c, $b8
GroundLevelPart2AHdr: .byte $18, <GroundM_P2AData, >GroundM_P2AData, $20, $12, $70
GroundLevelPart2BHdr: .byte $18, <GroundM_P2BData, >GroundM_P2BData, $1b, $10, $44
GroundLevelPart2CHdr: .byte $18, <GroundM_P2CData, >GroundM_P2CData, $11, $0a, $1c
GroundLevelPart3AHdr: .byte $18, <GroundM_P3AData, >GroundM_P3AData, $2d, $10, $58
GroundLevelPart3BHdr: .byte $18, <GroundM_P3BData, >GroundM_P3BData, $14, $0d, $3f
GroundLevelLeadInHdr: .byte $18, <GroundMLdInData, >GroundMLdInData, $15, $0d, $21
GroundLevelPart4AHdr: .byte $18, <GroundM_P4AData, >GroundM_P4AData, $18, $10, $7a
GroundLevelPart4BHdr: .byte $18, <GroundM_P4BData, >GroundM_P4BData, $19, $0f, $54
GroundLevelPart4CHdr: .byte $18, <GroundM_P4CData, >GroundM_P4CData, $1e, $12, $2b
DeathMusHdr:          .byte $18, <DeathMusData, >DeathMusData, $1e, $0f, $2d

;--------------------------------

;MUSIC DATA
;square 2/triangle format
;d7 - length byte flag (0-note, 1-length)
;if d7 is set to 0 and d6-d0 is nonzero:
;d6-d0 - note offset in frequency look-up table (must be even)
;if d7 is set to 1:
;d6-d3 - unused
;d2-d0 - length offset in length look-up table
;value of $00 in square 2 data is used as null terminator, affects all sound channels
;value of $00 in triangle data causes routine to skip note

;square 1 format
;d7-d6, d0 - length offset in length look-up table (bit order is d0,d7,d6)
;d5-d1 - note offset in frequency look-up table
;value of $00 in square 1 data is flag alternate control reg data to be loaded

;noise format
;d7-d6, d0 - length offset in length look-up table (bit order is d0,d7,d6)
;d5-d4 - beat type (0 - rest, 1 - short, 2 - strong, 3 - long)
;d3-d1 - unused
;value of $00 in noise data is used as null terminator, affects only noise

;all music data is organized into sections (unless otherwise stated):
;square 2, square 1, triangle, noise

Star_CloudMData:
      .byte $84, $2c, $2c, $2c, $82, $04, $2c, $04, $85, $2c, $84, $2c, $2c
      .byte $2a, $2a, $2a, $82, $04, $2a, $04, $85, $2a, $84, $2a, $2a, $00

      .byte $1f, $1f, $1f, $98, $1f, $1f, $98, $9e, $98, $1f
      .byte $1d, $1d, $1d, $94, $1d, $1d, $94, $9c, $94, $1d

      .byte $86, $18, $85, $26, $30, $84, $04, $26, $30
      .byte $86, $14, $85, $22, $2c, $84, $04, $22, $2c

      .byte $21, $d0, $c4, $d0, $31, $d0, $c4, $d0, $00

GroundM_P1Data:
      .byte $85, $2c, $22, $1c, $84, $26, $2a, $82, $28, $26, $04
      .byte $87, $22, $34, $3a, $82, $40, $04, $36, $84, $3a, $34
      .byte $82, $2c, $30, $85, $2a

SilenceData:
      .byte $00

      .byte $5d, $55, $4d, $15, $19, $96, $15, $d5, $e3, $eb
      .byte $2d, $a6, $2b, $27, $9c, $9e, $59

      .byte $85, $22, $1c, $14, $84, $1e, $22, $82, $20, $1e, $04, $87
      .byte $1c, $2c, $34, $82, $36, $04, $30, $34, $04, $2c, $04, $26
      .byte $2a, $85, $22

GroundM_P2AData:
      .byte $84, $04, $82, $3a, $38, $36, $32, $04, $34
      .byte $04, $24, $26, $2c, $04, $26, $2c, $30, $00

      .byte $05, $b4, $b2, $b0, $2b, $ac, $84
      .byte $9c, $9e, $a2, $84, $94, $9c, $9e

      .byte $85, $14, $22, $84, $2c, $85, $1e
      .byte $82, $2c, $84, $2c, $1e

GroundM_P2BData:
      .byte $84, $04, $82, $3a, $38, $36, $32, $04, $34
      .byte $04, $64, $04, $64, $86, $64, $00

      .byte $05, $b4, $b2, $b0, $2b, $ac, $84
      .byte $37, $b6, $b6, $45

      .byte $85, $14, $1c, $82, $22, $84, $2c
      .byte $4e, $82, $4e, $84, $4e, $22

GroundM_P2CData:
      .byte $84, $04, $85, $32, $85, $30, $86, $2c, $04, $00

      .byte $05, $a4, $05, $9e, $05, $9d, $85
      
      .byte $84, $14, $85, $24, $28, $2c, $82
      .byte $22, $84, $22, $14

      .byte $21, $d0, $c4, $d0, $31, $d0, $c4, $d0, $00

GroundM_P3AData:
      .byte $82, $2c, $84, $2c, $2c, $82, $2c, $30
      .byte $04, $34, $2c, $04, $26, $86, $22, $00

      .byte $a4, $25, $25, $a4, $29, $a2, $1d, $9c, $95

GroundM_P3BData:
      .byte $82, $2c, $2c, $04, $2c, $04, $2c, $30, $85, $34, $04, $04, $00

      .byte $a4, $25, $25, $a4, $a8, $63, $04

;triangle data used by both sections of third part
      .byte $85, $0e, $1a, $84, $24, $85, $22, $14, $84, $0c

GroundMLdInData:
      .byte $82, $34, $84, $34, $34, $82, $2c, $84, $34, $86, $3a, $04, $00

      .byte $a0, $21, $21, $a0, $21, $2b, $05, $a3

      .byte $82, $18, $84, $18, $18, $82, $18, $18, $04, $86, $3a, $22

;noise data used by lead-in and third part sections
      .byte $31, $90, $31, $90, $31, $71, $31, $90, $90, $90, $00

GroundM_P4AData:
      .byte $82, $34, $84, $2c, $85, $22, $84, $24
      .byte $82, $26, $36, $04, $36, $86, $26, $00

      .byte $ac, $27, $5d, $1d, $9e, $2d, $ac, $9f

      .byte $85, $14, $82, $20, $84, $22, $2c
      .byte $1e, $1e, $82, $2c, $2c, $1e, $04

GroundM_P4BData:
      .byte $87, $2a, $40, $40, $40, $3a, $36 
      .byte $82, $34, $2c, $04, $26, $86, $22, $00

      .byte $e3, $f7, $f7, $f7, $f5, $f1, $ac, $27, $9e, $9d

      .byte $85, $18, $82, $1e, $84, $22, $2a
      .byte $22, $22, $82, $2c, $2c, $22, $04

DeathMusData:
      .byte $86, $04 ;death music share data with fourth part c of ground level music 

GroundM_P4CData:
      .byte $82, $2a, $36, $04, $36, $87, $36, $34, $30, $86, $2c, $04, $00
      
      .byte $00, $68, $6a, $6c, $45 ;death music only

      .byte $a2, $31, $b0, $f1, $ed, $eb, $a2, $1d, $9c, $95

      .byte $86, $04 ;death music only

      .byte $85, $22, $82, $22, $87, $22, $26, $2a, $84, $2c, $22, $86, $14

;noise data used by fourth part sections
      .byte $51, $90, $31, $11, $00

CastleMusData:
      .byte $80, $22, $28, $22, $26, $22, $24, $22, $26
      .byte $22, $28, $22, $2a, $22, $28, $22, $26
      .byte $22, $28, $22, $26, $22, $24, $22, $26
      .byte $22, $28, $22, $2a, $22, $28, $22, $26
      .byte $20, $26, $20, $24, $20, $26, $20, $28
      .byte $20, $26, $20, $28, $20, $26, $20, $24
      .byte $20, $26, $20, $24, $20, $26, $20, $28
      .byte $20, $26, $20, $28, $20, $26, $20, $24
      .byte $28, $30, $28, $32, $28, $30, $28, $2e
      .byte $28, $30, $28, $2e, $28, $2c, $28, $2e
      .byte $28, $30, $28, $32, $28, $30, $28, $2e
      .byte $28, $30, $28, $2e, $28, $2c, $28, $2e, $00

      .byte $04, $70, $6e, $6c, $6e, $70, $72, $70, $6e
      .byte $70, $6e, $6c, $6e, $70, $72, $70, $6e
      .byte $6e, $6c, $6e, $70, $6e, $70, $6e, $6c
      .byte $6e, $6c, $6e, $70, $6e, $70, $6e, $6c
      .byte $76, $78, $76, $74, $76, $74, $72, $74
      .byte $76, $78, $76, $74, $76, $74, $72, $74

      .byte $84, $1a, $83, $18, $20, $84, $1e, $83, $1c, $28
      .byte $26, $1c, $1a, $1c

GameOverMusData:
      .byte $82, $2c, $04, $04, $22, $04, $04, $84, $1c, $87
      .byte $26, $2a, $26, $84, $24, $28, $24, $80, $22, $00

      .byte $9c, $05, $94, $05, $0d, $9f, $1e, $9c, $98, $9d

      .byte $82, $22, $04, $04, $1c, $04, $04, $84, $14
      .byte $86, $1e, $80, $16, $80, $14

TimeRunOutMusData:
      .byte $81, $1c, $30, $04, $30, $30, $04, $1e, $32, $04, $32, $32
      .byte $04, $20, $34, $04, $34, $34, $04, $36, $04, $84, $36, $00

      .byte $46, $a4, $64, $a4, $48, $a6, $66, $a6, $4a, $a8, $68, $a8
      .byte $6a, $44, $2b

      .byte $81, $2a, $42, $04, $42, $42, $04, $2c, $64, $04, $64, $64
      .byte $04, $2e, $46, $04, $46, $46, $04, $22, $04, $84, $22

WinLevelMusData:
      .byte $87, $04, $06, $0c, $14, $1c, $22, $86, $2c, $22
      .byte $87, $04, $60, $0e, $14, $1a, $24, $86, $2c, $24
      .byte $87, $04, $08, $10, $18, $1e, $28, $86, $30, $30
      .byte $80, $64, $00

      .byte $cd, $d5, $dd, $e3, $ed, $f5, $bb, $b5, $cf, $d5
      .byte $db, $e5, $ed, $f3, $bd, $b3, $d1, $d9, $df, $e9
      .byte $f1, $f7, $bf, $ff, $ff, $ff, $34
      .byte $00 ;unused byte

      .byte $86, $04, $87, $14, $1c, $22, $86, $34, $84, $2c
      .byte $04, $04, $04, $87, $14, $1a, $24, $86, $32, $84
      .byte $2c, $04, $86, $04, $87, $18, $1e, $28, $86, $36
      .byte $87, $30, $30, $30, $80, $2c

;square 2 and triangle use the same data, square 1 is unused
UndergroundMusData:
      .byte $82, $14, $2c, $62, $26, $10, $28, $80, $04
      .byte $82, $14, $2c, $62, $26, $10, $28, $80, $04
      .byte $82, $08, $1e, $5e, $18, $60, $1a, $80, $04
      .byte $82, $08, $1e, $5e, $18, $60, $1a, $86, $04
      .byte $83, $1a, $18, $16, $84, $14, $1a, $18, $0e, $0c
      .byte $16, $83, $14, $20, $1e, $1c, $28, $26, $87
      .byte $24, $1a, $12, $10, $62, $0e, $80, $04, $04
      .byte $00

;noise data directly follows square 2 here unlike in other songs
WaterMusData:
      .byte $82, $18, $1c, $20, $22, $26, $28 
      .byte $81, $2a, $2a, $2a, $04, $2a, $04, $83, $2a, $82, $22
      .byte $86, $34, $32, $34, $81, $04, $22, $26, $2a, $2c, $30
      .byte $86, $34, $83, $32, $82, $36, $84, $34, $85, $04, $81, $22
      .byte $86, $30, $2e, $30, $81, $04, $22, $26, $2a, $2c, $2e
      .byte $86, $30, $83, $22, $82, $36, $84, $34, $85, $04, $81, $22
      .byte $86, $3a, $3a, $3a, $82, $3a, $81, $40, $82, $04, $81, $3a
      .byte $86, $36, $36, $36, $82, $36, $81, $3a, $82, $04, $81, $36
      .byte $86, $34, $82, $26, $2a, $36
      .byte $81, $34, $34, $85, $34, $81, $2a, $86, $2c, $00

      .byte $84, $90, $b0, $84, $50, $50, $b0, $00

      .byte $98, $96, $94, $92, $94, $96, $58, $58, $58, $44
      .byte $5c, $44, $9f, $a3, $a1, $a3, $85, $a3, $e0, $a6
      .byte $23, $c4, $9f, $9d, $9f, $85, $9f, $d2, $a6, $23
      .byte $c4, $b5, $b1, $af, $85, $b1, $af, $ad, $85, $95
      .byte $9e, $a2, $aa, $6a, $6a, $6b, $5e, $9d

      .byte $84, $04, $04, $82, $22, $86, $22
      .byte $82, $14, $22, $2c, $12, $22, $2a, $14, $22, $2c
      .byte $1c, $22, $2c, $14, $22, $2c, $12, $22, $2a, $14
      .byte $22, $2c, $1c, $22, $2c, $18, $22, $2a, $16, $20
      .byte $28, $18, $22, $2a, $12, $22, $2a, $18, $22, $2a
      .byte $12, $22, $2a, $14, $22, $2c, $0c, $22, $2c, $14, $22, $34, $12
      .byte $22, $30, $10, $22, $2e, $16, $22, $34, $18, $26
      .byte $36, $16, $26, $36, $14, $26, $36, $12, $22, $36
      .byte $5c, $22, $34, $0c, $22, $22, $81, $1e, $1e, $85, $1e
      .byte $81, $12, $86, $14

EndOfCastleMusData:
      .byte $81, $2c, $22, $1c, $2c, $22, $1c, $85, $2c, $04
      .byte $81, $2e, $24, $1e, $2e, $24, $1e, $85, $2e, $04
      .byte $81, $32, $28, $22, $32, $28, $22, $85, $32
      .byte $87, $36, $36, $36, $84, $3a, $00

      .byte $5c, $54, $4c, $5c, $54, $4c
      .byte $5c, $1c, $1c, $5c, $5c, $5c, $5c
      .byte $5e, $56, $4e, $5e, $56, $4e
      .byte $5e, $1e, $1e, $5e, $5e, $5e, $5e
      .byte $62, $5a, $50, $62, $5a, $50
      .byte $62, $22, $22, $62, $e7, $e7, $e7, $2b

      .byte $86, $14, $81, $14, $80, $14, $14, $81, $14, $14, $14, $14
      .byte $86, $16, $81, $16, $80, $16, $16, $81, $16, $16, $16, $16
      .byte $81, $28, $22, $1a, $28, $22, $1a, $28, $80, $28, $28
      .byte $81, $28, $87, $2c, $2c, $2c, $84, $30

VictoryMusData:
      .byte $83, $04, $84, $0c, $83, $62, $10, $84, $12
      .byte $83, $1c, $22, $1e, $22, $26, $18, $1e, $04, $1c, $00

      .byte $e3, $e1, $e3, $1d, $de, $e0, $23
      .byte $ec, $75, $74, $f0, $f4, $f6, $ea, $31, $2d

      .byte $83, $12, $14, $04, $18, $1a, $1c, $14
      .byte $26, $22, $1e, $1c, $18, $1e, $22, $0c, $14

;unused space
      .byte $ff, $ff, $ff

FreqRegLookupTbl:
      .byte $00, $88, $00, $2f, $00, $00
      .byte $02, $a6, $02, $80, $02, $5c, $02, $3a
      .byte $02, $1a, $01, $df, $01, $c4, $01, $ab
      .byte $01, $93, $01, $7c, $01, $67, $01, $53
      .byte $01, $40, $01, $2e, $01, $1d, $01, $0d
      .byte $00, $fe, $00, $ef, $00, $e2, $00, $d5
      .byte $00, $c9, $00, $be, $00, $b3, $00, $a9
      .byte $00, $a0, $00, $97, $00, $8e, $00, $86
      .byte $00, $77, $00, $7e, $00, $71, $00, $54
      .byte $00, $64, $00, $5f, $00, $59, $00, $50
      .byte $00, $47, $00, $43, $00, $3b, $00, $35
      .byte $00, $2a, $00, $23, $04, $75, $03, $57
      .byte $02, $f9, $02, $cf, $01, $fc, $00, $6a

MusicLengthLookupTbl:
      .byte $05, $0a, $14, $28, $50, $1e, $3c, $02
      .byte $04, $08, $10, $20, $40, $18, $30, $0c
      .byte $03, $06, $0c, $18, $30, $12, $24, $08
      .byte $36, $03, $09, $06, $12, $1b, $24, $0c
      .byte $24, $02, $06, $04, $0c, $12, $18, $08
      .byte $12, $01, $03, $02, $06, $09, $0c, $04

EndOfCastleMusicEnvData:
      .byte $98, $99, $9a, $9b

AreaMusicEnvData:
      .byte $90, $94, $94, $95, $95, $96, $97, $98

WaterEventMusEnvData:
      .byte $90, $91, $92, $92, $93, $93, $93, $94
      .byte $94, $94, $94, $94, $94, $95, $95, $95
      .byte $95, $95, $95, $96, $96, $96, $96, $96
      .byte $96, $96, $96, $96, $96, $96, $96, $96
      .byte $96, $96, $96, $96, $95, $95, $94, $93

BowserFlameEnvData:
      .byte $15, $16, $16, $17, $17, $18, $19, $19
      .byte $1a, $1a, $1c, $1d, $1d, $1e, $1e, $1f
      .byte $1f, $1f, $1f, $1e, $1d, $1c, $1e, $1f
      .byte $1f, $1e, $1d, $1c, $1a, $18, $16, $14

BrickShatterEnvData:
      .byte $15, $16, $16, $17, $17, $18, $19, $19
      .byte $1a, $1a, $1c, $1d, $1d, $1e, $1e, $1f

