# SOC Incident Report
## Geo-Based SSH Brute-Force Detection

### 1. Incident Summary

A simulated SSH brute-force attack was detected through repeated failed authentication attempts originating from non-trusted geographic locations.

### 2. Detection

Detection Type: SSH Brute-Force  
Detection Method: Bash log analysis + Geo-IP enrichment  
Threshold: 5 failed attempts per source IP

### 3. Indicators of Compromise

| Source IP | Country | Failed Attempts | Severity |
|-----------|---------|-----------------|----------|
| 203.0.113.10 | CN | 6 | LOW |
| 198.51.100.25 | RU | 6 | LOW |

### 4. Analysis

The authentication log was parsed to identify failed SSH password attempts.

Source IP addresses were extracted and correlated with a simulated Geo-IP database.

IPs originating from non-trusted countries were compared against the configured failure threshold.

Both identified IP addresses exceeded the threshold and generated detection alerts.

### 5. MITRE ATT&CK Mapping

Technique: T1110 - Brute Force  
Tactic: Credential Access

### 6. Recommended Response

1. Investigate the source IP addresses.
2. Review additional authentication events.
3. Check whether any successful login occurred after the failed attempts.
4. Identify targeted usernames.
5. Block or rate-limit malicious sources according to organizational policy.
6. Continue monitoring for repeated activity.

### 7. Conclusion

The detection successfully identified repeated SSH authentication failures from non-trusted geographic locations and generated SOC-style alerts for further investigation.

> Disclaimer: All IP addresses, logs, and geographic information in this project are simulated for educational and defensive security purposes.
