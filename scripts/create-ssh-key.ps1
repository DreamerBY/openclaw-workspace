$sshPath = "$env:USERPROFILE\.ssh\id_ed25519"
if (-not (Test-Path $sshPath)) {
    $process = Start-Process -FilePath "ssh-keygen" -ArgumentList "-t","ed25519","-C","DreamerBY OpenClaw","-f",$sshPath -NoNewWindow -Wait -PassThru -RedirectStandardOutput "$env:TEMP\sshout.txt" -RedirectStandardError "$env:TEMP\ssherr.txt"
    Write-Host "Exit code: $($process.ExitCode)"
    Get-Content "$env:TEMP\sshout.txt" -EA SilentlyContinue
    Get-Content "$env:TEMP\ssherr.txt" -EA SilentlyContinue
} else {
    Write-Host "Key already exists"
}
