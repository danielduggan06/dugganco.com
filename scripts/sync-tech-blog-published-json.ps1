param(
    [string]$SourceRoot = "C:\Users\danie\Nextcloud\Notes\Blog Articles\4-Published\json",
    [string]$RepoRoot = "C:\Users\danie\.config\superpowers\worktrees\dugganco.com\tech-blog-ai-publishing"
)

$ErrorActionPreference = "Stop"

$postsSource = Join-Path $SourceRoot "posts"
$manifestTarget = Join-Path $RepoRoot "public\data\blog-manifest.json"
$postsTarget = Join-Path $RepoRoot "public\data\blog-posts"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Repair-Mojibake {
    param(
        [AllowNull()]
        [string]$Value
    )

    if ($null -eq $Value) {
        return $null
    }

    $singleQuote = [string][char]0x2019
    $openSingle = [string][char]0x2018
    $openDouble = [string][char]0x201C
    $closeDouble = [string][char]0x201D
    $emDash = [string][char]0x2014
    $enDash = [string][char]0x2013
    $ellipsis = [string][char]0x2026

    $fixed = $Value
    $fixed = $fixed.Replace((-join [char[]](0x00E2, 0x20AC, 0x2122)), $singleQuote)
    $fixed = $fixed.Replace((-join [char[]](0x00E2, 0x20AC, 0x02DC)), $openSingle)
    $fixed = $fixed.Replace((-join [char[]](0x00E2, 0x20AC, 0x0153)), $openDouble)
    $fixed = $fixed.Replace((-join [char[]](0x00E2, 0x20AC, 0x009D)), $closeDouble)
    $fixed = $fixed.Replace((-join [char[]](0x00E2, 0x20AC, 0x201D)), $closeDouble)
    $fixed = $fixed.Replace((-join [char[]](0x00E2, 0x20AC, 0x2014)), $emDash)
    $fixed = $fixed.Replace((-join [char[]](0x00E2, 0x20AC, 0x2013)), $enDash)
    $fixed = $fixed.Replace((-join [char[]](0x00E2, 0x20AC, 0x00A6)), $ellipsis)
    $fixed = $fixed.Replace("ï¿½?Ts", "$singleQuote" + "s")
    $fixed = $fixed.Replace("ï¿½?Tt", "$singleQuote" + "t")
    return $fixed
}

function Normalize-Value {
    param(
        $Value
    )

    if ($null -eq $Value) {
        return $null
    }

    if ($Value -is [string]) {
        return (Repair-Mojibake -Value $Value)
    }

    if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
        $items = @()
        foreach ($item in $Value) {
            $items += Normalize-Value -Value $item
        }
        return $items
    }

    if ($Value.PSObject -and $Value.PSObject.Properties.Count -gt 0) {
        $normalized = [ordered]@{}
        foreach ($property in $Value.PSObject.Properties) {
            $normalized[$property.Name] = Normalize-Value -Value $property.Value
        }
        return [pscustomobject]$normalized
    }

    return $Value
}

if (-not (Test-Path -LiteralPath $postsSource)) {
    throw "Published posts source folder not found: $postsSource"
}

New-Item -ItemType Directory -Force -Path $postsTarget | Out-Null

$sourceFiles = Get-ChildItem -LiteralPath $postsSource -Filter *.json -File | Sort-Object Name
foreach ($file in $sourceFiles) {
    $raw = Repair-Mojibake -Value (Get-Content -LiteralPath $file.FullName -Raw)
    $post = $raw | ConvertFrom-Json

    if (-not $post.slug) {
        throw "Post JSON is missing slug: $($file.FullName)"
    }

    $targetPath = Join-Path $postsTarget $file.Name
    [System.IO.File]::WriteAllText($targetPath, ($post | ConvertTo-Json -Depth 20), $utf8NoBom)
}

$repoFiles = Get-ChildItem -LiteralPath $postsTarget -Filter *.json -File | Sort-Object Name
$postEntries = foreach ($file in $repoFiles) {
    $raw = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($file.FullName))
    $post = $raw | ConvertFrom-Json

    [pscustomobject]@{
        title = [string]$post.title
        slug = [string]$post.slug
        excerpt = [string]$post.excerpt
        category = [string]$post.category
        tags = @($post.tags)
        published_at = [string]$post.published_at
        updated_at = [string]$post.updated_at
        reading_time = [int]$post.reading_time
        meta_description = [string]$post.meta_description
    }
}

$sortedPosts = $postEntries | Sort-Object @{ Expression = { [datetimeoffset]::Parse($_.published_at) }; Descending = $true }

$manifest = [pscustomobject]@{
    generated_at = [datetimeoffset]::Now.ToString("o")
    posts = @($sortedPosts)
}

[System.IO.File]::WriteAllText($manifestTarget, ($manifest | ConvertTo-Json -Depth 10), $utf8NoBom)

Write-Output "Synced $($sourceFiles.Count) published post JSON file(s) into $RepoRoot and rebuilt the manifest from $($repoFiles.Count) repo post file(s)"
