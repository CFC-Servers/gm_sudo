import Base64Encode from util
import Exists, Read, Write from file
import Logger from Sudo

encryptionSetting = CreateConVar "gm_sudo_encryption_method", "sha512", FCVAR_PROTECTED

print "Using: #{encryptionSetting\GetString!}"

local encrypt
hook.Add "InitPostEntity", "GmodSudo_LoadEncryptionMethod", ->
    print "Using: #{encryptionSetting\GetString!}"
    encrypt = include("includes/modules/sha2.lua")[encryptionSetting\GetString!]

class EncryptionInterface
    new: =>
        @random = include "lib/random.lua"
        print "(new) Using: #{encryptionSetting\GetString!}"

    digest: (password) =>
        Logger\debug "Generating digest"
        generatedSalt = Base64Encode @random.bytes 64

        print "(digest) Using: #{encryptionSetting\GetString!}"
        encrypt("#{password}#{generatedSalt}"), generatedSalt

    verify: (password, digest, salt="") =>
        Logger\debug "Verifying digest: #{digest}"

        print "(verify) Using: #{encryptionSetting\GetString!}"
        digest == encrypt("#{password}#{salt}")

EncryptionInterface!
