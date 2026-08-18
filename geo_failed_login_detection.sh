#!/bin/bash

# ==========================================
# Geo-Based Brute-Force Detection
# SOC Investigation Project
# ==========================================

LOG_FILE="auth.log"
GEOIP_FILE="geoip.csv"
TRUSTED_COUNTRIES="trusted_countries.txt"
ALERT_FILE="alerts.csv"

THRESHOLD=5

echo "=========================================="
echo " Geo-Based Brute-Force Detection"
echo " SOC Investigation Module"
echo "=========================================="
echo

# Check required files
for FILE in "$LOG_FILE" "$GEOIP_FILE" "$TRUSTED_COUNTRIES"
do
    if [[ ! -f "$FILE" ]]; then
        echo "[ERROR] $FILE not found."
        exit 1
    fi
done

# Create CSV header
echo "timestamp,source_ip,country,failed_attempts,severity,geo_status,detection" > "$ALERT_FILE"

echo "[+] Log file       : $LOG_FILE"
echo "[+] GeoIP database : $GEOIP_FILE"
echo "[+] Threshold      : $THRESHOLD"
echo

echo "[+] Analyzing failed authentication events..."
echo

# ------------------------------------------
# Detection
# ------------------------------------------

grep "Failed password" "$LOG_FILE" |
awk '$6=="Failed" && $7=="password" {print $NF}' |
sort |
uniq -c |
sort -nr |
while read COUNT IP
do

    COUNTRY=$(awk -F',' -v ip="$IP" '$1 == ip {print $2}' "$GEOIP_FILE")

    if [[ -z "$COUNTRY" ]]; then
        COUNTRY="UNKNOWN"
    fi

    if grep -qx "$COUNTRY" "$TRUSTED_COUNTRIES"; then
        GEO_STATUS="TRUSTED"
    else
        GEO_STATUS="NON-TRUSTED"
    fi

    # Severity calculation
    if [[ $COUNT -ge 20 ]]; then
        SEVERITY="HIGH"
    elif [[ $COUNT -ge 10 ]]; then
        SEVERITY="MEDIUM"
    elif [[ $COUNT -ge $THRESHOLD ]]; then
        SEVERITY="LOW"
    else
        continue
    fi

    if [[ "$GEO_STATUS" == "NON-TRUSTED" ]]; then

        echo "------------------------------------------"
        echo "[ALERT] Brute-force activity detected"
        echo "Severity        : $SEVERITY"
        echo "Source IP       : $IP"
        echo "Country         : $COUNTRY"
        echo "Failed Attempts : $COUNT"
        echo "Geo Status      : $GEO_STATUS"
        echo "Detection       : SSH Brute-Force"
        echo "Recommended     : Investigate source IP"
        echo "------------------------------------------"
        echo

        echo "$(date '+%Y-%m-%d %H:%M:%S'),$IP,$COUNTRY,$COUNT,$SEVERITY,$GEO_STATUS,SSH-Brute-Force" >> "$ALERT_FILE"

    fi

done

# ------------------------------------------
# Investigation Statistics
# ------------------------------------------

echo
echo "=========================================="
echo " SOC INVESTIGATION SUMMARY"
echo "=========================================="

echo
echo "[+] Top Attacker IP:"
grep "Failed password" "$LOG_FILE" |
awk '$6=="Failed" && $7=="password" {print $NF}' |
sort |
uniq -c |
sort -nr |
head -1

echo
echo "[+] Most Targeted Username:"
grep "Failed password" "$LOG_FILE" |
awk '$6=="Failed" && $7=="password" {print $9}' |
sort |
uniq -c |
sort -nr |
head -1

echo
echo "[+] Country-wise Failed Attempts:"

for COUNTRY in $(cut -d',' -f2 "$GEOIP_FILE" | sort -u)
do
    COUNT=0

    while read IP GEO_COUNTRY
    do
        if [[ "$GEO_COUNTRY" == "$COUNTRY" ]]; then
            IP_COUNT=$(grep "Failed password" "$LOG_FILE" |
            awk -v ip="$IP" '$6=="Failed" && $7=="password" && $NF==ip {count++} END {print count+0}')

            COUNT=$((COUNT + IP_COUNT))
        fi
    done < <(awk -F',' '{print $1,$2}' "$GEOIP_FILE")

    echo "$COUNTRY : $COUNT attempts"
done

echo
echo "[+] Alert report generated:"
echo "    $ALERT_FILE"

echo
echo "=========================================="
echo "[+] Detection completed."
echo "=========================================="
