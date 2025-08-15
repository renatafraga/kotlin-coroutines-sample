# 📚 Exemplos de Uso - Kotlin Coroutines API

## 🚀 Exemplos Práticos

### 1. Teste Básico de Endpoints

```bash
# Verificar se a aplicação está rodando
curl http://localhost:8080/api/

# Teste simples - WebFlux (mais rápido)
curl "http://localhost:8080/api/webflux/persons/list?count=10"

# Teste simples - MVC com Coroutines  
curl "http://localhost:8080/api/mvc/persons/async?count=10"

# Teste simples - MVC Blocking (comparação)
curl "http://localhost:8080/api/mvc/persons/blocking?count=10"
```

### 2. Benchmarks Automatizados

```bash
# Comparação direta Coroutines vs Blocking
curl "http://localhost:8080/api/benchmark/coroutines-vs-blocking?count=50"

# Comparação WebFlux vs MVC
curl "http://localhost:8080/api/benchmark/webflux-vs-mvc?count=50"
```

### 3. Testes de Performance

```bash
# Teste de carga com ApacheBench
ab -n 1000 -c 10 "http://localhost:8080/api/webflux/persons/list?count=5"

# Teste de carga com curl (paralelo)
for i in {1..10}; do
  curl "http://localhost:8080/api/webflux/persons/list?count=10" &
done
wait
```

## 📊 Exemplo de Resposta da API

### Person Object
```json
{
  "id": 1,
  "name": "Ana Silva",
  "email": "ana.silva@company.com", 
  "age": 28,
  "city": "São Paulo"
}
```

### Lista de Pessoas
```json
[
  {
    "id": 1,
    "name": "Ana Silva",
    "email": "ana.silva@company.com",
    "age": 28,
    "city": "São Paulo"
  },
  {
    "id": 2,
    "name": "João Santos",
    "email": "joao.santos@company.com",
    "age": 35,
    "city": "Rio de Janeiro"
  }
]
```

### Resposta de Benchmark
```json
{
  "approach": "Kotlin Coroutines",
  "requests": 100,
  "personsPerRequest": 50,
  "totalPersons": 5000,
  "executionTimeMs": 1250,
  "averageTimePerRequest": 12.5,
  "threadInfo": "Thread: kotlinx.coroutines.DefaultExecutor, Virtual: false"
}
```

## 🧪 Cenários de Teste para Apresentação

### Cenário 1: Performance Básica
```bash
# Demonstrar diferença básica
echo "=== MVC Blocking ==="
time curl "http://localhost:8080/api/mvc/persons/blocking?count=20"

echo "=== MVC Coroutines ==="  
time curl "http://localhost:8080/api/mvc/persons/async?count=20"

echo "=== WebFlux Coroutines ==="
time curl "http://localhost:8080/api/webflux/persons/list?count=20"
```

### Cenário 2: Carga Concorrente
```bash
# Script para demonstrar escalabilidade
#!/bin/bash
echo "Testando 50 requisições simultâneas..."

echo "=== MVC Blocking ==="
time (
  for i in {1..50}; do
    curl -s "http://localhost:8080/api/mvc/persons/blocking?count=5" > /dev/null &
  done
  wait
)

echo "=== WebFlux Coroutines ==="
time (
  for i in {1..50}; do  
    curl -s "http://localhost:8080/api/webflux/persons/list?count=5" > /dev/null &
  done
  wait
)
```

### Cenário 3: Benchmark Completo
```bash
# Executar benchmark completo
./performance-benchmark.sh

# Ver relatório gerado
ls performance-report-*.txt | tail -1 | xargs cat
```

## 📈 Interpretando os Resultados

### Métricas Importantes

1. **Tempo de Resposta**
   - Menor é melhor
   - Diferença entre min/max indica estabilidade

2. **Requisições por Segundo**
   - Maior é melhor  
   - Indica capacidade de throughput

3. **Uso de Thread**
   - WebFlux: Poucos threads, alta eficiência
   - MVC: Mais threads, mais recursos

### O que Observar na Apresentação

```bash
# 1. Diferença de tempo de resposta
WebFlux:  ~88ms   (🏆 Vencedor)
MVC+Cor:  ~142ms  (✅ Bom)  
MVC Bloc: ~1068ms (❌ Lento)

# 2. Escalabilidade
WebFlux:  27 req/s  (🚀 Excelente)
MVC+Cor:  18 req/s  (✅ Bom)
MVC Bloc: 5 req/s   (🐌 Limitado)

# 3. Uso de recursos
WebFlux:  Event loop threads
MVC+Cor:  Suspended + thread reuse  
MVC Bloc: 1 thread per request
```

## 🎯 Demonstração Passo a Passo

### 1. Preparação
```bash
# Compilar e iniciar
./gradlew clean build
./gradlew bootRun

# Em outro terminal, aguardar aplicação subir
while ! curl -s http://localhost:8080/api/ > /dev/null; do
  echo "Aguardando aplicação..."
  sleep 1
done
echo "Aplicação pronta!"
```

### 2. Demonstração Visual
```bash
# Terminal 1: Monitor de recursos
top -pid $(pgrep -f kotlin-coroutines-sample)

# Terminal 2: Executar testes
curl "http://localhost:8080/api/webflux/persons/list?count=100"
```

### 3. Análise Final
```bash
# Executar benchmark e mostrar relatório
./performance-benchmark.sh
cat performance-report-*.txt | tail -50
```

## 🔧 Troubleshooting

### Aplicação não inicia
```bash
# Verificar porta ocupada
lsof -i :8080

# Matar processos
pkill -f kotlin-coroutines-sample

# Verificar logs
tail -f /tmp/app-kotlin-coroutines.log
```

### Performance baixa
```bash
# Verificar recursos do sistema
top -o cpu

# Verificar GC
jstat -gc $(pgrep -f kotlin-coroutines-sample)

# Ajustar JVM
export JAVA_OPTS="-Xmx2g -XX:+UseG1GC"
```

### Resultados inconsistentes
```bash
# Aumentar warmup
WARMUP_REQUESTS=10 ./performance-benchmark.sh

# Verificar outros processos
ps aux | grep java
```
