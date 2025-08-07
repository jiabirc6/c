# --- 阶段 1: 构建阶段 ---
# 使用官方的 Node.js 18 "alpine" 镜像作为基础。alpine 是一个极简的 Linux 发行版，能让镜像更小。
FROM node:18-alpine AS builder

# 设置在容器内的工作目录
WORKDIR /app

# 复制 package.json 和 package-lock.json（或 yarn.lock）
# 这一步是为了利用 Docker 的缓存机制，如果依赖没变，就不用重新安装
COPY package*.json ./

# 安装所有项目依赖
RUN npm install

# 复制项目的其余所有文件到容器的 /app 目录
COPY . .

# 执行构建命令，生成生产环境的静态文件
# Vite 构建后的文件默认在 /app/dist 目录下
RUN npm run build

# --- 阶段 2: 运行阶段 ---
# 使用官方的 Nginx "alpine" 镜像，它非常轻量
FROM nginx:stable-alpine

# 将构建阶段生成的静态文件从 builder 容器复制到 Nginx 的网站根目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 暴露容器的 80 端口，这是 Nginx 默认监听的端口
EXPOSE 80

# 容器启动时运行的命令：启动 Nginx 服务
CMD ["nginx", "-g", "daemon off;"]
