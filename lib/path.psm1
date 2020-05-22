Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath misc.psm1) -DisableNameChecking -function *
Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath taxa.psm1) -DisableNameChecking -function `
    Get-EntityTemplate


function Construct-SmallName
{
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    $taxon = $Entity.taxon
    $base_name = $taxon.small_name

    # replace if necessary
    if ($taxon.replacer.Count -gt 0)
    {
        foreach ($index in 0..($taxon.replacer.Count - 1))
        {
            $holder = "{${index}}"
            if ( $base_name.Contains($holder))
            {
                $base_name = $base_name.Replace($holder, $taxon.replacer[$index])
            }
        }
    }

    if ($taxon.frequency -eq '毎年度')
    {
        $nendo = To-Nendo -date $Entity.date -ForTaxon $false

        if ($taxon.format -eq '後置')
        {
            return "${$base_name}（${nendo}）"
        }
        elseif ($taxon.format -eq '区切')
        {
            return "${nendo}　${base_name}"
        }
        else
        {
            return "${nendo}${base_name}"
        }
    }
    else
    {
        return $base_name
    }
}

function Construct-FileName
{
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    $name = $Entity.date.ToString('yyyyMMdd')

    if ($Entity.revision -ne 0)
    {
        $name += "_$( [String]$Entity.revision )"
    }

    if ($Entity.remark -ne '')
    {
        $name += " $( $Entity.remark )"
    }

    $name += "_$( $Entity.name )"

    return $name
}

function Construct-Directory
{
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity,

        [Parameter(Mandatory = $true)]
        [String]$Level
    )

    $taxon = $Entity.taxon

    if ($taxon.type -eq '検討中')
    {
        $type = '(検討中)'
    }
    else
    {
        $type = ''
    }

    if ($Level -eq '大分類')
    {
        return "$( $taxon.large_code )【大分類】${type}$( $taxon.large_name )"
    }
    elseif ($Level -eq '中分類')
    {
        return "$( $taxon.medium_code )【中分類】${type}$( $taxon.medium_name )"
    }
    else
    {
        return "$( $taxon.small_code )【小分類：$( $taxon.remark )】${type}$( Construct-SmallName -Entity $Entity )"
    }
}

function Construct-Path
{
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    $nendo_dir = To-Nendo -date $Entity.date -ForTaxon $true

    $type_dir = $Entity.taxon.type

    $large_dir = Construct-Directory -Entity $Entity -Level '大分類'
    $medium_dir = Construct-Directory -Entity $Entity -Level '中分類'
    $small_dir = Construct-Directory -Entity $Entity -Level '小分類'

    return Concatenate-Path -Parent $nendo_dir `
        -Children $type_dir, $large_dir, $medium_dir, $small_dir
}

function Parse-FileName
{
    # 小分類の下位構造にのみ使用
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$Info
    )

    $entity = Get-EntityTemplate

    if ($Info -is [System.IO.DirectoryInfo])
    {
        $entity.type = 'フォルダ'
    }
    else
    {
        $entity.type = 'ファイル'
    }

    try
    {
        if (!($Info.Name -match '_[^_]+$'))
        {
            throw
        }
        $len = ($Matches.0).Length
        $metadata = $Info.Name.Substring(0, $Info.Name.Length - $len)
        $entity.name = $Info.Name.Substring($metadata.Length + 1)

        $date = $metadata.Substring(0, 8)
        $metadata = $metadata.Substring(8)
        $entity.date = To-DateTime -Date $date

        if ($metadata.Length -gt 0)
        {
            $delimiter = $metadata.Substring(0, 1)
            $metadata = $metadata.Substring(1)

            if ($delimiter -eq '_')
            {
                if ($metadata -match '^[0123456789]+ ')
                {
                    $len = ($Matches.0).Length
                    [Int32]$entity.revision = ($Matches.0).Substring(0, $len - 1)
                    $metadata = $metadata.Substring($len)
                }
                else
                {
                    throw
                }
            }
            elseif ($delimiter -eq ' ')
            {
            }
            else
            {
                throw
            }
        }

        $entity.remark = $metadata

    }
    catch
    {
        $entity.date = ""
        $entity.revision = 0
        $entity.remark = '違反'
        $entity.name = $Info.Name
    }

    return $entity
}
