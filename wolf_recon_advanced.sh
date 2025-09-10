#!/bin/bash

# =============================================================================
# Advanced Reconnaissance Automation Suite v2.5
# Multi-Target Support Edition
# Coded by: Wolf
# =============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MAX_PARALLEL_JOBS=5

# Function to print simple professional banner
print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "┌────────────────────────────────────────────────────────────────────────────┐"
    echo "│                                                                            │"
    echo "│  ██╗    ██╗ ██████╗ ██╗     ███████╗    ██████╗ ███████╗ ██████╗ ██████╗  │"
    echo "│  ██║    ██║██╔═══██╗██║     ██╔════╝    ██╔══██╗██╔════╝██╔════╝██╔═══██╗ │"
    echo "│  ██║ █╗ ██║██║   ██║██║     █████╗      ██████╔╝█████╗  ██║     ██║   ██║ │"
    echo "│  ██║███╗██║██║   ██║██║     ██╔══╝      ██╔══██╗██╔══╝  ██║     ██║   ██║ │"
    echo "│  ╚███╔███╔╝╚██████╔╝███████╗██║         ██║  ██║███████╗╚██████╗╚██████╔╝ │"
    echo "│   ╚══╝╚══╝  ╚═════╝ ╚══════╝╚═╝         ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝  │"
    echo "│                                                                            │"
    echo "│            Advanced Reconnaissance Automation Suite v2.5                  │"
    echo "│                        Multi-Target Edition                               │"
    echo "│                                                                            │"
    echo "│    🎯 Single & Multi-Target     ⚡ Parallel Execution     🛡️ Error Safe    │"
    echo "│    🔧 8+ Recon Tools           📊 Intelligence Gathering  📈 Reports       │"
    echo "│                                                                            │"
    echo "└────────────────────────────────────────────────────────────────────────────┘"
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
    elif [[ "$input" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
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
            if [[ "$line" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
                valid_count=$((valid_count + 1))
            else
                print_status "WARNING" "Invalid domain format: $line"
            fi
        fi
    done < "$file"

    print_status "INFO" "Found $valid_count valid domains out of $total_count entries"
    return 0
}

# Function to check if command exists
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to check tool dependencies
check_dependencies() {
    print_status "INFO" "Checking tool dependencies..."

    local tools=("subfinder" "assetfinder" "amass")
    local optional_tools=("bbot" "ffuf" "subdog" "sudomy" "dnscan" "whois" "prips" "dig" "jq")
    local missing_critical=()
    local missing_optional=()

    # Check critical tools
    for tool in "${tools[@]}"; do
        if ! check_command "$tool"; then
            missing_critical+=("$tool")
        fi
    done

    # Check optional tools
    for tool in "${optional_tools[@]}"; do
        if ! check_command "$tool"; then
            missing_optional+=("$tool")
        fi
    done

    if [ ${#missing_critical[@]} -ne 0 ]; then
        print_status "ERROR" "Missing critical tools: ${missing_critical[*]}"
        print_status "INFO" "Install missing tools: go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        return 1
    fi

    if [ ${#missing_optional[@]} -ne 0 ]; then
        print_status "WARNING" "Missing optional tools: ${missing_optional[*]}"
        print_status "INFO" "Some features will be skipped"
    fi

    print_status "SUCCESS" "Critical tools are available"
    return 0
}

# Function to create output directory structure
setup_directories() {
    local target_info=$1
    local base_dir="recon_${target_info}_${TIMESTAMP}"

    mkdir -p "$base_dir" || {
        print_status "ERROR" "Failed to create output directory"
        return 1
    }

    mkdir -p "$base_dir"/{subdomains,enumeration,intelligence,ports,screenshots,reports,wordlists,raw_output} || {
        print_status "ERROR" "Failed to create subdirectories"
        return 1
    }

    mkdir -p "$base_dir"/subdomains/{subfinder,assetfinder,amass,bbot,ffuf,subdog,sudomy,dnscan} || {
        print_status "ERROR" "Failed to create tool directories"
        return 1
    }

    mkdir -p "$base_dir"/enumeration/{live_hosts,technologies,certificates} || true
    mkdir -p "$base_dir"/intelligence/{org_intel,asn_intel,cidr_intel,whois_data} || true

    echo "$base_dir"
}

# Function to create targets file for tools that need it
create_targets_file() {
    local input=$1
    local output_dir=$2
    local input_type=$(check_input_type "$input")

    if [ "$input_type" = "domain" ]; then
        echo "$input" > "$output_dir/targets.txt" || {
            print_status "ERROR" "Failed to create targets file"
            return 1
        }
    elif [ "$input_type" = "file" ]; then
        cp "$input" "$output_dir/targets.txt" || {
            print_status "ERROR" "Failed to copy targets file"
            return 1
        }
    fi

    echo "$output_dir/targets.txt"
}

# Function to run subfinder
run_subfinder() {
    local targets_file=$1
    local output_dir=$2

    print_status "INFO" "Running Subfinder..."

    if ! check_command "subfinder"; then
        print_status "WARNING" "Subfinder not found, skipping..."
        touch "$output_dir/subdomains/subfinder/subfinder.txt"
        return 0
    fi

    subfinder -dL "$targets_file" -t 50 -o "$output_dir/subdomains/subfinder/subfinder.txt" -all -silent 2>/dev/null || {
        print_status "WARNING" "Subfinder failed, continuing..."
        touch "$output_dir/subdomains/subfinder/subfinder.txt"
    }

    if [ -f "$output_dir/subdomains/subfinder/subfinder.txt" ]; then
        local count=$(wc -l < "$output_dir/subdomains/subfinder/subfinder.txt" 2>/dev/null || echo 0)
        print_status "SUCCESS" "Subfinder found $count subdomains"
    fi
}

# Function to run assetfinder
run_assetfinder() {
    local targets_file=$1
    local output_dir=$2

    print_status "INFO" "Running AssetFinder..."

    if ! check_command "assetfinder"; then
        print_status "WARNING" "AssetFinder not found, skipping..."
        touch "$output_dir/subdomains/assetfinder/assetfinder.txt"
        return 0
    fi

    # Use the exact command format from user's file
    {
        while read -r domain; do
            if [ ! -z "$domain" ]; then
                print_status "TARGET" "AssetFinder processing: $domain"
                assetfinder --subs-only "$domain" 2>/dev/null || true
            fi
        done < "$targets_file"
    } > "$output_dir/subdomains/assetfinder/assetfinder.txt" 2>/dev/null

    if [ -f "$output_dir/subdomains/assetfinder/assetfinder.txt" ]; then
        local count=$(wc -l < "$output_dir/subdomains/assetfinder/assetfinder.txt" 2>/dev/null || echo 0)
        print_status "SUCCESS" "AssetFinder found $count subdomains"
    fi
}

# Function to run amass passive enumeration
run_amass_passive() {
    local targets_file=$1
    local output_dir=$2

    print_status "INFO" "Running Amass passive enumeration..."

    if ! check_command "amass"; then
        print_status "WARNING" "Amass not found, skipping..."
        touch "$output_dir/subdomains/amass/amass_passive.txt"
        return 0
    fi

    amass enum -passive -df "$targets_file" -o "$output_dir/subdomains/amass/amass_passive.txt" 2>/dev/null || {
        print_status "WARNING" "Amass failed, continuing..."
        touch "$output_dir/subdomains/amass/amass_passive.txt"
    }

    if [ -f "$output_dir/subdomains/amass/amass_passive.txt" ]; then
        local count=$(wc -l < "$output_dir/subdomains/amass/amass_passive.txt" 2>/dev/null || echo 0)
        print_status "SUCCESS" "Amass passive found $count subdomains"
    fi
}

# Function to run bbot
run_bbot() {
    local targets_file=$1
    local output_dir=$2

    print_status "INFO" "Running BBOT..."

    if ! check_command "bbot"; then
        print_status "WARNING" "BBOT not found, skipping..."
        mkdir -p "$output_dir/subdomains/bbot"
        touch "$output_dir/subdomains/bbot/bbot_subdomains.txt"
        return 0
    fi

    # Run bbot with timeout and output redirection
    timeout 600 bbot -l "$targets_file" -p subdomain-enum cloud-enum code-enum email-enum spider web-basic paramminer dirbust-light web-screenshots --allow-deadly -o "$output_dir/subdomains/bbot/" 2>/dev/null || {
        print_status "WARNING" "BBOT timeout or failed, continuing..."
    }

    # Extract subdomains from bbot output
    if [ -d "$output_dir/subdomains/bbot" ]; then
        find "$output_dir/subdomains/bbot" -name "*.txt" -exec cat {} \; 2>/dev/null | \
            grep -E "^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" | sort -u > "$output_dir/subdomains/bbot/bbot_subdomains.txt" 2>/dev/null || \
            touch "$output_dir/subdomains/bbot/bbot_subdomains.txt"

        local count=$(wc -l < "$output_dir/subdomains/bbot/bbot_subdomains.txt" 2>/dev/null || echo 0)
        print_status "SUCCESS" "BBOT found $count subdomains"
    else
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
        return 0
    fi

    if ! check_command "ffuf"; then
        print_status "WARNING" "FFUF not found, skipping..."
        touch "$output_dir/subdomains/ffuf/ffuf.txt"
        return 0
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
                if check_command "jq"; then
                    jq -r '.results[].url' "$output_dir/subdomains/ffuf/ffuf_${domain//[.:]/_}.json" 2>/dev/null | \
                        sed 's|https\?://||' | cut -d'/' -f1 >> "$output_dir/subdomains/ffuf/ffuf.txt" || true
                fi
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

    if ! check_command "subdog"; then
        print_status "WARNING" "Subdog not found, skipping..."
        touch "$output_dir/subdomains/subdog/subdog.txt"
        return 0
    fi

    # Use exact command format from user's file
    cat "$targets_file" | subdog -tools all > "$output_dir/subdomains/subdog/subdog.txt" 2>/dev/null || \
        touch "$output_dir/subdomains/subdog/subdog.txt"

    if [ -f "$output_dir/subdomains/subdog/subdog.txt" ]; then
        local count=$(wc -l < "$output_dir/subdomains/subdog/subdog.txt")
        print_status "SUCCESS" "Subdog found $count subdomains"
    fi
}

# Function to run sudomy - with loop since it doesn't support lists
run_sudomy() {
    local targets_file=$1
    local output_dir=$2

    print_status "INFO" "Running Sudomy (with loop - no native list support)..."

    if ! check_command "sudomy"; then
        print_status "WARNING" "Sudomy not found, skipping..."
        touch "$output_dir/subdomains/sudomy/sudomy.txt"
        return 0
    fi

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
                find "$output_dir/subdomains/sudomy/individual/sudomy_${clean_domain}" -name "*.txt" -exec cat {} \; 2>/dev/null | \
                    grep -E "^[a-zA-Z0-9.-]+\.$domain$" >> "$output_dir/subdomains/sudomy/sudomy.txt" || true
            fi
        fi
    done < "$targets_file"

    # Sort and deduplicate final results
    if [ -f "$output_dir/subdomains/sudomy/sudomy.txt" ]; then
        sort -u "$output_dir/subdomains/sudomy/sudomy.txt" -o "$output_dir/subdomains/sudomy/sudomy.txt"
        local count=$(wc -l < "$output_dir/subdomains/sudomy/sudomy.txt")
        print_status "SUCCESS" "Sudomy found $count subdomains"
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
        return 0
    fi

    if ! check_command "dnscan"; then
        print_status "WARNING" "DNScan not found, skipping..."
        touch "$output_dir/subdomains/dnscan/dnscan.txt"
        return 0
    fi

    print_status "INFO" "Running DNScan..."
    # Use exact command format from user's file
    dnscan -l "$targets_file" -w "$wordlist" -r --maxdepth 3 -o "$output_dir/subdomains/dnscan/dnscan.txt" 2>/dev/null || \
        touch "$output_dir/subdomains/dnscan/dnscan.txt"

    if [ -f "$output_dir/subdomains/dnscan/dnscan.txt" ]; then
        local count=$(wc -l < "$output_dir/subdomains/dnscan/dnscan.txt")
        print_status "SUCCESS" "DNScan found $count subdomains"
    fi
}

# Function to aggregate and clean subdomains
aggregate_subdomains() {
    local output_dir=$1
    local targets_file=$2

    print_status "PHASE" "Aggregating and cleaning subdomain results..."

    # Combine all subdomain sources safely
    {
        find "$output_dir/subdomains" -name "*.txt" -exec cat {} \; 2>/dev/null || true
    } | sort -u > "$output_dir/subdomains/all_subdomains_raw.txt" 2>/dev/null

    # Clean and validate subdomains
    grep -E "^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\.[a-zA-Z]{2,}$" "$output_dir/subdomains/all_subdomains_raw.txt" 2>/dev/null | \
        grep -vE "(^\.|\.\.|\.\.$|^-|-$)" | \
        sort -u > "$output_dir/subdomains/all_subdomains_clean.txt" 2>/dev/null || \
        touch "$output_dir/subdomains/all_subdomains_clean.txt"

    local total_count=$(wc -l < "$output_dir/subdomains/all_subdomains_clean.txt" 2>/dev/null || echo 0)
    print_status "SUCCESS" "Total unique subdomains found: $total_count"

    # Save final list
    cp "$output_dir/subdomains/all_subdomains_clean.txt" "$output_dir/final_subdomains.txt" 2>/dev/null || \
        touch "$output_dir/final_subdomains.txt"
}

# Function to run amass intelligence gathering
run_amass_intel() {
    local targets_file=$1
    local output_dir=$2

    if ! check_command "amass"; then
        print_status "WARNING" "Amass not available for intelligence gathering, skipping..."
        return 0
    fi

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

# Function to generate summary report
generate_report() {
    local output_dir=$1
    local targets_file=$2
    local start_time=$3
    local end_time=$4

    local report_file="$output_dir/reports/reconnaissance_report.txt"

    print_status "PHASE" "Generating reconnaissance report..."

    mkdir -p "$(dirname "$report_file")" 2>/dev/null

    {
        echo "============================================================================="
        echo "RECONNAISSANCE REPORT"
        echo "Wolf Recon - Advanced Reconnaissance Automation Suite v2.5"
        echo "Coded by: Wolf"
        echo "============================================================================="
        echo "Target(s): $(tr '\n' ', ' < "$targets_file" 2>/dev/null | sed 's/,$//' || echo 'N/A')"
        echo "Number of targets: $(wc -l < "$targets_file" 2>/dev/null || echo 0)"
        echo "Scan Start Time: $(date -d "@$start_time" 2>/dev/null || echo 'N/A')"
        echo "Scan End Time: $(date -d "@$end_time" 2>/dev/null || echo 'N/A')"
        echo "Duration: $((end_time - start_time)) seconds"
        echo "Generated: $(date)"
        echo ""
        echo "============================================================================="
        echo "SUBDOMAIN ENUMERATION RESULTS"
        echo "============================================================================="
        echo ""
        echo "Tool Results:"
        for tool_dir in "$output_dir"/subdomains/*/; do
            local tool_name=$(basename "$tool_dir")
            local tool_file=$(find "$tool_dir" -name "*.txt" | head -1)
            if [ -f "$tool_file" ]; then
                local count=$(wc -l < "$tool_file" 2>/dev/null || echo 0)
                printf "%-15s: %d subdomains\n" "$tool_name" "$count"
            fi
        done
        echo ""
        echo "Total Unique Subdomains: $(wc -l < "$output_dir/final_subdomains.txt" 2>/dev/null || echo 0)"
        echo ""
        echo "Sample Subdomains (first 10):"
        head -10 "$output_dir/final_subdomains.txt" 2>/dev/null || echo "No subdomains found"
        echo ""
        echo "=============================================================================="
        echo "TARGET BREAKDOWN:"
        echo "=============================================================================="

        # Show breakdown per target
        while read -r domain; do
            if [ ! -z "$domain" ]; then
                local domain_count=$(grep -c "\.$domain$" "$output_dir/final_subdomains.txt" 2>/dev/null || echo 0)
                echo "- $domain: $domain_count subdomains"
            fi
        done < "$targets_file"

        echo ""
        echo "=============================================================================="
        echo "FILES GENERATED:"
        echo "=============================================================================="
        echo "- final_subdomains.txt: All unique subdomains found"
        echo "- subdomains/: Individual tool outputs"
        echo "- intelligence/: Organization and ASN intelligence"
        echo "- reports/: This report and other analysis files"
        echo "- targets.txt: Input targets used for scan"
    } > "$report_file" 2>/dev/null

    print_status "SUCCESS" "Report generated: $report_file"
}

# Function to run parallel subdomain enumeration
run_parallel_enumeration() {
    local targets_file=$1
    local output_dir=$2

    print_status "PHASE" "Starting parallel subdomain enumeration..."

    # Array of functions to run in parallel
    local enum_functions=("run_subfinder" "run_assetfinder" "run_amass_passive")

    # Start parallel jobs
    local pids=()
    for func in "${enum_functions[@]}"; do
        $func "$targets_file" "$output_dir" &
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
    if ! check_dependencies; then
        print_status "ERROR" "Missing critical dependencies"
        exit 1
    fi

    # Setup directories
    local output_dir=$(setup_directories "$target_info")
    if [ -z "$output_dir" ]; then
        print_status "ERROR" "Failed to setup directories"
        exit 1
    fi
    print_status "INFO" "Output directory: $output_dir"

    # Create targets file
    local targets_file=$(create_targets_file "$input" "$output_dir")
    if [ -z "$targets_file" ]; then
        print_status "ERROR" "Failed to create targets file"
        exit 1
    fi
    print_status "INFO" "Targets file: $targets_file"

    # Run enumeration tools
    run_parallel_enumeration "$targets_file" "$output_dir"

    # Aggregate results
    aggregate_subdomains "$output_dir" "$targets_file"

    # Run intelligence gathering
    run_amass_intel "$targets_file" "$output_dir"

    local end_time=$(date +%s)

    # Generate report
    generate_report "$output_dir" "$targets_file" "$start_time" "$end_time"

    print_status "SUCCESS" "Wolf Recon completed successfully!"
    print_status "INFO" "Results saved in: $output_dir"
    print_status "INFO" "Final subdomain list: $output_dir/final_subdomains.txt"
    print_status "INFO" "Full report: $output_dir/reports/reconnaissance_report.txt"

    # Display quick stats
    local total_subdomains=$(wc -l < "$output_dir/final_subdomains.txt" 2>/dev/null || echo 0)
    local target_count=$(wc -l < "$targets_file" 2>/dev/null || echo 0)
    local duration=$((end_time - start_time))

    echo -e "${CYAN}${BOLD}"
    echo "┌─────────────────────────────────────────┐"
    echo "│         🐺 WOLF RECON SUMMARY 🐺        │"
    echo "├─────────────────────────────────────────┤"
    printf "│ Targets Scanned: %-18s │\n" "$target_count"
    printf "│ Subdomains Found: %-17s │\n" "$total_subdomains"
    printf "│ Duration: %-26s │\n" "${duration}s"
    printf "│ Output Directory: %-18s │\n" "$(basename "$output_dir")"
    echo "└─────────────────────────────────────────┘"
    echo -e "${NC}"
}

# Run main function with all arguments
main "$@"
