---
name: Bug report
about: Report issues with HevLib
title: "[BUG]"
labels: ''
assignees: rwqfsfasxc100

---

**NOTE BEFORE REPORTING**
Bug reports on GitHub are rather slow. If you want the issue to be fixed as soon as, or want real-time data on the progress of reporting the bug, please join the [ΔV Discord server](https://discord.gg/dv), and head to the thread for HevLib, found [here](https://discord.com/channels/426287934870781952/1354537481197850655) 

**Describe the bug**
A clear and concise description of what the bug is.

**Link to save folder**
Many issues cannot be diagnosed with just a description of the issue and the environment, sometimes an issue can only be seen from the logs. The entire save folder is zipped as not all data on what happened is in one file, and I may need to launch the save to see anything that's wrong. 
It's the same method as used to report bugs for the vanilla game, and it works well. 

The steps to getting to the save folder are as follows:
1. Open the save directory.
 - Windows: `%APPDATA%/dV` OR `C://Users/<your windows user>/Appdata/Roaming/dV`
 - Linux/ChromeOS: `~/.local/share/dV/` OR `~/.var/app/com.valvesoftware.Steam/data/dV/`
 - MacOS: `~/Library/Application Support/dV`
2. Select all files (Control + A, or Command + A on MacOS)
3. Compress files (will be different for each OS, but most OSes have a zipping tool when right clicking on the selected files)
4. Upload the ZIP to the cloud (Google Drive, Onedrive, Dropbox, etc)
5. Link the folder within the report and make sure the link is visible to the public.

**Installed Mods**
Some mods may cause some code conflicts, please state every mod installed at the time of running in the following format:
 - ModZipName.zip (the mod's entire zip filename) - Mod Source Website (GitHub, GitLab, Nexus, etc.)

**To Reproduce**
Steps to reproduce the behavior. E.g:
1. Launch game
2. Open save
3. Select ship/equipment
4. Issue occurs

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Desktop (please complete the following information):**
 - OS: [e.g. Windows, Linux]
 - Game Version + Branch [e.g. 1.74.19 (Stable), 1.74.20 (Bleeding Edge)]
 - Command line flags - All command line/launch flags used when the game was launched

**Additional context**
Add any other context about the problem here.
