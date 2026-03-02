# OMB M-21-31 Log Classification & Conformance Framework

## Overview

This repository implements a Datadog-based log classification framework aligned to **OMB Memorandum M-21-31: Improving the Federal Government’s Investigative and Remediation Capabilities Related to Cybersecurity Incidents**.

The objective of this implementation is to:

* Automatically classify every ingested log
* Assign OMB event category metadata
* Derive an EL maturity tier (EL0–EL3)
* Apply precision logic when specific event attributes require reclassification
* Produce an `omb` JSON object on every log
* Support dashboards that demonstrate compliance and maturity posture

The pipeline definition is exported in:

* `omb_m2131_pipeline.json` 

---

# 1. OMB M-21-31 Directive Summary

OMB M-21-31 requires federal agencies to:

* Collect standardized security log categories
* Centralize log storage
* Retain logs for mandated durations (12 months searchable, 18 months archive)
* Support investigative reconstruction of incidents
* Achieve increasing logging maturity tiers:

| Tier | Description                                                         |
| ---- | ------------------------------------------------------------------- |
| EL0  | Logging incomplete or non-compliant                                 |
| EL1  | Basic high-value event logging                                      |
| EL2  | Intermediate coverage (network, DNS, endpoint, cloud control-plane) |
| EL3  | Advanced investigative telemetry                                    |

Maturity is derived from **coverage completeness**, not log volume.

---

# 2. Architecture Overview

The Datadog pipeline processes **every log (`source:*`)** and constructs an `omb` object using:

1. Source-based baseline classification
2. Secondary attribute precision logic
3. Tertiary attribute refinement
4. Controlled override precedence

The final result is an enriched JSON object:

```json
{
  "omb": {
    "source": "cloudtrail",
    "category": "cloud_api_activity",
    "domain": "cloud",
    "m2131_el": "el2"
  }
}
```

---

# 3. Datadog Pipeline Design

Pipeline name: **OMB M2131**
Filter: `source:*`
Exported configuration: 

The pipeline executes in structured stages:

---

## Stage 1 – Source Baseline Lookup

Reference Table:

* `omb_m2131_source_lookup.csv`

Lookup Key:

```
source
```

This provides:

* Default `omb.category`
* Default `omb.domain`
* Default `omb.m2131_el`

This ensures every log receives a minimum classification.

---

## Stage 2 – Precision Attribute Discovery

Certain sources produce multiple event types that require different classifications.

Examples:

* `cloudtrail` → Management vs Data events
* `windows.events` → 4624 vs 4688
* `pan.firewall` → TRAFFIC vs THREAT
* `route53` → NXDOMAIN vs NOERROR

To support this, the pipeline extracts possible discriminator fields into:

```
omb.precision_attribute.secondary_field
omb.precision_attribute.secondary_field_value
omb.precision_attribute.tertiary_field
omb.precision_attribute.tertiary_field_value
```

These are discovered using multiple Attribute Remappers across common log schemas.

---

## Stage 3 – Secondary Precision Lookup

Reference Table:

* `omb_m2131_precision_lookup.csv`

Lookup Key Format:

```
<source>|<secondary_field>|<secondary_field_value>
```

Example:

```
cloudtrail|eventCategory|Data
```

The lookup returns a refined `omb` object:

```
omb.precision_attribute.secondary_omb
```

If present, it overrides baseline classification.

---

## Stage 4 – Tertiary Precision Lookup

Some sources require deeper inspection.

Lookup Key Format:

```
<source>|<tertiary_field>|<tertiary_field_value>
```

Example:

```
windows.events|winlog.channel|Sysmon
```

This produces:

```
omb.precision_attribute.tertiary_omb
```

Which has highest override precedence.

---

## Override Precedence Logic

Final `omb` object is determined as:

```
Tertiary Precision Override
        ↓
Secondary Precision Override
        ↓
Source Baseline
        ↓
Default (UNDEFINED / EL0)
```

This prevents tier overstatement and maintains audit defensibility.

---

# 4. Reference Tables

## 4.1 Source Baseline Lookup

**File:** `omb_m2131_source_lookup.csv`

Maps:

```
source → omb.category, omb.domain, omb.m2131_el
```

Purpose:
Provides default classification for each integration.

---

## 4.2 Source Precision Field Mapping

