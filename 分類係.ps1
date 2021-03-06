$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

Write-Output '分類係: 0.0.5'
Write-Output "PowerShell: $( $PSVersionTable.PSVersion )"
Write-Output ("=" * 80)


try
{
    Write-Output '"パス設定.xml"の確認...'
    $config_path = Resolve-Path -Path .\パス設定.xml
    [System.Xml.XmlDocument]$config_xml = Get-Content $config_path
    $root = $config_xml.SelectSingleNode('root')


    Write-Output '各種パスの確認...'
    $env:BG_lib = Resolve-Path -Path $root.SelectSingleNode('ライブラリ').InnerText
    Write-Output "`tライブラリ: ${env:BG_lib}"
    if (Test-Path -Path $env:BG_lib -PathType Leaf)
    {
        throw 'ライブラリのパスにファイルが指定されています'
    }

    $env:BG_save = Resolve-Path -Path $root.SelectSingleNode('データベース').InnerText
    Write-Output "`tデータベース: ${env:BG_save}"
    if (Test-Path -Path $env:BG_save -PathType Leaf)
    {
        throw 'データベースのパスにファイルが指定されています'
    }

    $env:BG_post = Resolve-Path -Path $root.SelectSingleNode('ポスト').InnerText
    Write-Output "`tポスト: ${env:BG_post}"
    if (Test-Path -Path $env:BG_post -PathType Leaf)
    {
        throw 'ポストのパスにファイルが指定されています'
    }

    $env:BG_taxa = Resolve-Path -Path $root.SelectSingleNode('分類設定').InnerText
    Write-Output "`t分類設定: ${env:BG_taxa}"
    if (Test-Path -Path $env:BG_taxa -PathType Container)
    {
        throw '分類設定のパスにディレクトリが指定されています'
    }


    Write-Output 'モジュールのインポート...'
    Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath misc.psm1) -DisableNameChecking -function *
    Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath taxa.psm1) -DisableNameChecking -function *


    Write-Output '分類設定の確認...'
    Validate-Taxa -Xml (Get-CurrentTaxa)


    while ($true)
    {
        Delimit 'タスクの選択'

        WriteTab '1: ファイルを登録する'
        WriteTab '2: ファイル一覧を出力する'
        WriteTab '3: 分類一覧を出力する'
        WriteTab '4: ショートカットを作成する'

        $operation = ReadLn '行いたいタスクの番号を半角数字で入力してください'

        switch ($operation)
        {
            '1' {
                Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath register.psm1) `
                    -DisableNameChecking -function Register-File

                Highlight-Intent -Intent 'ファイル登録シークエンス' -Suffix 'を開始します'
                Register-File
            }

            '2' {
                Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath list.psm1) `
                    -DisableNameChecking -function Output-List

                Highlight-Intent -Intent 'ファイル一覧出力シークエンス' -Suffix 'を開始します'
                Output-List -Target 'ファイル一覧'
            }

            '3' {
                Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath list.psm1) `
                    -DisableNameChecking -function Output-List

                Highlight-Intent -Intent '分類一覧出力シークエンス' -Suffix 'を開始します'
                Output-List -Target '分類一覧'
            }

            '4' {
                Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath propose.psm1) `
                    -DisableNameChecking -function Generate-Shortcut

                Highlight-Intent -Intent 'ショートカット出力シークエンス' -Suffix 'を開始します'
                Generate-Shortcut
            }

            'DELETE' {
                Import-Module -Name (Join-Path -Path $env:BG_lib -ChildPath propose.psm1) `
                    -DisableNameChecking -function Delete-File

                Highlight-Intent -Intent 'ファイル削除シークエンス' -Suffix 'を開始します'

                WarnLn 'ファイルの削除は関連法規に従って努めて慎重に行ってください'

                Delete-File
            }
        }

        Delimit 'タスクの終了'

        $intent = ReadLn '[Enter]→終了 [何か入力+Enter]→続行'
        if ($intent -eq '')
        {
            exit
        }
    }
}
catch
{
    $error_message = "`r`n$( $_.Exception ):`r`n$( $_.ScriptStackTrace )"
    Write-Host -ForegroundColor Red -BackgroundColor Black "${error_message}"
    Write-Host "`r`n先に進めないエラーが発生しました"
    Read-Host -Prompt "`r`n終了するにはEnterキーを押してください..."
}
