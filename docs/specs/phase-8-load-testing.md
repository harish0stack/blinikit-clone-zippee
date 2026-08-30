# Phase 8 — Load Testing at 20K–30K Concurrent Users

> **Session start prompt:**
> ```
> Read: /Users/harishkumavat/blinkit-clone/docs/context/SESSION_CONTEXT.md
> Read: /Users/harishkumavat/blinkit-clone/docs/specs/phase-8-load-testing.md
> Branch: phase-8-load-test
> Phases 0–7 are COMPLETE.
> ```

---

## Goal

Validate that the Tier A architecture holds at 20,000–30,000 concurrent virtual users, using k6 distributed load testing. Produce a documented report that defines clear pass/fail criteria for triggering the Tier A → Tier B migration.

---

## Tooling & Infrastructure

| Tool | Purpose |
|---|---|
| **k6** (open-source) | JavaScript-scriptable HTTP + WebSocket load testing |
| **Hetzner/DigitalOcean VMs** (3–5 × $5–10/mo each) OR **k6 Cloud free trial** | Distributed execution (single machine can't open 20K connections) |
| **Supabase Dashboard** | Live monitoring during the test run |
| **k6 output → Grafana** | Optional: k6 supports InfluxDB/Prometheus output for dashboards |

---

## Why Distributed?

A single OS cannot open 20,000+ concurrent TCP connections (ephemeral port limit: ~60K, but OS overhead starts failing much earlier). **Run k6 on 4 VMs, each handling 5K VUs** — they all start at the same wall-clock time via `--execution-segment`.

---

## How We Will Implement It

### Step 1 — Install k6

```bash
# macOS
brew install k6

# Linux (on load test VMs)
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update && sudo apt-get install k6
```

### Step 2 — Create k6 test scripts

File: `docs/load-tests/config.js`
```javascript
// Shared config — import in each test script
export const BASE_URL = __ENV.SUPABASE_URL;
export const ANON_KEY = __ENV.SUPABASE_ANON_KEY;
export const HEADERS = {
  'apikey': ANON_KEY,
  'Authorization': `Bearer ${ANON_KEY}`,
  'Content-Type': 'application/json',
};
```

#### Test 1 — Product listing ramp test (read path)

File: `docs/load-tests/test_product_listing.js`
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, HEADERS } from './config.js';

export const options = {
  stages: [
    { duration: '1m', target: 1000 },    // ramp up to 1K
    { duration: '2m', target: 5000 },    // ramp to 5K
    { duration: '2m', target: 10000 },   // ramp to 10K
    { duration: '5m', target: 20000 },   // ramp to 20K
    { duration: '5m', target: 20000 },   // hold at 20K
    { duration: '2m', target: 0 },       // ramp down
  ],
  thresholds: {
    'http_req_duration': ['p(95)<300'],  // 95th percentile < 300ms
    'http_req_failed': ['rate<0.01'],    // error rate < 1%
  },
};

export default function () {
  // Simulate browsing: fetch categories, then products for a random category
  const CATEGORY_IDS = __ENV.CATEGORY_IDS.split(',');
  const categoryId = CATEGORY_IDS[Math.floor(Math.random() * CATEGORY_IDS.length)];

  const categoriesRes = http.get(
    `${BASE_URL}/rest/v1/categories?is_active=eq.true&select=*`,
    { headers: HEADERS }
  );
  check(categoriesRes, { 'categories 200': (r) => r.status === 200 });

  const productsRes = http.get(
    `${BASE_URL}/rest/v1/products?category_id=eq.${categoryId}&status=eq.live&select=*,product_images(*)`,
    { headers: HEADERS }
  );
  check(productsRes, {
    'products 200': (r) => r.status === 200,
    'products not empty': (r) => JSON.parse(r.body).length > 0,
  });

  sleep(1 + Math.random() * 2);  // 1–3s user think time
}
```

#### Test 2 — Realtime WebSocket concurrent connections

File: `docs/load-tests/test_realtime_connections.js`
```javascript
import ws from 'k6/ws';
import { check } from 'k6';
import { BASE_URL, ANON_KEY } from './config.js';

export const options = {
  vus: 5000,
  duration: '5m',
  thresholds: {
    'ws_connecting': ['p(95)<2000'],    // 95% of WS connections established < 2s
    'ws_session_duration': ['p(95)<300000'],
  },
};

