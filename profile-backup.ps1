using namespace System.IO

# root-path → @{ Alias='foo'; Stamp='2025-06-29T10:55:12Z' }
$script:SfCache = @{}

function Get-SfAlias {
    param([string]$startDir)

    $dir = [DirectoryInfo]$startDir
    while ($dir) {
        $cfg = Join-Path $dir.FullName '.sf\config.json'

        if ([File]::Exists($cfg)) {
            $stamp = (Get-Item $cfg).LastWriteTimeUtc

            # cache hit and still fresh?
            if ($script:SfCache.ContainsKey($dir.FullName)) {
                $entry = $script:SfCache[$dir.FullName]
                if ($entry.Stamp -eq $stamp) {
                    return $entry.Alias
                }
            }

            # (re)read file and refresh cache
            $text  = [File]::ReadAllText($cfg)
            $alias = ([regex]::Match($text,
                     '"target-org"\s*:\s*"([^"]+)"')).Groups[1].Value

            $script:SfCache[$dir.FullName] = @{
                Alias = $alias
                Stamp = $stamp
            }
            return $alias
        }

        $dir = $dir.Parent
    }
    return ''
}

function Set-SfAlias {
    $env:SF_TARGET_ORG_ALIAS = Get-SfAlias $PWD.ProviderPath
}

function Show-GitBranchesColumn {
       param(
        [Alias('c')]
        [int]$Count = 8,
        [Alias('m')]
        [int]$MaxLength = 30
       )
       git branch | select -first $Count | % { $_.substring(0, [System.Math]::Min($MaxLength, $_.Length)) } | git column
}

New-Alias Set-PoshContext Set-SfAlias -Scope Global -Force
oh-my-posh init pwsh --config "~/VeraCloud/src/ohmyposh_config/atomic_salesforce.omp.json" | Invoke-Expression

# I'm tired of this shit
New-Alias clera clear
New-Alias cleara clear
New-Alias cleaar clear
New-Alias c clear
New-Alias claer clear
New-Alias ckear clear
New-Alias ckaer clear