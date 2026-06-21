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

(straight-use-package 'use-package)

;; Place this immediately after your straight.el bootstrap block
(use-package project
  :straight t
  :demand t)

;;; --- General Settings ---
(defalias 'yes-or-no-p 'y-or-n-p)
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
(straight-use-package 'magit)

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
  :after evil
  :init
  (evil-collection-init '(dired)))

(with-eval-after-load 'evil-collection
  (evil-collection-define-key 'normal 'dired-mode-map (kbd "o") 'dired-find-file-other-window))

;; 1. Configure Corfu for the completion pop-up interface
(use-package corfu
  :straight t
  ;; Optional: Uses 'child-frames' for cleaner graphics (recommended)
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)                 ;; Enable auto-completion as you type
  (corfu-auto-delay 0.1)         ;; Short delay before pop-up appears (seconds)
  (corfu-auto-prefix 1)          ;; Show suggestions after typing just 1 character
  (corfu-quit-at-boundary 'separator) ;; Handle spacing nicely with Orderless
  (corfu-quit-no-match t)        ;; Close the popup if nothing matches
  :bind
  (:map corfu-map
        ("TAB" . corfu-next)     ;; Use TAB to cycle down choices
        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous) ;; Use Shift+TAB to cycle up
        ([backtab] . corfu-previous)
        ("<return>" . corfu-insert))) ;; Press Enter to commit selection

;; 2. Seamlessly link Eglot and Corfu for C mode
;;;(use-package eglot
;;;  :ensure t
;;;  :hook
;;;  (c-mode . eglot-ensure)        ;; Automatically start Eglot in C files
;;;  :config
;;;  ;; Tell Eglot to feed Corfu high-priority, contextual code data
;;;  (setq-default eglot-workspace-configuration
;;;                '((:clangd . (:completion (:detailedLabel t))))))

;;; --- Completion ---
;;;(use-package company
;;;  :straight t
;;;  :init (global-company-mode)
;;;  :custom
;;;  (company-idle-delay 0.1)
;;;  (company-minimum-prefix-length 1)
;;;  (company-tooltip-limit 10)
;;;  :config
;;;  (add-hook 'eglot-managed-mode-hook
;;;            (lambda ()
;;;              (add-to-list 'company-backends 'company-capf))))

(use-package treemacs
  :straight t
  :defer t
  :config
  (treemacs-git-mode 'simple)
  :bind (:map global-map
              ([f5] . treemacs)))

;;; ==========================================
;;; --- Core Project & File System Settings ---
;;; ==========================================

;; CRITICAL: Block Emacs from watching massive dependency folders globally.
;; This stops Eglot/Project from scanning virtual environments even if Git is missing.
(with-eval-after-load 'vc
  (setq vc-directory-exclusion-list
        (append '("venv" ".venv" "__pycache__" ".pytest_cache" "node_modules" ".git" "build")
                vc-directory-exclusion-list)))

(with-eval-after-load 'project
  (setq project-vc-ignores '("venv/" ".venv/" "__pycache__/" ".pytest_cache/" "build/")))

;;; ==========================================
;;; --- Tree-sitter Configuration ------------
;;; ==========================================

(use-package treesit
  :straight (:type built-in) ; Uses the core Emacs engine
  :config
  ;; Where to save compiled language grammar binaries
  (setq treesit-extra-load-path (list (expand-file-name "tree-sitter" straight-base-dir)))
  
  ;; Maximum syntax highlighting richness (Levels 1 to 4)
  (setq treesit-font-lock-level 4)
  
  ;; Remap legacy major modes to modern Tree-sitter modes automatically
  (setq major-mode-remap-alist
        '((c-mode          . c-ts-mode)
          (c++-mode        . c++-ts-mode)
          (c-or-c++-mode   . c-or-c++-ts-mode)
          (python-mode     . python-ts-mode))))

(use-package treesit-auto
  :straight t
  :after treesit
  :config
  ;; Tells treesit-auto to prompt you to download a parser if it is missing
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode 1)
  
  ;; Sources for the C, C++, and Python grammars
  (setq treesit-language-source-alist
        '((c      "https://github.com/tree-sitter/tree-sitter-c")
          (cpp    "https://github.com/tree-sitter/tree-sitter-cpp")
          (python "https://github.com/tree-sitter/tree-sitter-python"))))

;;; ==========================================
;;; --- Eglot (LSP) Configuration -----------
;;; ==========================================

;;; --- Python Tree-Sitter & Pyright Integration ---

(use-package eglot
  :straight t
  ;; Automatically trigger Eglot whenever a Tree-sitter Python buffer opens
  :hook (python-ts-mode . eglot-ensure)
  :config
  ;; 1. Register pyright-langserver explicitly to python-ts-mode
  (setq eglot-server-programs
        (append '((python-ts-mode . ("pyright-langserver" "--stdio")))
                eglot-server-programs))

  ;; 2. Optimize response times and logging footprints
  (setq eglot-events-buffer-size 0)           ; Save memory bandwidth
  (setq eglot-autoreconnect nil)              ; Disable auto-reconnect to prevent infinite crash-loops
  (setq eglot-max-file-watches 100000)

  ;; 3. Configure Pyright Workspace Options Globally
  (setq-default eglot-workspace-configuration
                '(:python (:analysis (:autoSearchPaths t
						       :useLibraryCodeForTypes t
						       :diagnosticMode "openFilesOnly"
						       :exclude [".venv" "venv" "node_modules"
								 "__pycache__" "build" "dist"])
				     :venvPath "."
				     :venv ".venv"))))


(use-package exec-path-from-shell
  :straight t
  :config
  ;; Force Emacs to copy the exact $PATH variable from your terminal shell
  (exec-path-from-shell-initialize))

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

;;;(use-package smex
;;;  :straight t
;;;  :init
;;;  ;; Smex requires ido to function as its filtering backend
;;;  (ido-mode 1)
;;;  :config
;;;  ;; Initialize Smex command tracking
;;;  (smex-initialize)
;;;  
;;;  ;; Global keybindings to replace standard execution menus
;;;  (global-set-key (kbd "M-x") 'smex)
;;;  (global-set-key (kbd "M-X") 'smex-major-mode-commands))

(use-package amx
  :straight t
  :config
  (amx-initialize)
  (amx-mode 1)
  :bind
  (("M-x" . amx)
   ("M-X" . amx-major-mode-commands)
   ;; To use the traditional, unenhanced Emacs M-x if needed:
   ("C-c C-c M-x" . execute-extended-command)))

;;; --- yasnippet ---

;; Install and configure the core snippet engine
(use-package yasnippet
  :straight t
  :config
  ;; Enable snippets globally across all major modes
  (yas-global-mode 1))

;; Install the community repository of snippets
(use-package yasnippet-snippets
  :straight t
  :after yasnippet
  :config
  ;; Reload all snippet definitions to make sure they are active
  (yas-reload-all))

(add-hook 'c-mode-hook #'hide-ifdef-mode)
(add-hook 'c++-mode-hook #'hide-ifdef-mode)
(add-hook 'c-ts-mode-hook #'hide-ifdef-mode)
(add-hook 'c++-ts-mode-hook #'hide-ifdef-mode)
(add-hook 'verilog-mode-hook #'hide-ifdef-mode)

;;; --- hs-minor-mode: fold #if/#else and #else/#endif as separate regions ---
(defun my-c-hs-forward-sexp (_arg)
  "Navigate past a brace block or preprocessor conditional for hideshow.
Stops at #else/#elif at the current nesting level so each branch
is independently foldable."
  (if (eq (char-before) ?{)
      (progn (backward-char) (forward-sexp))
    (let ((depth 1) done)
      (beginning-of-line 2)
      (while (not done)
        (when (eobp) (error "Unbalanced preprocessor block"))
        (cond
         ((looking-at "[[:space:]]*#[[:space:]]*if")
          (cl-incf depth)
          (forward-line 1))
         ((looking-at "[[:space:]]*\\(#[[:space:]]*endif\\)")
          (cl-decf depth)
          (if (> depth 0)
              (forward-line 1)
            (goto-char (match-end 1))
            (setq done t)))
         ((and (= depth 1)
               (looking-at "[[:space:]]*\\(#[[:space:]]*\\(?:else\\|elif\\)\\)"))
          (goto-char (match-end 1))
          (setq done t))
         (t (forward-line 1)))))))

(defun my-c-hs-init ()
  "Set buffer-local hideshow vars so #if/#else and #else/#endif fold separately.
Runs in C/C++ mode hooks, after hs-minor-mode (prog-mode-hook) has already
called hs-grok-mode-type — so these setq-locals take precedence."
  (setq-local hs-block-start-regexp
              "\\({\\|[[:space:]]*#[[:space:]]*\\(?:if\\|else\\b\\|elif\\b\\)\\)")
  (setq-local hs-block-end-regexp
              "\\(}\\|#[[:space:]]*\\(?:else\\b\\|elif\\b\\|endif\\b\\)\\)")
  (setq-local hs-forward-sexp-func #'my-c-hs-forward-sexp))

(dolist (hook '(c-mode-hook c-ts-mode-hook c++-mode-hook c++-ts-mode-hook))
  (add-hook hook #'my-c-hs-init))

;;; --- compilation no ask ---
(defun my-compile-no-ask ()
  "Compile the project immediately without prompting to save or confirm."
  (interactive)
  (let ((compilation-ask-about-save nil)) ;; Don't ask to save files
    (compile compile-command)))          ;; Run using the last set compile command

(setq display-buffer-alist
      (cons '("\\*compilation\\*"
              (display-buffer-reuse-window display-buffer-below-selected)
              (window-height . 15)) ;; Change 15 to your preferred number of lines
            display-buffer-alist))

(use-package claude-code-ide
  :straight (:type git :host github :repo "manzaltu/claude-code-ide.el")
  :bind ("C-c C-'" . claude-code-ide-menu) ; Set your favorite keybinding
  :config
  (claude-code-ide-emacs-tools-setup)) ; Optionally enable Emacs MCP tools

;;; --- Keybindings ---
(global-set-key (kbd "C-x C-r") 'recentf-open-files)
					;(global-set-key (kbd "<f6>") 'smex)
(global-set-key (kbd "<f6>") 'amx)
					;(global-set-key (kbd "<f7>") 'compile)
(global-set-key (kbd "<f7>") 'my-compile-no-ask)
(global-set-key (kbd "<f9>") 'hs-toggle-hiding)

