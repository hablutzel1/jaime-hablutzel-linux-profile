Start downloading repo with:

```
$ git clone https://github.com/hablutzel1/jaime-hablutzel-linux-profile.git ~/.jaime-hablutzel-linux-profile
```

Now, to apply aliases updates perform:

```
$ source ~/.jaime-hablutzel-linux-profile/update-profile
```
# Configure Git hook for next pulls #

Optionally, configure the following Git hook so `update-profile` is automatically executed for the next pull:

```
$ ~/.jaime-hablutzel-linux-profile/symlink-git-hooks
```

Anyway, after a Git pull it is required to log out and log in again.

# TODOS #

* Explore other alternatives to share these files (and keep them updated) across Linux servers, e.g. Puppet, Chef, etc. 
* Try to automate the installation (or at least clearly warn about the absence) of dependencies, e.g. 'screen', 'crontab', etc.
