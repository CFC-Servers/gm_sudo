import Base64Encode from util
import Exists, Read, Write from file
import Logger from Sudo

encryptionSetting = CreateConVar "gm_sudo_encryption_method", "sha512", FCVAR_PROTECTED + FCVAR_ARCHIVE

class EncryptionInterface
    new: =>
        @random = include "lib/random.lua"
        @sha = include "includes/modules/sha2.lua"

    encrypt: (data) =>
        print "(encrypt) Using: #{encryptionSetting\GetString!}"
        @sha[encryptionSetting\GetString!] data

    digest: (password) =>
        Logger\debug "Generating digest"
        generatedSalt = Base64Encode @random.bytes 64

        @encrypt("#{password}#{generatedSalt}"), generatedSalt

    verify: (password, digest, salt="") =>
        Logger\debug "Verifying digest: #{digest}"

        print "(verify) Using: #{encryptionSetting\GetString!}"
        digest == @encrypt("#{password}#{salt}")

EncryptionInterface!
