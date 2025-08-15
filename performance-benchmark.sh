#!/bin/bash

# =============================================================================
# Performance Benchmark - Kotlin Coroutines vs Spring WebFlux vs Spring MVC
# Executa todos os perfis e gera relatório completo de performance
# =============================================================================

set -e  # Para no primeiro erro

# Cores para output - Paleta moderna e elegante
RED='\033[0;31m'           # Vermelho para erros
EMERALD='\033[38;5;46m'    # Verde esmeralda
AMBER='\033[38;5;214m'     # Âmbar
BLUE='\033[0;34m'          # Azul padrão
PURPLE='\033[0;35m'        # Roxo padrão
CYAN='\033[0;36m'          # Ciano padrão
SILVER='\033[38;5;245m'    # Prata para informações secundárias
LIME='\033[38;5;154m'      # Verde lima para sucessos
ORANGE='\033[38;5;208m'    # Laranja para warnings
TEAL='\033[38;5;30m'       # Verde azulado
NC='\033[0m'               # No Color

# Configurações (podem ser sobrescritas por variáveis de ambiente)
PORT=${PORT:-8080}
WARMUP_REQUESTS=${WARMUP_REQUESTS:-5}
TEST_REQUESTS=${TEST_REQUESTS:-20}
CONCURRENT_REQUESTS=${CONCURRENT_REQUESTS:-100}
RESULTS_FILE="performance-report-$(date +%Y%m%d-%H%M%S).txt"

echo -e "${BLUE}🚀 BENCHMARK DE PERFORMANCE - KOTLIN COROUTINES${NC}"
echo "=============================================================="
echo "📅 Data: $(date)"
echo "⚙️  Configuração:"
echo "   - Warmup requests: $WARMUP_REQUESTS"
echo "   - Test requests: $TEST_REQUESTS"
echo "   - Concurrent requests: $CONCURRENT_REQUESTS"
echo "   - Relatório será salvo em: $RESULTS_FILE"
echo ""

# Função para obter timestamp preciso (compatível com macOS e Linux)
get_timestamp_ms() {
    if [[ "$OSTYPE" == "darwin"* ]] && command -v gdate &> /dev/null; then
        # macOS com GNU coreutils
        gdate +%s%3N
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sem GNU coreutils - usar python como fallback
        python3 -c "import time; print(int(time.time() * 1000))"
    else
        # Linux
        date +%s%3N
    fi
}

# Verificar dependências
check_dependencies() {
    echo -e "${CYAN}🔍 Verificando dependências...${NC}"
    
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}❌ curl não encontrado${NC}"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo -e "${ORANGE}⚠️  jq não encontrado. Instalando...${NC}"
        if command -v brew &> /dev/null; then
            brew install jq
        else
            echo -e "${RED}❌ Por favor, instale jq manualmente${NC}"
            exit 1
        fi
    fi
    
    if ! command -v bc &> /dev/null; then
        echo -e "${ORANGE}⚠️  bc (calculadora) não encontrado. Instalando...${NC}"
        if command -v brew &> /dev/null; then
            brew install bc
        else
            echo -e "${RED}❌ Por favor, instale bc manualmente: brew install bc${NC}"
            exit 1
        fi
    fi
    
    # Verificar se temos gdate (GNU date) para timestamps precisos no macOS
    if [[ "$OSTYPE" == "darwin"* ]] && ! command -v gdate &> /dev/null; then
        echo -e "${ORANGE}⚠️  gdate não encontrado. Instalando coreutils para timestamps precisos...${NC}"
        if command -v brew &> /dev/null; then
            brew install coreutils
        else
            echo -e "${ORANGE}⚠️  Sem coreutils, usando Python para timestamps${NC}"
        fi
    fi
    
    echo -e "${EMERALD}✅ Dependências verificadas${NC}"
}

# Compilar projeto se necessário
build_project() {
    if [ ! -f "build/libs/kotlin-coroutines-sample-0.0.1-SNAPSHOT.jar" ]; then
        echo -e "${AMBER}🔨 Compilando projeto...${NC}"
        ./gradlew clean build -x test
        if [ $? -ne 0 ]; then
            echo -e "${RED}💥 Erro na compilação!${NC}"
            exit 1
        fi
        echo -e "${EMERALD}✅ Projeto compilado${NC}"
    else
        echo -e "${EMERALD}✅ JAR já existe${NC}"
    fi
}

