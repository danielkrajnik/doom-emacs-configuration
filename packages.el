;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; https://discourse.doomemacs.org/t/how-to-upgrade-emacs-properly/2559/4
;; https://github.com/radian-software/straight.el/issues/1107#issuecomment-1662711415
;; (package! org :pin "ca873f7")

(package! org-wild-notifier)
(package! nhexl-mode)
(package! org-ql)
(package! org-preview-html)
(package! org-gtd)
(package! calfw)
(package! lorg-calendar
  :recipe (:host github :repo "lawlist/lorg-calendar"))

;; Forked and tried to modify the original package to add desktop notifications in addition to the modeline notifications
;; However, I never got to finish it and ended up using elfeed-new-entry-hook instead (config.el)
(package! elfeed-system-notifier
  :recipe (:host github :repo "danielkrajnik/elfeed-system-notifier"))

;; this took sooo damn long to setup and the first thing that turned out
;; working  was adding and ;;;autoloads header over the minor mode following the packaging conventions
;; However doom emacs later started to override any local changes, so following an advise I added
;; a :command to tge use-package! macro that does it on emacs boot instead (config.el)
;; https://www.reddit.com/r/emacs/comments/13pp502/help_install_simple_package_htmlzmode/
;; https://github.com/0xekez/htmlz-mode/issues/1
;; https://github.com/doomemacs/doomemacs/issues/7414#issuecomment-1732461759
(package! htmlz
  :recipe (:host github :repo "0xekez/htmlz-mode"))

(package! exec-path-from-shell)

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
                                        ;(package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
                                        ;(package! builtin-package :recipe (:nonrecursive t))
                                        ;(package! builtin-package-2 :recipe (:repo "myfork/package"))
