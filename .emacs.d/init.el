(setq installing-package-list
  '(
    color-theme
    color-theme-monokai
    elscreen
    evil
    evil-leader
    evil-numbers
    evil-paredit
    goto-chg
    helm
    htmlize
    melpa
    paredit
    paredit-menu
    powerline
    redo+
    surround
    undo-tree
    window-number
    smooth-scroll
    e2wm
    multiple-cursors
    clojure-mode
    ))

;; goto-last-change.el
; (global-set-key (kbd "C-;") 'goto-last-change)
; (global-set-key (kbd "C-,") 'goto-last-change-reverse)

;; TODO goto-last-change.elとgoto-chg.elの関数名がかぶっている？
;; goto-chg.elの方が高機能そう?

(require 'cl)
(server-start)
;; (toggle-debug-on-error)

;; environment variable
(setenv "PCTYPE" (if (string-match "2a07" (or (getenv "PROCESSOR_REVISION") "")) "work" "home"))
(setenv "TMP" (or (getenv "TMP") "/tmp"))
(setenv "DROPBOX_PATH" (or (getenv "DROPBOX_PATH") (expand-file-name "~/Dropbox")))
(setenv "bk" "\"c:/Program Files/Git/bin/sh.exe\" --login -c \"$DROPBOX_PATH/home/tools/hg-backup.sh\"")

;; key mapping prefix
(define-prefix-command 'my-qfix-prefix)
(define-prefix-command 'my-anything-prefix)
(define-prefix-command 'evil-mapleader)
(global-set-key "\C-\\" 'my-anything-prefix)

;; backup
(add-to-list 'backup-directory-alist
      (cons "." "~/tmp/emacs/"))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/tmp/emacs/") t)))

;; load-path
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

(add-to-load-path "public_repos") ; "elisp" "auto-install")

;; ---------------------------------------------------------------------
;; package manager
;; ELPA
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)
(require 'melpa nil t)

(defun myinstall ()
  (interactive)
  ;; http://qiita.com/items/5f1cd86e2522fd3384a0
  (let ((not-installed (loop for x in installing-package-list
                             when (not (package-installed-p x))
                             collect x)))
    (when not-installed
      (package-refresh-contents)
      (dolist (pkg not-installed)
        (package-install pkg)))))

; auto-install
; ;; まず、install-elisp のコマンドを使える様にします。
; (require 'install-elisp)
; ;; 次に、Elisp ファイルをインストールする場所を指定します。
; (setq install-elisp-repository-directory "~/.emacs.d/elisp/")

; ;; auto-install
; (require 'auto-install)
; (add-to-list 'load-path auto-install-directory)
; ;; (auto-install-update-emacswiki-package-name t)
; (auto-install-compatibility-setup)


;; GUI
(when window-system
  (tool-bar-mode 0)
  (toggle-scroll-bar t))

(add-hook 'input-method-activate-hook
             (lambda() (set-cursor-color "green")))
(add-hook 'input-method-inactivate-hook
      (lambda() (set-cursor-color "white")))


;; language
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)

(when (eq window-system 'w32)
  (set-file-name-coding-system 'cp932)
  (setq locale-coding-system 'cp932)
  (setq default-process-coding-system '(cp932 . cp932)))


;; windows {{{
(when (eq window-system 'w32)

(setenv "LANG" "ja")
(setenv "RUBYOPT" "-Ku")

;; http://d.hatena.ne.jp/khiker/20090711/emacsfullscreen
;; (set-frame-parameter nil 'fullscreen 'maximized)
(set-frame-parameter nil 'alpha 96)

;; font
;; (face-attribute 'default :fontset)
;; http://d.hatena.ne.jp/setoryohei/20110117/1295336454
;; http://dukeiizu.blogspot.jp/2011/07/emacs-ricty.html
;; (set-face-attribute 'default nil :height 50 :family "MeiryoKe_Console")
;; (set-face-attribute 'default nil :height 118 :family "Inconsolata")
;; (set-face-attribute 'default nil :height 100 :family "Source Code Pro")
;; (set-face-attribute 'default nil :height 116 :family "Migu 1M regular")
(set-face-attribute 'default nil :height 110 :family "Consolas")
(set-fontset-font nil 'japanese-jisx0208
                  nil)
                  ;; (font-spec :family "Migu 1M regular" :size 16))
                  ;; (font-spec :family "Meiryo" :size 16))
                  ;; (font-spec :family "MeiryoKe_Gothic" :size 8))
                  ;; (font-spec :family "MeiryoKe_Console" :size 8))
;; (set-fontset-font nil 'japanese-jisx0208 nil)
;; (setq face-font-rescale-alist '())
;; (add-to-list 'face-font-rescale-alist '("Migu 1M regular" . 1.1))
;; (add-to-list 'face-font-rescale-alist '("Meiryo" . 2.0))

;; env-path
; http://sakito.jp/emacs/emacsshell.html#path
;; より下に記述した物が PATH の先頭に追加されます
(dolist (dir (list
              ;; (expand-file-name "~/.emacs.d/bin")
              "C:\\Python27"
              "C:\\Python27\\Scripts"
              "C:\\Ruby200\\bin"
              "C:\\MinGW\\bin"              ; for gcc command
              "C:\\MinGW\\msys\\1.0\\bin"   ; for make command
              "C:\\Program Files\\Git\\bin" ; for grep command
              ;; "C:\\Program Files\\Microsoft F#\\v4.0"
              ;; "C:\\Program Files\\FSharp-2.0.0.0\\bin"
              (expand-file-name (substitute-in-file-name "$DROPBOX_PATH\\windows\\software\\bin"))
              ;; (expand-file-name (substitute-in-file-name "$DROPBOX_PATH\\home\\tools"))
              ))
  ;; PATH と exec-path に同じ物を追加します
  (when ;; (and
      (file-exists-p dir) ;; (not (member dir exec-path)))
    (setenv "PATH" (concat dir
                           (if (eq window-system 'w32) ";" ":")
                           (getenv "PATH")))
    (setq exec-path (append (list dir) exec-path))))

;; http://arunrocks.com/blog/2008/06/10/emacs-tip-a-key-to-open-the-current-folder-in-windows/#.UOt7Mkfwi30
;;; Windows explorer to open current file - Arun Ravindran
(defun explorer ()
  "Launch the windows explorer in the current directory and selects current file"
  (interactive)
  (w32-shell-execute "open" "explorer" (concat "/e,/select," (convert-standard-filename buffer-file-name))))

(defun tortoisehg-file-command (command)
  (start-process-shell-command "" nil (concat "thg " command " " (buffer-file-name))))

(defun extshell ()
  (interactive)
  (start-process-shell-command "" nil "ckw -e nyaos"))

;; Sublime Text 2
(defun launch-sublime-text ()
  (interactive)
  (start-process-shell-command
   "" nil
   (concat
    "\"" (expand-file-name (substitute-in-file-name "$PROGRAMFILES\\Sublime Text 2\\sublime_text.exe")) "\""
    " " (buffer-file-name) ":" (number-to-string (line-number-at-pos)))))

;; Vim
(defun launch-gvim ()
                  (interactive)
                  (start-process-shell-command
                   "" nil
                   (concat
                    (expand-file-name (substitute-in-file-name "$DROPBOX_PATH\\windows\\software\\vim73-kaoriya-win32\\gvim.exe"))
                    " --remote-silent +" (number-to-string (line-number-at-pos)) " " (buffer-file-name))))

(defun growl-notify (message)
  (start-process-shell-command
   "" nil
   (concat
    "\"" (expand-file-name (substitute-in-file-name "$PROGRAMFILES\\Growl for Windows\\growlnotify.exe")) "\""
    " /i:" (expand-file-name (substitute-in-file-name "$DROPBOX_PATH\\home\\.vim\\gomi\\icons\\df_project_icons\\PNG\\Calendar.png"))
    " /s:true"
    " /t:org-mode"
    " " message)))

(global-set-key (kbd "C-S-x") 'explorer) ; alt+shift+x には割り当て不可
(global-set-key (kbd "C-S-t") 'extshell)
(global-set-key (kbd "M-S-z") 'launch-sublime-text)
(global-set-key "\M-z" 'launch-gvim)

)
;; windows }}}

(define-key my-anything-prefix "\C-s" 'eval-buffer)
(define-key lisp-mode-shared-map (kbd "C-c C-e") 'eval-last-sexp)

;; Utility for org-babel
(defun transpose (m)
  (apply #'mapcar* #'list m))
(defun zip-streams (&rest streams)
  (apply #'smapcar* #'list streams))
(defun string-quote (str)
  (concat "\"" str "\""))
(defun slice (str beg end)
  (let ((len (length str)))
    (substring str (min index len) (min (+ index size) len))))

(defun average (&rest values)
  (/ (apply '+ values) (length values)))

;; データソースをテーブルに出力するための関数
(list
 (defun babel-table (lines columns)
   "org-table用にフォーマットする"
   (let ((titles (car (transpose (cddr columns))))
         (result (babel-split lines (cddr columns))))
     (transpose (append result (list titles)))))

 (defun babel-column-quote (str)
   (if (or (string-match "^[ ]+$" str)
           (string-match "\\." str))
   ;; (if (string-match "^ +\| +$" str)
       (string-quote str)
     str))

 (defun babel-split-column (line columns)
   "columnsで与えられたインデックス毎に文字列を分割する"
   (defun babel-split-column-rec (col index)
     (if (not col)
         nil
       (let* ((info (car col))          ; col[0]
              (size (cadr info))        ; col[0][1]
              (space (caddr info))      ; col[0][2]
              (text (slice line index (+ index size))))
              ;; (text (substring line index (+ index size))))
         (cons (babel-column-quote text)
               (babel-split-column-rec (cdr col) (+ index size space))))))
   (babel-split-column-rec columns 0))

 (defun babel-split (lines columns)
   (defun babel-split-rec (lines)
     (if (not lines)
         nil
       (cons (babel-split-column (car lines) columns)
             (babel-split-rec (cdr lines)))))
   (babel-split-rec lines))

 ;; test
 (babel-split-column "  " '(("" 2 1))) ; #=> ()
 (babel-split-column "aa bbb" '(("a" 2 1) ("b" 3 1))) ; #=> ("aa" "bbb")
 (babel-split '("aa bbb") '(("a" 2 1) ("b" 3 1))) ; #=> (("aa" "bbb"))

 ; example
 ; #+tblname: text1
 ; |       | サイズ | スペース | 開始位置 |
 ; |-------+--------+----------+----------|
 ; | text1 |      4 |        1 |        0 |
 ; | text2 |     10 |        1 |        5 |
 ; | text3 |     11 |        1 |       16 |
 ; #+TBLFM: $4=vsum(@2$2..$3) - vsum($2, $3)
 ;
 ; #+name: text1-input
 ; #+begin_src emacs-lisp
 ; '(
 ; "0000 2012"
 ; )
 ; #+end_src
 ;
 ; #+BEGIN_SRC emacs-lisp :var columns=text1 :var row=3 :var lines=text1-input
 ; (babel-table lines columns)
 ; #+END_SRC
 )


;; paren-mode
;; (setq show-paren-display 0)
(show-paren-mode t)
(setq show-paren-style 'parenthesis) ;; 'expression)
;; (set-face-background 'show-paren-match-face nil)
;; (set-face-underline-p 'show-paren-match-face "yellow")

;; appearance
(setq-default tab-width 4)
(setq-default tab-stop-list (number-sequence 4 100 4))
(setq-default indent-tabs-mode nil)
(column-number-mode t)
;; (global-linum-mode 0)
;; (global-hl-line-mode t)

;; http://d.hatena.ne.jp/tarao/20130304/evil_config#vim-eof
(setq indicate-empty-lines t)
(setq indicate-buffer-boundaries 'left)

;; 行末の空白を強調表示
(setq-default show-trailing-whitespace t)
;; TODO 全角空白・タブ文字の強調表示

(global-whitespace-mode 1)
;; (setq whitespace-style '(face tabs spaces trailing lines space-before-tab newline indentation empty space-after-tab space-mark tab-mark newline-mark))
(setq whitespace-style '(face tabs trailing space-before-tab newline space-after-tab tab-mark))

;; behaviour
(defalias 'yes-or-no-p 'y-or-n-p)
(require 'uniquify)
;; http://stackoverflow.com/questions/5748814/how-does-one-disable-vc-git-in-emacs
(setq vc-handled-backends ())

(setq require-final-newline t)

(electric-pair-mode t)
(global-auto-revert-mode)
(setq-default save-place t)
(require 'saveplace)

;; http://www.emacswiki.org/DeskTop
(desktop-save-mode 1)
;; (setq desktop-files-not-to-save "[^o][^r][^g]$")
(setq desktop-files-not-to-save "[^o][^r][^!]$")
;; (defadvice ad-desktop-save-buffer-p (after desktop-save-buffer-p activate)
;;   (let* ((filename (ad-get-arg 0))
;;          (to-save (string-match "\\.el$" filename)))
;;     (setq ad-return-value (or ad-return-value (not to-save)))))

;; scroll
(setq scroll-conservatively 1)
;; (setq scroll-margin 3) ;; evilのH/Lでスクロールしてしまう
;; (setq next-screen-context-lines 1)


;; recentf
(when (require 'recentf nil t)
  (setq recentf-max-saved-items 2000)
  (setq recentf-exclude '(".recentf"))
  ;; (setq recentf-auto-cleanup 10)
  (setq recentf-auto-save-timer
        (run-with-idle-timer 300 t 'recentf-save-list))
  (recentf-mode 1))

;; search
(setq-default case-fold-search t)
(setq-default case-replace nil)
;; tag-jump
(setq tags-case-fold-search nil)

;; cua-mode
(cua-mode t)
(setq cua-enable-cua-keys nil)

;; comment-out
(setq comment-empty-lines t)
(setq comment-column 48)


;; key mapping
(global-set-key (kbd "C-m") 'comment-indent-new-line)
;; (global-set-key (kbd "C-h") 'delete-backward-char)
(keyboard-translate ?\C-h ?\C-?)

(global-set-key (kbd "M-p") 'previous-error)
(global-set-key (kbd "M-n") 'next-error)

(global-set-key (kbd "M-g M-n") 'menu-bar-next-tag)
;; (define-key evil-normal-state-map (kbd "C-w C-]") 'find-tag-other-window)

(global-set-key "\C-]" 'find-tag)
(global-set-key "\C-t" 'pop-tag-mark)

;; http://d.hatena.ne.jp/yutoichinohe/20120912/1347446231
(ffap-bindings)
(setq ff-search-directories '("./" "../*" "../../*"))
(global-set-key "\M-o" 'ff-find-other-file)
(global-set-key "\C-^" (lambda () (interactive) (switch-to-buffer (other-buffer))))

;; http://d.hatena.ne.jp/kitokitoki/20100327/p1
;; (eval-after-load "anything"
;;   '(define-key anything-map (kbd "C-h") 'delete-backward-char))
; (define-key minibuffer-local-map "\C-w" 'backward-kill-word)

;; text key-mapping
(global-set-key "\M-~" '(lambda () (interactive) (insert "～")))
; (global-set-key "\M-+" '(lambda () (interactive) (insert "/*  */") (backward-char 3)))

;; yank した瞬間にインデントする
;; http://d.hatena.ne.jp/yascentur/20120228/1330355171

;; http://d.hatena.ne.jp/khiker/20061126/1164564817
;; 矩形選択はevilとemacs標準のどちらを使えばよいか？

;; grep
(when (and (executable-find "grep") (require 'igrep nil t)) ; required grep command on exec-path
  (setq igrep-options "--no-messages")
  (define-key my-qfix-prefix (kbd "e") 'igrep)
  (define-key my-qfix-prefix (kbd "f") 'igrep) ; TODO fgrepが存在しない
  (define-key my-qfix-prefix (kbd "r e") 'rgrep)
  (define-key my-qfix-prefix (kbd "r f") 'rgrep)
  )

;; ---------------------------------------------------------------------
(when (require 'helm-config nil t)
  (setq helm-input-idle-delay 0.1)
  (setq helm-quick-update t)
  (setq helm-candidate-number-limit 100)
  ;; (setq helm-split-window-default-side 'right)
  (setq helm-ff-toggle-auto-update nil)
  (setq helm-ff-transformer-show-only-basename t)

  ;; http://fukuyama.co/nonexpansion
  (custom-set-variables '(helm-ff-auto-update-initial-value nil))

  ; (global-set-key "\C-xx" 'helm-swap-windows)
  (global-set-key "\C-@" 'helm-for-files)
  (global-set-key "\M-x" 'helm-M-x)
  (global-set-key "\M-y" 'helm-show-kill-ring)
  (global-set-key "\M-r" 'helm-semantic-or-imenu)
  (global-set-key (kbd "C-:") 'helm-occur)
  (define-key my-anything-prefix "f" 'helm-find-files)

  ;; disable anything in minibuffer
  ; (add-hook 'minibuffer-setup-hook
  ;        (lambda ()
  ;        ; (turn-off-evil-mode)
  ;        (define-key anything-map (kbd "C-h") 'delete-backward-char)
  ;        (define-key anything-map (kbd "C-w") 'backward-kill-word)
  ;        ))
  )

;; http://d.hatena.ne.jp/sky-y/20120805/1344165096
;; (require 'misc)


;; calendar
;; http://stuff.mit.edu:8001/afs/athena.mit.edu/contrib/xemacs/OldFiles/share/2006-12-21/xemacs-packages/lisp/calendar/cal-japanese.el
;; (defvar calendar-japanese-day-names
;;   ["日" "月" "火" "水" "木" "金" "土"]
;;   "Japanese shortened week day names.")
;; (defvar calendar-japanese-month-names
;;   ["1月" "2月" "3月" "4月" "5月" "6月"
;;    "7月" "8月" "9月" "10月" "11月" "12月"]
;;   "Japanese month names.")
;; (setq calendar-day-name-array calendar-japanese-day-names)
;; (setq calendar-month-name-array calendar-japanese-month-names)

; ;; TODO http://d.hatena.ne.jp/TakashiHattori/20120627/1340768058
; ;; howm-mode
; (when (require 'howm nil t)
;   (add-to-list 'auto-mode-alist '("\\.howm$" . howm-mode))
;   (add-to-list 'auto-mode-alist '("note/.+\\.txt$" . org-mode))
;   (setq howm-view-title-header "*")
;   (setq howm-template "* %title%cursor\n") ; タイムスタンプは付加しない
;   )

;; org-mode
(require 'org)
(require 'org-habit)
(add-to-list 'auto-mode-alist '("eva/.+\\.txt$" . org-mode))
(setq org-return-follows-link t)
;; (org-remember-insinuate)
(setq org-log-done 'time)

;; (setq org-startup-folded nil)
(setq org-enforce-todo-dependencies t)
;; (setq org-enforce-todo-checkbox-dependencies t)
(setq org-src-fontify-natively t)

;; org-babel
(eval-after-load "org"
  '(progn
     (require 'ob-sh)
     (require 'ob-C)
     (require 'ob-python)
     (when (and (require 'org-export-diag nil t) (eq window-system 'w32))
       (defadvice myad-org-export-blocks-format-diag (around org-export-blocks-format-diag (&rest args) activate)
         (apply 'org-export-blocks-format-diag (append args '("-f C:\\Windows\\Fonts\\meiryo.ttc")))))
     ))

(setq org-use-fast-tag-selection t)
(setq org-todo-keywords
      '(
        (sequence "TODO(t)" "|" "DONE(x)" "CANCEL(c)" "WAITING(w)")
        (sequence "ASK(a)" "EVA(e)" "SOMEDAY(s)" "TODO(t)" "|" "DONE(x)")))


;; TODO http://d.hatena.ne.jp/TakashiHattori/20120627/1340768058
;; http://howm.sourceforge.jp/cgi-bin/hiki/hiki.cgi?FAQ.0

;; org-mode directory
(setenv "NOTEDIR" (substitute-in-file-name "$DROPBOX_PATH/note"))
(setenv "NOTEHOME" (substitute-in-file-name "$DROPBOX_PATH/unsync1/note"))

;; .txt: HTMLへ変換して、Evernoteへインポートするファイル
;; .org: インポートしないファイル
;; YYYY-mm-000000.org howm/Note/1day
;; YYYY-mm-HHMMSS.org org/Draft/1title
;; YYYY-mm-000000.txt org/Inbox/1day

;; note file path
(setq howm-file-name-format "%Y-%m/%Y-%m-%d-%H%M%S.org") ; Note or Draft?
(setq howm-directory (substitute-in-file-name "$NOTEDIR/howm"))
(setq org-directory  (substitute-in-file-name "$NOTEDIR/org"))
(setq org-default-notes-file (expand-file-name "agenda.org" org-directory))

(setq org-agenda-files '())             ; must unique
(dolist (dir (split-string (substitute-in-file-name "$PROJECTPATH") ";"))
  (add-to-list 'org-agenda-files dir))
(add-to-list 'org-agenda-files org-directory)
(add-to-list 'org-agenda-files (substitute-in-file-name "$NOTEHOME/org"))
(setq org-agenda-files
      (loop for x in org-agenda-files
            if (file-exists-p x) collect x)) ; filter

(defun my-note-date (fmt)
  (expand-file-name
   (format-time-string fmt (current-time))
   howm-directory))

;; http://orgmode.org/manual/Template-expansion.html#Template-expansion
;; http://skalldan.wordpress.com/2011/07/16/%E8%89%B2%E3%80%85-org-capture-%E3%81%99%E3%82%8B-2/
(setq org-capture-templates
      '(
        ;; ("c" "Agenda" entry (file+datetree (format-time-string "%Y-%m-agenda.org" (current-time)))
        ("t" "Todo"     entry (file+datetree "agenda.org") "* TODO %?")
        ("c" "Agenda"   entry (file+datetree "agenda.org") "* TODO %?\n SCHEDULED: %t")
        ("n" "Now"      entry (file+datetree "agenda.org") "* TODO [#A] %?\n SCHEDULED: %T")
        ("d" "Deadline" entry (file+datetree "agenda.org") "* TODO %?\n DEADLINE: %t")
        ("l" "List"     entry (file+datetree "agenda.org") "* TODO [/]\n SCHEDULED: %t\n - [ ] %?")
        ("D" "Draft"    entry (file (my-note-date "%Y-%m/%Y-%m-%d-%H%M%S.org")) "* %?") ; org/Draft/1entry
        ("N" "Note"     entry (file (my-note-date "%Y-%m/%Y-%m-%d-000000.org")) "* %?") ; howm/Note/1day
        ("i" "Inbox"    entry (file (my-note-date "%Y-%m/%Y-%m-%d-000000.txt")) "* %?") ; org/Inbox/1day
        ("m" "Menu Index"   entry (file+headline "index.org" "Menu") "* TODO %?\n SCHEDULED: %t")
        ("s" "Sublime Text" entry (file+datetree "SublimeText.org") "* TODO [#C] %?")
        ("S" "Sublime Tips" entry (file+headline "SublimeText.org" "Tips") "* TODO %?")
        ("P" "Sublime Packages" entry (file+headline "SublimeText.org" "Packages") "* TODO %?")
        ("C" "Clock"    entry (clock) "* TODO %?\n SCHEDULED: %t")
        ("p" "Project"  entry (file+datetree (substitute-in-file-name "$PROJECTFILE")) "* TODO %?\n SCHEDULED: %T")
        ("h" "Home"     entry (file+datetree (substitute-in-file-name "$NOTEHOME/org/home.org")) "* TODO %?\n SCHEDULED: %t")
        ("w" "Work"   entry (file+datetree "work.org") "* TODO %?\n SCHEDULED: %t")
        ))

(setq org-agenda-persistent-filter t)
(setq org-agenda-tag-filter '("-ST"))
;; ;; (org-agenda-filter-show-all-cat)
;; (when (not (file-exists-p (substitute-in-file-name "$DROPBOX_PATH/unsync1/note")))
;;  (setq org-agenda-tag-filter-preset '("-:ST:"))
;;   (setq org-agenda-category-filter-preset '("-SublimeText")))


;; org-agenda
;; http://d.hatena.ne.jp/t0m0_tomo/20091229/1262082716
(setq org-agenda-skip-deadline-if-done t)
(setq org-agenda-skip-scheduled-if-done t)
;; (setq org-agenda-restore-windows-after-quit t)
(setq org-agenda-todo-ignore-with-date t)
(setq org-agenda-skip-scheduled-if-deadline-is-shown t)
(setq org-agenda-skip-additional-timestamps-same-entry t)
(setq org-agenda-repeating-timestamp-show-all nil) ; 繰り返しの予定は2回目以降を表示しない
;; org-agendaに表示する期間
;; (setq org-agenda-span 'month)

;; org-export-icalendar
;; (setq org-combined-agenda-icalendar-file (expand-file-name "agenda-view.ics" org-directory))
(setq org-combined-agenda-icalendar-file (substitute-in-file-name "$DROPBOX_PATH/unsync1/note/agenda.ics"))
(setq org-icalendar-include-todo nil)
(setq org-icalendar-use-deadline '(event-if-todo event-if-not-todo))
(setq org-icalendar-use-scheduled '(event-if-todo event-if-not-todo))

;; org-agenda-view
;; http://orgmode.org/manual/Exporting-Agenda-Views.html
(setq org-agenda-custom-commands
      '(("X" agenda "" nil ("~/../agenda-view.html"))
        ("w" agenda "" ((org-agenda-category-filter '("-SublimeText"))))
        ("a" agenda "" ((org-agenda-category-filter '("-agenda" "-SublimeText"))))
        ("x" "Unscheduled TODO" tags-todo "-SCHEDULED>=\"<now>\"" nil)
        ))

;; http://orgmode.org/manual/Exporting-Agenda-Views.html#fn-4
(defadvice org-store-agenda-views (around org-store-agenda-views-arround activate)
  ;; (my-org-export-as-html-with-buffer "index.org")
  (my-agenda-view-export))

(defun my-agenda-view-export ()
  ;; export agenda to agenda-view.html
  (eval '(org-batch-store-agenda-views
          org-agenda-category-filter nil
          org-agenda-span (quote month)
          )))


;; org-export-html
;; http://nak2k.jp/pnote/emacs/org-mode/settings.html
(setq org-export-html-coding-system 'utf-8)
;; (setq org-export-html-preamble nil)
(setq org-export-html-postamble nil)    ; 著者名等は不要
;; (setq org-export-preserve-breaks t) ; or #+OPTIONS: \n:t
(setq org-export-with-tags nil)
;; (setq org-export-with-emphasize nil)
(setq org-export-with-sub-superscripts nil)
;; (setq org-fontify-emphasized-text nil)

(setq org-export-html-toplevel-hlevel 1) ; <h1>

;; html-style
(setq org-export-html-style "
<style type=\"text/css\">
 <!--/*--><![CDATA[/*><!--*/
       // html { font-family: sans-serif; font-size: 12pt; }
       html { font-family: MeiryoKe_UIGothic; }
  /*]]>*/-->
</style>")

;; Add "Mark of the Web"
(setq org-export-html-xml-declaration "<?xml version=\"1.0\" encoding=\"%s\"?>
<!-- saved from url=(0014)about:internet -->")

;; org-export-html
(defun my-org-export-as-html (arg)
  (interactive "P")
  (if (my-note-inbox-p)
    (let ((org-export-publishing-directory (substitute-in-file-name "$DROPBOX_PATH/note/inbox"))
          ;; remove xml declaration from exported html (for importing to Evernote)
          (org-export-html-xml-declaration '(("html" . nil)))
          (org-export-with-toc nil))
      (org-export-as-html arg))
    (org-export-as-html arg)))

(defun my-note-inbox-p ()
  (and (string= major-mode "org-mode")
       (string-match "note/howm/201.*000000\\.txt$" buffer-file-name)))

(defun my-org-export-as-html-with-buffer (target-buffer-name)
  (save-window-excursion
    (switch-to-buffer target-buffer-name)
    (org-export-as-html nil)))

;; http://blog.mkoga.net/2012/06/18/auto-publish-org-file/
(add-hook 'after-save-hook
          (lambda ()
            (interactive)
            (when (my-note-inbox-p)
              (revert-buffer t t) ; required in first write
              (my-org-export-as-html nil))
            (when (string-match "index.org" buffer-file-name)
              (org-export-as-html nil))
            ))

; ;; org-publish
; (setq org-publish-project-alist
;       '(("menu" :components ("menu-static" "menu-org"))
;         ("menu-org"
;          :base-directory "~/../Dropbox/note/org"
;          :base-extension "org"
;          :publishing-directory "~/tmp/org-menu"
;          :recursive t
;          :publishing-function org-publish-org-to-html
;          ;; :headline-levels 4             ; Just the default for this project.
;          ;; :auto-preamble t
;          ;; :exclude "PrivatePage.org"   ;; regexp
;          )
;         ("menu-static"
;          :base-directory "~/../Dropbox/note/org"
;          :recursive t
;          :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
;          :publishing-directory "~/tmp/org-menu"
;          :publishing-function org-publish-attachment
;          )
;         ))

;; memo/org-capture
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c l") 'org-store-link)

(add-hook 'org-mode-hook
      (defun my-org-mode-map ()
        ;; (setq indent-tabs-mode nil)
        (setq evil-auto-indent nil)
        ;; (global-set-key "\C-j" nil)
        ;; (define-key org-mode-map "\C-j" 'org-return-indent)

        (define-key org-mode-map [(meta return)] nil) ; use global
        (define-key org-mode-map "\C-y" nil)        ; disable org-yank
        ;; (define-key org-mode-map (kbd "C-c ,") nil) ; for howm keybind
        ;; (define-key org-mode-map "\M-2" 'my-org-export-as-excel-text)
        (define-key org-mode-map [(control up)] 'outline-previous-visible-heading)
        (define-key org-mode-map [(control down)] 'outline-next-visible-heading)
        (define-key org-mode-map [(control left)] 'org-shiftleft)
        (define-key org-mode-map [(control right)] 'org-shiftright)
        (define-key org-mode-map [(tab)] 'my-org-cycle)
        (define-key org-mode-map [(shift tab)] 'my-org-shifttab)
        (define-key org-mode-map [(return)]
          (lambda ()
            (interactive)
            (let ((org-table-automatic-realign (or (not (evil-normal-state-p)) (buffer-modified-p))))
              (if (and (evil-normal-state-p) (not (org-at-table-p)))
                  (progn      ; check and move next
                    (org-ctrl-c-ctrl-c)
                    (evil-next-line))
                (org-return))))) ; normal return
        (define-key org-mode-map (kbd "C-c C-c")
          (lambda ()
            (interactive)
            (if (and (org-at-heading-p) (not org-occur-highlights))
                (org-todo)
              (org-ctrl-c-ctrl-c))))
        (define-key org-mode-map (kbd "C-c T")
          (lambda () (interactive) (org-show-todo-tree '(4))))
        (define-key org-mode-map (kbd "C-c t")
          (lambda () (interactive) (org-occur (concat "^" org-outline-regexp " *" (org-fast-todo-selection)))))
        ))

(add-hook 'org-agenda-mode-hook
      (defun my-org-agenda-mode-map ()
        (define-key org-agenda-mode-map ">" (lambda () (interactive) (org-agenda-filter-by-category t)))
        ))

;; org-modeに限らず使用する
(global-set-key [(meta return)] 'my-org-meta-return)
(setq org-M-RET-may-split-line '((default . nil)))
;; (setq org-M-RET-may-split-line '((default . nil) (item . t) (table . t)))
(defun my-org-meta-return (&optional arg)
  (interactive "P")
  (if (evil-normal-state-p)
      (evil-insert 1))
  (call-interactively 'org-meta-return))

;; org-table
(setq org-table-automatic-realign t)
(setq org-table-copy-increment t)

(defun my-org-cycle (&optional arg)
  "Do not realign table when evil-normal-state or buffer not modified."
  (interactive "P")
  (let ((org-table-automatic-realign (or (not (evil-normal-state-p)) (buffer-modified-p))))
    (org-cycle arg)))

(defun my-org-shifttab (&optional arg)
  (interactive "P")
  ;; TODO なぜか表のフォーマットが崩れてしまう
  ;; (let ((org-table-automatic-realign (or (not (evil-normal-state-p)) (buffer-modified-p))))
  ;;    (org-shifttab arg)))
  (let ((org-table-automatic-realign nil))
    (org-shifttab arg)))

;; org-mode excel
;; http://d.hatena.ne.jp/buzztaiki/20111209/1323444755
(defun font-lock-user-keywords (mode &optional keywords)
  "Add user highlighting to KEYWORDS to MODE.
See `font-lock-add-keywords' and `font-lock-defaults'."
  (unless mode
    (error "mode should be non-nil "))
  (font-lock-remove-keywords mode (get mode 'font-lock-user-keywords))
  (font-lock-add-keywords mode keywords)
  (put mode 'font-lock-user-keywords keywords))

(font-lock-user-keywords 'org-mode '(
  ; excel clipboard notation
  ("^\n\".+$" . font-lock-keyword-face) ; section title
  ("^\".+$" . font-lock-string-face)    ; cell list
))

;; face utility
(defun show-face ()
  (interactive)
  (print (get-char-property (point) 'face)))

;; org-export excel
; (require 'tsv-mode nil t)
; ;; http://fukuyama.co/haml
; (defun my-org-export-as-excel-text ()
;   (interactive)
;   ;; TODO ここでorg-export-as-htmlを呼び出しても動作しない？
;   ;; (org-export-as-html)
;   (let ((path (replace-regexp-in-string "\.org$" ".html" buffer-file-name)))
;     (set-excel-text path)))

; (defun set-excel-text (path)
;     (shell-command
;      (concat "python "
;              (expand-file-name "~/.emacs.d/bin/orghtmltool.py")
;              " " path) nil)) ; TODO don't show command output

; ;; ---------------------------------------------------------------------
; ;;; org-refile
; ;;; http://lists.gnu.org/archive/html/emacs-orgmode/2010-11/msg01091.html
; ;; any headline with level <= 2 is a target
; (setq org-refile-targets '((nil :maxlevel . 2)
;                                 ; all top-level headlines in the
;                                 ; current buffer are used (first) as a
;                                 ; refile target
;                            (org-agenda-files :maxlevel . 2)))

; ;; provide refile targets as paths, including the file name
; ;; (without directory) as level 1 of the path
; (setq org-refile-use-outline-path 'file)

; ;; allow to create new nodes (must be confirmed by the user) as
; ;; refile targets
; (setq org-refile-allow-creating-parent-nodes 'confirm)

; ;; refile only within the current buffer
; (defun my/org-refile-within-current-buffer ()
;   "Move the entry at point to another heading in the current buffer."
;   (interactive)
;   (let ((org-refile-targets '((nil :maxlevel . 5))))
;     (org-refile)))


;; org-quickrun http://d.hatena.ne.jp/syohex/20121114/1352900035

;; ---------------------------------------------------------------------
;;; org-notify
(when 1
  ;; http://www.gside.org/blowg/e/user/tma/entry/200711202213
  ;; apptをwindow表示
  (setq appt-display-format 'window)
  ;; appt message 表示秒数
  (setq appt-display-duration 30)
  ;; beep音をならす
  (setq appt-audible nil)
  ;; appt message 何分前にアラームを上げるか
  (setq appt-message-warning-time 15)
  ;; mode line に apptまでの分を表示
  (setq appt-display-mode-line t)

  ;; 保存時にorg-agenda-to-apptを実行
  (add-hook 'org-mode-hook
            ;; (lambda() (add-hook 'before-save-hook
            ;;                  'org-agenda-to-appt t)))
            (lambda()
              (add-hook 'before-save-hook
                        (lambda ()
                          (org-agenda-to-appt)
                          ;; (my-org-agenda-export)
                          ))))

  ;; http://emacswiki.org/emacs/OrgMode-OSD
  (defun growl-appt-display (min-to-app new-time msg)
    (growl-notify (car msg)))
  (setq appt-disp-window-function (function growl-appt-display))

  (run-at-time nil 3600 'org-agenda-to-appt)
  (appt-activate 1)
  ;; (org-agenda-to-appt)

  (run-at-time "6:00" (* 3600 8) (lambda () (org-store-agenda-views)))
  )


;; ---------------------------------------------------------------------
;; evil
;; (setq evil-want-C-w-in-emacs-state t)
(setq evil-want-C-i-jump nil)
(modify-syntax-entry ?_ "w")
(global-subword-mode t)

(when (require 'evil nil t)
  (evil-mode t)
  (setq evil-flash-delay 100)

  ;; evil-surround
  ;; https://github.com/timcharper/evil-surround
  (when (require 'surround nil t)
    (global-surround-mode t))

  ;; evil-numbers.el
  (when (require 'evil-numbers nil t)
    (define-key evil-normal-state-map (kbd "C-a") 'evil-numbers/inc-at-pt)
    (define-key evil-normal-state-map (kbd "C-M-x") 'evil-numbers/dec-at-pt)
    )

  ;; ---------------------------------------------------------------------
  ;; evil mapping
  ; (define-key evil-normal-state-map (kbd "C-w C-]") 'find-tag-other-window)

  (define-key evil-normal-state-map "s" 'my-anything-prefix)
  (define-key evil-normal-state-map "\C-h" 'my-qfix-prefix)
  (define-key evil-normal-state-map "\\" 'evil-mapleader)

  (define-key evil-normal-state-map "\C-q" 'evil-visual-block)
  (define-key evil-normal-state-map "\C-s" 'save-buffer)

  (define-key evil-normal-state-map "q" 'nil)
  ;; (define-key evil-normal-state-map "qq" 'evil-visual-block)
  (define-key evil-normal-state-map "q/" 're-builder)

  (define-key evil-normal-state-map "\C-e" 'evil-end-of-line)
  (define-key evil-operator-state-map "\C-e" 'evil-end-of-line)
  (define-key evil-visual-state-map "\C-e"
    (lambda () (interactive) (evil-end-of-line)))

  ;; NOTE: recenter-top-bottom を使うと repeat の内容が更新されてしまうので evil-mode のコマンドを使う
  (define-key evil-normal-state-map "\C-l" 'evil-scroll-line-to-center)
  (define-key evil-normal-state-map "zz" 'font-lock-fontify-buffer)  ; font-lock 再描画

  (define-key evil-normal-state-map "\C-p" 'nil)
  (define-key evil-normal-state-map "\C-n" 'nil)
  (define-key evil-normal-state-map "\C-y" 'nil)
  (define-key evil-motion-state-map "\C-y" 'nil) ; evil-motion-state-map は visual mode

  (define-key evil-window-map "q" 'delete-window)
  (define-key evil-window-map "\C-q" 'delete-window)
  ; (global-set-key "\C-o" 'evil-jump-backward)

  ;; evil-insert-state-map
  (define-prefix-command 'evil-insert-state-map)
  ;; (define-key evil-insert-state-map "\C-r" 'evil-paste-from-register)
  ;; (define-key evil-insert-state-map [remap newline] 'evil-ret)
  ;; (define-key evil-insert-state-map [remap newline-and-indent] 'evil-ret)
  (define-key evil-insert-state-map [escape] 'evil-normal-state)
  (define-key evil-insert-state-map "\C-z" 'evil-emacs-state)
  (define-key evil-insert-state-map "\C-s" 'save-buffer)

  (defadvice evil-insert-newline-below (around evil-insert-newline-below-around activate)
    "Open line with comment and indent."
    (evil-narrow-to-field
    (evil-move-end-of-line)
    (comment-indent-new-line)))

  (define-key evil-normal-state-map "j" 'evil-next-visual-line)
  (define-key evil-normal-state-map "gj" 'evil-next-line)
  (define-key evil-normal-state-map "k" 'evil-previous-visual-line)
  (define-key evil-normal-state-map "gk" 'evil-previous-line)

  ;; http://d.hatena.ne.jp/tarao/20130304/evil_config#emacs-evilize
  (evil-declare-not-repeat 'my-org-cycle)
  (evil-declare-not-repeat 'my-org-shifttab)

  ;; evil-comment
  (define-key evil-normal-state-map "\M-;"
    '(lambda ()
     (interactive)
     (if (evil-visual-state-p)
       (comment-dwim nil)
       (progn
       (evil-append-line 1)
       (comment-dwim nil)))))

  ;; evil-clipboard
  ;; regionがアクティブの場合kill、その他の場合 C-w + ?
  ;; TODO http://qiita.com/items/7e51af7cd5eb21d6cc84
  (defun my-ctrl-w-prefix ()
    (interactive)
    (if mark-active
        (progn
          (clipboard-kill-region (region-beginning) (region-end))
          (setq mark-active nil))
      ;; http://www.geocities.co.jp/SiliconValley-Bay/9285/ELISP-JA/elisp_304.html
      (execute-kbd-macro (concat "\M-9" (read-key-sequence nil)))))
  ;; (define-key evil-normal-state-map "\C-w" 'my-ctrl-w-prefix)
  (define-key evil-motion-state-map "\C-w" 'my-ctrl-w-prefix)
  (global-set-key "\C-w" 'my-ctrl-w-prefix)
  (global-set-key "\M-9" 'evil-window-map)

  ;; C-w & M-w の時だけクリップボードを使用する
  (setq x-select-enable-clipboard nil)
  (defun clipboard-cua-paste (arg)
    (interactive "P")
    (let ((x-select-enable-clipboard t))
      (cua-paste arg)))
  (defun clipboard-kill-region (beg end &optional yank-handler)
    (interactive "r")
    (let ((x-select-enable-clipboard t))
      (kill-region beg end yank-handler)))
  (evil-define-operator clipboard-evil-yank (beg end type register yank-handler)
    "Yank to clipboard."
    :move-point nil
    :repeat nil
    (interactive "<R><x><y>")
    (let ((x-select-enable-clipboard t))
      (evil-yank beg end type register yank-handler))
    ;; (message (concat "cell count: "
    ;;                  (number-to-string (/ (length (split-string (substring-no-properties (car kill-ring)) "\"")) 2))))
    )

  (define-key evil-insert-state-map "\C-v" 'clipboard-cua-paste)
  (global-set-key "\C-y" 'clipboard-cua-paste)
  (global-set-key "\M-w" 'clipboard-evil-yank)

  ;; indent
  (define-key evil-insert-state-map [(shift tab)] 'tab-to-tab-stop)
  (define-key esc-map "i" 'indent-relative)
  )


;; (setq elscreen-prefix-key "\C-z")
(when (require 'elscreen nil t)
  (elscreen-start)
  (when (featurep 'evil)
    (define-key elscreen-map "\C-r" 'toggle-truncate-lines)
    (define-key evil-motion-state-map "\C-z" elscreen-map)
    (define-key evil-normal-state-map "\C-z" elscreen-map)
    (define-key evil-normal-state-map "zl" 'elscreen-next)
    (define-key evil-normal-state-map "zh" 'elscreen-previous)
    ;; (define-key evil-normal-state-map "zn"
    ;;   (lambda ()
    ;;   (interactive)
    ;;   (elscreen-clone)
    ;;   (delete-other-windows)))
    ))

;; windows IME
;; see also: http://gnupack.sourceforge.jp/docs/latest/UsersGuide_technical_info.html#_about_emacs_patch
(when (eq window-system 'w32)
  ;; input method
  ;; Memo: https://twitter.com/kawabata/status/230626432001392641
  (setq default-input-method "W32-IME")
  (w32-ime-initialize)

  ;; auto ime off
  (when (featurep 'evil)
    ;; (define-key evil-insert-state-map "\C-j" 'toggle-input-method)
    (add-hook 'evil-insert-state-entry-hook (lambda () (if (ime-get-mode) (toggle-input-method))))
    (add-hook 'evil-insert-state-exit-hook  (lambda () (if (ime-get-mode) (toggle-input-method))))
    ))

;; ibus.el
(when (eq window-system 'x)
  (when (require 'ibus nil t)
    (add-hook 'after-init-hook 'ibus-mode-on)
    (when (featurep 'evil)
      (add-hook 'evil-insert-state-entry-hook (lambda () (if ibus-imcontext-status (ibus-disable))))
      (add-hook 'evil-insert-state-exit-hook  (lambda () (if ibus-imcontext-status (ibus-disable))))
      )))

;; window-number.el
(require 'window-number)
(global-set-key (kbd "C-1") (lambda () (interactive) (window-number-select 1)))
(global-set-key (kbd "C-2") (lambda () (interactive) (window-number-select 2)))
(global-set-key (kbd "C-3") (lambda () (interactive) (window-number-select 3)))
(global-set-key (kbd "C-4") (lambda () (interactive) (window-number-select 4)))

(when (require 'redo+ nil t)
  (define-key global-map (kbd "C-r") 'redo))

;; (when (require 'multi-web-mode nil t)
;;   (setq mweb-default-major-mode 'html-mode)
;;   (setq mweb-tags '((php-mode "<\\?php\\|<\\? \\|<\\?=" "\\?>")
;;                     (js-mode "<script +\\(type=\"text/javascript\"\\|language=\"javascript\"\\)[^>]*>" "</script>")
;;                     (css-mode "<style +type=\"text/css\"[^>]*>" "</style>")))
;;   (setq mweb-filename-extensions '("php" "htm" "html" "ctp" "phtml" "php4" "php5"))
;;   (multi-web-global-mode 1)
;;   )

; ;; ---------------------------------------------------------------------
; ;;; elisp/Emacs lisp
; (require 'eldoc)
; ;; (require 'eldoc-extention)
; (setq eldoc-idle-delay 0.5)
; ; (setq eldoc-echo-area-use-multiline-p t)
; (add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)


; ;; ---------------------------------------------------------------------
; ;; auto-complete
; ;; (global-auto-complete-mode t)
; (when (require 'auto-complete-config nil t)
;   (add-to-list 'ac-dictionary-directories
;                "~/.emacs.d/elisp/ac-dict")
;   (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
;   (ac-config-default))

;; ---------------------------------------------------------------------
;; filetype c
(add-hook 'c-mode-common-hook
      (defun my-c-mode-setup ()
        (c-set-style "linux")
        (setq tab-width 4)
        (setq c-basic-offset 4)
        ;; (setq indent-tabs-mode nil)     ; インデントは空白文字で行う（TABコードを空白に変換）
        (c-set-offset 'innamespace 0)   ; namespace {}の中はインデントしない
        ;; (c-set-offset 'arglist-close 0) ; 関数の引数リストの閉じ括弧はインデントしない
        ;; (define-key c++-mode-map "/" 'self-insert-command) ; javadoc風コメント
        (setq comment-style 'extra-line)
        (setq comment-continue " * ")
        (setq comment-start "/* ")
        (setq comment-end " */")
        ;; (flymake-mode nil)
      ))

;; (when (require 'powerline nil t)
;;   (powerline-default-theme))

(when (eq window-system 'w32)
  ; (w32-send-sys-command #xf030) ; maximizing window
  (setq initial-frame-alist
        (append
         '((top . 0)    ; フレームの Y 位置(ピクセル数)
           (left . 30)    ; フレームの X 位置(ピクセル数)
           (width . 160)    ; フレーム幅(文字数)
           (height . 53)   ; フレーム高(文字数)
           ) initial-frame-alist))
  )

(when (eq window-system 'x)
  (setq initial-frame-alist
        (append
         '((top . 0)    ; フレームの Y 位置(ピクセル数)
           (left . 30)    ; フレームの X 位置(ピクセル数)
           (width . 120)    ; フレーム幅(文字数)
           (height . 55)   ; フレーム高(文字数)
           ) initial-frame-alist))
  )

;; color-theme
(when (require 'color-theme nil t)
  (color-theme-initialize)
  ;(color-theme-gray30)
  (color-theme-charcoal-black)
  )
;; (when (featurep 'color-theme-monokai)
;;   (color-theme-monokai))
;; (color-theme-monokai)

;; '(outline-4 ((t (:foreground "slate gray"))))


;; (when (require 'smooth-scroll nil t)
;;   (smooth-scroll-mode t)
;;   (setq smooth-scroll/vscroll-step-size 32)
;;   )


(when (require 'e2wm nil t)
  (global-set-key (kbd "M-+") 'e2wm:start-management)
  )


(when (require 'multiple-cursors nil t)
  ;; https://github.com/magnars/multiple-cursors.el
  (global-set-key (kbd "<M-S-down>") 'mc/mark-previous-like-this)
  (global-set-key (kbd "<M-S-down>") 'mc/mark-next-like-this)
  )


(when (require 'paredit nil t)
  (add-hook 'clojure-mode-hook 'paredit-mode)
  (when (require 'evil-paredit nil t)
    (add-hook 'clojure-mode-hook 'evil-paredit-mode)
    )
  )


(defconst *dmacro-key* (kbd "C-M-y") "繰返し指定キー")
(global-set-key *dmacro-key* 'dmacro-exec)
(autoload 'dmacro-exec "dmacro" nil t)


;; Save for future sessions.
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(evil-default-cursor (quote (t "white"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(rst-level-1-face ((t nil)) t)
 '(rst-level-2-face ((t nil)) t)
 '(rst-level-3-face ((t nil)) t)
 '(rst-level-4-face ((t nil)) t)
 '(rst-level-5-face ((t nil)) t)
 '(rst-level-6-face ((t nil)) t)
 '(show-paren-match ((t (:underline "yellow"))))
 '(trailing-whitespace ((t (:background "brown3")))))
