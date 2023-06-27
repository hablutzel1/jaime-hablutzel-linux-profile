# Installation #

Start downloading repo with:

```
git clone https://github.com/hablutzel1/jaime-hablutzel-linux-profile.git ~/.jaime-hablutzel-linux-profile
```

Now, to configure the profile execute:

```
source ~/.jaime-hablutzel-linux-profile/configure-profile
```

# Options #

The following options could be set in the beginning of `~/.bash_profile`:

- `JHLP_NO_MULTIPLEXER=1` to not load screen automatically as it might be undesirable in certain environments, e.g. a regular desktop environment.

# TODOS #

* Evaluate to make this repository private (but does it really dangerously provide information about my environment?) while keeping it comfortable to use it from any place, even from third party infrastructure, maybe by generating quick read-only access keys for every server that it will be deployed to?. Another option for beginning would be just removing it from any public listing, if GitHub allows for this. Maybe it would be a good idea to publish it in a Blobfish's managed Git server, otherwise too much trust in being put in GitHub.
* Check if there is any way to safely share my current unique password using this, e.g. by salting and iterating a lot over it. Otherwise I could adopt the practice of using a different random password (to be used for `sudo`) for each different machine and I could have something to warn me if the password haven't been ever changed (since originally provisioned) or if it haven't been changed for a given period of time. This would make my usage of `sudo` hard enough to force me to use it sparingly.
* Explore other alternatives to share these files (and keep them updated) across Linux servers, e.g. Ansible (maybe with a user local installation), Puppet, Chef, etc. If possible try to migrate to one of these standard tools as they could make it easier to update configuration. Evaluate to use something different than Ansible as this one is already being used for https://bitbucket.org/blobfisheirl/blobfish-ansible-automation/. But consider that requiring Ansible to be installed in each of the nodes could increment too much the dependencies required to run this project, so maybe the best bet is to just keep it as simple as possible, e.g. even preferring to use sh instead of bash.
* Evaluate to use this to increment/replicate the list of my known SSH hosts, e.g. Bitbucket or GitHub. Do not forget to explore SSHFP too. Maybe this script could install its own copy of .ssh/known_hosts and we could additionally provide a companion script to help update the bundled known_hosts from the known_hosts of the current system (ignoring duplicates). Anyway, look for a more standard solution for this as it has to be a very common productivity affecting problem. Evaluate possible integration with my Termius list of known hosts.
* Evaluate to sign (with a key being held in hardware) every commit made to this repository and configure the automated `git pull` in each server to only accept incoming commits if they are signed with a previously authorized key.
* Add the origin_ssh remote automatically as I need it from time to time.
* Support the configuration required to send emails directly from the terminal, e.g. with mailx.
* Evaluate to put my home folder under version control with etckeeper, with everything but Bash related configuration files excluded by default (see https://serverfault.com/questions/411494/etckeeper-on-custom-directory/411512#comment812342_411512).
* Explore if GitHub imposes a quota on the number of fetches on a repository (from the same or different locations) because it was observed in `ocsp-1.llamainternal.com` that there were apparently a lot of cron/git/git-remote-http processes opened/frozen at a given time and that triggered the OOM killer.
* Configure my .forward defaulting to my personal email, but allowing it to be overridden, maybe with a variable like JHLP_NO_MULTIPLEXER.
* Apparently this type of personal configuration projects are called Dotfiles (https://github.com/ajmalsiddiqui/dotfiles and https://www.freecodecamp.org/news/dive-into-dotfiles-part-1-e4eb1003cff6/). TODO research more on this practice and into the standard tooling that they use.
* Confirm if we are following the guidelines of the TLCL book, "Modifying the Environment", "Which Files Should We Modify?".
* Try to automatically configure Codex CLI (https://github.com/microsoft/Codex-CLI) in all the hosts where this profile gets configured. Maybe the sensitive credentials could be expected to be provided in the first log in.
* Check if it would be possible to merge all Bash history files in some chosen hosts (e.g. the trusted workstations). Maybe by retrieving the Bash history on SSH connection/disconnection and merge it to the client's Bash history.

