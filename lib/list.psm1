Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath misc.psm1) -DisableNameChecking -function *
Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath taxa.psm1) -DisableNameChecking -function *
Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath path.psm1) -DisableNameChecking -function *


$crawler = Get-EntityTemplate
[System.Collections.ArrayList]$records = @()

function _Reset-Holders
{
    $crawler.taxon = Get-TaxonTemplate
    foreach ($property in @('type', 'date', 'revision', 'remark', 'name'))
    {
        $crawler.$property = ''
    }

    $records.Clear()
}

function _Add-FileRecord
{
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    $taxon = $Entity.taxon

    $lc = $taxon.large_code
    $mc = $taxon.medium_code
    $sc = $taxon.small_code

    if ($Entity.nom -eq '不規則')
    {
        $date = ''
    }
    else
    {
        $date = $Entity.date.ToString('yyyyMMdd')
    }

    [Void]$records.Add([PSCustomObject]@{
        年度 = [String]($taxon.nendo.Year)
        命名 = $Entity.nom
        大分類 = $taxon.large_name
        大分類コード = '#' + $lc
        中分類 = $taxon.medium_name
        中分類コード = '#' + $mc
        小分類 = $taxon.small_name
        小分類コード = '#' + $sc
        連結コード = '#' + $lc + $mc + $sc
        分類備考 = $taxon.remark
        保存区分 = $taxon.type
        レコードタイプ = $Entity.type
        作成日時 = $date
        リビジョン = [String]$Entity.revision
        ファイル備考 = $Entity.remark
        名称 = $Entity.name
    })
}

function _Add-Large
{
    $taxon = $crawler.taxon

    $record = [PSCustomObject]@{
        年度 = [String]($taxon.nendo.Year)
        命名 = $crawler.nom
        大分類 = $taxon.large_name
        大分類コード = '#' + $taxon.large_code
        中分類 = ''
        中分類コード = ''
        小分類 = ''
        小分類コード = ''
        連結コード = ''
        分類備考 = ''
        保存区分 = $taxon.type
        レコードタイプ = '大分類'
        作成日時 = ''
        リビジョン = ''
        ファイル備考 = ''
        名称 = ''
    }


    if ($crawler.nom -eq '不規則')
    {
        $record.大分類コード = ''
    }

    [Void]$records.Add($record)
}

function _Add-Medium
{
    $taxon = $crawler.taxon

    $record = [PSCustomObject]@{
        年度 = [String]($taxon.nendo.Year)
        命名 = $crawler.nom
        大分類 = $taxon.large_name
        大分類コード = '#' + $taxon.large_code
        中分類 = $taxon.medium_name
        中分類コード = '#' + $taxon.medium_code
        小分類 = ''
        小分類コード = ''
        連結コード = ''
        分類備考 = ''
        保存区分 = $taxon.type
        レコードタイプ = '中分類'
        作成日時 = ''
        リビジョン = ''
        ファイル備考 = ''
        名称 = ''
    }


    if ($crawler.nom -eq '不規則')
    {
        $record.中分類コード = ''
    }

    [Void]$records.Add($record)
}

function _Add-Small
{
    $taxon = $crawler.taxon

    $lc = $taxon.large_code
    $mc = $taxon.medium_code
    $sc = $taxon.small_code

    $record = [PSCustomObject]@{
        年度 = [String]($taxon.nendo.Year)
        命名 = $crawler.nom
        大分類 = $taxon.large_name
        大分類コード = '#' + $lc
        中分類 = $taxon.medium_name
        中分類コード = '#' + $mc
        小分類 = $taxon.small_name
        小分類コード = '#' + $sc
        連結コード = '#' + $lc + $mc + $sc
        分類備考 = $taxon.remark
        保存区分 = $taxon.type
        レコードタイプ = '小分類'
        作成日時 = ''
        リビジョン = ''
        ファイル備考 = ''
        名称 = ''
    }

    if ($crawler.nom -eq '不規則')
    {
        $record.小分類コード = ''
        $record.連結コード = ''
    }

    [Void]$records.Add($record)
}

