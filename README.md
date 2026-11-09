# wgctl

轻量级 WireGuard 管理端客户端管理工具。中文文档： [README.zh-CN.md](README.zh-CN.md)。

## What it is

`wgctl` runs on a Linux WireGuard **server/management host**. It creates and removes WireGuard peers, allocates client addresses, writes standard client configuration files, and prints terminal QR codes.

It is not a mobile or desktop VPN client. End users should use the official WireGuard application and import the generated configuration or scan the QR code.

## Supported client platforms

The generated configuration is standard WireGuard INI format and can be imported by:

- Android: official WireGuard app;
- iOS/iPadOS: official WireGuard app;
- Windows: official WireGuard for Windows;
- macOS: official WireGuard app;
- Linux: `wg-quick`, NetworkManager, or another WireGuard-compatible tool;
- OpenWrt and routers that support standard WireGuard configuration;
- Other devices that explicitly support WireGuard.

This project does not generate OpenVPN, IPsec, or L2TP profiles, and it cannot add WireGuard support to devices that do not provide it.

## Server requirements

- Linux and Bash 4+;
- a running WireGuard interface;
- `wireguard-tools` (`wg`);
- `iproute2` (`ip`);
- `qrencode` for QR output;
- root privileges;
- a reachable public IP, hostname, or NAT mapping;
- firewall access for the WireGuard UDP listen port.

On Debian/Ubuntu:

```bash
apt-get update
apt-get install -y wireguard-tools iproute2 qrencode
```

## One-click installation

```bash
git clone https://github.com/ShileiWang/wgctl.git
cd wgctl
chmod +x install.sh
./install.sh
```

The installer places the management command at `/usr/local/sbin/wgctl` and creates `/usr/local/bin/wgctl`. It does not create a WireGuard server interface or change firewall rules.

## Usage

The default interface is `wgmesh`. Use `-i` for another interface and `-e` for the public endpoint included in client profiles:

```bash
wgctl -i wg155 -e vpn.example.com add phone
wgctl -i wg155 show phone
wgctl -i wg155 qr phone
wgctl -i wg155 ls
wgctl -i wg155 del phone
```

Commands:

- `add NAME`: create a managed peer and client profile;
- `ls`: list clients created by this tool;
- `show NAME`: print the profile followed by a terminal QR code;
- `qr NAME`: print only the QR code;
- `del NAME`: remove a peer created by this tool;
- `help`: print help.

Options:

```text
-i INTERFACE   WireGuard interface, default: wgmesh
-e ENDPOINT    public IP or hostname placed in the client Endpoint
-n NETWORK     override client AllowedIPs
```

## Security

Client profiles and QR images contain private key material. Do not commit generated profiles, QR images, server configuration, or backups to a public repository. If a client private key is exposed, replace the client key and server peer.

The tool only operates on peers marked as created by itself, does not run `wg-quick down/up`, does not remove unmanaged peers, and backs up the server configuration before deletion.

Default data directory:

```text
/etc/wireguard/clients/<interface>/<client-name>/
```

## Limitations

The tool requires an already-running WireGuard interface. It does not configure DNS, firewall rules, NAT/port forwarding, DDNS, or client applications. See [README.zh-CN.md](README.zh-CN.md) for detailed Chinese documentation, troubleshooting, and uninstall instructions.

## License

MIT License. See [LICENSE](LICENSE).
