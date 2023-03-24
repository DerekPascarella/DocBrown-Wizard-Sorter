# DocBrown/Wizard Sorter
SD card sorter for the FM Towns/Marty ODEs [DocBrown](https://gdemu.wordpress.com/details/docbrown-details/) and [Wizard](https://gdemu.wordpress.com/details/wizard-details/).

This utility will perform all file/folder operations to automatically alphanumerically sort the game list on a target SD card for use with the [Almanac](https://gdemu.wordpress.com/operation/docbrown-operation/) and [Spellbook](https://gdemu.wordpress.com/operation/wizard-operation/) menu systems.

![#f03c15](https://via.placeholder.com/15/f03c15/f03c15.png) **IMPORTANT:** *Please do not run this program against your daily-use SD card. Instead, use a copy or backup until you're sure it works with your disc image collection.*

## Current Version
DocBrown/Wizard Sorter is currently at version [1.0](https://github.com/DerekPascarella/DocBrown-Wizard-Sorter/raw/main/towns_sorter.exe).

## Supported Features
Below is a specific list of the current features.

* Optionally executes menu system's `RunMe.bat` script.
* Automatically sorts game folders based on `Title.txt` inside of them, or the folder name itself of no text file is present.
* Automatically generates `Title.txt` file for new folders added since last run.
* Ignores folders without a valid disc image.
  * Note that adding a `Title.txt` file to a folder will force this utility to treat it as a valid game folder. This is useful for adding a menu entry to force booting from FDD, as both DocBrown and Wizard will do so if user launches a menu entry containing no disc image.
* more here

## Usage
