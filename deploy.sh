#!/bin/bash

set -e

echo "🚀 GitHub Actions Runner Controller (ARC) 部署工具"
echo "================================================"
echo ""

# 函数：寻找第一个 .pem 文件
find_pem_file() {
  local pem_file=$(find . -maxdepth 1 -name "*.pem" -type f | head -n 1)
  echo "$pem_file"
}

# 1. GitHub Organization/User
read -p "📌 GitHub Organization 或 Username: " GITHUB_ORG
if [ -z "$GITHUB_ORG" ]; then
  echo "❌ 錯誤：GitHub Organization 不能為空"
  exit 1
fi

# 2. App ID
read -p "📌 GitHub App ID: " APP_ID
if [ -z "$APP_ID" ]; then
  echo "❌ 錯誤：App ID 不能為空"
  exit 1
fi

# 3. Installation ID
read -p "📌 GitHub App Installation ID: " INSTALLATION_ID
if [ -z "$INSTALLATION_ID" ]; then
  echo "❌ 錯誤：Installation ID 不能為空"
  exit 1
fi

# 4. Private Key 路径
DEFAULT_PEM=$(find_pem_file)
if [ -n "$DEFAULT_PEM" ]; then
  read -p "📌 Private Key 路徑 [${DEFAULT_PEM}]: " PRIVATE_KEY_PATH
  PRIVATE_KEY_PATH=${PRIVATE_KEY_PATH:-$DEFAULT_PEM}
else
  read -p "📌 Private Key 路徑: " PRIVATE_KEY_PATH
fi

if [ -z "$PRIVATE_KEY_PATH" ]; then
  echo "❌ 錯誤：Private Key 路徑不能為空"
  exit 1
fi

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
  echo "❌ 錯誤：找不到檔案 $PRIVATE_KEY_PATH"
  exit 1
fi

# 5. Runner 配置
read -p "📌 最小 Runner 數量 [1]: " MIN_RUNNERS
MIN_RUNNERS=${MIN_RUNNERS:-1}

read -p "📌 最大 Runner 數量 [10]: " MAX_RUNNERS
MAX_RUNNERS=${MAX_RUNNERS:-10}

echo ""
echo "📋 部署配置摘要："
echo "  GitHub Org:       $GITHUB_ORG"
echo "  App ID:           $APP_ID"
echo "  Installation ID:  $INSTALLATION_ID"
echo "  Private Key:      $PRIVATE_KEY_PATH"
echo "  Min Runners:      $MIN_RUNNERS"
echo "  Max Runners:      $MAX_RUNNERS"
echo ""

read -p "確認部署？(y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "❌ 取消部署"
  exit 0
fi

echo ""
echo "📦 安裝 ARC Controller..."
helm upgrade --install arc-controller \
  --namespace arc-system \
  --create-namespace \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

echo ""
echo "⏳ 等待 Controller 就緒..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/arc-controller-gha-rs-controller \
  -n arc-system

echo ""
echo "🔑 建立 ServiceAccount 和權限..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: runner-sa
  namespace: arc-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: runner-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: runner-sa
    namespace: arc-system
EOF

echo ""
echo "🚀 部署 Runner ScaleSet..."
helm upgrade --install ko-runners \
  --namespace arc-system \
  --create-namespace \
  --set githubConfigUrl="https://github.com/${GITHUB_ORG}" \
  --set githubConfigSecret.github_app_id="${APP_ID}" \
  --set githubConfigSecret.github_app_installation_id="${INSTALLATION_ID}" \
  --set-file githubConfigSecret.github_app_private_key="${PRIVATE_KEY_PATH}" \
  --set minRunners=${MIN_RUNNERS} \
  --set maxRunners=${MAX_RUNNERS} \
  --set runnerScaleSetName=ko \
  --set template.spec.serviceAccountName=runner-sa \
  --set template.spec.containers[0].name=runner \
  --set template.spec.containers[0].image="ghcr.io/shared-utils/github-runner-ko:0.0.2" \
  --set template.spec.containers[0].imagePullPolicy=IfNotPresent \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

echo ""
echo "✅ 部署完成！"
echo ""
echo "📊 查看 Runner 狀態："
echo "  kubectl get pods -n arc-system"
echo ""
echo "📊 查看 Runner ScaleSet："
echo "  kubectl get autoscalingrunnersets -n arc-system"
echo ""
echo "🎯 在 GitHub Workflow 中使用："
echo "  runs-on: [self-hosted, ko]"
