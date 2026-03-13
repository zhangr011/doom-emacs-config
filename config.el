;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Rime input method configuration (Squirrel on macOS)
;; (after! rime
;;   (setq default-input-method "rime"
;;         rime-librime-root "/opt/homebrew"
;;         rime-user-data-dir "~/Library/Rime"
;;         rime-show-candidate 'posframe)
;;   (map! :map rime-mode-map
;;         :i "C-`" #'rime-send-keybinding))

;; Toggle Rime input method with C-\ or C-`
;; (map! :i "C-\\" #'toggle-input-method)
;; (map! :i "C-`" #'toggle-input-method)

(use-package! liberime
  :load-path "~/.config/doom"
  :init
  (setq liberime-user-data-dir "~/Library/Rime"
        liberime-module-file "~/.config/doom/lib/liberime-core.so")
  :config
  ;; Automatically build liberime-core if not loaded
  (when (not (liberime-workable-p))
    (liberime-build)))

(defun pyim-probe-evil-normal-mode ()
  "禁用 Evil normal mode 探针。"
  nil)

(use-package! pyim
  ;; :quelpa (pyim :fetcher github :repo "merrickluo/pyim")
  :init
  (setq pyim-title "R")
  :config
  ;; (use-package pyim-basedict
  ;;   :config
  ;;   (pyim-basedict-enable))
  (global-set-key (kbd "M-j") 'pyim-convert-string-at-point)
  (setq pyim-dcache-auto-update nil)
  (setq default-input-method "pyim")
  ;; 我使用全拼
  (setq pyim-default-scheme 'rime)
  (setq pyim-page-tooltip 'child-frame)

  ;; 设置 pyim 探针设置，这是 pyim 高级功能设置，可以实现 *无痛* 中英文切换 :-)
  ;; 我自己使用的中英文动态切换规则是：
  ;; 1. 光标只有在注释里面时，才可以输入中文。
  ;; 2. 光标前是汉字字符时，才能输入中文。
  ;; 3. 使用 M-j 快捷键，强制将光标前的拼音字符串转换为中文。
  (setq-default pyim-english-input-switch-functions
		'(pyim-probe-dynamic-english
		  pyim-probe-isearch-mode
		  pyim-probe-program-mode
                  pyim-probe-evil-normal-mode
		  pyim-probe-org-structure-template))

  (setq-default pyim-punctuation-half-width-functions
		'(pyim-probe-punctuation-line-beginning
		  pyim-probe-punctuation-after-punctuation)))

;; Lua mode configuration with 4-space indentation (using tree-sitter)
(after! lua-ts-mode
  (setq treesit-simple-indent-rules
        `((lua
           ((node-is ")") parent-bol 0)
           ((node-is "]") parent-bol 0)
           ((node-is "else") parent-bol 0)
           ((node-is "elseif") parent-bol 0)
           ((node-is "end") parent-bol 0)
           ((match "block" "function_definition" "arguments" "function_call") parent 8)
           ((parent-is "block") parent 4)
           ((parent-is "function_definition") parent 4)
           ((parent-is "function_call") parent 4)
           ((parent-is "arguments") parent 4)
           ((parent-is "table_constructor") parent-bol 4)
           ((parent-is "if_statement") parent-bol 4)
           ((parent-is "repeat_statement") parent-bol 4)
           ((parent-is "while_statement") parent-bol 4)
           ((parent-is "for_statement") parent-bol 4)
           ((parent-is "assignment_expression") parent-bol 4)))))

;; Auto-enable lua-ts-mode for lua files
(add-to-list 'auto-mode-alist '("\\.lua\\'" . lua-ts-mode))

