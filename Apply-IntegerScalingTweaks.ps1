# PATHS
$PathGameCompiledJS = '.\assets\js\game.compiled.js'
$PathGUIenUS = '.\assets\data\lang\sc\gui.en_US.json'

if((Test-Path -Path $PathGameCompiledJS) -eq $false -or (Test-Path -Path $PathGUIenUS) -eq $false)
{
	Write-Host "Could not find files. Be sure to run this script from the game install folder."
	Read-Host
	return;
}


# PATCHES - PathGameCompiledJS

# sc.DISPLAY_TYPE - Add integer display type as an option.
$OptionDisplayTypeSource 			= '{ORIGINAL:0,SCALE_X2:1,FIT:2,STRETCH:3};'
$OptionDisplayTypeReplacement 		= '{ORIGINAL:0,SCALE_X2:1,FIT:2,STRETCH:3,INTEGER:4};'

# sc.PIXEL_SIZE - Add 5 and 6 as acceptable multipliers
$OptionPixelSizeSource 				= 'sc.PIXEL_SIZE={ONE:0,TWO:1,THREE:2,FOUR:3};'
$OptionPixelSizeReplacement 		= 'sc.PIXEL_SIZE={ONE:0,TWO:1,THREE:2,FOUR:3,FIVE:4,SIX:5};'

# _checkSystemSettings -  Add a call to _setDisplaySize() (bandaid to properly apply the integer ratio scaling on launch).
$_checkSystemSettingsSource 		= 'else if(b=="pixel-size"){window.IG_GAME_SCALE=(this.values[b]||0)+1;localStorage.setItem("options.scale",window.IG_GAME_SCALE)}'
$_checkSystemSettingsReplacement 	= 'else if(b=="pixel-size"){window.IG_GAME_SCALE=(this.values[b]||0)+1;localStorage.setItem("options.scale",window.IG_GAME_SCALE);this._setDisplaySize();}'

# _setDisplaySize - Adds new case for handling integer base scaling.
$_setDisplaySizeSource 				= 'case sc.DISPLAY_TYPE.STRETCH:o=true;a=b;b=e;f=true;break;default:a=c;b=d'
$_setDisplaySizeReplacement 		= 'case sc.DISPLAY_TYPE.STRETCH:o=true;a=b;b=e;f=true;break;case sc.DISPLAY_TYPE.INTEGER:if(b>c*window.IG_GAME_SCALE&&e>d*window.IG_GAME_SCALE){a=c*window.IG_GAME_SCALE;b=d*window.IG_GAME_SCALE}else if(Math.floor(b/c)==0||Math.floor(e/d)==0){a=c;b=d}else{if(b/c<e/d){a=c*Math.floor(b/c);b=d*Math.floor(b/c)}else{a=c*Math.floor(e/d);b=d*Math.floor(e/d)}}break;default:a=c;b=d'



# PATCHES - PathGUIenUS

# "display-type" - Add "integer" to the localization of the display type setting
$DisplayTypeSource					= '"display-type":{"name":"Display Type","group":["Original","Double","Fit","Stretch"]'
$DisplayTypeReplacement				= '"display-type":{"name":"Display Type","group":["Original","Double","Fit","Stretch","Integer"]'

# "pixel-size" - Add 5 and 6 to the localization of the pixel size setting
$PixelSizeSource 					= '"pixel-size":{"name":"Pixel Size","group":["1","2","3","4"]'
$PixelSizeReplacement 				= '"pixel-size":{"name":"Pixel Size","group":["1","2","3","4","5","6"]'



# OPERATION
Write-Host "Patching '$PathGameCompiledJS'..."
$FileGameCompiledJS = Get-Content -Path $PathGameCompiledJS -Raw
$FileGameCompiledJS = $FileGameCompiledJS -replace [regex]::escape($OptionDisplayTypeSource), $OptionDisplayTypeReplacement
$FileGameCompiledJS = $FileGameCompiledJS -replace [regex]::escape($OptionPixelSizeSource), $OptionPixelSizeReplacement
$FileGameCompiledJS = $FileGameCompiledJS -replace [regex]::escape($_checkSystemSettingsSource), $_checkSystemSettingsReplacement
$FileGameCompiledJS = $FileGameCompiledJS -replace [regex]::escape($_setDisplaySizeSource), $_setDisplaySizeReplacement
$FileGameCompiledJS | Set-Content -Path $PathGameCompiledJS

Write-Host "Patching '$PathGUIenUS'..."
$FileGUIenUS = Get-Content -Path $PathGUIenUS -Raw
$FileGUIenUS = $FileGUIenUS -replace [regex]::escape($DisplayTypeSource), $DisplayTypeReplacement
$FileGUIenUS = $FileGUIenUS -replace [regex]::escape($PixelSizeSource), $PixelSizeReplacement
$FileGUIenUS | Set-Content -Path $PathGUIenUS

Write-Host "Patching finished. Press Enter to exit the script."
Read-Host
