require "securerandom"
bcrypt = require "bcrypt"

import Base64Encode from util
import Exists, Read, Write from file

class EncryptionInterface
    new: (logRounds=12, saltLength=64) =>
        @logRounds = logRounds
        @saltLength = saltLength

    salt: => Base64Encode random.Bytes, @saltLength

    digest: (password, salt=true) =>
        salt = salt and @salt! or ""

        bcrypt.digest(password, @logRounds) .. salt, salt

    verify: (password, digest, salt="") =>
        bcrypt.verify "#{password}#{salt}", digest

EncryptionInterface!
