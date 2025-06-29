using namespace System.IO
$script:SfCache = @{}

function Get-SfAlias {
    param([string]$startDir)

    $dir = [DirectoryInfo]$startDir
    while ($dir) {
        # hit the cache?
        if ($script:SfCache.ContainsKey($dir.FullName)) {
            return $script:SfCache[$dir.FullName]
        }

        $cfg = Join-Path $dir.FullName '.sf\config.json'
        if ([File]::Exists($cfg)) {
            $text  = [File]::ReadAllText($cfg)
            $alias = ([regex]::Match($text, '"target-org"\s*:\s*"([^"]+)"')).Groups[1].Value
            $script:SfCache[$dir.FullName] = $alias
            return $alias
        }

        $dir = $dir.Parent
    }
    return ''
}

function Set-PoshContext {
    $env:SF_TARGET_ORG_ALIAS = Get-SfAlias $PWD.ProviderPath
}

oh-my-posh init pwsh --config "~/VeraCloud/src/ohmyposh_config/atomic_salesforce.omp.json" | Invoke-Expression