# Aguardar aplicação estar pronta
wait_for_app() {
    local max_attempts=30
    local attempt=1
    
    echo -e "${SILVER}⏳ Aguardando aplicação inicializar...${NC}" >&2
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:$PORT/api/ > /dev/null 2>&1; then
            return 0
        fi
        echo -n "." >&2
        sleep 1
        ((attempt++))
    done
    
    echo -e "${RED}❌ Timeout aguardando aplicação${NC}" >&2
    return 1
}

# Fazer warmup da JVM
warmup_jvm() {
    local endpoint=$1
    echo -e "${ORANGE}🔥 Fazendo warmup da JVM...${NC}" >&2
    for i in $(seq 1 $WARMUP_REQUESTS); do
        curl -s "$endpoint" > /dev/null 2>&1 || true
        echo -n "." >&2
    done
    echo -e "${LIME} ✅ Warmup concluído${NC}" >&2
}

# Executar teste de performance
run_performance_test() {
    local test_name=$1
    local endpoint=$2
    local description=$3
    
    echo -e "${CYAN}🧪 Testando: $test_name${NC}" >&2
    echo "   Endpoint: $endpoint" >&2
    echo "   Descrição: $description" >&2
    
    # Fazer warmup primeiro
    warmup_jvm "$endpoint"
    
    # Arrays para armazenar resultados
    local times=()
    local thread_infos=()
    
    echo -e "${SILVER}📊 Executando $TEST_REQUESTS requisições...${NC}" >&2
    
    for i in $(seq 1 $TEST_REQUESTS); do
        local start_time=$(get_timestamp_ms)
        
        # Fazer a requisição e capturar resposta
        local response=$(curl -s "$endpoint" 2>/dev/null)
        
        local end_time=$(get_timestamp_ms)
        local total_time=$((end_time - start_time))
        
        # Verificar se temos resposta válida
        if [ ! -z "$response" ]; then
            # Extrair informações da resposta se possível
            local thread_info=$(echo "$response" | jq -r '.threadInfo // .initialThreadInfo // "N/A"' 2>/dev/null || echo "N/A")
            
            times+=($total_time)
            thread_infos+=("$thread_info")
        else
            echo -n "E" >&2 # Erro
            times+=(0)
            thread_infos+=("ERROR")
        fi
        
        echo -n "." >&2
    done
    
    echo "" >&2
    
    # Calcular estatísticas
    local sum=0
    local min=999999
    local max=0
    local valid_count=0
    
    for time in "${times[@]}"; do
        if [ "$time" -gt 0 ] 2>/dev/null; then
            sum=$((sum + time))
            if [ $time -lt $min ]; then min=$time; fi
            if [ $time -gt $max ]; then max=$time; fi
            ((valid_count++))
        fi
    done
    
    if [ $valid_count -eq 0 ]; then
        echo -e "${RED}❌ Nenhum tempo válido coletado${NC}" >&2
        echo "0:0:0:0:ERROR"
        return
    fi
    
    local avg=$((sum / valid_count))
    
    # Salvar resultados
    echo "----------------------------------------" >> "$RESULTS_FILE"
    echo "TESTE: $test_name" >> "$RESULTS_FILE"
    echo "Endpoint: $endpoint" >> "$RESULTS_FILE"
    echo "Descrição: $description" >> "$RESULTS_FILE"
    echo "Data/Hora: $(date)" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "RESULTADOS:" >> "$RESULTS_FILE"
    echo "- Requisições válidas: $valid_count/${#times[@]}" >> "$RESULTS_FILE"
    echo "- Tempo médio: ${avg}ms" >> "$RESULTS_FILE"
    echo "- Tempo mínimo: ${min}ms" >> "$RESULTS_FILE"
    echo "- Tempo máximo: ${max}ms" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    # Mostrar resumo na tela
    echo -e "${LIME}📈 Resultados:${NC}" >&2
    echo "   • Requisições válidas: $valid_count/${#times[@]}" >&2
    echo "   • Tempo médio: ${avg}ms" >&2
    echo "   • Tempo mínimo: ${min}ms" >&2
    echo "   • Tempo máximo: ${max}ms" >&2
    echo "   • Thread info (primeira req): ${thread_infos[0]}" >&2
    echo "" >&2
    
    # Retornar valores para comparação global
    echo "$avg:$min:$max:$valid_count:${thread_infos[0]}"
}

