# wgctl

Lightweight WireGuard client manager for Linux.

## Features

- Add, list, show, and delete clients
- Automatic IPv4 allocation
- Hot-load WireGuard peers
- `show` prints the client configuration and a terminal QR code
- `qr` and `qrcode` print a QR code directly
- Safe deletion with configuration backup and marker checks

## Dependencies

- bash
- wireguard-tools
- iproute2
- qrencode for QR code support

On Debian or Ubuntu:

```bash
apt-get update
apt-get install -y wireguard-tools iproute2 qrencode
```

## Install

```bash
chmod +x install.sh
./install.sh
```

## Usage

The default interface is `wgmesh`. Set the public endpoint explicitly:

```bash
wgctl -i wg155 -e vpn.example.com add oneplus12
wgctl -i wg155 show oneplus12
wgctl -i wg155 qr oneplus12
wgctl -i wg155 ls
wgctl -i wg155 del oneplus12
```

`show` prints the configuration followed by its QR code. Protect the client
`PrivateKey` and never commit generated client files to Git.

## Security

The script requires root. Delete only operates on peers created by this script
and does not remove unmanaged peers or other WireGuard interfaces.
