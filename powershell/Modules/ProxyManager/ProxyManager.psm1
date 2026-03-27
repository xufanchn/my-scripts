# 核心功能模块
$script:ProxyConfig = @{
    defaultProxy = "http://127.0.0.1:7897"
    line         = "  ────────────────────────────────────"
    colors       = @{
        success = 'Green'
        error   = 'Red'
        info    = 'Blue'
        border  = 'DarkGray'
    }
}

# 地址校验
function Test-ProxyUrl {
    param([string]$url)
    return ($url -match '^https?://[^:]+:\d+$') -or ($url -match '^[^:]+:\d+$')
}

# 输出结果
function Write-ProxyResult {
    param(
        [string]$type,
        [string]$message = "",
        [string]$url = ""
    )

    $colors = $script:ProxyConfig.colors
    $line = $script:ProxyConfig.line

    switch ($type) {
        "enable" {
            Write-Host "`n$line" -ForegroundColor $colors.border
            Write-Host "  🟢 代理已开启" -ForegroundColor $colors.success
            Write-Host "  🚀 $url" -ForegroundColor $colors.border
            Write-Host "$line" -ForegroundColor $colors.border
        }
        "disable" {
            Write-Host "`n$line" -ForegroundColor $colors.border
            Write-Host "  🔴 代理已关闭" -ForegroundColor $colors.error
            Write-Host "$line" -ForegroundColor $colors.border
        }
        "status" {
            Write-Host "`n$line" -ForegroundColor $colors.border
            if ($url) {
                Write-Host "  🌐 代理状态: 已开启" -ForegroundColor $colors.success
                Write-Host "  🚀 $url" -ForegroundColor $colors.border
            }
            else {
                Write-Host "  🌐 代理状态: 未开启" -ForegroundColor $colors.error
            }
            Write-Host "$line" -ForegroundColor $colors.border
        }
        "error" {
            Write-Host "`n$line" -ForegroundColor $colors.border
            Write-Host "  ❌ $message" -ForegroundColor $colors.error
            Write-Host "$line" -ForegroundColor $colors.border
        }
    }
}

# 开启代理
function Enable-Proxy {
    $colors = $script:ProxyConfig.colors
    $defaultProxy = $script:ProxyConfig.defaultProxy

    Write-Host "`n  🚀 配置代理" -ForegroundColor $colors.border
    $url = Read-Host "  💡 默认 $defaultProxy，或自定义地址"

    if (-not $url) {
        $url = $defaultProxy
    }
    else {
        if (-not (Test-ProxyUrl $url)) {
            Write-ProxyResult -type "error" -message "地址格式错误，示例: 127.0.0.1:7897 或 http://proxy.com:8080"
            return
        }
        if ($url -notmatch '^https?://') { $url = "http://$url" }
    }

    $Env:HTTP_PROXY = $url
    $Env:HTTPS_PROXY = $url
    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($url)
    Write-ProxyResult -type "enable" -url $url
}

# 关闭代理
function Disable-Proxy {
    $Env:HTTP_PROXY = $null
    $Env:HTTPS_PROXY = $null
    [System.Net.WebRequest]::DefaultWebProxy = $null
    Write-ProxyResult -type "disable"
}

# 查看状态
function Get-ProxyStatus {
    Write-ProxyResult -type "status" -url $env:HTTP_PROXY
}

# 主函数
function Set-Proxy {
    param([string]$opt = $null)

    $colors = $script:ProxyConfig.colors
    $line = $script:ProxyConfig.line

    # 带参数执行
    if ($opt -and $opt -match '^[123]$') {
        switch ($opt) {
            "1" { Enable-Proxy }
            "2" { Disable-Proxy }
            "3" { Get-ProxyStatus }
        }
        return
    }
    elseif ($opt) {
        Write-ProxyResult -type "error" -message "无效参数，请使用: Set-Proxy [1|2|3]"
        return
    }

    # 无参数显示菜单
    Clear-Host
    Write-Host ""
    Write-Host "$line" -ForegroundColor $colors.border
    Write-Host "          PowerShell 代理管理 >_"
    Write-Host "$line" -ForegroundColor $colors.border
    Write-Host "  1  →  🟢 开启代理" -ForegroundColor $colors.success
    Write-Host "  2  →  🔴 关闭代理" -ForegroundColor $colors.error
    Write-Host "  3  →  🌐 查看状态" -ForegroundColor $colors.info
    Write-Host "  0  →  👋 退出"
    Write-Host "$line" -ForegroundColor $colors.border
    Write-Host ""
    Write-Host "  👉 请选择..." -ForegroundColor $colors.border -NoNewline

    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $choice = $key.Character.ToString()
    Write-Host " $choice" -ForegroundColor $colors.border

    switch ($choice) {
        "1" { Enable-Proxy }
        "2" { Disable-Proxy }
        "3" { Get-ProxyStatus }
        "0" { return }
        default { Write-ProxyResult -type "error" -message "无效选择" }
    }
    Write-Host ""
}

# 快捷函数 - 使用函数包装，更稳定
function pxy { Set-Proxy @args }
function proxy { Set-Proxy @args }
function p1 { Enable-Proxy }
function p2 { Disable-Proxy }
function p3 { Get-ProxyStatus }
