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

It will require installing the 1Password CLI interface via:

```
brew install 1password-cli
```

A reminder that if you plan to use `.*` in your regular expression, you'll
want to wrap that argument in single-quotes to prevent filepath expansion of
the `*`.

So, for example:

```
$ ./find_password.pl --userregex 'userid@.*'
Amazon -- userid@mydomain.com -- hunter2
GMail -- userid@gmail.com -- 123456
eBay -- userid@mydomain.com -- drowssap
```

or, for the example I gave earlier:

```
$ ./find_password.pl --pwregex 'q8!.*'
FictionalSite -- userid@mydomain.com -- q8!*sadoiu%s2
```

