curl -X POST "https://api.datadoghq.com/api/v2/logs/config/metrics" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "type": "logs_metrics",
      "attributes": {
        "name": "omb.m2131.el0",
        "filter": { "query": "omb.m2131_el:el0" },
        "compute": { "aggregation_type": "count" }
      }
    }
  }'

curl -X POST "https://api.datadoghq.com/api/v2/logs/config/metrics" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "type": "logs_metrics",
      "attributes": {
        "name": "omb.m2131.el1",
        "filter": { "query": "omb.m2131_el:el1" },
        "compute": { "aggregation_type": "count" }
      }
    }
  }'

curl -X POST "https://api.datadoghq.com/api/v2/logs/config/metrics" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "type": "logs_metrics",
      "attributes": {
        "name": "omb.m2131.el2",
        "filter": { "query": "omb.m2131_el:el2" },
        "compute": { "aggregation_type": "count" }
      }
    }
  }'

curl -X POST "https://api.datadoghq.com/api/v2/logs/config/metrics" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "type": "logs_metrics",
      "attributes": {
        "name": "omb.m2131.el3",
        "filter": { "query": "omb.m2131_el:el3" },
        "compute": { "aggregation_type": "count" }
      }
    }
  }'


