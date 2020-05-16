Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath misc.psm1) -DisableNameChecking -function *
Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath taxa.psm1) -DisableNameChecking -function *


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

        $taxon.type = $record.保存区分
        $taxon.large_code = $record.大分類コード.Substring(1)
        $taxon.large_name = $record.大分類
        $taxon.medium_code = $record.中分類コード.Substring(1)
        $taxon.medium_name = $record.中分類
        $taxon.small_code = $record.小分類コード.Substring(1)
        $taxon.small_name = $record.小分類
        $taxon.remark = $record.分類備考
        $taxon.frequency = $record.頻度
        $taxon.format = $record.書式

        $entity = Get-EntityTemplate
        $entity.taxon = $taxon

        $entity.type = $record.レコードタイプ
        $entity.date = To-DateTime -Date $record.作成日時
        [Int32]$entity.revision = $record.revision
        $entity.remark = $record.ファイル備考
        $entity.name = $record.名称

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
        $small_dir = Construct-Path -Entity $entity

        if ($entity.remark -eq '違反')
        {
            $src = Join-Path -Path $small_dir -ChildPath $entity.name
            $link_name = $entity.name
        }
        elseif ($entity.type -eq '小分類')
        {
            $src = $small_dir
            $link_name = Construct-SmallName -Entity $entity
        }
        else
        {
            $file_name = Construct-FileName -Entity $entity
            $src = Join-Path -Path $small_dir -ChildPath $file_name
            $link_name = $file_name
        }

        $link_name = '_' + $link_name + '.lnk'
        WriteTab $link_name

        Write-Output ([PSCustomObject]@{
            src = Join-Path -Path $env:BG_save -ChildPath $src
            dst = Join-Path -Path $env:BG_post -ChildPath $link_name
        })
    }
}

function _List-PathToDelete
{
    param (
        [Parameter(Mandatory = $true)]
        [Array]$Records
    )

    $prior_entities = @()
    $posterior_entities = @()

    foreach ($entity in $Records)
    {
        $small_dir = Construct-Path -Entity $entity

        if ($entity.remark -eq '違反')
        {
            $src = Join-Path -Path $small_dir -ChildPath $entity.name
            $isPrior = $true
        }
        elseif ($entity.type -eq '小分類')
        {
            $src = $small_dir
            $isPrior = $false
        }
        else
        {
            $file_name = Construct-FileName -Entity $entity
            $src = Join-Path -Path $small_dir -ChildPath $file_name
            $isPrior = $true
        }

        $src = Join-Path -Path $env:BG_save -ChildPath $src

        Highlight-Intent -Intent $src

        if ($isPrior)
        {
            $prior_entities += $src
        }
        else
        {
            $posterior_entities += $src
        }
    }

    return $prior_entities + $posterior_entities
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
        $link = $wsh.CreateShortcut($path.dst)
        $link.TargetPath = $path.src
        $link.Save()
    }

    WriteLn 'ショートカットの作成が完了しました'
}

function Delete-File
{
    $records = _Convert-ToEntity -Csv (_Select-Csv)

    Delimit 'ファイルの削除'

    [Array]$paths = _List-PathToDelete -Records $records

    $selected = Loop-Block -Block {
        $intent = ReadLn "以上のファイルが削除されます`r`nよろしいですか？【最終確認】[Y/n]"

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

    foreach ($src in $paths)
    {
        try
        {
            Write-Host -NoNewline "${src}削除中..."
            Remove-Item -Recurse -Force -Path $src
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
