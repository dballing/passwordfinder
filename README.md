# passwordfinder

Frequently whatever service you use for identity protection will give you
some meaningless info like:

"Your password (q8!....) was found in a batch on the darkweb. You should
change it now!"

Of course, if you're using a password manager like 1Password, all your
passwords are different. So which password was actually compromised?!

This script will accept a regular expression to search for a matching password
and/or a regular expression for a matching userID, and search your 1Password
vault for matching passwords, and report them to you.

## Security Warning

This script has direct read access to your 1Password vault. Passwords are
never displayed — only the title and username of matching entries are printed,
so you know which entry to open and change. A few things to keep in mind:

- **Use a specific pattern.** A regex of `.` or `.*` will match every password
  and effectively enumerate every entry in your vault. The script requires you
  to provide at least one regex, but it cannot tell the difference between a
  meaningful pattern and a trivially permissive one. Use the most specific
  pattern you can.
- **Mind your terminal history.** Matched entries (title and username) are
  printed to stdout. Passwords are never displayed, but usernames may still be
  sensitive depending on your setup.
- **Run only in a trusted environment.** Do not run this script over SSH in a
  shared environment or anywhere the terminal output could be observed.

## Prerequisites

Install the 1Password CLI:

```
brew install 1password-cli
```

Then sign in before running the script:

```
op signin
```

You only need to sign in once per session (or you can enable biometric unlock
in the 1Password desktop app so `op` authenticates automatically).

## Usage

```
./find_password.pl [--pwregex <regex>] [--userregex <regex>] [--vault <name>]
```

At least one of `--pwregex` or `--userregex` must be provided.

- `--pwregex` matches against passwords and is **case-sensitive**.
- `--userregex` matches against usernames and is **case-insensitive**.
- `--vault` limits the search to a specific named vault. Without it, all vaults are searched.

A reminder that if you plan to use `.*` in your regular expression, you'll
want to wrap that argument in single-quotes to prevent filepath expansion of
the `*`.

## Examples

Match by username domain:

```
$ ./find_password.pl --userregex 'userid@.*'
Phase 1: Listing vault items... found 42 items.
Phase 2: Fetching and checking passwords (42/42) -- 3 matches found
Amazon -- userid@mydomain.com
GMail -- userid@gmail.com
eBay -- userid@mydomain.com
```

Match by the partial password hint from the breach notification:

```
$ ./find_password.pl --pwregex 'q8!.*'
Phase 1: Listing vault items... found 42 items.
Phase 2: Fetching and checking passwords (42/42) -- 1 match found
FictionalSite -- userid@mydomain.com
```

Combine both to narrow results:

```
$ ./find_password.pl --pwregex 'q8!.*' --userregex 'work@'
```

Limit search to a specific vault:

```
$ ./find_password.pl --pwregex 'q8!.*' --vault 'Personal'
```
