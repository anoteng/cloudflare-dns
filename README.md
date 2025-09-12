# Cloudflare Dynamic DNS (Bash)

A minimal Bash script to keep an **A** and **AAAA** record up-to-date on
[Cloudflare](https://www.cloudflare.com/) using their v4 API.  
The script loads its configuration from the file cloudflare-dns.conf in the same directory as the script.
In its current iteration, the script is only useable for those who need a simple update of 1 record (A and AAAA) and who has a working IPv6 connection. Support for protocol selection and multiple records may come in the future.

---

## Quick Start

1. **Clone or download this repository.**

2. **Copy the example config** and edit it with your settings:

   ```bash
   cp cloudflare-dns.conf.example cloudflare-dns.conf
   vim cloudflare-dns.conf
   ```

   Set at least:
   * `CF_API_TOKEN` – your Cloudflare API token  
   * `CF_ZONE_NAME` – the DNS zone (e.g. `example.com`)  
   * `DNS_NAME` – the record you want to update (e.g. `media.example.com`)

3. **Make the script executable** and run it:

   ```bash
   chmod +x cloudflare-dns.sh
   ./cloudflare-dns.sh
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
*/10 * * * * /path/to/cloudflare-dns.sh >/dev/null 2>&1
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