function _Iterate-Nendo
{
    foreach ($info in Get-ChildItem -Path $env:BG_save -Directory)
    {
        try
        {
            $crawler.taxon.nendo = Parse-Nendo -Name $info.Name
        }
        catch
        {
            continue
        }

        Write-Output $info.FullName
    }
}

function _Iterate-Type
{
    begin
    {
        $types = @{ '検討中' = $null; '記録用' = $null }
    }

    Process {
        foreach ($info in Get-ChildItem -Path $_ -Directory)
        {
            if ( $types.ContainsKey($info.Name))
            {
                $crawler.taxon.type = $info.Name
                Write-Output $info.FullName
            }
        }
    }
}

function _Iterate-Large
{
    process
    {
        foreach ($info in Get-ChildItem -Path $_)
        {
            $isValid = ($info.Name -match '^([0-9a-zA-Z]+)【大分類】(\(検討中\)|)(.+)')
            if ($isValid)
            {
                if ($info -isnot [System.IO.DirectoryInfo])
                {
                    $isValid = $false
                }

                if (($crawler.taxon.type -eq '検討中') -and ($Matches.2 -ne '(検討中)'))
                {
                    $isValid = $false
                }
            }

            if ($isValid)
            {
                $crawler.taxon.large_code = $Matches.1
                $crawler.taxon.large_name = $Matches.3
                $crawler.nom = '正常'

                _Add-Large

                Write-Output $info.FullName
            }
            else
            {
                $crawler.taxon.large_name = $info.Name
                $crawler.nom = '不規則'

                _Add-Large
            }
        }
    }
}

function _Iterate-Medium
{
    process
    {
        foreach ($info in Get-ChildItem -Path $_)
        {
            $isValid = ($info.Name -match '^([0-9a-zA-Z]+)【中分類】(\(検討中\)|)(.+)')
            if ($isValid)
            {
                if ($info -isnot [System.IO.DirectoryInfo])
                {
                    $isValid = $false
                }

                if (($crawler.taxon.type -eq '検討中') -and ($Matches.2 -ne '(検討中)'))
                {
                    $isValid = $false
                }
            }

            if ($isValid)
            {
                $crawler.taxon.medium_code = $Matches.1
                $crawler.taxon.medium_name = $Matches.3
                $crawler.nom = '正常'

                _Add-Medium

                Write-Output $info.FullName
            }
            else
            {
                $crawler.taxon.medium_name = $info.Name
                $crawler.nom = '不規則'

                _Add-Medium
            }
        }
    }
}

function _Iterate-Small
{
    process
    {
        foreach ($info in Get-ChildItem -Path $_)
        {
            $crawler.type = '小分類'

            $isValid = ($info.Name -match '^([0-9a-zA-Z]+)【小分類：([^】]+)】(\(検討中\)|)(.+)')
            if ($isValid)
            {
                if ($info -isnot [System.IO.DirectoryInfo])
                {
                    $isValid = $false
                }

                if (($crawler.taxon.type -eq '検討中') -and ($Matches.3 -ne '(検討中)'))
                {
                    $isValid = $false
                }
            }


            if ($isValid)
            {
                $crawler.taxon.small_code = $Matches.1
                $crawler.taxon.small_name = $Matches.4
                $crawler.taxon.remark = $Matches.2
                $crawler.nom = '正常'

                _Add-Small

                Write-Output $info.FullName
            }
            else
            {
                $crawler.taxon.small_name = $info.Name
                $crawler.taxon.remark = ''
                $crawler.nom = '不規則'

                _Add-Small
            }
        }
    }
}

function _List-Record
{
    _Reset-Holders

    _Iterate-Nendo |
        _Iterate-Type |
        _Iterate-Large |
        _Iterate-Medium |
        _Iterate-Small |
        ForEach-Object -Process {
            foreach ($info in Get-ChildItem -Path $_)
            {
                $entity = Parse-FileName -Info $info
                $entity.taxon = $crawler.taxon
                _Add-FileRecord -Entity $entity
            }
        }

    return $records
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
        _List-Record | Export-Csv -Path $dst -Encoding 'Default' -NoTypeInformation
    }

    WriteLn "${Target}の出力が完了しました"
}
