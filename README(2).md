# 🔍 Advanced Reconnaissance Automation Suite

**Coded by: [Youssef Hamdi](https://github.com/yourusername)**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](https://opensource.org/licenses/MIT) [![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/) [![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey?style=for-the-badge&logo=linux&logoColor=white)](https://www.linux.org/) [![Version](https://img.shields.io/badge/Version-2.5-green?style=for-the-badge)](https://github.com/yourusername/recon-automation-suite)

A comprehensive reconnaissance automation suite designed for **bug bounty hunters**, **penetration testers**, and **security researchers**. This toolkit automates the complete reconnaissance workflow from subdomain enumeration to intelligence gathering using industry-standard tools with professional-grade automation.

## 🌟 Key Features

- **🎯 Single & Multi-Target Support** - Process one domain or hundreds with ease
- **🎨 Professional ASCII Art Banner** - Eye-catching banner with author credit
- **⚡ Parallel & Sequential Execution** - Choose between speed or stability
- **🔧 8+ Integrated Tools** - Subfinder, AssetFinder, Amass, BBOT, FFUF, Subdog, Sudomy, DNScan
- **🔄 Smart Loop Implementation** - Custom handling for tools without native multi-target support
- **📊 Advanced Intelligence Gathering** - Organization, ASN, and CIDR analysis
- **📁 Organized Output Structure** - Systematic directory organization with timestamps
- **🛡️ Robust Error Handling** - Graceful handling of missing tools and timeouts
- **📈 Detailed Reporting** - Per-target statistics and executive summaries

---

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/yourusername/recon-automation-suite.git
cd recon-automation-suite
chmod +x *.sh
```

### 2. Single Domain Reconnaissance
```bash
./advanced_recon_multi.sh example.com
# or
./simple_recon_multi.sh example.com
```

### 3. Multi-Target Reconnaissance
```bash
# Create targets file
echo "example.com" > targets.txt
echo "test.com" >> targets.txt
echo "demo.org" >> targets.txt

# Run reconnaissance
./advanced_recon_multi.sh targets.txt
```

### 4. Review Results
```bash
# Check final results
cat recon_*/final/all_subdomains.txt

# View summary report
cat recon_*/summary.txt
```

---

## 📋 Available Scripts

| Script | Description | Best for | Execution |
|--------|-------------|----------|-----------|
| `advanced_recon_multi.sh` | Full-featured with parallel execution | Production reconnaissance, time-critical assessments | Parallel then Sequential |
| `simple_recon_multi.sh` | Streamlined sequential execution | Learning, debugging, resource-constrained environments | Sequential |

---

## 🛠️ Tool Integration

The suite implements your exact tool specifications:

### Subfinder
```bash
subfinder -dL targets.txt -t 50 -o subfinder.txt -all
```
**Features**: Fast passive enumeration with 55+ data sources

### AssetFinder
```bash
cat targets.txt | while read domain; do
    assetfinder --subs-only "$domain"
done > assetfinder.txt
```
**Features**: Quick API-based subdomain discovery

### Amass
```bash
amass enum -passive -df targets.txt -o amass_results.txt
```
**Features**: Advanced OSINT framework with intelligence gathering

### BBOT
```bash
bbot -l targets.txt -p subdomain-enum cloud-enum code-enum email-enum spider web-basic paramminer dirbust-light web-screenshots --allow-deadly
```
**Features**: Comprehensive recursive web application scanner

### FFUF
```bash
# Per-domain fuzzing implementation
while read domain; do
    ffuf -w wordlist.txt -u "https://FUZZ.$domain" -mc 200,301,302,403
done < targets.txt
```
**Features**: High-performance web fuzzer

### Subdog
```bash
cat targets.txt | subdog -tools all
```
**Features**: Multi-tool integration wrapper

### Sudomy (Special Implementation)
```bash
# Custom loop since Sudomy doesn't support target lists
while read -r domain; do
    sudomy -d "$domain" --all -o "output_${domain}/"
done < targets.txt
```
**Features**: Comprehensive subdomain enumeration with custom multi-target handling

### DNScan
```bash
dnscan -l targets.txt -w wordlist.txt -r --maxdepth 3 -o dnscan.txt
```
**Features**: Recursive DNS brute-force with depth control

---

## 📂 Output Structure

```
recon_[target]_[timestamp]/
├── targets.txt                    # Input targets used
├── final/
│   └── all_subdomains.txt        # Aggregated unique subdomains
├── subdomains/                   # Individual tool outputs
│   ├── subfinder.txt
│   ├── assetfinder.txt
│   ├── amass_passive.txt
│   ├── bbot.txt
│   ├── ffuf.txt
│   ├── subdog.txt
│   ├── sudomy.txt
│   └── dnscan.txt
├── intelligence/                 # OSINT and network intelligence
│   ├── org_intel.txt            # Organization intelligence
│   ├── asn_*.txt                # ASN-specific data
│   ├── all_asn.txt              # Combined ASN results
│   ├── cidr_ranges.txt          # Discovered CIDR ranges
│   └── reverse_dns.txt          # Reverse DNS lookups
├── reports/                     # Detailed analysis
│   └── reconnaissance_report.txt
└── summary.txt                  # Executive summary
```

---

## 🎨 Professional Banner

The suite features a professional ASCII art banner:

```
████████████████████████████████████████████████████████████████████████████████
█                                                                              █
█  ╔═══╗ ╔═══╗ ╔═══╗ ╔═══╗ ╔══╗  ╔═══╗        ╔═══╗ ╔═══╗ ╔═══╗ ╔══╗ ╔═══╗  █
█  ║ ╔═╝ ║ ╔═╝ ║ ╔═╝ ║ ╔═╝ ║ ╔╗║ ║ ╔═╝        ║ ╔═╝ ║ ╔═╝ ║ ╔═╝ ║ ╔╗║ ║ ╔═╝  █
█  ║ ╚═╗ ║ ╚═╗ ║ ║   ║ ║   ║ ║║║ ║ ╚═╗        ║ ║   ║ ║   ║ ║   ║ ║║║ ║ ║    █
█  ║ ╔═╝ ║ ╔═╝ ║ ║   ║ ║   ║ ║║║ ║ ╔═╝        ║ ║   ║ ║   ║ ║   ║ ║║║ ║ ║    █
█  ║ ║   ║ ╚═╗ ║ ╚═╗ ║ ╚═╗ ║ ╚╝║ ║ ╚═╗        ║ ╚═╗ ║ ╚═╗ ║ ╚═╗ ║ ╚╝║ ║ ╚═╗  █
█  ╚═╝   ╚═══╝ ╚═══╝ ╚═══╝ ╚══╝  ╚═══╝        ╚═══╝ ╚═══╝ ╚═══╝ ╚══╝  ╚═══╝  █
█                                                                              █
████████████████████████████████████████████████████████████████████████████████
                     Advanced Reconnaissance Automation Suite
                              Multi-Target Edition v2.5
                            Coded by: Youssef Hamdi
```

---

## 📊 Performance Metrics

| Target Size | Expected Runtime | Subdomains Found | Memory Usage |
|-------------|------------------|------------------|---------------|
| Single Domain | 5-15 minutes | 100-1000+ | 2-4 GB |
| 5 Domains | 15-45 minutes | 500-5000+ | 4-8 GB |
| 10+ Domains | 30+ minutes | 1000+ | 6+ GB |

## 🔧 Tool Comparison

| Tool | Type | Speed | Sources | Quality | False Positives |
|------|------|-------|---------|---------|----------------|
| Subfinder | Passive | Fast | 55+ | High | Low |
| AssetFinder | Passive | Very Fast | 10+ | Medium | Medium |
| Amass | Passive/Active | Medium | 100+ | Very High | Very Low |
| BBOT | Active | Slow | 50+ | High | Low |
| FFUF | Active | Medium | Brute Force | Medium | High |
| Subdog | Passive | Fast | 20+ | Medium | Medium |
| Sudomy | Passive/Active | Medium | 30+ | High | Low |
| DNScan | Active | Fast | Brute Force | Medium | High |

---

## 🛠️ Installation

### Prerequisites
- **Operating System**: Linux (Ubuntu 20.04+ recommended)
- **Shell**: Bash 4.0+
- **Go**: 1.19+ (for Go-based tools)
- **Python**: 3.8+ (for Python-based tools)

### Automated Installation
```bash
# Clone repository
git clone https://github.com/yourusername/recon-automation-suite.git
cd recon-automation-suite

# Run installation script
chmod +x install.sh
./install.sh
```

### Manual Installation
See [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for detailed manual installation instructions.

---

## 💡 Usage Examples

### Bug Bounty Hunting
```bash
# Create bug bounty targets
cat > bug_bounty_targets.txt << EOF
hackerone.com
bugcrowd.com
intigriti.com
yeswehack.com
EOF

# Run comprehensive reconnaissance
./advanced_recon_multi.sh bug_bounty_targets.txt
```

### Penetration Testing
```bash
# Single high-value target
./simple_recon_multi.sh client-company.com

# Multiple client subsidiaries
echo "client-main.com" > client_targets.txt
echo "client-subsidiary1.com" >> client_targets.txt
echo "client-subsidiary2.com" >> client_targets.txt
./advanced_recon_multi.sh client_targets.txt
```

### Security Research
```bash
# Technology companies research
cat > tech_research.txt << EOF
github.com
gitlab.com
bitbucket.org
sourceforge.net
EOF

./advanced_recon_multi.sh tech_research.txt
```

---

## 🎯 Key Improvements Over Original

| Feature | Original | Upgraded |
|---------|----------|----------|
| **Target Support** | Single Domain Only | Single + Multi-Target |
| **Banner Style** | Simple Text | Professional ASCII Art |
| **Sudomy Handling** | Basic | Custom Loop Implementation |
| **Tool Commands** | Generic | User-Specified (Exact) |
| **Reporting** | Basic Summary | Per-Target Breakdown |
| **Author Credit** | Not Included | Prominently Featured |
| **Input Validation** | Basic | Robust File/Domain Detection |
| **Error Handling** | Standard | Enhanced Multi-Target |

---

## 🚦 Execution Flow

### Advanced Script (Recommended)
1. **Input Validation** → Detect domain vs file input
2. **Dependency Check** → Verify tool availability
3. **Parallel Phase** → Run Subfinder, AssetFinder, Amass simultaneously
4. **Sequential Phase** → Execute BBOT, FFUF, Sudomy, DNScan in order
5. **Aggregation** → Combine and deduplicate all results
6. **Intelligence** → Perform OSINT and network analysis
7. **Reporting** → Generate comprehensive reports

### Simple Script
1. **Input Validation** → Basic input checking
2. **Sequential Execution** → Run all tools in order
3. **Result Collection** → Gather outputs from each tool
4. **Basic Intelligence** → Perform essential OSINT
5. **Summary Generation** → Create quick summary report

---

## 🛡️ Security Considerations

### Legal and Ethical Use
- ✅ **Only test domains you own or have explicit permission to test**
- ✅ **Follow responsible disclosure practices**
- ✅ **Respect robots.txt and security.txt files**
- ✅ **Comply with local laws and regulations**

### OPSEC Best Practices
- Use VPS or cloud instances for operational security
- Consider VPN/proxy chains for attribution management
- Monitor and rotate IP addresses if needed
- Be aware of logging and detection mechanisms

### Rate Limiting
- Tools implement built-in rate limiting
- API keys recommended for increased limits
- Monitor target responsiveness during scans

---

## 🔧 Customization

### Adding Custom Tools
```bash
# Example: Adding a custom reconnaissance tool
run_custom_tool() {
    local targets_file=$1
    local output_dir=$2
    
    print_status "INFO" "Running Custom Tool..."
    your_custom_tool -input "$targets_file" -output "$output_dir/custom_tool.txt"
}

# Add to main execution flow
run_custom_tool "$targets_file" "$output_dir"
```

### Modifying Tool Parameters
```bash
# Adjust timeout values
timeout 1200 bbot -l "$targets_file" ...

# Change thread counts
subfinder -dL "$targets_file" -t 100 ...

# Use custom wordlists
CUSTOM_WORDLIST="/path/to/your/wordlist.txt"
```

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Contribution Steps
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📚 Documentation

- **[INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)** - Complete installation instructions
- **[USAGE_GUIDE.md](USAGE_GUIDE.md)** - Comprehensive usage documentation
- **[MULTI_TARGET_GUIDE.md](MULTI_TARGET_GUIDE.md)** - Multi-target feature guide
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

---

## 🐛 Troubleshooting

### Common Issues

**Tool Not Found**
```bash
# Check if tool is installed
which subfinder
echo $PATH

# Install missing tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
```

**Memory Issues**
```bash
# Monitor system resources
htop

# Reduce parallel jobs
export MAX_PARALLEL_JOBS=5
```

**Permission Denied**
```bash
# Make scripts executable
chmod +x *.sh
```

For more troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

### Tools and Projects
- **[ProjectDiscovery](https://projectdiscovery.io/)** - Subfinder, Nuclei, httpx
- **[OWASP Amass](https://github.com/OWASP/Amass)** - Advanced OSINT framework
- **[Tom Hudson](https://github.com/tomnomnom)** - AssetFinder and various security tools
- **[FFUF](https://github.com/ffuf/ffuf)** - Fast web fuzzer
- **[BlackLanternSecurity](https://github.com/blacklanternsecurity/bbot)** - BBOT framework

### Community
- Bug bounty community for methodology and best practices
- Security researchers for tool development and testing
- Open source contributors for continuous improvement

---

## 📞 Support

### Community Support
- **GitHub Issues**: [Report bugs or request features](https://github.com/yourusername/recon-automation-suite/issues)
- **GitHub Discussions**: [Community discussions](https://github.com/yourusername/recon-automation-suite/discussions)
- **Discord**: [Join our community](https://discord.gg/your-invite)

### Professional Support
For enterprise support, custom development, or training:
- **Email**: youssef.hamdi@domain.com
- **LinkedIn**: [Youssef Hamdi](https://linkedin.com/in/youssef-hamdi)

---

## ⭐ Star History

If this tool has been helpful, please consider giving it a star! ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/recon-automation-suite&type=Date)](https://star-history.com/#yourusername/recon-automation-suite&Date)

---

<div align="center">

**🔍 Happy Hunting! 🔍**

*Crafted with ❤️ for the cybersecurity community*

**Coded by: [Youssef Hamdi](https://github.com/yourusername)**  
**Version 2.5 Multi-Target Edition**  
**Last Updated: September 2025**

</div>