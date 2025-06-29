;;; modula2-mode.el --- Major mode for editing Modula-2 source code -*- lexical-binding: t; -*-

;; Author: Your Name <your@email.com>
;; Version: 0.1
;; Keywords: languages
;; Package-Requires: ((emacs "24.3"))
;; URL: https://github.com/yourusername/modula2-mode

;;; Commentary:

;; A simple major mode for Modula-2 with syntax highlighting,
;; 4-space indentation, and auto-uppercase for keywords.

;;; Code:

(defvar modula2-mode-hook nil)

(defvar modula2-mode-map
  (let ((map (make-sparse-keymap)))
    map)
  "Keymap for Modula-2 major mode.")

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.mod\\'" . modula2-mode))
(add-to-list 'auto-mode-alist '("\\.def\\'" . modula2-mode))

;; ----------------------
;; Syntax highlighting
;; ----------------------

(defconst modula2-keywords
  '("AND" "ARRAY" "BEGIN" "BY" "CASE" "CONST" "DEFINITION" "DIV" "DO"
    "ELSE" "ELSIF" "END" "EXIT" "EXPORT" "EXCEPT" "FINALLY" "FOR" "FROM"
    "GENERIC" "IF" "IMPLEMENTATION" "IMPORT" "IN" "INHERIT" "LOOP"
    "MOD" "MODULE" "NOT" "OF" "OR" "POINTER" "PROCEDURE" "QUALIFIED"
    "REPEAT" "RECORD" "RETURN" "SET" "THEN" "TO" "TYPE" "UNTIL" "VAR"
    "WHILE" "WITH" "AS" "ABSTRACT" "TRACED" "OVERRIDE"
    "UNSAFEGUARDED" "CLASS" "READONLY" "GUARD" "REVEAL"))

(defconst modula2-types
  '("INTEGER" "CARDINAL" "BOOLEAN" "CHAR" "REAL" "LONGREAL" "SET"))

(defconst modula2-constants
  '("TRUE" "FALSE" "NIL"))

(defvar modula2-font-lock-keywords
  `((,(regexp-opt modula2-keywords 'words) . font-lock-keyword-face)
    (,(regexp-opt modula2-types 'words) . font-lock-type-face)
    (,(regexp-opt modula2-constants 'words) . font-lock-constant-face)))

;; ----------------------
;; Syntax table
;; ----------------------

(defvar modula2-syntax-table
  (let ((st (make-syntax-table)))
    ;; Comment syntax: (* ... *)
    (modify-syntax-entry ?\( ". 1" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\) ". 4" st)
    ;; Underscore is part of word
    (modify-syntax-entry ?_ "w" st)
    st)
  "Syntax table for `modula2-mode'.")

;; ----------------------
;; Indentation (4 spaces, smart END alignment)
;; ----------------------

(defun modula2-indent-line ()
  "Indent current line according to Modula-2 block structure using 4 spaces."
  (interactive)
  (let ((indent-level 0)
        (offset 4)
        (cur-indent 0))
    (save-excursion
      (beginning-of-line)
      (cond
       ;; Dedent END, ELSE, ELSIF, UNTIL
       ((looking-at "^[ \t]*\\(END\\|ELSE\\|ELSIF\\|UNTIL\\)")
        (save-excursion
          (forward-line -1)
          (while (and (not (bobp))
                      (looking-at "^[ \t]*$"))
            (forward-line -1))
          (setq cur-indent (- (current-indentation) offset))
          (if (< cur-indent 0) (setq cur-indent 0))))
       ;; Otherwise, indent after BEGIN, THEN, DO, ELSE, ELSIF, LOOP
       (t
        (save-excursion
          (forward-line -1)
          (while (and (not (bobp))
                      (looking-at "^[ \t]*$"))
            (forward-line -1))
          (if (looking-at ".*\\b\\(BEGIN\\|THEN\\|DO\\|ELSE\\|ELSIF\\|LOOP\\)\\b")
              (setq cur-indent (+ (current-indentation) offset))
            (setq cur-indent (current-indentation)))))))
    (indent-line-to (max cur-indent 0))
    ;; Move point after indent if inside indent
    (when (< (point) (+ (line-beginning-position) cur-indent))
      (goto-char (+ (line-beginning-position) cur-indent)))))

;; ----------------------
;; Auto-uppercase typed keywords
;; ----------------------

(defun modula2--maybe-uppercase-keyword ()
  "Uppercase the current word if it's a Modula-2 keyword, keeping point at end."
  (let* ((end (point))
         (start (save-excursion (backward-word) (point)))
         (word (buffer-substring-no-properties start end))
         (upcased (upcase word)))
    (when (and (member upcased modula2-keywords)
               (not (string= word upcased)))
      (let ((pos (- end start)))
        (delete-region start end)
        (goto-char start)
        (insert upcased)
        (goto-char (+ start pos))))))

(defun modula2--setup-uppercase-hook ()
  "Enable auto-uppercase for Modula-2 keywords."
  (add-hook 'post-self-insert-hook #'modula2--maybe-uppercase-keyword nil t))

;; ----------------------
;; Major Mode Definition
;; ----------------------

;;;###autoload
(define-derived-mode modula2-mode prog-mode "Modula-2"
  "Major mode for editing Modula-2 source code."
  :syntax-table modula2-syntax-table
  (setq font-lock-defaults '((modula2-font-lock-keywords)))
  (setq-local comment-start "(*")
  (setq-local comment-end "*)")
  (setq-local indent-line-function #'modula2-indent-line)
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)
  (modula2--setup-uppercase-hook))

(provide 'modula2-mode)

;;; modula2-mode.el ends here
