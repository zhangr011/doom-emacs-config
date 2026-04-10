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

;; emacs-rime configuration - Rime input method for Emacs
;; Must be set before compilation (doom sync), not inside after!
(setq rime-librime-root "/opt/homebrew"
      rime-emacs-module-header-root "/opt/homebrew/opt/emacs/include")

(after! rime
  (setq default-input-method "rime"
        rime-user-data-dir (expand-file-name "~/Library/Rime")
        rime-share-data-dir (expand-file-name "~/Library/Rime/sync/Rime")
        rime-show-candidate 'posframe
        rime-disable-predicates '(rime-predicate-after-alphabet-char-p
                                   rime-predicate-prog-in-code-p
                                   rime-predicate-in-code-string-p
                                   rime-predicate-evil-mode-p
                                   rime-predicate-space-after-cc-p
                                   rime-predicate-current-uppercase-letter-p))
  ;; Send C-` to Rime for schema switcher menu
  (map! :map rime-mode-map
        :i "C-`" #'rime-send-keybinding)
  ;; Sync user data on exit
  (add-hook! 'kill-emacs-hook
    (when (fboundp 'rime-lib-sync-user-data)
      (ignore-errors (rime-sync))))
  ;; Show rime status with color indicator in modeline
  (setq mode-line-mule-info '((:eval (rime-lighter))))
  ;; Activate rime by default on startup
  (rime-mode 1))

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

;; In isearch, C-s with empty string yanks word at point
(defun my/isearch-yank-word-if-empty (&rest _)
  "Yank word at point into isearch if search string is empty."
  (when (and isearch-mode (string= isearch-string ""))
    (let ((word (thing-at-point 'word t)))
      (when word
        (isearch-yank-string word)))))

(advice-add 'isearch-repeat-forward :before #'my/isearch-yank-word-if-empty)
(advice-add 'isearch-repeat-backward :before #'my/isearch-yank-word-if-empty)

;; Maximize frame on startup
(add-hook! 'after-init-hook #'toggle-frame-maximized)

;; Font configuration - good Unicode support for terminal and Claude Code
(setq doom-font (font-spec :family "JuliaMono" :size 13))
;; Avoid high line-spacing which breaks terminal box lines
(setq-default line-spacing nil)

;; LSP server configuration
(use-package! eglot
  :config
  ;; C/C++ - clangd (use Homebrew version for better C++20/23 support)
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode cc-mode) . ("/opt/homebrew/opt/llvm/bin/clangd"
                                                "--header-insertion=iwyu"
                                                "--header-insertion-decorators"
                                                "--clang-tidy"
                                                "--log=verbose")))

  ;; Lua - lua-language-server (Homebrew)
  (add-to-list 'eglot-server-programs
               `(lua-mode . ("/opt/homebrew/bin/lua-language-server"
                             "--locale=en"
                             "--logpath=/tmp/lua-language-server.log")))

  ;; JavaScript/TypeScript - typescript-language-server
  (add-to-list 'eglot-server-programs
               '((js-mode js-jsx-mode typescript-mode typescript-tsx-mode) .
                 ("~/.nvm/versions/node/v18.12.1/bin/typescript-language-server" "--stdio")))

  ;; C# - Use dotnet Roslyn server (via dotnet build)
  ;; Note: For full C# LSP support, you may need to install:
  ;; brew install roslyn or use the OmniSharp server manually
  (add-to-list 'eglot-server-programs
               `(csharp-mode . ("dotnet" "/usr/local/share/dotnet/Roslyn/bin/Microsoft.CodeAnalysis.LanguageServer.dll"))))

;; vterm anti-flicker filter
(after! vterm
  (add-hook! 'vterm-mode-hook #'vterm-anti-flicker-filter-enable)
  (setq vterm-blink-cursor nil))

;; Disable cursor blinking globally
(blink-cursor-mode 0)
(setq visible-bell nil)

;; Claude Code IDE integration
(after! claude-code-ide
  ;; Keybinding for Claude Code IDE menu
  (map! :leader
        :desc "Claude Code IDE" "c c" #'claude-code-ide-menu)
  ;; Set full path to Claude CLI (Emacs on macOS may not inherit shell PATH)
  (setq claude-code-ide-cli-path "/Users/zhangrong/.local/bin/claude")
  ;; Use vterm terminal backend
  (setq claude-code-ide-terminal-backend 'vterm)
  ;; Buffer multiline output to prevent flickering
  (setq claude-code-vterm-buffer-multiline-output t)
  ;; Clear nesting detection env var so claude can start inside Emacs
  (setenv "CLAUDECODE" nil)
  ;; Enable built-in Emacs MCP tools (xref, treesit, imenu, project-info)
  (claude-code-ide-emacs-tools-setup)
  ;; Optional: Customize window placement
  (setq claude-code-ide-window-side 'right
        claude-code-ide-window-width 100))

;; Ensure Claude Code IDE can find a working directory
;; Override to guarantee a string is always returned
(advice-add 'claude-code-ide--get-working-directory :filter-return
            (lambda (dir)
              (or dir (expand-file-name "~"))))

