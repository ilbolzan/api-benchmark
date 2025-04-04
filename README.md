# API Benchmark

Este projeto é um benchmark comparativo de APIs REST implementadas em diferentes tecnologias e frameworks. O objetivo é comparar o desempenho, consumo de recursos e facilidade de desenvolvimento entre diferentes abordagens.

## Estrutura do Projeto

```
.
├── apis/            # Implementações das APIs
│   ├── spring-boot/ # Implementação em Spring Boot
│   ├── go/         # Implementação em Go
│   ├── quarkus/    # Implementação em Quarkus
│   ├── webflux/    # Implementação em Spring WebFlux
│   └── rust/       # Implementação em Rust
└── load-test/      # Scripts de teste de carga
    └── benchmark.js # Script principal de benchmark
```

## Tecnologias Implementadas

- **Spring Boot** - Implementação em Java usando o framework Spring Boot
- **Go** - Implementação em Go usando o pacote `net/http` nativo
- **Quarkus** - Implementação em Java usando o framework Quarkus
- **WebFlux** - Implementação em Java usando o Spring WebFlux
- **Rust** - Implementação em Rust

## Funcionalidade

Todas as implementações expõem um endpoint `/api/hello` que retorna uma mensagem simples de "Hello" seguida do nome da tecnologia.

## Requisitos

- Java 17+ (para Spring Boot, Quarkus e WebFlux)
- Go 1.21+ (para implementação em Go)
- Rust 1.75+ (para implementação em Rust)
- Maven (para projetos Java)
- Cargo (para projeto Rust)

## Como Executar

### Configuração das APIs

Para executar o teste de carga, é necessário configurar cada API em uma porta diferente:

1. Spring Boot: porta 8080
2. Go: porta 8081
3. Quarkus: porta 8082
4. WebFlux: porta 8083
5. Rust: porta 8084

### Executando o Teste de Carga

1. Instale o k6:
```bash
brew install k6
```

2. Torne o script executável:
```bash
cd load-test
chmod +x run-benchmark.sh
```

3. Execute o teste:
```bash
./run-benchmark.sh
```

O script irá:
- Testar cada API individualmente
- Gerenciar automaticamente o ciclo de vida de cada aplicação:
  1. Verificar se a porta está disponível
  2. Iniciar a aplicação
  3. Aguardar a API ficar disponível
  4. Executar o teste de carga
  5. Parar a aplicação
- Gerar um relatório HTML separado para cada API
- Executar os testes na seguinte ordem:
  1. Spring Boot
  2. Go
  3. Quarkus
  4. WebFlux
  5. Rust

Cada teste irá:
- Iniciar com 50 usuários virtuais
- Manter 50 usuários por 1 minuto
- Aumentar para 100 usuários
- Manter 100 usuários por 1 minuto
- Reduzir gradualmente até 0 usuários

Ao final de cada teste, será gerado um relatório HTML (`summary-{api-name}.html`) com os resultados.

### Gerenciamento de Aplicações

O script `run-benchmark.sh` gerencia automaticamente:
- Inicialização das aplicações
- Verificação de disponibilidade
- Encerramento das aplicações
- Limpeza de processos pendentes

Em caso de interrupção (Ctrl+C), o script irá:
- Parar todas as aplicações em execução
- Limpar processos pendentes
- Encerrar graciosamente

### Métricas Coletadas

O teste de carga coleta as seguintes métricas para cada API:

- Tempo de resposta (latência)
- Taxa de requisições por segundo (RPS)
- Taxa de erros
- Percentis de latência (p50, p90, p95, p99)
- Status das requisições

### Thresholds

O teste considera falha se:
- 95% das requisições demorarem mais que 500ms
- A taxa de erros for maior que 1%

## Objetivos do Benchmark

Este projeto permite comparar:

- Tempo de resposta das APIs
- Consumo de recursos (CPU e memória)
- Tempo de inicialização das aplicações
- Facilidade de desenvolvimento
- Escalabilidade
- Tamanho do binário final

## Observações

- Todas as implementações rodam na porta 8080 por padrão
- Cada implementação pode ser executada independentemente
- As APIs seguem o mesmo padrão de resposta para facilitar a comparação

## Próximos Passos

- Adicionar métricas de performance
- Implementar testes automatizados
- Adicionar documentação mais detalhada para cada tecnologia
- Incluir análise de consumo de recursos

## Ferramentas de Benchmark e Testes de Carga

Para realizar os testes de carga e benchmark das APIs, sugerimos as seguintes ferramentas:

### Apache JMeter
- **Descrição**: Ferramenta de código aberto para testes de carga e performance
- **Como usar**:
  ```bash
  # Instalação (usando Homebrew no macOS)
  brew install jmeter
  
  # Executar teste
  jmeter -n -t benchmark.jmx -l results.jtl
  ```
- **Vantagens**: 
  - Interface gráfica para criação de testes
  - Suporte a diferentes protocolos
  - Geração de relatórios detalhados
  - Scripts em JMX podem ser versionados

### k6
- **Descrição**: Ferramenta moderna de testes de carga em código aberto
- **Como usar**:
  ```bash
  # Instalação
  brew install k6
  
  # Executar teste
  k6 run benchmark.js
  ```
- **Vantagens**:
  - Scripts em JavaScript
  - Baixo consumo de recursos
  - Métricas em tempo real
  - Integração com Grafana

### wrk
- **Descrição**: Ferramenta de linha de comando para testes de carga HTTP
- **Como usar**:
  ```bash
  # Instalação
  brew install wrk
  
  # Executar teste (exemplo: 1000 conexões, 4 threads, 30 segundos)
  wrk -c1000 -t4 -d30s http://localhost:8080/api/hello
  ```
- **Vantagens**:
  - Simples e direto
  - Baixo overhead
  - Bom para testes rápidos

### Vegeta
- **Descrição**: Ferramenta de linha de comando para testes de carga HTTP
- **Como usar**:
  ```bash
  # Instalação
  brew install vegeta
  
  # Executar teste
  echo "GET http://localhost:8080/api/hello" | vegeta attack -duration=30s -rate=100 | vegeta report
  ```
- **Vantagens**:
  - Configuração simples
  - Suporte a diferentes formatos de saída
  - Bom para automação

## Métricas a Serem Coletadas

Durante os testes de carga, recomenda-se coletar as seguintes métricas:

1. **Latência**:
   - Tempo médio de resposta
   - Percentis (p50, p90, p95, p99)
   - Tempo máximo de resposta

2. **Throughput**:
   - Requisições por segundo (RPS)
   - Taxa de transferência (bytes/segundo)

3. **Recursos do Sistema**:
   - Uso de CPU
   - Uso de memória
   - Número de threads
   - GC pauses (para JVM)

4. **Erros**:
   - Taxa de erros
   - Tipos de erros
   - Timeouts

## Script de Benchmark Exemplo (k6)

```