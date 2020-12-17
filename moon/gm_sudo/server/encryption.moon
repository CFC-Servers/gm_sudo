require "securerandom"
sha = require "sha2"

import Base64Encode from util
import Exists, Read, Write from file
import Logger from Sudo

class EncryptionInterface
    new: (logRounds=12, saltLength=64) =>
        @saltLength = saltLength

    salt: => Base64Encode random.Bytes, @saltLength

    digest: (password) =>
        Logger\debug "Generating digest"
        generatedSalt = @salt!

        sha.sha3_512("#{password}#{generatedSalt}"), generatedSalt

    verify: (password, digest, salt="") =>
        Logger\debug "Verifying digest: #{digest}"

        digest == sha.sha3_512 "#{password}#{salt}"

EncryptionInterface!
