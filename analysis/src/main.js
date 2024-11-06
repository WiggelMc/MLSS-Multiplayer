import * as fs from 'node:fs';
import * as path from 'node:path';

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
* @typedef {Map<string, number[][]>} ByteCounts
*/

/**
 * 
 * @param {SearchSet} set
 * @returns {number[][]}
 */
function loadSearchSet(set) {
    const byteCounts = []

    for (const dirName of set.buckets) {
        const dirPath = path.join("/data/buckets/", dirName)

        for (const fileName of fs.readdirSync(dirPath)) {
            const filePath = path.resolve(dirPath, fileName)

            const buffer = fs.readFileSync(filePath, {flag: "r"})
            for (const [i, byte] of buffer.entries()) {
                
                const byteCount = byteCounts[i] ?? []
                byteCount[byte] = (byteCount[byte] ?? 0) + 1
    
                byteCounts[i] = byteCount
            }
        }
    }

    return byteCounts
}

/**
* @typedef {object} ByteAnalysis
*/

/**
* @typedef {object} QualifiedByteCount
* @property {string} QualifiedByteCount.name
* @property {number[]} QualifiedByteCount.byteCounts 
*/

/**
 * 
 * @param {QualifiedByteCount[]} countData
 * @returns {ByteAnalysis}
 */
function createByteAnalysis(countData) {
    for (const dataEntry of countData) {
        
    }
    //TODO
    return {}
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

    const outFilePath = path.join(path.dirname(filePath), path.basename(filePath, ".json") + ".results.log")
    const fileContent = fs.readFileSync(filePath, {encoding: "utf-8", flag: "r"})

    
    /** @type {SearchFile} */
    const searchData = JSON.parse(fileContent)

    /** @type {ByteCounts} */
    const byteCounts = new Map()

    for (const set of searchData.sets) {
        byteCounts.set(set.name, loadSearchSet(set))
    }

    const fileSize = byteCounts.get(searchData.sets[0].name)?.length ?? 0

    for (let i = 0; i < fileSize; i++) {
        /** @type {QualifiedByteCount[]} */
        const countData = []
        
        for (const set of searchData.sets) {
            countData.push({
                name: set.name,
                byteCounts: byteCounts.get(set.name)?.[i] ?? []
            })
        }
    
        const byteAnalysis = createByteAnalysis(countData)
        //TODO: push into sorted Set
    }

   
    console.log(searchData)

    



    fs.writeFileSync(outFilePath, JSON.stringify(searchData), {encoding: "utf-8", flag: "w"})
    console.log("Successfully analysed Data")
    console.log(`Log File Generated: ${outFilePath}`)
}

main()


    // Todo: Read files from Buckets
    // Compare Sets and document similarities between bits and bytes
    // Eg. Load X Bytes from all Files, and compare for each bit / byte
    // Comparison: Create Score
    // Different Groupings (bytes only) eg. 0 as values 0x12, 0x13 and 1 has 0x00
    // Each Result has Score values:
    //      minSpread (min number of different values in set)
    //      maxSpread (max number of different values in set) 
    //      outlierPercentage (values that dont fit into calculation, eg. common value from 0 appears once in 1) (above 0.05 not counted as Result)

    // Store everything in SortedMap
    // When done, output map entries into file

    // TODO: analysis functions
    //  find bytes / bits (that are identifying across all buckets) eg. each bucket has a single unique value
    //  ability to combine buckets for tests (eg. battle_mario, battle_luigi, battle_enemy vs levelup_mario, levelup_luigi)
    //  maybe trough tags (battle, mario, luigi, overworld, movement, ...)
    //  make sure that memory is taken, before buttons are pressed (eg. while you can still make inputs) (battle_mario_attack_before_press, battle_mario_attack_after_press)
    //  ability to detect near misses

    // maybe use many addresses for each detection and log unexpected deviations (they should all give the same result)
    // prepare tests for each flag
    //  mario v luigi overworld
    //  battle v overworld
    //  battle v powerup
    //  mario_battle v luigi_battle
    //  minigame v overworld
    //  minigame v battle
    //  pause v overworld
    //  textbox v overworld
    //  cutscene v overworld
    //  pause + textbox + cutscene v battle