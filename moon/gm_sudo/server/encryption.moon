import Base64Encode from util
import Exists, Read, Write from file
import Logger from Sudo

encryptionSetting = CreateConVar "gm_sudo_encryption_method", "sha512", FCVAR_PROTECTED

local encrypt
hook.Add "OnGamemodeLoaded", "GmodSudo_LoadEncryptionMethod", ->
    encrypt = include("includes/modules/sha2.lua")[encryptionSetting\GetString!]

class EncryptionInterface
    new: =>
        @random = include "lib/random.lua"

    digest: (password) =>
        Logger\debug "Generating digest"
        generatedSalt = Base64Encode @random.bytes 64

        encrypt("#{password}#{generatedSalt}"), generatedSalt

    verify: (password, digest, salt="") =>
        Logger\debug "Verifying digest: #{digest}"

        digest == encrypt("#{password}#{salt}")

EncryptionInterface!