**File:** `omb_m2131_source_precision_fields.csv`

Maps:

```
source → which attributes to inspect
```

Purpose:
Defines which event fields are eligible for secondary/tertiary precision logic.

---

## 4.3 Precision Lookup Table

**File:** `omb_m2131_precision_lookup.csv`

Maps composite keys to refined OMB classifications.

Example entries:

```
cloudtrail|eventCategory|Data → el3
cloudtrail|eventCategory|Management → el2
windows.events|winlog.event_id|4624 → el1
windows.events|winlog.event_id|4688 → el2
```

Purpose:
Allows event-level maturity correction.

---

# 5. Resulting OMB JSON Object Per Log

Every processed log will contain:

```json
{
  "omb": {
    "source": "<original source>",
    "category": "<omb category>",
    "domain": "<omb domain>",
    "m2131_el": "<el0–el3>"
  }
}
```

This enables:

* Domain filtering
* Tier-based routing
* Retention policy logic
* Dashboard reporting
* Audit traceability

---

# 6. Compliance Dashboards

An additional dashboard suite provides visibility into:

## 6.1 Domain Coverage

* Identity
* Endpoint
* Network
* DNS
* Cloud
* Application

## 6.2 Tier Distribution

* % logs by EL0–EL3
* Trend of maturity over time

## 6.3 Source Conformance

* Which sources lack precision mappings
* Sources defaulting to UNDEFINED
* Tier regression alerts

## 6.4 Investigative Readiness

* Presence of required categories
* Evidence of privileged access logging
* Data-plane logging coverage

---

# 7. Audit & Governance Benefits

This implementation provides:

* Deterministic classification logic
* Centralized override control
* Prevention of blanket EL3 assignments
* Evidence-backed maturity reporting
* Version-controlled reference tables
* Transparent override precedence

---

# 8. Operational Best Practices

* Normalize source values
* Keep reference tables under version control
* Review precision rules quarterly
* Monitor for UNDEFINED classifications
* Avoid hardcoding EL3 in baseline tables
* Use precision logic for high-risk sources only

---

# 9. Change Management

All classification logic changes should occur via:

* Reference table updates
* Pipeline version export
* Controlled deployment
* Dashboard validation

---

# 10. Custom Tier Metrics (EL0–EL3)

In addition to enriching each log with an `omb` classification object, this implementation generates **four custom metrics**, one aligned to each OMB M-21-31 maturity tier.

These metrics provide quantitative visibility into logging maturity and enable dashboarding, alerting, and executive reporting.

---

## Custom Metrics

The following log-based metrics are generated:

| Metric Name           | Description                      |
| --------------------- | -------------------------------- |
| `omb.m2131.el0` | Number of logs classified as EL0 |
| `omb.m2131.el1` | Number of logs classified as EL1 |
| `omb.m2131.el2` | Number of logs classified as EL2 |
| `omb.m2131.el3` | Number of logs classified as EL3 |

Each metric increments by 1 for every log where:

```
omb.m2131_el:<tier>
```

---

## Purpose of Tier Metrics

These metrics enable:

* Continuous monitoring of logging maturity distribution
* Trend analysis of EL progression over time
* Detection of regression (e.g., sudden spike in EL0)
* Executive-level compliance reporting
* Evidence of increasing investigative readiness
* Domain-level breakdowns when grouped by `omb.domain`

---

## Example Dashboard Visualizations

The tier metrics support:

* EL distribution pie chart
* Time-series trend of EL maturity
* EL2 + EL3 coverage ratio
* EL0 alert thresholds
* Domain vs Tier heatmaps

Example executive view:

```
Identity: EL3 dominant
Cloud: EL2 trending upward
Network: EL2 stable
Endpoint: EL3 high coverage
```

---

## Compliance Reporting Value

These metrics provide measurable evidence that:

* Logging maturity is continuously monitored
* Agencies can demonstrate quantitative progress
* EL regression is detectable in near real time
* Logging posture is operationalized, not static

This transforms OMB M-21-31 compliance from documentation-based reporting to measurable operational control.

---

# Summary

This framework transforms OMB M-21-31 from a compliance documentation exercise into an automated, continuously validated control within Datadog.

It ensures:

* Every log is classified
* Tiering is defensible
* Overrides are precise
* Compliance posture is measurable
* Investigative readiness is demonstrable
