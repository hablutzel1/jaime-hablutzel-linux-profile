# jaime-hablutzel-linux-profile

My shell profile and dotfiles, applied by `configure-profile` on my workstations and servers.

## This repository is public

https://github.com/hablutzel1/jaime-hablutzel-linux-profile is public. Every host that uses it pulls it
every five minutes from cron, and `git_hooks/post-merge` then runs `configure-profile`. So anything
committed here is readable by anyone, stays in the Git history after it is deleted, and reaches every
host within minutes.

- Never commit secrets: passwords, default or shared passwords, API keys, tokens, private keys, or
  anything derived from them.
- Never commit details that help map my infrastructure: internal host names, IP addresses, internal
  domains, user names other than `jhablutzel`, client or employer names, or which hosts or accounts
  share a credential. Write comments and TODOs with generic wording instead.
- Keep host-specific or private configuration out of the repository and read it at run time from
  files outside it, as `configure-profile` already does with `~/.ssh/authorized_keys_host_specific`.
- Treat every change to `configure-profile`, `git_hooks/` and `authorized_keys_global` as security
  critical: it runs, or grants SSH access, on every host automatically.
- Before each commit, review the staged diff against the rules above. If something might break them,
  ask me before committing.
- This file is public too.

## Commit and push every change

Whenever you change any file in this repository, commit the change and push it right away to the
branch's upstream (`origin`), in the same turn and without asking. One commit per logical change.
