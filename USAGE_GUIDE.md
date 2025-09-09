# 🚀 Advanced Reconnaissance Scripts - Usage Guide
**Coded by: Youssef Hamdi**

## 📋 Available Scripts

| Script | Description | Best For |
|--------|-------------|----------|
| `advanced_recon_multi.sh` | Full-featured with parallel execution | Production reconnaissance |
| `simple_recon_multi.sh` | Streamlined sequential execution | Learning and quick scans |

## 🎯 Usage Modes

### 1. Single Domain Mode
```bash
# Advanced version
./advanced_recon_multi.sh example.com

# Simple version  
./simple_recon_multi.sh example.com
```

### 2. Multi-Target Mode
```bash
# Create targets file
cat > targets.txt << EOF
example.com
test.com
demo.org
target.net
EOF

# Run reconnaissance
./advanced_recon_multi.sh targets.txt
./simple_recon_multi.sh targets.txt
```

## 🔧 Tool Command Implementations

Based on your specifications, here's how each tool is implemented:

### Subfinder
```bash
# Your command: subfinder -dL targets.txt -t 50 -o subfinder.txt -all
# Implementation: 
subfinder -dL "$TARGETS_FILE" -t 50 -o "$OUTPUT_DIR/subdomains/subfinder/subfinder.txt" -all -silent
```

### AssetFinder
```bash
# Your command: cat targets.txt | while read domain; do assetfinder --subs-only "$domain"; done
# Implementation:
cat "$TARGETS_FILE" | while read domain; do
    if [ ! -z "$domain" ]; then
        assetfinder --subs-only "$domain"
    fi
done > "$OUTPUT_DIR/subdomains/assetfinder/assetfinder.txt"
```

### Amass
```bash
# Your command: amass enum -passive -df targets.txt -o amass_results.txt
# Implementation:
amass enum -passive -df "$TARGETS_FILE" -o "$OUTPUT_DIR/subdomains/amass/amass_passive.txt"
```

### BBOT
```bash
# Your command: bbot -l targets.txt -p subdomain-enum cloud-enum code-enum email-enum spider web-basic paramminer dirbust-light web-screenshots --allow-deadly
# Implementation:
bbot -l "$TARGETS_FILE" -p subdomain-enum cloud-enum code-enum email-enum spider web-basic paramminer dirbust-light web-screenshots --allow-deadly -o "$OUTPUT_DIR/subdomains/bbot/"
```

### Subdog
```bash
# Your command: cat targets.txt | subdog -tools all
# Implementation:
cat "$TARGETS_FILE" | subdog -tools all > "$OUTPUT_DIR/subdomains/subdog/subdog.txt"
```

### Sudomy (Special Loop Implementation)
```bash
# Issue: sudomy doesn't support list of targets
# Solution: Custom loop for each domain
while read -r domain; do
    if [ ! -z "$domain" ]; then
        sudomy -d "$domain" --all -o "$OUTPUT_DIR/sudomy_${domain}/"
    fi
done < "$TARGETS_FILE"
```

### DNScan
```bash
# Your command: dnscan -l target.txt -w wordlist.txt -r --maxdepth 3 -o dnscan_recursive.txt
# Implementation:
dnscan -l "$TARGETS_FILE" -w "$WORDLIST" -r --maxdepth 3 -o "$OUTPUT_DIR/subdomains/dnscan/dnscan.txt"
```

## 🎨 Professional Banner Features

The new banner includes:
- **ASCII Art Design**: Professional box-style graphics
- **Author Attribution**: "Coded by: Youssef Hamdi"
- **Version Information**: v2.5 Multi-Target Edition
- **Feature Highlights**: Visual indicators of capabilities

## 📊 Output Structure

```
recon_[target]_[timestamp]/
├── targets.txt                    # Input targets used
├── final/
│   └── all_subdomains.txt        # Aggregated results
├── subdomains/
│   ├── subfinder.txt
│   ├── assetfinder.txt
│   ├── amass_passive.txt
│   ├── bbot.txt
│   ├── ffuf.txt
│   ├── subdog.txt
│   ├── sudomy.txt
│   └── dnscan.txt
├── intelligence/
│   ├── org_intel.txt
│   ├── asn_*.txt
│   ├── all_asn.txt
│   └── reverse_dns.txt
└── summary.txt                   # Executive summary
```

## 🔍 Sample Targets File

Create a `targets.txt` file with your domains:
```
example.com
sub.example.com
test.example.org
demo.company.net
target.domain.co.uk
```

## ⚡ Performance Considerations

### Single Domain
- **Runtime**: 5-15 minutes
- **Memory**: 2-4 GB RAM
- **Output**: 100-1000+ subdomains

### Multi-Target (5 domains)
- **Runtime**: 15-45 minutes  
- **Memory**: 4-8 GB RAM
- **Output**: 500-5000+ subdomains

## 🚦 Execution Flow

### Advanced Script (Parallel)
1. **Input Validation** → Domain/File detection
2. **Dependency Check** → Tool availability
3. **Parallel Phase** → Subfinder, AssetFinder, Amass
4. **Sequential Phase** → BBOT, FFUF, Sudomy, DNScan
5. **Aggregation** → Deduplication and cleanup
6. **Intelligence** → Amass intel gathering
7. **Reporting** → Comprehensive analysis

### Simple Script (Sequential)
1. **Input Validation** → Domain/File detection
2. **Sequential Execution** → All tools in order
3. **Aggregation** → Result combination
4. **Intelligence** → Basic intel gathering
5. **Summary** → Quick report generation

## 🛡️ Error Handling

Both scripts handle:
- **Missing tools** → Skip and continue
- **Network timeouts** → Graceful degradation
- **Invalid domains** → Validation warnings
- **Empty results** → Create placeholder files
- **Tool failures** → Error logging and recovery

## 🎯 Quick Start Examples

### Bug Bounty Reconnaissance
```bash
# Create target list
echo "hackerone.com" > bug_bounty_targets.txt
echo "bugcrowd.com" >> bug_bounty_targets.txt

# Run comprehensive scan
./advanced_recon_multi.sh bug_bounty_targets.txt
```

### Penetration Testing
```bash
# Single high-value target
./simple_recon_multi.sh client-company.com
```

### Security Research
```bash
# Multiple research targets
cat > research_targets.txt << EOF
github.com
gitlab.com
bitbucket.org
EOF

./advanced_recon_multi.sh research_targets.txt
```

## 📈 Results Analysis

After completion, check:
1. **`final/all_subdomains.txt`** → All discovered subdomains
2. **`summary.txt`** → Executive summary with statistics  
3. **`intelligence/`** → OSINT and network intelligence
4. **Individual tool outputs** → For detailed analysis

## 🔧 Customization

### Modify Tool Parameters
Edit the script to adjust:
- Timeout values for slow tools
- Wordlist paths for fuzzing
- Thread counts for parallel execution
- Output formats and locations

### Add Custom Tools
Integrate additional tools by:
1. Adding tool check in `check_dependencies()`
2. Creating tool function (e.g., `run_custom_tool()`)
3. Calling function in main execution flow
4. Adding results to aggregation process

---

**Author**: Youssef Hamdi  
**Version**: 2.5 Multi-Target Edition  
**License**: MIT
