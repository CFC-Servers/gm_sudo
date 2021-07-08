import TableExists, Query, QueryRow, SQLStr from sql
import format from string
import Logger from Sudo

class UserStorage
    new: =>
        @tableName = SQLStr "gm_sudo_users"

        hook.Add "PostGamemodeLoaded", "GmodSudo_DBInit", ->
            @initTable!

    initTable: =>
        Logger\debug "Running DB setup..."

        Query format [[
            CREATE TABLE IF NOT EXISTS %s(
                steam_id TEXT    PRIMARY KEY NOT NULL,
                digest   TEXT    NOT NULL,
                salt     TEXT
                active   BOOLEAN DEFAULT 1
            )
        ]], @tableName

    store: (steamId, digest, salt) =>
        Logger\debug "Storing: #{steamId} | #{digest} | #{salt}"

        result = Query format [[
            INSERT OR REPLACE INTO %s (steam_id, digest, salt) VALUES(%s, %s, %s)
        ]], @tableName, SQLStr(steamId), SQLStr(digest), SQLStr(salt)

        error sql.LastError! if result == false else result

    delete: (steamId) =>
        Logger\debug "Deleting: #{steamId}"

        result = Query format [[
            DELETE FROM %s
            WHERE steam_id = %s
        ]], @tableName, SQLStr(steamId)

        error sql.LastError! if result == false else result

    get: (steamId) =>
        Logger\debug "Getting: #{steamId}"

        result = QueryRow format [[
            SELECT digest, salt
            FROM %s
            WHERE steam_id = %s
        ]], @tableName, SQLStr(steamId)

        error sql.LastError! if result == false else result

UserStorage!
