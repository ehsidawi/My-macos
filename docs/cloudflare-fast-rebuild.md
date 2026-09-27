# Cloudflare fast rebuild + secure access

This setup uses Cloudflare at the edge and keeps the macOS VM on a host that has KVM access.

Cloudflare Containers are not a replacement for the VM host because this project requires `/dev/kvm`, `/dev/net/tun`, and elevated network capabilities. Run the VM on a compatible Linux host with hardware virtualization, and use Cloudflare Tunnel to publish only the browser UI.

## 1. Fast rebuilds

The workflow at `.github/workflows/fast-rebuild.yml` builds the Docker image on changes to the Dockerfile, `src/`, or `assets/`.

It pushes two tags to GitHub Container Registry:

- `ghcr.io/ehsidawi/my-macos:edge`
- a commit-specific `sha-...` tag

BuildKit's GitHub Actions cache is enabled with `cache-from: type=gha` and `cache-to: type=gha,mode=max`, so unchanged layers are reused on later builds.

You can also trigger **Fast Rebuild** manually from GitHub Actions.

## 2. Create the Cloudflare Tunnel

In Cloudflare, create a tunnel and add a published application route.

Recommended route:

- Public hostname: for example `mac.example.com`
- Service: `http://macos:8006`

Copy the tunnel token.

For production, put Cloudflare Access in front of the hostname so the macOS web console is not open to the public Internet.

## 3. Start the stack

Create a local `.env` file on the KVM host:

```env
CLOUDFLARE_TUNNEL_TOKEN=replace-with-your-tunnel-token
MACOS_VERSION=15
RAM_SIZE=8G
CPU_CORES=4
DISK_SIZE=128G
```

Then run:

```bash
docker compose -f compose.cloudflare.yml pull
docker compose -f compose.cloudflare.yml up -d
```

The `cloudflared` container reaches the macOS web UI over the internal Docker network. Port 8006 is not published directly on the host.

## 4. Rebuild and roll forward

After a successful Fast Rebuild, refresh the KVM host with:

```bash
docker compose -f compose.cloudflare.yml pull macos
docker compose -f compose.cloudflare.yml up -d macos
```

The persistent `./macos:/storage` volume keeps the VM disk across container image updates.

## Notes

- The host must provide working KVM access.
- Do not commit the Cloudflare tunnel token.
- If you need direct local access for troubleshooting, temporarily publish `127.0.0.1:8006:8006`.
- Follow Apple's licensing terms; the upstream project states that macOS should only be run on Apple hardware.
