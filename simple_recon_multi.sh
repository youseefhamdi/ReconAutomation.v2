#!/bin/bash

# =============================================================================
# Simple Reconnaissance Automation Suite v2.5
# Multi-Target Support Edition
# Coded by: Youssef Hamdi
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
WORDLIST="/usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt"

# Alternative wordlists if main one doesn't exist
if [ ! -f "$WORDLIST" ]; then
    WORDLIST="/usr/share/wordlists/dirb/common.txt"
fi

# Professional banner
print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "████████████████████████████████████████████████████████████████████████████████"
    echo "█                                                                              █"
    echo "█  ╔═══╗ ╔═══╗ ╔═══╗ ╔═══╗ ╔══╗  ╔═══╗        ╔═══╗ ╔═══╗ ╔═══╗ ╔══╗ ╔═══╗  █"
    echo "█  ║ ╔═╝ ║ ╔═╝ ║ ╔═╝ ║ ╔═╝ ║ ╔╗║ ║ ╔═╝        ║ ╔═╝ ║ ╔═╝ ║ ╔═╝ ║ ╔╗║ ║ ╔═╝  █"
    echo "█  ║ ╚═╗ ║ ╚═╗ ║ ║   ║ ║   ║ ║║║ ║ ╚═╗        ║ ║   ║ ║   ║ ║   ║ ║║║ ║ ║    █"
    echo "█  ║ ╔═╝ ║ ╔═╝ ║ ║   ║ ║   ║ ║║║ ║ ╔═╝        ║ ║   ║ ║   ║ ║   ║ ║║║ ║ ║    █"
    echo "█  ║ ║   ║ ╚═╗ ║ ╚═╗ ║ ╚═╗ ║ ╚╝║ ║ ╚═╗        ║ ╚═╗ ║ ╚═╗ ║ ╚═╗ ║ ╚╝║ ║ ╚═╗  █"
    echo "█  ╚═╝   ╚═══╝ ╚═══╝ ╚═══╝ ╚══╝  ╚═══╝        ╚═══╝ ╚═══╝ ╚═══╝ ╚══╝  ╚═══╝  █"
    echo "█                                                                              █"
    echo "████████████████████████████████████████████████████████████████████████████████"
    echo -e "${WHITE}${BOLD}"
    echo "                       Simple Reconnaissance Automation Suite"
    echo "                              Multi-Target Edition v2.5"
    echo "                            Coded by: Youssef Hamdi"
    echo ""
    echo "    🎯 Single & Multi-Target    🔍 8+ Recon Tools    📊 Quick Results"
    echo -e "${NC}"
}

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_target() { echo -e "${CYAN}[TARGET]${NC} $1"; }

# Function to check if input is a file or domain
check_input_type() {
    local input=$1

    if [ -f "$input" ]; then
        echo "file"
    elif [[ "$input" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
        echo "domain"
    else
        echo "invalid"
    fi
}

# Check if input provided
if [ -z "$1" ]; then
    print_banner
    print_error "Usage: $0 <domain|targets_file>"
    print_info "Examples:"
    print_info "  $0 example.com                    # Single domain"
    print_info "  $0 targets.txt                    # Multiple domains from file"
    exit 1
fi

INPUT=$1
INPUT_TYPE=$(check_input_type "$INPUT")

# Validate input
case $INPUT_TYPE in
    "domain")
        print_info "Single domain mode: $INPUT"
        OUTPUT_DIR="recon_${INPUT//[.:]/_}_${TIMESTAMP}"
        ;;
    "file")
        print_info "Multi-target mode: $INPUT"
        OUTPUT_DIR="recon_multi_target_${TIMESTAMP}"
        ;;
    "invalid")
        print_error "Invalid input: $INPUT"
        print_info "Please provide a valid domain or file path"
        exit 1
        ;;
esac

print_banner

# Create output structure
mkdir -p "$OUTPUT_DIR"/{subdomains,intelligence,final}

print_info "Starting reconnaissance..."
print_info "Output directory: $OUTPUT_DIR"

# Create targets file for tools
if [ "$INPUT_TYPE" = "domain" ]; then
    echo "$INPUT" > "$OUTPUT_DIR/targets.txt"
else
    cp "$INPUT" "$OUTPUT_DIR/targets.txt"
fi

TARGETS_FILE="$OUTPUT_DIR/targets.txt"

