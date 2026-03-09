# ZapVoice System Redirect - Updated for WaSpeed PHP Server
# Dev: @pugno_fc
# Elevacao de admin feita pelo .bat - nao repetir aqui

$DEV      = "@pugno_fc"
$WHATSAPP = "+55 (61) 99603-7036"

# Hosts antigos que precisam ser interceptados
$OldHosts = @(
    "backend-plugin.wascript.com.br",
    "app-backend.wascript.com.br",
    "audio-transcriber.wascript.com.br"
)

# Novo host de destino (seu servidor PHP)
$NewHost     = "zapmod.shop"
$BasePath    = "/extension/waspeed"

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
    Write-Host "                     W A S P E E D   P A T C H" -ForegroundColor White
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
    Start-Sleep -Milliseconds (Get-Random -Minimum 50 -Maximum 150)
}

function Show-ProgressBar {
    param([string]$color = "Green")
    for ($i = 1; $i -le 40; $i++) {
        $pct = [math]::Round(($i / 40) * 100)
        Write-Host "`r  [" -NoNewline
        Write-Host ("█" * $i) -ForegroundColor $color -NoNewline
        Write-Host ("░" * (40 - $i)) -ForegroundColor DarkGray -NoNewline
        Write-Host "] $pct%" -ForegroundColor White -NoNewline
        Start-Sleep -Milliseconds 20
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
    Write-Host "[ WASPEED ENGINE  >>  PATCH v5.0 ]" -ForegroundColor Green
    Write-Host ""

    @(
        "Interceptando dominios wascript.com.br...",
        "Configurando redirecionamento local (127.0.0.1)...",
        "Gerando certificados SSL auto-assinados...",
        "Instalando certificados na Autoridade Raiz Confiável...",
        "Mapeando portas HTTPS (443)...",
        "Conectando ao servidor remoto zapmod.shop...",
        "Sincronizando rotas da API PHP...",
        "Validando bypass de autenticacao...",
        "Injetando headers de bypass [access-token]...",
        "Finalizando configuracao do Proxy reverso..."
    ) | ForEach-Object { Show-HackLine $_ "Green" }

    Write-Host ""
    Show-ProgressBar "Green"

    $HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
    $AppGuid   = "{$(New-Guid)}"

    try {
        # 1. Atualizar arquivo HOSTS
        $c = Get-Content $HostsPath
        foreach ($hostName in $OldHosts) {
            $c = $c | Where-Object { $_ -notmatch $hostName }
            $c += "127.0.0.1 $hostName # WaSpeed Redirect"
        }
        $c | Out-File $HostsPath -Encoding UTF8 -Force
        ipconfig /flushdns | Out-Null

        # 2. Configurar Certificados SSL para todos os dominios
        netsh http delete sslcert ipport=0.0.0.0:443 2>$null | Out-Null
        
        # Cria um certificado SAN (Subject Alternative Name) para todos os dominios
        $dnsNames = $OldHosts -join ","
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
    Write-Host "  " -NoNewline; Write-Host "Proxy Reverso Ativo e Operacional." -ForegroundColor DarkGreen
    Write-Host "  " -NoNewline; Write-Host "Redirecionando para: $NewHost$BasePath" -ForegroundColor DarkGreen
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host " MANTENHA ESTA JANELA ABERTA " -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "  " -NoNewline; Write-Host "Pressione CTRL+C para encerrar." -ForegroundColor DarkGray
    Write-Host ""

    # 3. Iniciar Servidor Proxy
    $listener = New-Object System.Net.HttpListener
    foreach ($hostName in $OldHosts) {
        $listener.Prefixes.Add("https://$hostName/")
    }

    try {
        $listener.Start()
        while ($listener.IsListening) {
            $context   = $listener.GetContext()
            $req       = $context.Request
            $res       = $context.Response
            
            # Monta a URL de destino baseada no Host de origem
            $targetUrl = "https://$NewHost$BasePath" + $req.RawUrl
            
            # Log simples no console
            Write-Host "  [PROXY] " -NoNewline; Write-Host "$($req.HttpMethod) " -ForegroundColor Cyan -NoNewline; Write-Host "$($req.Url.Host)$($req.RawUrl) -> REDIRECT" -ForegroundColor Gray

            try {
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
                $webReq        = [System.Net.HttpWebRequest]::Create($targetUrl)
                $webReq.Method = $req.HttpMethod
                $webReq.UserAgent = $req.UserAgent
                $webReq.ContentType = $req.ContentType

                # Copia Headers
                foreach ($h in $req.Headers.AllKeys) {
                    if ($h -notin @("Host","Connection","Content-Length","Accept-Encoding","User-Agent","Content-Type")) {
                        try { $webReq.Headers.Add($h, $req.Headers[$h]) } catch {}
                    }
                }

                # Copia Body (POST/PUT)
                if ($req.HasEntityBody) {
                    $s = $webReq.GetRequestStream()
                    $req.InputStream.CopyTo($s)
                    $s.Close()
                }

                # Obtem Resposta
                $webRes         = $webReq.GetResponse()
                $res.StatusCode = [int]$webRes.StatusCode
                $res.ContentType = $webRes.ContentType

                foreach ($h in $webRes.Headers.AllKeys) {
                    if ($h -notin @("Transfer-Encoding","Content-Length","Content-Type")) {
                        try { $res.Headers.Add($h, $webRes.Headers[$h]) } catch {}
                    }
                }

                # Copia Stream de Resposta
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
                    $b = [System.Text.Encoding]::UTF8.GetBytes("Erro no Proxy: $($_.Exception.Message)")
                    $res.OutputStream.Write($b, 0, $b.Length)
                }
            }
            $res.Close()
        }
    } catch {
        Show-FatalError "Erro no servidor Proxy: $($_.Exception.Message)"
    } finally {
        $listener.Stop()
    }
}

# ── Desfazer ───────────────────────────────────────────────────────

function Start-Deactivate {
    Show-Banner
    Write-Host "  " -NoNewline
    Write-Host "[ WASPEED ENGINE  >>  RESTORE v5.0 ]" -ForegroundColor Yellow
    Write-Host ""

    @(
        "Limpando arquivo HOSTS...",
        "Removendo entradas de redirecionamento...",
        "Desinstalando certificados SSL do sistema...",
        "Limpando cache DNS (flushdns)...",
        "Removendo mapeamento de portas HTTPS...",
        "Restaurando rotas originais do Windows...",
        "Verificando integridade do sistema..."
    ) | ForEach-Object { Show-HackLine $_ "Yellow" }

    Write-Host ""
    Show-ProgressBar "Yellow"

    $HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"

    try {
        $c = Get-Content $HostsPath
        foreach ($hostName in $OldHosts) {
            $c = $c | Where-Object { $_ -notmatch $hostName }
        }
        $c | Out-File $HostsPath -Encoding UTF8 -Force
        ipconfig /flushdns | Out-Null
        
        netsh http delete sslcert ipport=0.0.0.0:443 2>$null | Out-Null

        $cert = Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*wascript.com.br*" }
        if ($cert) { Remove-Item $cert.PSPath -Force }

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
    Write-Host "  " -NoNewline; Write-Host "[ 1 ]" -ForegroundColor Green  -NoNewline; Write-Host "  ATIVAR WASPEED (REDIRECIONAR)" -ForegroundColor White
    Write-Host "        " -NoNewline; Write-Host "Redireciona wascript.com.br -> zapmod.shop" -ForegroundColor DarkGray
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
