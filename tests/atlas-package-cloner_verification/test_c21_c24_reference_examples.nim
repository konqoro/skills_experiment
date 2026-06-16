import std/[os, osproc, strutils]

proc runAtlas(args, cwd: string): tuple[output: string, code: int] =
  let res = execCmdEx("atlas " & args, options = {poStdErrToStdOut, poUsePath}, workingDir = cwd)
  (res.output, res.exitCode)

let root = getCurrentDir()
let skill = readFile(root / "skills/atlas-package-cloner/SKILL.md")
let startProject = readFile(root / "skills/atlas-package-cloner/references/start_project.md")
let customDeps = readFile(root / "skills/atlas-package-cloner/references/custom_deps_and_overrides.md")
let featuresReplay = readFile(root / "skills/atlas-package-cloner/references/features_and_replay.md")

for refPath in [
  "references/start_project.md",
  "references/custom_deps_and_overrides.md",
  "references/features_and_replay.md"
]:
  doAssert refPath in skill, refPath

for doc in [startProject, customDeps, featuresReplay]:
  doAssert doc.splitLines()[0].len > 0
  doAssert "```bash" in doc
  doAssert "# Key points" in doc

let help = runAtlas("--help", root)
doAssert help.code == 0
for text in [
  "init",
  "use <url|pkgname>",
  "install",
  "update [filter]",
  "pin [atlas.lock]",
  "rep [atlas.lock]",
  "replay [atlas.lock]",
  "reproduce [atlas.lock]",
  "--feature=<feature>",
  "--features=<list>",
  "--allFeatures",
  "--keepFeatures, -k",
  "--noexec",
  "--deps=path",
  "--forceGitToHttps"
]:
  doAssert text in help.output, text

let sourceDir = getEnv("ATLAS_SOURCE_DIR", "/home/ageralis/Projects/atlas/src")
let pkgUrls = readFile(sourceDir / "basic/pkgurls.nim")
for text in [
  "\"gh\": ForgeGitHub",
  "\"github\": ForgeGitHub",
  "github.com/",
  "gitlab.com/",
  "git.sr.ht/",
  "codeberg.org/"
]:
  doAssert text in pkgUrls, text

doAssert "atlas init" in startProject
doAssert "atlas use gh:user/repo" in startProject
doAssert "deps/atlas.config" in startProject

doAssert "atlas init --deps=vendor/atlas-deps" in customDeps
doAssert "\"nameOverrides\"" in customDeps
doAssert "\"urlOverrides\"" in customDeps
doAssert "\"pkgOverrides\"" in customDeps
doAssert "atlas --forceGitToHttps install" in customDeps

doAssert "atlas --feature=test install" in featuresReplay
doAssert "atlas --features=\"sqlite ssl\" update" in featuresReplay
doAssert "atlas --keepFeatures install" in featuresReplay
doAssert "atlas --noexec rep atlas.lock" in featuresReplay
doAssert "atlas --allFeatures install" in featuresReplay

echo "C21-C24: PASS"
