#!/bin/bash
#!/bin/bash
# 获取kubecm最新版本号
path=$(pwd)
version=$(curl https://api.github.com/repos/vmware-tanzu/velero/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$version" ]; then
    echo "最新版本号:$version"
else
    echo "获取版本号失败"
fi

echo "开始下载..."
curl -Lo kubecm.tar.gz "https://api.github.com/repos/vmware-tanzu/velero/releases/download/${version}/velero-${version}_linux-amd64.tar.gz"
file=$path+"/kubecm.tar.gz"
if [ -f "$file" ]; then
    echo "下载成功"
else
    echo "下载失败"
fi

echo "解压安装"
tar -zxvf kubecm.tar.gz kubecm
sudo mv kubecm /usr/local/bin/
success=kubecm version | grep '"Version":' | sed -E 's/.*"([^"]+)".*/\1/'
# 判断是否安装成功
if [ "$success" = "$version" ]; then
  echo "安装完成"
else
  echo "安装失败"
fi
