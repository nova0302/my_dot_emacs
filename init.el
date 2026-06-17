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

;; Place this immediately after your straight.el bootstrap block
(use-package project
  :straight t
  :demand t)

;;; --- General Settings ---
(desktop-save-mode 1)
(recentf-mode 1)
(electric-pair-mode 1)
(setq dired-dwim-target t)
(setq electric-pair-preserve-balance nil)
(setq recentf-max-saved-items 50)
(setq compilation-ask-about-save nil)
(setq initial-buffer-choice 'recentf-open-files)
(windmove-default-keybindings)
(add-hook 'prog-mode-hook 'hs-minor-mode)

(straight-use-package 'use-package)
;(straight-use-package 'evil)
(straight-use-package 'magit)
;(straight-use-package 'evil-collection)
;(straight-use-package 'company)
(straight-use-package 'treemacs)

;;; --- Evil Mode Configuration with straight.el ---
(use-package evil
  :straight t
  :init
  ;; Pre-emptive configuration variables must be set BEFORE evil loads
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil) ; Crucial for evil-collection compatibility
  (setq evil-symbol-word-search t) ; Makes * and # search look for whole symbols
  
  :config
  ;; Enable Evil globally
  (evil-mode 1)
  
  ;; Custom normal-state keybindings
  (with-eval-after-load 'evil-maps
    (define-key evil-normal-state-map (kbd "M-.") 'xref-find-definitions)))

;;; --- Global Syntax Modifications ---
;; Treat underscores as word characters in code and text modes
(add-hook 'prog-mode-hook
          (lambda () (modify-syntax-entry ?_ "w")))

(add-hook 'text-mode-hook
          (lambda () (modify-syntax-entry ?_ "w")))

(use-package evil-collection
  :straight t
;  :ensure t
  :after evil
  :init
  (evil-collection-init '(dired)))

(with-eval-after-load 'evil-collection
  (evil-collection-define-key 'normal 'dired-mode-map (kbd "o") 'dired-find-file-other-window))


;;; --- Completion ---
(use-package company
  :straight t
;  :ensure t
  :init (global-company-mode)
  :custom
  (company-idle-delay 0.1)
  (company-minimum-prefix-length 1)
  (company-tooltip-limit 10)
  :config
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (add-to-list 'company-backends 'company-capf))))

(use-package treemacs
  :straight t
;  :ensure t
  :defer t
  :config
  (treemacs-git-mode 'simple)
  :bind (:map global-map
              ([f5] . treemacs)))

;;; --- Python ---
(use-package pyvenv
  :straight t
;  :ensure t
  :config
  (pyvenv-mode 1))

;;; --- Tree-sitter ---


;;; --- Built-in Tree-sitter Configuration ---

(use-package treesit
  :straight (:type built-in) ; Explicitly tells straight.el this package is core
  :mode (("\\.cpp\\'" . c++-ts-mode)
         ("\\.hpp\\'" . c++-ts-mode)
         ("\\.c\\'"   . c-ts-mode)
         ("\\.h\\'"   . c-ts-mode))
  :config
  ;; Define where Emacs should look for compiled grammar libraries
  (setq treesit-extra-load-path (list (expand-file-name "tree-sitter" straight-base-dir)))
  
  ;; Control the density of syntax highlighting (Levels 1 to 4)
  (setq treesit-font-lock-level 4))

(use-package treesit-auto
  :straight t
  :after treesit
  :config
  (setq treesit-auto-install 'prompt)
  ;; Automatically use treesit major modes (like python-ts-mode) over legacy modes
  (global-treesit-auto-mode 1)
  
  ;; Optional: Force compile and install all available language grammars on startup
  ;; (treesit-auto-install-all)
  )

(setq treesit-language-source-alist
      '((cpp "https://github.com/tree-sitter/tree-sitter-cpp")
        (c   "https://github.com/tree-sitter/tree-sitter-c")))

(setq treesit-load-name-override-list '((c++ "libtree-sitter-cpp")))

(setq major-mode-remap-alist
      '((c-mode          . c-ts-mode)
        (c++-mode        . c++-ts-mode)
        (c-or-c++-mode   . c-or-c++-ts-mode)
        (python-mode     . python-ts-mode)))

;;; --- Eglot (LSP) ---
(use-package eglot
  :straight t
;  :ensure nil
  :hook ((python-ts-mode . eglot-ensure)
         (c-ts-mode      . eglot-ensure)
         (c++-ts-mode    . eglot-ensure))
  :config
  (dolist (server '(((c-ts-mode c++-ts-mode) . ("clangd" "--header-insertion=never"))
                    (python-mode             . ("pyright-langserver" "--stdio"))))
    (add-to-list 'eglot-server-programs server))
  (setq eglot-events-buffer-size 0)
  (setq-default eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly))

(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "C-c d") #'eglot-find-implementation))

(use-package eldoc-box
  :straight t
  :hook (eglot-managed-mode . eldoc-box-hover-mode))

;;; --- default text scale  ---
(use-package default-text-scale
  :straight t
  :config
  ;; Automatically activate the global minor mode
  (default-text-scale-mode 1)
  
  ;; Bind the scale adjustment keys specifically for Evil Normal State
  (with-eval-after-load 'evil-maps
    (define-key evil-normal-state-map (kbd "C-=") 'default-text-scale-increase)
    (define-key evil-normal-state-map (kbd "C--") 'default-text-scale-decrease)
    (define-key evil-normal-state-map (kbd "C-0") 'default-text-scale-reset)))

;;; --- transpose frame  ---
(use-package transpose-frame
  :straight t
;  :ensure t
  :bind(("C-c f t" . transpose-frame)))

;;; --- Traditional Scala Configuration ---

(use-package scala-mode
  :straight t
  :interpreter ("scala" . scala-mode)
  :config
  ;; Ensure underscores treat as words within Scala buffers as well
  (add-hook 'scala-mode-hook
            (lambda () (modify-syntax-entry ?_ "w"))))

(use-package sbt-mode
  :straight t
  :commands sbt-start sbt-command
  :config
  ;; Settings to handle compiler buffers and ansi colors correctly
  (setq sbt:program-name "sbt"))

(use-package smex
  :straight t
  :init
  ;; Smex requires ido to function as its filtering backend
  (ido-mode 1)
  :config
  ;; Initialize Smex command tracking
  (smex-initialize)
  
  ;; Global keybindings to replace standard execution menus
  (global-set-key (kbd "M-x") 'smex)
  (global-set-key (kbd "M-X") 'smex-major-mode-commands))

;;; --- Keybindings ---
(global-set-key (kbd "C-x C-r") 'recentf-open-files)
;(global-set-key (kbd "<C-tab>") 'tab-line-switch-to-next-tab)
;(global-set-key (kbd "<C-S-iso-lefttab>") 'tab-line-switch-to-prev-tab)
(global-set-key (kbd "<f6>") 'smex)
(global-set-key (kbd "<f7>") 'compile)
(global-set-key (kbd "<f9>") 'hs-toggle-hiding)

