(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(dired-listing-switches "-alh --group-directories-first")
 '(ispell-dictionary nil)
 '(package-selected-packages
   '(counsel ag projectile resize-window ggtags dts magit dired-toggle-sudo sudo-edit sudo-save yaml-mode yaml dired-subtree tabbar dts-mode sr-speedbar markdown-mode smex dashboard text-scale text-scale-mode elpy default-text-scale nyan-mode auto-complete evil yasnippet-snippets yasnippet company-statistics company use-package)))
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


(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

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
  (modify-syntax-entry ?_ "w")
  (evil-mode t)
  (evil-set-initial-state 'calendar-mode 'emacs)
  (evil-set-initial-state 'calculator-mode 'emacs)
  (evil-set-initial-state 'git-rebase-mode 'emacs)
  (evil-set-initial-state 'magit-blame-mode 'emacs)
  (setq-default evil-symbol-word-search t))

(define-key evil-normal-state-map (kbd "C-]")'ggtags-find-tag-dwim)
(define-key evil-insert-state-map (kbd "C-/") 'completion-at-point)



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

(global-set-key (kbd "C-+") 'default-text-scale-increase)
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

(use-package rst
  :mode (("\\.txt$" . rst-mode)
         ("\\.rst$" . rst-mode)
         ("\\.rest$" . rst-mode)))

(use-package transpose-frame
  :ensure t)

(use-package sudo-edit
  :ensure t)

;https://menno.io/posts/use-package/
(use-package magit
  :init
  (message "Loading Magit!")
  :config
  (message "Loaded Magit!")
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-status)))

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))

;(use-package counsel
;  :ensure t)
;
;(use-package ivy
;  :ensure t
;  :config
;  (setq ivy-use-virtual-buffers t)
;  (setq enable-recursive-minibuffers t)
;  ;; enable this if you want `swiper' to use it
;  ;; (setq search-default-mode #'char-fold-to-regexp)
;  (global-set-key "\C-s" 'swiper)
;  (global-set-key (kbd "C-c C-r") 'ivy-resume)
;  (global-set-key (kbd "<f6>") 'ivy-resume)
;  (global-set-key (kbd "M-x") 'counsel-M-x)
;  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
;;  (global-set-key (kbd "<f1> f") 'counsel-describe-function)
;;  (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
;;  (global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
;;  (global-set-key (kbd "<f1> l") 'counsel-find-library)
;;  (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
;;  (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
;  (global-set-key (kbd "C-c g") 'counsel-git)
;  (global-set-key (kbd "C-c j") 'counsel-git-grep)
;  (global-set-key (kbd "C-c k") 'counsel-ag)
;  (global-set-key (kbd "C-x l") 'counsel-locate)
;  (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
;  (define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history))
;
(global-set-key (kbd "<f4>") 'find-file-at-point)
(global-set-key (kbd "<f5>") 'dired)
;(global-set-key (kbd "<f5>") 'sr-speedbar-toggle)
(global-set-key (kbd "<f6>") 'ibuffer)
(global-set-key (kbd "<f7>") 'smex)
(global-set-key (kbd "<f8>") 'compile)
(global-set-key (kbd "<f9>") 'hs-toggle-hiding)
(global-set-key (kbd "<f10>") 'transpose-frame)
(global-set-key (kbd "<f12>") 'hs-hide-level)
;(global-set-key (kbd "<f12>") 'resize-window)
(global-set-key (kbd "M-x") 'smex)
;(global-set-key (kbd "M-<down>") 'enlarge-window)

(put 'scroll-left 'disabled nil)



