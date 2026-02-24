#!/bin/bash

# ============================================
# oh-my-zsh 一键安装配置脚本
# 功能：安装 zsh + oh-my-zsh + 插件 + 配置
# ============================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 root
if [ "$EUID" -eq 0 ]; then
    print_error "请不要使用 root 用户运行此脚本！"
    exit 1
fi

# ============================================
# 步骤 1: 安装 zsh
# ============================================
print_info "===== 步骤 1: 安装 zsh ====="
if command -v zsh &> /dev/null; then
    print_success "zsh 已安装: $(zsh --version)"
else
    print_info "正在安装 zsh..."
    sudo apt update
    sudo apt install -y zsh
    print_success "zsh 安装完成: $(zsh --version)"
fi

# ============================================
# 步骤 2: 安装 oh-my-zsh
# ============================================
print_info "===== 步骤 2: 安装 oh-my-zsh ====="
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_warning "oh-my-zsh 已存在，跳过安装"
else
    print_info "正在下载并安装 oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "oh-my-zsh 安装完成"
fi

# ============================================
# 步骤 3: 安装插件
# ============================================
print_info "===== 步骤 3: 安装插件 ====="

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# 3.1 安装 zsh-autosuggestions
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_warning "zsh-autosuggestions 已安装"
else
    print_info "安装 zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_success "zsh-autosuggestions 安装完成"
fi

# 3.2 安装 zsh-syntax-highlighting
if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_warning "zsh-syntax-highlighting 已安装"
else
    print_info "安装 zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    print_success "zsh-syntax-highlighting 安装完成"
fi

# 3.3 安装 zsh-history-substring-search
if [ -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
    print_warning "zsh-history-substring-search 已安装"
else
    print_info "安装 zsh-history-substring-search..."
    git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
    print_success "zsh-history-substring-search 安装完成"
fi

# 3.4 安装 fzf（系统级）
print_info "检查 fzf..."
if command -v fzf &> /dev/null; then
    print_success "fzf 已安装: $(fzf --version)"
else
    print_info "安装 fzf..."
    sudo apt install -y fzf
    print_success "fzf 安装完成"
fi

# ============================================
# 步骤 4: 安装 Powerlevel10k 主题（可选）
# ============================================
print_info "===== 步骤 4: 安装 Powerlevel10k 主题 ====="
read -p "是否安装 Powerlevel10k 主题？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        print_warning "Powerlevel10k 已安装"
    else
        print_info "安装 Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
        print_success "Powerlevel10k 安装完成"
        THEME="powerlevel10k/powerlevel10k"
    fi
else
    THEME="agnoster"
    print_info "使用默认主题: $THEME"
fi

# ============================================
# 步骤 5: 备份并生成 .zshrc 配置
# ============================================
print_info "===== 步骤 5: 配置 .zshrc ====="

# 备份原配置
if [ -f "$HOME/.zshrc" ]; then
    BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.zshrc" "$BACKUP_FILE"
    print_success "已备份原配置到: $BACKUP_FILE"
fi

# 生成新的 .zshrc
cat > "$HOME/.zshrc" << 'EOF'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  sudo
  docker
  docker-compose
  python
  pip
  npm
  node
  fzf
  extract
  z
  history-substring-search
  cp
  rsync
  httpie
  command-not-found
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Set preferred editor
export EDITOR='vim'
export VISUAL='vim'

# Set language
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Add custom bin directory to PATH
# export PATH="$HOME/bin:$PATH"

# Aliases
alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'
alias lt='ls -ltrh --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cdd='cd ~/Desktop'
alias cddo='cd ~/Documents'
alias cddw='cd ~/Downloads'

# System
alias update='sudo apt update && sudo apt upgrade -y'
alias upgrade='sudo apt update && sudo apt upgrade -y'
alias clean='sudo apt autoremove -y && sudo apt autoclean -y'
alias ports='netstat -tulanp'
alias myip='curl ifconfig.me'

# Git
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit -a -m'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gl='git log --oneline --graph'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gm='git merge'

# Docker
alias dps='docker ps -a'
alias di='docker images'
alias dc='docker-compose'
alias dclean='docker system prune -f'

# Python
alias py='python3'
alias ipy='ipython'

# History
alias h='history | grep'

# Custom functions
mkcd() {
    mkdir -p "$1"
    cd "$1"
}

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# Auto cd (just type directory name to cd into it)
setopt AUTO_CD

# Correct spelling for commands
setopt CORRECT

# Long running command notification
REPORTTIME=5

# Completion settings
autoload -Uz compinit
compinit

# FZF settings
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# History substring search bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

# Zsh autosuggestions settings
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#888'

# Custom prompt (if not using a theme)
# PROMPT='%F{blue}%n%f@%F{green}%m%f:%F{yellow}%~%f $(git_prompt_info)%# '
# RPROMPT='%F{cyan}[%*]%f'

# Load Powerlevel10k instant prompt if available
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
EOF

print_success ".zshrc 配置文件已生成"

# ============================================
# 步骤 6: 设置 zsh 为默认 shell
# ============================================
print_info "===== 步骤 6: 设置 zsh 为默认 shell ====="

CURRENT_SHELL=$(echo $SHELL)
if [[ "$CURRENT_SHELL" == *"zsh" ]]; then
    print_success "zsh 已是默认 shell"
else
    print_info "当前 shell: $CURRENT_SHELL"
    read -p "是否将 zsh 设置为默认 shell？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        chsh -s $(which zsh)
        print_success "已将 zsh 设置为默认 shell"
        print_warning "请重新登录或重启终端以生效"
    else
        print_info "跳过设置默认 shell"
    fi
fi

# ============================================
# 步骤 7: 安装额外字体（Powerlevel10k 需要）
# ============================================
if [[ $THEME == "powerlevel10k/powerlevel10k" ]]; then
    print_info "===== 步骤 7: 安装 Powerlevel10k 字体 ====="
    print_warning "Powerlevel10k 需要 Nerd Fonts 才能正常显示图标"
    print_info "推荐字体：FiraCode Nerd Font / MesloLGS Nerd Font"
    print_info "下载地址：https://www.nerdfonts.com/font-downloads"
    print_info "安装后需要在终端设置中选择该字体"
fi

# ============================================
# 完成
# ============================================
print_success "=========================================="
print_success "   oh-my-zsh 安装配置完成！"
print_success "=========================================="
echo
print_info "下一步操作："
echo "  1. 重新打开终端或运行: ${GREEN}exec zsh${NC}"
if [[ $THEME == "powerlevel10k/powerlevel10k" ]]; then
    echo "  2. Powerlevel10k 配置向导会自动启动"
    echo "  3. 按提示选择你喜欢的样式即可"
fi
echo
print_info "配置文件位置：${BLUE}~/.zshrc${NC}"
print_info "插件目录：${BLUE}~/.oh-my-zsh/custom/plugins${NC}"
print_info "主题目录：${BLUE}~/.oh-my-zsh/custom/themes${NC}"
echo
print_success "🎉 享受你的新终端吧！"
