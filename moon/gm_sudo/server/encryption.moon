bcrypt = require "bcrypt"

export EncryptionInterface
class EncryptionInterface
    new: =>
        @logRounds = 12

    digest: (password) =>
        bcrypt.digest password, @logRounds

    verify: (password, digest) =>
        bcrypt.verify password, digest
