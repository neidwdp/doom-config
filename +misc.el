;;; ~/.doom.d/+misc.el -*- lexical-binding: t; -*-

;; Use chrome to browse
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program
      (cond (IS-MAC "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")
            ((executable-find "/opt/google/chrome/chrome") "/opt/google/chrome/chrome")
            ((executable-find "google-chrome") "google-chrome")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INPUT METHOD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package! rime
  :custom
  (rime-user-data-dir "~/.config/fcitx/rime")
  (default-input-method "rime")
  (rime-show-candidate 'posframe)
  (rime-disable-predicates
   '(rime-predicate-evil-mode-p
     rime-predicate-after-alphabet-char-p
     rime-predicate-prog-in-code-p))
  (rime-inline-ascii-trigger 'shift-l)
  :bind
  ;; C-\ to toggle-input-method
  ;; C-` to toggle
  ;; , and . to page up and down
  (:map rime-mode-map
    ;; open rime menu
    ("C-`" . 'rime-send-keybinding))
  (:map rime-active-mode-map
    ("C-j" . 'rime-inline-ascii)))


(after! doom-modeline
  (set-face-attribute 'rime-indicator-face nil
                      :foreground 'unspecified
                      :inherit 'doom-modeline-buffer-major-mode)
  (set-face-attribute 'rime-indicator-dim-face nil
                      :foreground 'unspecified
                      :inherit 'doom-modeline-buffer-minor-mode)

  (doom-modeline-def-segment input-method
    "Define the current input method properties."
    (propertize (cond (current-input-method
                       (concat (doom-modeline-spc)
                               current-input-method-title
                               (doom-modeline-spc)))
                      ((and (bound-and-true-p evil-local-mode)
                            (bound-and-true-p evil-input-method))
                       (concat
                        (doom-modeline-spc)
                        (nth 3 (assoc default-input-method input-method-alist))
                        (doom-modeline-spc)))
                      (t ""))
                'face (if (doom-modeline--active)
                          (or (get-text-property 0 'face (rime-lighter))
                              'doom-modeline-buffer-major-mode)
                        'mode-line-inactive)
                'help-echo (concat
                            "Current input method: "
                            current-input-method
                            "\n\
mouse-2: Disable input method\n\
mouse-3: Describe current input method")
                'mouse-face 'mode-line-highlight
                'local-map mode-line-input-method-map)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SSH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(make--ssh "argo-desktop" "ztlevi-5820")
(make--shell "argo-desktop" "ztlevi-5820")

(after! ssh-deploy
  (setq ssh-deploy-automatically-detect-remote-changes 1))

(use-package! clipetty
  :defer t
  :unless (display-graphic-p)
  :hook (after-init . global-clipetty-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NAVIGATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq evil-cross-lines t
      evil-split-window-below t
      evil-vsplit-window-right t)

(use-package! evil-nerd-commenter :defer t)


(after! evil
  (evil-define-text-object evil-inner-buffer (count &optional beg end type)
    (list (point-min) (point-max)))
  (define-key evil-inner-text-objects-map "g" 'evil-inner-buffer))


(after! evil-snipe
  (setq evil-snipe-scope 'buffer
        evil-snipe-repeat-scope 'buffer)
  (push 'prodigy-mode evil-snipe-disabled-modes))


(use-package! tmux-pane
  :defer t
  :config
  (defvar my-tmux-pane-mode-map
    (let ((map (make-sparse-keymap)))
      (define-key map (kbd "C-x k")
        (lambda () (interactive) (tmux-pane--windmove "up"  "tmux select-pane -U")))
      (define-key map (kbd "C-x j")
        (lambda () (interactive) (tmux-pane--windmove "down"  "tmux select-pane -D")))
      (define-key map (kbd "C-x h")
        (lambda () (interactive) (tmux-pane--windmove "left" "tmux select-pane -L")))
      (define-key map (kbd "C-x l")
        (lambda () (interactive) (tmux-pane--windmove "right" "tmux select-pane -R")))
      (define-key map (kbd "C-x C-k")
        (lambda () (interactive) (tmux-pane--windmove "up"  "tmux select-pane -U")))
      (define-key map (kbd "C-x C-j")
        (lambda () (interactive) (tmux-pane--windmove "down"  "tmux select-pane -D")))
      (define-key map (kbd "C-x C-h")
        (lambda () (interactive) (tmux-pane--windmove "left" "tmux select-pane -L")))
      (define-key map (kbd "C-x C-l")
        (lambda () (interactive) (tmux-pane--windmove "right" "tmux select-pane -R")))
      map))

  (define-minor-mode my-tmux-pane-mode
    "Seamlessly navigate between tmux pane and emacs window"
    :init-value nil
    :global t
    :keymap 'my-tmux-pane-mode-map)

  :hook (after-init . my-tmux-pane-mode))


(use-package! imenu-list
  :defer t
  :config
  (set-popup-rules! '(("^\\*Ilist\\*" :side right :size 40 :select t))))


(after! nav-flash
  ;; (defun nav-flash-show (&optional pos end-pos face delay)
  ;; ...
  ;; (let ((inhibit-point-motion-hooks t))
  ;; (goto-char pos)
  ;; (beginning-of-visual-line) ; work around args-out-of-range error when the target file is not opened
  (defun +advice/nav-flash-show (orig-fn &rest args)
    (ignore-errors (apply orig-fn args)))
  (advice-add 'nav-flash-show :around #'+advice/nav-flash-show))

;; Use ) key to toggle it
(after! dired
  ;; Rust version ls
  (when-let (exa (executable-find "exa"))
    (setq insert-directory-program exa)
    (setq dired-listing-switches (string-join (list "-ahl" "--group-directories-first") " ")))
  )

(use-package! ranger
  :config
  (setq ranger-hide-cursor t
        ranger-show-hidden 'format
        ranger-deer-show-details nil)

  (defun ranger-copy-relative-path ()
    "Copy the current file path relative to `default-directory path."
    (interactive)
    (let ((current-prefix-arg 1))
      (call-interactively 'dired-copy-filename-as-kill)))

  (defun ranger-close-and-kill-inactive-buffers ()
    "ranger close current buffer and kill inactive ranger buffers"
    (interactive)
    (ranger-close)
    (ranger-kill-buffers-without-window))
  ;; do not kill buffer if exists in windows
  (defun ranger-disable ()
    "Interactively disable ranger-mode."
    (interactive)
    (ranger-revert)))


(after! dash-docs
  (setq dash-docs-use-workaround-for-emacs-bug nil)
  (setq dash-docs-browser-func 'browse-url-generic))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IVY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! ivy
  (after! ivy-prescient
    (setq ivy-prescient-retain-classic-highlighting t)))


(after! ivy-posframe
  ;; Lower internal-border-width on MacOS
  (when IS-MAC
    (setq ivy-posframe-border-width 5))

  ;; Use minibuffer to display ivy functions
  (dolist (fn '(+ivy/switch-workspace-buffer
                ivy-switch-buffer))
    (setf (alist-get fn ivy-posframe-display-functions-alist) #'ivy-display-function-fallback)))


(after! counsel
  (setq counsel-find-file-ignore-regexp "\\(?:^[#.]\\)\\|\\(?:[#~]$\\)\\|\\(?:^Icon?\\)"
        counsel-describe-function-function 'helpful-callable
        counsel-describe-variable-function 'helpful-variable
        counsel-rg-base-command "rg -zS --no-heading --line-number --max-columns 1000 --color never %s ."
        counsel-grep-base-command counsel-rg-base-command))


(use-package! counsel-etags
  :init
  (add-hook 'prog-mode-hook
            (lambda ()
              (add-hook 'after-save-hook
                        'counsel-etags-virtual-update-tags 'append 'local)))
  :config
  (map!
   :nv "ge"  #'counsel-etags-find-tag-at-point)

  (setq counsel-etags-update-interval 60)
  (add-to-list 'counsel-etags-ignore-directories "build"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; QUICKRUN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! quickrun
  ;; quickrun--language-alist
  (when IS-LINUX
    (quickrun-set-default "c++" "c++/g++")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PROJECTILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! projectile
  (setq compilation-read-command nil)   ; no prompt in projectile-compile-project
  ;; . -> Build
  (projectile-register-project-type 'cmake '("CMakeLists.txt")
                                    :configure "cmake %s"
                                    :compile "cmake --build Debug"
                                    :test "ctest")

  ;; set projectile-known-projects after magit
  (after! magit
    (update-projectile-known-projects))
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! git-link
  (setq git-link-open-in-browser t)

  (add-to-list 'git-link-remote-alist
               '("rnd-github-usa-g\\.huawei\\.com" git-link-github-http))
  (add-to-list 'git-link-commit-remote-alist
               '("rnd-github-usa-g\\.huawei\\.com" git-link-commit-github-http))

  ;; OVERRIDE
  (advice-add #'git-link--select-remote :override #'git-link--read-remote)
  )


(after! magit
  (setq magit-repository-directories '(("~/Developer" . 2))
        magit-save-repository-buffers nil
        git-commit-style-convention-checks nil
        magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)

  (magit-wip-after-apply-mode t)
  (magit-wip-before-change-mode t))


;; TEMP: fix github-repository-id is void error
(defalias 'github-repository-id 'ghub-repository-id)

(after! forge
  (push '("github.argo.ai" "github.argo.ai/api/v3"
          "github.argo.ai" forge-github-repository)
        forge-alist)

  ;; TEMP
  ;; (setq ghub-use-workaround-for-emacs-bug 'force)

  (defvar forge-show-all-issues-and-pullreqs t
    "If nil, only show issues and pullreqs assigned to me.")

  (defun +my/forge-toggle-all-issues-and-pullreqs ()
    (interactive)
    (setq forge-insert-default '(forge-insert-pullreqs forge-insert-issues))
    (setq forge-insert-assigned '(forge-insert-assigned-pullreqs forge-insert-assigned-issues))
    (if forge-show-all-issues-and-pullreqs
        (progn
          (setq forge-show-all-issues-and-pullreqs nil)
          (remove-hook! 'magit-status-sections-hook #'forge-insert-issues nil t)
          (remove-hook! 'magit-status-sections-hook #'forge-insert-pullreqs nil t)
          (magit-add-section-hook 'magit-status-sections-hook 'forge-insert-assigned-pullreqs nil t)
          (magit-add-section-hook 'magit-status-sections-hook 'forge-insert-assigned-issues nil t))
      (progn
        (setq forge-show-all-issues-and-pullreqs t)
        (remove-hook! 'magit-status-sections-hook #'forge-insert-assigned-issues nil t)
        (remove-hook! 'magit-status-sections-hook #'forge-insert-assigned-pullreqs nil t)
        (magit-add-section-hook 'magit-status-sections-hook 'forge-insert-pullreqs nil t)
        (magit-add-section-hook 'magit-status-sections-hook 'forge-insert-issues nil t)))

    ;; refresh magit-status buffer
    (magit-refresh))

  ;; Only show issues and pullreqs assigned to me
  (+my/forge-toggle-all-issues-and-pullreqs)
  )


(after! browse-at-remote
  (add-to-list 'browse-at-remote-remote-type-domains '("github.argo.ai" . "github")))


(use-package! magit-todos
  :init
  (setq magit-todos-ignored-keywords nil)
  :config
  (setq magit-todos-exclude-globs '("third-party/*" "third_party/*")))


;; magit-todos uses hl-todo-keywords
(after! hl-todo
  (setq hl-todo-keyword-faces
        `(("TODO"  . ,(face-foreground 'warning))
          ("HACK"  . ,(face-foreground 'warning))
          ("TEMP"  . ,(face-foreground 'warning))
          ("DONE"  . ,(face-foreground 'success))
          ("NOTE"  . ,(face-foreground 'success))
          ("DONT"  . ,(face-foreground 'error))
          ("DEBUG"  . ,(face-foreground 'error))
          ("FAIL"  . ,(face-foreground 'error))
          ("FIXME" . ,(face-foreground 'error))
          ("XXX"   . ,(face-foreground 'error))
          ("XXXX"  . ,(face-foreground 'error)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ATOMIC CHROME
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package! atomic-chrome
  :defer 3
  :preface
  (defun +my/atomic-chrome-server-running-p ()
    (cond ((executable-find "lsof")
           (zerop (call-process "lsof" nil nil nil "-i" ":64292")))
          ((executable-find "netstat")  ; Windows
           (zerop (call-process-shell-command "netstat -aon | grep 64292")))))
  :hook
  (atomic-chrome-edit-mode . +my/atomic-chrome-mode-setup)
  (atomic-chrome-edit-done . +my/window-focus-google-chrome)
  :config
  (progn
    (setq atomic-chrome-buffer-open-style 'full) ;; or frame, split
    (setq atomic-chrome-url-major-mode-alist
          '(("github\\.com"        . gfm-mode)
            ("emacs-china\\.org"   . gfm-mode)
            ("stackexchange\\.com" . gfm-mode)
            ("stackoverflow\\.com" . gfm-mode)
            ("discordapp\\.com"    . gfm-mode)
            ("coderpad\\.io"       . c++-mode)
            ;; jupyter notebook
            ("localhost\\:8888"    . python-mode)
            ("lintcode\\.com"      . python-mode)
            ("leetcode\\.com"      . python-mode)))

    (defun +my/atomic-chrome-mode-setup ()
      (setq header-line-format
            (substitute-command-keys
             "Edit Chrome text area.  Finish \
`\\[atomic-chrome-close-current-buffer]'.")))

    (if (+my/atomic-chrome-server-running-p)
        (message "Can't start atomic-chrome server, because port 64292 is already used")
      (atomic-chrome-start-server))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PRODIGY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after! prodigy
  (set-evil-initial-state!
    '(prodigy-mode)
    'normal)

  (prodigy-define-tag
    :name 'jekyll
    :env '(("LANG" "en_US.UTF-8")
           ("LC_ALL" "en_US.UTF-8")))
  ;; define service
  (prodigy-define-service
    :name "ML Gitbook Publish"
    :command "npm"
    :args '("run" "docs:publish")
    :cwd "~/Developer/Github/Machine_Learning_Questions"
    :tags '(npm gitbook)
    :kill-signal 'sigkill
    :kill-process-buffer-on-stop t)

  (prodigy-define-service
    :name "ML Gitbook Start"
    :command "npm"
    :args '("start")
    :cwd "~/Developer/Github/Machine_Learning_Questions"
    :tags '(npm gitbook)
    :init (lambda () (browse-url "http://localhost:4000"))
    :kill-signal 'sigkill
    :kill-process-buffer-on-stop t)

  (prodigy-define-service
    :name "Hexo Blog Server"
    :command "hexo"
    :args '("server" "-p" "4000")
    :cwd blog-admin-backend-path
    :tags '(hexo server)
    :init (lambda () (browse-url "http://localhost:4000"))
    :kill-signal 'sigkill
    :kill-process-buffer-on-stop t)

  (prodigy-define-service
    :name "Hexo Blog Deploy"
    :command "hexo"
    :args '("deploy" "--generate")
    :cwd blog-admin-backend-path
    :tags '(hexo deploy)
    :kill-signal 'sigkill
    :kill-process-buffer-on-stop t)

  (defun refresh-chrome-current-tab (beg end length-before)
    (call-interactively '+my/browser-refresh--chrome-applescript))
  ;; add watch for prodigy-view-mode buffer change event
  (add-hook 'prodigy-view-mode-hook
            #'(lambda() (set (make-local-variable 'after-change-functions) #'refresh-chrome-current-tab))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TERM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(set-formatter! 'shfmt "shfmt -i=2")

(after! eshell
  ;; eshell-mode imenu index
  (add-hook! 'eshell-mode-hook (setq-local imenu-generic-expression '(("Prompt" " λ \\(.*\\)" 1))))

  (defun eshell/l (&rest args) (eshell/ls "-l" args))
  (defun eshell/e (file) (find-file file))
  (defun eshell/md (dir) (eshell/mkdir dir) (eshell/cd dir))
  (defun eshell/ft (&optional arg) (treemacs arg))

  (defun eshell/up (&optional pattern)
    (let ((p (locate-dominating-file
              (f-parent default-directory)
              (lambda (p)
                (if pattern
                    (string-match-p pattern (f-base p))
                  t)))
             ))
      (eshell/pushd p)))
  )


(after! term
  ;; term-mode imenu index
  (add-hook! 'term-mode-hook (setq-local imenu-generic-expression '(("Prompt" "➜\\(.*\\)" 1)))))


(use-package! vterm-toggle
  :defer t)
