---
name: atlas-package-cloner
description: Use Atlas to clone, install, update, link, pin, and reproduce Nim package dependencies in an isolated deps directory. Use when setting up Atlas projects, translating Nimble dependencies into Atlas-managed deps, fixing atlas.config, nim.cfg, project.nimble, lockfile, feature, override, or linked-project workflows, or preparing Atlas usage for CI.
---

# Atlas Package Cloner

Use this skill to manage Nim dependencies with Atlas. Atlas keeps dependencies in a project-local `deps/` directory and patches `project.nimble` plus `nim.cfg` so Nim can import cloned packages without Nimble path magic.

# Rules

## Project Shape

- Treat a directory containing `atlas.config` as an Atlas project.
- Use `atlas init` to turn the current directory into an Atlas project.
- Use `atlas init --deps=DIR` only when the project intentionally uses a non-default dependency directory.
- Expect this layout:

```text
project/
  project.nimble
  nim.cfg
  atlas.config
  deps/
    atlas.config
    dependency-a/
    dependency-b/
    linked-project.nimble-link
```

- Do not assume `deps/` is disposable. It can contain cloned repos, lockfile replay state, caches, and linked-project files.
- A project has higher dependency-resolution priority than a dependency. Moving a package into or out of `deps/` changes how Atlas treats it.

## Files Atlas Manages

- Atlas edits or creates `project.nimble` and `nim.cfg`.
- Preserve user-written content outside Atlas-managed sections.
- Expect `nim.cfg` to include an Atlas section like:

```text
############# begin Atlas config section ##########
--noNimblePath
--path:"deps/pkg"
--path:"deps/pkg/src"
--path:"../linked-project/src"
############# end Atlas config section   ##########
```

- If imports fail after dependency changes, inspect the generated `--path` entries before editing Nim source.
- If a package name resolves to the wrong URL, fix Atlas resolution with overrides instead of hand-editing cloned dependency paths.

## Package Names And URLs

- `atlas use <package>` resolves Nimble package names through `packages.json` or fallback search.
- `atlas use <url>` clones directly from a URL.
- Forge aliases are valid in commands and Nimble `require` statements:

| Alias | Expands to |
|-------|------------|
| `gh:user/repo` or `github:user/repo` | `https://github.com/user/repo` |
| `gl:user/repo` or `gitlab:user/repo` | `https://gitlab.com/user/repo` |
| `srht:~user/repo` or `sourcehut:~user/repo` | `https://git.sr.ht/~user/repo` |
| `cb:user/repo`, `cberg:user/repo`, or `codeberg:user/repo` | `https://codeberg.org/user/repo` |

- If dependency URLs use `git://`, prefer Atlas' `--forceGitToHttps` option instead of manually rewriting every dependency URL.
- Atlas downloads `packages.json` into `deps/_packages` by default. Use `--packagesRepo` only when the full packages repository clone is needed.

## Resolution And Reproducibility

- Inspect `atlas.config` before changing dependency policy.
- Atlas supports these `resolver` values:
  - `MaxVer`: select the highest available version that fits requirements.
  - `SemVer`: select the highest SemVer-compatible version that fits the range.
  - `MinVer`: select the highest version among minimum requirements.
- Set `resolver` explicitly when the task requires a specific policy.
- Use `atlas pin` to write the current dependency commits to `atlas.lock`.
- Use `atlas rep`, `atlas replay`, or `atlas reproduce` to replay pinned commits.
- Use `atlas rep --noexec` when reproducing dependencies but arbitrary dependency build actions should not run.
- Treat lockfiles as dependency pins only. They do not pin the Nim compiler, C/C++ compiler, system libraries, or OS image.

## Features

- Atlas supports a subset of Nim `when` expressions for platform and CPU defines: `windows`, `posix`, `linux`, `macosx`, `freebsd`, `openbsd`, `netbsd`, `solaris`, `amd64`, `x86_64`, `i386`, `arm`, `arm64`, `mips`, and `powerpc`.
- If a needed `when` expression is unsupported, prefer Nimble `feature` statements for optional dependencies.
- Feature flags are not saved to `atlas.config`.
- Pass features on commands that need them, for example `atlas --feature=testing install`.
- Use `--keepFeatures` or `-k` when the command should reuse feature defines already present in `nim.cfg`.
- In Nimble files, enable package features with syntax like `require "somelib[testing]"`.

## Overrides

- Use `nameOverrides` to map a package name to a URL.
- Use `urlOverrides` to rewrite matching URLs.
- Use `pkgOverrides` to resolve shortname conflicts, especially when a fork should be canonical.
- Prefer the narrowest override that fixes the dependency graph.
- Keep overrides in `atlas.config` so future `install`, `use`, `update`, and `rep` commands are repeatable.
- When working with forks, remember that Atlas may keep both the canonical fork remote and an upstream-style remote so branch tips and special versions can resolve correctly.

Example:

```json
{
  "resolver": "SemVer",
  "nameOverrides": {
    "customProject": "https://gitlab.company.com/customProject"
  },
  "urlOverrides": {
    "https://github.com/araq/ormin": "https://github.com/useMyForkInstead/ormin"
  },
  "pkgOverrides": {
    "asynctools": "https://github.com/timotheecour/asynctools"
  },
  "plugins": ""
}
```

## Linking Local Projects

- Use `atlas link ../other-project` to share dependencies with another local Atlas project.
- Confirm the linked target is itself an Atlas project and has a Nimble file.
- Expect `atlas link` to create `nimble-link` files and add the linked project to the current project's Nimble file if needed.
- Do not assume linked project overrides are imported. Copy or recreate needed `nameOverrides` or `urlOverrides` in the current project.

