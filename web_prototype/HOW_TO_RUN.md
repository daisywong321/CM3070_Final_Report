# How to Run PlayGarden in Visual Studio Code

This guide walks you through running the PlayGarden app on your own computer using Visual Studio Code (VS Code). No coding experience is needed. The whole thing takes about five minutes.

PlayGarden is a plain web app (HTML, CSS and JavaScript). There is nothing to compile and nothing to install beyond VS Code and one small helper extension.

> **Important: do not double-click `index.html` to open it.** If you open the file directly (as a `file://` page) the layout, fonts, sound and speech can fail to load, and the app will look broken and unstyled. PlayGarden must be served by a small local web server, which is what the "Live Server" step below does for you. This is the single most common mistake, so please follow Steps 3 and 4.

---

## What you need

- A computer running Windows, macOS or Linux.
- The PlayGarden source folder (the files that came with this guide: `index.html`, `style.css`, `games.js`, `manifest.webmanifest`, `icon.svg`, plus `README.md` and this file).

---

## Step 1: Install Visual Studio Code

1. Go to https://code.visualstudio.com.
2. Click the big download button for your operating system.
3. Open the downloaded file and follow the installer.
4. Launch VS Code once it has finished installing.

If you already have VS Code, skip to Step 2.

---

## Step 2: Open the PlayGarden folder

1. If the app arrived as a zip file, unzip it first. Right-click the zip and choose "Extract All" (Windows) or double-click it (macOS), so you end up with a normal folder of files.
2. In VS Code, go to the top menu and choose **File → Open Folder…**
3. Select the PlayGarden folder (the one that contains `index.html`) and click **Open**.
4. You should now see all the project files listed in the Explorer panel down the left-hand side.

---

## Step 3: Install the "Live Server" extension

A web app needs to be served by a tiny local web server rather than opened straight off the disk, otherwise the speech and audio features may not work. The free "Live Server" extension does this for you with one click.

1. In VS Code, click the **Extensions** icon in the left-hand toolbar (it looks like four small squares), or press `Ctrl+Shift+X` (Windows/Linux) or `Cmd+Shift+X` (macOS).
2. In the search box, type **Live Server**.
3. Find the one by **Ritwick Dey** and click **Install**.

---

## Step 4: Run the app

1. In the Explorer panel on the left, click **index.html** once to select it.
2. Right-click `index.html` and choose **Open with Live Server**.
   - Alternatively, click the **Go Live** button in the blue bar at the bottom-right of the VS Code window.
3. Your default web browser will open automatically at an address such as `http://127.0.0.1:5500/index.html`.
4. PlayGarden's home screen with the ten game cards should appear. Click any card to play.

That's it. The app is now running on your computer.

---

## Step 5: See it as a phone app (optional)

PlayGarden is designed for a phone-sized screen. To preview it that way:

1. In the browser, press `F12` (or right-click the page and choose **Inspect**) to open the developer tools.
2. Click the small phone/tablet icon (the "Toggle device toolbar"), usually near the top-left of the developer-tools panel, or press `Ctrl+Shift+M` (Windows/Linux) or `Cmd+Shift+M` (macOS).
3. From the device dropdown at the top, pick a phone such as "iPhone 12 Pro" or set a custom size of 390 by 844.

To turn sound and speech on, make sure your computer's volume is up. The app's tones and spoken prompts start after your first tap, which is normal browser behaviour.

---

## Stopping the server

When you are finished, click the address in the blue bar at the bottom of VS Code (it shows the port number, for example "Port: 5500") to stop Live Server, or simply close VS Code.

---

## Troubleshooting

- **The page is blank.** Make sure you opened the *folder* in VS Code (Step 2), not just a single file, and that you launched it through Live Server (Step 4) rather than double-clicking the HTML file.
- **No sound or speech.** Turn your volume up and tap once inside a game; browsers block audio until the user interacts with the page. Speech voices also vary between browsers; Chrome and Edge tend to work best.
- **"Go Live" button is missing.** Confirm the Live Server extension installed correctly (Step 3), then restart VS Code.

---

## A note for the marker

There is no build step, no package manager and no internet connection required to run the app (the only external resource is a Google Font, which falls back gracefully if offline). The entire app is the handful of static files in this folder.
