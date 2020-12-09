require "securerandom"
bcrypt = require "bcrypt"

import Base64Encode from util
import Exists, Read, Write from file

class EncryptionInterface
    new: =>
        @logRounds = 12
        @salt = @fillShaker!

    fillShaker: =>
        saltFile = "gm_sudo_salt.txt"

        if not Exists saltFile
            with Base64Encode random.Bytes, 64
                Write saltfile, self

        with Read saltFile
            Replace self, "\r", ""
            Replace self, "\n", ""

    digest: (password) =>
        bcrypt.digest(password, @logRounds) .. @salt

    verify: (password, digest) =>
        bcrypt.verify "#{password}#{@salt}", digest

EncryptionInterface!
