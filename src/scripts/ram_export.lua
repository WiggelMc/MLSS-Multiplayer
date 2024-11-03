
-- TODO: use loop
--  ensure that memory is read in a single frame
-- TODO: easy trigger mechanism (with named buckets)
--  a input key for each bucket
-- TODO: analysis functions
--  find bytes / bits (that are identifying across all buckets) eg. each bucket has a single unique value

-- maybe use many addresses for each detection and log unexpected deviations (they should all give the same result)
-- prepare tests for each flag
--  mario v luigi overworld
--  battle v overworld
--  battle v powerup
--  mario_battle v luigi_battle
--  minigame v overworld
--  minigame v battle
--  pause v overworld
--  textbox v overworld
--  cutscene v overworld
--  pause + textbox + cutscene v battle

local frames_i = 0
local iterations_i = 0

local frames = 60
local iterations = 5

math.randomseed(os.time())
local id = math.random(100000, 999999)

while (iterations_i < iterations) do
    frames_i = frames_i + 1

    if (frames_i >= frames) then
        frames_i = 0
        iterations_i = iterations_i + 1

        local bytes = memory.read_bytes_as_array(0x0000, 0x7FFF, "IWRAM")
        local file = io.open("ramdump_" .. id .. "_" .. iterations_i .. ".bin", "wb")

        if (file == nil) then
            error("File could not be created")
        end

        file:write(string.char(table.unpack(bytes)))

        file:flush()
        file:close()
        print("Written File " .. iterations_i)
    end

    emu.frameadvance()
end
