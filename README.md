# GMod Sudo

# Intro

**FYI: This addon currently only works on Linux. The SHA implementation used in `gm_sudo` doesn't work on Windows for some reason. This is a problem we intend to fix ASAP**

<details><summary><strong>Background</strong></summary>
<p>
In Linux, a superuser is a user who can run any command at the highest permission level, never limited by permissions (just like the `root` user).

A regular system user can be granted `sudo` access, allowing them to run commands as a superuser.

However, first, they must enter their password.

After they enter their password, they're granted elevated permissions for a limited amount of time.
 During this timeframe, they can run any command with elevated privileges.

Once the session expires, they must re-authenticate before running any more privileged commands.

`gm_sudo` operates under the same principles. Any authorized player can authenticate (via password) and enter `sudo` mode for a limited amount of time.
</p>
</details>

**General Idea:**
 - Instead of having a superadmin rank, all administrators just have an "Admin" rank (`:IsAdmin()`, but not `:IsSuperAdmin()`)
 - Qualified users may receive a Sudo login
 - Once a player successfully enters Sudo mode, they can perform any action as a superadmin for some period of time
 - Once Sudo expires, the user will have the same permissions as they did pre-sudo mode


<details><summary><strong>✅ Benefits</strong></summary>
<p>
This makes your server more secure.

Instead of always having superadmin access, staff _must_ authenticate before using privileged tools (running serverside code, configuring addons, etc.)
This way, if a staff member is compromised, your server remains safe.

At minimum, your server's attack surface decreases significantly.
</p>
</details>

<details><summary><strong>❌ Drawbacks</strong></summary>
<p>
Always, with every tool we use, we must find a balance between Security and Convenience.

Making your applications more secure means making them less convenient to use legitimately.

Two factor authentication makes your accounts significantly harder to hack, but it makes it inconvenient to log in every time.

In the same vein, using `gm_sudo` is inconvenient.

Instead of simply tweaking an addon setting or running a quick script, the staff must authenticate with `gm_sudo`.

It only requires them to enter a password but, still, it's a barrier to doing their job.
</p>
</details>


`gm_sudo` is recommended for everyone, but especially so for larger servers.
If you're a smaller server, `gm_sudo` can help keep you safer, but may not be as valuable.


# Security features
 - Nothing in the global scope
 - Each step of the transaction protected by tokens
 - Limited time to enter password
 - Full SHA-2/SHA-3 implementation, configurable encryption algorithm
 - Passwords are salted
 - Passwords never stored plainly in a variable

# Use
_(FIXME: Include installation instructions for moonscript addon)_

Anyone with rcon (or direct terminal) access to the server can use the `sudoadd <steamid>` command:
```
sudoadd "STEAM_1:0:21170873"
```

The targeted user will be prompted to enter a password. Once they hit `enter`, the server will receive, encrypt, salt, and store the password.

Now that the user has a `gm_sudo` account, they can run the `sudo` command locally, where they're prompted to enter their password. Once they submit the correct password, they'll be allowed to perform any action requiring `superadmin` access.

And that's it!

---

If a user forgets their password, you can simply run `sudoadd` again, and the password they enter will overwrite their previous password.

If you need to remove a user, you can run `sudoremove "steamid"` (works the same way as `sudoadd`, but in reverse) to remove their `gm_sudo` account.
