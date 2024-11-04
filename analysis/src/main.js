import * as fs from 'node:fs';
import * as path from 'node:path';

/**
* @typedef {object} SearchFile
* @property {string[][]} SearchFile.set
* @property {boolean} SearchFile.verbose
*/

function main() {
    /** @type string | undefined */
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

    
    /** @type SearchFile */
    const searchData = JSON.parse(fileContent)

    
    console.log(searchData)


    fs.writeFileSync(outFilePath, JSON.stringify(searchData), {encoding: "utf-8", flag: "w"})
    console.log("Successfully analysed Data")
    console.log(`Log File Generated: ${outFilePath}`)

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
}

main()