# 1. Subfinder
print_info "Running Subfinder..."
subfinder -dL "$TARGETS_FILE" -t 50 -o "$OUTPUT_DIR/subdomains/subfinder.txt" -all -silent
print_success "Subfinder completed"

# 2. AssetFinder - exactly as user specified
print_info "Running AssetFinder..."
cat "$TARGETS_FILE" | while read domain; do
    if [ ! -z "$domain" ]; then
        print_target "AssetFinder processing: $domain"
        assetfinder --subs-only "$domain"
    fi
done > "$OUTPUT_DIR/subdomains/assetfinder.txt"
print_success "AssetFinder completed"

# 3. Amass passive enumeration
print_info "Running Amass passive enumeration..."
amass enum -passive -df "$TARGETS_FILE" -o "$OUTPUT_DIR/subdomains/amass_passive.txt" 2>/dev/null
print_success "Amass passive enumeration completed"

# 4. BBOT - exactly as user specified
print_info "Running BBOT..."
timeout 600 bbot -l "$TARGETS_FILE" -p subdomain-enum cloud-enum code-enum email-enum spider web-basic paramminer dirbust-light web-screenshots --allow-deadly -o "$OUTPUT_DIR/bbot_output/" &>/dev/null || print_warning "BBOT completed with timeout"

# Extract subdomains from BBOT
find "$OUTPUT_DIR/bbot_output" -name "*.txt" -exec cat {} \; 2>/dev/null | grep -E "\.[a-zA-Z]{2,}$" | sort -u > "$OUTPUT_DIR/subdomains/bbot.txt" || touch "$OUTPUT_DIR/subdomains/bbot.txt"
print_success "BBOT completed"

# 5. FFUF subdomain fuzzing - for each domain
if [ -f "$WORDLIST" ]; then
    print_info "Running FFUF subdomain fuzzing..."
    > "$OUTPUT_DIR/subdomains/ffuf.txt"

    while read -r domain; do
        if [ ! -z "$domain" ]; then
            print_target "FFUF processing: $domain"
            ffuf -w "$WORDLIST" -u "https://FUZZ.$domain" -mc 200,301,302,403 -o "$OUTPUT_DIR/subdomains/ffuf_${domain//[.:]/_}.json" -of json -s 2>/dev/null

            # Extract domains from JSON
            if [ -f "$OUTPUT_DIR/subdomains/ffuf_${domain//[.:]/_}.json" ]; then
                jq -r '.results[].url' "$OUTPUT_DIR/subdomains/ffuf_${domain//[.:]/_}.json" 2>/dev/null | sed 's|https\?://||' | cut -d'/' -f1 >> "$OUTPUT_DIR/subdomains/ffuf.txt"
            fi
        fi
    done < "$TARGETS_FILE"

    sort -u "$OUTPUT_DIR/subdomains/ffuf.txt" -o "$OUTPUT_DIR/subdomains/ffuf.txt"
    print_success "FFUF completed"
else
    print_warning "No wordlist found for FFUF, skipping..."
    touch "$OUTPUT_DIR/subdomains/ffuf.txt"
fi

# 6. Subdog - exactly as user specified
print_info "Running Subdog..."
cat "$TARGETS_FILE" | subdog -tools all > "$OUTPUT_DIR/subdomains/subdog.txt" 2>/dev/null || touch "$OUTPUT_DIR/subdomains/subdog.txt"
print_success "Subdog completed"

# 7. Sudomy - with loop since it doesn't support lists
print_info "Running Sudomy (with loop - no native list support)..."
> "$OUTPUT_DIR/subdomains/sudomy.txt"

