# gmod_su

**General idea:**
 - Instead of having a superadmin rank, all administrators just have an "Admin" rank
 - Qualified users will get a Sudo login
 - Once successfully entering Sudo mode, they can perform the given action as a superadmin, and can use more sudo commands without authenticating for some period of time.
 - Once sudo expires, the user will have to re-authenticate
