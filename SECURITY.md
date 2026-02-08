# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of this defensive research tool seriously. If you discover a security vulnerability, please follow these steps:

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

### For Researchers
- Only test on authorized systems
- Use isolated laboratory environments
- Implement proper access controls
- Monitor network traffic for anomalies
- Maintain detailed logs of all activities

### For Defenders
- Monitor for unauthorized PowerShell/bash script execution
- Watch for Cloudflare tunnel connections
- Implement network segmentation
- Deploy endpoint detection solutions
- Regular security awareness training

## Contact

For security-related inquiries:
- Email: chrizmonsaji@proton.me
- PGP Key: Available upon request
- Response SLA: 48 hours for acknowledgment

---

*This security policy is subject to change. Last updated: February 2026*
