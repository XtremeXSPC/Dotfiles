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
;; (setq doom-theme 'doom-one)
(setq doom-theme 'doom-tokyo-night)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
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
;;
;; Font size
(setq doom-font (font-spec :family "CaskaydiaCove Nerd Font" :size 15 ))

;; Imposta Aspell come programma di controllo ortografico
;(setq ispell-program-name "aspell")
;(setq ispell-dictionary nil)

;; Imposta il comando di Aspell per abilitare più dizionari
;; (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en,it"))

;; Configura la modalità per permettere la scelta dei dizionari
;; (add-hook 'text-mode-hook 'flyspell-mode)

;; Attivare il controllo ortografico in Org-mode
;; (add-hook 'org-mode-hook 'flyspell-mode)

;; Estensione per Hugo - Generatore di contenuti in Markdown da sorgenti Org
(after! org
  (require 'ox-hugo))

;; Abilita la visualizzazione delle anteprime Markdown utilizzando Pandoc
(setq markdown-command "pandoc --standalone --mathjax --highlight-style=pygments --from=markdown_mmd --to=html5")

;; Disabilita l'occultamento automatico delle headings di Org
(setq org-hide-leading-stars nil)

;; vTerm Settings
(after! vterm
  (set-face-attribute 'vterm-color-black nil :background "#282828" :foreground "#282828")
  (set-face-attribute 'vterm-color-underline nil :foreground "#8ec07c" :underline t)
  (set-face-attribute 'vterm-color-inverse-video nil :background "#282828" :inverse-video t)

  ;; Aggiungiamo anche le altre definizioni di colore per completezza
  (setq vterm-color-black   "#282828"
        vterm-color-red     "#cc241d"
        vterm-color-green   "#98971a"
        vterm-color-yellow  "#d79921"
        vterm-color-blue    "#458588"
        vterm-color-magenta "#b16286"
        vterm-color-cyan    "#689d6a"
        vterm-color-white   "#a89984"))
