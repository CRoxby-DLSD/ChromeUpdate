<#
	Automatically update any recovery bin for families listed in the input file.

	This awesome script was created by Chris Roxby for Deer Lakes School District.
	v1.0 - 4/17/2020
	GPLv3
#>

$INFILE = ".\models.txt"
<#
	This file stores the model families that you use.
	* Do NOT use the model name. E.g. Google Pixelbook
	* DO use the Firmware name. E.g. EVE
#>

# Read the input file.
$content=Get-Content $INFILE

# Create an emty array to store the models.
$list = @()

# Store only the first word
foreach($word in $content) {
	$word1 = ($word -split ' ')[0]
	if ($word1-ne '') {
		$list += $word1
	}
}

# Get Google's Recovery information.
wget https://dl.google.com/dl/edgedl/chromeos/recovery/recovery.conf -OutFile recovery.conf

# Find applicable links.
$links = foreach($line in $list) {
	if ($line) {
		(Select-String .\recovery.conf -Pattern $line | Select-String -Pattern "url" | Select-Object -First 1|Out-String) -split "=" | Select-Object -Last 1
	}
	else {
		$false
	}
}

# Get the current files so that we only download what we need.
$curFiles = Get-ChildItem -Include *.bin -Name

# Find files that match the input file.
$files = foreach($item in $list) {
	if ($item) {
		$curFiles|Select-String -Pattern $item
	}
}

# Create Empty Array to store the version comparison result.
$newer = @()

<#
	Get the version numbers only, sort of.
	String equality will be used
	to decide if the local file is old.
#>
for ($i = 0; $i-lt $list.length; $i++) {

	# The local version end up null when there isn't a file.
	$lv = ($files[$i] -split '_')[1]

	$ov = ($links[$i] -split '_')[1]
	# Do the local files have the same version as the online ones?
	$newer += ($ov-ne $lv)
}

# Downloading the ZIP files will take a while.
for ($j = 0; $j-lt $list.length; $j++) {
	# Is the online file newer?
	if ($newer[$j]) {
		# Make sure that the link is there.
		if ($links[$j]) {
			# Remove the line-breaks from the link.
			$links[$j] = $($links[$j] -replace "`r`n")

			# Download the file.
			wget $links[$j] -OutFile ($links[$j] -split '/' | Select-Object -Last 1)

			# With the ZIP file downloaded, the the old BIN file can go away
			Remove-Item –path $files[$j]
		}
	}
}

# List all ZIP files.
$zipFiles = Get-ChildItem -Include *.zip -Name

# Extraction will take time.
foreach($zip in $zipFiles) {
	Expand-Archive $zip -DestinationPath $(Get-Location)
	# now the ZIP file can go away.
	Remove-Item –path $zip
}

# Don't store recovery.conf.
Remove-Item –path .\recovery.conf
