Start downloading repo with:

```
$ git clone https://github.com/hablutzel1/jaime-hablutzel-linux-profile.git ~/.jaime-hablutzel-linux-profile
```

Now, to configure the profile execute:

```
$ source ~/.jaime-hablutzel-linux-profile/configure-profile
```

# TODOS #

* Evaluate to make this repository private (because it might be dangerously providing information about my environment) while keeping it comfortable to use it from any place, even from third party infrastructure.
* Check if there is any way to safely share my current unique password using this, e.g. by salting and iterating a lot over it.
* Explore other alternatives to share these files (and keep them updated) across Linux servers, e.g. Puppet, Chef, etc. 
* Try to automate the installation (or at least clearly warn about the absence) of dependencies, e.g. 'screen', 'crontab', etc.
* Try to automate the installation of all the other tools that I use in a regular basis, e.g.
  * emacs-nox
* Make some options configurable in a Git ignored file (e.g. `options.conf`):
  * Use (or not) screen as it might be undesirable in certain environments, e.g. a regular desktop environment.
