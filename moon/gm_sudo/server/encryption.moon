import Base64Encode from util
import Exists, Read, Write from file
import Logger from Sudo

encryptionSetting = CreateConVar("gm_sudo_encryption_method", "sha512", FCVAR_PROTECTED)
sha = include "includes/modules/sha2.lua"

class EncryptionInterface
    new: =>
        @random = include "lib/random.lua"
        @encrypt = sha[encryptionSetting\GetString!]

    digest: (password) =>
        generatedSalt = Base64Encode @random.bytes 64
        @encrypt("#{password}#{generatedSalt}"), generatedSalt

    verify: (password, digest, salt="") =>
        digest == @encrypt "#{password}#{salt}"

EncryptionInterface!
