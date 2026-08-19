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
   

## 📂 Input Files

### 1. auth.log

Contains simulated SSH authentication failure events.

Example:

```text
Aug 18 09:01:12 kali sshd[1011]: Failed password for root from 203.0.113.10
Aug 18 09:02:18 kali sshd[1012]: Failed password for admin from 203.0.113.10
Aug 18 09:07:11 kali sshd[1017]: Failed password for test from 198.51.100.25
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

## 🔍 Detection Logic

The detection script follows a SOC-style authentication monitoring workflow:

1. Read SSH authentication events from `auth.log`.
2. Identify failed password authentication attempts.
3. Extract the source IP address from each event.
4. Count failed attempts for each unique source IP.
5. Enrich the source IP using the simulated `geoip.csv` database.
6. Determine whether the source country is trusted or non-trusted.
7. Compare the failed-attempt count against the configured threshold.
8. Assign severity based on the number of attempts:
   - LOW: 5–9 attempts
   - MEDIUM: 10–19 attempts
   - HIGH: 20+ attempts
9. Generate an alert when a non-trusted source exceeds the threshold.
10. Save detected events to `alerts.csv`.
11. Generate investigation statistics such as:
    - Top attacker IP
    - Most targeted username
    - Country-wise failed attempts


## ▶️ Usage

### Step 1 — Clone the repository

```bash
git clone https://github.com/Akshaychavan9420/geo-based-bruteforce-detection.git
cd geo-based-bruteforce-detection