export default function () {
  const url = BASE_URL.replace('https://', 'wss://') + '/realtime/v1/websocket?apikey=' + ANON_KEY;

  const res = ws.connect(url, {}, function (socket) {
    socket.on('open', () => {
      // Subscribe to products channel (live products in any category)
      socket.send(JSON.stringify({
        topic: 'realtime:public:products',
        event: 'phx_join',
        payload: {},
        ref: '1',
      }));
    });

    socket.on('message', (msg) => {
      const data = JSON.parse(msg);
      check(data, { 'realtime heartbeat': (d) => d.event !== undefined });
    });

    socket.setTimeout(() => socket.close(), 4 * 60 * 1000);  // hold 4 min
  });

  check(res, { 'ws connected': (r) => r && r.status === 101 });
}
```

#### Test 3 — Checkout write path (concurrent order placement)

File: `docs/load-tests/test_checkout.js`
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, HEADERS } from './config.js';

export const options = {
  vus: 2000,
  duration: '5m',
  thresholds: {
    'http_req_duration{type:cart_read}': ['p(95)<300'],
    'http_req_duration{type:order_insert}': ['p(95)<500'],
    'http_req_failed': ['rate<0.01'],
  },
};

// NOTE: This test requires pre-seeded test user tokens in __ENV.TEST_USER_TOKENS (comma-separated JWTs)
export default function () {
  const tokens = __ENV.TEST_USER_TOKENS.split(',');
  const token = tokens[__VU % tokens.length];  // round-robin across test users

  const authHeaders = {
    'apikey': __ENV.SUPABASE_ANON_KEY,
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  };

  // Step 1: Read cart
  const cartRes = http.get(
    `${BASE_URL}/rest/v1/carts?select=*,cart_items(*)`,
    { headers: authHeaders, tags: { type: 'cart_read' } }
  );
  check(cartRes, { 'cart 200': (r) => r.status === 200 });

  sleep(0.5);

  // Step 2: Simulate placing an order (Edge Function call — not direct DB insert in real checkout)
  // For load test purposes, simulate the DB write directly
  // In production, this goes through checkout Edge Function
  const orderRes = http.post(
    `${BASE_URL}/rest/v1/orders`,
    JSON.stringify({
      user_id: __ENV.TEST_USER_ID,
      address_id: __ENV.TEST_ADDRESS_ID,
      status: 'placed',
      total_amount: 299.00,
    }),
    { headers: authHeaders, tags: { type: 'order_insert' } }
  );
  check(orderRes, { 'order placed': (r) => r.status === 201 });

  sleep(1);
}
```

#### Test 4 — Sustained 20K VU steady-state

File: `docs/load-tests/test_sustained.js`
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, HEADERS } from './config.js';

export const options = {
  vus: 20000,
  duration: '15m',            // 15 minutes sustained, no ramp
  thresholds: {
    'http_req_duration': ['p(95)<300', 'p(99)<600'],
    'http_req_failed': ['rate<0.02'],
  },
};

export default function () {
  const res = http.get(
    `${BASE_URL}/rest/v1/products?status=eq.live&select=id,name,selling_price&limit=20`,
    { headers: HEADERS }
  );
  check(res, { '200': (r) => r.status === 200 });
  sleep(0.75 + Math.random());
}
```

### Step 3 — Run distributed (4 VMs, each handles 5K VUs)

On each VM, run:
```bash
# VM 1 of 4 (handles VU 1–5000)
k6 run \
  --execution-segment "0/4:1/4" \
  --execution-segment-sequence "0,1/4,2/4,3/4,1" \
  -e SUPABASE_URL=https://xxx.supabase.co \
  -e SUPABASE_ANON_KEY=xxx \
  -e CATEGORY_IDS=uuid1,uuid2,uuid3,uuid4,uuid5,uuid6 \
  docs/load-tests/test_sustained.js

# VM 2 of 4
k6 run --execution-segment "1/4:2/4" ...

# VM 3 of 4
k6 run --execution-segment "2/4:3/4" ...

