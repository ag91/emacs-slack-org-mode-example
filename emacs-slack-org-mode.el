(use-package slack
  :defer 4
  :init (make-directory "/tmp/emacs-slack-images/" t)
  :bind (:map slack-mode-map
              (("@" . slack-message-embed-mention)
               ("#" . slack-message-embed-channel)))
  :custom
  (slack-buffer-emojify t)
  (slack-prefer-current-team t)
  (slack-image-file-directory "/tmp/emacs-slack-images/")
  (slack-buffer-create-on-notify t) ; this is to get more alerts? https://github.com/yuya373/emacs-slack/issues/512
  :config
  (when (f-dir-p "someFileOrDirectoryExistingOnlyOnWorkEnvironment")
    (slack-register-team
     :name "someTeam"
     :token (password-store-get "someTeamPass")
     :full-and-display-names t)
    (slack-start)
    (add-to-list 'org-agenda-files "~/yourOrgAgendaFilesFolder/Slack.org")))

(use-package alert
  :after slack
  :init
  (alert-define-style
   'my/alert-style :title
   "Make Org headings for messages I receive - Style"
   :notifier
   (lambda (info)
     (write-region
      (s-concat
       "* TODO "
       (plist-get info :title)
       " : "
       (format
        "%s %s :slack:"
        (plist-get info :title)
        (plist-get info :message))
       "\n"
       (format "\n <%s>" (format-time-string "%Y-%m-%d %H:%M"))
       "\n")
      nil
      "~/yourOrgAgendaFilesFolder/Slack.org"
      t)))
  (setq alert-default-style 'message)
  (add-to-list 'alert-user-configuration
               '(((:category . "slack")) my/alert-style nil)))
