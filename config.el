;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Daniel Krajnik"
      user-mail-address "<REDACTED>")

(setq doom-theme 'doom-city-lights)

(setq doom-font (font-spec :family "JetBrains Mono" :size 12)
      doom-variable-pitch-font (font-spec :family "JetBrains Mono" :height 1.3)
      doom-unicode-font (font-spec :family "JetBrains Mono")
      doom-big-font (font-spec :family "JetBrains Mono" :size 22))

;; change theme background
;; https://www.reddit.com/r/DoomEmacs/comments/ig6ubw/how_to_properly_change_backgroundcolor_other_than/
;; enlarge org mode title font size - if it doesn't work run doom-docs-mode instead
;; https://www.reddit.com/r/DoomEmacs/comments/13wkam9/how_to_toggle_size_of_headers_font_in_org_mode/?sort=new
;; https://stackoverflow.com/questions/21525436/orgmode-title-levels-height/76374044
(custom-theme-set-faces! 'doom-city-lights
  '(default :background "#10151a")
  '(default :foreground "#ffffff")
  '(org-level-1 :inherit outline-1 :height 1.2)
  '(org-level-2 :inherit outline-2 :height 1.0)
  '(org-level-3 :inherit outline-3 :height 1.0)
  )

;; For relative line numbers, set to `relative'.
(setq display-line-numbers-type nil)

;; personal preference
(centered-window-mode)

;; search across buffers - I don't use it that often, but maybe one day...
(defun my-multi-occur-in-matching-buffers (regexp &optional allbufs)
  "https://stackoverflow.com/questions/2641211/emacs-interactively-search-open-buffers"
  (interactive (occur-read-primary-args))
  (multi-occur-in-matching-buffers "." regexp allbufs))

(defun my-multi-occur-in-all-matching-buffers (regexp &optional allbufs)
  "search only notmuch messages"
  (interactive (occur-read-primary-args))
  (multi-occur-in-matching-buffers "." regexp (not allbufs)))

(defun my-multi-occur-in-notmuch-message-matching-buffers (regexp &optional allbufs)
  "search only in notmuch messages"
  (interactive (occur-read-primary-args))
  (multi-occur-in-matching-buffers "notmuch" regexp (not allbufs)))

(map! :leader "s q" 'my-multi-occur-in-matching-buffers)
(map! :leader "s Q" 'my-multi-occur-in-all-matching-buffers)

;; add TAB to jump to occurances
(map! :map occur-mode-map "<tab>" 'occur-mode-display-occurrence)

;; email
(defun notmuch-tree-show-all-messages ()
  "open all notmuch emails and run multi-occur
   https://emacs.stackexchange.com/questions/77535/open-all-emails-in-notmuch-tree-search-buffer"
  (interactive)
  (goto-char (point-min))
  (while (and (not (eobp)) (not (get-buffer (notmuch-tree-get-message-id))))
    (notmuch-tree-show-message-out)
    (previous-buffer)
    (forward-line 1)))

;; use zathura or whatever is default when clicking on attachment
;; modified also in ~/.mailcap
(setq notmuch-show-part-button-default-action 'notmuch-show-view-part)

;; preview messages with TAB key (ENTER by default)
(map! :map notmuch-search-mode-map "<tab>" 'notmuch-search-show-thread)

;; preview messages with TAB key (ENTER by default)
(map! :map notmuch-tree-mode-map "<tab>" 'notmuch-tree-show-message)
(map! :map notmuch-tree-mode-map "<tab>" 'notmuch-tree-show-message-in)

;; "push button" with TAB - helps in some windows
(map! :map button-map "<tab>" 'push-button)

;; debugging
;;
;; disabled it after all - cursor needed to be in backtrace to show local variables
;; (defun edebug-pop-to-backtrace-and-return ()
;;         (interactive)
;;         (edebug-pop-to-backtrace)
;;         (windmove-up))
;; (map! :map edebug-mode-map "d" 'edebug-pop-to-backtrace-and-return)
;; oh boy this took ages
(map! :map backtrace-mode-map :after backtrace :n "d" 'backtrace-toggle-locals)
(map! :map backtrace-mode-map :after backtrace :n "n" 'edebug-next-mode)

;; org-mode
;; set the directory variables before org-mode loads
(setq org-directory "<REDACTED>")
(setq org-roam-directory "<REDACTED>")

;; quickly add timestamps to new headings - hack
;; it may be useful for taking minutes during meetings
;; add timestamp to new list items: C-RET or M-RET
;; https://www.reddit.com/r/orgmode/comments/14br2xi/automatic_timestamps_in_listsheaders/
(defun org-insert-heading-with-timestamp (&rest r)
  (insert (format-time-string "~%H:%M:%S~ ")))
(defun org-insert-heading-with-timestamp-enable ()
  (interactive)
  (advice-add 'org-insert-item :after #'org-insert-heading-with-timestamp))
(defun org-insert-heading-with-timestamp-disable ()
  (interactive)
  (advice-remove 'org-insert-item 'org-insert-heading-with-timestamp))

;; prettify org mode (hide title headers and =formatting= characters)
;; it may cause problems with inline images...
;; (add-hook! 'org-mode-hook 'doom-docs-mode)
(advice-add #'org-mode-hook :after '+word-wrap-mode)

;; by default it's 8 ?!
;; add indentation by pressing the ">" key twice
(setq evil-shift-width 2)

(after! org
  ;; I've had to give up on this - org-yt package seems to break loading order
  ;; https://github.com/TobiasZawada/org-yt/issues/6#issue-1826702028
  ;; pinning org-mode version: https://github.com/org-roam/org-roam/issues/2361#issuecomment-1650957932
  (advice-remove 'org-display-inline-images 'org-display-user-inline-images)

  (add-to-list 'org-capture-templates
               '("T" "Custom todo" entry
                 (file+headline +org-capture-todo-file "inbox")
                 "* TODO %?\n%i%u\n%a" :prepend t))
  (add-to-list 'org-capture-templates
               '("J" "Custom Journal" entry
                 (file+olp+datetree +org-capture-journal-file)
                 "* =%<%H:%M>= %?\n%i\n%a" :kill-buffer t))

  ;; oh why why why was it so hard (10 hours+)
  (org-wild-notifier-mode)
  (setq alert-default-style 'libnotify
        org-wild-notifier-alert-time '(0 15 60)
        org-wild-notifier-keyword-whitelist nil
        ;; good for testing
        org-wild-notifier--alert-severity 'high
        alert-fade-time 50
        )
  ;; https://www.reddit.com/r/orgmode/comments/14bx0v4/open_orgcapture_frame_maximized_to_the_window/
  ;; needs to be inside after! org block
  (defun stag-misanthropic-capture (&rest r)
    (delete-other-windows))
  (advice-add  #'org-capture-place-template :after 'stag-misanthropic-capture)
  (setq org-emphasis-alist
        '(("*" (bold))
          ;; ("/" italic)
          ("_" underline)
          ("=" (:foreground "#8bd49c"))
          ("~" (:foreground "#5ec4ff"))
          ("+" (:strike-through t))))
  ;; https://stackoverflow.com/questions/26204223/display-formatted-text-in-org-mode-without-formatting-characters
  (setq org-hide-emphasis-markers t)
  (setq org-agenda-files '("/home/user1/notes"))

  ;; graphical line between org-agenda sections (blocks)
  ;; couldn't decide on the right look, 32 is still a bit too big, ideally it would be a single line
  ;; (setq org-agenda-block-separator 9472)
  (setq org-agenda-block-separator 32)
  ;; (setq org-agenda-block-separator nil)

  (setq org-tag-alist '(("priority")
                        ("ongoing")
                        ("idea")
                        ("")
                        ))
  ;; https://github.com/zyrohex/.doom.d#agenda
  (setq org-agenda-custom-commands
        '(("o" "overview"
           ((agenda "" (
                        (org-agenda-overriding-header "")
                        (org-agenda-files '("<REDACTED>"))
                        (org-agenda-span '15)
                        ))
            (tags-todo "priority"
                       ((org-agenda-overriding-header "⚛ priority")
                        (org-agenda-files '("<REDACTED>"))
                        (org-agenda-todo-ignore-scheduled t)
                        (org-agenda-todo-ignore-deadlines t)
                        (org-agenda-todo-ignore-with-date t)
                        (org-tags-match-list-sublevels 'indented)
                        (org-agenda-sorting-strategy
                         '(category-up))))
            ;; i swear you just can't make up this shit:
            ;; https://emacs.stackexchange.com/questions/18179/org-agenda-command-with-org-agenda-filter-by-tag-not-working
            (alltodo "" (
                         (org-agenda-overriding-header " inbox")
                         (org-agenda-files '("<REDACTED>"))
                         (org-agenda-todo-ignore-scheduled t)
                         (org-agenda-todo-ignore-deadlines t)
                         (org-agenda-todo-ignore-with-date t)
                         (org-agenda-skip-function '(org-agenda-skip-entry-if 'regexp ":priority:\\|:ongoing:\\|:idea:"))
                         ))
            (tags-todo "ongoing"
                       ((org-agenda-overriding-header "📌 ongoing")
                        (org-agenda-files '("<REDACTED>"))
                        (org-agenda-todo-ignore-scheduled t)
                        (org-agenda-todo-ignore-deadlines t)
                        (org-agenda-todo-ignore-with-date t)
                        (org-tags-match-list-sublevels 'indented)
                        (org-agenda-sorting-strategy
                         '(category-up))))
            (tags-todo "idea"
                       ((org-agenda-overriding-header "🔍 idea")
                        (org-agenda-files '("<REDACTED>"))
                        (org-agenda-todo-ignore-scheduled t)
                        (org-agenda-todo-ignore-deadlines t)
                        (org-agenda-todo-ignore-with-date t)
                        (org-tags-match-list-sublevels 'indented)
                        (org-agenda-sorting-strategy
                         '(category-up))))
            ))
          ("p1" "project-1"
           ((agenda "" (
                        (org-agenda-overriding-header "")
                        (org-agenda-files '("<REDACTED>"))
                        (org-agenda-span '8)
                        ))
            (tags-todo "priority"
                       ((org-agenda-overriding-header "⚛ priority")
                        (org-agenda-files '("<REDACTED>"))
                        (org-agenda-todo-ignore-scheduled t)
                        (org-agenda-todo-ignore-deadlines t)
                        (org-agenda-todo-ignore-with-date t)
                        (org-tags-match-list-sublevels 'indented)
                        (org-agenda-sorting-strategy
                         '(category-up))))
            ;; i swear you just can't make up this shit:
            ;; https://emacs.stackexchange.com/questions/18179/org-agenda-command-with-org-agenda-filter-by-tag-not-working
            (alltodo "" (
                         (org-agenda-overriding-header " inbox")
                         (org-agenda-skip-function '(org-agenda-skip-entry-if 'regexp ":priority:\\|:ongoing:\\|:idea:"))
                         (org-agenda-files '("<REDACTED>"))
                         ))
            (tags-todo "ongoing"
                       ((org-agenda-overriding-header "📌 ongoing")
                        (org-agenda-files '("<REDACTED>"))
                        (org-agenda-todo-ignore-scheduled t)
                        (org-agenda-todo-ignore-deadlines t)
                        (org-agenda-todo-ignore-with-date t)
                        (org-tags-match-list-sublevels 'indented)
                        (org-agenda-sorting-strategy
                         '(category-up))))
            (tags-todo "idea"
                       ((org-agenda-overriding-header "🔍 idea")
                        (org-agenda-files '("<REDACTED>"))
                        (org-agenda-todo-ignore-scheduled t)
                        (org-agenda-todo-ignore-deadlines t)
                        (org-agenda-todo-ignore-with-date t)
                        (org-tags-match-list-sublevels 'indented)
                        (org-agenda-sorting-strategy
                         '(category-up))))
            ))
          ;;             trying to list all scheduled tasks for notifications service, but doesn't work
          ;;             ("sc" "overview" (
          ;; (alltodo "" (
          ;;              (org-agenda-todo-ignore-deadlines t)
          ;;              (org-agenda-todo-ignore-with-date t)
          ;;             ))))
          ))

  (setq org-confirm-babel-evaluate t)
  (setq org-icalendar-combined-agenda-file "<REDACTED>")
  (setq org-icalendar-include-todo t)
  ;; start calendar on monday instead of sunday
  (setq calendar-week-start-day 1)

  ;; shorthand for adding code source blocks
  ;; nowadays I just type "src" press enter and specify the language
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))

  (setq org-startup-with-inline-images t)
  ;; https://github.com/tefkah/doom-emacs-config/blob/main/config.org
  (custom-set-faces!
    '((org-block) :background "#182027")
    )
  ;; (set-face-font 'org-quote (font-spec :family "noto serif"))
  (custom-set-faces!
    '(org-document-title :height 1.75 :weight extrabold)
    ;; '(org-level-1 :inherit outline-1 :height 1.2 :weight bold :slant normal)
    ;; '(org-level-2 :inherit outline-2 :height 1.1 :weight bold :slant normal)
    ;; '(org-level-3 :inherit outline-3 :height 1.1 :weight regular :slant normal)
    ;; '(org-document-info  :inherit 'nano-face-faded)
    )
  ;; https://stackoverflow.com/questions/11718401/how-to-use-todo-tags-in-org-mode-without-defining-headings
  ;; https://www.reddit.com/r/orgmode/comments/14w45bt/how_to_use_orginline_task/
  ;; (require 'org-inlinetask)
  )

;; couldn't add this directly to org-mode-map
(map! :leader "d d" 'org-cut-subtree)

(map! :leader "e h" 'org-pandoc-export-to-html5-and-open)

;; for org-structure-template-alist
;; https://www.youtube.com/live/kkqVTDbfYp4?feature=share&t=723
(use-package! org-tempo
  :after org)

(use-package! org-ql
  :after org)

;; https://github.com/doomemacs/doomemacs/issues/7414#issuecomment-1732461759
(use-package! htmlz :commands (htmlz-mode))

;; https://baty.net/2022/configuring-the-org-download-save-directory
;; https://github.com/abo-abo/org-download/issues/46
;; https://github.com/abo-abo/org-download/issues/151#issuecomment-1425096926
(after! org-download
  (setq org-download-method 'directory)
  (setq org-download-image-dir (concat (file-name-sans-extension (buffer-file-name)) "-images"))
  (setq org-download-image-org-width 600)
  (setq org-download-link-format "[[file:%s]]\n"
        org-download-abbreviate-filename-function #'file-relative-name)
  (setq org-download-link-format-function #'org-download-link-format-function-default))

;; https://discourse.doomemacs.org/t/org-time-stamp-only-gives-date-no-time-hoursseconds/3269/3
;; (after! org
;;   (setq org-time-stamp-formats '("<%Y-%m-%d %a %H:%M>" . "<%Y-%m-%d %a %H:%M>")))

(setq deft-directory "/home/user1/notes"
      deft-recursive t)

(after! dap-mode
  (setq dap-python-debugger 'debugpy))

;; clipboard
;; these settings should come as a defualt in my opinion
;;
;; don't put deleted strings to X11 clipboard
(setq select-enable-clipboard nil)

;; copies and pastes selected text to and from X11 clipboard
;; this was my first tweak on doom emacs
;; I took me sooo much time to figure out
(map! "S-C-c" 'clipboard-kill-ring-save)
(map! "S-C-v" 'clipboard-yank)

;; to copy the visible portion of the selection
;; useful when copying commands that are often in ~this format~
;; https://www.reddit.com/r/orgmode/comments/14cm6j0/comment/jomihz4/?utm_source=share&utm_medium=web2x&context=3
(defun org-copy-visible-X11-clipboard (beg end)
  (interactive "r")
  (let ((select-enable-clipboard t))
    (org-copy-visible beg end)))

;; ein
;;
;; Here be dragons...
;;
;; https://github.com/doomemacs/doomemacs/issues/7257#issuecomment-1648522478
;; https://github.com/millejoh/emacs-ipython-notebook/issues/873
;; https://emacs.stackexchange.com/questions/14432/initialize-ipython-notebook-server-from-ipynb-file/77386
;; (add-hook 'ein:ipynb-mode-hook
;;           (lambda ()
;;             (cl-letf (((symbol-function 'read-directory-name)
;;                        (lambda (_prompt dir &rest _args) dir)))
;;               (ein:process-open-notebook nil (lambda (&rest _args)
;;               (mapc 'switch-to-buffer
;;                      (cl-remove-if-not (lambda (b)
;;                       (and
;;                        (string-match-p "ein" (buffer-name b))
;;                        (string-match-p "ipynb" (buffer-name b))))
;;                     (buffer-list)))
;;               (delete-other-windows)))
;;                 )))

;; henrik tried to solve it
;; https://github.com/doomemacs/doomemacs/issues/7257#issuecomment-1648522478
;; (add-hook! 'ein:ipynb-mode-hook
;;   ;; By adding it to this hook, we can be sure that the server
;;   ;; won't be started until the buffer is visible (prevents a
;;   ;; cascade of new processes when opening multiple *.ipynb files
;;   ;; all at once.
;;   (add-hook 'doom-switch-buffer-hook #'ein:process-open-notebook nil 'local))

;; https://emacs.stackexchange.com/questions/58339/async-shell-command-run-command-without-displaying-the-output
;; open an external shell
(defun open-terminal-alacritty ()
  (interactive)
  (add-to-list 'display-buffer-alist '("*Async Shell Command*" display-buffer-no-window (nil)))
  (async-shell-command "alacritty -e tmux" nil nil))

;; ...replace doom's default keybinding to open a shell
(map! :leader "o t" 'open-terminal-alacritty)

;; centaur tabs activate
;; I like them, but YMMV
(setq centaur-tabs-set-bar t)

;; Switch centaur tabs with ctrl+tab and ctrl+shift+tab
;; turns out :nvi and other states are the way to do that
;; to prevent evil keybindings from taking over
;; https://discourse.doomemacs.org/t/how-to-bind-keys-with-higher-precedence-than-evil-keybindings/3743/3
(map! :nvi "C-<tab>" 'centaur-tabs-forward)
(map! :nvi "C-<iso-lefttab>" 'centaur-tabs-backward)

;; I can't remember what this was
;; use once groked
;; (map! :nvi "C-t" #'centaur-tabs--create-new-tab)

;; speed up which-key's buffer prompt
(setq which-key-idle-delay 0.25)

;; allow which-key to expand side-window to half the frame's height
(setq which-key-side-window-max-height 0.5)

;; RSS
(setq elfeed-feeds (quote (
                           ("https://lwn.net/headlines/rss" linux)
                           ("https://archlinux.org/feeds/news/" linux)
                           ("https://rss.slashdot.org/Slashdot/slashdotMain" linux)
                           ("https://www.phoronix.com/rss.php" linux)
                           ("https://architectsjournal.co.uk/feed" architecture)
                           ("https://osarch.org/feed/" architecture)
                           ("https://feeds.feedburner.com/Archdaily" architecture)
                           ("https://www.dezeen.com/rss" architecture)
                           )))
;; copied from distrotube
(setq elfeed-goodies/entry-pane-size 0.7)
(evil-define-key 'normal elfeed-show-mode-map
  (kbd "J") 'elfeed-goodies/split-show-next
  (kbd "K") 'elfeed-goodies/split-show-prev)
(evil-define-key 'normal elfeed-search-mode-map
  (kbd "J") 'elfeed-goodies/split-show-next
  (kbd "K") 'elfeed-goodies/split-show-prev)

;; Forked it and tried to add desktop notifications
;; Originally it only provides modeline notifications
;; Ended up using the elfeed-new-entry-hook instead (below)
(use-package! elfeed-system-notifier
  :defer t
  :commands elfeed-notifier-mode)
(elfeed-notifier-mode)

(defun elfeed-desktop-notifications (entry)
  "Parse and display new feeds as desktop notifications."
  (alert (elfeed-deref (elfeed-entry-content entry))
         :title (concat
                 (elfeed-feed-title (elfeed-deref (elfeed-entry-feed entry))) "\n"
                 (elfeed-deref (elfeed-entry-title entry))
                 )
         ;; :severity 'high
         ))
(add-hook! 'elfeed-new-entry-hook #'elfeed-desktop-notifications)

;; hmm, not sure what this is...
(advice-add 'kill-current-buffer :after #'+workspace/close-window-or-workspace)
