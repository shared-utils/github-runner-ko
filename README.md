# GitHub Runner with ko

專為 Go 專案 CI/CD 打造的 GitHub Actions Self-hosted Runner，內建 ko 工具。

## 特色

- 內建 **ko** - 無需 Docker 建置 Go 容器映像
- 內建 **kubectl** - 部署到 Kubernetes
- 基於官方 GitHub Actions Runner
- 交互式一鍵部署

## 使用步驟

### 1. 建立 GitHub App

前往 **GitHub → Settings → Developer settings → GitHub Apps → New GitHub App**

**基本設定**
- App name: `arc-runner`
- Homepage URL: `https://github.com/actions/actions-runner-controller`
- Webhook: 留空

**權限設定**
- Repository: Actions (RW), Contents (R), Metadata (R)
- Organization: Self-hosted runners (RW)

**取得認證**
- APP_ID（頁面顯示）
- INSTALLATION_ID（安裝後從網址取得）
- Private Key（下載 .pem 檔案）

### 2. 部署到 Kubernetes

```bash
curl -sSL https://raw.githubusercontent.com/shared-utils/github-runner-ko/main/deploy.sh -o deploy.sh
chmod +x deploy.sh
./deploy.sh
```

腳本會交互式詢問配置資訊（自動偵測 .pem 檔案）。

### 3. 在 Workflow 中使用

```yaml
jobs:
  build:
    runs-on: [self-hosted, ko-runners]
    steps:
      - uses: actions/checkout@v4
      - run: ko publish ./cmd/app
```

## 為什麼用 ko

- 🚀 無需 Dockerfile，自動建置優化的容器映像
- 🔒 不需要 Docker daemon 或特權模式
- ⚡ 建置快速，基於 distroless 精簡映像
- 📦 專為 Go 應用設計

## 鏡像倉庫

```bash
docker pull ghcr.io/shared-utils/github-runner-ko:latest
```

查看版本：https://github.com/shared-utils/github-runner-ko/pkgs/container/github-runner-ko

## License

MIT
