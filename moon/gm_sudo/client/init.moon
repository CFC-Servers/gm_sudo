-- When receiving a sudo prompt,
    -- Prompt user for PIN. Just four numbers, easy unobtrusive input panel
    -- On submission, read encrypted private key from database
    -- Respond with net message to server, include PIN, encrypted private key, and given token

include "prompt.lua"
include "sudo.lua"
