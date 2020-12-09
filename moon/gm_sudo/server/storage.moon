import TableExists, Query from sql
import format from string

class UserStorage
    new: =>
        @tableName = "gm_sudo_users"

        hook.Add "PostGamemodeLoaded", "GmodSudo_DBInit", ->
            @initTable!

    initTable: =>
        Query format [[
            CREATE TABLE IF NOT EXISTS %s(
                steam_id TEXT    PRIMARY KEY NOT NULL,
                digest   TEXT    NOT NULL,
                active   BOOLEAN DEFAULT 1
            )
        ]], @tableName

    store: (steamId, digest) =>
        Query format [[
            INSERT OR REPLACE INTO %s (steam_id, digest) VALUES(%s, %s)
        ]], @tableName, steamId, digest

    delete: (steamId) =>
        Query format [[
            DELETE FROM %s
            WHERE steam_id = %s
        ]], @tableName, steamId

    getDigest: (steamId) =>
        Query format [[
            SELECT digest
            FROM %s
            WHERE steam_id = %s
        ]], @tableName, steamId

UserStorage
