# DocBrown/Wizard Sorter
SD card sorter for the FM Towns/Marty ODEs [DocBrown](https://gdemu.wordpress.com/details/docbrown-details/) and [Wizard](https://gdemu.wordpress.com/details/wizard-details/).

This utility will perform all file/folder operations to automatically alphanumerically sort the game list on a target SD card for use with the [Almanac](https://gdemu.wordpress.com/operation/docbrown-operation/) and [Spellbook](https://gdemu.wordpress.com/operation/wizard-operation/) menu systems.

![#f03c15](https://i.imgur.com/XsUAGA0.png) **IMPORTANT:** *Please do not run this program against your daily-use SD card. Instead, use a copy or backup until you're sure it works with your disc image collection.*

## Current Version
DocBrown/Wizard Sorter is currently at version [1.4](https://github.com/DerekPascarella/DocBrown-Wizard-Sorter/raw/main/towns_sorter.exe).

## Changelog
* **Version 1.4 (2025-09-08)**
  * Game labels can now be modified in `GameList.txt` before processing SD card instead of solely by modifying `Title.txt` metadata text files inside of numbered folders (read more [here](#method-2)).
  * If files/folders are locked by another process when DocBrown/Wizard Sorter attempts to move/rename them, a prompt will now be displayed giving the user the opportunity to close said processes before proceeding, instead of those locked files/folders being skipped.
* **Version 1.3 (2025-05-06)**
  * Improved clarity of status message output when new disc images are added and processed.
* **Version 1.2 (2025-02-19)**
  * Cleaned up status message output to be more compact and descriptive.
  * Enhanced sanity-check for Almanac/Spellbook rebuild.
  * Invalid user response to Almanac/Spellbook rebuild prompt now properly handled.
* **Version 1.1 (2023-05-03)**
  * To force Almanac/Spellbook to properly index a game list exceeding 100 even when using FindFirstFile(), a "FAT sort" is now performed on target SD card (e.g., `20 200 21` now becomes `20 21 ... 200`).
* **Version 1.0 (2023-03-24)**
  * Initial release.

## Adding Disc Images
1. Create a folder on the root of the SD card, giving it whatever name should appear in the Almanac/Spellbook game list.
   - Should a label be desired that contains characters that are restricted in file/folder names (i.e., `<`, `>`, `:`, `"`, `/`, `\`, `|`, `?`, and `*`), create a file named `Title.txt` inside of the game disc folder containing said label. In this case, the name of the folder itself is ignored and not important.
3. Copy the disc image (in a [supported format](https://gdemu.wordpress.com/details/docbrown-details/)) to the newly created game folder.
4. Drag the SD card onto `towns_sorter.exe` and watch the status messages until processing is complete.
   - DocBrown/Wizard Sorter will alphanumerically sort all numbered folders based on game name, performing a proper FAT sort so that a game list exceeding 100 will be ordered properly (e.g., `20 200 21` now becomes `20 21 ... 200`).

## Removing Disc Images
1. On the SD card, open `GameList.txt` in the root of the SD card and then identify the numbered folder containing the disc image to be removed.
2. Remove the identified numbered folder from the SD card.
3. Drag the SD card onto `towns_sorter.exe` and watch the status messages until processing is complete.

## Changing Disc Image Names as They Appear in the Menu
There are two methods by which users can modify the menu display labels for disc images. The first method is more cumbersome, especially for bulk changes. The second method is convenient and allows quick changes, especially in bulk.
#### Method 1
1. In the root of the SD card, open `GameList.txt` and then identify the numbered folder containing the disc image label to be renamed.
2. Open the identified numbered folder, then open and make changes to the `Title.txt` text file.
3. Drag the SD card onto `towns_sorter.exe` and watch the status messages until processing is complete.
#### Method 2
This method requires that an SD card is processed at least once (even without changes) by version 1.4 or newer.

1. Open `GameList.txt` in the root of the SD card and identify each disc image with a display label that is to be modified.
2. Edit `GameList.txt` directly to make desired changes to menu display labels.
3. Drag the SD card onto `towns_sorter.exe` and watch the status messages until processing is complete.

Note that there is minimal error handling for user mistakes when manually editing `GameList.txt`. One must be careful when making changes to avoid breaking the expected formatting.

As an example, `GameList.txt` may contain the following.

```
01 - MENU
02 - ---Boot From Floppy---
03 - Advantage Tennis
04 - AFTER BURNER II
```

However, the user wishes to use title casing for "After Burner II", so they make the following modification.

```
01 - MENU
02 - ---Boot From Floppy---
03 - Advantage Tennis
04 - After Burner II
```

## Supported Features
Below is a specific list of the current features.

* Optionally executes menu system's `RunMe.bat` script, which must be present in the expected location (folder `01`).
* Automatically sorts game folders based on `Title.txt` inside of them, or the folder name itself if no text file is present.
* Automatically generates `Title.txt` file for new folders added since last run.
* Ignores folders without a valid disc image.
  * Note that adding a `Title.txt` file to a folder will force this utility to treat it as a valid game folder. This is useful for adding a menu entry to force booting from FDD, as both DocBrown and Wizard will do so if user launches a menu entry containing no disc image.
  * Invalid folders will be renamed to `INVALID_X`, where `X` is iterated over sequentially for each found.

## Usage
Two options exist for launching this utility.

1. In Windows File Explorer, drag target SD card onto `towns_sorter.exe`.
2. From a terminal (e.g., PowerShell, CMD), execute `towns_sorter.exe` with the path to the target SD card as the first input parameter (e.g., `towns_sorter.exe H:\`).  Linux users can execute the Perl script directly (e.g., `perl towns_sorter.pl /mnt/sd` or `./towns_sorter.pl /mnt/sd` if script is made executable). However, execution of `RunMe.bat` is limited to Windows hosts.

Example output:

```
DocBrown/Wizard Sorter v1.4
Written by Derek Pascarella (ateam)

WARNING: Before proceeding, ensure that no files or folders on SD card (F:\)
         are open in File Explorer or any other program. Failure to do so
         will result in data corruption!

Press Enter to continue...

Processing SD card (F:\)...

6 disc image(s) found and pre-processed on SD card.

These disc images have been moved to a temporary folder on the SD card for
purposes of FAT sorting.

In five seconds, disc images will be auomatically organized using numbered
folders in alphanumeric order.

  -> Folder 02 (new: After Burner)
  -> Folder 03 (previously 02: Asuka 120% Burning Fest - Excellent [REQ. DISK])
  -> Folder 04 (previously 03: EMIT Vol. 1 - Lost in Time (T-En) [REQ. DISK])
  -> Folder 05 (previously 04: Indiana Jones and the Last Crusade)
  -> Folder 06 (previously 05: Muscle Bomber - The Body Explosion)
  -> Folder 07 (previously 06: Scavenger 4)

6 disc images(s) fully processed!

Run Almanac/Spellbook batch script? (Y/N) y

==========RunMe.bat==========
Scanning folders...
Titles found: 6
Compiling list
Done
Total translation table size: 0
Total rockridge attributes bytes: 0
Total directory bytes: 560
Path table size(bytes): 10
611 extents written (1 MB)
IO.SYS LBA: 24
=============================

SD card processing complete!

An index of disc images can be found in the following location:
F:\GameList.txt

Press Enter to exit.
```
