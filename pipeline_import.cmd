curl -X POST "https://api.datadoghq.com/api/v1/logs/config/pipelines" \
  -H "Content-Type: application/json" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
  -d @pipelines/omb_m2131_pipeline.json
