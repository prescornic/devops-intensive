# Linux COmmands

## Core Essentials (Must Know)

### File & Directory Management

- ls, cd, pwd
- cp, mv, rm
- mkdir, rmdir
- touch
- tree

### Viewing Files

- cat
- less
- head, tail (tail -f for logs)
- wc
- nl

### Editing

- nano (basic)
- vi / vim (industry standard)

## File Search & Filtering

### Searching

- find
- locate
- which, whereis
- grep (with regex)
- ack, rg (ripgrep)

### Text Processing

- awk
- sed
- sort
- uniq
- cut
- tr
- jq (JSON processing )

## Archiving & Compression

- tar
- gzip, gunzip
- zip, unzip

## System Monitoring & Performance

### Process & System Monitoring

- top, htop, atop
- ps
- kill, pkill
- nice, renice

### Resource Usage

- free -m
- df -h
- du -sh
- iostat
- vmstat

## Networking & Debugging

### Basics:

- ip a, ip r, ip link
- ss -tulpn or netstat
- ping
- curl
- wget

### Debug Level:

- tcpdump
- nmap
- dig
- nslookup
- traceroute
- telnet / nc (netcat)
- openssl (TLS/SSL checks)

## Security & Access

- chmod
- chown
- umask
- sudo
- passwd
- ssh, ssh-keygen, ssh-copy-id
- gpg

## Package Management

### Debian/Ubuntu:

- apt, apt-get

### RHEL/CentOS/Rocky:

- yum, dnf

### General:

- snap
- brew (for macOS/Linuxbrew)

## System Services & Daemons

- systemctl (start/stop/status/logs)
- journalctl
- service

## Disk, Filesystems, and OS

- mount, umount
- lsblk
- blkid
- fdisk, parted

## DevOps-Specific Domain Tools

### Containers & Docker

- docker ps, docker logs, docker exec
- docker build, docker run, docker compose

### Kubernetes (must know)

- kubectl get, kubectl describe, kubectl logs
- kubectl exec
- kubectl apply -f
- kubectl port-forward

### CI/CD related

- git (all core commands)
- make

### Cloud CLI

- aws
- gcloud
- az

## Scripting & Automation

### Shell scripting:

- bash basics (if, for, while, case)
- Variables
- Functions
- Pipes |
- Redirects >, >>, 2>, <
- xargs

## Advanced Tools (Great for experienced DevOps)

- strace
- lsof
- perf
- sar
- ufw / firewall-cmd
- iptables
- socat
- rsync (very important)
- tmux / screen
