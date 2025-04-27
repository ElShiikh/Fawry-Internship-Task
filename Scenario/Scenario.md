# Step 1: Verify DNS Resolution

```bash
# Check system DNS servers
cat /etc/resolv.conf

# Resolve domain using system DNS
dig internal.example.com +short

# Resolve using public DNS (8.8.8.8)
dig @8.8.8.8 internal.example.com +short
```

Possible Outcomes:

- Internal DNS works, public DNS fails:
  Cause: Domain is internal-only (split DNS).
  Fix: Ensure clients use internal DNS (edit /etc/resolv.conf or NetworkManager).

- Both DNS fail:
  Cause: Missing `A` record or DNS server down.
  Fix: Add `A` record to DNS zone or restore DNS server.

- Different IPs:
  Cause: Domain accidentally public.
  Fix: Remove public `A` record.

# Step 2: Check Service Reachability

```bash
# Get the resolved IP
IP=$(dig +short internal.example.com)

# Test HTTP(S) connectivity
curl -Iv http://$IP -H "Host: internal.example.com"

# Check port accessibility
nc -zv $IP 80

# Check if the service is listening (on the server)
sudo ss -tuln | grep ':80\|:443'
```

Possible Outcomes:

- Port blocked by firewall:
  Fix: Allow traffic ( `sudo ufw allow 80/tcp` )

- Service bound to localhost:
  Fix: Reconfigure service to listen on `0.0.0.0`

# Step 3: Network/Service Layer Checks

## Common Issues & Fixes:

1. Firewall Blocking Traffic:
   Check: `sudo ufw status` or `iptables -L -n`.

Fix: Allow port 80/443.

2. Routing Issues:
   Check: `ip route get <IP>`
   Fix: Correct routes or gateway settings.

3. SELinux/AppArmor:
   Check: `sudo ausearch -m avc` (SELinux) or `dmesg | grep apparmor`.
   Fix: Temporarily disable or create policies.

4. Proxy Misconfiguration:
   Check: `grep proxy_pass /etc/nginx/sites-enabled/*`.
   Fix: Update proxy settings and reload.

5. Application Crashes:
   Check: `curl -I http://<IP>` or service logs (`journalctl -u apache2`).
   Fix: Restart service or debug application.

# Step 4: Bonus Fixes

Bypass DNS with `/etc/hosts`:

```bash
# Add entry (replace IP)
echo "192.168.1.5 internal.example.com" | sudo tee -a /etc/hosts
```

Persist DNS Settings:

- systemd-resolved:

```bash
sudo nano /etc/systemd/resolved.conf  # Add DNS=10.1.1.1
sudo systemctl restart systemd-resolved
```

- NetworkManager:

```bash
nmcli con mod "eth0" ipv4.dns "10.1.1.1"
nmcli con down "eth0" && nmcli con up "eth0"
```
