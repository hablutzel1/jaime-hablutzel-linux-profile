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
  domains, user names other than `jhablutzel`, or which hosts or accounts share a credential. Write
  comments and TODOs with generic wording instead.
- Never mention any company except Blobfish, my own: no client, employer or partner names, in files,
  comments or commit messages.
- Keep host-specific or private configuration out of the repository and read it at run time from
  files outside it, as `configure-profile` already does with `~/.ssh/authorized_keys_host_specific`.
- Treat every change to `configure-profile`, `git_hooks/` and `authorized_keys_global` as security
  critical: it runs, or grants SSH access, on every host automatically.
- Before each commit, review the staged diff against the rules above. If something might break them,
  ask me before committing.
- This file is public too.

## Where a command goes

- A command that does not need to change the shell it is typed in goes as a function in `lib/*.bash`
  (bash 3.2 compatible), plus a symlink `bin/<name>` to `jhlp-run`. It then runs the same from bash,
  zsh, scripts, `sudo` and non-interactive SSH.
- A command that must change the current shell (`cd`, variables, history, aliases) goes in
  `jhlp_aliases`, in POSIX sh, or in `jhlp_bashrc` when it needs bash, e.g. `jh_super`.
- An alias that would need arguments in the middle (`$1`) is a function in `lib/*.bash` instead.
- Code that runs at shell startup, not on demand, goes in `jhlp_init`.

## Commit every change, push only after I confirm

Whenever you change any file in this repository, commit the change right away, in the same turn and
without asking. One commit per logical change.

Never push on your own. After committing, always ask me to confirm the push, with the agent's
structured question tool where it has one, and push to the branch's upstream (`origin`) only after
I confirm. A push reaches every host within minutes, so this applies to every push, however small.
