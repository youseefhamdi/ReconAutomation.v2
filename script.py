# Let me create an upgraded version that supports both single targets and lists of targets
# Based on the user's commands file and requirements

advanced_script_upgraded = '''#!/bin/bash

# =============================================================================
# Advanced Reconnaissance Automation Suite v2.5
# Multi-Target Support Edition
# Coded by: Youssef Hamdi
# =============================================================================

# Color codes for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
PURPLE='\\033[0;35m'
CYAN='\\033[0;36m'
WHITE='\\033[1;37m'
BOLD='\\033[1m'
NC='\\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MAX_PARALLEL_JOBS=10

# Function to print professional banner
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
    echo "█           ╔═══╗ ╔╗ ╔╗ ╔════╗ ╔═══╗        ╔═══╗ ╔╗ ╔╗ ╔════╗ ╔═══╗         █"
    echo "█           ║ ╔═╝ ║║ ║║ ║ ╔══╝ ║ ╔═╝        ║ ╔═╝ ║║ ║║ ║ ╔══╝ ║ ╔═╝         █"
    echo "█           ║ ║   ║╚═╝║ ║ ╚══╗ ║ ║          ║ ║   ║╚═╝║ ║ ╚══╗ ║ ║           █"
    echo "█           ║ ║   ║ ╔ ║ ║ ╔══╝ ║ ║          ║ ║   ║ ╔ ║ ║ ╔══╝ ║ ║           █"
    echo "█           ║ ╚═╗ ║ ║ ║ ║ ╚══╗ ║ ╚═╗        ║ ╚═╗ ║ ║ ║ ║ ╚══╗ ║ ╚═╗         █"
    echo "█           ╚═══╝ ╚═╝ ╚═╝ ╚═══╝ ╚═══╝        ╚═══╝ ╚═╝ ╚═╝ ╚═══╝ ╚═══╝         █"
    echo "█                                                                              █"
    echo "████████████████████████████████████████████████████████████████████████████████"
    echo -e "${WHITE}${BOLD}"
    echo "                     Advanced Reconnaissance Automation Suite"
    echo "                              Multi-Target Edition v2.5"
    echo "                            Coded by: Youssef Hamdi"
    echo ""
    echo "    🎯 Single Target Support    📋 Multi-Target Support    ⚡ Parallel Execution"
    echo "    🔍 8+ Recon Tools          📊 Intelligence Gathering   📈 Professional Reports"
    echo -e "${NC}"
}

# Function to print colored output
print_status() {
    local level=$1
    local message=$2
    case $level in
        "INFO")
            echo -e "${BLUE}[INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        "PHASE")
            echo -e "${PURPLE}[PHASE]${NC} $message"
            ;;
        "TARGET")
            echo -e "${CYAN}[TARGET]${NC} $message"
            ;;
    esac
}

# Function to check if input is a file or domain
check_input_type() {
    local input=$1
    
    if [ -f "$input" ]; then
        echo "file"
    elif [[ "$input" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,}$ ]]; then
        echo "domain"
    else
        echo "invalid"
    fi
}

# Function to validate domains in file
validate_domain_file() {
    local file=$1
    local valid_count=0
    local total_count=0
    
    while read -r line; do
        if [ ! -z "$line" ]; then
            total_count=$((total_count + 1))
            if [[ "$line" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,}$ ]]; then
                valid_count=$((valid_count + 1))
            else
                print_status "WARNING" "Invalid domain format: $line"
            fi
        fi
    done < "$file"
    
    print_status "INFO" "Found $valid_count valid domains out of $total_count entries"
    return $valid_count
}

# Function to check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_status "ERROR" "Command '$1' not found. Please install it first."
        return 1
    fi
    return 0
}

# Function to check tool dependencies
check_dependencies() {
    print_status "INFO" "Checking tool dependencies..."
    
    local tools=("subfinder" "assetfinder" "amass" "bbot" "ffuf" "subdog" "sudomy" "dnscan" "whois" "prips" "dig" "httpx" "nuclei" "anew" "sort" "uniq" "jq")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! check_command "$tool"; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_status "ERROR" "Missing tools: ${missing_tools[*]}"
        print_status "INFO" "Please install missing tools before running the script."
        exit 1
    fi
    
    print_status "SUCCESS" "All required tools are available."
}

# Function to create output directory structure
setup_directories() {
    local target_info=$1
    local base_dir="recon_${target_info}_${TIMESTAMP}"
    
    mkdir -p "$base_dir"/{subdomains,enumeration,intelligence,ports,screenshots,reports,wordlists,raw_output}
    mkdir -p "$base_dir"/subdomains/{subfinder,assetfinder,amass,bbot,ffuf,subdog,sudomy,dnscan}
    mkdir -p "$base_dir"/enumeration/{live_hosts,technologies,certificates}
    mkdir -p "$base_dir"/intelligence/{org_intel,asn_intel,cidr_intel,whois_data}
    
    echo "$base_dir"
}

# Function to create targets file for tools that need it
create_targets_file() {
    local input=$1
    local output_dir=$2
    local input_type=$(check_input_type "$input")
    
    if [ "$input_type" = "domain" ]; then
        echo "$input" > "$output_dir/targets.txt"
    elif [ "$input_type" = "file" ]; then
        cp "$input" "$output_dir/targets.txt"
    fi
    
    echo "$output_dir/targets.txt"
}

# Function to run subfinder
run_subfinder() {
    local targets_file=$1
    local output_dir=$2
    
    print_status "INFO" "Running Subfinder..."
    subfinder -dL "$targets_file" -t 50 -o "$output_dir/subdomains/subfinder/subfinder.txt" -all -silent
    
    if [ -f "$output_dir/subdomains/subfinder/subfinder.txt" ]; then
        local count=$(wc -l < "$output_dir/subdomains/subfinder/subfinder.txt")
        print_status "SUCCESS" "Subfinder found $count subdomains"
    else
        print_status "WARNING" "Subfinder output file not created"
        touch "$output_dir/subdomains/subfinder/subfinder.txt"
    fi
}

# Function to run assetfinder
run_assetfinder() {
    local targets_file=$1
    local output_dir=$2
    
    print_status "INFO" "Running AssetFinder..."
    
    # Use the exact command format from user's file
    cat "$targets_file" | while read domain; do
        if [ ! -z "$domain" ]; then
            print_status "TARGET" "AssetFinder processing: $domain"
            assetfinder --subs-only "$domain"
        fi
    done > "$output_dir/subdomains/assetfinder/assetfinder.txt" 2>/dev/null
    
    if [ -f "$output_dir/subdomains/assetfinder/assetfinder.txt" ]; then
        local count=$(wc -l < "$output_dir/subdomains/assetfinder/assetfinder.txt")
        print_status "SUCCESS" "AssetFinder found $count subdomains"
    else
        print_status "WARNING" "AssetFinder output file not created"
        touch "$output_dir/subdomains/assetfinder/assetfinder.txt"
    fi
}

# Function to run amass passive enumeration
run_amass_passive() {
    local targets_file=$1
    local output_dir=$2
    
    print_status "INFO" "Running Amass passive enumeration..."
    amass enum -passive -df "$targets_file" -o "$output_dir/subdomains/amass/amass_passive.txt" 2>/dev/null
    
    if [ -f "$output_dir/subdomains/amass/amass_passive.txt" ]; then
        local count=$(wc -l < "$output_dir/subdomains/amass/amass_passive.txt")
        print_status "SUCCESS" "Amass passive found $count subdomains"
    else
        print_status "WARNING" "Amass passive output file not created"
        touch "$output_dir/subdomains/amass/amass_passive.txt"
    fi
}

# Function to run bbot
run_bbot() {
    local targets_file=$1
    local output_dir=$2
    
    print_status "INFO" "Running BBOT..."
    # Use exact command format from user's file
    timeout 600 bbot -l "$targets_file" -p subdomain-enum cloud-enum code-enum email-enum spider web-basic paramminer dirbust-light web-screenshots --allow-deadly -o "$output_dir/subdomains/bbot/" 2>/dev/null || true
    
    # Extract subdomains from bbot output
    if [ -d "$output_dir/subdomains/bbot" ]; then
        find "$output_dir/subdomains/bbot" -name "*.txt" -exec cat {} \\; 2>/dev/null | \
            grep -E "^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$" | sort -u > "$output_dir/subdomains/bbot/bbot_subdomains.txt" || \
            touch "$output_dir/subdomains/bbot/bbot_subdomains.txt"
        
        local count=$(wc -l < "$output_dir/subdomains/bbot/bbot_subdomains.txt" 2>/dev/null || echo 0)
        print_status "SUCCESS" "BBOT found $count subdomains"
    else
        print_status "WARNING" "BBOT output directory not created"
        mkdir -p "$output_dir/subdomains/bbot"
        touch "$output_dir/subdomains/bbot/bbot_subdomains.txt"
    fi
}

# Function to run ffuf subdomain fuzzing
run_ffuf() {
    local targets_file=$1
    local output_dir=$2
    local wordlist="/usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt"
    
    # Use smaller wordlist if main one doesn't exist
    if [ ! -f "$wordlist" ]; then
        wordlist="/usr/share/wordlists/dirb/common.txt"
    fi
    
    if [ ! -f "$wordlist" ]; then
        print_status "WARNING" "No wordlist found for ffuf, skipping..."
        touch "$output_dir/subdomains/ffuf/ffuf.txt"
        return
    fi
    
    print_status "INFO" "Running FFUF subdomain fuzzing..."
    
    # Run ffuf for each domain in targets file
    > "$output_dir/subdomains/ffuf/ffuf.txt"
    while read -r domain; do
        if [ ! -z "$domain" ]; then
            print_status "TARGET" "FFUF processing: $domain"
            ffuf -w "$wordlist" -u "https://FUZZ.$domain" -mc 200,301,302,403 -o "$output_dir/subdomains/ffuf/ffuf_${domain//[.:]/_}.json" -of json -s 2>/dev/null || true
            
            # Extract subdomains from ffuf json output
            if [ -f "$output_dir/subdomains/ffuf/ffuf_${domain//[.:]/_}.json" ]; then
                jq -r '.results[].url' "$output_dir/subdomains/ffuf/ffuf_${domain//[.:]/_}.json" 2>/dev/null | \
                    sed 's|https\\?://||' | cut -d'/' -f1 >> "$output_dir/subdomains/ffuf/ffuf.txt" || true
            fi
        fi
    done < "$targets_file"
    
    if [ -f "$output_dir/subdomains/ffuf/ffuf.txt" ]; then
        sort -u "$output_dir/subdomains/ffuf/ffuf.txt" -o "$output_dir/subdomains/ffuf/ffuf.txt"
        local count=$(wc -l < "$output_dir/subdomains/ffuf/ffuf.txt")
        print_status "SUCCESS" "FFUF found $count subdomains"
    fi
}

# Function to run subdog
run_subdog() {
    local targets_file=$1
    local output_dir=$2
    
    print_status "INFO" "Running Subdog..."
    # Use exact command format from user's file
    cat "$targets_file" | subdog -tools all > "$output_dir/subdomains/subdog/subdog.txt" 2>/dev/null || \
        touch "$output_dir/subdomains/subdog/subdog.txt"
    
    if [ -f "$output_dir/subdomains/subdog/subdog.txt" ]; then
        local count=$(wc -l < "$output_dir/subdomains/subdog/subdog.txt")
        print_status "SUCCESS" "Subdog found $count subdomains"
    else
        print_status "WARNING" "Subdog output file not created"
        touch "$output_dir/subdomains/subdog/subdog.txt"
    fi
}

# Function to run sudomy - with loop since it doesn't support lists
run_sudomy() {
    local targets_file=$1
    local output_dir=$2
    
    print_status "INFO" "Running Sudomy (with loop - no native list support)..."
    
    # Create temporary directory for individual sudomy results
    mkdir -p "$output_dir/subdomains/sudomy/individual"
    
    # Loop through each domain since sudomy doesn't support lists
    > "$output_dir/subdomains/sudomy/sudomy.txt"
    while read -r domain; do
        if [ ! -z "$domain" ]; then
            print_status "TARGET" "Sudomy processing: $domain"
            
            # Clean domain name for filename
            local clean_domain=${domain//[.:]/_}
            
            timeout 300 sudomy -d "$domain" --all -o "$output_dir/subdomains/sudomy/individual/sudomy_${clean_domain}/" 2>/dev/null || true
            
            # Collect results from this domain
            if [ -d "$output_dir/subdomains/sudomy/individual/sudomy_${clean_domain}" ]; then
                find "$output_dir/subdomains/sudomy/individual/sudomy_${clean_domain}" -name "*.txt" -exec cat {} \\; 2>/dev/null | \
                    grep -E "^[a-zA-Z0-9.-]+\\.$domain$" >> "$output_dir/subdomains/sudomy/sudomy.txt" || true
            fi
        fi
    done < "$targets_file"
    
    # Sort and deduplicate final results
    if [ -f "$output_dir/subdomains/sudomy/sudomy.txt" ]; then
        sort -u "$output_dir/subdomains/sudomy/sudomy.txt" -o "$output_dir/subdomains/sudomy/sudomy.txt"
        local count=$(wc -l < "$output_dir/subdomains/sudomy/sudomy.txt")
        print_status "SUCCESS" "Sudomy found $count subdomains"
    else
        print_status "WARNING" "Sudomy output file not created"
        touch "$output_dir/subdomains/sudomy/sudomy.txt"
    fi
}

# Function to run dnscan
run_dnscan() {
    local targets_file=$1
    local output_dir=$2
    local wordlist="/usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt"
    
    if [ ! -f "$wordlist" ]; then
        wordlist="/usr/share/wordlists/dirb/common.txt"
    fi
    
    if [ ! -f "$wordlist" ]; then
        print_status "WARNING" "No wordlist found for dnscan, skipping..."
        touch "$output_dir/subdomains/dnscan/dnscan.txt"
        return
    fi
    
    print_status "INFO" "Running DNScan..."
    # Use exact command format from user's file
    dnscan -l "$targets_file" -w "$wordlist" -r --maxdepth 3 -o "$output_dir/subdomains/dnscan/dnscan.txt" 2>/dev/null || \
        touch "$output_dir/subdomains/dnscan/dnscan.txt"
    
    if [ -f "$output_dir/subdomains/dnscan/dnscan.txt" ]; then
        local count=$(wc -l < "$output_dir/subdomains/dnscan/dnscan.txt")
        print_status "SUCCESS" "DNScan found $count subdomains"
    else
        print_status "WARNING" "DNScan output file not created"
        touch "$output_dir/subdomains/dnscan/dnscan.txt"
    fi
}

# Function to aggregate and clean subdomains
aggregate_subdomains() {
    local output_dir=$1
    local targets_file=$2
    
    print_status "PHASE" "Aggregating and cleaning subdomain results..."
    
    # Combine all subdomain sources
    cat "$output_dir"/subdomains/*/subfinder.txt \\
        "$output_dir"/subdomains/*/assetfinder.txt \\
        "$output_dir"/subdomains/*/amass_passive.txt \\
        "$output_dir"/subdomains/*/bbot_subdomains.txt \\
        "$output_dir"/subdomains/*/ffuf.txt \\
        "$output_dir"/subdomains/*/subdog.txt \\
        "$output_dir"/subdomains/*/sudomy.txt \\
        "$output_dir"/subdomains/*/dnscan.txt 2>/dev/null | \\
        sort -u > "$output_dir/subdomains/all_subdomains_raw.txt"
    
    # Clean and validate subdomains
    grep -vE "(^\\.|\\.\\.|\\.\\.$|^-|-$)" "$output_dir/subdomains/all_subdomains_raw.txt" | \\
        grep -E "^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,}$" | \\
        sort -u > "$output_dir/subdomains/all_subdomains_clean.txt"
    
    local total_count=$(wc -l < "$output_dir/subdomains/all_subdomains_clean.txt")
    print_status "SUCCESS" "Total unique subdomains found: $total_count"
    
    # Save final list
    cp "$output_dir/subdomains/all_subdomains_clean.txt" "$output_dir/final_subdomains.txt"
}

# Function to run amass intelligence gathering
run_amass_intel() {
    local targets_file=$1
    local output_dir=$2
    
    print_status "PHASE" "Running Amass intelligence gathering..."
    
    # Organization intelligence for each domain
    print_status "INFO" "Gathering organization intelligence..."
    > "$output_dir/intelligence/org_intel/org_intel.txt"
    
    while read -r domain; do
        if [ ! -z "$domain" ]; then
            print_status "TARGET" "Intel gathering for: $domain"
            local org_name=$(echo "$domain" | cut -d'.' -f1)
            amass intel -org "$org_name" -o "$output_dir/intelligence/org_intel/org_${domain//[.:]/_}.txt" 2>/dev/null || true
            
            if [ -f "$output_dir/intelligence/org_intel/org_${domain//[.:]/_}.txt" ]; then
                cat "$output_dir/intelligence/org_intel/org_${domain//[.:]/_}.txt" >> "$output_dir/intelligence/org_intel/org_intel.txt"
            fi
        fi
    done < "$targets_file"
    
    # If we have organization data, get ASN information
    if [ -s "$output_dir/intelligence/org_intel/org_intel.txt" ]; then
        print_status "INFO" "Gathering ASN intelligence..."
        while read -r asn_line; do
            if [[ $asn_line =~ AS[0-9]+ ]]; then
                local asn=$(echo "$asn_line" | grep -oE 'AS[0-9]+')
                amass intel -active -asn "$asn" -o "$output_dir/intelligence/asn_intel/asn_${asn}.txt" 2>/dev/null || true
            fi
        done < "$output_dir/intelligence/org_intel/org_intel.txt"
        
        # Combine all ASN results
        cat "$output_dir/intelligence/asn_intel"/*.txt > "$output_dir/intelligence/asn_intel/all_asn.txt" 2>/dev/null || \
            touch "$output_dir/intelligence/asn_intel/all_asn.txt"
    fi
}

# Function to perform reverse DNS lookups
run_reverse_dns() {
    local output_dir=$1
    
    print_status "PHASE" "Performing reverse DNS lookups..."
    
    if [ -s "$output_dir/intelligence/asn_intel/all_asn.txt" ]; then
        print_status "INFO" "Extracting IP ranges and performing reverse DNS..."
        
        # Extract CIDR ranges and perform reverse DNS
        grep -oE "([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]+" "$output_dir/intelligence/asn_intel/all_asn.txt" | \
            sort -u > "$output_dir/intelligence/cidr_ranges.txt"
        
        while read -r cidr; do
            if [ ! -z "$cidr" ]; then
                print_status "INFO" "Processing CIDR range: $cidr"
                
                # Use prips to generate IP list and perform reverse DNS
                prips "$cidr" 2>/dev/null | head -100 | while read -r ip; do
                    reverse_record=$(dig -x "$ip" +short 2>/dev/null)
                    if [ ! -z "$reverse_record" ] && [ "$reverse_record" != ";" ]; then
                        echo "$ip -> $reverse_record"
                    fi
                done >> "$output_dir/intelligence/reverse_dns_results.txt" 2>/dev/null || true
            fi
        done < "$output_dir/intelligence/cidr_ranges.txt"
    fi
}

# Function to generate summary report
generate_report() {
    local output_dir=$1
    local targets_file=$2
    local start_time=$3
    local end_time=$4
    
    local report_file="$output_dir/reports/reconnaissance_report.txt"
    
    print_status "PHASE" "Generating reconnaissance report..."
    
    cat > "$report_file" << EOF
=============================================================================
RECONNAISSANCE REPORT
Advanced Reconnaissance Automation Suite v2.5
Coded by: Youssef Hamdi
=============================================================================
Target(s): $(tr '\\n' ', ' < "$targets_file" | sed 's/,$//')
Number of targets: $(wc -l < "$targets_file")
Scan Start Time: $(date -d "@$start_time")
Scan End Time: $(date -d "@$end_time")
Duration: $((end_time - start_time)) seconds
Generated: $(date)

=============================================================================
SUBDOMAIN ENUMERATION RESULTS
=============================================================================
EOF

    # Add subdomain statistics
    echo "Tool Results:" >> "$report_file"
    for tool_dir in "$output_dir"/subdomains/*/; do
        local tool_name=$(basename "$tool_dir")
        local tool_file=$(find "$tool_dir" -name "*.txt" | head -1)
        if [ -f "$tool_file" ]; then
            local count=$(wc -l < "$tool_file")
            printf "%-15s: %d subdomains\\n" "$tool_name" "$count" >> "$report_file"
        fi
    done
    
    echo "" >> "$report_file"
    echo "Total Unique Subdomains: $(wc -l < "$output_dir/final_subdomains.txt")" >> "$report_file"
    
    # Add top 10 subdomains
    echo "" >> "$report_file"
    echo "Sample Subdomains (first 10):" >> "$report_file"
    head -10 "$output_dir/final_subdomains.txt" >> "$report_file"
    
    echo "" >> "$report_file"
    echo "==============================================================================" >> "$report_file"
    echo "TARGET BREAKDOWN:" >> "$report_file"
    echo "==============================================================================" >> "$report_file"
    
    # Show breakdown per target
    while read -r domain; do
        if [ ! -z "$domain" ]; then
            local domain_count=$(grep -c "\\.$domain$" "$output_dir/final_subdomains.txt" 2>/dev/null || echo 0)
            echo "- $domain: $domain_count subdomains" >> "$report_file"
        fi
    done < "$targets_file"
    
    echo "" >> "$report_file"
    echo "==============================================================================" >> "$report_file"
    echo "FILES GENERATED:" >> "$report_file"
    echo "==============================================================================" >> "$report_file"
    echo "- final_subdomains.txt: All unique subdomains found" >> "$report_file"
    echo "- subdomains/: Individual tool outputs" >> "$report_file"
    echo "- intelligence/: Organization and ASN intelligence" >> "$report_file"
    echo "- reports/: This report and other analysis files" >> "$report_file"
    echo "- targets.txt: Input targets used for scan" >> "$report_file"
    
    print_status "SUCCESS" "Report generated: $report_file"
}

# Function to run parallel subdomain enumeration
run_parallel_enumeration() {
    local targets_file=$1
    local output_dir=$2
    
    print_status "PHASE" "Starting parallel subdomain enumeration..."
    
    # Create a job control function
    run_job() {
        local func_name=$1
        local targets_file=$2
        local output_dir=$3
        
        # Run the function and capture any errors
        $func_name "$targets_file" "$output_dir" 2>&1
    }
    
    # Array of functions to run in parallel
    local enum_functions=("run_subfinder" "run_assetfinder" "run_amass_passive")
    
    # Start parallel jobs
    local pids=()
    for func in "${enum_functions[@]}"; do
        run_job "$func" "$targets_file" "$output_dir" &
        pids+=($!)
        
        # Limit parallel jobs
        if [ ${#pids[@]} -ge $MAX_PARALLEL_JOBS ]; then
            wait "${pids[0]}"
            pids=("${pids[@]:1}")
        fi
    done
    
    # Wait for remaining jobs
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    
    # Run sequential jobs (these tools don't play well with parallel execution)
    run_bbot "$targets_file" "$output_dir"
    run_ffuf "$targets_file" "$output_dir"
    run_subdog "$targets_file" "$output_dir"
    run_sudomy "$targets_file" "$output_dir"
    run_dnscan "$targets_file" "$output_dir"
}

# Main function
main() {
    local input=$1
    
    # Validate input
    if [ -z "$input" ]; then
        echo "Usage: $0 <domain|targets_file>"
        echo "Examples:"
        echo "  $0 example.com                    # Single domain"
        echo "  $0 targets.txt                    # Multiple domains from file"
        exit 1
    fi
    
    print_banner
    
    local start_time=$(date +%s)
    
    # Check input type
    local input_type=$(check_input_type "$input")
    
    case $input_type in
        "domain")
            print_status "INFO" "Single domain mode: $input"
            local target_info=$(echo "$input" | tr '.' '_')
            ;;
        "file")
            print_status "INFO" "Multi-target mode: $input"
            validate_domain_file "$input"
            local target_info="multi_target"
            ;;
        "invalid")
            print_status "ERROR" "Invalid input: $input"
            print_status "INFO" "Please provide a valid domain or file path"
            exit 1
            ;;
    esac
    
    # Check dependencies
    check_dependencies
    
    # Setup directories
    local output_dir=$(setup_directories "$target_info")
    print_status "INFO" "Output directory: $output_dir"
    
    # Create targets file
    local targets_file=$(create_targets_file "$input" "$output_dir")
    print_status "INFO" "Targets file: $targets_file"
    
    # Run parallel enumeration
    run_parallel_enumeration "$targets_file" "$output_dir"
    
    # Aggregate results
    aggregate_subdomains "$output_dir" "$targets_file"
    
    # Run intelligence gathering
    run_amass_intel "$targets_file" "$output_dir"
    
    # Run reverse DNS lookups
    run_reverse_dns "$output_dir"
    
    local end_time=$(date +%s)
    
    # Generate report
    generate_report "$output_dir" "$targets_file" "$start_time" "$end_time"
    
    print_status "SUCCESS" "Reconnaissance completed!"
    print_status "INFO" "Results saved in: $output_dir"
    print_status "INFO" "Final subdomain list: $output_dir/final_subdomains.txt"
    print_status "INFO" "Full report: $output_dir/reports/reconnaissance_report.txt"
    
    # Display quick stats
    local total_subdomains=$(wc -l < "$output_dir/final_subdomains.txt")
    local target_count=$(wc -l < "$targets_file")
    local duration=$((end_time - start_time))
    
    echo -e "${CYAN}${BOLD}"
    echo "┌─────────────────────────────────────────┐"
    echo "│            SCAN SUMMARY                 │"
    echo "├─────────────────────────────────────────┤"
    printf "│ Targets Scanned: %-18s │\\n" "$target_count"
    printf "│ Subdomains Found: %-17s │\\n" "$total_subdomains"
    printf "│ Duration: %-26s │\\n" "${duration}s"
    printf "│ Output Directory: %-18s │\\n" "$(basename "$output_dir")"
    echo "└─────────────────────────────────────────┘"
    echo -e "${NC}"
}

# Error handling
set -eE
trap 'print_status "ERROR" "Script interrupted or failed at line $LINENO"' ERR

# Run main function with all arguments
main "$@"
'''

with open("advanced_recon_multi.sh", "w") as f:
    f.write(advanced_script_upgraded)

print("✅ Created advanced_recon_multi.sh with:")
print("  🎯 Single domain support: ./script.sh example.com")
print("  📋 Multi-target support: ./script.sh targets.txt")
print("  🎨 Professional banner with author credit")
print("  🔄 Sudomy loop implementation")
print("  ⚡ All tools configured per your command specifications")