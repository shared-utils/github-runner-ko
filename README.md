# GitHub Runner with ko

專為 Go 專案 CI/CD 打造的 GitHub Actions Self-hosted Runner 映像檔，內建 ko 工具。

## 特色

- 基於官方 GitHub Actions Runner
- 內建 **ko** - Go 容器化工具
- 內建 **kubectl** - Kubernetes CLI
- 無需 Docker daemon
- 支援多平台（AMD64、ARM64）

## 使用

```bash
docker pull ghcr.io/shared-utils/github-runner-ko:latest
```

## 為什麼用 ko

- 🚀 無需寫 Dockerfile
- 🔒 不需要 Docker daemon 或特權模式
- ⚡ 建置速度快
- 📦 映像檔更小

## License

MIT
