test commit
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

# TODOS #

* Evaluate to make this repository private (but does it really dangerously provide information about my environment?) while keeping it comfortable to use it from any place, even from third party infrastructure, maybe by generating quick read-only access keys for every server that it will be deployed to?. Another option for beginning would be just removing it from any public listing, if GitHub allows for this. Maybe it would be a good idea to publish it in a Blobfish's managed Git server, otherwise too much trust in being put in GitHub.
* Check if there is any way to safely share my current unique password using this, e.g. by salting and iterating a lot over it.
* Explore other alternatives to share these files (and keep them updated) across Linux servers, e.g. Ansible, Puppet, Chef, etc. If possible try to migrate to one of these standard tools. 
* Try to automate the installation (or at least clearly warn about the absence) of dependencies, e.g. 'screen', 'crontab', etc.
* Try to automate the installation of all the other tools that I use in a regular basis, e.g.
  * emacs-nox
* Evaluate to use this to increment/replicate the list of my known SSH hosts, e.g. Bitbucket or GitHub. Do not forget to explore SSHFP too. Maybe this script could install its own copy of .ssh/known_hosts and we could additionally provide a companion script to help update the bundled known_hosts from the known_hosts of the current system (ignoring duplicates). Anyway, look for a more standard solution for this as it has to be a very common productivity affecting problem. Evaluate possible integration with my Termius list of known hosts.
