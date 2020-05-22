Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath misc.psm1) -DisableNameChecking -function *
Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath taxa.psm1) -DisableNameChecking -function *
Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath path.psm1) -DisableNameChecking -function *


function _Select-Type
{
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Taxon
    )

    Delimit '保存区分の選択'

    WriteTab '1: 検討中'
    WriteTab '2: 記録用'

    Loop-Block -Block {
        $intent = ReadLn "選択する保存区分の番号を半角数字で入力してください"

        if ($intent -eq '1')
        {
            $Taxon.type = '検討中'
        }
        elseif ($intent -eq '2')
        {
            $Taxon.type = '記録用'
        }
        else
        {
            throw '無効な文字が入力されました'
        }
    }

    Highlight-Intent -Intent $Taxon.type -Suffix 'が選択されました'
}

function _Select-Taxon
{
    [OutputType([System.Xml.XmlNode])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Taxon,

        [Parameter(Mandatory = $true)]
        [Array]$Nodes,

        [Parameter(Mandatory = $true)]
        [String]$Level
    )

    Delimit "${Level}の選択"

    $table = @{ }
    foreach ($node in $Nodes)
    {
        if ($Level -eq '小分類')
        {
            $code = $node.Attributes.ItemOf('コード').Value
            $name = $node.Attributes.ItemOf('名称').Value
            $remark = $node.Attributes.ItemOf('備考').Value
            $frequency = $node.Attributes.ItemOf('頻度').Value

            WriteTab "${code}: ${name}    [${remark}][${frequency}]"

        }
        else
        {
            $code = $node.Attributes.ItemOf('コード').Value
            $name = $node.Attributes.ItemOf('名称').Value

            WriteTab "${code}: ${name}"
        }

        $table.Add($code, $node)
    }


    $selected = Loop-Block -Block {
        $intent = ReadLn "選択する${Level}コードを半角英数で入力してください"

        if (!($table.ContainsKey($intent)))
        {
            throw '無効な文字が入力されました'
        }

        return $table.$intent
    }

    Update-Taxon -Taxon $Taxon -Node $selected -Level $Level

    Highlight-Intent -Prefix "${Level}" -Suffix "が選択されました" `
        -Intent ("$( $selected.Attributes.ItemOf('コード').Value )-" +
            "$( $selected.Attributes.ItemOf('名称').Value )")

    return $selected
}

function _Select-Date
{
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    Delimit '作成日時の設定'

    Loop-Block -Block {
        $intent = ReadLn (
        "作成日時を半角数字で入力してください(例: 2020年4月1日 → 20200401)" `
              + "`r`n何も入力されない場合、今日の日付が自動的に設定されます"
        )

        if ($intent -eq "")
        {
            $Entity.date = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0
        }
        else
        {
            $Entity.date = To-DateTime -Date $intent
        }
    }

    $nendo = To-Nendo -Date $Entity.date -ForTaxon $true

    Highlight-Intent -Suffix "が選択されました" `
        -Intent ("[{0}] {1}年{2}月{3}日" -f `
            $nendo, $Entity.date.Year, $Entity.date.Month, $Entity.date.day)
}

function _Select-Remark
{
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]$Xml
    )

    Delimit 'ファイル備考の設定'

    $table = @{ }
    $i = 0

    foreach ($element in $xml.SelectSingleNode('root').SelectSingleNode('ファイル備考').SelectNodes('要素'))
    {
        $i++

        WriteTab "${i}: $( $element.InnerText )"

        $table.Add($i.ToString(), $element.InnerText)
    }

    Loop-Block -Block {
        $intent = ReadLn (
        "選択するファイル備考の番号を半角数字で入力してください" `
              + "`r`n何も入力されない場合、ファイル備考は設定されません"
        )

        if ($intent -eq '')
        {
            $Entity.remark = ''
        }
        elseif ($table.ContainsKey($intent))
        {
            $Entity.remark = $table.$intent
        }
        else
        {
            throw '無効な文字が入力されました'
        }
    }

    if ($Entity.remark -eq '')
    {
        Highlight-Intent -Prefix 'ファイル備考は' -Intent '設定されません'
    }
    else
    {
        Highlight-Intent -Prefix 'ファイル備考' -Suffix 'が設定されました' `
            -Intent $Entity.remark
    }
}

function _Equal-Entity
{
    [OutputType([Boolean])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Left,

        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Right
    )

    foreach ($property in @('date', 'name'))
    {
        if ($left.$property -ne $right.$property)
        {
            return $false
        }
    }

    return $true
}

