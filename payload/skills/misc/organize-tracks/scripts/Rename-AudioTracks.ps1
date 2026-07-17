<# 
.SYNOPSIS
    Batch rename multitrack audio files to Category_Sub_Description_#.ext format.
.DESCRIPTION
    Template script for renaming DAW-exported multitrack files.
    Edit the $path and $map variables before running.
.EXAMPLE
    .\Rename-AudioTracks.ps1
#>

# === CONFIG ===
$path = "FILL_IN_YOUR_PATH_HERE"

# === RENAME MAP (old → new) ===
$map = @{
    # --- Drum ---
    # "KICK knock .wav"       = "Drum_Kick_Knock.wav"
    # "SNARE TRAP .wav"       = "Drum_Snare_Trap.wav"
    # "CLAP .wav"             = "Drum_Clap_Main.wav"
    
    # --- Bass ---
    # "BASS Jazz Bass .wav"   = "Bass_Jazz_Main.wav"
    
    # --- Guitar ---
    # "GTR NILE 1 .wav"       = "Gtr_Nile_1.wav"
    
    # --- Keys / Synth ---
    # "PIANO .wav"            = "Key_Piano_Main.wav"
    # "STABS jupiter .wav"    = "Synth_Stabs_Jupiter.wav"
    
    # --- Vox ---
    # "LEAD VOCAL .wav"       = "Vox_Lead_Main.wav"
    # "HOOK DUA HI 1.wav"     = "Vox_Hook_Dua_Hi_1.wav"
    # "TALKBOX 1.wav"         = "Vox_Talkbox_1.wav"
    # "GANGS HIGH .wav"       = "Vox_Gang_High.wav"
    
    # --- Fx / Ref ---
    # "SWELLS 1 .wav"         = "Fx_Swells_1.wav"
    # "reference mix.wav"     = "Ref_Main.wav"
}

# === EXECUTE ===
$ok = 0
$err = @()

foreach ($oldName in $map.Keys) {
    $oldPath = Join-Path -Path $path -ChildPath $oldName
    $newName = $map[$oldName]
    if (Test-Path -LiteralPath $oldPath) {
        Rename-Item -LiteralPath $oldPath -NewName $newName
        Write-Host "✔  $oldName → $newName" -ForegroundColor Green
        $ok++
    } else {
        $err += $oldName
        Write-Host "✖  NOT FOUND: $oldName" -ForegroundColor Red
    }
}

Write-Host "`n===== DONE =====" -ForegroundColor Cyan
Write-Host "Renamed: $ok files"
if ($err.Count -gt 0) {
    Write-Host "Not found: $($err.Count) files" -ForegroundColor Yellow
    foreach ($e in $err) { Write-Host "  - $e" }
}

# === VERIFY ===
Write-Host "`nFiles by category:" -ForegroundColor Cyan
Get-ChildItem -LiteralPath $path -Filter *.wav | Group-Object { $_.Name.Split('_')[0] } | Sort-Object Name | Format-Table -AutoSize
