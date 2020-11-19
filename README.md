# SMB & SMB2J Practice ROM

A speedrun practice ROM for Super Mario Bros. and Super Mario Bros 2 - The Lost Levels.

For feature requests or bug reports, please visit the [issue tracker](https://github.com/pellsson/smb/issues).

Looking to practice on PAL? [Try out threecreepio's independent PAL-conversion.](https://github.com/threecreepio/pallsson)

## Major Version 5 (Current 5.6)

### New Features 
- Ability to **wipe SMB/LL/LL-EXT records** under settings.
- Added [tavenwebb2002](https://twitch.tv/tavenwebb2002) to the loader. Huge congratulations on the world record.
- Added **real-time counter** for each level (Records saved in WRAM).
	- Your **time & PB** is presented at the **end of each level**.
	- All **PBs** for each level and game can be viewed from the **loader menu**.
- Allows you to **start** directly on **Second Quest** in Super Mario Bros (Press B on title).
- Added **Slow Motion** feature (accessible from pause menu). Kinda conceptual and experimental at this point.
- Added **Frame Advance**. Set `SLOMO` in pause menu to `ADV`. To advance frame, press **A** on **controller two**. **If you dont have two controllers you will softlock :)**

### Bug Fixes
- 5.6 bug fixes
	- Fixed bug where loading state would cause a subsequent save if select was still held.
	- Fixed sprite & WRAM corruption.
	- Sanity check settings.
- 5.5 bug fixes
	- Fixed bug where early input to pause menu would overflow ppubuffer.
	- Fixed bugs relating to running it on physical carts.
	- Fixed bugs relating to save states.
	- Updated faces to reflect new leader board.
- 5.4 bug fixes
	- When starting on a specific rule in Lost Levels the frame counter was set incorrectly, which could cause rule-deviations vs. vanilla.
	- Use the coin-sprite for sprite0 (no more glitchy garbage under the coin).
	- The Save-state is no longer invalidated as you power the machine on and off.
- 5.3 bug fixes
	- Disabled **B** in pause menu.
	- Fixed a million bugs related to save states
	- Fix rendering issue when showing RTA time @ 8-4s and D-4
- 5.2 bugs fixes
	- The 8-4s and D-4 records are tracked and shown @ Axe grab.
	- Slowmotion doesn't crash arbitrarily (I think)
	- Now possible to save while in slow motion mode.
- 5.1 bugs fixes
	- Support for physical hardware.
	- Save states won't break PBs
	- Slow motion in Original doesn't brick Top Loader.
- Remove artifact in the statusbar where the bottom portion of certain letters would jitter with scrolling.
- There is no longer a horribly ugly flicker when you save or load states (unless you load from a level with a different background color than the save state).
- Fix "Restart Level" that would glitch Lost Levels in some scenarios.
- Fix bug where only parts of the font-set was copied if using a custom one.
- Lots of other smaller things...

## Persistence

To keep settings, frame rules and stuff persistent; configure your game
system (emulator, PowerPAK, EverDrive etc.) to allow the SMB Practice ROM
battery-backed WRAM. Essentially, figure out how to make it so that you can
save in Zelda (without savestates), power off the system, and load (without using save states). Then do the same for the SMB Practice ROM.

## Feature list
- Practice both **SMB** and **SMB Lost Levels**
- **Start** the game from **any frame rule**
- **Start** on **any level**.
- Keeps **track of prefered start rule** for each level.
- **Battery backed WRAM** for persistent memory.
	- Level rules.
	- One save state.
	- Personal bests.
	- Settings.
- **Restart the level** from the **frame-rule** you entered.
- Monitor **two user-defined RAM addresses**.
- Built-in **save-states**.
- Customizable **hotkeys**.
- **In-game menu** with lots of stuff.
- **Pause** completely **freezes** the game (does not advance frame rules).
- Practice **specific scenarios**
- **Advanced settings** menu in the loader.
- **Real-time** counter for each level, and persistent records.
- Start directly on the **Second Quest** in SMB1.
- Practice with **Slow Motion**.
- Practice with **Frame Advance** (A on second controller to advance. Start on second to exit.).
- And a lot more...

## Download & Installation

First download the desired version below:

- [Version 5.6 - IPS](https://github.com/pellsson/smb/raw/master/smb-v5.6.ips)

Then simply apply that IPS (using for instance Lunar IPS) to the an original, unmodified version of the Super Mario Bros. (US/World) ROM. *DO NOT* use The Lost Levels. The MD5 checksum for the ROM you should be using is `811b027eaf99c2def7b933c5208636de`.

<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
	<input type="hidden" name="cmd" value="_donations" />
	<input type="hidden" name="business" value="66GJXJYBSFVB6" />
	<input type="hidden" name="currency_code" value="USD" />
	<input type="image" src="https://www.paypalobjects.com/en_US/SE/i/btn/btn_donateCC_LG.gif" border="0" name="submit" title="PayPal - The safer, easier way to pay online!" alt="Donate with PayPal button" />
	<img alt="" border="0" src="https://www.paypal.com/en_SE/i/scr/pixel.gif" width="1" height="1" />
</form>

Have fun!

## Credits
Sprites for peach shamelessly stolen from [Super Mario Bros.: Peach Edition](https://www.romhacking.net/hacks/1229)
