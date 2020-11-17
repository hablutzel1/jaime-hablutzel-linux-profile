# Installation #

Start downloading repo with:

```
$ git clone https://github.com/hablutzel1/jaime-hablutzel-linux-profile.git ~/.jaime-hablutzel-linux-profile
```

Now, to configure the profile execute:

```
$ source ~/.jaime-hablutzel-linux-profile/configure-profile
```

# Options #

The following options could be set in the beginning of `~/.bash_profile`:

- `JHLP_NO_AUTOLOAD_SCREEN=1` to not load screen automatically as it might be undesirable in certain environments, e.g. a regular desktop environment.
- `JHLP_DISABLE_BASH_IDLE_SESSION_TIMEOUT` to disable Bash idle sessions to get automatically closed after $BASH_IDLE_SESSION_TIMEOUT. This might be required when using a local Cygwin or WSL or when screen is not being used.

# TODOS #

* Evaluate to make this repository private (but does it really dangerously provide information about my environment?) while keeping it comfortable to use it from any place, even from third party infrastructure, maybe by generating quick read-only access keys for every server that it will be deployed to?. Another option for beginning would be just removing it from any public listing, if GitHub allows for this. Maybe it would be a good idea to publish it in a Blobfish's managed Git server, otherwise too much trust in being put in GitHub.
* Check if there is any way to safely share my current unique password using this, e.g. by salting and iterating a lot over it.
* Explore other alternatives to share these files (and keep them updated) across Linux servers, e.g. Ansible (maybe with an user local installation), Puppet, Chef, etc. If possible try to migrate to one of these standard tools as they could make it easier to update configuration. Evaluate to use something different than Ansible as this one is already being used for https://bitbucket.org/blobfisheirl/blobfish-ansible-automation/. But consider that requiring Ansible to be installed in each of the nodes could increment too much the dependencies required to run this project, so maybe the best bet is to just keep it as simple as possible, e.g. even preferring to use sh instead of bash.
* Try to automate the installation (or at least clearly warn about the absence) of dependencies, e.g. 'screen', 'crontab', etc.
* Try to automate the installation of all the other tools that I use in a regular basis, e.g.
  * emacs-nox
* Evaluate to use this to increment/replicate the list of my known SSH hosts, e.g. Bitbucket or GitHub. Do not forget to explore SSHFP too. Maybe this script could install its own copy of .ssh/known_hosts and we could additionally provide a companion script to help update the bundled known_hosts from the known_hosts of the current system (ignoring duplicates). Anyway, look for a more standard solution for this as it has to be a very common productivity affecting problem. Evaluate possible integration with my Termius list of known hosts.
* Evaluate to provide a full template for .bash* files and just let .old backups for the originals, see https://github.com/AlbanAndrieu/ansible-shell/blob/master/templates/.bashrc.j2.
* Evaluate to sign (with a key being held in hardware) every commit made to this repository and configure the automated `git pull` in each server to only accept incoming commits if they are signed with a previously authorized key.
* Add the origin_ssh remote automatically as I need it from time to time.
* Support the configuration required to send emails directly from the terminal, e.g. with mailx.
* Look for the way to root sessions to be prompted in a different color to reflect warning, e.g. all of the following could be painted in red: "root@server01:/etc#".
* Evaluate to put my home folder under version control with etckeeper, with everything but Bash related configuration files excluded by default (see https://serverfault.com/questions/411494/etckeeper-on-custom-directory/411512#comment812342_411512).
* Explore if GitHub imposes a quota on the number of fetches on a repository (from the same or different locations) because it was observed in `ocsp-1.llamainternal.com` that there were apparently a lot of cron/git/git-remote-http processes opened/frozen at a given time and that triggered the OOM killer.
* Ensure that Bash is configured to not save into the history the lines prefixed with an space.

