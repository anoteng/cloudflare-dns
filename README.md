# Cloudflare Dynamic DNS (Bash)

A minimal Bash script to keep an **A** and **AAAA** record up-to-date on
[Cloudflare](https://www.cloudflare.com/) using their v4 API.  
The script automatically detects its own directory and loads a separate
configuration file.

---

## Quick Start

1. **Clone or download this repository.**

2. **Copy the example config** and edit it with your settings:

   ```bash
   cp cloudflare-ddns.conf.example cloudflare-ddns.conf
   nano cloudflare-ddns.conf
   ```

   Set at least:
   * `CF_API_TOKEN` – your Cloudflare API token  
   * `CF_ZONE_NAME` – the DNS zone (e.g. `example.com`)  
   * `DNS_NAME` – the record you want to update (e.g. `media.example.com`)

3. **Make the script executable** and run it:

   ```bash
   chmod +x cf-ddns.sh
   ./cf-ddns.sh
   ```

   The script will:
   * detect your current public IPv4/IPv6 addresses
   * create the DNS record if it doesn’t exist
   * update it only when the IP changes

---

## Create an API Token

Create a restricted token with **Zone → DNS → Edit** and **Zone → Zone → Read** permissions:

* [Cloudflare Dashboard → My Profile → API Tokens → Create Token](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)

For extra security, choose **Include → Specific Zone** and select the zone you plan to update.

---

## Automating Updates

Run it periodically with cron, for example every 10 minutes:

```bash
*/10 * * * * /path/to/cf-ddns.sh >/dev/null 2>&1
```

Or use a systemd timer if you prefer.

---

## Requirements

* `bash` (4.x or newer)
* `curl`
* `jq` (for JSON parsing)

---

## License

This project is licensed under the **GNU General Public License v3 or later (GPL-3.0-or-later)**.  
See the [LICENSE](LICENSE) file for the full text.
