# DocBrown/Wizard Sorter
SD card sorter for the FM Towns/Marty ODEs [DocBrown](https://gdemu.wordpress.com/details/docbrown-details/) and [Wizard](https://gdemu.wordpress.com/details/wizard-details/).

This utility will perform all file/folder operations to automatically alphanumerically sort the game list on a target SD card for use with the [Almanac](https://gdemu.wordpress.com/operation/docbrown-operation/) and [Spellbook](https://gdemu.wordpress.com/operation/wizard-operation/) menu systems.

![#f03c15](https://i.imgur.com/XsUAGA0.png) **IMPORTANT:** *Please do not run this program against your daily-use SD card. Instead, use a copy or backup until you're sure it works with your disc image collection.*

## Current Version
DocBrown/Wizard Sorter is currently at version [1.2](https://github.com/DerekPascarella/DocBrown-Wizard-Sorter/raw/main/towns_sorter.exe).

## Changelog
* Version 1.2 (2025-02-19)
  * Cleaned up status message output to be more compact and descriptive.
  * Invalid user response to Almanac/Spellbook rebuild prompt now properly handled.
* Version 1.1 (2023-05-03)
  * To force Almanac/Spellbook to properly index a game list exceeding 100 even when using FindFirstFile(), a "FAT sort" is now performed on target SD card (e.g., `20 200 21` now becomes `20 21 ... 200`).
* Version 1.0 (2023-03-24)
  * Initial release.

## Supported Features
DocBrown/Wizard Sorter aims to solve not only the problem of clean alphanumeric sorting of one's game list, but also the otherwise manual process of adding new games. Generally, this utility can be used in one of two ways.

1. New disc images can be added to the target SD card by placing them inside a numbered folder, along with a `Title.txt` file containing the desired display name.  The number used to name said folder doesn't matter, as this utility will automatically rename and sort it accordingly.
2. A simpler option afforded by this utility is to create a new folder in the root of the target SD card with the desired display name.  The disc image itself can be placed inside said folder, and DocBrown/Wizard Sorter will automatically generate a `Title.txt` file to reflect its folder name, and afterwards rename and sort it accordingly.

Below is a specific list of the current features.

* Optionally executes menu system's `RunMe.bat` script, which must be present in the expected location (folder `01`).
* Automatically sorts game folders based on `Title.txt` inside of them, or the folder name itself if no text file is present.
* Automatically generates `Title.txt` file for new folders added since last run.
* Game names can be changed by modifying `Title.txt` inside of their respective folders and then processing SD card with DocBrown/Wizard Sorter.
* Ignores folders without a valid disc image.
  * Note that adding a `Title.txt` file to a folder will force this utility to treat it as a valid game folder. This is useful for adding a menu entry to force booting from FDD, as both DocBrown and Wizard will do so if user launches a menu entry containing no disc image.
  * Invalid folders will be renamed to `INVALID_X`, where `X` is iterated over sequentially for each found.

## Usage
Two options exist for launching this utility.

1. In Windows File Explorer, drag target SD card onto `towns_sorter.exe`.
2. From a terminal (e.g., PowerShell, CMD), execute `towns_sorter.exe` with the path to the target SD card as the first input parameter (e.g., `towns_sorter.exe H:\`).  Linux users can execute the Perl script directly (e.g., `perl towns_sorter.pl /mnt/sd` or `./towns_sorter.pl /mnt/sd` if script is made executable). However, execution of `RunMe.bat` is limited to Windows hosts.

Example output:

```
DocBrown/Wizard Sorter v1.2
Written by Derek Pascarella (ateam)

Processing SD card (F:)...

8 disc image(s) found and pre-processed on SD card.

These disc images have been moved to a temporary folder on the SD card for
purposes of FAT sorting.

In five seconds, disc images will be auomatically organized using numbered
folders in alphanumeric order.

  -> Folder 02 (unchanged: ADVANTAGE TENNIS)
  -> Folder 03 (unchanged: AFTER BURNER)
  -> Folder 04 (unchanged: AFTER BURNER 2)
  -> Folder 05 (unchanged: AFTER BURNER 3)
  -> Folder 06 (unchanged: ALLTYNEX (T-EN))
  -> Folder 07 (new: ARQUELPHOS)
  -> Folder 08 (previously 07: ASUKA 120% BURNING FEST)
  -> Folder 09 (previously 08: ASUKA 120% BURNING FEST - UNLIMITED)

8 disc images(s) fully processed!

Run Almanac/Spellbook batch script? (Y/N) y

==========RunMe.bat==========
Scanning folders...
Titles found: 75
Total translation table size: 0
Total rockridge attributes bytes: 0
Total directory bytes: 2564
Path table size(bytes): 24
782 extents written (1 MB)
IO.SYS LBA: 25
=============================

SD card processing complete!

An index of disc images can be found in the following location:
F:\01\data\TITLES.TXT

Press Enter to exit.
```
