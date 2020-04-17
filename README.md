# ChromeUpdate
Automatically update a collection of ChromeOS recovery files with Powershell.

The models.txt file contains all the firmware families that you use. Just fill it with "codenames" from the recovery screen on your Chromebooks. The script will check to see if Google's file has the same name as yours. If not, it will download and extract the new bin file and delete the current one.
