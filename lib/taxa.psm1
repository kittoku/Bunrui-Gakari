Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath misc.psm1) -DisableNameChecking -function *


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
        [String]$num,

        [Parameter(Mandatory = $true)]
        [Int32]$old
    )

    if (!($num -match "^[0123456789]+$"))
    {
        throw 'コードに半角数字以外の文字が使用されています'
    }

    if (($old -ne 0) -and ($old -ne $num.Length))
    {
        throw 'コードの長さが他のコードと一致していません'
    }

    return $num.Length
}

function _Check-Taxon
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$Code,

        [Parameter(Mandatory = $true)]
        [String]$Name,

        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Bookmark
    )

    try
    {
        $Bookmark.length = _Check-Code -old $Bookmark.length -num $Code

        if ( $Bookmark.codes.ContainsKey($Code))
        {
            throw '既に登録済みのコードです'
        }
        else
        {
            $Bookmark.codes.Add($Code, $null)
        }

        if ( $Bookmark.names.ContainsKey($Name))
        {
            throw '既に登録済みの名称です'
        }
        else
        {
            $Bookmark.names.Add($Name, $null)
        }
    }
    catch
    {
        $message = "分類 ${Code}-${Name} に不適切な要素がありました: `r`n"
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

function Get-TaxonTemplate
{
    return [PSCustomObject]@{
        type = '' # [検討中/記録用]
        large_code = ''
        large_name = ''
        medium_code = ''
        medium_name = ''
        small_code = ''
        small_name = ''
        remark = ''
        frequency = ''
    }
}

function Get-EntityTemplate
{
    return [PSCustomObject]@{
        taxon = ''
        type = '' # [大分類/中分類/小分類/ファイル/フォルダ]
        date = '' # DateTime object
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

    foreach ($property in @('taxon', 'date', 'remark', 'type', 'name', 'revision'))
    {
        $copied.$property = $Entity.$property
    }

    return $copied
}

function Construct-SmallName
{
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Entity
    )

    $taxon = $Entity.taxon

    if ($taxon.frequency = '毎年度')
    {
        $prefix = To-Nendo -date $Entity.date -ForTaxon $false
    }
    else
    {
        $prefix = ''
    }

    return "${prefix}$( $taxon.small_name )"
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

function Parse-Name
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
                    $entity.revision = [Int32](($Matches.0).Substring(0, $len - 1))
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
        $Taxon.frequency = $Node.Attributes.ItemOf('頻度').Value
    }
}

function Extract-Taxon
{
    [OutputType([System.Xml.XmlNode])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Taxon,

        [Parameter(Mandatory = $true)]
        [String]$Level
    )

    $root = $new.SelectSingleNode('root')

    $large = $root.SelectSingleNode("大分類[@名称='${Taxon.large_name}' and @コード='${Taxon.large_code}']")
    if ($Level -eq '大分類')
    {
        return $large
    }

    $medium = $large.SelectSingleNode("中分類[@名称='${Taxon.medium_name}' and @コード='${Taxon.medium_code}']")
    if ($Level -eq '中分類')
    {
        return $medium
    }

    return $medium.SelectSingleNode("小分類[@名称='${Taxon.small_name}' and @コード='${Taxon.small_code}']")
}

function Add-Taxon
{
    [OutputType([System.Xml.XmlDocument])]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Taxon,

        [Parameter(Mandatory = $true)]
        [String]$Level,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]$Xml
    )

    $new = $Xml.Clone()

    if ($Level -eq '大分類')
    {
        $root = $new.SelectSingleNode('root')

        $name = $new.CreateAttribute("名称")
        $name.Value = $Taxon.large_name
        $code = $new.CreateAttribute("コード")
        $code.Value = $Taxon.large_code

        $element = $new.CreateElement('大分類')
        [Void]$element.Attributes.Append($name)
        [Void]$element.Attributes.Append($code)
        [Void]$root.AppendChild($element)

        return $new
    }

    if ($Level -eq '中分類')
    {
        $large = Extract-Taxon -Taxon $Taxon -Level '大分類' -Xml $new

        $name = $new.CreateAttribute("名称")
        $name.Value = $Taxon.medium_name
        $code = $new.CreateAttribute("コード")
        $code.Value = $Taxon.medium_code

        $element = $new.CreateElement('中分類')
        [Void]$element.Attributes.Append($name)
        [Void]$element.Attributes.Append($code)
        [Void]$large.AppendChild($element)

        return $new
    }

    $medium = Extract-Taxon -Taxon $Taxon -Level '中分類' -Xml $new

    $name = $new.CreateAttribute("名称")
    $name.Value = $Taxon.small_name
    $code = $new.CreateAttribute("コード")
    $code.Value = $Taxon.small_code
    $remark = $new.CreateAttribute("備考")
    $remark.Value = $Taxon.remark
    $frequency = $new.CreateAttribute("頻度")
    $frequency.Value = $Taxon.frequency

    $element = $new.CreateElement('小分類')
    [Void]$element.Attributes.Append($name)
    [Void]$element.Attributes.Append($code)
    [Void]$element.Attributes.Append($remark)
    [Void]$element.Attributes.Append($frequency)
    [Void]$medium.AppendChild($element)

    return $new
}

function Add-Remark
{
    [OutputType([System.Xml.XmlDocument])]
    param (
        [Parameter(Mandatory = $true)]
        [String]$Remark,

        [Parameter(Mandatory = $true)]
        [String]$Type,

        [Parameter(Mandatory = $true)]
        [System.Xml.XmlDocument]$Xml
    )

    $new = $Xml.Clone()

    $node = $new.SelectSingleNode('root').SelectSingleNode($Type)

    $element = $new.CreateElement('要素')
    $element.InnerText = $Remark

    [Void]$node.AppendChild($element)

    return $new
}

function Get-CurrentTaxa
{
    param ()

    return [System.Xml.XmlDocument](Get-Content $env:BG_taxa)
}

function Sort-ByCode
{
    param (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlNodeList]$Nodes
    )

    return $Nodes | Sort-Object -Property { $_.Attributes.ItemOf('コード').Value }
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
                    -Bookmark $small_bookmark

                if ($null -eq $taxon.remark)
                {
                    throw "小分類 $( $taxon.small_name ) に分類備考が設定されていません"
                }

                if ($null -eq $taxon.frequency)
                {
                    throw "小分類 $( $taxon.small_name ) に頻度が設定されていません"
                }

                if (!($taxon_remarks.ContainsKey($taxon.remark)))
                {
                    throw "$( $taxon.remark )は定義された分類備考ではありません"
                }

                if (($taxon.frequency -ne '毎年度') -and ($taxon.frequency -ne '不定期'))
                {
                    throw "$( $taxon.frequency )が[毎年度/不定期]のいずれでもありません"
                }
            }
        }
    }
}

Export-ModuleMember -function Get-TaxonTemplate, Get-EntityTemplate,   `
      Copy-Entity, Construct-SmallName, Construct-Directory, Construct-FileName,   `
      Construct-Path, Parse-Name, Update-Taxon, Get-CurrentTaxa, Sort-ByCode,   `
      Validate-Taxa
