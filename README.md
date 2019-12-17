Start downloading repo with:

```
$ git clone https://github.com/hablutzel1/jaime-hablutzel-linux-profile.git ~/.jaime-hablutzel-linux-profile
```

Then configure the following Git hook so `update-profile` is automatically executed for the next pull:

```
$ ~/.jaime-hablutzel-linux-profile/symlink-git-hooks
```

Now, only for this first pull it is required to source update-profile explicitely with something like this:

```
$ source ~/.jaime-hablutzel-linux-profile/update-profile
```

# TODOS #

* Check if there is any smarter way to share these files across Linux servers, e.g. Puppet, Chef, etc.
