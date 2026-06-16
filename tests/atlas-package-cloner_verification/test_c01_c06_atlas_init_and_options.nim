import std/[json, os, osproc, strutils]

proc runAtlas(args, cwd: string): tuple[output: string, code: int] =
  let res = execCmdEx("atlas " & args, options = {poStdErrToStdOut, poUsePath}, workingDir = cwd)
  (res.output, res.exitCode)

proc writeNimble(dir, name: string) =
  writeFile(
    dir / (name & ".nimble"),
    "version = \"0.1.0\"\n" &
    "author = \"Test\"\n" &
    "description = \"fixture\"\n" &
    "license = \"MIT\"\n"
  )

proc newProject(root, name: string): string =
  result = root / name
  createDir(result)
  writeNimble(result, name)

proc main() =
  let root = getTempDir() / ("atlas_skill_init_" & $getCurrentProcessId())
  if dirExists(root):
    removeDir(root)
  createDir(root)

  try:
    let defaultProject = newProject(root, "default_project")
    let initDefault = runAtlas("init", defaultProject)
    doAssert initDefault.code == 0, initDefault.output
    doAssert dirExists(defaultProject / "deps")
    doAssert fileExists(defaultProject / "deps" / "atlas.config")
    doAssert not fileExists(defaultProject / "atlas.config")
    doAssert not fileExists(defaultProject / "nim.cfg")

    let defaultConfig = parseFile(defaultProject / "deps" / "atlas.config")
    doAssert defaultConfig["deps"].getStr() == "deps"
    doAssert defaultConfig["nameOverrides"].kind == JObject
    doAssert defaultConfig["urlOverrides"].kind == JObject
    doAssert defaultConfig["pkgOverrides"].kind == JObject
    doAssert defaultConfig["plugins"].getStr() == ""
    doAssert defaultConfig["resolver"].getStr() == "SemVer"
    doAssert defaultConfig["graph"].kind == JNull

    let customProject = newProject(root, "custom_project")
    let initCustom = runAtlas("init --deps=vendor_deps", customProject)
    doAssert initCustom.code == 0, initCustom.output
    doAssert fileExists(customProject / "vendor_deps" / "atlas.config")
    let customConfig = parseFile(customProject / "vendor_deps" / "atlas.config")
    doAssert customConfig["deps"].getStr() == "vendor_deps"

    let customProject2 = newProject(root, "custom_project2")
    let initCustom2 = runAtlas("--deps=alt_deps init", customProject2)
    doAssert initCustom2.code == 0, initCustom2.output
    doAssert fileExists(customProject2 / "alt_deps" / "atlas.config")
    let customConfig2 = parseFile(customProject2 / "alt_deps" / "atlas.config")
    doAssert customConfig2["deps"].getStr() == "alt_deps"

    let help = runAtlas("--help", root)
    doAssert help.code == 0
    for text in [
      "use <url|pkgname>",
      "install",
      "update [filter]",
      "link <path>",
      "pin [atlas.lock]",
      "rep [atlas.lock]",
      "env <nimversion>",
      "--feature=<feature>",
      "--confdir=path",
      "--noexec",
      "--packagesRepo",
      "--resolver=minver|semver|maxver"
    ]:
      doAssert text in help.output, text

    let forceHttps = runAtlas("--forceGitToHttps --help", root)
    doAssert forceHttps.code == 0

    echo "C01-C06: PASS"
  finally:
    if dirExists(root):
      removeDir(root)

main()
