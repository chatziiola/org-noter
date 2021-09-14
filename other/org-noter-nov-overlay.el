;;; org-noter-nov-overlay.el --- Module to highlight text in nov-mode with notes  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Charlie Gordon

;; Author: Charlie Gordon <char1iegordon@protonmail.com>
;; Keywords: multimedia

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License,
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Highlight your precise notes in nov with org-noter-nov-overlay.el

;;; Code:
(require 'org-noter)
(require 'nov nil t)
(require 'seq)

(defcustom org-noter-nov-overlay-color-property "NOTER_OVERLAY"
  "A property that specifies the overlay color for `org-noter-nov-make-ov'.")

(defcustom org-noter-nov-overlay-default-color "yellow"
  "Name of the default background color of the overlay `org-noter-nov-make-ov' makes.

Should be one of the element in `defined-colors'.")

(defun org-noter-nov-make-overlays ()
  (org-noter--with-selected-notes-window
   (let* ((page (buffer-local-value 'nov-documents-index (org-noter--session-doc-buffer session)))
          (regexp (org-re-property org-noter-property-note-location t nil (format ".*%s.*" page))))
     (org-with-wide-buffer
      (goto-char (point-min))
      (while (re-search-forward regexp nil t)
        (org-noter-nov-make-overlay-no-question))))))

(defun org-noter-nov-make-overlay ()
  "TODO"
  (org-noter--with-selected-notes-window
   "No notes window exists"
   (when (eq (org-noter--session-doc-mode session) 'nov-mode)
     (when-let* ((location-property (org-entry-get nil org-noter-property-note-location nil t))
                 (location-cons (cdr (read location-property)))
                 (beg (if (consp location-cons)
                          (car location-cons)
                        location-cons))
                 (end (if (consp location-cons)
                          (cdr location-cons)
                        (1+ beg)))
                 (ov (make-overlay beg end (org-noter--session-doc-buffer session)))
                 (hl-color (or (org-entry-get nil org-noter-nov-overlay-color-property nil t) org-noter-nov-overlay-default-color)))
       
       (overlay-put ov 'button ov)
       (overlay-put ov 'category 'default-button)
       (overlay-put ov 'face (list :background (if org-noter-insert-note-no-questions
                                                   hl-color
                                                 (setq hl-color (read-color "Highlight color: ")))
                                   :foreground (readable-foreground-color hl-color)))
       
       (org-entry-put nil org-noter-nov-overlay-color-property hl-color)
       
       (overlay-put ov 'mouse-face (list :background (setq hl-color (color-lighten-name hl-color 15))
                                         :foreground (readable-foreground-color hl-color)))

       (overlay-put ov 'origin (org-element-property :begin (org-element-at-point)))

       (overlay-put ov 'action #'org-noter-nov-overlay-sync-current-page-or-chapter)))))

(defun org-noter-nov-make-overlay-no-question ()
  "Like `org-noter-nov-make-ov', but doesn't ask user to select the overlay color."
  (org-noter--with-valid-session
   (let ((org-noter-insert-note-no-questions t))
     (org-noter-nov-make-overlay))))

(defun org-noter-nov-overlay-sync-current-page-or-chapter (_overlay)
  "A wrapper function for `org-noter-sync-current-page-or-chapter'
used exclusively with overlays made with `org-noter-nov-make-overlay'

This wrapper ignores the first argument passed to it and just call
`org-noter-sync-current-page-or-chapter'."
  
  (org-noter-sync-current-page-or-chapter))

(add-hook 'org-noter-insert-heading-hook #'org-noter-nov-make-overlay)

(add-hook 'nov-post-html-render-hook #'org-noter-nov-make-overlays)

(provide 'org-noter-nov-overlay)
;;; org-noter-nov-ov.el ends here
