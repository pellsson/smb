# SMB & SMB2J Practice ROM

A speedrun practice ROM for Super Mario Bros. and Super Mario Bros 2 - The Lost Levels.

For feature requests or bug reports, please visit the [issue tracker](https://github.com/pellsson/smb/issues).

<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
	<input type="hidden" name="cmd" value="_donations" />
	<input type="hidden" name="business" value="66GJXJYBSFVB6" />
	<input type="hidden" name="currency_code" value="USD" />
	<input type="image" src="https://www.paypalobjects.com/en_US/SE/i/btn/btn_donateCC_LG.gif" border="0" name="submit" title="PayPal - The safer, easier way to pay online!" alt="Donate with PayPal button" />
	<img alt="" border="0" src="https://www.paypal.com/en_SE/i/scr/pixel.gif" width="1" height="1" />
</form>
<br />

## Version 5.0

### Features 

- Add [tavenwebb2002](https://twitch.tv/tavenwebb2002) to the loader. Huge congratulations on the world record.
- Add **real-time counter** for each level (Records saved in WRAM).
	- Your time & PB is presented at the end of each level.
	- All PBs for each level and game can be viewed from the loader menu.
- Allow you to **start** directly on **Second Quest** in Super Mario Bros (Press B on title).
- Added **Slow Motion** feature (accessible from pause menu). Kinda conceptual and experimental at this point.

### Bug Fixes

- Remove articat in the statusbar where the bottom portion of certain letters would jitter with scrolling.
- There is no longer a horribly ugly flicker when you save or load states (unless you load from a level with a different background color than the save state).
- Fix "Restart Level" that would glitch Lost Levels in some scenarios.
- Fix bug where only parts of the font-set was copied if using a custom one.
- Lots of other smaller things...

## Persistancy

To keep settings, frame rules and stuff persistent; configure your game
system (emulator, PowerPAK, EverDrive etc.) to allow the SMB Practice ROM
battery-backed WRAM. Essentially, figure out how to make it so that you can
save in Zelda (without savestates), power off the system, and load (without using save states). Then do the same for the SMB Practice ROM.

**I'll describe more indepth about new features tomorrow. Right now I just want
it released.**

## Feature list
- Practice both **SMB** and **SMB Lost Levels**
- **Start** the game from **any frame rule**
- **Start** on **any level**.
- Keeps **track of prefered start rule** for each level.
- **Battery backed WRAM** for persistent memory.
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
- And a lot more...

## Download

- [Version 5.0 - IPS](https://github.com/pellsson/smb/raw/master/smb-v5.0.ips)

