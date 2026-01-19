# windfind

`windfind` is a lightweight, user-controlled file indexing and search tool for Linux.
It behaves like a personal `locate`, but with explicit indexing, no hidden daemons,
and full control over what gets indexed.

---

## Features

- Explicit, manual indexing (`-u`)
- Fast substring search over indexed paths
- Verbose mode validates real filesystem state
- Colored `ls -lah` output in verbose mode
- Safe handling of spaces in filenames
- No dependency on `locate` / `mlocate`
- Works well on NFS, labs, VMs, and large homes

---

## Installation

```bash
chmod +x windfind.sh
```

Optionally move it into your PATH:

```bash
mv windfind.sh ~/.local/bin/windfind
```

---

## Usage

### Update index

```bash
windfind -u
```

### Search by string

```bash
windfind ffmpeg
```

Outputs one file path per line from the index.

### Verbose search

```bash
windfind Qt6 -v
```

For each indexed result:
- checks if the file still exists
- prints `ls -lah --color=auto`
- prints `[REMOVED]` if the file no longer exists

---

## Index location

The index is stored at:

```
~/.cache/windfind/index.db
```

---

## Configuration

Edit the script to customize:

### Indexed directories

```bash
SEARCH_PATHS=(
  "$HOME"
  "/etc"
  "/usr/local"
)
```

### Excluded paths

```bash
EXCLUDES=(
  ".git"
  "node_modules"
  ".cache"
)
```

---

## Design philosophy

- No background daemons
- No magic automation
- No hidden global database
- Trust the filesystem, not stale metadata
- Simple, debuggable, portable shell code

---

## License

Public domain / Do whatever you want.
