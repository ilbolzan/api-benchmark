#!/bin/bash

# Lista de APIs
APIS=(
  "spring-boot"
  "go"
  "quarkus"
  "webflux"
  "rust"
)

# URLs das APIs
URLS=(
  "http://localhost:8080/api/hello"
  "http://localhost:8080/api/hello"
  "http://localhost:8080/api/hello"
  "http://localhost:8080/api/hello"
  "http://localhost:8080/api/hello"
)

# Comandos de inicialização
START_COMMANDS=(
  "cd ../apis/spring-boot && mvn spring-boot:run &"
  "cd ../apis/go && go run main.go &"
  "cd ../apis/quarkus && mvn quarkus:dev &"
  "cd ../apis/webflux && mvn spring-boot:run &"
  "cd ../apis/rust && cargo run &"
)

# Função para verificar se uma porta está em uso
check_port() {
  local port=$1
  lsof -i :$port > /dev/null 2>&1
  return $?
}

# Função para esperar a API ficar disponível
wait_for_api() {
  local url=$1
  local max_attempts=5
  local attempt=1

  echo "⏳ Aguardando API ficar disponível em $url..."
  
  while [ $attempt -le $max_attempts ]; do
    # Tenta fazer uma requisição HTTP e captura o código de status
    response=$(curl -s -w "%{http_code}" -o /dev/null $url)
    curl_exit_code=$?
    
    # Verifica se o curl foi bem sucedido e se o status code é 200
    if [ $curl_exit_code -eq 0 ] && [ $response -eq 200 ]; then
      echo "✅ API está disponível! Status code: $response"
      return 0
    fi
    
    # Se o curl falhou, mostra o erro específico
    if [ $curl_exit_code -ne 0 ]; then
      echo "❌ Erro ao tentar conectar (tentativa $attempt de $max_attempts)"
      case $curl_exit_code in
        7)
          echo "   ❌ Código 7: Falha ao conectar ao host"
          echo "   Possíveis causas:"
          echo "   - Aplicação ainda não iniciou"
          echo "   - Porta não está aberta"
          echo "   - Aplicação não está escutando na porta correta"
          ;;
        6)
          echo "   ❌ Código 6: Não foi possível resolver o host"
          ;;
        28)
          echo "   ❌ Código 28: Timeout da operação"
          ;;
        *)
          echo "   ❌ Código de erro desconhecido: $curl_exit_code"
          ;;
      esac
      
      echo "   Verificando se a porta está em uso..."
      port=${url#*:}
      port=${port%/*}
      if check_port $port; then
        echo "   ✅ Porta $port está em uso"
      else
        echo "   ❌ Porta $port não está em uso"
      fi
    else
      echo "⚠️ API retornou status code: $response (tentativa $attempt de $max_attempts)"
    fi
    
    sleep 2
    attempt=$((attempt + 1))
  done

  echo "❌ Timeout: API não ficou disponível após $max_attempts tentativas"
  echo "   Último status code: $response"
  echo "   Último código de saída do curl: $curl_exit_code"
  return 1
}

# Função para parar uma aplicação
stop_app() {
  local pid=$(lsof -ti :8080)
  
  if [ ! -z "$pid" ]; then
    echo "🛑 Parando aplicação na porta 8080 (PID: $pid)"
    kill $pid
    sleep 2
  fi
}

# Função para executar o teste de uma API
run_benchmark() {
  local index=$1
  local api_name=${APIS[$index]}
  local api_url=${URLS[$index]}
  local start_command=${START_COMMANDS[$index]}
  local port=8080
  
  echo "🚀 Iniciando teste da API: $api_name"
  echo "📡 URL: $api_url"
  
  # Verifica se a porta está disponível
  if check_port $port; then
    echo "❌ Porta $port já está em uso. Parando aplicação..."
    stop_app
  fi
  
  # Inicia a aplicação
  echo "⚡ Iniciando aplicação $api_name..."
  echo "Comando: $start_command"
  eval "$start_command"
  
  # Espera a API ficar disponível
  if ! wait_for_api $api_url; then
    echo "❌ Falha ao iniciar a API $api_name"
    return 1
  fi
  
  # Executa o teste
  echo "📊 Executando teste de carga..."
  K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_EXPORT=${api_name}-html-report.html k6 run \
    -e API_URL="$api_url" \
    -e API_NAME="$api_name" \
    benchmark.js
  
  # Para a aplicação
  echo "🛑 Parando aplicação $api_name..."
  stop_app
  
  echo "✅ Teste da API $api_name concluído"
  echo "----------------------------------------"
}

# Função para limpar processos pendentes
cleanup() {
  echo "🧹 Limpando processos pendentes..."
  stop_app
}

# Registra o handler para limpeza ao receber SIGINT
trap cleanup SIGINT

# Função para mostrar ajuda
show_help() {
  echo "Uso: $0 [opção]"
  echo ""
  echo "Opções:"
  echo "  -h, --help     Mostra esta ajuda"
  echo "  -l, --list     Lista todas as APIs disponíveis"
  echo "  -a, --all      Executa todos os testes (padrão)"
  echo "  <api-name>     Executa o teste apenas para a API especificada"
  echo ""
  echo "Exemplos:"
  echo "  $0                  # Executa todos os testes"
  echo "  $0 spring-boot      # Executa apenas o teste do Spring Boot"
  echo "  $0 go               # Executa apenas o teste do Go"
  echo "  $0 -l               # Lista todas as APIs disponíveis"
}

# Função para listar todas as APIs disponíveis
list_apis() {
  echo "APIs disponíveis para teste:"
  for i in "${!APIS[@]}"; do
    echo "  ${APIS[$i]}"
  done
}

# Verifica se foi passado algum parâmetro
if [ $# -eq 0 ]; then
  # Nenhum parâmetro, executa todos os testes
  echo "Executando todos os testes..."
  for i in "${!APIS[@]}"; do
    run_benchmark $i
    sleep 2
  done
else
  # Verifica o parâmetro passado
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -l|--list)
      list_apis
      exit 0
      ;;
    -a|--all)
      echo "Executando todos os testes..."
      for i in "${!APIS[@]}"; do
        run_benchmark $i
      done
      ;;
    *)
      # Procura a API especificada
      api_found=false
      for i in "${!APIS[@]}"; do
        if [ "${APIS[$i]}" = "$1" ]; then
          echo "Executando teste apenas para a API: $1"
          run_benchmark $i
          api_found=true
          break
        fi
      done
      
      # Se a API não foi encontrada, mostra erro
      if [ "$api_found" = false ]; then
        echo "❌ Erro: API '$1' não encontrada."
        echo ""
        list_apis
        exit 1
      fi
      ;;
  esac
fi

echo "🎉 Todos os testes foram concluídos!"
echo "📊 Relatórios gerados:"
ls -1 summary-*.json 2>/dev/null || echo "Nenhum relatório encontrado." 