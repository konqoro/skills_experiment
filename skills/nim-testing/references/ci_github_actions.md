GitHub Actions CI workflow for a Nim project. Runs the auto-discovering test runner across Linux, macOS, and Windows in debug, release, and danger configurations. Includes an optional AddressSanitizer job on Linux.

Adapted from verified patterns in production Nim projects using `jiro4989/setup-nim-action@v2` and `actions/checkout@v7`.

## `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
  workflow_dispatch:

jobs:
  linux:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v7

      - name: Install Nim
        uses: jiro4989/setup-nim-action@v2
        with:
          nim-version: stable
          repo-token: ${{ github.token }}

      - name: Install Atlas
        run: nimble install -y "https://github.com/nim-lang/atlas@#head"

      - name: Install Nim dependencies
        run: atlas install

      - name: Run tests (debug)
        run: nim c -r tests/tester.nim

      - name: Run tests (release)
        run: nim c -d:release -r tests/tester.nim

      - name: Run tests (danger)
        run: nim c -d:danger -r tests/tester.nim

  macos:
    runs-on: macos-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v7

      - name: Install Nim
        uses: jiro4989/setup-nim-action@v2
        with:
          nim-version: stable
          repo-token: ${{ github.token }}

      - name: Install Atlas
        run: nimble install -y "https://github.com/nim-lang/atlas@#head"

      - name: Install Nim dependencies
        run: atlas install

      - name: Run tests (debug)
        run: nim c -r tests/tester.nim

      - name: Run tests (release)
        run: nim c -d:release -r tests/tester.nim

      - name: Run tests (danger)
        run: nim c -d:danger -r tests/tester.nim

  windows:
    runs-on: windows-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v7

      - name: Install Nim
        uses: jiro4989/setup-nim-action@v2
        with:
          nim-version: stable
          repo-token: ${{ github.token }}

      - name: Install Atlas
        run: nimble install -y "https://github.com/nim-lang/atlas@#head"

      - name: Install Nim dependencies
        run: atlas install

      - name: Run tests (debug)
        run: nim c -r tests/tester.nim

      - name: Run tests (release)
        run: nim c -d:release -r tests/tester.nim

      - name: Run tests (danger)
        run: nim c -d:danger -r tests/tester.nim

  sanitizer:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v7

      - name: Install Nim
        uses: jiro4989/setup-nim-action@v2
        with:
          nim-version: stable
          repo-token: ${{ github.token }}

      - name: Run tests with AddressSanitizer
        run: |
          nim c \
            --passC:"-fsanitize=address -fno-omit-frame-pointer" \
            --passL:"-fsanitize=address -fno-omit-frame-pointer" \
            -g -d:noSignalHandler -d:useMalloc \
            -r tests/tester.nim
```

## How it works

- **One job per OS:** `linux`, `macos`, `windows` run in parallel. Each runs the test suite in debug, release, and danger configurations as sequential steps.
- **Runner selection:** `ubuntu-latest` (x86_64), `macos-latest` (ARM64), `windows-latest` (x86_64). These are free for public repositories.
- **Sanitizer job:** Separate single job on Linux with gcc's AddressSanitizer. Not run on macOS or Windows due to toolchain differences.
- **Test runner:** Each job runs `tests/tester.nim`, which auto-discovers and executes all `tests/t*.nim` files.

## Customization

- Add `atlas install` before the test steps if the project has dependencies. Use `atlas use <pkg>` to add a new dependency.
- Add a `config.nims` at project root for project-wide defaults (allocator selection, memory manager).
- For Windows-specific compiler flags (e.g., MSVC), add a conditional step or use `tests/config.nims` with `when defined(windows)` blocks.
- To install system libraries, add OS-specific steps:
  - Linux: `sudo apt-get install -y <packages>`
  - macOS: `brew install <packages>`
  - Windows: use vcpkg or prebuilt binaries

Key points:

- The `jiro4989/setup-nim-action@v2` action installs Nim stable and adds it to PATH. `repo-token` avoids rate limits.
- Each OS job runs debug, release, and danger as separate steps so a failure in one mode does not mask results in the others.
- The sanitizer job is separate so it does not slow down the main jobs. Remove it if the project does not use unsafe constructs.