# Teste de carga concorrente
run_concurrent_test() {
    local test_name=$1
    local endpoint=$2
    
    echo -e "${PURPLE}⚡ Teste de Carga Concorrente: $test_name${NC}" >&2
    echo "   Endpoint: $endpoint" >&2
    echo "   Requisições simultâneas: $CONCURRENT_REQUESTS" >&2
    
    local start_time=$(get_timestamp_ms)
    
    # Executar requisições em paralelo
    for i in $(seq 1 $CONCURRENT_REQUESTS); do
        curl -s "$endpoint" > /dev/null 2>&1 &
    done
    
    # Aguardar todas as requisições terminarem
    wait
    
    local end_time=$(get_timestamp_ms)
    local total_time=$((end_time - start_time))
    
    echo -e "${TEAL}📊 Teste de carga concluído em: ${total_time}ms${NC}" >&2
    
    if [ "$total_time" -gt 0 ]; then
        local rps=$(echo "scale=2; $CONCURRENT_REQUESTS * 1000 / $total_time" | bc 2>/dev/null || echo "N/A")
        echo "   • Requisições por segundo: $rps" >&2
    else
        echo "   • Requisições por segundo: N/A (tempo inválido)" >&2
        local rps="N/A"
    fi
    
    # Salvar no relatório
    echo "TESTE DE CARGA CONCORRENTE: $test_name" >> "$RESULTS_FILE"
    echo "- Requisições simultâneas: $CONCURRENT_REQUESTS" >> "$RESULTS_FILE"
    echo "- Tempo total: ${total_time}ms" >> "$RESULTS_FILE"
    echo "- Requisições por segundo: $rps" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    echo "$total_time"
}

# Iniciar aplicação
start_application() {
    echo -e "${BLUE}🚀 Iniciando aplicação Kotlin Coroutines${NC}" >&2
    
    # Matar processos existentes
    pkill -f "kotlin-coroutines-sample" 2>/dev/null || true
    sleep 2
    
    # Iniciar nova aplicação
    java -jar build/libs/kotlin-coroutines-sample-0.0.1-SNAPSHOT.jar \
        --server.port=$PORT \
        --logging.level.root=WARN \
        > /tmp/app-kotlin-coroutines.log 2>&1 &
    
    local pid=$!
    echo "   PID: $pid" >&2
    
    if ! wait_for_app; then
        echo -e "${RED}❌ Falha ao iniciar aplicação${NC}" >&2
        kill $pid 2>/dev/null || true
        return 1
    fi
    
    return 0
}

# Parar aplicação
stop_application() {
    echo -e "${ORANGE}🛑 Parando aplicação...${NC}" >&2
    pkill -f "kotlin-coroutines-sample" 2>/dev/null || true
    sleep 2
    echo -e "${EMERALD}✅ Aplicação parada${NC}" >&2
}

