# 🔧 Detalhes Técnicos - Kotlin Coroutines Benchmark

## 📊 Resultados Oficiais (Atualizado 18/08/2025)

### 🎯 Configuração do Benchmark
- **Requisições de Teste**: 20 (compatível com java-virtual-threads-sample)
- **Requisições Concorrentes**: 100
- **Requisições de Warmup**: 5
- **Relatório**: performance-report-20250818-103924.txt

### 🏆 Rankings de Performance

| 🏁 Posição | Abordagem                | Tempo Médio | Melhoria vs Pior |
| --------- | ------------------------ | ----------- | ---------------- |
| 🥇 **1º**  | **WebFlux + Coroutines** | **83ms**    | **-92.1%**       |
| 🥈 **2º**  | **MVC + Coroutines**     | **142ms**   | **-86.5%**       |
| 🥉 **3º**  | **WebFlux Tradicional**  | **557ms**   | **-47.2%**       |
| 🔴 **4º**  | **MVC Blocking**         | **1054ms**  | **baseline**     |

## 📐 Arquitetura Detalhada

### PersonService
```kotlin
class PersonService {
    suspend fun generatePersons(count: Int): List<Person>
    suspend fun findPersonById(id: Long): Person?
}
```
- Utiliza `suspend` functions para operações não-bloqueantes
- Simula delays de I/O para demonstrar diferenças de performance
- Thread-safe e escalável

### Controllers

#### MvcController
- **Blocking**: Usa thread pool tradicional
- **Async**: Integra coroutines com `runBlocking`
- Demonstra migração gradual

#### WebFluxController  
- **List**: Retorna lista completa com coroutines
- **Parallel**: Processa batches em paralelo
- Totalmente reativo e não-bloqueante

#### BenchmarkController
- Testes diretos entre abordagens
- Métricas detalhadas de performance
- Comparação side-by-side

## ⚙️ Configurações de Performance

### JVM Settings
```bash
-Xmx2g -Xms1g
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
```

### Coroutines Configuration
```kotlin
val dispatcher = Dispatchers.IO.limitedParallelism(100)
```

### Thread Pool Comparison
- **MVC**: Tomcat thread pool (200 threads)
- **WebFlux**: Event loop + worker threads (4-8 threads)
- **Coroutines**: Dispatcher pool (configurable)

## 📊 Metodologia de Benchmark

### Warmup Process
1. JVM warmup com 5 requisições
2. Compilação JIT das hot paths
3. Garbage collection estabilizada

### Test Execution
1. Medição de tempo em milissegundos
2. Coleta de métricas de thread
3. Análise de throughput
4. Teste de carga concorrente

### Metrics Collected
- Response time (avg, min, max)
- Requests per second
- Thread utilization
- Memory usage patterns
- CPU utilization

## 🔍 Análise dos Resultados

### Por que WebFlux + Coroutines vence?

1. **Não-bloqueante**: Não trava threads em I/O
2. **Event Loop**: Poucos threads, alta eficiência
3. **Backpressure**: Controle automático de fluxo
4. **Sintaxe clara**: Coroutines vs callbacks

### Thread Usage Analysis
```
MVC Blocking:     1 thread per request
MVC Coroutines:   Suspended on I/O, thread reuse
WebFlux:          Event loop + worker threads
```

### Memory Footprint
- **WebFlux**: Menor uso de memória por request
- **Coroutines**: Stack frame suspension
- **Blocking**: Full thread stack allocation

## 🧪 Configurações de Teste

### Padrão
```bash
WARMUP_REQUESTS=5
TEST_REQUESTS=20
CONCURRENT_REQUESTS=100
```

### Stress Test
```bash
WARMUP_REQUESTS=10
TEST_REQUESTS=100
CONCURRENT_REQUESTS=500
```

### Production Simulation
```bash
WARMUP_REQUESTS=20
TEST_REQUESTS=1000
CONCURRENT_REQUESTS=1000
```

## 🎯 Cenários de Carga

### Low Load (< 10 req/s)
- MVC Blocking: Aceitável
- Diferenças mínimas entre abordagens

### Medium Load (10-100 req/s)
- Coroutines começam a mostrar vantagem
- Thread pool saturation no MVC

### High Load (> 100 req/s)
- WebFlux + Coroutines: Excelente
- MVC Blocking: Degradação significativa

## 🔧 Tuning Tips

### Para MVC + Coroutines
```properties
server.tomcat.threads.max=200
server.tomcat.threads.min-spare=10
```

### Para WebFlux
```properties
spring.webflux.multipart.max-in-memory-size=1MB
reactor.netty.ioWorkerCount=4
```

### Para Coroutines
```kotlin
val scope = CoroutineScope(
    Dispatchers.IO.limitedParallelism(100) + 
    SupervisorJob()
)
```

## 📈 Performance Patterns

### CPU Bound Tasks
- Coroutines: `Dispatchers.Default`
- Parallelism = CPU cores

### I/O Bound Tasks  
- Coroutines: `Dispatchers.IO`
- Higher parallelism (64-unlimited)

### Mixed Workloads
- WebFlux: Reactive streams
- Backpressure handling
- Resource allocation

## 🛠️ Debugging & Monitoring

### Coroutines Debug
```kotlin
-Dkotlinx.coroutines.debug
```

### JVM Monitoring
```bash
jstat -gc <pid> 1s
jstack <pid>
```

### Application Metrics
- Micrometer integration
- Custom performance counters
- Response time histograms
