Steem Pressure
---

### Keeping your STEEM locked safely inside

Steem Pressure is a simple application which lets you store your Steem private keys outside of the browser. This keeps them safe against most web-based attacks such as the XSS attack which recently affected Steemit.com. If a Steemian affected by the XSS attack had used Steem Pressure to keep his owner and active keys outside the browser, the most the attacker could have gained was his posting key allowing the attacker to vote and make posts on the victim's account, but not steal the account itself or the funds within it.

Please note that at this point, Steem Pressure is considered a beta, and while I believe the keys it stores are safe from theft (unless the password which encrypts them is compromised), it is possible that a bug in the software may cause it to forget keys. I recommend having safe backups of keys (or their recovery phrases) stored in Steem Pressure.

I would like to provide binaries for Windows and Mac; however, I am unable to build Steem on Windows and thus cannot build Steem Pressure. Others have succeeded in building Steem on Windows, so I would appreciate it if someone could give me some pointers on how to do it. Mac binaries are available in the Releases section.

## Build Instructions
Steem Pressure is designed to be light on dependencies, and thus the only externally required dependencies are Qt 5.7+ (with qbs) and Steem. As Steem is linked statically, it is a build-time dependency only. Steem Pressure uses qbs as its build system, and as such, does not require a configure step. Ensure the `STEEM_PATH` environment variable is set to the path Steem is installed to, then simply run `qbs` to build.

**Notes**
- Some Linux distributions, such as Ubuntu, do not ship recent versions of Qt, thus it will be necessary to download an up-to-date copy from https://qt.io.
- Steemit's repo for Steem has broken installation. This is fixed in [my fork](https://github.com/nathanhourt/steem), so for now it will be easiest to build/install Steem from my fork