# Gerar análise comparativa detalhada
generate_detailed_analysis() {
    local temp_dir="$1"
    echo ""
    echo -e "${EMERALD}📊 GERANDO ANÁLISE COMPARATIVA DETALHADA${NC}"
    echo "=============================================================="
    
    echo "" >> "$RESULTS_FILE"
    echo "=============================================================" >> "$RESULTS_FILE"
    echo "ANÁLISE COMPARATIVA DETALHADA" >> "$RESULTS_FILE"
    echo "=============================================================" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    # Analisar resultados de performance
    echo "🚀 ANÁLISE DE PERFORMANCE (Tempo de Resposta)" >> "$RESULTS_FILE"
    echo "-------------------------------------------------------------" >> "$RESULTS_FILE"
    
    local best_avg=999999
    local best_approach=""
    local worst_avg=0
    local worst_approach=""
    
    # Ler resultados dos arquivos temporários
    for file in "$temp_dir"/*; do
        if [ -f "$file" ] && [[ ! "$(basename "$file")" == concurrent_* ]]; then
            local approach=$(basename "$file")
            local result=$(cat "$file")
            
            if [ "$result" != "0:0:0:0:ERROR" ]; then
                local avg=$(echo "$result" | cut -d: -f1)
                local min=$(echo "$result" | cut -d: -f2)
                local max=$(echo "$result" | cut -d: -f3)
                local valid=$(echo "$result" | cut -d: -f4)
                
                if [ "$avg" -gt 0 ] 2>/dev/null; then
                    echo "• $approach: ${avg}ms médio (min: ${min}ms, max: ${max}ms)" >> "$RESULTS_FILE"
                    
                    if [ "$avg" -lt "$best_avg" ]; then
                        best_avg=$avg
                        best_approach=$approach
                    fi
                    
                    if [ "$avg" -gt "$worst_avg" ]; then
                        worst_avg=$avg
                        worst_approach=$approach
                    fi
                fi
            fi
        fi
    done
    
    echo "" >> "$RESULTS_FILE"
    echo "🏆 VENCEDOR EM PERFORMANCE: $best_approach (${best_avg}ms)" >> "$RESULTS_FILE"
    echo "🐌 MAIS LENTO: $worst_approach (${worst_avg}ms)" >> "$RESULTS_FILE"
    
    # Calcular diferença percentual
    if [ "$best_avg" -gt 0 ] && [ "$worst_avg" -gt 0 ]; then
        local improvement=$(echo "scale=1; ($worst_avg - $best_avg) * 100 / $worst_avg" | bc 2>/dev/null || echo "N/A")
        echo "📈 MELHORIA: ${improvement}% mais rápido que a abordagem mais lenta" >> "$RESULTS_FILE"
    fi
    
    echo "" >> "$RESULTS_FILE"
    
    # Analisar resultados de carga concorrente
    echo "⚡ ANÁLISE DE CARGA CONCORRENTE" >> "$RESULTS_FILE"
    echo "-------------------------------------------------------------" >> "$RESULTS_FILE"
    
    local best_concurrent=999999
    local best_concurrent_approach=""
    local worst_concurrent=0
    local worst_concurrent_approach=""
    
    for file in "$temp_dir"/concurrent_*; do
        if [ -f "$file" ]; then
            local approach=$(basename "$file" | sed 's/concurrent_//')
            local time=$(cat "$file")
            
            if [ "$time" -gt 0 ] 2>/dev/null; then
                local rps=$(echo "scale=2; $CONCURRENT_REQUESTS * 1000 / $time" | bc 2>/dev/null || echo "N/A")
                echo "• $approach: ${time}ms total (${rps} req/s)" >> "$RESULTS_FILE"
                
                if [ "$time" -lt "$best_concurrent" ]; then
                    best_concurrent=$time
                    best_concurrent_approach=$approach
                fi
                
                if [ "$time" -gt "$worst_concurrent" ]; then
                    worst_concurrent=$time
                    worst_concurrent_approach=$approach
                fi
            fi
        fi
    done
    
    echo "" >> "$RESULTS_FILE"
    echo "🏆 MELHOR EM CARGA: $best_concurrent_approach (${best_concurrent}ms)" >> "$RESULTS_FILE"
    echo "🐌 PIOR EM CARGA: $worst_concurrent_approach (${worst_concurrent}ms)" >> "$RESULTS_FILE"
    
    echo "" >> "$RESULTS_FILE"
    
    # Análise técnica e recomendações
    echo "🎯 ANÁLISE TÉCNICA E RECOMENDAÇÕES" >> "$RESULTS_FILE"
    echo "=============================================================" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    echo "📋 CARACTERÍSTICAS DE CADA ABORDAGEM:" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    echo "1. SPRING MVC BLOCKING:" >> "$RESULTS_FILE"
    echo "   ✅ Simplicidade de implementação" >> "$RESULTS_FILE"
    echo "   ✅ Familiar para a maioria dos desenvolvedores" >> "$RESULTS_FILE"
    echo "   ❌ Bloqueia threads durante I/O" >> "$RESULTS_FILE"
    echo "   ❌ Baixa escalabilidade com alta concorrência" >> "$RESULTS_FILE"
    echo "   💡 USAR QUANDO: Aplicações com baixa concorrência" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    echo "2. SPRING MVC COM COROUTINES:" >> "$RESULTS_FILE"
    echo "   ✅ Sintaxe simples e familiar" >> "$RESULTS_FILE"
    echo "   ✅ Não bloqueia threads durante suspensão" >> "$RESULTS_FILE"
    echo "   ✅ Boa escalabilidade" >> "$RESULTS_FILE"
    echo "   ⚠️  Requer runBlocking para integração com MVC" >> "$RESULTS_FILE"
    echo "   💡 USAR QUANDO: Migração gradual para programação assíncrona" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    echo "3. SPRING WEBFLUX:" >> "$RESULTS_FILE"
    echo "   ✅ Totalmente não-bloqueante" >> "$RESULTS_FILE"
    echo "   ✅ Excelente para alta concorrência" >> "$RESULTS_FILE"
    echo "   ✅ Suporte nativo para streams" >> "$RESULTS_FILE"
    echo "   ❌ Curva de aprendizado mais íngreme" >> "$RESULTS_FILE"
    echo "   💡 USAR QUANDO: Alta concorrência, APIs reativas" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    echo "4. WEBFLUX COM COROUTINES:" >> "$RESULTS_FILE"
    echo "   ✅ Combina benefícios do WebFlux com sintaxe simples" >> "$RESULTS_FILE"
    echo "   ✅ Melhor experiência de desenvolvimento" >> "$RESULTS_FILE"
    echo "   ✅ Performance excelente" >> "$RESULTS_FILE"
    echo "   🎯 RECOMENDAÇÃO PRINCIPAL para novos projetos" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    # Recomendação final baseada nos resultados
    echo "🏆 RECOMENDAÇÃO FINAL" >> "$RESULTS_FILE"
    echo "=============================================================" >> "$RESULTS_FILE"
    
    if [[ "$best_approach" == *"webflux"* ]]; then
        echo "🎯 SPRING WEBFLUX COM COROUTINES é a MELHOR ESCOLHA!" >> "$RESULTS_FILE"
        echo "" >> "$RESULTS_FILE"
        echo "JUSTIFICATIVA:" >> "$RESULTS_FILE"
        echo "• Melhor performance nos testes (${best_avg}ms)" >> "$RESULTS_FILE"
        echo "• Excelente escalabilidade" >> "$RESULTS_FILE"
        echo "• Sintaxe clara com Coroutines" >> "$RESULTS_FILE"
        echo "• Totalmente não-bloqueante" >> "$RESULTS_FILE"
    elif [[ "$best_approach" == *"coroutines"* ]]; then
        echo "🎯 KOTLIN COROUTINES é a MELHOR ESCOLHA!" >> "$RESULTS_FILE"
        echo "" >> "$RESULTS_FILE"
        echo "JUSTIFICATIVA:" >> "$RESULTS_FILE"
        echo "• Melhor performance nos testes (${best_avg}ms)" >> "$RESULTS_FILE"
        echo "• Sintaxe simples e intuitiva" >> "$RESULTS_FILE"
        echo "• Boa escalabilidade" >> "$RESULTS_FILE"
        echo "• Facilita migração de código blocking" >> "$RESULTS_FILE"
    else
        echo "🎯 ANÁLISE BASEADA NOS RESULTADOS:" >> "$RESULTS_FILE"
        echo "" >> "$RESULTS_FILE"
        echo "• Melhor performance: $best_approach (${best_avg}ms)" >> "$RESULTS_FILE"
        echo "• Para aplicações de alta concorrência: WebFlux + Coroutines" >> "$RESULTS_FILE"
        echo "• Para projetos existentes: MVC + Coroutines" >> "$RESULTS_FILE"
        echo "• Para simplicidade: MVC Blocking (apenas baixa concorrência)" >> "$RESULTS_FILE"
    fi
    
    echo "" >> "$RESULTS_FILE"
    echo "📊 CENÁRIOS DE USO RECOMENDADOS:" >> "$RESULTS_FILE"
    echo "• 🚀 APIs de alta performance: WebFlux + Coroutines" >> "$RESULTS_FILE"
    echo "• 🔄 Migração de projetos legados: MVC + Coroutines" >> "$RESULTS_FILE"
    echo "• 🎯 Novos microserviços: WebFlux + Coroutines" >> "$RESULTS_FILE"
    echo "• 📱 Aplicações com muitas chamadas externas: Coroutines" >> "$RESULTS_FILE"
    echo "• 🏢 Sistemas corporativos tradicionais: MVC + Coroutines" >> "$RESULTS_FILE"
    
    echo "" >> "$RESULTS_FILE"
    echo "=============================================================" >> "$RESULTS_FILE"
    echo "📝 RELATÓRIO GERADO EM: $(date)" >> "$RESULTS_FILE"
    echo "🔧 FERRAMENTA: Kotlin Coroutines Performance Benchmark" >> "$RESULTS_FILE"
    echo "=============================================================" >> "$RESULTS_FILE"
    
    # Mostrar resumo na tela
    echo ""
    echo -e "${EMERALD}📊 RESUMO COMPARATIVO${NC}"
    echo "=============================================================="
    echo -e "${LIME}🏆 Melhor Performance: $best_approach (${best_avg}ms)${NC}"
    echo -e "${ORANGE}🐌 Mais Lento: $worst_approach (${worst_avg}ms)${NC}"
    echo -e "${CYAN}⚡ Melhor em Carga: $best_concurrent_approach (${best_concurrent}ms)${NC}"
    echo ""
    echo -e "${PURPLE}🎯 RECOMENDAÇÃO: Spring WebFlux com Kotlin Coroutines${NC}"
    echo -e "${SILVER}   para novos projetos de alta performance${NC}"
    echo ""
    echo -e "${EMERALD}✨ ANÁLISE COMPLETA DISPONÍVEL NO RELATÓRIO!${NC}"
    echo -e "${CYAN}📄 Arquivo: $RESULTS_FILE${NC}"
}

# Executar todos os testes
run_all_tests() {
    echo -e "${BLUE}🎯 EXECUTANDO TODOS OS TESTES${NC}"
    echo "=============================================================="
    
    # Inicializar arquivo de relatório
    echo "RELATÓRIO DE PERFORMANCE - KOTLIN COROUTINES" > "$RESULTS_FILE"
    echo "=============================================================" >> "$RESULTS_FILE"
    echo "Data/Hora: $(date)" >> "$RESULTS_FILE"
    echo "Configuração:" >> "$RESULTS_FILE"
    echo "- Warmup requests: $WARMUP_REQUESTS" >> "$RESULTS_FILE"
    echo "- Test requests: $TEST_REQUESTS" >> "$RESULTS_FILE"
    echo "- Concurrent requests: $CONCURRENT_REQUESTS" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    
    # Arrays para armazenar resultados para comparação (usando arquivos temporários)
    local temp_dir="/tmp/benchmark-$$"
    mkdir -p "$temp_dir"
    
    if start_application; then
        echo ""
        echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${BLUE}🧪 TESTANDO ENDPOINTS${NC}"
        echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
        echo ""
        
        # Teste 1: Spring MVC Blocking
        result1=$(run_performance_test \
            "Spring MVC Blocking" \
            "http://localhost:$PORT/api/mvc/persons/blocking?count=10" \
            "Spring MVC tradicional com blocking I/O")
        echo "$result1" > "$temp_dir/mvc_blocking"
        
        # Teste 2: Spring MVC com Coroutines
        result2=$(run_performance_test \
            "Spring MVC com Coroutines" \
            "http://localhost:$PORT/api/mvc/persons/async?count=10" \
            "Spring MVC com Kotlin Coroutines")
        echo "$result2" > "$temp_dir/mvc_coroutines"
        
        # Teste 3: WebFlux List (com Coroutines)
        result3=$(run_performance_test \
            "WebFlux List" \
            "http://localhost:$PORT/api/webflux/persons/list?count=10" \
            "Spring WebFlux list com Coroutines")
        echo "$result3" > "$temp_dir/webflux_list"
        
        # Teste 4: WebFlux Parallel (com Coroutines)
        result4=$(run_performance_test \
            "WebFlux Parallel" \
            "http://localhost:$PORT/api/webflux/persons/parallel?batches=2&countPerBatch=5" \
            "Spring WebFlux parallel com Kotlin Coroutines")
        echo "$result4" > "$temp_dir/webflux_parallel"
        
        # Teste 5: Benchmark Coroutines vs Blocking
        result5=$(run_performance_test \
            "Benchmark Coroutines vs Blocking" \
            "http://localhost:$PORT/api/benchmark/coroutines-vs-blocking?count=20" \
            "Benchmark direto Coroutines vs Blocking")
        echo "$result5" > "$temp_dir/benchmark_coroutines"
        
        # Teste 6: Benchmark WebFlux vs MVC
        result6=$(run_performance_test \
            "Benchmark WebFlux vs MVC" \
            "http://localhost:$PORT/api/benchmark/webflux-vs-mvc?count=20" \
            "Benchmark WebFlux vs MVC com Coroutines")
        echo "$result6" > "$temp_dir/benchmark_webflux_mvc"
        
        echo ""
        echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${PURPLE}⚡ TESTES DE CARGA CONCORRENTE${NC}"
        echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
        echo ""
        
        # Testes de carga
        concurrent1=$(run_concurrent_test \
            "MVC Blocking Concorrente" \
            "http://localhost:$PORT/api/mvc/persons/blocking?count=5")
        echo "$concurrent1" > "$temp_dir/concurrent_mvc_blocking"
        
        concurrent2=$(run_concurrent_test \
            "MVC Coroutines Concorrente" \
            "http://localhost:$PORT/api/mvc/persons/async?count=5")
        echo "$concurrent2" > "$temp_dir/concurrent_mvc_coroutines"
        
        concurrent3=$(run_concurrent_test \
            "WebFlux List Concorrente" \
            "http://localhost:$PORT/api/webflux/persons/list?count=5")
        echo "$concurrent3" > "$temp_dir/concurrent_webflux_list"
        
        concurrent4=$(run_concurrent_test \
            "WebFlux Parallel Concorrente" \
            "http://localhost:$PORT/api/webflux/persons/parallel?batches=2&countPerBatch=3")
        echo "$concurrent4" > "$temp_dir/concurrent_webflux_parallel"
        
        stop_application
        
        # Gerar análise comparativa detalhada
        generate_detailed_analysis "$temp_dir"
        
        # Limpar arquivos temporários
        rm -rf "$temp_dir"
        
        echo ""
        echo -e "${EMERALD}✨ BENCHMARK CONCLUÍDO!${NC}"
        echo -e "${CYAN}📄 Relatório completo salvo em: $RESULTS_FILE${NC}"
    else
        echo -e "${RED}❌ Falha ao iniciar aplicação${NC}"
        return 1
    fi
}

# Função de teste rápido
quick_test() {
    echo -e "${CYAN}🧪 Teste Rápido de Funcionalidade${NC}"
    
    check_dependencies
    build_project
    
    # Reduzir configurações para teste rápido
    WARMUP_REQUESTS=2
    TEST_REQUESTS=5
    CONCURRENT_REQUESTS=10
    
    if start_application; then
        run_performance_test \
            "MVC Quick Test" \
            "http://localhost:$PORT/api/mvc/persons/blocking?count=5" \
            "Teste rápido do MVC blocking"
        
        stop_application
        echo -e "${EMERALD}✅ Teste rápido concluído com sucesso!${NC}"
    else
        echo -e "${RED}❌ Falha no teste rápido${NC}"
        return 1
    fi
}

# Script principal
main() {
    case "${1:-all}" in
        "quick")
            quick_test
            ;;
        "simple")
            check_dependencies
            build_project
            run_all_tests
            ;;
        "all"|"")
            check_dependencies
            build_project
            run_all_tests
            ;;
        *)
            echo "Uso: $0 [quick|simple|all]"
            echo "  quick  - Teste rápido de funcionalidade"
            echo "  simple - Todos os testes (padrão)"
            echo "  all    - Todos os testes (padrão)"
            exit 1
            ;;
    esac
}

# Executar função principal
main "$@"
