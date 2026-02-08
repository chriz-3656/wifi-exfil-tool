# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of this offensive research tool seriously. If you discover a security vulnerability, please follow these steps:

### Responsible Disclosure Process

1. **Do NOT create a public issue** for security vulnerabilities
2. Email security concerns to: chrizmonsaji@proton.me
3. Include the following information in your report:
   - Description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact assessment
   - Suggested remediation (if any)

### What to Expect

- **Response Time**: We aim to acknowledge receipt within 48 hours
- **Initial Assessment**: Within 5 business days, we'll determine the severity
- **Resolution Timeline**: Based on severity classification:
  - Critical: 14 days
  - High: 30 days
  - Medium: 60 days
  - Low: 90 days

### Security Measures

This tool implements several security features:
- Token-based authentication for data transmission
- Encrypted Cloudflare tunnel communication
- Process isolation and sandboxing
- Temporary file cleanup
- Self-destruction mechanisms

## Security Best Practices

### For Red Team Operators
- Only conduct operations on authorized systems with proper engagement scope
- Use isolated laboratory environments for technique development
- Implement operational security measures to maintain stealth
- Monitor network traffic for defensive countermeasures
- Maintain detailed operational logs and evidence chains

### For Blue Team Defenders
- Monitor for unauthorized PowerShell/bash script execution and credential harvesting
- Watch for anomalous Cloudflare tunnel connections and data exfiltration patterns
- Implement network segmentation and micro-segmentation strategies
- Deploy advanced endpoint detection and response (EDR) solutions
- Conduct regular security awareness training and phishing simulations

## Contact

For security-related inquiries:
- Email: chrizmonsaji@proton.me
- PGP Key: Available upon request
- Response SLA: 48 hours for acknowledgment

---

*This security policy is subject to change. Last updated: February 2026*
