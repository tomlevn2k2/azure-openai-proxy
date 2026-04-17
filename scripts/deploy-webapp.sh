#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/deploy-webapp.sh --resource-group <rg> [--webapp-name <name>] [--package-path <zip> | --package-url <url>] [--subscription <id>]
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PARAM_FILE="${PROJECT_DIR}/main.bicepparam"
TEMPLATE_FILE="${PROJECT_DIR}/main.bicep"
DEFAULT_PACKAGE_PATH="${PROJECT_DIR}/openai-responses-api.zip"
RESOURCE_GROUP_LOCATION="southeastasia"

RESOURCE_GROUP_NAME=""
WEBAPP_NAME=""
PACKAGE_PATH=""
PACKAGE_URL=""
SUBSCRIPTION_ID=""

get_bicep_param_value() {
  local file_path="$1"
  local param_name="$2"
  awk -v name="$param_name" '
    $1 == "param" && $2 == name {
      match($0, /'\''[^'\'']+'\''/)
      if (RSTART > 0) {
        value = substr($0, RSTART + 1, RLENGTH - 2)
        print value
        exit
      }
    }
  ' "$file_path"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --resource-group|-g)
      RESOURCE_GROUP_NAME="$2"
      shift 2
      ;;
    --webapp-name|-n)
      WEBAPP_NAME="$2"
      shift 2
      ;;
    --package-path)
      PACKAGE_PATH="$2"
      shift 2
      ;;
    --package-url)
      PACKAGE_URL="$2"
      shift 2
      ;;
    --subscription|-s)
      SUBSCRIPTION_ID="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "${RESOURCE_GROUP_NAME}" ]]; then
  echo "--resource-group is required." >&2
  usage >&2
  exit 1
fi

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI 'az' is required." >&2
  exit 1
fi

if [[ ! -f "${PARAM_FILE}" ]]; then
  echo "Parameter file not found: ${PARAM_FILE}" >&2
  exit 1
fi

if [[ ! -f "${TEMPLATE_FILE}" ]]; then
  echo "Template file not found: ${TEMPLATE_FILE}" >&2
  exit 1
fi

if [[ -z "${WEBAPP_NAME}" ]]; then
  WEBAPP_NAME="$(get_bicep_param_value "${PARAM_FILE}" "webAppName")"
fi

if [[ -z "${WEBAPP_NAME}" ]]; then
  echo "Unable to resolve webAppName from ${PARAM_FILE}." >&2
  exit 1
fi

if [[ -n "${SUBSCRIPTION_ID}" ]]; then
  az account set --subscription "${SUBSCRIPTION_ID}" >/dev/null
fi

az account show >/dev/null

az group create \
  --name "${RESOURCE_GROUP_NAME}" \
  --location "${RESOURCE_GROUP_LOCATION}" \
  --output table

az deployment group create \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --template-file "${TEMPLATE_FILE}" \
  --parameters "${PARAM_FILE}" \
  --output table

if [[ -z "${PACKAGE_PATH}" && -z "${PACKAGE_URL}" ]]; then
  PACKAGE_PATH="${DEFAULT_PACKAGE_PATH}"
fi

if [[ -n "${PACKAGE_PATH}" && -n "${PACKAGE_URL}" ]]; then
  echo "Specify either --package-path or --package-url, not both." >&2
  exit 1
fi

if [[ -n "${PACKAGE_PATH}" ]]; then
  if [[ ! -f "${PACKAGE_PATH}" ]]; then
    echo "Package file not found: ${PACKAGE_PATH}" >&2
    exit 1
  fi

  az webapp deploy \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --name "${WEBAPP_NAME}" \
    --src-path "${PACKAGE_PATH}" \
    --type zip \
    --clean true \
    --restart true \
    --track-status true \
    --output table
else
  az webapp deploy \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --name "${WEBAPP_NAME}" \
    --src-url "${PACKAGE_URL}" \
    --type zip \
    --restart true \
    --async true \
    --output table
fi

DEFAULT_HOSTNAME="$(az webapp show --resource-group "${RESOURCE_GROUP_NAME}" --name "${WEBAPP_NAME}" --query defaultHostName --output tsv)"
echo "Infrastructure and app deployment completed for resource group '${RESOURCE_GROUP_NAME}'."
echo "App URL: https://${DEFAULT_HOSTNAME}"
