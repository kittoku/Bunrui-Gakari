function ReadLn
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$Message
    )

    return Read-Host -Prompt "`r`n${Message}"
}

function WriteLn
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$Message
    )

    Write-Host "`r`n${Message}"
}

function WriteTab
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$Message
    )

    Write-Host "`t${Message}"
}

function WarnLn
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$message
    )

    Write-Host -ForegroundColor Red -BackgroundColor Black "`r`n${message}"
}

function ThrowLn
{
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$record
    )

    $message = "`r`n$( $record.Exception ):`r`n$( $record.ScriptStackTrace )"

    WarnLn $message
}

function Highlight-Intent
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$Intent,

        [String]$Prefix,
        [String]$Suffix
    )

    if ($null -ne $Prefix)
    {
        Write-Host -NoNewline "${Prefix} "
    }

    Write-Host -NoNewline -ForegroundColor Yellow -BackgroundColor Black $Intent

    if ($null -ne $Suffix)
    {
        Write-Host -NoNewline " ${Suffix}"
    }

    Write-Host ''
}

function Delimit
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$Message
    )

    $len = 80 - (4 + 2 * $Message.Length)

    Write-Host "`r`n$( '=' * $len )【${Message}】`r`n"
}

function Loop-Block
{
    param (
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$Block
    )

    while ($true)
    {
        try
        {
            Invoke-Command -ScriptBlock $Block
        }
        catch
        {
            WriteLn '操作をやり直してください．以下のエラーが発生しました:'
            ThrowLn $_
            continue
        }

        break
    }
}

function To-DateTime
{
    param (
        [Parameter(Mandatory = $true)]
        [String]$Date
    )

    if (!($Date -match "^[0123456789]{8}$"))
    {
        throw '日付は半角数字8桁で指定してください'
    }

    return Get-Date -Year $Date.Substring(0, 4) `
            -Month $Date.Substring(4, 2) `
            -Day $Date.Substring(6, 2) `
            -Hour 0 -Minute 0 -Second 0 -Millisecond 0
}

$_reiwa = Get-Date -Year 2019 -Month 4 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0
$_h23 = Get-Date -Year 2011 -Month 4 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0
$_table = @{
    '0' = '０'
    '1' = '１'
    '2' = '２'
    '3' = '３'
    '4' = '４'
    '5' = '５'
    '6' = '６'
    '7' = '７'
    '8' = '８'
    '9' = '９'
}
function To-Nendo
{
    param (
        [Parameter(Mandatory = $true)]
        [DateTime]$Date,

        [Parameter(Mandatory = $true)]
        [Boolean]$ForTaxon
    )

    if ($Date -lt $_h23)
    {
        throw '平成23年4月1日以前の日付を検出しました'
    }

    if ($Date -lt $_reiwa)
    {
        $prefix = '平成'
        $num = $Date.Year - 1988
    }
    else
    {
        $prefix = '令和'
        $num = $Date.Year - 2018
    }

    if ($Date.Month -lt 4)
    {
        $num -= 1
    }

    $half = "{0:D2}" -f $num

    if ($ForTaxon)
    {
        return "${prefix}${half}年度"
    }

    if ($half -eq '01')
    {
        return "${prefix}元年度"
    }
    else
    {
        $first_digit = $_table.($half.Substring(0, 1))
        if ($first_digit -eq '０')
        {
            $first_digit = ''
        }

        $second_digit = $_table.($half.Substring(1, 1))

        return "${prefix}{0}{1}年度" -f $first_digit, $second_digit
    }
}

function Parse-Nendo
{
    [OutputType([DateTime])]
    param (
        [Parameter(Mandatory = $true)]
        [String]$Name
    )

    if (!($Name -match '^(平成|令和)([0-9]+)年度$'))
    {
        throw
    }

    [Int32]$num = $Matches.2

    if ($Matches.1 -eq '平成')
    {
        $year = $num + 1988
    }
    else
    {
        $year = $num + 2018
    }

    if ($year -lt 2011)
    {
        throw
    }

    return Get-Date -Year $year -Month 4 -Day 1 `
            -Hour 0 -Minute 0 -Second 0 -Millisecond 0
}
