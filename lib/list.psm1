Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath misc.psm1) -DisableNameChecking -function *
Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath taxa.psm1) -DisableNameChecking -function *
Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath path.psm1) -DisableNameChecking -function *


function _Iterate_Shallow
{
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    foreach ($year in 2011..2030)
    {
        $Entity.date = Get-Date -Year $year -Month 4 -Day 1 `
            -Hour 0 -Minute 0 -Second 0 -Millisecond 0

        $nendo_dir = Join-Path -Path $env:BG_save `
            -ChildPath (To-Nendo -Date $Entity.date -ForTaxon $true)

        if (!(Test-Path -Path $nendo_dir -PathType Container))
        {
            continue
        }

        foreach ($type in @('検討中', '記録用'))
        {
            $type_dir = Join-Path -Path $nendo_dir -ChildPath $type

            if (!(Test-Path -Path $type_dir -PathType Container))
            {
                continue
            }

            $Entity.taxon.type = $type

            Write-Output $type_dir
        }
    }
}

function _Iterate_Small
{
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    $root = (Get-CurrentTaxa).SelectSingleNode('root')

    _Iterate_Shallow -Entity $Entity | ForEach-Object -Process {
        foreach ($large in Sort-ByCode -Nodes ($root.SelectNodes('大分類')))
        {
            Update-Taxon -Taxon $Entity.taxon -Node $large -Level '大分類'

            $large_dir = Join-Path -Path $_ `
                            -ChildPath (Construct-Directory -Entity $Entity -Level '大分類')

            if (!(Test-Path -Path $large_dir -PathType Container))
            {
                continue
            }

            foreach ($medium in Sort-ByCode -Nodes ($large.SelectNodes('中分類')))
            {
                Update-Taxon -Taxon $Entity.taxon -Node $medium -Level '中分類'

                $medium_dir = Join-Path -Path $large_dir `
                            -ChildPath (Construct-Directory -Entity $Entity -Level '中分類')

                if (!(Test-Path -Path $medium_dir -PathType Container))
                {
                    continue
                }

                foreach ($small in Sort-ByCode -Nodes ($medium.SelectNodes('小分類')))
                {
                    Update-Taxon -Taxon $Entity.taxon -Node $small -Level '小分類'

                    $small_dir = Join-Path -Path $medium_dir `
                                    -ChildPath (Construct-Directory -Entity $Entity -Level '小分類')

                    if (Test-Path -Path $small_dir -PathType Container)
                    {
                        Write-Output $small_dir
                    }
                }
            }
        }
    }
}

function _Get-Record
{
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    $lc = $Entity.taxon.large_code
    $mc = $Entity.taxon.medium_code
    $sc = $Entity.taxon.small_code

    return ([PSCustomObject]@{
        保存区分 = $Entity.taxon.type
        レコードタイプ = $Entity.type
        作成日時 = $Entity.date.ToString('yyyyMMdd')
        リビジョン = $Entity.revision
        ファイル備考 = $Entity.remark
        名称 = $Entity.name
        大分類 = $Entity.taxon.large_name
        大分類コード = '#' + $lc
        中分類 = $Entity.taxon.medium_name
        中分類コード = '#' + $mc
        小分類 = $Entity.taxon.small_name
        小分類コード = '#' + $sc
        連結コード = '#' + $lc + $mc + $sc
        分類備考 = $Entity.taxon.remark
        頻度 = $Entity.taxon.frequency
        書式 = $Entity.taxon.format
    })
}

function _List-File
{
    $small_entity = Get-EntityTemplate
    $small_entity.type = '小分類'
    $small_entity.taxon = Get-TaxonTemplate

    _Iterate_Small -Entity $small_entity | ForEach-Object -Process {
        $small_entity.name = Construct-SmallName -Entity $small_entity
        Write-Output (_Get-Record -Entity $small_entity)

        foreach ($info in Get-ChildItem -Path $_)
        {
            $entity = Parse-FileName -Info $info
            if ($entity.remark -eq '違反')
            {
                $entity.date = $small_entity.date
            }

            $entity.taxon = $small_entity.taxon
            Write-Output (_Get-Record -Entity $entity)
        }
    }
}

function _List-Taxa
{
    $root = (Get-CurrentTaxa).SelectSingleNode('root')

    foreach ($large in Sort-ByCode -Nodes ($root.SelectNodes('大分類')))
    {
        foreach ($medium in Sort-ByCode -Nodes ($large.SelectNodes('中分類')))
        {
            foreach ($small in Sort-ByCode -Nodes ($medium.SelectNodes('小分類')))
            {
                $lc = $large.Attributes.ItemOf('コード').Value
                $mc = $medium.Attributes.ItemOf('コード').Value
                $sc = $small.Attributes.ItemOf('コード').Value

                Write-Output ([PSCustomObject]@{
                    大分類 = $large.Attributes.ItemOf('名称').Value
                    大分類コード = '#' + $lc
                    中分類 = $medium.Attributes.ItemOf('名称').Value
                    中分類コード = '#' + $mc
                    小分類 = $small.Attributes.ItemOf('名称').Value
                    小分類コード = '#' + $sc
                    連結コード = '#' + $lc + $mc + $sc
                    分類備考 = $small.Attributes.ItemOf('備考').Value
                    頻度 = $small.Attributes.ItemOf('頻度').Value
                    書式 = $small.Attributes.ItemOf('書式').Value
                })
            }
        }
    }
}

function Output-List
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$Target
    )

    Delimit "${Target}の出力"

    $selected = Loop-Block -Block {
        $intent = ReadLn "${Target}がCSV形式でポストに出力されます`r`nよろしいですか？【最終確認】[Y/n]"

        if (($intent -ne 'Y') -and ($intent -ne 'n'))
        {
            throw '無効な文字が入力されました'
        }

        return $intent
    }

    if ($selected -eq 'n')
    {
        WriteLn "${Target}の出力が中止されました"

        return
    }

    $csv_name = "_${Target}_$( Get-Date -Format 'yyyyMMddHHmmss' ).csv"
    $dst = Join-Path -Path $env:BG_post -ChildPath $csv_name

    if ($Target -eq '分類一覧')
    {
        _List-Taxa | Export-Csv -Path $dst -Encoding 'Default' -NoTypeInformation
    }
    else
    {
        _List-File | Export-Csv -Path $dst -Encoding 'Default' -NoTypeInformation
    }

    WriteLn "${Target}の出力が完了しました"
}
