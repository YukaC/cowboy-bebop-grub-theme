# Security Policy

## Supported Versions

Security fixes are applied on the `main` branch (and the default branch used for releases). Older tags are not actively maintained unless noted in a release.

## Reporting a Vulnerability

Please **do not** open a public GitHub issue for security vulnerabilities.

- Prefer a **private security advisory** on GitHub (Repository → Security → Advisories → Report a vulnerability), or
- Email **agusyuk25@gmail.com** with a clear description, steps to reproduce, and impact.

We will acknowledge receipt and work on a fix; please allow reasonable time before public disclosure.

## Scope

This repository ships a GRUB bootloader theme and an `install.sh` installer that copies assets and updates GRUB configuration (often requiring `sudo`). Reports are in scope when they concern:

- The install/uninstall script (command injection, unsafe file operations, privilege escalation)
- Malicious or misleading theme assets distributed from this repository

Out of scope: vulnerabilities in GRUB itself, your bootloader configuration outside this theme, or issues that only affect locally modified copies not published here.
