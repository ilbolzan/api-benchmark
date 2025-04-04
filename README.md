![Benchmark Status](https://github.com/ilbolzan/api-benchmark/actions/workflows/benchmark.yml/badge.svg)

# API Benchmark

Este projeto realiza testes de benchmark em diferentes implementações de APIs REST, comparando performance, consumo de recursos e facilidade de desenvolvimento.

## Tecnologias Testadas

- Spring Boot (Java)
- Quarkus (Java)
- Go
- Rust
- Spring WebFlux (Java)

## Funcionalidade

Todas as APIs implementam um endpoint simples:
```
GET /api/hello
```

Que retorna:
```json
{
    "message": "Hello, World!"
}
```

## Requisitos

- Java 17+
- Go 1.21+
- Rust 1.75+
- Maven
- k6 (para testes de carga)
- Docker (opcional, para containerização)

## Execução

### Preparação

1. Clone o repositório
2. Instale as dependências de cada API:
   ```bash
   # Spring Boot
   cd apis/spring-boot
   mvn clean install

   # Quarkus
   cd apis/quarkus
   mvn clean install

   # Go
   cd apis/go
   go mod tidy

   # Rust
   cd apis/rust
   cargo build

   # WebFlux
   cd apis/webflux
   mvn clean install
   ```

### Executando os Testes

O projeto inclui scripts para executar os testes de carga usando k6. Para executar todos os testes:

```bash
cd load-test
./run-benchmark.sh
```

Para executar o teste de uma API específica:

```bash
cd load-test
./run-benchmark.sh <nome-da-api>
```

Exemplos:
```bash
./run-benchmark.sh spring-boot
./run-benchmark.sh go
./run-benchmark.sh quarkus
./run-benchmark.sh webflux
./run-benchmark.sh rust
```

Opções disponíveis:
- `-h, --help`: Mostra a ajuda
- `-l, --list`: Lista todas as APIs disponíveis
- `-a, --all`: Executa todos os testes (padrão)
- `<api-name>`: Executa o teste apenas para a API especificada

### Configuração de Carga

Os testes de carga são configurados com os seguintes parâmetros:

- Rampa de subida: 5 segundos até 9000 usuários
- Manutenção: 10 segundos com 9000 usuários
- Aumento: 10 segundos até 15000 usuários
- Rampa de descida: 1 segundo até 0 usuários

Thresholds:
- 95% das requisições devem completar em menos de 500ms
- Taxa de falha deve ser menor que 1%

### Resultados

Os resultados dos testes são gerados no diretório `results`:
- `results/summary.json`: Resultados em formato JSON
- `results/summary.html`: Relatório HTML com visualização dos resultados
- `results/<api-name>-html-report.html`: Relatório detalhado por API

## Estrutura do Projeto

```
.
├── apis/
│   ├── spring-boot/    # API Spring Boot
│   ├── quarkus/        # API Quarkus
│   ├── go/            # API Go
│   ├── rust/          # API Rust
│   └── webflux/       # API Spring WebFlux
├── load-test/         # Scripts de teste de carga
│   ├── benchmark.js   # Script k6
│   └── run-benchmark.sh # Script de execução
└── results/           # Diretório para resultados dos testes
```

## Contribuindo

1. Fork o projeto
2. Crie sua branch de feature (`git checkout -b feature/nova-api`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona nova API'`)
4. Push para a branch (`git push origin feature/nova-api`)
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.