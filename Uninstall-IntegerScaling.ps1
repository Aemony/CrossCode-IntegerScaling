# Functions
function Stop-Script {
	[cmdletbinding()]
	param([string]$Message = "")

	Write-Warning $Message
	Read-Host "Execution have terminated! Press Enter to close the window"
	exit
}

Write-Host "Preparing patches..."

# Patches to apply
$Patches = @(
	[PSCustomObject]@{
		File = '.\assets\js\game.compiled.js'
		Changes = @(
			[PSCustomObject]@{
				Original = '{ORIGINAL:0,SCALE_X2:1,FIT:2,STRETCH:3};'
				Patched = '{ORIGINAL:0,SCALE_X2:1,FIT:2,STRETCH:3,INTEGER:4};'
			}
			[PSCustomObject]@{
				Original = 'sc.PIXEL_SIZE={ONE:0,TWO:1,THREE:2,FOUR:3};'
				Patched = 'sc.PIXEL_SIZE={ONE:0,TWO:1,THREE:2,FOUR:3,FIVE:4,SIX:5};'
			}
			[PSCustomObject]@{
				Original = 'else if(a=="pixel-size"){window.IG_GAME_SCALE=(this.values[a]||0)+1;localStorage.setItem("options.scale",window.IG_GAME_SCALE)}'
				Patched = 'else if(a=="pixel-size"){window.IG_GAME_SCALE=(this.values[a]||0)+1;localStorage.setItem("options.scale",window.IG_GAME_SCALE);this._setDisplaySize();}'
			}
			[PSCustomObject]@{
				Original = 'case sc.DISPLAY_TYPE.STRETCH:k=true;a=b;b=i;j=true;break;default:a=c;b=d'
				Patched = 'case sc.DISPLAY_TYPE.STRETCH:k=true;a=b;b=i;j=true;break;case sc.DISPLAY_TYPE.INTEGER:j=true;if(b>c*window.IG_GAME_SCALE&&i>d*window.IG_GAME_SCALE){a=c*window.IG_GAME_SCALE;b=d*window.IG_GAME_SCALE}else if(Math.floor(b/c)==0||Math.floor(i/d)==0){a=c;b=d}else{if(b/c<i/d){a=c*Math.floor(b/c);b=d*Math.floor(b/c)}else{a=c*Math.floor(i/d);b=d*Math.floor(i/d)}}break;default:a=c;b=d'
			}
		)
		Content = $null
	}
	[PSCustomObject]@{
		File = '.\assets\data\lang\sc\gui.en_US.json'
		Changes = @(
			[PSCustomObject]@{
				Original = '"display-type":{"name":"Display Type","group":["Original","Double","Fit","Stretch"]'
				Patched = '"display-type":{"name":"Display Type","group":["Original","Double","Fit","Stretch","Integer"]'
			},
			[PSCustomObject]@{
				Original = '"pixel-size":{"name":"Pixel Size","group":["1","2","3","4"]'
				Patched = '"pixel-size":{"name":"Pixel Size","group":["1","2","3","4","5","6"]'
			}
		)
		Content = $null
	}
)

Write-Host "Verifying files..."

# Pre-patch checks...
ForEach ($Patch in $Patches)
{
	If((Test-Path -Path $Patch.File) -eq $false)
	{
		Stop-Script "One or more of the required files were not. Verify that the script is being run in the game folder."
	} else {
		Write-Host "Reading file contents..."
		$Patch.Content = Get-Content -Path $Patch.File -Raw

		if($Patch.Content)
		{
			ForEach ($Change in $Patch.Changes)
			{
				$MatchesFound = ($Patch.Content -split $Change.Patched, 0, "simplematch" | Measure-Object | Select-Object -Exp Count) - 1
				if($MatchesFound -ne 1)
				{
					Stop-Script "Expected 1 match but found $MatchesFound, in file '$($Patch.File)', for line:
					$($Change.Patched)"
				}
			}
		} else {
			Stop-Script "The file was empty."
		}
	}
}

# Everything looks fine, let's patch the files!
ForEach ($Patch in $Patches)
{
	Write-Host "Applying patches to " $Patch.File "..."

	ForEach ($Change in $Patch.Changes)
	{
		$Patch.Content = $Patch.Content -replace [regex]::escape($Change.Patched), $Change.Original
	}

	$Patch.Content | Set-Content -Path $Patch.File
}

Write-Host "Patching is complete. Press Enter to exit the script."
Read-Host
