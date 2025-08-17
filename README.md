# 🚀 Kotlin Coroutines Performance Benchmark

Este projeto demonstra a efetividade das **Kotlin Coroutines** comparando diferentes abordagens: **Spring MVC tradicional**, **Spring MVC com Coroutines** e **Spring WebFlux com Coroutines**.

## 📊 Principais Resultados

Baseado nos benchmarks executados com **20 requisições** (padronização para comparação), **Spring WebFlux com Coroutines** apresentou a melhor performance:
- **96.6% mais rápido** que a abordagem mais lenta
- **193.79 requisições/segundo** em testes de carga concorrente (100 requisições simultâneas)
- **86ms** de tempo médio de resposta

## 🎯 Objetivo

Este projeto foi desenvolvido para demonstrações e apresentações sobre:
- Performance das Kotlin Coroutines
- Comparação entre abordagens síncronas e assíncronas
- Escalabilidade de diferentes tecnologias Spring
- Análise automatizada de benchmarks

## 🛠️ Tecnologias Utilizadas

- **Kotlin** 1.9+
- **Spring Boot** 3.x
- **Spring WebFlux** (programação reativa)
- **Spring MVC** (abordagem tradicional)
- **Kotlin Coroutines** (programação assíncrona)
- **Gradle** (build tool)

## 🏗️ Arquitetura do Projeto

```
src/main/kotlin/
├── model/
│   └── Person.kt                    # Modelo de dados
├── service/
│   └── PersonService.kt             # Lógica de negócio com coroutines
├── controller/
│   ├── MvcController.kt             # Endpoints Spring MVC
│   ├── WebFluxController.kt         # Endpoints Spring WebFlux
│   └── BenchmarkController.kt       # Endpoints para comparação
└── KotlinCoroutinesSampleApplication.kt
```

## 🚀 Como Executar

### Pré-requisitos
- Java 17+
- Kotlin 1.9+
- Gradle 7.5+

### Executar a aplicação
```bash
# Compilar o projeto
./gradlew clean build

# Executar a aplicação
./gradlew bootRun

# Ou executar o JAR diretamente
java -jar build/libs/kotlin-coroutines-sample-0.0.1-SNAPSHOT.jar
```

A aplicação estará disponível em: `http://localhost:8080`

## 📈 Executar Benchmarks

O projeto inclui um sistema completo de benchmarks automatizados:

### Teste Rápido
```bash
./performance-benchmark.sh quick
```

### Benchmark Completo
```bash
./performance-benchmark.sh
```

### Benchmark com Configurações Customizadas
```bash
# Configurar parâmetros
TEST_REQUESTS=10 WARMUP_REQUESTS=5 CONCURRENT_REQUESTS=50 ./performance-benchmark.sh
```

### Usando o Makefile
```bash
# Ver todos os comandos disponíveis
make help

# Teste rápido de funcionalidade
make test-quick

# Benchmark completo com análise
make benchmark

# Benchmark rápido (configurações reduzidas)
make benchmark-fast

# Teste de carga intensiva
make benchmark-load

# Compilar e executar aplicação
make run

# Ver último relatório gerado
make report

# Limpar relatórios antigos
make clean-reports
```

## 🧪 Endpoints Disponíveis

### Spring MVC Endpoints
- `GET /api/mvc/persons/blocking?count={n}` - Abordagem tradicional bloqueante
- `GET /api/mvc/persons/async?count={n}` - MVC com Kotlin Coroutines

### Spring WebFlux Endpoints
- `GET /api/webflux/persons/list?count={n}` - WebFlux com Coroutines (lista)
- `GET /api/webflux/persons/parallel?batches={n}&countPerBatch={n}` - WebFlux paralelo

### Benchmark Endpoints
- `GET /api/benchmark/coroutines-vs-blocking?count={n}` - Comparação direta
- `GET /api/benchmark/webflux-vs-mvc?count={n}` - Comparação WebFlux vs MVC

## 📊 Análise de Performance

O sistema de benchmark gera relatórios detalhados com:

### 🚀 Métricas de Performance
- Tempo médio de resposta
- Tempo mínimo e máximo
- Taxa de requisições por segundo
- Análise de carga concorrente

### 📈 Comparação Automatizada
- Identificação da melhor abordagem
- Cálculo de melhorias percentuais
- Recomendações técnicas baseadas em dados

### 📄 Relatórios Detalhados
Os relatórios são salvos em arquivos como `performance-report-YYYYMMDD-HHMMSS.txt` contendo:
- Resultados individuais de cada teste
- Análise comparativa detalhada
- Recomendações técnicas
- Cenários de uso para cada abordagem

## 🏆 Resultados Oficiais (20 Requisições)

| Abordagem                | Tempo Médio | Req/s (Carga) | Uso Recomendado            |
| ------------------------ | ----------- | ------------- | -------------------------- |
| **WebFlux + Coroutines** | **86ms**    | **193.79**    | 🎯 **Melhor escolha geral** |
| MVC + Coroutines         | 143ms       | 174.21        | Migração gradual           |
| MVC Blocking             | 1060ms      | 104.38        | Baixa concorrência         |

*Testes executados com 20 requisições sequenciais e 100 requisições concorrentes para carga*

## 🎯 Cenários de Uso Recomendados

### 🚀 **WebFlux + Coroutines**
- APIs de alta performance
- Novos microserviços
- Aplicações com muitas chamadas externas

### 🔄 **MVC + Coroutines**
- Migração de projetos legados
- Sistemas corporativos tradicionais
- Transição gradual para programação assíncrona

### 🏢 **MVC Blocking**
- Aplicações com baixa concorrência
- Sistemas simples e tradicionais
- Equipes sem experiência em programação assíncrona

## 🛠️ Comandos Úteis

```bash
# Verificar status da aplicação
curl http://localhost:8080/api/

# Teste rápido de endpoint
curl "http://localhost:8080/api/webflux/persons/list?count=10"

# Teste de benchmark
curl "http://localhost:8080/api/benchmark/coroutines-vs-blocking?count=20"

# Parar processos da aplicação
pkill -f "kotlin-coroutines-sample"
```

## 📚 Recursos de Aprendizado

Este projeto demonstra:
- **Suspend functions** e como usar coroutines
- **Programação reativa** com WebFlux
- **Integração** de coroutines com Spring
- **Benchmarking automatizado** de performance
- **Análise comparativa** de diferentes abordagens

### 📖 Documentação Adicional

- [`TECHNICAL_DETAILS.md`](./TECHNICAL_DETAILS.md) - Detalhes técnicos e arquitetura
- [`EXAMPLES.md`](./EXAMPLES.md) - Exemplos práticos e cenários de teste
- [`performance-report-*.txt`](./performance-report-20250816-225541.txt) - Relatórios de benchmark oficiais
- [`Makefile`](./Makefile) - Automação de tarefas e comandos

## 🤝 Contribuição

Para contribuir com o projeto:
1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é destinado para fins educacionais e de demonstração.

---

**🎯 Conclusão**: Spring WebFlux com Kotlin Coroutines oferece a melhor combinação de performance, escalabilidade e experiência de desenvolvimento para aplicações modernas.

**📊 Comparação**: Este projeto utiliza **20 requisições** como padrão para permitir comparação direta com projetos similares como `java-virtual-threads-sample`. 