# VM 4 of 4
k6 run --execution-segment "3/4:1" ...
```

All 4 VMs must start within seconds of each other (coordinate via a shared start time or use k6 Cloud for orchestration).

### Step 4 — What to monitor during the run

**Supabase Dashboard panels to watch:**

| Panel | Alert threshold |
|---|---|
| Database → Connections (active vs pool max) | Alert if active connections > 80% of pool |
| Database → CPU % | Alert if > 80% sustained |
| Realtime → Concurrent connections | Note when it approaches plan limit |
| Storage → Bandwidth | Informational |
| Edge Functions → Invocations / errors | Watch publish-product error rate |

**k6 output to watch:**
- `p(95)` latency (target: < 300ms on reads)
- `p(99)` latency (target: < 600ms on reads)
- `http_req_failed` rate (target: < 1%)
- `ws_connecting` latency for Realtime test

### Step 5 — Write the load test report

File: `docs/load-test-results.md`

Template:
```markdown
# Load Test Results — Tier A (Blinkit Clone)
Date: YYYY-MM-DD
Supabase plan: [Free / Pro / Team]
Region: [ap-south-1 / us-east-1]

## Test Environment
- k6 version: X.X.X
- Number of VMs: 4 × [VM spec]
- Supabase project ref: xxxxx

## Results Summary

| Scenario | VUs | Duration | p95 | p99 | Error Rate | Pass/Fail |
|---|---|---|---|---|---|---|
| Product listing ramp | 100→20K | 17m | Xms | Xms | X% | ✅/❌ |
| Realtime WS connections | 5000 concurrent | 5m | N/A | N/A | X% | ✅/❌ |
| Checkout write path | 2000 | 5m | Xms | Xms | X% | ✅/❌ |
| Sustained 20K | 20000 | 15m | Xms | Xms | X% | ✅/❌ |

## DB Connection Pool Observations
- Peak active connections observed: X / Y pool max
- Connection errors: X

## Realtime Observations
- Peak concurrent Realtime connections: X / [plan limit]
- First cap-out event (if any): [describe]

## Verdict

- [ ] Tier A can sustain 20K concurrent ✅
- [ ] Tier A cap reached at [X]K users — migrate to Tier B

## Recommended Next Steps
[Based on results: upgrade Realtime add-on / tune narrow subscriptions / move to Tier B]
```

---

## Files in Scope

```
docs/
├── load-tests/
│   ├── config.js                      [CREATE]
│   ├── test_product_listing.js        [CREATE]
│   ├── test_realtime_connections.js   [CREATE]
│   ├── test_checkout.js               [CREATE]
│   └── test_sustained.js             [CREATE]
└── load-test-results.md               [CREATE — filled in after running tests]
```

**No application code changes in this phase.**

---

## Acceptance Criteria

- [ ] All 4 k6 test scripts run without syntax errors (`k6 run --dry-run`)
- [ ] Test 1 (product listing ramp): p95 < 300ms at 20K VUs, error rate < 1%
- [ ] Test 2 (Realtime WS): 5000 concurrent connections established without plan-level refusal
- [ ] Test 3 (checkout write): p95 < 500ms at 2000 VUs, no order duplication (idempotency key check)
- [ ] Test 4 (sustained): p95 < 300ms for 15 minutes at 20K VUs
- [ ] `docs/load-test-results.md` is filled in with actual observed numbers
- [ ] The report clearly states whether Tier A passes or what the actual ceiling is
- [ ] DB connection pool never exceeded 80% of pool size during any test

---

## If Tests Fail

| Symptom | Root cause | Fix |
|---|---|---|
| p95 spikes at 5–10K users | Connection pool exhausted | Upgrade Supabase plan or narrow query scope |
| Realtime connections refused | Plan-level concurrent connection limit | Upgrade Realtime add-on or scope subscriptions to per-category channels |
| Order insert p95 > 500ms | Lock contention on `products.stock_qty` during concurrent checkout | Use `FOR UPDATE SKIP LOCKED` in checkout Edge Function |
| k6 VMs can't reach 20K VUs | OS connection limits | Check `ulimit -n` on VMs — should be > 65536; `sysctl net.ipv4.ip_local_port_range` |

---

## This Is The End of Tier A

After this phase, the project can handle 20K concurrent users. The load test report is the objective evidence for deciding if/when to move to Tier B (add dark-store inventory, Kafka event streaming, separate microservices).
