import * as fs from 'node:fs';
import * as path from 'node:path';
import { OrderedSet } from 'js-sdsl';
import jsonStringify from "json-stringify-pretty-compact";
import YAML from 'yaml'

/**
* @typedef {object} SearchSet
* @property {string} SearchFile.name
* @property {string[]} SearchFile.buckets
*/

/**
* @typedef {object} SearchFile
* @property {SearchSet[]} SearchFile.sets
* @property {boolean} SearchFile.verbose
*/

/**
* @typedef {Map<string, Map<number,number>[]>} ByteCounts
*/

/**
 * 
 * @param {SearchSet} set
 * @returns {Map<number,number>[]}
 */
function loadSearchSet(set) {
    /** @type {Map<number,number>[]} */
    const byteCounts = []

    for (const dirName of set.buckets) {
        const dirPath = path.join(path.dirname(import.meta.dirname), "/data/buckets/", dirName)

        for (const fileName of fs.readdirSync(dirPath)) {
            const filePath = path.join(dirPath, fileName)

            if (!fileName.endsWith(".bin")) {
                continue
            }

            const buffer = fs.readFileSync(filePath, {flag: "r"})
            for (const [i, byte] of buffer.entries()) {
                
                const byteCount = byteCounts[i] ?? new Map()
                byteCount.set(byte, (byteCount.get(byte) ?? 0) + 1)

                byteCounts[i] = byteCount
            }
        }
    }

    return byteCounts
}

/**
 * 
 * @param {number} n
 * @returns {string} 
 */
function formatHex(n) {
    const digits = n.toString(16).toUpperCase()
    const length = Math.ceil(digits.length / 2) * 2

    return "0x" + digits.padStart(length, 0)
}

/**
 * @typedef {object} ByteAnalysisSet
 * @property {string} ByteAnalysisSet.name
 * @property {number[]} ByteAnalysisSet.values
 * @property {Set<number>} ByteAnalysisSet.uniqueValues
 * @property {number} ByteAnalysisSet.valueComplexity
 */

/**
* @typedef {object} ByteAnalysis
* @property {number} ByteAnalysis.byte
* @property {ByteAnalysisSet[]} ByteAnalysis.sets
* @property {Map<number, Set<string>>} ByteAnalysis.overlapValues
* @property {number} ByteAnalysis.minValueCount
* @property {number} ByteAnalysis.maxValueCount
* @property {number} ByteAnalysis.minValueComplexity
* @property {number} ByteAnalysis.maxValueComplexity
* @property {number} ByteAnalysis.bitDistance
*/

/**
* @typedef {object} QualifiedByteCount
* @property {string} QualifiedByteCount.name
* @property {Map<number,number>} QualifiedByteCount.byteCounts 
*/

/**
 * @param {number[]} values
 * @returns {number}
 */
function rateValueComplexity(values) {
    const sum = values.map(v => {
        if (v === 0x00 || v === 0x01 || v === 0xFE || v === 0xFF) {
            return 1
        } else {
            const distanceTowardEdge = Math.min(v, 0xFF - v)
            return distanceTowardEdge * distanceTowardEdge
        }
    }).reduce((acc, v) => acc + v, 0)

    return sum / values.length
}

/**
 * @param {QualifiedByteCount[]} countData
 * @param {number} byte
 * @returns {ByteAnalysis}
 */
function createByteAnalysis(countData, byte) {
    /** @type {Set<QualifiedByteCount>} */
    const loopedEntries = new Set()
    
    /** @type {Map<number, Set<string>>} */
    const overlapValues = new Map()

    /** @type {Map<string, ByteAnalysisSet>} */
    const analysisSets = new Map()

    /** @type {number?} */
    let maxValueCount = null
    /** @type {number?} */
    let minValueCount = null
    /** @type {number?} */
    let maxValueComplexity = null
    /** @type {number?} */
    let minValueComplexity = null


    for (const dataEntry1 of countData) {
        loopedEntries.add(dataEntry1)

        /** @type {number[]} */
        const values = Array.from(dataEntry1.byteCounts.keys())
        const valueComplexity = rateValueComplexity(values)

        analysisSets.set(dataEntry1.name, {
            name: dataEntry1.name,
            values: values,
            uniqueValues: new Set(values),
            valueComplexity: valueComplexity
        })

        if (maxValueCount === null || values.length > maxValueCount) {
            maxValueCount = values.length
        }
        if (minValueCount === null || values.length < minValueCount) {
            minValueCount = values.length
        }
        if (maxValueComplexity === null || valueComplexity > maxValueComplexity) {
            maxValueComplexity = valueComplexity
        }
        if (minValueComplexity === null || valueComplexity < minValueComplexity) {
            minValueComplexity = valueComplexity
        }


        for (const dataEntry2 of countData) {
            if (loopedEntries.has(dataEntry2)) {
                continue
            }

            for (const [value, count] of dataEntry1.byteCounts.entries()) {
                if (dataEntry2.byteCounts.has(value)) {
                    const overlapSet = overlapValues.get(value) ?? new Set()
                    overlapSet.add(dataEntry1.name)
                    overlapSet.add(dataEntry2.name)
                    overlapValues.set(value, overlapSet)
                }
            }
        }
    }

    for (const [value,entries] of overlapValues) {
        for (const entry of entries) {
            analysisSets.get(entry).uniqueValues.delete(value)
        }
    }

    const sets = Array.from(analysisSets.values())

    let bitDistance = computeBitDistance(sets)
    if (minValueCount == 1 && maxValueCount == 1 && bitDistance == 8) {
        bitDistance = 1
    }

    return {
        byte: byte,
        sets: sets,
        overlapValues: overlapValues,
        minValueCount: minValueCount ?? 0,
        maxValueCount: maxValueCount ?? 0,
        maxValueComplexity: maxValueComplexity ?? 0,
        minValueComplexity: minValueComplexity ?? 0,
        bitDistance: bitDistance
    }
}


