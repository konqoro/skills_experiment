import std/[os, strutils]

let sourceDir = getEnv("ATLAS_SOURCE_DIR", "/home/ageralis/Projects/atlas/src")
doAssert dirExists(sourceDir), "Atlas source directory not found: " & sourceDir

proc readSource(path: string): string =
  readFile(sourceDir / path)

let atlasMain = readSource("atlas.nim")
let pkgUrls = readSource("basic/pkgurls.nim")
let configHandler = readSource("confighandler.nim")
let jsonConfigSection = configHandler.split("ActivatedPackage* = object")[0]
doAssert "type\n  JsonConfig* = object" in configHandler
for field in [
  "deps*: string",
  "nameOverrides*: Table[string, string]",
  "urlOverrides*: Table[string, string]",
  "pkgOverrides*: Table[string, string]",
  "plugins*: string",
  "resolver*: string",
  "graph*: JsonNode"
]:
  doAssert field in configHandler, field
doAssert "resolver: $SemVer" in configHandler
doAssert "features*:" notin jsonConfigSection
doAssert "ctx.nameOverrides.addPattern" in configHandler
doAssert "ctx.urlOverrides.addPattern" in configHandler
doAssert "ctx.pkgOverrides[key] = parseUri(val)" in configHandler
doAssert "ctx.defaultAlgo = parseEnum[ResolutionAlgorithm](m.resolver)" in configHandler
doAssert "readPluginsDir(m.plugins.Path)" in configHandler
doAssert "walkDir($(project() / dir))" in configHandler
doAssert "f.endsWith(\".nims\")" in configHandler

let nimbleContext = readSource("basic/nimblecontext.nim")
doAssert "doAssert not nameOrig.isAbsolute()" in nimbleContext
doAssert "if nameOrig.isUrl()" in nimbleContext
doAssert "substitute(nc.urlOverrides, nameOrig" in nimbleContext
doAssert "substitute(nc.nameOverrides, nameOrig" in nimbleContext
doAssert "nc.lookup(name)" in nimbleContext
doAssert "fileExists(packageInfosFile())" in nimbleContext
doAssert "updatePackages()" in nimbleContext
doAssert "createUrlFromPath" in nimbleContext
doAssert "link://" in nimbleContext
doAssert "atlas://" in nimbleContext

let nimbleParser = readSource("basic/nimbleparser.nim")
doAssert "patchNimbleFile" in nimbleParser
doAssert "var url = nc.createUrl(name)" in nimbleParser

let allAtlasSource = atlasMain & nimbleContext & readSource("basic/pkgurls.nim")
for aliasText in ["github", "gitlab", "sourcehut", "codeberg", "cberg", "srht"]:
  doAssert aliasText in allAtlasSource.toLowerAscii(), aliasText
doAssert "isForgeAlias" in pkgUrls
doAssert "expandForgeAlias" in pkgUrls
doAssert "github.com/" in pkgUrls
doAssert "gitlab.com/" in pkgUrls
doAssert "git.sr.ht/" in pkgUrls
doAssert "codeberg.org/" in pkgUrls

let packageInfos = readSource("basic/packageinfos.nim")
doAssert "PackagesJsonUrls" in packageInfos
doAssert "https://packages.nim-lang.org/packages.json" in packageInfos
doAssert "https://raw.githubusercontent.com/nim-lang/packages" in packageInfos
doAssert "writeFile($pkgsFile, contents)" in packageInfos
doAssert "https://github.com/nim-lang/packages" in packageInfos
doAssert "if PackagesGit in context().flags" in packageInfos

let configUtils = readSource("basic/configutils.nim")
doAssert "configPatternBegin = \"############# begin Atlas config section ##########\\n\"" in configUtils
doAssert "configPatternEnd =   \"############# end Atlas config section   ##########\\n\"" in configUtils
doAssert "var paths = \"--noNimblePath\\n\"" in configUtils
doAssert "paths.add \"--path:\\\"\" & x & \"\\\"\\n\"" in configUtils
doAssert "content.substr(0, start-1)" in configUtils
doAssert "content.substr(theEnd+len(configPatternEnd))" in configUtils

doAssert "of \"feature\":" in atlasMain
doAssert "proc addRequestedFeature(rawFeature: string)" in atlasMain
doAssert "addRequestedFeature(val)" in atlasMain
doAssert "addRequestedFeatures(val)" in atlasMain
doAssert "of \"noexec\":" in atlasMain
doAssert "context().flags.incl NoExec" in atlasMain
doAssert "of \"packagesrepo\":" in atlasMain
doAssert "context().flags.incl PackagesGit" in atlasMain
doAssert "of \"forcegittohttps\":" in atlasMain.toLowerAscii()
doAssert "of \"keepfeatures\", \"k\":" in atlasMain.toLowerAscii()

let depGraphs = readSource("depgraphs.nim")
doAssert "of MinVer: p.versions.sort(sortVersionsDesc)" in depGraphs
doAssert "of SemVer, MaxVer: p.versions.sort(sortVersionsAsc)" in depGraphs
doAssert "feature in context().features" in depGraphs
doAssert "\"feature.\" & graph.root.url.projectName & \".\" & feature" in depGraphs
doAssert "\"feature.\" & pkg.url.shortName & \".\" & feature" in depGraphs

let versions = readSource("basic/versions.nim")
doAssert "proc selectBestCommitMinVer*" in versions
doAssert "proc selectBestCommitMaxVer*" in versions
doAssert "proc toSemVer*" in versions
doAssert "result.b = VersionReq(r: verLt, v: Version($(major+1)))" in versions
doAssert "proc selectBestCommitSemVer*" in versions

let parseRequires = readSource("basic/parse_requires.nim")
doAssert "of \"feature\":" in parseRequires
doAssert "feature requires string literals" in parseRequires
doAssert "result.features[f] = newSeq[string]()" in parseRequires

let nimEnv = readSource("nimenv.nim")
doAssert "Implementation of the \"Nim virtual environment\" (`atlas env`) feature." in nimEnv
doAssert "nimVersion == \"devel\"" in nimEnv
doAssert "ActivationFile* = when defined(windows): Path \"activate.bat\" else: Path \"activate.sh\"" in nimEnv
doAssert "source nim-\" & nimVersion & \"/activate.sh" in nimEnv
doAssert "nim-\" & nimVersion & \"\\\\activate.bat" in nimEnv

echo "C07-C20: PASS"
