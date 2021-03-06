function _Produce-Bookmark
{
    param ()

    return [PSCustomObject]@{
        length = 0
        codes = @{ }
        names = @{ }
    }
}

function _Reset-Bookmark
{
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Bookmark
    )

    $Bookmark.codes = @{ }
    $Bookmark.names = @{ }
}

function _Check-Code
{
    [OutputType([Int32])]
    param (
        [Parameter(Mandatory = $true)]
        [String]$Code,

        [Parameter(Mandatory = $true)]
        [Int32]$CurrentLength
    )

    if (!($Code -match "^[0-9a-zA-Z]+$"))
    {
        throw 'コードに半角英数以外の文字が使用されています'
    }

    if (($CurrentLength -ne 0) -and ($CurrentLength -ne $Code.Length))
    {
        throw 'コードの長さが他のコードと一致していません'
    }

    return $Code.Length
}

function _Check-Taxon
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$Code,

        [Parameter(Mandatory = $true)]
        [String]$Name,

        [String]$Remark,

        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Bookmark
    )

    if ($null -eq $Remark)
    {
        $id = $Name
    }
    else
    {
        $id = "${Name}[$Remark]"
    }

    try
    {
        $Bookmark.length = _Check-Code -CurrentLength $Bookmark.length -Code $Code

        if ( $Bookmark.codes.ContainsKey($Code))
        {
            throw '既に登録済みのコードです'
        }
        else
        {
            $Bookmark.codes.Add($Code, $null)
        }

        if ( $Bookmark.names.ContainsKey($id))
        {
            throw '既に登録済みの分類です'
        }
        else
        {
            $Bookmark.names.Add($id, $null)
        }
    }
    catch
    {
        $message = "分類 ${Code}-${id} に不適切な要素がありました: `r`n"
        $message += "$( $_.Exception ):`r`n$( $_.ScriptStackTrace )"
        throw $message
    }
}

function _Check-Remarks
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$Name,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]$Xml,

        [Parameter(Mandatory = $true)]
        [Hashtable]$Table
    )

    $root = $Xml.SelectSingleNode('root')

    if ($root.SelectNodes($Name).count -ne 1)
    {
        throw "root以下に${Name}が存在していません"
    }

    foreach ($item in $root.SelectSingleNode($Name).SelectNodes('要素'))
    {
        $text = $item.InnerText
        if ( $Table.ContainsKey($text))
        {
            throw "${Name}に重複した要素が含まれています: ${text}"
        }
        else
        {
            $Table.Add($text, $null)
        }
    }
}

function Sort-ByCode
{
    param (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNodeList]$Nodes
    )

    return $Nodes | Sort-Object -Property { $_.Attributes.ItemOf('コード').Value }
}

function Get-TaxonTemplate
{
    return [PSCustomObject]@{
        nendo = $null # DateTime object
        type = '' # [検討中/記録用]
        large_code = ''
        large_name = ''
        medium_code = ''
        medium_name = ''
        small_code = ''
        small_name = ''
        remark = ''
    }
}

function Get-EntityTemplate
{
    return [PSCustomObject]@{
        nom = '' # [正常/不規則]
        taxon = $null
        type = '' # [大分類/中分類/小分類/ファイル/フォルダ]
        date = $null # DateTime object
        revision = 0 # Int32
        remark = ''
        name = ''
    }
}

function Copy-Entity
{
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    $copied = Get-EntityTemplate

    foreach ($property in @('nom', 'taxon', 'type', 'date', 'revision', 'remark', 'name'))
    {
        $copied.$property = $Entity.$property
    }

    return $copied
}

function Update-Taxon
{
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Taxon,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNode]$Node,

        [Parameter(Mandatory = $true)]
        [String]$Level
    )

    if ($Level -eq '大分類')
    {
        $Taxon.large_code = $Node.Attributes.ItemOf('コード').Value
        $Taxon.large_name = $Node.Attributes.ItemOf('名称').Value
    }
    elseif ($Level -eq '中分類')
    {
        $Taxon.medium_code = $Node.Attributes.ItemOf('コード').Value
        $Taxon.medium_name = $Node.Attributes.ItemOf('名称').Value
    }
    else
    {
        $Taxon.small_code = $Node.Attributes.ItemOf('コード').Value
        $Taxon.small_name = $Node.Attributes.ItemOf('名称').Value
        $Taxon.remark = $Node.Attributes.ItemOf('備考').Value
    }
}

function Get-CurrentTaxa
{
    param ()

    return [System.Xml.XmlDocument](Get-Content $env:BG_taxa)
}

function Validate-Taxa
{
    param (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]$Xml
    )

    if ($Xml.SelectNodes('root').count -ne 1)
    {
        throw 'XMLファイルにrootが存在していません'
    }

    $taxon_remarks = @{ }
    $file_remarks = @{ }

    _Check-Remarks -Name '分類備考' -Xml $Xml -Table $taxon_remarks
    _Check-Remarks -Name 'ファイル備考' -Xml $Xml -Table $file_remarks

    $large_bookmark = _Produce-Bookmark
    $medium_bookmark = _Produce-Bookmark
    $small_bookmark = _Produce-Bookmark

    $larges = $Xml.SelectSingleNode('root').SelectNodes('大分類')
    if ($larges.Count -eq 0)
    {
        throw 'root以下に大分類が定義されていません'
    }

    $taxon = Get-TaxonTemplate

    foreach ($large in $larges)
    {
        _Reset-Bookmark($medium_bookmark)

        Update-Taxon -Taxon $taxon -Node $large -Level '大分類'

        _Check-Taxon -Code $taxon.large_code -Name $taxon.large_name `
            -Bookmark $large_bookmark

        $mediums = $large.SelectNodes('中分類')
        if ($mediums.Count -eq 0)
        {
            throw "大分類 $( $taxon.large_name ) 以下に中分類が定義されていません"
        }

        foreach ($medium in $mediums)
        {
            _Reset-Bookmark($small_bookmark)

            Update-Taxon -Taxon $taxon -Node $medium -Level '中分類'

            _Check-Taxon -Code $taxon.medium_code -Name $taxon.medium_name `
                -Bookmark $medium_bookmark

            $smalls = $medium.SelectNodes('小分類')
            if ($smalls.Count -eq 0)
            {
                throw "中分類 $( $taxon.medium_name ) 以下に小分類が定義されていません"
            }

            foreach ($small in $smalls)
            {
                Update-Taxon -Taxon $taxon -Node $small -Level '小分類'

                _Check-Taxon -Code $taxon.small_code -Name $taxon.small_name `
                    -Remark $Taxon.remark -Bookmark $small_bookmark

                if ($null -eq $taxon.remark)
                {
                    throw "小分類 $( $taxon.small_name ) に分類備考が設定されていません"
                }

                if (!($taxon_remarks.ContainsKey($taxon.remark)))
                {
                    throw "$( $taxon.remark )は定義された分類備考ではありません"
                }
            }
        }
    }
}

Export-ModuleMember -function Sort-ByCode, Get-TaxonTemplate, Get-EntityTemplate,  `
       Copy-Entity, Update-Taxon, Get-CurrentTaxa, Validate-Taxa
