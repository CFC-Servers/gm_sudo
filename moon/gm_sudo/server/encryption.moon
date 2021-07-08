import Base64Encode from util
import Exists, Read, Write from file
import Logger from Sudo

encryptionSetting = CreateConVar "gm_sudo_encryption_method", "sha512", FCVAR_PROTECTED

class EncryptionInterface
    new: =>
        @random = include "lib/random.lua"
        @sha = include "includes/modules/sha2.lua"

    encrypt: =>
        return @_encrypt if @_encrypt
        print "(encrypt) Using: #{encryptionSetting\GetString!}"
        @_encrypt = include("includes/modules/sha2.lua")[encryptionSetting\GetString!]
        @_encrypt

    digest: (password) =>
        Logger\debug "Generating digest"
        generatedSalt = Base64Encode @random.bytes 64

        @encrypt("#{password}#{generatedSalt}"), generatedSalt

    verify: (password, digest, salt="") =>
        Logger\debug "Verifying digest: #{digest}"

        print "(verify) Using: #{encryptionSetting\GetString!}"
        digest == @encrypt("#{password}#{salt}")

EncryptionInterface!
