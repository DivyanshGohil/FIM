Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new Baseline?"
Write-Host "B) Begin monitoring files with saved Baseline?"

$response = Read-Host -Prompt "Please enter 'A' or 'B'"


# file hash calculating function
Function calculate-file-hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
 }

Function erase-baseline-if-already-exists() {
    $baselineExists = Test-Path -Path .\baseline.txt

    if ($baselineExists){
        # Delete it
        Remove-Item -Path "D:\19IT042\Cybersecurity Projects\FIM\baseline.txt"
    }
}

Write-Host ""
if ($response -eq "A".ToUpper()) {

    # Delete baseline if it already exists
    erase-baseline-if-already-exists
    
    # Calculate Hash from the target files and store in baseline.txt
    
    # Collect all files in the target folder
    $files = Get-ChildItem -Path "D:\19IT042\Cybersecurity Projects\FIM\files"
    
    # For each file, calculate the hash, and write to baseline.txt
    foreach ( $f in $files){
        $hash = calculate-file-hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath "D:\19IT042\Cybersecurity Projects\FIM\baseline.txt" -Append
    }
}
elseif ($response -eq "B".ToUpper()){
    # Begin monitoring files with saved baseline

    $fileHashdictionary = @{}
    # Load file|hash from baseline.txt and store them in a dictionary
    $filePathesAndHashes = Get-Content -Path "D:\19IT042\Cybersecurity Projects\FIM\baseline.txt"
    
    foreach ($f in $filePathesAndHashes) {
        $fileHashdictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }

    # Begin (continuously) monitoring files with saved Baseline
    while ($true) {
        Start-Sleep -Seconds 1
        Write-Host "Checking if files match...." -ForegroundColor Yellow
        
        $files = Get-ChildItem -Path "D:\19IT042\Cybersecurity Projects\FIM\files"

        # For each file, calculate the hash, and verify it
        foreach ($f in $files) {
            $hash = calculate-file-hash $f.FullName
            
            # Notify if a new file has been created
            if ($fileHashdictionary[$hash.Path] -eq $null) {
                # A new file has been created!
                Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
            }

            #Notify if a new file has been changed
            if ($fileHashdictionary[$hash.Path] -eq $hash.Hash){
                # The file has not changed

            }
            else {
                # File has been compromised! Notify the user
                Write-Host "$($hash.Path) has changed!!!" -ForegroundColor Yellow
            }
        }

        foreach ($key in $fileHashdictionary.Keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists){
                # One of the baselines files must have been deleted, notify the user
                Write-Host "$($key) has been deleted!" -ForegroundColor Red
            }        
        }
    }
  
}
else {
    Write-Host "Enter Valid Input" -ForegroundColor Red
}