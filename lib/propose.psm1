Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath misc.psm1) -DisableNameChecking -function *
Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath taxa.psm1) -DisableNameChecking -function *
Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath path.psm1) -DisableNameChecking -function *


function _Select-Csv
{
    Delimit "CSVファイルの選択"

    $table = @{ }
    $i = 0
    foreach ($info in Get-ChildItem -Path $env:BG_post)
    {
        if ($info.name -match '.*\.csv$')
        {
            $i++

            WriteTab "${i}: $( $info.name )"

            $table.Add($i.ToString(), $info.name)
        }
    }

    if ($i -eq 0)
    {
        throw 'ポストに認識可能なCSVファイルが入っていません'
    }

    $selected = Loop-Block -Block {
        $intent = ReadLn "選択するCSVファイルの番号を半角数字で入力してください"

        if (!($table.ContainsKey($intent)))
        {
            throw '無効な文字が入力されました'
        }

        return $table.$intent
    }

    Highlight-Intent -Intent $selected -suffix 'が選択されました'

    return Import-Csv -Path (Join-Path -Path $env:BG_post -ChildPath $selected) -Encoding 'Default'
}

function _Convert-ToEntity
{
    param (
        [Parameter(Mandatory = $true)]
        [Array]$Csv
    )

    foreach ($record in $Csv)
    {
        $taxon = Get-TaxonTemplate

        $taxon.nendo = Get-Date -Year ([Int32]($record.年度)) `
            -Month 4 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0
        $taxon.type = $record.保存区分
        $taxon.large_code = $record.大分類コード.Replace('#', '')
        $taxon.large_name = $record.大分類
        $taxon.medium_code = $record.中分類コード.Replace('#', '')
        $taxon.medium_name = $record.中分類
        $taxon.small_code = $record.小分類コード.Replace('#', '')
        $taxon.small_name = $record.小分類
        $taxon.remark = $record.分類備考

        $entity = Get-EntityTemplate
        $entity.taxon = $taxon

        $entity.nom = $record.命名
        $entity.type = $record.レコードタイプ
        $entity.date = $record.作成日時
        [Int32]$entity.revision = $record.リビジョン
        $entity.remark = $record.ファイル備考
        $entity.name = $record.名称

        if ($entity.date -ne '')
        {
            $entity.date = To-DateTime -Date $entity.date
        }

        Write-Output $entity
    }
}

function _List-PathToLink
{
    param (
        [Parameter(Mandatory = $true)]
        [Array]$Records
    )

    foreach ($entity in $Records)
    {
        $target = Construct-Path -Entity $entity

        $link_name = '_' + (Split-Path -Path $target -Leaf) + '.lnk'
        WriteTab $link_name

        Write-Output ([PSCustomObject]@{
            link = Join-Path -Path $env:BG_post -ChildPath $link_name
            target = Join-Path -Path $env:BG_save -ChildPath $target
        })
    }
}

function _List-PathToDelete
{
    param (
        [Parameter(Mandatory = $true)]
        [Array]$Records
    )

    foreach ($entity in $Records)
    {
        $target = Construct-Path -Entity $entity

        Highlight-Intent -Intent $target

        if ($entity.type -eq '大分類')
        {
            $priority = 0
        }
        elseif ($entity.type -eq '中分類')
        {
            $priority = 1
        }
        elseif ($entity.type -eq '小分類')
        {
            $priority = 2
        }
        else
        {
            $priority = 3
        }

        Write-Output ([PSCustomObject]@{
            priority = $priority
            target = Join-Path -Path $env:BG_save -ChildPath $target
        })
    }
}

function Generate-Shortcut
{
    $records = _Convert-ToEntity -Csv (_Select-Csv)

    Delimit 'ショートカットの作成'

    [Array]$paths = _List-PathToLink -Records $records

    $selected = Loop-Block -Block {
        $intent = ReadLn "以上のショートカットがポストに作成されます`r`nよろしいですか？【最終確認】[Y/n]"

        if (($intent -ne 'Y') -and ($intent -ne 'n'))
        {
            throw '無効な文字が入力されました'
        }

        return $intent
    }

    if ($selected -eq 'n')
    {
        WriteLn 'ショートカットの作成が中止されました'

        return
    }

    $wsh = New-Object -ComObject WScript.Shell
    foreach ($path in $paths)
    {
        $link = $wsh.CreateShortcut($path.link)
        $link.TargetPath = $path.target
        $link.Save()
    }

    WriteLn 'ショートカットの作成が完了しました'
}

function Delete-File
{
    $records = _Convert-ToEntity -Csv (_Select-Csv)

    Delimit 'ファイルの削除'

    [Array]$paths = _List-PathToDelete -Records $records | `
        Sort-Object -Property { $_.priority } -Descending

    $selected = Loop-Block -Block {
        $intent = ReadLn "以上の要素が削除されます`r`nよろしいですか？【最終確認】[Y/n]"

        if (($intent -ne 'Y') -and ($intent -ne 'n'))
        {
            throw '無効な文字が入力されました'
        }

        return $intent
    }

    if ($selected -eq 'n')
    {
        WriteLn 'ファイルの削除が中止されました'

        return
    }

    foreach ($path in $paths)
    {
        try
        {
            Write-Host -NoNewline "$( $path.target ) 削除中..."
            Remove-Item -Recurse -Force -Path $path.target
            Write-Host '完了'
        }
        catch
        {
            Write-Host ''
            ThrowLn $_
        }
    }

    WriteLn 'ファイルの削除が完了しました'
}
