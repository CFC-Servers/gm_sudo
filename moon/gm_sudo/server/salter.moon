import Read from file

class Salter
    new: =>
        @salt = @getSalt!

    getSalt: =>
        contents = Read "cfc/sudo_salt.txt", "DATA"
        gsub contents, "%s", ""

    season: (hash) =>
        "hash#{@salt}"
