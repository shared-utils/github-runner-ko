# GitHub Runner with ko

專為 Go 專案 CI/CD 打造的 GitHub Actions Self-hosted Runner。

## 特色

- ✅ 基於官方 GitHub Actions Runner
- ✅ 內建 **ko** - Go 容器化工具（無需 Docker）
- ✅ 內建 **kubectl** - Kubernetes CLI
- ✅ 支援多平台（AMD64）
- ✅ 一鍵部署到 Kubernetes

## 快速開始

```bash
# 1. 下載部署腳本
curl -sSL https://raw.githubusercontent.com/shared-utils/github-runner-ko/main/deploy.sh -o deploy.sh
chmod +x deploy.sh

# 2. 執行部署（需先建立 GitHub App）
./deploy.sh
```

## 詳細步驟

### 1. 建立 GitHub App

前往：**GitHub → Settings → Developer settings → GitHub Apps → New GitHub App**

填寫：
- **GitHub App name**: `arc-runner`
- **Homepage URL**: `https://github.com/actions/actions-runner-controller`
- **Webhook URL**: 留空

設定權限：

**Repository permissions**
- Actions: Read & Write
- Contents: Read-only
- Metadata: Read-only

**Organization permissions**
- Self-hosted runners: Read & Write

建立後取得：
- **APP_ID**（在頁面上看到）
- **INSTALLATION_ID**（安裝 App 後，從網址取得 `/installations/xxxxxx`）
- **Private Key**（點擊 "Generate a private key" 下載 .pem 檔案）

### 2. 部署到 Kubernetes

下載 Private Key 檔案到當前目錄，然後執行部署腳本：

```bash
# 下載部署腳本
curl -sSL https://raw.githubusercontent.com/shared-utils/github-runner-ko/main/deploy.sh -o deploy.sh
chmod +x deploy.sh

# 執行部署（交互式）
./deploy.sh
```

腳本會詢問：
- GitHub Organization/Username
- App ID
- Installation ID
- Private Key 路徑（自動偵測 .pem 檔案）
- Runner 數量（預設 1-10）

### 3. 在 Workflow 中使用

```yaml
jobs:
  build:
    runs-on: [self-hosted, ko-runners]
    steps:
      - uses: actions/checkout@v4
      
      - name: Build and Push
        run: ko publish ./cmd/app
```

## 為什麼用 ko

- 🚀 無需寫 Dockerfile
- 🔒 不需要 Docker daemon 或特權模式
- ⚡ 建置速度快
- 📦 映像檔更小（基於 distroless）

## 可用鏡像

```bash
docker pull ghcr.io/shared-utils/github-runner-ko:latest
```

查看所有版本：https://github.com/shared-utils/github-runner-ko/pkgs/container/github-runner-ko

## License

MIT
