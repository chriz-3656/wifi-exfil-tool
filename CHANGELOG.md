# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Enhanced directory management system
- Comprehensive cleanup procedures
- Detailed process tracking and monitoring
- Improved error handling and reporting
- Enhanced README documentation

### Changed
- Directory structure now uses local tool directory instead of `~/.wifi-exfil`
- Cleanup mechanism now handles background processes more robustly
- Process PID tracking for better resource management

### Fixed
- Directory creation reliability issues
- Process termination inconsistencies
- Temporary file cleanup procedures

## [1.0.0] - 2024-02-08

### Added
- Initial release of WiFi Credential Exfiltration Toolkit
- Cross-platform payload generation (Windows/Linux)
- Cloudflare tunnel integration
- Flask-based receiver server
- Interactive terminal interface
- Basic cleanup functionality
- Core documentation and templates

[Unreleased]: https://github.com/chriz-3656/wifi-exfil-tool/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/chriz-3656/wifi-exfil-tool/releases/tag/v1.0.0