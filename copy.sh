#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_BASE="${HOME}/.claude"

copy_dir() {
    local source_dir="$1"
    local target_dir="$2"
    local label="$3"

    if [ ! -d "${source_dir}" ]; then
        return
    fi

    # .keep のみの場合はスキップ
    local count
    count=$(find "${source_dir}" -mindepth 1 -not -name '.keep' | head -1 | wc -l)
    if [ "${count}" -eq 0 ]; then
        echo "${label}: スキップ（コンテンツなし）"
        return
    fi

    mkdir -p "${target_dir}"
    echo "${label}を ${target_dir} にコピーします..."

    for item_dir in "${source_dir}"/*/; do
        [ -d "${item_dir}" ] || continue
        local item_name
        item_name="$(basename "${item_dir}")"
        echo "  ${item_name}"
        mkdir -p "${target_dir}/${item_name}"
        cp -r "${item_dir}"* "${target_dir}/${item_name}/"
    done
}

echo "=== Claude Code グローバルコピー ==="
echo ""

copy_dir "${SCRIPT_DIR}/skills" "${TARGET_BASE}/skills" "Skills"
copy_dir "${SCRIPT_DIR}/commands" "${TARGET_BASE}/commands" "Commands"

echo ""
echo "コピー完了"
