import http from 'k6/http';
import { sleep, check } from 'k6';
import { htmlReport } from "https://jslib.k6.io/k6-html/0.0.6/index.js";

// Configuração do teste
export const options = {
  stages: [
    { duration: '5s', target: 9000 },
    { duration: '10s', target: 9000 },
    { duration: '10s', target: 15000 },
    { duration: '1s', target: 0 }, 
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% das requisições devem completar em menos de 500ms
    http_req_failed: ['rate<0.01'],   // Menos de 1% de falhas
  },
};

// URL da API a ser testada (será substituída pelo script de execução)
const API_URL = __ENV.API_URL || 'http://localhost:8080/api/hello';
const API_NAME = __ENV.API_NAME || 'default';

// Função principal do teste
export default function() {
  const response = http.get(API_URL);
  
  // Verifica o resultado da requisição
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  // Adiciona uma pausa entre as requisições
  sleep(1);
}

// Função para imprimir um resumo ao final do teste
export function handleSummary(data) {
  return {
    "results/summary.json": JSON.stringify(data),
    "results/summary.html": htmlReport(data),
  };
} 