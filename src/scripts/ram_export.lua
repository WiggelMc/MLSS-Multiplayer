local bytes = memory.read_bytes_as_array(0x0000, 0x7FFF, "IWRAM")

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

math.randomseed(os.time())
local file = io.open("ramdump" .. math.random(100000, 999999) .. ".bin", "wb")

if (file == nil) then
    error("ERROR")
end

for _, value in ipairs(bytes) do
    file:write(string.char(value))
end

file:flush()
file:close()
