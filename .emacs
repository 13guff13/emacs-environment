;;global varibale.
;;end global variable.

;; global hotkey.

(global-set-key (kbd "C-M-p") 'move-text-up)
(global-set-key (kbd "C-M-n") 'move-text-down)
(global-set-key (kbd "C-M-j") 'to-speak-region)
(global-set-key (kbd "C-c g") 'revert-buffer)

  (global-set-key (kbd "C-l") 'recenter-top-bottom)
  (global-set-key (kbd "C-u") 'recenter)
  ;; global default hotkey.
;; org mode
;;(add-to-list 'org-emphasis-alist
;;             '("*" (:foreground "red")
;;               ))


;; global settings

;; reduce the frequency of garbage collection by making it happen on
;; each 50MB of allocated data (the default is on every 0.76MB)
(setq gc-cons-threshold 50000000)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

(setq jit-lock-defer-time 0.05)
(defalias 'yes-or-no-p 'y-or-n-p)

(setq make-backup-files nil)
(setq backup-inhibited t)
(setq auto-save-default nil)
(setq confirm-kill-emacs nil)

(set-default 'truncate-lines t)

(setq visible-bell t
      column-number-mode t
      echo-keystrokes 0.1
      font-lock-maximum-decoration t
      inhibit-startup-message t
      transient-mark-mode t
      color-theme-is-global t
      shift-select-mode nil
      mouse-yank-at-point t
      ;;require-final-newline t
      truncate-partial-width-windows nil
      delete-by-moving-to-trash nil
      uniquify-buffer-name-style 'forward
      ediff-window-setup-function 'ediff-setup-windows-plain
      xterm-mouse-mode t)

(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(menu-bar-mode -1)
(tool-bar-mode -1)
;; custome function definitions.
(defun drag-line-custome (arg)
  "Drag the line at point ARG lines forward."
  (interactive "p")
  (dotimes (n (abs arg))
    (let ((c (current-column)))
      (if (< 0 arg)
          (progn
            (beginning-of-line 2)
            (transpose-lines 1)
            (beginning-of-line 0))
        (transpose-lines 1)
        (beginning-of-line -1)))))

(drag-line-custome -1)


(defun to-speak-region (start end)
  "Print number of lines and characters in the region."
  (interactive "r")
  (eshell-command (concat "espeak -g 10 -s 70 -v en-uk  --ipa=2 \"" (buffer-substring start end) "\""))
;;  (message "%s" (concat "espeak -s 100 -v en-uk  --ipa=2 \"" (buffer-substring start end) "\""))
)

(defun prelude-open-with ()
  "Simple function that allows us to open the underlying
file of a buffer in an external program. 
NOTE: part of https://github.com/bbatsov/prelude."
  (interactive)
  (when buffer-file-name
    (shell-command (concat
                    (if (eq system-type 'darwin)
                        "open"
                      (read-shell-command "Open current file with: "))
                    " "
                    buffer-file-name))))
(global-set-key (kbd "C-c o") 'prelude-open-with)


(defun move-text-internal (arg)
   (cond
    ((and mark-active transient-mark-mode)
     (if (> (point) (mark))
            (exchange-point-and-mark))
     (let ((column (current-column))
              (text (delete-and-extract-region (point) (mark))))
       (forward-line arg)
       (move-to-column column t)
       (set-mark (point))
       (insert text)
       (exchange-point-and-mark)
       (setq deactivate-mark nil)))
    (t
     (beginning-of-line)
     (when (and (> arg 0) (not (bobp)))
       (forward-line)
       (when (or (< arg 0) (not (eobp)))
         (transpose-lines arg))
       (forward-line -1)))))

(defun move-text-down (arg)
   "Move region (transient-mark-mode active) or current line
  arg lines down."
   (interactive "*p")
   (move-text-internal arg))

(defun move-text-up (arg)
   "Move region (transient-mark-mode active) or current line
  arg lines up."
   (interactive "*p")
   (move-text-internal (- arg)))


(defun revert-buffer-no-confirm ()
  "Revert buffer without confirmation."
  (interactive)
      (revert-buffer t t))

;;; translate UI functions...
(defun translate-at-point2 ()
  (interactive)
  (if (setq bounds (bounds-of-thing-at-point 'word))
      (translation-buffer2 (buffer-substring-no-properties
                       (car bounds)
                       (cdr bounds)))
      (message "don't find any word.")))


(defun translation-buffer2 (str)
  (let ((buffer-name "*translate dictionary*"))
    (with-output-to-temp-buffer buffer-name
      (select-window (display-buffer buffer-name))
      (set-buffer buffer-name)
      (set-process-sentinel
       (start-file-process "jopa" buffer-name "~/emacs/sbcl/dictionary/dictionary-cli2.lisp.bin" str)
       (lambda (process string)
         (message "I've done."))))))
;;; translate UI functions.

(global-set-key (kbd "C-t") 'mc/mark-next-like-this)
(add-to-list 'load-path "/home/guff/.emacs.d/manual-packages/eap/")
;;(require 'org-drill)
(require 'package)
(add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
(package-initialize)
(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
(package-initialize)

;;grep
(add-to-list 'load-path "/home/guff/.emacs.d/manual-packages/igrep/")
(require 'igrep)

(autoload 'igrep "igrep"
  "*Run `grep` PROGRAM to match REGEX in FILES..." t)
(autoload 'igrep-find "igrep"
  "*Run `grep` via `find`..." t)
(autoload 'igrep-visited-files "igrep"
  "*Run `grep` ... on all visited files." t)
(autoload 'dired-do-igrep "igrep"
  "*Run `grep` on the marked (or next prefix ARG) files." t)
(autoload 'dired-do-igrep-find "igrep"
  "*Run `grep` via `find` on the marked (or next prefix ARG) directories." t)
(autoload 'Buffer-menu-igrep "igrep"
  "*Run `grep` on the files visited in buffers marked with '>'." t)
(autoload 'igrep-insinuate "igrep"
  "Define `grep' aliases for the corresponding `igrep' commands." t)


(require 'grep-a-lot)
(grep-a-lot-setup-keys)

;;(eshell-command "espeak -s 100 -v en-polish  --ipa=3 \"where\"")

(defun espeak-buffer2 (str)
  (message str)
  (let ((buffer-name "*speak-buffer*"))
    (with-output-to-temp-buffer buffer-name
      (select-window (display-buffer buffer-name))
      (set-buffer buffer-name)
      (let ((proc
             (start-process "emacs-espeak-process" buffer-name "espeak" "-s 100 -v en-uk  --ipa=2 \"" str "\"")))
        (set-process-filter proc (lambda (process string)
                                   (message "this isn't work.")))
        (set-process-sentinel proc
                              (lambda (process string)
                                (message string)))))))

(defun to-speak-at-point ()
    (interactive "r")
    (if (setq bounds (bounds-of-thing-at-point 'word))
      (espeak-buffer2 (buffer-substring-no-properties
                       (car bounds)
                       (cdr bounds)))
      (message "don't find any word.")))



(defun to-speak-region (start end)
  "Print number of lines and characters in the region."
  (interactive "r")
  (eshell-command (concat "espeak -s 100 -v en-uk  --ipa=2 \"" (buffer-substring start end) "\""))
;;  (message "%s" (concat "espeak -s 100 -v en-uk  --ipa=2 \"" (buffer-substring start end) "\""))
)


;; initialize global modes.
;;(show-paren-mode)

(load (expand-file-name "~/quicklisp/slime-helper.el"))
  ;; Replace "sbcl" with the path to your implementation
  (setq inferior-lisp-program "sbcl")

;; ace-jump package.
(autoload
  'ace-jump-mode
  "ace-jump-mode"
  "Emacs quick move minor mode"
  t)

(eval-after-load "ace-jump-mode"
  '(ace-jump-mode-enable-mark-sync))
;; end ace-jump package.

;; highlight-parentheses
(require 'highlight-parentheses)

(define-globalized-minor-mode global-highlight-parentheses-mode highlight-parentheses-mode
  (lambda nil (highlight-parentheses-mode t)))

(global-highlight-parentheses-mode t)

;; codesearch 
(require 'codesearch)

(require 'multiple-cursors)

(global-set-key (kbd "C-w") 'mc/mark-next-like-this)

(require 'ediprolog)
(global-set-key [f10] 'ediprolog-dwim)
(setq auto-mode-alist
      (cons (cons "\\.pl" 'prolog-mode)
	         auto-mode-alist))


(global-diff-hl-mode)


(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; set global variables.
;;(setq make-backup-files nil)
(setq auto-save-file-name nil)
(setq auto-save-default nil)
(setq inhibit-startup-message t)
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(fset 'yes-or-no-p 'y-or-n-p)


(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

(global-set-key (kbd "C-c n") 'psw-switch-buffer)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
(define-key global-map [f5] 'toggle-truncate-lines)
(define-key global-map (kbd "C-x SPC") 'ace-jump-mode-pop-mark)
;;(keyboard-translate ?\C-f ?\C-l)

;;(keyboard-translate ?\C-l ?\C-f)
;;(keyboard-translate ?\C-b ?\C-j)
;;(keyboard-translate ?\C-j ?\C-b)
;;(keyboard-translate ?\C-p ?\C-i)
;;(keyboard-translate ?\C-i ?\C-p)
;;(keyboard-translate ?\C-n ?\C-k)
;;(keyboard-translate ?\C-k ?\C-n)

;;(keyboard-translate ?\M-f ?\M-l)
;;(keyboard-translate ?\M-l ?\M-f)
;;(keyboard-translate ?\M-b ?\M-j)
;;(keyboard-translate ?\M-j ?\M-b)
;;(keyboard-translate ?\M-p ?\M-i)
;;(keyboard-translate ?\M-i ?\M-p)
;;(keyboard-translate ?\M-n ?\M-k)
;;(keyboard-translate ?\M-k ?\M-n)

(require 'multiple-cursors)
    (global-set-key (kbd "C-w") 'mc/mark-next-like-this)
;;    (global-set-key (kbd "C-q") 'mc/mark-previous-like-this)
;;    (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

(org-babel-do-load-languages
 'org-babel-load-languages
  '((dot . t)))

(load (expand-file-name "~/quicklisp/slime-helper.el"))
;; Replace "sbcl" with the path to your implementation
(setq inferior-lisp-program "sbcl")

(require 'auto-complete-config)
(setq ac-directory-directories "/home/guff/.emacs.d/elpa/auto-complete-1.4/dict")
(setq-default ac-sources
	      '(ac-source-abbrev ac-source-dictionary  ac-source-words-in-same-mode-buffers))
(ac-config-default)

(add-to-list 'load-path "/home/guff/.emacs.d/manual-packages/eap/")
(require 'eap-autoloads)
(setq eap-music-library
      "/media/guff/ee5f827f-e13a-4d2a-8abc-bed9f94296a2/muz/" ;default value "~/Music"

      eap-playlist-library
      "~/eap-playlist-library") ;default value "~/eap-playlist-library"

(add-to-list 'load-path "/home/guff/.emacs.d/elpa/ag.el-master")
(require 'ag)


(require 'projectile)
(projectile-global-mode)

;;(add-to-list 'load-path "~/.emacs.d/elpa/helm-projectile-0.10.0/")
;; open realy large file to 500MB and even more on 64 bit system.
(require 'vlf-setup)

(require 'helm-config)

;;(require 'yasnippet)
;;(yas-global-mode 1)
;;(setq yas-snippet-dirs
;;      '("/home/guff/.emacs.d/elpa/yasnippet-0.8.0/snippets"                 ;; personal snippets
;;        "/path/to/some/collection/"           ;; foo-mode and bar-mode snippet collection
;;        "/path/to/yasnippet/yasmate/snippets" ;; the yasmate collection
;;        "/path/to/yasnippet/snippets"         ;; the default collection
;;	        ))
(require 'sr-speedbar)
(global-set-key (kbd "<f12>") 'sr-speedbar-toggle)
(require 'emmet-mode)
(require 'google-translate)
(require 'google-translate-smooth-ui)
(setq google-translate-default-source-language "English")
(setq google-translate-default-target-language "Russian")
(global-set-key (kbd "C-t") 'translate-at-point2)
(global-set-key (kbd "C-M-r") 'revert-buffer-no-confirm)
(global-set-key (kbd "C-M-m") 'magit-status)
(global-set-key (kbd "C-c SPC") 'ace-jump-mode)
(global-set-key (kbd "C-c C-f") 'projectile-find-file)
(global-set-key (kbd "C-c C-s") 'codesearch-search)

(defun disable-magit-highlight-in-buffer ()
  (face-remap-add-relative 'magit-item-highlight '()))

(add-hook 'magit-status-mode-hook 'disable-magit-highlight-in-buffer)

;;(global-set-key (kbd "C-t") 'google-translate-query-translate)
(delete-selection-mode t)
(show-paren-mode t)

;;(require 'ido)
;;(ido-mode t)
;;(setq ido-enable-flex-matching t)

;;path to load plugins.
(add-to-list 'load-path "/home/guff/.emacs.d/elpa/")

(smart-tabs-insinuate 'javascript 'nxml)

(require 'whitespace)

;; Set to the location of your Org files on your local system
(setq org-directory "~/tmp/emacs_learn/mobile/")
;; Set to the name of the file where new notes will be stored
(setq org-mobile-inbox-for-pull "~/tmp/emacs_learn/mobile/mob-org/inbox.org")
;; Set to <your Dropbox root directory>/MobileOrg.
(setq org-mobile-directory "~/tmp/emacs_learn/mobile/mob-org")

(require 'linum)
(setq linum-format "%d| " )
(global-linum-mode 1) 

;;(defun my/insert-line-before ()
;; (interactive)
;;(save-excursion
;;  (move-beginning-of-line 1)
;;  (newline)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(blink-cursor-blinks 10)
 '(blink-cursor-interval 1)
 '(custom-enabled-themes (quote (manoj-dark)))
 '(custom-safe-themes
   (quote
    ("a9c09f6267b3c01f3d43afdb8a36e56f9edf90953ffbe993c176b6b662d3755f" "c383aa2e5b0756e28ac8d9af6340a87704edc1a11647ca710f178568ad033560" default)))
 '(google-translate-default-source-language "en")
 '(google-translate-default-target-language "ru")
 '(hourglass-delay 1)
 '(org-modules
   (quote
    (org-bbdb org-bibtex org-docview org-gnus org-info org-irc org-mhe org-rmail org-w3m org-drill)))
 '(safe-local-variable-values (quote ((Syntax . Common-Lisp)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'upcase-region 'disabled nil)



(add-hook 'js2-mode-hook 'skewer-mode)
(add-hook 'css-mode-hook 'skewer-css-mode)
(add-hook 'html-mode-hook 'skewer-html-mode)
