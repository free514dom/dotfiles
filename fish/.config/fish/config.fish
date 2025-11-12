if test -f ~/.config/fish/secrets.fish
    source ~/.config/fish/secrets.fish
end

if status is-interactive
end

set -gx EDITOR (command -v nvim)
set -gx VISUAL (command -v nvim)

fish_add_path $HOME/.local/bin

alias cat 'bat --paging=never --style="plain"'
alias ls 'eza --git'
alias l  'eza --git'
alias ll 'eza -l --git --header'
alias la 'eza -a --git'
alias lla 'eza -la --git --header'
alias lt 'eza --tree'
alias lta 'eza --tree -a'

function copy --wraps wl-copy --description "Pipe to wl-copy and notify"
    command wl-copy $argv
    if test $status -eq 0
        notify-send -a "Terminal" -i "utilities-terminal" "复制成功 (来自终端)" "内容已通过管道命令保存"
    end
end

function get_ip --description "Discovers a device IP using its MAC address"
    if not command -v arp-scan >/dev/null
        echo "错误: 'arp-scan' 命令未找到。请先安装 (e.g., sudo dnf install arp-scan)" >&2
        return 1
    end

    set --local device_alias $argv[1]
    set --local mac_address
    switch $device_alias
        case 'pi'
            set mac_address 'd8:3a:dd:7e:c5:dc'
        case '*'
            echo "错误: 未知的设备别名 '$device_alias'。" >&2
            return 1
    end

    echo -n "==> 正在扫描 '$device_alias' ($mac_address)... " >&2

    set --local ip (sudo arp-scan -l | grep -i "$mac_address" | awk '{print $1}')

    if test -z "$ip"
        echo "未找到。" >&2
        echo "错误: 未能在网络上找到设备 '$device_alias'。" >&2
        return 1
    end

    echo "找到！" >&2
    echo $ip
end

function s_pi --description "SSH to Raspberry Pi"
    if set --local pi_ip (get_ip pi)
        echo "✅ 发现树莓派 IP: $pi_ip, 正在连接..."
        TERM=xterm-256color ssh "pi@$pi_ip"
    else
        echo "❌ 连接失败：无法获取 IP 地址。" >&2
        return 1
    end
end

function f_pi --description "Mount Raspberry Pi via sshfs"
    mkdir -p ~/mnt_points/pi_mnt_point
    if set --local pi_ip (get_ip pi)
        echo "✅ 发现树莓派 IP: $pi_ip, 正在挂载..."
        sshfs "pi@$pi_ip": ~/mnt_points/pi_mnt_point/
        if test $status -eq 0; echo "👍 成功! 树莓派已挂载。"; else; echo "❌ 错误: sshfs 挂载失败。" >&2; end
    else
        echo "❌ 挂载失败：无法获取 IP 地址。" >&2
        return 1
    end
end

function vnc_pi --description "VNC to Raspberry Pi"
    echo "提示: 请确保树莓派已启用 VNC 服务，并且您已安装 vncviewer (tigervnc)。"
    read --prompt-str "按 Enter 继续, Ctrl+C 取消..."
    echo ""
    if set --local pi_ip (get_ip pi)
        echo "✅ 发现树莓派 IP: $pi_ip, 正在启动 VNC 查看器..."
        vncviewer $pi_ip &
        if test $status -eq 0; echo "👍 VNC 客户端已启动。"; else; echo "❌ 错误: 启动 vncviewer 失败。" >&2; end
    else
        echo "❌ VNC 失败：无法获取 IP 地址。" >&2
        return 1
    end
end

function s_phone1 --description "SSH to Phone 1 (Static IP)"
    read --prompt-str "确保手机 Termux 的 sshd 已启动。按 Enter 连接..."
    echo ""
    ssh -p 8022 "9.9.9.9"
end

function f_phone1 --description "Mount Phone 1 via sshfs"
    mkdir -p ~/mnt_points/phone1_mnt
    read --prompt-str "确保手机 Termux 的 sshd 已启动。按 Enter 挂载..."
    echo ""
    sshfs -p 8022 "9.9.9.9:/data/data/com.termux/files/home" ~/mnt_points/phone1_mnt
    if test $status -eq 0; echo "✅ 成功! 手机1已挂载。"; else; echo "❌ 错误: sshfs 挂载失败。" >&2; end
end

function u_all --description "Unmount all custom mount points"
    echo "正在尝试卸载..."
    fusermount -u ~/mnt_points/pi_mnt_point 2>/dev/null && echo "✓ 树莓派已卸载" || echo "树莓派未挂载或卸载失败"
    fusermount -u ~/mnt_points/phone1_mnt 2>/dev/null && echo "✓ 手机1已卸载" || echo "手机1未挂载或卸载失败"
end
