;;; evil-colemak-basics.el --- Basic Colemak key bindings for evil-mode

;; Author: Wouter Bolsterlee <wouter@bolsterl.ee>
;; Version: 2.2.2
;; Package-Requires: ((emacs "24.3") (evil "1.2.12") (evil-snipe "2.0.3"))
;; Keywords: convenience emulations colemak evil
;; URL: https://github.com/wbolster/evil-colemak-basics
;;
;; This file is not part of GNU Emacs.

;;; License:

;; Licensed under the same terms as Emacs.

;;; Commentary:

;; This package provides basic key rebindings for evil-mode with the
;; Colemak keyboard layout.  See the README for more information.
;;
;; To enable globally, use:
;;
;;   (global-evil-colemak-basics-mode)
;;
;; To enable for just a single buffer, use:
;;
;;   (evil-colemak-basics-mode)

;;; Code:

(require 'evil)
(require 'evil-snipe)

(defgroup evil-colemak-basics nil
  "Basic key rebindings for evil-mode with the Colemak keyboard layout."
  :prefix "evil-colemak-basics-"
  :group 'evil)

(defcustom evil-colemak-basics-layout-mod nil
  "Which Colemak layout mod to use.

Colemak Mod-DH, also known as Colemak Mod-DHm, has m where the h
key is on qwerty. This means we need to swap the h and m
bindings. No other changes are necessary."
  :group 'evil-colemak-basics
  :type '(choice (const :tag "default" nil)
                 (const :tag "mod-dh" mod-dh)))

(defcustom evil-colemak-basics-rotate-t-f-j t
  "Whether to keep find-char and end of word jumps at their qwerty position.

When non-nil, this will rotate the t, f, and j keys, so that f
jumps to the end of the word (qwerty e, same position), t jumps to a
char (qwerty f, same position), and j jumps until a char (qwerty t,
different position)."
  :group 'evil-colemak-basics
  :type 'boolean)

(defcustom evil-colemak-basics-char-jump-commands nil
  "The set of commands to use for jumping to characters.

By default, the built-in evil commands evil-find-char (and
variations) are used; when set to the symbol 'evil-snipe, this
behaves like evil-snipe-override-mode, but adapted to the right
keys.

This setting is only used when the character jump commands are
rotated; see evil-colemak-basics-rotate-t-f-j."
  :group 'evil-colemak-basics
  :type '(choice (const :tag "default" nil)
                 (const :tag "evil-snipe" evil-snipe)))

(defun evil-colemak-basics--make-keymap ()
  "Initialise the keymap based on the current configuration."
  (let ((keymap (make-sparse-keymap)))
    (evil-define-key '(motion normal visual) keymap
      "e" 'evil-next-line
      "ge" 'evil-next-visual-line
      "u" 'evil-previous-line
      "U" 'evil-lookup
      "gu" 'evil-previous-visual-line
      "i" 'evil-forward-char
      "I" 'evil-window-bottom
      "zi" 'evil-scroll-column-right
      "zI" 'evil-scroll-right
      "j" 'evil-forward-word-end
      "J" 'evil-forward-WORD-end
      "gj" 'evil-backward-word-end
      "gJ" 'evil-backward-WORD-end
      "k" (if (eq evil-search-module 'evil-search) 'evil-ex-search-next 'evil-search-next)
      "K" (if (eq evil-search-module 'evil-search) 'evil-ex-search-previous 'evil-search-previous)
      "gk" 'evil-next-match
      "gK" 'evil-previous-match)
    (evil-define-key '(normal visual) keymap
      "N" 'evil-join
      "gN" 'evil-join-whitespace
      "gl" 'evil-downcase
      "gL" 'evil-upcase)
    (evil-define-key 'normal keymap
      "l" 'evil-undo
      "m" 'evil-insert
      "M" 'evil-insert-line
      "gm" 'evil-insert-resume
      "gM" 'evil-insert-0-line)
    (evil-define-key 'visual keymap
      "l" 'evil-downcase
      "L" 'evil-upcase
      "M" 'evil-insert)
    (evil-define-key '(visual operator) keymap
      "m" evil-inner-text-objects-map)
    (evil-define-key 'operator keymap
      "i" 'evil-forward-char)
    (when evil-colemak-basics-rotate-t-f-j
      (evil-define-key '(motion normal visual) keymap
        "f" 'evil-forward-word-end
        "F" 'evil-forward-WORD-end
        "gf" 'evil-backward-word-end
        "gF" 'evil-backward-WORD-end)
      (evil-define-key 'normal keymap
        "gt" 'find-file-at-point
        "gT" 'evil-find-file-at-point-with-line)
      (evil-define-key 'visual keymap
        "gt" 'evil-find-file-at-point-visual)
      (when (featurep 'tab-bar)  ; Evil also checks this; see evil-maps.el
        (evil-define-key 'normal keymap
          "gj" 'tab-bar-switch-to-next-tab
          "gJ" 'tab-bar-switch-to-prev-tab))
      (cond
       ((eq evil-colemak-basics-char-jump-commands nil)
        (evil-define-key '(motion normal visual) keymap
          "t" 'evil-find-char
          "T" 'evil-find-char-backward
          "j" 'evil-find-char-to
          "J" 'evil-find-char-to-backward))
       ((eq evil-colemak-basics-char-jump-commands 'evil-snipe)
        ;; XXX https://github.com/hlissner/evil-snipe/issues/46
        (evil-snipe-def 1 inclusive "t" "T")
        (evil-snipe-def 1 exclusive "j" "J")
        (evil-define-key '(motion normal visual) keymap
          "t" 'evil-snipe-t
          "T" 'evil-snipe-T
          "j" 'evil-snipe-j
          "J" 'evil-snipe-J))
       (t (user-error "Invalid evil-colemak-basics-char-jump-commands configuration"))))
    (when (eq evil-colemak-basics-layout-mod 'mod-dh)
      (evil-define-key '(motion normal visual) keymap
;; "m" 'evil-backward-char)
        "n" 'evil-backward-char)
      (evil-define-key '(normal visual) keymap
        "h" 'evil-set-marker))
    keymap))

(defvar evil-colemak-basics-keymap
  (evil-colemak-basics--make-keymap)
  "Keymap for evil-colemak-basics-mode.")

(defun evil-colemak-basics--refresh-keymap ()
  "Refresh the keymap using the current configuration."
  (setq evil-colemak-basics-keymap (evil-colemak-basics--make-keymap)))

;;;###autoload
(define-minor-mode evil-colemak-basics-mode
  "Minor mode with evil-mode enhancements for the Colemak keyboard layout."
  :keymap evil-colemak-basics-keymap
  :lighter " hnei")

;;;###autoload
(define-globalized-minor-mode global-evil-colemak-basics-mode
  evil-colemak-basics-mode
  (lambda () (evil-colemak-basics-mode t))
  "Global minor mode with evil-mode enhancements for the Colemak keyboard layout.")

(provide 'evil-colemak-basics)

;;; evil-colemak-basics.el ends here
