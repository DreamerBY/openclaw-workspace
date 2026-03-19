$sshKeygen = @"
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\id_ed25519" -C "DreamerBY OpenClaw"
""@

# Create batch file
$batchPath = "$env:TEMP\genssh.bat"
$batch = "@echo off`necho. | ssh-keygen -t ed25519 -f `"$env:USERPROFILE\.ssh\id_ed25519`" -C `"DreamerBY OpenClaw`""
[System.IO.File]::WriteAllText($batchPath, $batch, [System.Text.Encoding]::OEM)

Write-Host "Running batch..."
$proc = Start-Process -FilePath $batchPath -NoNewWindow -Wait -PassThru
Write-Host "Exit: $($proc.ExitCode)"

if (Test-Path "$env:USERPROFILE\.ssh\id_ed25519") {
    Write-Host "KEY CREATED!"
    Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub"
} else {
    Write-Host "Key NOT created"
}
