Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath misc.psm1) -DisableNameChecking -function *
Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath taxa.psm1) -DisableNameChecking -function *


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
        [PSCustomObject]$Taxon,

        [Parameter(Mandatory = $true)]
        [String]$Level
    )

    if ($Taxon.type -eq '検討中')
    {
        $type = '(検討中)'
    }
    else
    {
        $type = ''
    }

    if ($Level -eq '大分類')
    {
        return "$( $Taxon.large_code )【大分類】${type}$( $Taxon.large_name )"

    }
    elseif ($Level -eq '中分類')
    {
        return "$( $Taxon.medium_code )【中分類】${type}$( $Taxon.medium_name )"
    }
    else
    {
        return "$( $Taxon.small_code )【小分類：$( $Taxon.remark )】${type}$( $Taxon.small_name )"
    }
}

$_prop = @{ '大分類' = 'large_name'; '中分類' = 'medium_name'; '小分類' = 'small_name' }
function Construct-Path
{
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    $taxon = $Entity.taxon

    $current_dir = Join-Path -Path (To-Nendo -Date $taxon.nendo -ForTaxon $true) `
        -ChildPath $taxon.type

    foreach ($level in @('大分類', '中分類', '小分類'))
    {
        $level_dir = Join-Path -Path $current_dir `
            -ChildPath (Construct-Directory -Taxon $taxon -Level $level)

        if ($Entity.type -eq $level)
        {
            if ($Entity.nom -eq '不規則')
            {
                return Join-Path -Path $current_dir -ChildPath $taxon.($_prop.$level)
            }
            else
            {
                return $level_dir
            }
        }

        $current_dir = $level_dir
    }

    if ($Entity.nom -eq '不規則')
    {
        $filename = $Entity.name
    }
    else
    {
        $filename = Construct-FileName -Entity $Entity
    }

    return Join-Path -Path $current_dir -ChildPath $filename
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
                [Int32]$entity.revision = 0
            }
            else
            {
                throw
            }
        }

        $entity.nom = '正常'
        $entity.remark = $metadata
    }
    catch
    {
        $entity.nom = '不規則'
        $entity.date = $null
        $entity.revision = 0
        $entity.remark = ''
        $entity.name = $Info.Name
    }

    return $entity
}