while read -r domain; do
    if [ ! -z "$domain" ]; then
        print_target "Sudomy processing: $domain"
        clean_domain=${domain//[.:]/_}

        timeout 300 sudomy -d "$domain" --all -o "$OUTPUT_DIR/sudomy_${clean_domain}/" 2>/dev/null || print_warning "Sudomy timeout for $domain"

        if [ -d "$OUTPUT_DIR/sudomy_${clean_domain}" ]; then
            find "$OUTPUT_DIR/sudomy_${clean_domain}" -name "*.txt" -exec cat {} \; 2>/dev/null | grep -E "\.$domain$" >> "$OUTPUT_DIR/subdomains/sudomy.txt"
        fi
    fi
done < "$TARGETS_FILE"

sort -u "$OUTPUT_DIR/subdomains/sudomy.txt" -o "$OUTPUT_DIR/subdomains/sudomy.txt"
print_success "Sudomy completed"

# 8. DNScan - exactly as user specified
if [ -f "$WORDLIST" ]; then
    print_info "Running DNScan..."
    dnscan -l "$TARGETS_FILE" -w "$WORDLIST" -r --maxdepth 3 -o "$OUTPUT_DIR/subdomains/dnscan.txt" 2>/dev/null || touch "$OUTPUT_DIR/subdomains/dnscan.txt"
    print_success "DNScan completed"
else
    print_warning "No wordlist found for DNScan, skipping..."
    touch "$OUTPUT_DIR/subdomains/dnscan.txt"
fi

# Aggregate all subdomains
print_info "Aggregating all subdomains..."
cat "$OUTPUT_DIR"/subdomains/*.txt 2>/dev/null | grep -E "\.[a-zA-Z]{2,}$" | sort -u > "$OUTPUT_DIR/final/all_subdomains.txt"
TOTAL_SUBS=$(wc -l < "$OUTPUT_DIR/final/all_subdomains.txt")
print_success "Found $TOTAL_SUBS unique subdomains"

# 9. Amass intel - organization (for each target)
print_info "Running Amass intel for organizations..."
> "$OUTPUT_DIR/intelligence/org_intel.txt"

while read -r domain; do
    if [ ! -z "$domain" ]; then
        print_target "Intel gathering for: $domain"
        ORG_NAME=$(echo "$domain" | cut -d'.' -f1)
        amass intel -org "$ORG_NAME" -o "$OUTPUT_DIR/intelligence/org_${domain//[.:]/_}.txt" 2>/dev/null || true

        if [ -f "$OUTPUT_DIR/intelligence/org_${domain//[.:]/_}.txt" ]; then
            cat "$OUTPUT_DIR/intelligence/org_${domain//[.:]/_}.txt" >> "$OUTPUT_DIR/intelligence/org_intel.txt"
        fi
    fi
done < "$TARGETS_FILE"

print_success "Organization intelligence completed"

# 10. Amass intel - ASN (if org intel found ASNs)
if [ -s "$OUTPUT_DIR/intelligence/org_intel.txt" ]; then
    print_info "Running Amass intel for ASNs..."
    grep -oE 'AS[0-9]+' "$OUTPUT_DIR/intelligence/org_intel.txt" | head -5 | while read -r asn; do
        if [ ! -z "$asn" ]; then
            print_info "Processing ASN: $asn"
            amass intel -active -asn "$asn" -o "$OUTPUT_DIR/intelligence/asn_${asn}.txt" 2>/dev/null || true
        fi
    done

    # Combine ASN results
    cat "$OUTPUT_DIR/intelligence/asn_"*.txt > "$OUTPUT_DIR/intelligence/all_asn.txt" 2>/dev/null || touch "$OUTPUT_DIR/intelligence/all_asn.txt"
    print_success "ASN intelligence completed"
fi

# 11. Amass intel - CIDR (if ASN intel found CIDRs)
if [ -s "$OUTPUT_DIR/intelligence/all_asn.txt" ]; then
    print_info "Running Amass intel for CIDR ranges..."
    grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]+" "$OUTPUT_DIR/intelligence/all_asn.txt" | head -3 | while read -r cidr; do
        if [ ! -z "$cidr" ]; then
            print_info "Processing CIDR: $cidr"
            amass intel -active -cidr "$cidr" -o "$OUTPUT_DIR/intelligence/cidr_${cidr//\//_}.txt" 2>/dev/null || true
        fi
    done
    print_success "CIDR intelligence completed"
fi

# 12. WHOIS lookups for IP ranges
if [ -s "$OUTPUT_DIR/intelligence/all_asn.txt" ]; then
    print_info "Performing WHOIS lookups..."
    grep -oE 'AS[0-9]+' "$OUTPUT_DIR/intelligence/all_asn.txt" | head -3 | while read -r asn; do
        if [ ! -z "$asn" ]; then
            ASN_NUM=$(echo "$asn" | sed 's/AS//')
            whois -h whois.radb.net -- "-i origin AS$ASN_NUM" | grep -Eo "([0-9.]+){4}/[0-9]+" | sort -u >> "$OUTPUT_DIR/intelligence/whois_cidrs.txt" 2>/dev/null || true
        fi
    done
    print_success "WHOIS lookups completed"
fi

# 13. Reverse DNS lookups
if [ -s "$OUTPUT_DIR/intelligence/whois_cidrs.txt" ]; then
    print_info "Performing reverse DNS lookups..."
    head -3 "$OUTPUT_DIR/intelligence/whois_cidrs.txt" | while read -r cidr_range; do
        if [ ! -z "$cidr_range" ]; then
            print_info "Reverse DNS for: $cidr_range"
            prips "$cidr_range" 2>/dev/null | head -20 | while read -r ip; do
                reverse_result=$(dig -x "$ip" +short 2>/dev/null)
                if [ ! -z "$reverse_result" ] && [ "$reverse_result" != ";" ]; then
                    echo "$ip -> $reverse_result" >> "$OUTPUT_DIR/intelligence/reverse_dns.txt"
                fi
            done
        fi
    done
    print_success "Reverse DNS lookups completed"
fi

# Generate summary
TARGET_COUNT=$(wc -l < "$TARGETS_FILE")
cat > "$OUTPUT_DIR/summary.txt" << EOF
RECONNAISSANCE SUMMARY
Simple Reconnaissance Automation Suite v2.5
Coded by: Youssef Hamdi
=====================================
Generated: $(date)
Target(s): $(tr '\n' ', ' < "$TARGETS_FILE" | sed 's/,$//')
Number of targets: $TARGET_COUNT
Total Subdomains: $TOTAL_SUBS

Tool Results:
- Subfinder: $(wc -l < "$OUTPUT_DIR/subdomains/subfinder.txt" 2>/dev/null || echo 0)
- AssetFinder: $(wc -l < "$OUTPUT_DIR/subdomains/assetfinder.txt" 2>/dev/null || echo 0)
- Amass: $(wc -l < "$OUTPUT_DIR/subdomains/amass_passive.txt" 2>/dev/null || echo 0)
- BBOT: $(wc -l < "$OUTPUT_DIR/subdomains/bbot.txt" 2>/dev/null || echo 0)
- FFUF: $(wc -l < "$OUTPUT_DIR/subdomains/ffuf.txt" 2>/dev/null || echo 0)
- Subdog: $(wc -l < "$OUTPUT_DIR/subdomains/subdog.txt" 2>/dev/null || echo 0)
- Sudomy: $(wc -l < "$OUTPUT_DIR/subdomains/sudomy.txt" 2>/dev/null || echo 0)
- DNScan: $(wc -l < "$OUTPUT_DIR/subdomains/dnscan.txt" 2>/dev/null || echo 0)

Target Breakdown:
EOF

# Add per-target breakdown
while read -r domain; do
    if [ ! -z "$domain" ]; then
        domain_count=$(grep -c "\.$domain$" "$OUTPUT_DIR/final/all_subdomains.txt" 2>/dev/null || echo 0)
        echo "- $domain: $domain_count subdomains" >> "$OUTPUT_DIR/summary.txt"
    fi
done < "$TARGETS_FILE"

cat >> "$OUTPUT_DIR/summary.txt" << EOF

Key Files:
- final/all_subdomains.txt: All unique subdomains
- intelligence/: Organization, ASN, and CIDR data
- intelligence/reverse_dns.txt: Reverse DNS results
- targets.txt: Input targets used

Intelligence:
- Organization intel: $(wc -l < "$OUTPUT_DIR/intelligence/org_intel.txt" 2>/dev/null || echo 0) entries
- ASN intel: $(ls "$OUTPUT_DIR/intelligence/asn_"*.txt 2>/dev/null | wc -l || echo 0) ASNs processed
- Reverse DNS: $(wc -l < "$OUTPUT_DIR/intelligence/reverse_dns.txt" 2>/dev/null || echo 0) entries
EOF

print_success "Reconnaissance completed!"
print_info "Summary: $OUTPUT_DIR/summary.txt"
print_info "All subdomains: $OUTPUT_DIR/final/all_subdomains.txt"
print_info "Check $OUTPUT_DIR for all results"

# Final stats display
echo -e "${CYAN}${BOLD}"
echo "┌─────────────────────────────────────────┐"
echo "│            SCAN SUMMARY                 │"
echo "├─────────────────────────────────────────┤"
printf "│ Targets Scanned: %-18s │\n" "$TARGET_COUNT"
printf "│ Subdomains Found: %-17s │\n" "$TOTAL_SUBS"
printf "│ Output Directory: %-18s │\n" "$(basename "$OUTPUT_DIR")"
echo "└─────────────────────────────────────────┘"
echo -e "${NC}"
