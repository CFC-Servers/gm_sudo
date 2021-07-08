import Base64Encode from util
import Exists, Read, Write from file
import Logger from Sudo

class EncryptionInterface
    new: =>
        @sha = include "includes/modules/sha2.lua"
        @random = include "lib/random.lua"

    digest: (password) =>
        Logger\debug "Generating digest"
        generatedSalt = Base64Encode @random.bytes 64

        @sha.sha3_512("#{password}#{generatedSalt}"), generatedSalt

    verify: (password, digest, salt="") =>
        Logger\debug "Verifying digest: #{digest}"

        digest == @sha.sha3_512 "#{password}#{salt}"

EncryptionInterface!
