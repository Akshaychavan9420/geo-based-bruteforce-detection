#!/bin/bash

# ==========================================
# Geo-Based Brute-Force Detection
# SOC Detection Project
# ==========================================

LOG_FILE="auth.log"
GEOIP_FILE="geoip.csv"
TRUSTED_COUNTRIES="trusted_countries.txt"
THRESHOLD=5

echo "=========================================="
echo " Geo-Based Brute-Force Detection"
echo "=========================================="
echo

# Check files
for FILE in "$LOG_FILE" "$GEOIP_FILE" "$TRUSTED_COUNTRIES"
do
    if [[ ! -f "$FILE" ]]; then
        echo "[ERROR] $FILE not found."
        exit 1
    fi
done

echo "[+] Log file       : $LOG_FILE"
echo "[+] GeoIP database : $GEOIP_FILE"
echo "[+] Threshold      : $THRESHOLD"
echo

echo "[+] Analyzing failed authentication events..."
echo

# Extract source IPs from failed password events
grep "Failed password" "$LOG_FILE" |
awk '$6=="Failed" && $7=="password" {print $NF}' |
sort |
uniq -c |
sort -nr |
while read COUNT IP
do

    # Geo-IP lookup
    COUNTRY=$(awk -F',' -v ip="$IP" '$1 == ip {print $2}' "$GEOIP_FILE")

    if [[ -z "$COUNTRY" ]]; then
        COUNTRY="UNKNOWN"
    fi

    # Check trusted country
    if grep -qx "$COUNTRY" "$TRUSTED_COUNTRIES"; then
        GEO_STATUS="TRUSTED"
    else
        GEO_STATUS="NON-TRUSTED"
    fi

    # Severity
    if [[ $COUNT -ge 20 ]]; then
        SEVERITY="HIGH"
    elif [[ $COUNT -ge 10 ]]; then
        SEVERITY="MEDIUM"
    elif [[ $COUNT -ge $THRESHOLD ]]; then
        SEVERITY="LOW"
    else
        continue
    fi

    # Generate alert
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

    else

        echo "[INFO] $IP -> $COUNTRY -> $COUNT failed attempts -> Trusted"
        echo

    fi

done

echo "=========================================="
echo "[+] Detection completed."
echo "=========================================="
