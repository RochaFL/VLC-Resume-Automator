# VLC-Resume-Automator


**VLC Resume Automator** is a lightweight VBScript utility designed to bridge the gap between VLC's "Recent Media" feature and a true "Continue Watching" experience. 

##  The Problem
When watching a series or anime in VLC, users often face a repetitive workflow:
1.  VLC’s "Open Recent" only loads the **single** last-played file, meaning it won't auto-play the next episode once the current one finishes.
2.  The alternative is manually navigating to the folder, dragging it into VLC, and searching for where you left off.
3.  Standard Batch scripts (`.bat`) solve the automation but force an intrusive Command Prompt window to remain open or flash on the screen.

##  The Solution
This script automates the retrieval of your last-watched file and generates a dynamic playlist (`.m3u`) starting exactly from that file and including every subsequent episode in the folder. By using **VBScript**, the entire process happens silently in the background with no terminal windows, providing a seamless "one-click" resume experience.

##  How It Works
The script follows a logical pipeline to ensure your media is ready to play:

1.  [cite_start]**History Discovery**: It locates and accesses the VLC configuration file (`vlc-qt-interface.ini`) stored in the user's `%APPDATA%` folder[cite: 1].
2.  [cite_start]**Metadata Extraction**: It parses the configuration to find the `list=` entry, which identifies the most recently played file[cite: 2].
3.  [cite_start]**Path Decoding**: Since VLC stores paths in URL format (e.g., `%20` for spaces), the script performs a manual "cleaning" and decoding to convert the URL into a standard Windows file path[cite: 3].
4.  [cite_start]**Directory Indexing**: It scans the parent folder of the last-played file, filtering only for common video extensions (`.mp4`, `.mkv`, `.avi`, etc.)[cite: 4, 5].
5.  [cite_start]**Smart Sorting**: To ensure the playlist follows the correct order, the script implements a sorting algorithm to organize the files alphabetically/numerically[cite: 6].
6.  [cite_start]**Playlist Generation**: A temporary `.m3u` playlist is created, starting from the last-watched file[cite: 7]. 
7.  [cite_start]**Execution**: Finally, it launches VLC and passes the generated playlist as an argument, allowing you to pick up exactly where you left off[cite: 8].

##  Configuration
The script is pre-configured for standard VLC installations. [cite_start]If your VLC is installed in a non-standard directory, update the `caminhoVLC` variable at the top of the script[cite: 1]:

```vbs
' --- CONFIGURAÇÃO ---
caminhoVLC = "C:\Program Files\VideoLAN\VLC\vlc.exe"
' --------------------
```

## Why VBScript?
Unlike `.bat` or `.ps1` files which typically trigger a console window, **VBScript** runs via the `WScript` engine. This allows the script to perform its logic and launch VLC without any visual "noise" or lingering CMD windows, keeping your desktop clean and your focus on your media.

---

### How to Use
1. Download `salvaep2.0.vbs`.
2. (Optional) Create a shortcut on your desktop or Taskbar.
3. Simply run the script to immediately resume your series from the last point played.