/**
 * @param {ByteAnalysis[]} list
 * @returns {object}
 */
function simplifyAnalysis(list) {
    const output = {}
    for (const analysis of list) {
        if (analysis.overlapValues.size > 0) {
            continue
        }

        const analysisObj = {}
        for (const set of analysis.sets) {
            if (set.values.length == 1) {
                analysisObj[set.name] = set.values[0]
            } else {
                analysisObj[set.name] = set.values
            }
        }
        output[formatHex(analysis.byte)] = analysisObj
    }

    return output
}

function replacerJSON(key, value) {
    if (value instanceof Map) {
        const obj = {}
        for (const [k, v] of value.entries()) {
            if (typeof k === "number") {
                obj[formatHex(k)] = v
            } else {
                obj[k.toString()] = v
            }
        }
        return obj
    } else if (value instanceof Set) {
        return Array.from(value.keys())
    } else if (key.startsWith("min") || key.startsWith("max") || key == "valueComplexity" || key == "bitDistance" ) {
        return value
    } else if (typeof value === "number") {
        return formatHex(value)
    } else {
        return value
    }
}

function replaceYAML(key, value) {
    if (typeof value === "number"){
        return formatHex(value)
    } else {
        return value
    }
}

/**
 * @param {ByteAnalysisSet[]} sets
 * @returns {number}
 */
function computeBitDistance(sets) {
    const values = sets.flatMap((set) => set.values)

    const all = values.reduce((a, b) => a & b)
    const any = values.reduce((a, b) => a | b)
    const same = (all | (~ any)) & 0xFF
    const different = (~same) & 0xFF

    const differentCount = different.toString(2).replace("0", "").length
    return differentCount
}

/**
 * @param {ByteAnalysis} a
 * @param {ByteAnalysis} b
 * @returns {number}
 */
function orderAnalysis(a,b) {
    if (a.overlapValues.size !== b.overlapValues.size) {
        return a.overlapValues.size - b.overlapValues.size

    } else if (a.bitDistance !== b.bitDistance) {
        return a.bitDistance - b.bitDistance

    } else if (a.minValueComplexity !== b.minValueComplexity) {
        return a.minValueComplexity - b.minValueComplexity

    } else if (a.minValueCount !== b.minValueCount) {
        return a.minValueCount - b.minValueCount

    } else if (a.maxValueComplexity !== b.maxValueComplexity) {
        return a.maxValueComplexity - b.maxValueComplexity

    } else if (a.maxValueCount !== b.maxValueCount) {
        return a.maxValueCount - b.maxValueCount

    } else {
        return a.byte - b.byte
    }
}

function main() {
    /** @type {string | undefined} */
    const filePath = process.argv[2]

    if (filePath == undefined) {
        console.error("Error: No File provided")
        return
    }

    if (!fs.existsSync(filePath) || !fs.lstatSync(filePath).isFile()) {
        console.error("Error: File does not exist")
        return
    }

    const outFilePath = path.join(path.dirname(filePath), path.basename(filePath, ".json") + ".results.verbose.json")
    const shortOutFilePath = path.join(path.dirname(filePath), path.basename(filePath, ".json") + ".results.short.yml")
    const fileContent = fs.readFileSync(filePath, {encoding: "utf-8", flag: "r"})

    
    /** @type {SearchFile} */
    const searchData = JSON.parse(fileContent)

    /** @type {ByteCounts} */
    const byteCounts = new Map()

    for (const set of searchData.sets) {
        byteCounts.set(set.name, loadSearchSet(set))
    }

    const fileSize = byteCounts.get(searchData.sets[0].name)?.length ?? 0

    /** @type {OrderedSet<ByteAnalysis>} */
    const analysisOutput = new OrderedSet([], orderAnalysis)

    for (let i = 0; i < fileSize; i++) {
        /** @type {QualifiedByteCount[]} */
        const countData = []
        
        for (const set of searchData.sets) {
            countData.push({
                name: set.name,
                byteCounts: byteCounts.get(set.name)?.[i] ?? []
            })
        }
        
        const byteAnalysis = createByteAnalysis(countData, i)
        analysisOutput.insert(byteAnalysis)
    }

    const analysisOutputList = Array.from(analysisOutput)

    console.log("Successfully analysed Data")

    if (searchData.verbose) {
        const analysisOutputString = jsonStringify(analysisOutputList, {indent: 4, maxLength: 100, replacer: replacerJSON})
        fs.writeFileSync(outFilePath, analysisOutputString, {encoding: "utf-8", flag: "w"})
        console.log(`Verbose Log File Generated: ${outFilePath}`)
    }

    const shortAnalysisOutputString = YAML.stringify(simplifyAnalysis(analysisOutputList), replaceYAML, {
        indent: 4,
        defaultKeyType: "PLAIN",
        defaultStringType: "PLAIN",
        collectionStyle: "block"
    })

    fs.writeFileSync(shortOutFilePath, shortAnalysisOutputString, {encoding: "utf-8", flag: "w"})
    console.log(`Log File Generated: ${shortOutFilePath}`)    
}

main()