function _Move-Entity
{
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    $posted_path = Join-Path -Path $env:BG_post -ChildPath $Entity.name
    $dst_path = Concatenate-Path -Parent $env:BG_save -Children `
        (Construct-Path -Entity $Entity), (Construct-FileName -Entity $Entity)

    Move-Item -Path $posted_path -Destination $dst_path
}

function _Get-Posted
{
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    foreach ($info in Get-ChildItem -Path $env:BG_post)
    {
        if ($info.name.Substring(0, 1) -eq '_')
        {
            continue
        }

        $copied = Copy-Entity($Entity)

        if ($Info -is [System.IO.DirectoryInfo])
        {
            $copied.type = 'フォルダ'
        }
        else
        {
            $copied.type = 'ファイル'
        }

        $copied.name = $info.name

        Write-Output $copied
    }
}

function _Get-Existings
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$Path
    )

    foreach ($child in (Get-ChildItem -Path $dst))
    {
        Write-Output (Parse-FileName -Info $child)
    }
}

function _Check-Duplication
{
    param (
        [Parameter(Mandatory = $true)]
        [Array]$New,

        [Parameter(Mandatory = $true)]
        [Array]$Old
    )

    foreach ($left in $New)
    {
        foreach ($right in $Old)
        {
            if (_Equal-Entity -Left $left -Right $right)
            {
                $left.revision = [Math]::Max($left.revision, $right.revision + 1)
            }
        }
    }
}

function _Fill-Holder
{
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Taxon
    )

    Delimit '文字列の挿入'

    WriteLn ("小分類 $( $Taxon.small_name ) には文字列を挿入する必要があります`r`n" `
         + '他の小分類と名称の整合性を保つよう全角，半角，桁数等に注意して入力してください')

    $replacer = @()

    $index = 0
    while ($true)
    {
        $holder = "{${index}}"
        if ( $Taxon.small_name.Contains($holder))
        {
            $intent = ReadLn "${holder}の位置に入る文字列を入力してください"
            Highlight-Intent -Intent $intent -Suffix 'が入力されました'
            $replacer += $intent
        }
        else
        {
            break
        }

        $index++
    }

    $Taxon.replacer = $replacer
}

function Register-File
{
    param ()

    $taxon = Get-TaxonTemplate
    $xml = Get-CurrentTaxa

    _Select-Type -Taxon $taxon

    $large = _Select-Taxon -Level '大分類' -Taxon $taxon `
        -Nodes (Sort-ByCode -Nodes ($xml.SelectSingleNode('root').SelectNodes('大分類')))

    $medium = _Select-Taxon -Level '中分類' -Taxon $taxon `
        -Nodes (Sort-ByCode -Nodes ($large.SelectNodes('中分類')))

    $small = _Select-Taxon -Level '小分類' -Taxon $taxon `
        -Nodes (Sort-ByCode -Nodes ($medium.SelectNodes('小分類')))

    if ( $taxon.small_name.Contains('{0}'))
    {
        _Fill-Holder -Taxon $taxon
    }

    $basic_entity = Get-EntityTemplate
    $basic_entity.taxon = $taxon
    $basic_entity.revision = 0

    _Select-Date -Entity $basic_entity
    _Select-Remark -Entity $basic_entity -Xml $xml

    $dst = Join-Path -Path $env:BG_save -ChildPath (Construct-Path -Entity $basic_entity)

    [Array]$posted = _Get-Posted -Entity $basic_entity
    if ($posted.Count -eq 0)
    {
        throw 'ポストに認識可能なファイルが入っていません'
    }

    $isExisting = Test-Path -Path $dst -PathType Container

    if ($isExisting)
    {
        [Array]$exisitings = _Get-Existings -Path $dst
    }
    else
    {
        $exisitings = @()
    }

    if ($exisitings.Count -gt 0)
    {
        _Check-Duplication -New $posted -Old $exisitings
    }


    Delimit 'ファイルの登録'

    foreach ($entity in $posted)
    {
        WriteTab (Construct-FileName -Entity $entity)
    }

    $selected = Loop-Block -Block {
        Highlight-Intent -Prefix "`r`n以上のファイルが`r`n" -Suffix "`r`nに作成されます" `
            -Intent $dst

        $intent = ReadLn ('よろしいですか？【最終確認】[Y/n]')

        if (($intent -ne 'Y') -and ($intent -ne 'n'))
        {
            throw '無効な文字が入力されました'
        }

        return $intent
    }

    if ($selected -eq 'Y')
    {
        if (!$isExisting)
        {
            [Void](New-Item -Path $dst -ItemType Directory)
        }

        foreach ($entity in $posted)
        {
            _Move-Entity -Entity $entity
        }

        WriteLn 'ファイルの登録が完了しました'
    }
    else
    {
        WriteLn 'ファイルの登録が中止されました'
    }
}
