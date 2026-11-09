# wgctl 中文说明

`wgctl` 是运行在 Linux WireGuard **管理端/服务器**上的轻量级客户端管理工具。它负责创建和删除 WireGuard Peer，自动生成标准客户端配置，并在终端显示二维码。

> 本项目不是手机或电脑客户端，也不会替代官方 WireGuard App。客户端用户只需要导入 `client.conf` 或扫描二维码。

## 一、管理端与客户端

### 管理端（服务器）

管理端是安装 WireGuard 服务端接口的 Linux 主机，运行 `wgctl`。它负责：

- 使用现有 WireGuard 接口管理 Peer；
- 为客户端分配接口网段内的 IPv4 地址；
- 生成客户端配置文件；
- 将 Peer 热加载到运行中的 WireGuard 接口；
- 输出配置文本和二维码。

### 客户端（用户设备）

客户端是 Android 手机、iPhone/iPad、Windows、macOS、Linux 电脑，或支持 WireGuard 标准配置的路由器/网络设备。客户端通过配置文件或二维码连接管理端。

客户端不需要安装本项目的 `wgctl`。

## 二、支持的客户端类型

生成的配置是标准 WireGuard INI 配置，支持：

| 客户端类型 | 导入方式 |
|---|---|
| Android | 官方 WireGuard App：扫描二维码或导入配置文件 |
| iOS / iPadOS | 官方 WireGuard App：扫描二维码或导入文件 |
| Windows | 官方 WireGuard for Windows：Import tunnel(s) from file |
| macOS | 官方 WireGuard App：导入配置文件 |
| Linux | `wg-quick`、NetworkManager 或其他支持 WireGuard 的工具 |
| OpenWrt/部分路由器 | 导入标准 WireGuard 配置，具体取决于固件 |
| 其他网络设备 | 仅限明确支持 WireGuard 的设备 |

不支持直接生成 OpenVPN、IPsec、L2TP 配置，也不支持没有 WireGuard 功能的设备。

## 三、依赖和要求

管理端要求：

- Linux；
- Bash 4+；
- 已安装并运行 WireGuard 接口；
- `wireguard-tools`（提供 `wg`）；
- `iproute2`（提供 `ip`）；
- `qrencode`（二维码功能）；
- root 权限；
- 服务端公网地址、域名或可访问的 NAT 映射；
- 防火墙放行 WireGuard UDP 监听端口。

Debian/Ubuntu：

```bash
apt-get update
apt-get install -y wireguard-tools iproute2 qrencode
```

## 四、一键安装

```bash
git clone https://github.com/ShileiWang/wgctl.git
cd wgctl
chmod +x install.sh
./install.sh
```

安装位置：

```text
/usr/local/sbin/wgctl
/usr/local/bin/wgctl -> /usr/local/sbin/wgctl
```

安装脚本只安装管理脚本，不会自动安装或创建 WireGuard 服务端接口，也不会修改防火墙。

## 五、基本用法

默认接口名是 `wgmesh`，可使用 `-i` 指定接口，使用 `-e` 指定客户端连接的服务端公网地址：

```bash
wgctl -i wg155 -e vpn.example.com add phone
wgctl -i wg155 show phone
wgctl -i wg155 qr phone
wgctl -i wg155 ls
wgctl -i wg155 del phone
```

### 命令说明

- `add 名称`：创建客户端 Peer 和配置；
- `ls`：列出本工具创建的客户端；
- `show 名称`：显示配置文本，然后显示终端二维码；
- `qr 名称`：只显示二维码；
- `del 名称`：删除本工具创建的 Peer；
- `help`：显示帮助。

`show` 示例：

```bash
wgctl -i wg155 show oneplus12
```

手机打开 WireGuard App，选择“从二维码创建”后扫描终端二维码即可。

## 六、选项

```text
-i 接口    WireGuard 接口名，默认 wgmesh
-e 地址    客户端配置中的 Endpoint 主机名或公网 IP
-n 网段    覆盖客户端 AllowedIPs，默认使用接口 IPv4 网段
```

建议始终显式指定 `-e`，不要依赖脚本默认值。

## 七、文件和数据安全

默认数据目录：

```text
/etc/wireguard/clients/<接口>/<客户端名称>/
```

其中可能包含：

- `client.conf`：包含客户端私钥，必须保密；
- `client.png`：二维码图片，必须保密；
- `public.key`：客户端公钥；
- `address`：分配的客户端地址；
- `peer.block`：服务端配置中的管理标记。

不要将 `client.conf`、二维码图片、备份文件或任何私钥提交到公开 Git 仓库。泄露客户端私钥后，应重新生成客户端密钥并替换 Peer。

## 八、行为和限制

- 只处理本工具创建并带有标记的 Peer；
- 不执行 `wg-quick down/up`；
- 不删除其他接口或未管理的 Peer；
- 删除前会备份服务端配置；
- 需要现有接口已经运行；
- 本工具不会自动配置 DNS、路由、防火墙、端口转发或 DDNS；
- 本工具不会安装客户端 App。

## 九、故障排查

### 找不到接口

```text
接口不存在或未运行
```

先确认接口：

```bash
ip link show
wg show
```

然后使用正确的接口名：

```bash
wgctl -i wg0 ls
```

### 没有二维码

安装依赖：

```bash
apt-get install -y qrencode
```

### 客户端无法连接

检查：

1. `Endpoint` 是否为客户端可访问的公网地址；
2. UDP 监听端口是否已放行；
3. 服务端和客户端时间是否大致准确；
4. 客户端配置中的 `PublicKey`、`AllowedIPs` 是否正确；
5. 服务端执行 `wg show <接口>` 查看握手时间。

## 十、卸载

卸载管理脚本不会删除 WireGuard Peer：

```bash
rm -f /usr/local/bin/wgctl /usr/local/sbin/wgctl
```

如需删除客户端，请先使用：

```bash
wgctl del <名称>
```

卸载前请确认已备份需要保留的配置。

## 许可证

MIT License，详见 [LICENSE](LICENSE)。
