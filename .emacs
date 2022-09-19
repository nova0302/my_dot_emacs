(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(dired-listing-switches "-alh --group-directories-first")
 '(ispell-dictionary nil)
 '(package-selected-packages
   '(company-tabnine lsp-ui lsp-mode flycheck exec-path-from-shell kotlin-mode doxy-graph-mode highlight-doxygen cmake-mode counsel ag projectile resize-window ggtags dts magit dired-toggle-sudo sudo-edit sudo-save yaml-mode yaml dired-subtree tabbar dts-mode sr-speedbar markdown-mode smex dashboard text-scale text-scale-mode elpy default-text-scale nyan-mode auto-complete evil yasnippet-snippets yasnippet company-statistics company use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(setq user-full-name "Sanglae Kim"
      user-mail-address "nova0302@hotmail.com")
(setq compilation-ask-about-save nil)
(setq delete-by-moving-to-trash t
      trash-directory "~/.Trash/")
;
;
;; finally, I got this option on...no more M+x toggle-truncate-longlines
(set-default 'truncate-lines t)
;
;; with trailing whitespace, Makefile drive me crazy
(add-hook 'prog-mode-hook
	  (lambda ()
	    (setq show-trailing-whitespace t)))
;
;;(setq-default show-trailing-whitespace nil)
;
(setq inhibit-startup-message t)
;
(windmove-default-keybindings)
;
;;(global-hl-line-mode -1)
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
(menu-bar-mode -1)            ; Disable the menu bar
(defalias 'yes-or-no-p 'y-or-n-p)
;
(require 'paren)
(setq show-paren-style 'parenthesis)
(show-paren-mode 1)
(when (fboundp 'electric-pair-mode)
  (electric-pair-mode))
;
;
;;;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
             ("org" . "https://orgmode.org/elpa/")
             ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))
;
;;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(setq use-package-always-ensure t)


(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))
;
;(use-package company
;  :bind (:map company-active-map
;          ("C-n" . company-select-next)
;          ("C-p" . company-select-previous))
;  :config
;  (setq company-idle-delay 0.0)
;  (global-company-mode t))
;
(setq vc-follow-symlinks nil)
;
(use-package recentf
  :config
  (setq recentf-auto-cleanup 'never
        recentf-max-saved-items 1000
        recentf-save-file (concat user-emacs-directory ".recentf"))
  (global-set-key "\C-x\ \C-r" 'recentf-open-files)
  (recentf-mode t))
;
(use-package smex
  :ensure t
  :bind (("M-x" . smex))
  :config (smex-initialize))

(use-package ggtags
  :config
  (add-hook 'c-mode-hook
	    (lambda ()
	      (ggtags-mode t)))
  (add-hook 'c-mode-common-hook
	    (lambda ()
	      (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
		(ggtags-mode t)))))
;
(require 'flymake)

(use-package yasnippet
  :ensure t
  :init
  (yas-global-mode 1)
  :config
  (use-package yasnippet-snippets
    :ensure t)
  (yas-reload-all))

(use-package evil
  :ensure t
  :init
  (setq evil-want-C-d-scroll t)
  :config
  ;(modify-syntax-entry ?_ "w")
  (evil-mode t)
  (evil-set-initial-state 'calendar-mode 'emacs)
  (evil-set-initial-state 'calculator-mode 'emacs)
  (evil-set-initial-state 'git-rebase-mode 'emacs)
  (evil-set-initial-state 'magit-blame-mode 'emacs)
  (setq-default evil-symbol-word-search t))

;(modify-syntax-entry ?_ "w")
(define-key evil-normal-state-map (kbd "C-]")'ggtags-find-tag-dwim)
(define-key evil-insert-state-map (kbd "C-/") 'completion-at-point)
;
;(add-hook 'after-change-major-mode-hook
;          (lambda ()
;            (modify-syntax-entry ?_ "w")))
;
;
;;(use-package auto-complete-config
;;  :ensure auto-complete
;;  :bind ("M-<tab>" . my--auto-complete)
;;  :init
;;  (defun my--auto-complete ()
;;    (interactive)
;;    (unless (boundp 'auto-complete-mode)
;;      (global-auto-complete-mode 1))
;;    (auto-complete)))
;;(global-auto-complete-mode t)
;
(use-package nyan-mode
  :config
  (nyan-mode t))
;
(add-hook 'prog-mode-hook #'hs-minor-mode)
;
;(eval-after-load "dired"
;  '(progn
;     (define-key dired-mode-map "e" 'ora-ediff-files)))
;
;;; -*- lexical-binding: t -*-
;(defun ora-ediff-files ()
;  (interactive)
;  (let ((files (dired-get-marked-files))
;        (wnd (current-window-configuration)))
;    (if (<= (length files) 2)
;        (let ((file1 (car files))
;              (file2 (if (cdr files)
;                         (cadr files)
;                       (read-file-name
;                        "file: "
;                        (dired-dwim-target-directory)))))
;          (if (file-newer-than-file-p file1 file2)
;              (ediff-files file2 file1)
;            (ediff-files file1 file2))
;          (add-hook 'ediff-after-quit-hook-internal
;                    (lambda ()
;                      (setq ediff-after-quit-hook-internal nil)
;                      (set-window-configuration wnd))))
;      (error "no more than 2 files should be marked"))))
;
;;; backup in one place. flat, no tree structure
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))
;
(setq dired-dwim-target t)
;
;;https://unipro.tistory.com/230
;;(use-package elpy
;;  :ensure t
;;  :config
;;  (elpy-enable)
;;  (setq elpy-rpc-python-command "python3")
;;  (setq elpy-rpc-backend "jedi")
;;  (elpy-use-cpython (or (executable-find "python3")
;;                        (executable-find "/usr/bin/python3")
;;                        (executable-find "/usr/local/bin/python3")
;;                        "python3"))
;;  ;; (elpy-use-ipython)
;;  (setq python-shell-interpreter-args "--simple-prompt -i")
;;  (add-hook 'python-mode-hook (lambda ()
;;				(setq indent-tabs-mode nil))))
;
;;(use-package elpy
;;  :ensure t
;;  :config
;;  (add-hook 'python-mode-hook
;;	    (lambda ()
;;		(setq indent-tabs-mode nil)))
;;  (elpy-enable))
;
;;(use-package default-text-scale
;;  :defer 2)
;
(use-package default-text-scale
  :ensure t
  :config
  (default-text-scale-mode))
;
;;(use-package dashboard
;;  :ensure t
;;  :config
;;  (dashboard-setup-startup-hook))
;;(global-auto-revert-mode 1)
;
(global-set-key (kbd "C-+") 'default-text-scale-increase)
(global-set-key (kbd "C--") 'default-text-scale-decrease)
;
;;(use-package sr-speedbar
;;  :ensure t
;;  :defer t
;;  :init
;;;  (setq sr-speedbar-skip-other-window-p t)
;;  (setq sr-speedbar-right-side nil)
;;  (setq speedbar-show-unknown-files t)
;;  (setq sr-speedbar-width 35)
;;  (setq sr-speedbar-max-width 35)
;;  (setq speedbar-use-images t)
;;;  (setq speedbar-initial-expansion-list-name "quick buffers")
;;  ;(define-key speedbar-mode-map "\M-p" nil)
;;  ;;(sr-speedbar-open)
;;  :config
;;  ;(with-current-buffer sr-speedbar-buffer-name
;;  ;  (setq window-size-fixed 'width))
;;  )
;(require 'sr-speedbar)
;  (setq sr-speedbar-right-side nil)
;  (setq speedbar-show-unknown-files t)
;  (setq sr-speedbar-width 35)
;  (setq sr-speedbar-max-width 35)
;  (setq speedbar-use-images t)
;
(load-theme 'deeper-blue)
;
;(add-to-list 'load-path "~/.emacs.d/plugins/bb-mode/")
;(require 'bb-mode)
;(setq auto-mode-alist (cons '("\\.bb$" . bb-mode) auto-mode-alist))
;(setq auto-mode-alist (cons '("\\.inc$" . bb-mode) auto-mode-alist))
;(setq auto-mode-alist (cons '("\\.bbappend$" . bb-mode) auto-mode-alist))
;(setq auto-mode-alist (cons '("\\.bbclass$" . bb-mode) auto-mode-alist))
;(setq auto-mode-alist (cons '("\\.conf$" . bb-mode) auto-mode-alist))
;
;(setq auto-mode-alist (cons '("\\.ino$" . c++-mode) auto-mode-alist))
;
;(use-package tabbar
;  :ensure t
;  :init
;  (tabbar-mode 1)
;  :bind
;  ("<f2>" . tabbar-backward)
;  ("<f3>" . tabbar-forward))
;
;(add-hook 'speedbar-mode-hook
;	  (lambda ()
;		(setq truncate-lines nill)))
;
;;https://blog.mads-hartmann.com/2016/05/12/emacs-tree-view.html
;
;
;;(setq frame-title-format
;;      '("%b@" (:eval (or (file-remote-p default-directory 'host) system-name)) " — Emacs"))
;
;(setq-default frame-title-format
;	      '("%f [%m] @ "
;		(:eval (or (file-remote-p default-directory 'host) system-name))))
;
;(use-package yaml-mode
;  :mode ("\\.yml$" . yaml-mode))
;
;(use-package rst
;  :mode (("\\.txt$" . rst-mode)
;         ("\\.rst$" . rst-mode)
;         ("\\.rest$" . rst-mode)))
;
;(use-package transpose-frame
;  :ensure t)
;
;(use-package sudo-edit
;  :ensure t)
;
;;https://menno.io/posts/use-package/
;(use-package magit
;  :init
;  (message "Loading Magit!")
;  :config
;  (message "Loaded Magit!")
;  :bind (("C-x g" . magit-status)
;         ("C-x C-g" . magit-status)))
;
;;(use-package projectile
;;  :ensure t
;;  :init
;;  (projectile-mode +1)
;;  :bind (:map projectile-mode-map
;;              ("s-p" . projectile-command-map)
;;              ("C-c p" . projectile-command-map)))
;
;;(use-package counsel
;;  :ensure t)
;;
;;(use-package ivy
;;  :ensure t
;;  :config
;;  (setq ivy-use-virtual-buffers t)
;;  (setq enable-recursive-minibuffers t)
;;  ;; enable this if you want `swiper' to use it
;;  ;; (setq search-default-mode #'char-fold-to-regexp)
;;  (global-set-key "\C-s" 'swiper)
;;  (global-set-key (kbd "C-c C-r") 'ivy-resume)
;;  (global-set-key (kbd "<f6>") 'ivy-resume)
;;  (global-set-key (kbd "M-x") 'counsel-M-x)
;;  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
;;;  (global-set-key (kbd "<f1> f") 'counsel-describe-function)
;;;  (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
;;;  (global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
;;;  (global-set-key (kbd "<f1> l") 'counsel-find-library)
;;;  (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
;;;  (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
;;  (global-set-key (kbd "C-c g") 'counsel-git)
;;  (global-set-key (kbd "C-c j") 'counsel-git-grep)
;;  (global-set-key (kbd "C-c k") 'counsel-ag)
;;  (global-set-key (kbd "C-x l") 'counsel-locate)
;;  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
;;  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history))
;;
(global-set-key (kbd "<f4>") 'find-file-at-point)
(global-set-key (kbd "<f5>") 'dired)
;(global-set-key (kbd "<f5>") 'sr-speedbar-toggle)
(global-set-key (kbd "<f6>") 'ibuffer)
(global-set-key (kbd "<f7>") 'smex)
(global-set-key (kbd "<f8>") 'compile)
(global-set-key (kbd "<f9>") 'hs-toggle-hiding)
(global-set-key (kbd "<f10>") 'sr-speedbar-toggle)
;(global-set-key (kbd "<f10>") 'transpose-frame)
(global-set-key (kbd "<f12>") 'hs-hide-level)
;(global-set-key (kbd "<f12>") 'resize-window)
(global-set-key (kbd "M-x") 'smex)
;(global-set-key (kbd "M-<down>") 'enlarge-window)
;
;(put 'scroll-left 'disabled nil)
;
;(setq ibuffer-saved-filter-groups
;      (quote (("default"
;	       ("dired" (mode . dired-mode))
;	       ("perl" (mode . cperl-mode))
;	       ("erc" (mode . erc-mode))
;	       ("planner" (or
;			   (name . "^\\*Calendar\\*$")
;			   (name . "^diary$")
;			   (mode . muse-mode)))
;	       ("emacs" (or
;			 (name . "^\\*scratch\\*$")
;			 (name . "^\\*Messages\\*$")))
;	       ("svg" (name . "\\.svg")) ; group by file extension
;	       ("gnus" (or
;			(mode . message-mode)
;			(mode . bbdb-mode)
;			(mode . mail-mode)
;			(mode . gnus-group-mode)
;			(mode . gnus-summary-mode)
;			(mode . gnus-article-mode)
;			(name . "^\\.bbdb$")
;			(name . "^\\.newsrc-dribble")))))))
;
;
;(add-hook 'ibuffer-mode-hook
;	  (lambda ()
;	    (ibuffer-switch-to-saved-filter-groups "default")))
;
;
;
;;; Enable ibuffer-filter-by-filename to filter on directory names too.
;(eval-after-load "ibuf-ext"
;  '(define-ibuffer-filter filename
;       "Toggle current view to buffers with file or directory name matching QUALIFIER."
;     (:description "filename"
;		   :reader (read-from-minibuffer "Filter by file/directory name (regexp): "))
;     (ibuffer-awhen (or (buffer-local-value 'buffer-file-name buf)
;			(buffer-local-value 'dired-directory buf))
;		    (string-match qualifier it))))
;
;(setq desktop-path '("~/.emacs.d/"))
;(desktop-save-mode t)
;
;(defun my-c-mode-font-lock-if0 (limit)
;  (save-restriction
;    (widen)
;    (save-excursion
;      (goto-char (point-min))
;      (let ((depth 0) str start start-depth)
;        (while (re-search-forward "^\s-*#\s-*\(if\|else\|endif\)" limit 'move)
;          (setq str (match-string 1))
;          (if (string= str "if")
;              (progn
;                (setq depth (1+ depth))
;                (when (and (null start) (looking-at "\s-+0"))
;                  (setq start (match-end 0)
;                        start-depth depth)))
;            (when (and start (= depth start-depth))
;              (c-put-font-lock-face start (match-beginning 0) 'font-lock-comment-face)
;              (setq start nil))
;            (when (string= str "endif")
;              (setq depth (1- depth)))))
;        (when (and start (> depth 0))
;          (c-put-font-lock-face start (point) 'font-lock-comment-face)))))
;  nil)
;
;(defun my-c-mode-common-hook ()
;  (font-lock-add-keywords
;   nil
;   '((my-c-mode-font-lock-if0 (0 font-lock-comment-face prepend))) 'add-to-end))
;
;(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
;
;
;
;
;(defun my-cpp-highlight ()
;  "highlight c/c++ #if 0 #endif macros"
;  ;; (interactive)
;  (setq cpp-known-face 'default)
;  (setq cpp-unknown-face 'default)
;  (setq cpp-known-writable 't)
;  (setq cpp-unknown-writable 't)
;  (setq cpp-edit-list '(("0" font-lock-comment-face default both)
;                        ("1" default font-lock-comment-face both)))
;  (cpp-highlight-buffer t))
;
;(add-hook 'c-mode-common-hook 'my-cpp-highlight)
;
;;;;; colorize output in compile buffer
;(require 'ansi-color)
;(defun colorize-compilation-buffer ()
;  (ansi-color-apply-on-region compilation-filter-start (point-max)))
;
;(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)
;
;(set-language-environment "Korean")
;(prefer-coding-system 'utf-8)
;(set-file-name-coding-system 'cp949-dos)
;(set-default-coding-systems 'utf-8)
;(set-language-environment "UTF-8")
;


(use-package exec-path-from-shell
   :init
   (when (memq window-system '(mac ns x))
     (exec-path-from-shell-initialize)))

;; Red lines and similar below syntax errors to make them visible
(use-package flycheck)

(use-package lsp-mode)

;; helper boxes and other nice functionality (for other servers like the jdt one for Java, whit include Javadoc popups)
(use-package lsp-ui)

;; I use Kotlin mode, not perfect, but works. Just start LSP when Kotlin mode starts.
;; hook keyword replaces (add-to-list 'kotlin-mode-hook 'lsp)
;; You can omit the hook and start lsp manually with M-x lsp if you want.
(use-package kotlin-mode
  :hook
  (kotlin-mode . lsp))


(use-package company
  :ensure t
  :diminish company-mode
  :commands (company-complete company-mode)
  :bind (([remap dabbrev-expand] . company-complete)
     :map prog-mode-map
     ([tab] . company-indent-or-complete-common))
  :init (if (fboundp 'evil-declare-chage-repeat)
        (map #'evil-declare-chage-repeat
         '(company-complete-common
           company-select-next
           company-select-previous
           company-complete-selection
           company-complete-number)))
  :config
  (use-package company-statistics
    :ensure t
    :init
    (company-statistics-mode))
  (setq company-idle-delay 0.0)
  (setq company-show-numbers "on")
  (add-hook 'prog-mode-hook 'company-mode))


;(use-package company
;  :init
;  (global-company-mode)
;
;  ;; set the completion to begin at once. Not needed, but handy!
;  (setq company-idle-delay 0
;	company-echo-delay 0
;	company-minimum-prefix-length 1)
;
;  ;; Not strictly necessary. Just gives a hotkey to complete when it doesnt start automatically
;  :bind
;  ([(control return)] . company-complete))

(use-package company-tabnine :ensure t)
(add-to-list 'company-backends #'company-tabnine)
