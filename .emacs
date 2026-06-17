;;; --- Package Management ---
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;; Automatically refresh once if a package download fails
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'vc-use-package)
  (package-vc-install "https://github.com/slotThe/vc-use-package"))
(require 'vc-use-package)

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
  :ensure t
  :after evil
  :init
  (evil-collection-init '(dired)))

(with-eval-after-load 'evil-collection
  (evil-collection-define-key 'normal 'dired-mode-map (kbd "o") 'dired-find-file-other-window))

;;; --- Tree-sitter ---
(setq treesit-language-source-alist
      '((cpp "https://github.com/tree-sitter/tree-sitter-cpp")
        (c   "https://github.com/tree-sitter/tree-sitter-c")))

(setq treesit-load-name-override-list '((c++ "libtree-sitter-cpp")))

(setq major-mode-remap-alist
      '((c-mode          . c-ts-mode)
        (c++-mode        . c++-ts-mode)
        (c-or-c++-mode   . c-or-c++-ts-mode)
        (python-mode     . python-ts-mode)))

(use-package treesit-auto
  :ensure t
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))

(use-package treesit
  :ensure nil
  :mode (("\\.cpp\\'" . c++-ts-mode)
         ("\\.hpp\\'" . c++-ts-mode)
         ("\\.c\\'"   . c-ts-mode)
         ("\\.h\\'"   . c-ts-mode))
  :config
  (setq treesit-font-lock-level 4))


;;; --- Eglot (LSP) ---
(use-package eglot
  :ensure nil
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
  :hook (eglot-managed-mode . eldoc-box-hover-mode))


;;; --- Completion ---
(use-package company
  :ensure t
  :init (global-company-mode)
  :custom
  (company-idle-delay 0.1)
  (company-minimum-prefix-length 1)
  (company-tooltip-limit 10)
  :config
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (add-to-list 'company-backends 'company-capf))))


;;; --- Navigation ---
(setq xref-show-definitions-function #'xref-show-definitions-completing-read)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate 1)
(global-set-key (kbd "C-c o") 'ff-find-other-file)

(use-package treemacs
  :ensure t
  :defer t
  :config
  (treemacs-git-mode 'simple)
  :bind (:map global-map
              ([f5] . treemacs)))

;;; --- Python ---
(use-package pyvenv
  :ensure t
  :config
  (pyvenv-mode 1))

;;; --- UI ---
(global-tab-line-mode 1)

;;; --- Claude Code IDE ---
(unless (package-installed-p 'claude-code-ide)
  (package-vc-install "https://github.com/manzaltu/claude-code-ide.el"))

(use-package claude-code-ide
  :ensure nil)
(setq claude-code-ide-model "claude-sonnet-4-6")

(use-package transpose-frame
  :ensure t
  :bind(("C-c f t" . transpose-frame)))

(use-package posframe)

(defun my/treemacs-show-floating-name ()
  "Show the full name of the current Treemacs node in a floating posframe."
  (when (eq major-mode 'treemacs-mode)
    (if-let* ((node (treemacs-node-at-point))
              (name (treemacs-button-get node :label)))
        (posframe-show " *treemacs-floating-name*"
                       :string (propertize (format " %s " name) 'face 'info-title)
                       :position (point)
                       :background-color (face-attribute 'tooltip :background)
                       :foreground-color (face-attribute 'tooltip :foreground)
                       :internal-border-width 1
                       :internal-border-color (face-attribute 'font-lock-comment-face :foreground))
      (posframe-hide " *treemacs-floating-name*"))))

(defun my/treemacs-hide-floating-name ()
  "Hide the Treemacs floating name frame."
  (posframe-hide " *treemacs-floating-name*"))

;; Hook into Treemacs to track cursor movement
(add-hook 'treemacs-mode-hook
          (lambda ()
            (add-hook 'post-command-hook #'my/treemacs-show-floating-name nil t)
            (add-hook 'focus-out-hook #'my/treemacs-hide-floating-name nil t)))

;;; --- Keybindings ---
(global-set-key (kbd "C-x C-r") 'recentf-open-files)
(global-set-key (kbd "<C-tab>") 'tab-line-switch-to-next-tab)
(global-set-key (kbd "<C-S-iso-lefttab>") 'tab-line-switch-to-prev-tab)
(global-set-key (kbd "<f6>") 'smex)
(global-set-key (kbd "<f7>") 'compile)
(global-set-key (kbd "<f9>") 'hs-toggle-hiding)


;;; --- Custom (managed by Emacs) ---
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(evil-symbol-word-search t)
 '(package-selected-packages
   '(all-the-icons-dired all-the-icons-ibuffer all-the-icons-ivy bicycle
			 cape claude-code claude-code-ide company
			 corfu dash default-text-scale dts-mode
			 dumb-jump ein eldoc-box elpy evil-collection
			 evil-mc exec-path-from-shell f ggtags
			 golden-ratio helm highlight-numbers
			 highlight-symbol idle-highlight-mode
			 imenu-list indent-bars lsp-mode lsp-ui
			 multiple-cursors nyan-mode orderless
			 org-bullets origami resize-window s
			 scala-mode shackle smex sr-speedbar tabbar
			 transpose-frame tree-sitter
			 treemacs-all-the-icons treemacs-evil
			 treemacs-icons-dired treemacs-magit
			 treemacs-persp treemacs-projectile
			 treemacs-tab-bar treesit-auto use-package
			 vc-use-package yasnippet-snippets ztree))
 '(package-vc-selected-packages
   '((claude-code-ide :vc-backend Git :url
		      "https://github.com/manzaltu/claude-code-ide.el")
     (vc-use-package :vc-backend Git :url
		     "https://github.com/slotThe/vc-use-package"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
