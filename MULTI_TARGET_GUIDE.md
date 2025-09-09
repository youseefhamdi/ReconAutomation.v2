# Multi-Target Support Update

## 🎯 Enhanced Features

Both scripts now support **single domain** and **multiple domains** from a file:

### Single Domain Usage:
```bash
./advanced_recon_multi.sh example.com
./simple_recon_multi.sh example.com
```

### Multi-Target Usage:
```bash
# Create targets file
echo "example.com" > targets.txt
echo "test.com" >> targets.txt
echo "demo.org" >> targets.txt

# Run reconnaissance
./advanced_recon_multi.sh targets.txt
./simple_recon_multi.sh targets.txt
```

## 🔧 Tool-Specific Implementation

### Tools with Native List Support:
- **Subfinder**: `subfinder -dL targets.txt -t 50 -o subfinder.txt -all`
- **Amass**: `amass enum -passive -df targets.txt -o amass_results.txt`
- **BBOT**: `bbot -l targets.txt -p subdomain-enum cloud-enum...`
- **DNScan**: `dnscan -l targets.txt -w wordlist.txt -r --maxdepth 3`

### Tools with Loop Implementation:
- **AssetFinder**: `cat targets.txt | while read domain; do assetfinder --subs-only "$domain"; done`
- **Subdog**: `cat targets.txt | subdog -tools all`
- **Sudomy**: Custom loop implementation (no native list support)
- **FFUF**: Loop through each domain for fuzzing

## 🎨 Professional Banner

New ASCII art banner with:
- Professional styling with box characters
- Author attribution: "Coded by: Youssef Hamdi"
- Version information
- Feature highlights

## 📊 Enhanced Reporting

- Per-target subdomain breakdown
- Total statistics across all targets  
- Individual tool performance metrics
- Target validation and error handling

## 🔄 Sudomy Special Handling

Since Sudomy doesn't support multiple targets natively, the script:
1. Loops through each domain individually
2. Creates separate output directories per domain
3. Aggregates results into final output
4. Handles timeouts and errors gracefully
