import http from 'k6/http';
import { sleep, check } from 'k6';

// Configuração do teste
export const options = {
  stages: [
    { duration: '5s', target: 9000 },
    { duration: '10s', target: 9000 },
    { duration: '10s', target: 15000 },
    { duration: '1s', target: 0 }, 
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% das requisições devem ser mais rápidas que 500ms
    http_req_failed: ['rate<0.01'],   // Taxa de falha deve ser menor que 1%
  },
};

// URL da API a ser testada (será substituída pelo script de execução)
const API_URL = __ENV.API_URL || 'http://localhost:8080/api/hello';
const API_NAME = __ENV.API_NAME || 'spring-boot';

// Função principal do teste
export default function() {
  const res = http.get(API_URL);
  
  // Verifica o resultado da requisição
  check(res, {
    [`${API_NAME} status is 200`]: (r) => r.status === 200,
    [`${API_NAME} response time < 500ms`]: (r) => r.timings.duration < 500,
  });

  // Adiciona uma pausa entre as requisições
  sleep(1);
}

// Função para imprimir um resumo ao final do teste
export function handleSummary(data) {
  console.log('Test Completed!');
  console.log('================');
  console.log(`API: ${API_NAME}`);
  console.log(`URL: ${API_URL}`);
  console.log('================');
  return {
    'stdout': JSON.stringify(data),
    [`summary-${API_NAME}.json`]: JSON.stringify(data),
  };
} 