 -- On chat or console command, "!sudo, sudo"
    -- Check if user is already authenticated, pass if so
    -- Else send net message with temporary token.
    -- On client, open prompt to enter PIN, when submitted send along encrypted private key and temporary token
    -- Server receives steam id, PIN, encrypted private key, and temporary token
    -- Check that temporary token matches, reject if not
    -- Server looks up steam id in database, if doesn't exist then pass
    -- If steam id exists, test validity of ecnryped private key. (Length or size perhaps?)
    -- Check if decrypted private key matches database (using serverside key, never storing it in a variable)
        -- If private key matches, override player:IsSuperAdmin to return true and include a timeout in the function. Set serverside flag on player.
            -- Log all usage of sudo during time limit
            -- Prevent sudo user from connecting to EGP, Keyboard, etc. or giving permissions to starfall (and revoke all existing)
        -- If private key does not match, log the violation and start rate limiting (leading to a ban) from a player if they try too often
    -- update: just using passwords, stored with bcrypt, stored in sv.db

export Sudo
Sudo = {}
