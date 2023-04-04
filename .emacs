(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
;;; '(company-backends
;;;   '(company-bbdb company-semantic company-cmake company-capf company-files
;;;		  (company-dabbrev-code company-gtags company-etags company-keywords)
;;;		  company-oddmuse company-dabbrev))
 '(package-selected-packages
   '(dired+ dts yasnippet-snippets yaml-mode use-package transpose-frame tabbar sudo-edit sr-speedbar smex resize-window projectile nyan-mode magit lsp-ui kotlin-mode highlight-doxygen ggtags flycheck exec-path-from-shell evil elpy dts-mode doxy-graph-mode dired-toggle-sudo default-text-scale dashboard counsel company-tabnine company-statistics cmake-mode ag)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


(require 'package)
;(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;;(add-to-list 'package-archives '("MELPA Stable" . "https://stable.melpa.org/packages/") t)

(package-initialize)

(setq byte-compile-warning '(cl-functions))

(setq dired-dwim-target t)
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
(menu-bar-mode -1)            ; Disable the menu bar
(defalias 'yes-or-no-p 'y-or-n-p)

(setq user-full-name "Sanglae Kim"
      user-mail-address "nova0302@hotmail.com")

(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))

(setq compilation-ask-about-save nil)
(setq delete-by-moving-to-trash t
      trash-directory "~/.Trash/")

(set-default 'truncate-lines t)
(setq inhibit-startup-message t)

(use-package recentf
  :config
  (setq recentf-auto-cleanup 'never
	recentf-max-saved-items 1000
	recentf-save-file (concat user-emacs-directory ".recentf"))
  (global-set-key "\C-x\ \C-r" 'recentf-open-files)
  (recentf-mode t))

;(use-package flycheck
;  :ensure t
;  :init
;  (add-hook 'prog-mode-hook 'flycheck-mode))

(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :commands flycheck-mode
  :init (global-flycheck-mode)
  :config
  (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled)
        flycheck-idle-change-delay 5.0))




(use-package dts-mode :ensure t)

(setq compilation-ask-about-save nil)
(set-default 'truncate-lines t)
(windmove-default-keybindings)

(when (fboundp 'electric-pair-mode)
  (electric-pair-mode))


(use-package company
  :ensure t
  :init
  (add-hook 'after-init-hook 'global-company-mode)
  :config
  (setq company-idle-delay 0)
  (setq company-show-numbers "on"))


;;;;(use-package company
;;;;  :ensure t
;;;;  :diminish company-mode
;;;;  :commands (company-complete company-mode)
;;;;;  :bind (([remap dabbrev-expand] . company-complete)
;;;;;	 :map prog-mode-map
;;;;;	 ([tab] . company-indent-or-complete-common))
;;;;  :init (if (fboundp 'evil-declare-chage-repeat)
;;;;	    (map #'evil-declare-chage-repeat
;;;;		 '(company-complete-common
;;;;		   company-select-next
;;;;		   company-select-previous
;;;;		   company-complete-selection
;;;;		   company-complete-number)))
;;;;  :config
;;;;  (use-package company-statistics
;;;;    :ensure t
;;;;    :init
;;;;    (company-statistics-mode))
;;;;  (setq company-idle-delay 0.0)
;;;;  (add-hook 'prog-mode-hook 'company-mode))
;;;;
(use-package company-tabnine :ensure t)
(add-to-list 'company-backends #'company-tabnine)
;;;;(setq company-show-quick-access t)
(add-hook 'after-init-hook 'global-company-mode)

(use-package evil
  :ensure t
  :init
  (setq evil-want-C-d-scroll t)
  :config
					;(modify-syntax-entry ?_ "w")
  (evil-mode t)
  (evil-set-initial-state 'calculator-mode 'emacs)
  (evil-set-initial-state 'git-rebase-mode 'emacs)
  (evil-set-initial-state 'magit-blame-mode 'emacs)
  (setq-default evil-symbol-word-search t))

(add-hook 'prog-mode-hook #'hs-minor-mode)

;(load-theme 'deeper-blue)
;(load-theme 'manoj-dark)
(load-theme 'misterioso)

(use-package default-text-scale
  :ensure t
  :config
  (default-text-scale-mode))
					;(global-set-key (kbd "C-+") 'default-text-scale-increase)
(global-set-key (kbd "C-=") 'default-text-scale-increase)
(global-set-key (kbd "C--") 'default-text-scale-decrease)

(require 'flymake)

(add-hook 'prog-mode-hook
	  (lambda ()
	    (setq show-trailing-whitespace t)))

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

(use-package yasnippet
  :ensure t
  :init
  (yas-global-mode 1)
  :config
  (use-package yasnippet-snippets
    :ensure t)
  (yas-reload-all))

(use-package nyan-mode
  :config
  (nyan-mode t))

(add-hook 'prog-mode-hook #'hs-minor-mode)

(setq dired-listing-switches "-alh --group-directories-first")

(setq desktop-path '("~/.emacs.d/"))

(desktop-save-mode t)

(use-package tabbar
  :ensure t
  :init
  (tabbar-mode 1)
  :bind
  ("<f2>" . tabbar-backward)
  ("<f3>" . tabbar-forward))

;;https://stackoverflow.com/questions/443302/emacs-how-to-compile-run-make-without-pressing-enter-for-the-compile-command
;(setq compilation-read-command nil)

(global-set-key (kbd "<f4>") 'find-file-at-point)
(global-set-key (kbd "<f5>") 'dired)
(global-set-key (kbd "<f6>") 'smex)
(global-set-key (kbd "<f7>") 'recompile)
(global-set-key (kbd "<f8>") 'compile)
(global-set-key (kbd "<f9>") 'hs-toggle-hiding)
(global-set-key (kbd "<f11>") 'resize-window)
(global-set-key (kbd "<f12>") 'hs-hide-level)
					;(global-set-key (kbd "TAB") 'hippie-expand)


					;(add-to-list 'load-path "~/.emacs.d/plugins/jdee-2.4.1/lisp")
					;(load "jde")
(use-package sr-speedbar
  :ensure t
  :defer t
  :init
  (setq sr-speedbar-right-side nil)
  (setq speedbar-show-unknown-files t)
  (setq sr-speedbar-width 35)
  (setq sr-speedbar-max-width 35)
  (setq speedbar-use-images nil)
					;(setq speedbar-initial-expansion-list-name "quick buffers")
  (sr-speedbar-open)
  (with-current-buffer sr-speedbar-buffer-name
    (setq window-size-fixed 'width))
  (define-key speedbar-mode-map "\M-p" nil))

(add-hook 'dired-mode-hook 'auto-revert-mode)

(setq auto-mode-alist (cons '("\\.\\(pde\\|ino\\)$" . c++-mode) auto-mode-alist))

;(add-to-list 'load-path "~/.emacs.d/vendor/arduino-mode")
;(setq auto-mode-alist (cons '("\\.\\(pde\\|ino\\)$" . arduino-mode) auto-mode-alist))
;(autoload 'arduino-mode "arduino-mode" "Arduino editing mode." t)

(setq ibuffer-saved-filter-groups
      (quote (("default"
	       ("dired" (mode . dired-mode))
	       ("perl" (mode . cperl-mode))
	       ("erc" (mode . erc-mode))
	       ("planner" (or
			   (name . "^\\*Calendar\\*$")
			   (name . "^diary$")
			   (mode . muse-mode)))
	       ("emacs" (or
			 (name . "^\\*scratch\\*$")
			 (name . "^\\*Messages\\*$")))
	       ("svg" (name . "\\.svg")) ; group by file extension
	       ("gnus" (or
			(mode . message-mode)
			(mode . bbdb-mode)
			(mode . mail-mode)
			(mode . gnus-group-mode)
			(mode . gnus-summary-mode)
			(mode . gnus-article-mode)
			(name . "^\\.bbdb$")
			(name . "^\\.newsrc-dribble")))))))
(add-hook 'ibuffer-mode-hook
	  (lambda ()
	    (ibuffer-switch-to-saved-filter-groups "default")))

;; Use human readable Size column instead of original one
(define-ibuffer-column size-h
  (:name "Size" :inline t)
  (cond
   ((> (buffer-size) 1000000) (format "%7.1fM" (/ (buffer-size) 1000000.0)))
   ((> (buffer-size) 100000) (format "%7.0fk" (/ (buffer-size) 1000.0)))
   ((> (buffer-size) 1000) (format "%7.1fk" (/ (buffer-size) 1000.0)))
   (t (format "%8d" (buffer-size)))))

;; Modify the default ibuffer-formats
(setq ibuffer-formats
      '((mark modified read-only " "
	      (name 18 18 :left :elide)
	      " "
	      (size-h 9 -1 :right)
	      " "
	      (mode 16 16 :left :elide)
	      " "
	      filename-and-process)))

;; Enable ibuffer-filter-by-filename to filter on directory names too.
(eval-after-load "ibuf-ext"
  '(define-ibuffer-filter filename
       "Toggle current view to buffers with file or directory name matching QUALIFIER."
     (:description "filename"
		   :reader (read-from-minibuffer "Filter by file/directory name (regexp): "))
     (ibuffer-awhen (or (buffer-local-value 'buffer-file-name buf)
			(buffer-local-value 'dired-directory buf))
       (string-match qualifier it))))

; from enberg on #emacs
(add-hook 'compilation-finish-functions
  (lambda (buf str)
    (if (null (string-match ".*exited abnormally.*" str))
        ;;no errors, make the compilation window go away in a few seconds
        (progn
          (run-at-time
           "5 sec" nil 'delete-windows-on
           (get-buffer-create "*compilation*"))
          (message "No Compilation Errors!")))))
