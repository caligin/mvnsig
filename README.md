# mvnsig

Scan your Maven repo for tampered jars!

# Usage

`./mvnsig.sh`

Will scan `~/.m2/repository/`

# Requirements

- `gpg2`
- `curl`

# Output format

`OK|FAIL GOOD|TRUSTED|NOSIG|NOKEY|BAD|ERROR <jarfile> <keyid>|NOKEY <message>`

# TODO

- Handle trusted/untrusted sigs
- Lookup in local keystore before searching on keyserver
- Tests!
