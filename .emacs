; TODO check: Saving Emacs backups could be a security risk because of the possibility that it could inadvertently leave sensitive information (e.g. passwords) lying around, even when this information is under the user home folder. Evaluate not to save backups at all.
; TODO check what other files Emacs saves next to the original file, e.g. files starting with #.
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))
