(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-hide-compile-buffer-delay 3)
 '(company-auto-complete t)
 '(company-idle-delay 0.2)
 '(company-insertion-on-trigger t)
 '(company-minimum-prefix-length 2)
 '(flymake-diagnostic-at-point-display-diagnostic-function 'flymake-diagnostic-at-point-display-minibuffer)
 '(help-at-pt-display-when-idle '(flymake-overlay) nil (help-at-pt))
 '(help-at-pt-timer-delay 0.9)
 '(package-selected-packages
   '(tabbar helm-gtags sr-speedbar helm-tramp org-bullets ace-window 0blayout magithub lsp-mode lua-mode transpose-frame scala-mode neotree magit ggtags helm flymake flymake-cursor yasnippet-snippets yasnippet company-quickhelp company smex idle-highlight-mode resize-window default-text-scale use-package dts-mode evil))
 '(warning-suppress-types '((comp) (comp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(global-hi-lock-mode 1)

;;disable splash screen and startup message
(setq inhibit-startup-message t) 
(setq initial-scratch-message nil)
;(global-hl-line-mode -1)
(defalias 'yes-or-no-p 'y-or-n-p)

(tool-bar-mode -1)          ; Disable the toolbar
(menu-bar-mode -1)            ; Disable the menu bar

(require 'paren)
(setq show-paren-style 'parenthesis)
(show-paren-mode 1)
(when (fboundp 'electric-pair-mode)
  (electric-pair-mode))

(setq user-full-name "Sanglae Kim"
      user-mail-address "nova0302@hotmail.com")

(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(require 'flymake)

(setq dired-listing-switches "-alh --group-directories-first")
(setq dired-dwim-target t)

(use-package helm
  :ensure t
  :demand
  :bind (("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x b" . helm-buffers-list)
         ("C-x c o" . helm-occur)) ;SC
  ("M-y" . helm-show-kill-ring) ;SC
  ("C-x r b" . helm-filtered-bookmarks) ;SC
;;;  :preface (require 'helm-config)
  :config (helm-mode 1))

(add-hook 'prog-mode-hook #'hs-minor-mode)

(use-package default-text-scale
  :ensure t
  :config
  (default-text-scale-mode))
(global-set-key (kbd "C-=") 'default-text-scale-increase)
(global-set-key (kbd "C--") 'default-text-scale-decrease)


;(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))
(setq make-backup-files nil)
(setq create-lockfiles nil)

(setq compilation-ask-about-save nil)

(setq delete-by-moving-to-trash t
      trash-directory "~/.Trash/")

(use-package recentf
  :config
  (setq recentf-auto-cleanup 'never
	recentf-max-saved-items 1000
	recentf-save-file (concat user-emacs-directory ".recentf"))
  (global-set-key "\C-x\ \C-r" 'recentf-open-files)
  (recentf-mode t))


(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

(use-package sr-speedbar
  :custom
  ;; Show tree on the left side
  (sr-speedbar-right-side nil)
  ;; Show all files
  (speedbar-show-unknown-files t)
  ;; Bigger size (default is 24)
  (sr-speedbar-width 35))

(global-set-key (kbd "<f3>") 'jpt-toggle-mark-word-at-point)

;(global-set-key (kbd "<f3>") 'sr-speedbar-toggle)
(global-set-key (kbd "<f4>") 'find-file-at-point)
(global-set-key (kbd "<f5>") 'dired)

;(global-set-key (kbd "<f6>") 'smex)
(global-set-key (kbd "<f6>") 'helm-M-x)


(global-set-key (kbd "<f7>") 'recompile)
(global-set-key (kbd "<f8>") 'compile)
(global-set-key (kbd "<f9>") 'hs-toggle-hiding)
(global-set-key (kbd "<f11>") 'resize-window)
(global-set-key (kbd "<f12>") 'hs-hide-level)

;(add-to-list 'load-path "~/.emacs.d/plugins/bb-mode/")

;(require 'bb-mode)
;(setq auto-mode-alist (cons '("\\.bb$" . bb-mode) auto-mode-alist))
;(setq auto-mode-alist (cons '("\\.inc$" . bb-mode) auto-mode-alist))
;(setq auto-mode-alist (cons '("\\.bbappend$" . bb-mode) auto-mode-alist))
;(setq auto-mode-alist (cons '("\\.bbclass$" . bb-mode) auto-mode-alist))
;(setq auto-mode-alist (cons '("\\.conf$" . bb-mode) auto-mode-alist))

;(autoload 'octave-mode "octave-mod" nil t)
(setq auto-mode-alist
      (cons '("\\.m$" . octave-mode) auto-mode-alist))

;(use-package company
;  :init
;  (setq company-backends '((company-files company-keywords company-capf company-dabbrev-code company-etags company-dabbrev)))
;  :config
;  (global-company-mode 1))
;(eval-after-load 'company
;  '(progn
;     (define-key company-mode-map (kbd "C-:") 'helm-company)
;     (define-key company-active-map (kbd "C-:") 'helm-company)))

;(add-hook 'after-init-hook 'global-company-mode)

;(company-quickhelp-mode)

(require 'yasnippet)
(yas-global-mode 1)
(yas-reload-all)
(add-hook 'prog-mode-hook #'yas-minor-mode)

;;;(add-hook 'compilation-start-hook 'compilation-started)
;;;(add-hook 'compilation-finish-functions 'hide-compile-buffer-if-successful)
;;;
;;;(defcustom auto-hide-compile-buffer-delay 0
;;;  "Time in seconds before auto hiding compile buffer."
;;;  :group 'compilation
;;;  :type 'number
;;;  )
;;;
;;;(defun hide-compile-buffer-if-successful (buffer string)
;;;  (setq compilation-total-time (time-subtract nil compilation-start-time))
;;;  (setq time-str (concat " (Time: " (format-time-string "%s.%3N" compilation-total-time) "s)"))
;;;
;;;  (if
;;;      (with-current-buffer buffer
;;;	(setq warnings (eval compilation-num-warnings-found))
;;;	(setq warnings-str (concat " (Warnings: " (number-to-string warnings) ")"))
;;;	(setq errors (eval compilation-num-errors-found))
;;;
;;;	(if (eq errors 0) nil t)
;;;	)
;;;
;;;      ;;If Errors then
;;;      (message (concat "Compiled with Errors" warnings-str time-str))
;;;
;;;    ;;If Compiled Successfully or with Warnings then
;;;    (progn
;;;      (bury-buffer buffer)
;;;      (run-with-timer auto-hide-compile-buffer-delay nil 'delete-window (get-buffer-window buffer 'visible))
;;;      (message (concat "Compiled Successfully" warnings-str time-str))
;;;      )
;;;    )
;;;  )
;;;
;;;(make-variable-buffer-local 'compilation-start-time)
;;;
;;;(defun compilation-started (proc) 
;;;  (setq compilation-start-time (current-time)))

(load "flymake")

;(eval-after-load 'flymake '(require 'flymake-cursor))

;(use-package flymake-diagnostic-at-point
;  :after flymake
;  :config
;  (add-hook 'flymake-mode-hook #'flymake-diagnostic-at-point-mode))

;(add-to-list 'load-path "~/.emacs.d/plugins/flymake-diagnostic-at-point/")


;(eval-after-load 'flymake
;  '(require 'flymake-diagnostic-at-point))
;(add-hook 'flymake-mode-hook #'flymake-diagnostic-at-point-mode)

;; Auto refresh buffers
(global-auto-revert-mode 1)

;; Also auto refresh dired, but be quiet about it
(setq global-auto-revert-mode 1)
(setq auto-revert-verbose nil)
(add-hook 'ibuffer-mode-hook (lambda () (ibuffer-auto-mode 1)))

(setq byte-compile-warnings '(not-free-vars))

(add-hook 'ibuffer-mode-hook
	  (lambda ()
	    (ibuffer-auto-mode 1)
	    (electric-pair-mode)))
(add-hook 'prog-mode-hook 'electric-pair-mode)

;(add-hook 'compilation-start-hook 'compilation-started)
;(add-hook 'compilation-finish-functions 'hide-compile-buffer-if-successful)
;(defcustom auto-hide-compile-buffer-delay 0
;  "Time in seconds before auto hiding compile buffer."
;  :group 'compilation
;  :type 'number)
;
;(defun hide-compile-buffer-if-successful (buffer string)
;  (setq compilation-total-time (time-subtract nil compilation-start-time))
;  (setq time-str (concat " (Time: " (format-time-string "%s.%3N" compilation-total-time) "s)"))
;
;  (if
;      (with-current-buffer buffer
;        (setq warnings (eval compilation-num-warnings-found))
;        (setq warnings-str (concat " (Warnings: " (number-to-string warnings) ")"))
;        (setq errors (eval compilation-num-errors-found))
;
;        (if (eq errors 0) nil t)
;	)
;
;      ;;If Errors then
;      (message (concat "Compiled with Errors" warnings-str time-str))
;
;    ;;If Compiled Successfully or with Warnings then
;    (progn
;      (bury-buffer buffer)
;      (run-with-timer auto-hide-compile-buffer-delay nil 'delete-window (get-buffer-window buffer 'visible))
;      (message (concat "Compiled Successfully" warnings-str time-str))
;      )
;    )
;  )
;
;(make-variable-buffer-local 'compilation-start-time)
;
;(defun compilation-started (proc) 
;  (setq compilation-start-time (current-time)))

(desktop-save-mode 1)

;(use-package magit
;  :init
;  (message "Loading Magit!")
;  :config
;  (message "Loaded Magit!")
;  :bind (("C-x g" . magit-status)
;	 ("C-x C-g" . magit-status))
;  )

;;;;(evil-mode)
;;(defalias 'forward-evil-word 'forward-evil-symbol)

(use-package evil
  :demand t
  :custom
  (evil-esc-delay 0.001 "avoid ESC/meta mixups")
  (evil-shift-width 4)
  (evil-search-module 'evil-search)

  :bind (:map evil-normal-state-map
	      ("S" . replace-symbol-at-point))
  :config
  ;; Enable evil-mode in all buffers.
  (evil-mode 1))

;;(modify-syntax-entry ?_ "w")
(add-hook 'prog-mode-hook (lambda () (modify-syntax-entry ?_ "w")))
(add-hook 'prog-mode-hook (lambda () (modify-syntax-entry ?- "w")))

;; Auto-refresh dired on file change
(add-hook 'dired-mode-hook 'auto-revert-mode)

(use-package ggtags
  :config
  (add-hook 'c-mode-hook
	    (lambda ()
	      (ggtags-mode t)))
  (add-hook 'c-mode-common-hook
	    (lambda ()
	      (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
		(ggtags-mode t)))))

(define-key evil-normal-state-map (kbd "C-]")'ggtags-find-tag-dwim)
(define-key evil-insert-state-map (kbd "C-/") 'completion-at-point)

(require 'hi-lock)
(defun jpt-toggle-mark-word-at-point ()
  (interactive)
  (if hi-lock-interactive-patterns
      (unhighlight-regexp (car (car hi-lock-interactive-patterns)))
    (highlight-symbol-at-point)))

;(use-package idle-highlight-mode
;  :config (setq idle-highlight-idle-time 5)
;  :hook ((prog-mode text-mode) . idle-highlight-mode))

;(require 'idle-highlight-mode)
;(add-hook 'prog-mode-hook 'idle-highlight-mode)
;(idle-highlight-global-mode)

(add-to-list 'load-path (expand-file-name "~/.emacs.d/plugins/lazycat-theme"))
					;(require 'lazycat-theme)
;(load-theme 'misteriso)

(use-package ace-window
  :ensure t
  :init (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)
	      aw-char-position 'left
	      aw-ignore-current nil
	      aw-leading-char-style 'char
	      aw-scope 'frame)
  :bind (("M-o" . ace-window)
	 ("M-O" . ace-swap-window)))

(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))

(require 'org-tempo)


;(set-language-environment "UTF-8")

(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(require 'transpose-frame)

(add-to-list 'load-path "~/.emacs.d/plugins/dts-mode-1.0/")
(require'dts-mode)
;(add-to-list 'auto-mode-alist)

(setq auto-mode-alist
      (cons '("\\.dtsi$" . dts-mode) auto-mode-alist))

(add-to-list 'load-path "~/.emacs.d/plugins/")
(require 'resize-frame)

;(add-hook 'gtags-mode-hook
;          (lambda ()
;            (local-set-key (kbd "M-]") 'gtags-find-tag)
;            (local-set-key (kbd "M-[") 'gtags-find-rtag)))

;(add-hook 'gtags-mode-hook
;          (lambda ()
;            (local-set-key (kbd "C-]") 'gtags-find-tag)
;            (local-set-key (kbd "M-[") 'gtags-find-rtag)))
(eval-after-load 'evil-maps
  '(define-key evil-normal-state-map (kbd "M-.") nil))

;(setq ido-enable-flex-matching t)
;(setq ido-everywhere t)
;(ido-mode 1)

(add-hook 'after-init-hook 'global-company-mode)
(setq org-src-widow-setup 'other-window)

(add-hook 'c-mode-hook '
	  (lambda ()
	    (c-set-style "bsd")
	    (setq default-tab-width 2)
	    (setq c-basic-offset 2) ;; indent use only 2 blank
	    (setq indent-tabs-mode nil) ;; no tab
	    ))

(add-hook 'compilation-start-hook 'compilation-started)
(add-hook 'compilation-finish-functions 'hide-compile-buffer-if-successful)

(defcustom auto-hide-compile-buffer-delay 0
  "Time in seconds before auto hiding compile buffer."
  :group 'compilation
  :type 'number
  )

(defun hide-compile-buffer-if-successful (buffer string)
  (setq compilation-total-time (time-subtract nil compilation-start-time))
  (setq time-str (concat " (Time: " (format-time-string "%s.%3N" compilation-total-time) "s)"))

  (if
      (with-current-buffer buffer
	(setq warnings (eval compilation-num-warnings-found))
	(setq warnings-str (concat " (Warnings: " (number-to-string warnings) ")"))
	(setq errors (eval compilation-num-errors-found))

	(if (eq errors 0) nil t)
	)

      ;;If Errors then
      (message (concat "Compiled with Errors" warnings-str time-str))

    ;;If Compiled Successfully or with Warnings then
    (progn
      (bury-buffer buffer)
      (run-with-timer auto-hide-compile-buffer-delay nil 'delete-window (get-buffer-window buffer 'visible))
      (message (concat "Compiled Successfully" warnings-str time-str)))))

(make-variable-buffer-local 'compilation-start-time)

(defun compilation-started (proc) 
  (setq compilation-start-time (current-time)))
