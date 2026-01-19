# WindFind minimal search index shell script
# by Gustavo L Conte @2026
#!/usr/bin/env bash
set -euo pipefail

############################################
# CONFIGURATION
############################################

INDEX_DIR="${HOME}/.cache/windfind"
INDEX_DB="${INDEX_DIR}/index.db"
TMP_DB="${INDEX_DIR}/index.tmp"

# Directories to index (edit as needed)
SEARCH_PATHS=(
  "${HOME}"
  "/etc"
  "/usr/local"
)

# Common exclusions
EXCLUDES=(
  ".git"
  "node_modules"
  ".cache"
  ".npm"
  ".cargo"
)

############################################
# FUNCTIONS
############################################

usage() {
  cat <<EOF
Usage:
  $0 -u                 Update the index
  $0 STRING             Search STRING in the index
  $0 STRING -v          Search and show ls -lah of the current file

Examples:
  $0 ffmpeg
  $0 libQt6 -v
  $0 -u
EOF
}

ensure_index_dir() {
  mkdir -p "${INDEX_DIR}"
}

build_find_excludes() {
  local expr=""
  for e in "${EXCLUDES[@]}"; do
    expr+=" -path '*/${e}/*' -prune -o"
  done
  echo "${expr}"
}

update_index() {
  ensure_index_dir
  echo "🔄 Updating index..."

  : > "${TMP_DB}"

  local exclude_expr
  exclude_expr="$(build_find_excludes)"

  for path in "${SEARCH_PATHS[@]}"; do
    if [[ -d "${path}" ]]; then
      echo "📁 Indexing: ${path}"
      eval find "\"${path}\"" \
        ${exclude_expr} \
        -type f -print >> "${TMP_DB}"
    fi
  done

  sort -u "${TMP_DB}" > "${INDEX_DB}"
  rm -f "${TMP_DB}"

  echo "✅ Index updated: ${INDEX_DB}"
  echo "📊 Total files indexed: $(wc -l < "${INDEX_DB}")"
}

search_index() {
  local query="$1"

  if [[ ! -f "${INDEX_DB}" ]]; then
    echo "❌ Index not found. Run: $0 -u"
    exit 1
  fi

  grep -i -- "${query}" "${INDEX_DB}" || true
}

verbose_output() {
  local query="$1"

  search_index "${query}" | while IFS= read -r file; do
    if [[ -e "${file}" ]]; then
      ls -lah --color=auto "${file}"
    else
      echo -e "\e[31m[REMOVED]\e[0m ${file}"
    fi
  done
}

############################################
# MAIN
############################################

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

case "$1" in
  -u)
    update_index
    ;;
  -*)
    usage
    exit 1
    ;;
  *)
    if [[ "${2:-}" == "-v" ]]; then
      verbose_output "$1"
    else
      search_index "$1"
    fi
    ;;
esac
