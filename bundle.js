const fs = require('fs')
const path = require('path')

const args = process.argv.slice(2)
if (args.length < 2) {
  console.error('❌ Usage: node bundle.js <entry.lua> <output.lua>')
  process.exit(1)
}

const ENTRY_FILE = args[0]
let outputPath = args[1]

if (fs.existsSync(outputPath) && fs.statSync(outputPath).isDirectory()) {
  outputPath = path.join(outputPath, path.basename(ENTRY_FILE))
}

if (path.extname(outputPath) !== '.lua') outputPath += '.lua'
const OUTPUT_FILE = outputPath

// 상태 관리
const includedModules = new Set()
const preloads = []
const hoistedComments = []
let totalInputBytes = 0

const REQUIRE_REGEX = /require\s*\(?["']([^"']+)["']\)?/g

function resolvePath(moduleName) {
  return moduleName.replace(/\./g, '/') + '.lua'
}

function formatBytes(bytes) {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

function smartMinify(content) {
  const tokenRegex = /(--\[(=*)\[[\s\S]*?\]\2\])|(--.*)|(\[(=*)\[[\s\S]*?\]\5\])|("([^"\\]|\\.)*")|('([^'\\]|\\.)*')/g

  return content
    .replace(tokenRegex, (match, longComm, lcEq, shortComm) => {
      if (longComm || shortComm) {
        if (shortComm && match.startsWith('--!')) {
          hoistedComments.push(match)
          return ' '
        }
        if (longComm && /^--\[(=*)\[!/.test(match)) {
          hoistedComments.push(match)
          return ' '
        }

        return ' '
      }
      return match
    })
    .split('\n')
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .join('\n')
}

function processModule(moduleName) {
  if (includedModules.has(moduleName)) return

  const rootDir = path.dirname(path.resolve(ENTRY_FILE))
  const modulePath = path.join(rootDir, resolvePath(moduleName))

  if (!fs.existsSync(modulePath)) {
    console.warn(`⚠️  Warning: Module '${moduleName}' not found.`)
    return
  }

  const stats = fs.statSync(modulePath)
  totalInputBytes += stats.size

  includedModules.add(moduleName)

  const rawContent = fs.readFileSync(modulePath, 'utf8')

  let match
  const regex = new RegExp(REQUIRE_REGEX)
  while ((match = regex.exec(rawContent)) !== null) {
    processModule(match[1])
  }

  const minifiedContent = smartMinify(rawContent)
  preloads.push(`package.preload["${moduleName}"]=function(...)${minifiedContent} end`)
}

function bundle() {
  console.log(`🚀 Bundling: ${ENTRY_FILE} -> ${OUTPUT_FILE}`)

  if (!fs.existsSync(ENTRY_FILE)) {
    console.error(`❌ Error: Entry file not found: ${ENTRY_FILE}`)
    process.exit(1)
  }

  const mainStats = fs.statSync(ENTRY_FILE)
  totalInputBytes += mainStats.size

  const mainRaw = fs.readFileSync(ENTRY_FILE, 'utf8')

  let match
  const mainRegex = new RegExp(REQUIRE_REGEX)
  while ((match = mainRegex.exec(mainRaw)) !== null) {
    processModule(match[1])
  }

  const mainMinified = smartMinify(mainRaw)

  const hoisted = hoistedComments.length > 0 ? hoistedComments.join('\n') + '\n' : ''
  const finalOutput = hoisted + preloads.join('\n') + '\n' + mainMinified

  const outputDir = path.dirname(OUTPUT_FILE)
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true })

  fs.writeFileSync(OUTPUT_FILE, finalOutput, 'utf8')

  const outputBytes = fs.statSync(OUTPUT_FILE).size
  const reduction = ((totalInputBytes - outputBytes) / totalInputBytes) * 100

  console.log(`\n📊 Build Summary`)
  console.log(`-----------------------------------`)
  console.log(`  Target:     ${includedModules.size} modules + Entry`)
  console.log(`  Original:   ${formatBytes(totalInputBytes)}`)
  console.log(`  Bundled:    ${formatBytes(outputBytes)}`)
  console.log(`  Reduction:  ${reduction.toFixed(2)}% 📉`)
  console.log(`-----------------------------------`)
}

bundle()
