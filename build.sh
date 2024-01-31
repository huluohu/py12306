#!/bin/bash
set -o errexit
echo "###############开始构建Docker镜像###############"
v="latest"
l="y"
while getopts ":v:l:" opt;
do
    case $opt in
        v) v="$OPTARG";;
        l) l="$OPTARG";;
    esac
done
echo "镜像版本：$v"
echo "仅本地构建：$l"

get_arch=`arch`
p="linux/amd64"
arm64="arm64"
if [ "$get_arch" == "$arm64" ]; then
    p="linux/arm64"
fi
echo "平台架构：$p"

is_local="y"
if [ "$l" == "$is_local" ]; then
    echo "开始构建本地镜像，忽略参数v=$v"
    docker buildx build --builder mybuildx  -t fooololo/py12306:latest  --platform $p --load .
else
    echo "开始构建并推送镜像,版本：$v"
    docker buildx build --builder mybuildx  -t fooololo/py12306:$cv  --platform linux/amd64,linux/arm64  --push .

    echo "开始构建并推送镜像,版本：latest"
    docker buildx build --builder mybuildx  -t fooololo/py12306:latest  --platform linux/amd64,linux/arm64  --push .
fi

echo "构建镜像完成"

## 如果构建失败，先执行一下：docker run --privileged --rm tonistiigi/binfmt --install all