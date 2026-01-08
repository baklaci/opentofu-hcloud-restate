// Simple HTTP service that mimics a Restate service
// This demonstrates the service interface without requiring the SDK

const http = require('http');
const url = require('url');

// Simple in-memory state
let state = {
  count: 0,
  greetings: []
};

// Service handlers
const handlers = {
  greet: (name) => {
    const greeting = `Hello, ${name || "World"}!`;
    state.greetings.push(greeting);
    return greeting;
  },
  
  count: () => {
    state.count += 1;
    return state.count;
  },
  
  getState: () => {
    return state;
  }
};

// Create HTTP server
const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  const method = req.method;
  
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  if (method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }
  
  // Handle different endpoints
  if (path === '/greeter/greet' && method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const name = JSON.parse(body);
        const result = handlers.greet(name);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result));
      } catch (e) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid JSON' }));
      }
    });
  } else if (path === '/greeter/count' && method === 'POST') {
    const result = handlers.count();
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(result));
  } else if (path === '/greeter/state' && method === 'GET') {
    const result = handlers.getState();
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(result));
  } else if (path === '/health' && method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'healthy', timestamp: new Date().toISOString() }));
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found', available_endpoints: [
      'POST /greeter/greet',
      'POST /greeter/count',
      'GET /greeter/state',
      'GET /health'
    ]}));
  }
});

const PORT = 9080;
server.listen(PORT, () => {
  console.log(`Test service listening on port ${PORT}`);
  console.log('Available endpoints:');
  console.log('  POST /greeter/greet - Send a name to get a greeting');
  console.log('  POST /greeter/count - Increment and get counter');
  console.log('  GET /greeter/state - Get current state');
  console.log('  GET /health - Health check');
  console.log('');
  console.log('Example usage:');
  console.log(`  curl -X POST http://localhost:${PORT}/greeter/greet -H 'Content-Type: application/json' -d '"World"'`);
  console.log(`  curl -X POST http://localhost:${PORT}/greeter/count`);
  console.log(`  curl http://localhost:${PORT}/greeter/state`);
});