## Plugins And Build Actions

- Atlas plugins are NimScript snippets under the directory named by `plugins` in `atlas.config`, commonly `_plugins`.
- Plugins can call external tools through `exec`.
- If the task only needs dependency graph setup or lockfile replay, use `--noexec` when available to avoid running dependency build actions.
- Before enabling or editing plugins, inspect the matching `*.nims` files and the files they trigger on, such as `CMakeLists.txt`.

## Virtual Nim Environments

- Use `atlas env <version>` to install a project-local Nim version, for example `atlas env 1.6.12` or `atlas env devel`.
- After creation, activate it explicitly:
  - Unix: `source deps/nim-<version>/activate.sh`
  - Windows: `deps\nim-<version>\activate.bat`
- Do not assume the virtual Nim environment is active in later shell sessions.

# Workflow

1. Identify the project state.
   Check for `atlas.config`, `*.nimble`, `nim.cfg`, `atlas.lock`, `deps/`, `deps/atlas.config`, and `deps/.cache`.
2. Choose the operation.
   Use `init` for a new project, `use` for a new dependency, `install` to materialize existing Nimble requirements, `update` to refresh dependency refs, `link` for a local project, `pin` for a lockfile, `rep` to replay a lockfile, and `env` for a project-local Nim.
3. Inspect dependency policy.
   Read `resolver`, overrides, plugins, features, and package requirements before changing commands or files.
4. Run Atlas from the project root.
   Atlas commands are project-relative and update `project.nimble`, `nim.cfg`, `atlas.config`, `atlas.lock`, and `deps/`.
5. Verify the result.
   Inspect `nim.cfg` paths, check the Nimble file requirements, then compile or test the smallest relevant Nim target.
6. Preserve reproducibility.
   If the dependency set must be stable, run `atlas pin` after successful setup and commit `atlas.lock` if the repository expects lockfiles.

# Common Tasks

## Start A New Atlas Project

```bash
git init
atlas init
atlas use <package-or-url-or-forge-alias>
nim c <main-file>.nim
```

Use `atlas init --deps=vendor/deps` only when the repo intentionally keeps dependencies somewhere other than `deps/`.

## Add A Dependency

```bash
atlas use lexim
atlas use gh:zedeus/nitter
atlas use https://github.com/user/repo
```

Then verify:

```bash
rg '^--path' nim.cfg
nim c <file-that-imports-the-package>.nim
```

## Install Existing Nimble Requirements

```bash
atlas install
atlas --feature=test install
atlas --feature=test --feature=sqlite install
```

Use this when the `.nimble` file already contains `requires` entries and the goal is to clone the dependency graph.

## Update Dependencies

```bash
atlas update
atlas update <package-or-url-filter>
```

Use a filter for targeted updates. Rebuild or test after update because Atlas may rewrite `nim.cfg` paths and dependency commits.

## Pin And Reproduce Dependencies

```bash
atlas pin
atlas rep
atlas rep --noexec
```

Use `rep --noexec` when dependency build scripts should not run during replay.

## Link A Local Project

```bash
atlas link ../other-project
```

After linking, inspect the current project's Nimble file and `nim.cfg` for paths into the linked project and its dependencies.

## Prepare CI

- Install Atlas before dependency setup. If the bundled Nim version has an older Atlas, install the current head:

```bash
nimble install 'https://github.com/nim-lang/atlas@#head'
```

- Cache `deps/` using a key derived from the OS and Nimble file or lockfile.
- Run `atlas install` with all required `--feature` flags.
- Compile or test the project after Atlas setup.

Example shape:

```yaml
- name: Cache Atlas deps
  uses: actions/cache@v3
  with:
    path: deps/
    key: ${{ runner.os }}-${{ hashFiles('*.nimble', 'atlas.lock') }}

- name: Install deps
  run: atlas --feature=test install
```

# Troubleshooting

| Symptom | Check |
|---------|-------|
| Import cannot be found | Inspect Atlas section in `nim.cfg`; confirm the dependency was cloned and has the expected `src` path. |
| Wrong package was cloned | Add or fix `nameOverrides`, `urlOverrides`, or `pkgOverrides` in `atlas.config`. |
| Feature dependency is missing | Re-run with `--feature=<name>` or `--keepFeatures`; check Nimble `feature` blocks. |
| Linked project cannot resolve deps | Confirm both projects are Atlas projects; copy needed overrides into the current project. |
| `git://` clone fails | Re-run with `--forceGitToHttps` if appropriate. |
| Reproduce runs unexpected build steps | Use `atlas rep --noexec` and inspect configured plugins. |
| Repeated resolution is slow or stale | Inspect `deps/.cache`; Atlas should invalidate cache entries when remote HEAD, local commit, or release-collection flags change. |

# Common Mistakes

| Mistake | Why it is wrong |
|---------|-----------------|
| Editing Atlas-generated `nim.cfg` paths by hand first | The next Atlas command may overwrite them; fix dependency resolution or package metadata instead. |
| Assuming features persist in `atlas.config` | Features must be passed again or preserved with `--keepFeatures`. |
| Running `atlas link` and expecting overrides to follow | Linked project overrides are not imported into the current project. |
| Treating `atlas.lock` as a full build lock | It pins dependency commits, not compilers, system libraries, or OS packages. |
| Enabling plugins without inspection | Plugins can execute external tools. |
| Updating every dependency for a targeted fix | `atlas update <filter>` is safer when only one package needs refresh. |

# Changelog

- 2026-06-16: Initial Atlas package cloner skill.
