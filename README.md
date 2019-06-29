# CrossCode-IntegerScaling
Patch to add integer-based scaling method to CrossCode through a new custom display type called **Integer**, along with two new pixels sizes (5x and 6x; 6x is the optimal for 4K gameplay).

Why integer scaling? To prevent blur and/or shimmering that can otherwise result as a consequence as pixels are interpolated and doesn't fit evenly. See http://tanalin.com/en/articles/lossless-scaling/ for a better explanation. The idea came as a result of [this thread](https://steamcommunity.com/app/368340/discussions/0/1640915206443018918/) on the Steam Community forums, and previous requests made to add integer scaling to the game.

*Confirmed working with build ID 3830405 on Steam, manifest 3613959795902897611 of depot 368341 (dated May 16, 2019 – 18:02:18 UTC). May or may not work with copies on other platforms.*


## Instructions

1. Download the **Install-IntegerScaling.ps1** script file and place it in the game folder.

2. Right click it and select **Run with PowerShell**.

3. Launch the game and reconfigure it to use the new **Integer** display type as well as a fitting pixel size. It is recommended to restart the game to allow the change in pixel size to properly take effect.

4. To remove the mod, download and run the **Uninstall-IntegerScaling.ps1** script file from the game folder.

5. The video settings menu can be made inaccessible after the mod have been removed if the save file still refer to the custom video options. Open the general settings menu and click the B key or **Reset all settings** to restore the original video settings to be able to access the video settings menu again.


## Changes to the original code

The patch changes the following code sections:

**assets\data\lang\sc\gui.en_US.json** - Added localization to the new video settings options
```
        "display-type": {
        	"name": "Display Type",
        	"group": ["Original", "Double", "Fit", "Stretch", "Integer"],
        	"description": "Changes the Scaling used for the box the game runs in."
        },
```
```
        "pixel-size": {
        	"name": "Pixel Size",
        	"group": ["1", "2", "3", "4", "5", "6"],
        	"description": "Higher size means sharper image. May reduce FPS. \\c[1]Needs a restart!"
        },
```

**assets\js\game.compiled.js**
*  sc.DISPLAY_TYPE - Added integer display type as an option:
 ```
        sc.DISPLAY_TYPE = {
        	ORIGINAL: 0,
        	SCALE_X2: 1,
        	FIT: 2,
        	STRETCH: 3,
        	INTEGER: 4
        };
```

* sc.PIXEL_SIZE - Added 5 and 6 as pixel size options.
  * Note this whole approach is not future-proof, and preferably the number of pixel sizes available should be determined by dividing the monitorWidth / 568 and monitorHeight / 320 and then flooring lowest value of the two.
```
        sc.PIXEL_SIZE = {
        	ONE: 0,
        	TWO: 1,
        	THREE: 2,
        	FOUR: 3,
        	FIVE: 4,
        	SIX: 5
        };
```

* _checkSystemSettings - Added a call to _setDisplaySize() (needed to properly apply the integer ratio on launch and when changing pixel size).
```
        } else if (b == "pixel-size") {
        	window.IG_GAME_SCALE = (this.values[b] || 0) + 1;
        	localStorage.setItem("options.scale", window.IG_GAME_SCALE);
        	this._setDisplaySize();
        }
```

* _setDisplaySize - Added a new case for the switch statement for handling integer scaling:
```
case sc.DISPLAY_TYPE.INTEGER:
	if (b > c * window.IG_GAME_SCALE && e > d * window.IG_GAME_SCALE) {
		a = c * window.IG_GAME_SCALE;
		b = d * window.IG_GAME_SCALE;
	} else if (Math.floor(b / c) == 0 || Math.floor(e / d) == 0) {
		a = c;
		b = d;
	} else {
		if (b / c < e / d) {
			a = c * Math.floor(b / c);
			b = d * Math.floor(b / c);
		} else {
			a = c * Math.floor(e / d);
			b = d * Math.floor(e / d);
		}
	}
	break;
```
