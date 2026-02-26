#!/bin/bash

echo "=================================================="
echo "开始安装 Docker Engine"
echo "=================================================="

# 更新包索引
echo "[1/5] 更新包索引..."
sudo apt-get update

# 安装依赖包
echo "[2/5] 安装依赖包..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# 添加 Docker 官方 GPG 密钥
echo "[3/5] 添加 Docker GPG 密钥..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 设置 Docker 仓库
echo "[4/5] 设置 Docker 仓库..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker Engine
echo "[5/5] 安装 Docker Engine..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 启动 Docker 服务
echo "启动 Docker 服务..."
sudo service docker start

# 将当前用户添加到 docker 组
echo "将当前用户添加到 docker 组..."
sudo usermod -aG docker $USER

# 验证安装
echo "=================================================="
echo "验证 Docker 安装..."
sudo docker --version
sudo docker compose version

echo "=================================================="
echo "Docker 安装完成!"
echo "请运行以下命令使组设置生效："
echo "=================================================="
