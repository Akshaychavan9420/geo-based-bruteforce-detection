# Geo-Based Brute-Force Detection | SOC Bash Project

## 📌 Overview

This project simulates a Security Operations Center (SOC) detection use case for identifying repeated failed SSH authentication attempts originating from non-trusted geographic locations.

The project uses Bash scripting to analyze authentication logs, extract source IP addresses, enrich them with simulated Geo-IP information, apply configurable detection thresholds, and generate SOC-style alerts.

---

## 🎯 Objectives

- Detect repeated SSH authentication failures
- Identify suspicious source IP addresses
- Perform Geo-IP enrichment
- Compare countries against a trusted-country list
- Assign risk severity based on failed attempts
- Generate automated CSV alerts
- Produce SOC investigation statistics
- Map the detection to MITRE ATT&CK

---

## 🏗️ Detection Architecture

```text
              Authentication Logs
                      |
                      v
                  auth.log
                      |
                      v
              Extract Source IP
                      |
                      v
                Geo-IP Lookup
                      |
                      v
                Country Code
                      |
             +--------+--------+
             |                 |
             v                 v
         Trusted           Non-Trusted
             |                 |
             |                 v
             |          Failed Attempt
             |             Threshold
             |                 |
             |                 v
             |           Risk Severity
             |                 |
             |                 v
             |            SOC Alert
             |                 |
             +--------+--------+
                      |
                      v
               alerts.csv
