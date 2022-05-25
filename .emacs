(setq inhibit-startup-message t)
(windmove-default-keybindings)
;(global-hl-line-mode -1)
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
(menu-bar-mode -1)            ; Disable the menu bar
(defalias 'yes-or-no-p 'y-or-n-p)

(require 'paren)
(setq show-paren-style 'parenthesis)
(show-paren-mode 1)
(when (fboundp 'electric-pair-mode)
  (electric-pair-mode))


;;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
             ("org" . "https://orgmode.org/elpa/")
             ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(dired-listing-switches "-alh --group-directories-first")
 '(ispell-dictionary nil)
 '(package-selected-packages
   '(yaml-mode yaml dired-subtree tabbar dts-mode sr-speedbar markdown-mode smex dashboard text-scale text-scale-mode elpy default-text-scale nyan-mode auto-complete evil yasnippet-snippets yasnippet company-statistics company use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


(use-package company
  :bind (:map company-active-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous))
  :config
  (setq company-idle-delay 0.0)
  (global-company-mode t))

;(use-package company
;  :ensure t
;  :diminish company-mode
;  :commands (company-complete company-mode)
;  :bind (([remap dabbrev-expand] . company-complete)
;     :map prog-mode-map
;     ([tab] . company-indent-or-complete-common))
;  :init (if (fboundp 'evil-declare-chage-repeat)
;        (map #'evil-declare-chage-repeat
;         '(company-complete-common
;           company-select-next
;           company-select-previous
;           company-complete-selection
;           company-complete-number)))
;  :config
;  (use-package company-statistics
;    :ensure t
;    :init
;    (company-statistics-mode))
;  (setq company-idle-delay 0.0)
;  (setq company-show-numbers "on")
;  (add-hook 'prog-mode-hook 'company-mode))

(use-package recentf
  :config
  (setq recentf-auto-cleanup 'never
        recentf-max-saved-items 1000
        recentf-save-file (concat user-emacs-directory ".recentf"))
  (global-set-key "\C-x\ \C-r" 'recentf-open-files)
  (recentf-mode t))

;(use-package smex
;  :ensure t
;  :disabled t
;  :config(setq smex-save-file (concat user-emacs-directory ".smex-items"))
;  (smex-initialize)global
;  :bind
;  ("M-x" . smex))

(require 'smex)
(global-set-key (kbd "<f4>") 'find-file-at-point)
(global-set-key (kbd "<f5>") 'sr-speedbar-toggle)
(global-set-key (kbd "<f6>") 'ibuffer)
(global-set-key (kbd "<f7>") 'smex)
(global-set-key (kbd "<f9>") 'hs-toggle-hiding)
(global-set-key (kbd "M-x") 'smex)
;(global-set-key (kbd "M-x") 'smex-major-mode-commands)

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
  (evil-mode t)
  (evil-set-initial-state 'calendar-mode 'emacs)
  (evil-set-initial-state 'calculator-mode 'emacs)
  (evil-set-initial-state 'git-rebase-mode 'emacs)
  (evil-set-initial-state 'magit-blame-mode 'emacs)
  (setq-default evil-symbol-word-search t))

;(use-package auto-complete-config
;  :ensure auto-complete
;  :bind ("M-<tab>" . my--auto-complete)
;  :init
;  (defun my--auto-complete ()
;    (interactive)
;    (unless (boundp 'auto-complete-mode)
;      (global-auto-complete-mode 1))
;    (auto-complete)))
;(global-auto-complete-mode t)

(use-package nyan-mode
  :config
  (nyan-mode t))

(add-hook 'prog-mode-hook #'hs-minor-mode)

(eval-after-load "dired"
  '(progn
     (define-key dired-mode-map "e" 'ora-ediff-files)))

;; -*- lexical-binding: t -*-
(defun ora-ediff-files ()
  (interactive)
  (let ((files (dired-get-marked-files))
        (wnd (current-window-configuration)))
    (if (<= (length files) 2)
        (let ((file1 (car files))
              (file2 (if (cdr files)
                         (cadr files)
                       (read-file-name
                        "file: "
                        (dired-dwim-target-directory)))))
          (if (file-newer-than-file-p file1 file2)
              (ediff-files file2 file1)
            (ediff-files file1 file2))
          (add-hook 'ediff-after-quit-hook-internal
                    (lambda ()
                      (setq ediff-after-quit-hook-internal nil)
                      (set-window-configuration wnd))))
      (error "no more than 2 files should be marked"))))

;; backup in one place. flat, no tree structure
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))

(setq dired-dwim-target t)

;https://unipro.tistory.com/230
;(use-package elpy
;  :ensure t
;  :config
;  (elpy-enable)
;  (setq elpy-rpc-python-command "python3")
;  (setq elpy-rpc-backend "jedi")
;  (elpy-use-cpython (or (executable-find "python3")
;                        (executable-find "/usr/bin/python3")
;                        (executable-find "/usr/local/bin/python3")
;                        "python3"))
;  ;; (elpy-use-ipython)
;  (setq python-shell-interpreter-args "--simple-prompt -i")
;  (add-hook 'python-mode-hook (lambda ()
;				(setq indent-tabs-mode nil))))

(use-package elpy
  :ensure t
  :config
  (add-hook 'python-mode-hook
	    (lambda ()
		(setq indent-tabs-mode nil)))
  (elpy-enable))

;(use-package default-text-scale
;  :defer 2)

(use-package default-text-scale
  :ensure t
  :config
  (default-text-scale-mode))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))
(global-auto-revert-mode 1)

(global-set-key (kbd "C-=") 'default-text-scale-increase)
(global-set-key (kbd "C--") 'default-text-scale-decrease)

(use-package sr-speedbar
  :ensure t
  :defer t
  :init
;  (setq sr-speedbar-skip-other-window-p t)
  (setq sr-speedbar-right-side nil)
  (setq speedbar-show-unknown-files t)
  (setq sr-speedbar-width 35)
  (setq sr-speedbar-max-width 35)
  (setq speedbar-use-images t)
;  (setq speedbar-initial-expansion-list-name "quick buffers")
  ;(define-key speedbar-mode-map "\M-p" nil)
  ;;(sr-speedbar-open)
  :config
  ;(with-current-buffer sr-speedbar-buffer-name
  ;  (setq window-size-fixed 'width))
  )

(load-theme 'deeper-blue)

(add-to-list 'load-path "~/.emacs.d/plugins/bb-mode/")
(require 'bb-mode)
(setq auto-mode-alist (cons '("\\.bb$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.inc$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.bbappend$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.bbclass$" . bb-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.conf$" . bb-mode) auto-mode-alist))

(use-package tabbar
  :ensure t
  :init
  (tabbar-mode 1)
  :bind
  ("<f2>" . tabbar-backward)
  ("<f3>" . tabbar-forward))

(add-hook 'speedbar-mode-hook
	  (lambda ()
		(setq truncate-lines nill)))

;https://blog.mads-hartmann.com/2016/05/12/emacs-tree-view.html


;(setq frame-title-format
;      '("%b@" (:eval (or (file-remote-p default-directory 'host) system-name)) " — Emacs"))

(setq-default frame-title-format
	      '("%f [%m] @ "
		(:eval (or (file-remote-p default-directory 'host) system-name))))

(use-package yaml-mode
  :mode ("\\.yml$" . yaml-mode))
