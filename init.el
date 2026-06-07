;;; init.el --- Emacs 31 Modern Native Intellisense Configuration -*- lexical-binding: t; -*-

;; =============================================================================
;; 1. BOOTSTRAP PACKAGE MANAGER (straight.el)
;; =============================================================================
(setq package-enable-at-startup nil)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Integrate straight.el natively into use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t) ; Eliminates the need to type :straight t on every package

;; =============================================================================
;; 2. CLEAN USER INTERFACE & GENERAL CONFIGURATION
;; =============================================================================
(set-face-attribute 'default nil 
                    :font "DejaVu Sans Mono"
                    :height 150 
                    :weight 'regular)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(load-theme 'misterioso t)

(setq inhibit-startup-screen t)
(setq make-backup-files nil)
(setq dired-dwim-target t)

(recentf-mode t)
(desktop-save-mode 1)

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))

;; Code folding initialization
(add-hook 'prog-mode-hook 'hs-minor-mode)

;; =============================================================================
;; 3. NATIVE CODE INTERPRETATION (Tree-sitter)
;; =============================================================================
(use-package treesit
  :straight (:type built-in)
  :config
  ;; Correct full URLs for automated compilation via `M-x treesit-install-language-grammar`
  (setq treesit-language-source-alist
        '((bash "https://github.com")
          (cmake "https://github.com")
          (css "https://github.com")
          (elisp "https://github.com")
          (go "https://github.com")
          (html "https://github.com")
          (javascript "https://github.com" "master" "src")
          (json "https://github.com")
          (make "https://github.com")
          (markdown "https://github.com" "main" "tree-sitter-markdown/src")
          (python "https://github.com")
          (rust "https://github.com")
          (toml "https://github.com")
          (tsx "https://github.com" "master" "tsx/src")
          (typescript "https://github.com" "master" "typescript/src")
          (yaml "https://github.com")))

  ;; Automatically remap standard programming modes to their modern Tree-sitter counterparts
  (setq major-mode-remap-alist
        '((bash-mode . bash-ts-mode)
          (c-mode . c-ts-mode)
          (c++-mode . c++-ts-mode)
          (cmake-mode . cmake-ts-mode)
          (python-mode . python-ts-mode))))

;; =============================================================================
;; 4. CORE ENGINE COMPLETION & INTELLISENSE (Eglot, Corfu, Orderless)
;; =============================================================================
(use-package eglot
  :straight (:type built-in)
  :hook
  ((python-ts-mode . eglot-ensure)
   (c-ts-mode . eglot-ensure)
   (c++-ts-mode . eglot-ensure))
  :bind
  (:map eglot-mode-map
        ("M-." . xref-find-definitions)
        ("M-," . xref-go-back)
        ("C-c c r" . eglot-rename)
        ("C-c c a" . eglot-code-actions)
        ("C-c c f" . eglot-format-buffer))
  :config
  (setq eglot-autoshutdown t)
  (setq eglot-events-buffer-size 0))

(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  :bind
  (:map corfu-map
        ("TAB" . corfu-next)
        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous)
        ("RET" . corfu-insert)))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package yasnippet
  :config
  (yas-global-mode 1))

;; =============================================================================
;; 5. NAVIGATION & KEYBOARD CONTROL (Evil Mode, Smex, Projectile)
;; =============================================================================
(use-package undo-fu)

(use-package evil
  :demand t
  :init
  (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode 1)
  ;; Restore native LSP jump points inside Evil State if you choose to uncomment them
  (with-eval-after-load 'eglot
    (with-eval-after-load 'evil
      (evil-define-key 'normal eglot-mode-map
        (kbd "gd") 'xref-find-definitions
        (kbd "gD") 'xref-find-definitions-other-window
        (kbd "C-t") 'xref-pop-marker-stack))))

(use-package smex
  :init
  (smex-initialize)
  :bind
  (("M-x" . smex)
   ("M-X" . smex-major-mode-commands)
   ("C-c C-c M-x" . execute-extended-command)))

(use-package projectile
  :init
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map))

(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-status))
  :config
  ;; Optional: If you want Magit to play nicely with Evil keys
  ;; (straight-use-package 'evil-collection)
  )
;; =============================================================================
;; 6. TRANSIENT WIDGET INTERFACES (Hydra)
;; =============================================================================
(use-package hydra)

(defhydra hydra-zoom (:color red :hint nil)
  "
  Zoom: _g_/_+_ (In)  _l_/_-_ (Out)  _r_/_0_ (Reset)  _q_ (Quit)
  "
  ("g" global-text-scale-adjust "in")
  ("+" global-text-scale-adjust)
  ("l" (global-text-scale-adjust -1) "out")
  ("-" (global-text-scale-adjust -1))
  ("r" (global-text-scale-adjust 0) "reset")
  ("0" (global-text-scale-adjust 0))
  ("q" nil "quit" :exit t))

;; =============================================================================
;; 7. GLOBAL CORE KEYBINDINGS
;; =============================================================================
(global-set-key (kbd "<f4>") 'hydra-zoom/body)
(global-set-key (kbd "<f5>") 'dired)
(global-set-key (kbd "<f6>") 'smex)
(global-set-key (kbd "<f7>") 'compile)
(global-set-key (kbd "<f9>") 'hs-toggle-hiding)
