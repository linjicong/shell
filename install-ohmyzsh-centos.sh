#!/bin/bash

# Oh My Zsh 安装脚本 for AlmaLinux
# 功能：安装 zsh, Oh My Zsh, 插件 (zsh-syntax-highlighting, zsh-autosuggestions) 和 Powerlevel10k 主题
# 用法：直接运行（需要 sudo 权限）

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}开始安装 Oh My Zsh 及相关组件...${NC}"

# 检查 sudo 权限
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}提示：部分操作需要 sudo 权限，可能需要输入密码。${NC}"
    if ! sudo -v; then
        echo -e "${RED}错误：无法获取 sudo 权限，请检查配置。${NC}"
        exit 1
    fi
fi

# 1. 安装必要的软件包
echo -e "${GREEN}[1/6] 安装依赖软件包 (zsh, curl, git, util-linux)...${NC}"
sudo dnf install -y zsh curl git util-linux

# 确保 chsh 可用（util-linux 提供了 chsh）
if ! command -v chsh &> /dev/null; then
    echo -e "${YELLOW}chsh 命令未找到，尝试安装 shadow-utils...${NC}"
    sudo dnf install -y shadow-utils
fi

# 2. 安装 Oh My Zsh（如果尚未安装）
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
if [ -d "$OH_MY_ZSH_DIR" ]; then
    echo -e "${YELLOW}[2/6] 检测到 Oh My Zsh 已安装，跳过。${NC}"
else
    echo -e "${GREEN}[2/6] 正在安装 Oh My Zsh...${NC}"
    # 使用环境变量避免自动修改 Shell 和启动
    export RUNZSH=no
    export CHSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 3. 定义自定义目录
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGIN_DIR="$ZSH_CUSTOM/plugins"
THEME_DIR="$ZSH_CUSTOM/themes"

# 4. 安装插件
echo -e "${GREEN}[3/6] 安装插件...${NC}"
# zsh-syntax-highlighting
if [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
    echo "安装 zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting 已存在，跳过。"
fi

# zsh-autosuggestions
if [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
    echo "安装 zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$PLUGIN_DIR/zsh-autosuggestions"
else
    echo "zsh-autosuggestions 已存在，跳过。"
fi

# 5. 安装 Powerlevel10k 主题
echo -e "${GREEN}[4/6] 安装 Powerlevel10k 主题...${NC}"
if [ ! -d "$THEME_DIR/powerlevel10k" ]; then
    echo "安装 Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEME_DIR/powerlevel10k"
else
    echo "Powerlevel10k 已存在，跳过。"
fi

# 6. 配置 ~/.zshrc
echo -e "${GREEN}[5/6] 配置 ~/.zshrc ...${NC}"
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    BACKUP="$ZSHRC.backup.$(date +%Y%m%d%H%M%S)"
    cp "$ZSHRC" "$BACKUP"
    echo -e "${YELLOW}已备份原配置文件至 $BACKUP${NC}"
fi

# 设置主题
if grep -q '^ZSH_THEME=' "$ZSHRC"; then
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
else
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC"
fi

# 设置插件（语法高亮必须放在最后）
PLUGINS="git zsh-autosuggestions zsh-syntax-highlighting"
if grep -q '^plugins=' "$ZSHRC"; then
    sed -i "s/^plugins=.*/plugins=(${PLUGINS})/" "$ZSHRC"
else
    echo "plugins=(${PLUGINS})" >> "$ZSHRC"
fi

echo -e "${GREEN}主题和插件配置完成。${NC}"

# 7. 更改默认 Shell 为 zsh
echo -e "${GREEN}[6/6] 更改默认 Shell 为 zsh...${NC}"
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" = "zsh" ]; then
    echo -e "${YELLOW}当前 Shell 已经是 zsh，无需更改。${NC}"
else
    ZSH_PATH=$(which zsh)
    if command -v chsh &> /dev/null; then
        echo "使用 chsh 更改 Shell..."
        sudo chsh -s "$ZSH_PATH" "$USER"
    elif command -v usermod &> /dev/null; then
        echo "使用 usermod 更改 Shell..."
        sudo usermod --shell "$ZSH_PATH" "$USER"
    else
        echo -e "${RED}错误：找不到 chsh 或 usermod 命令，无法更改 Shell。${NC}"
        exit 1
    fi
    echo -e "${GREEN}默认 Shell 已更改为 zsh，需要重新登录生效。${NC}"
fi

# 8. 完成提示
echo -e "${GREEN}所有步骤执行完毕！${NC}"
echo -e "${YELLOW}接下来请：${NC}"
echo "1. 退出当前终端并重新登录（或重启终端）使默认 Shell 生效。"
echo "2. 首次进入 zsh 时可能会显示 Oh My Zsh 的欢迎信息，按 'q' 跳过。"
echo "3. Powerlevel10k 会自动启动配置向导，按提示个性化你的提示符。"
echo "4. 如需重新运行 Powerlevel10k 配置向导，执行 'p10k configure'。"
