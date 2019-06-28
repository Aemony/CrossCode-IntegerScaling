# CrossCode-IntegerScaling
Patch to add integer-based scaling method to CrossCode through a new custom display type called **Integer**, along with two new pixels sizes (5x and 6x; 6x is the optimal for 4K gameplay).

Confirmed working with build ID 3830405 on Steam, manifest 3613959795902897611 of depot 368341 (dated May 16, 2019 – 18:02:18 UTC). May or may not work with copies on other platforms.


## Instructions

1. Download the **Apply-IntegerScalingTweaks.ps1** PowerShell script file and place it in the game folder.

2. Right click it and select **Run with Powershell**.

3. To remove the mod, revalidate game files through Steam to restore the original files.

4. The video settings menu can be made inaccessible after the mod have been removed if the save file still refer to the custom video options. Open the general settings menu and click the B key or **Reset all settings** to restore the original video settings to be able to access the video settings menu again.
