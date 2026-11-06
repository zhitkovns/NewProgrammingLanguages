(defun alist-to-string (alist)
  (with-output-to-string (s)
    (dolist (pair alist)
      (format s "~A=~A~%" (car pair) (cdr pair)))))

(defun string-to-alist (str)
  (with-input-from-string (in str)
    (loop for line = (read-line in nil)
          while line
          for pos = (position #\= line)
          when pos
            collect (cons (subseq line 0 pos) (subseq line (1+ pos))))))

(let ((original '(("name" . "Alice") ("age" . "30") ("city" . "Moscow"))))
  (format t "original: ~S~%" original)
  (let* ((encoded (alist-to-string original)))
    (format t "encoded:~%~A" encoded)
    (let ((decoded (string-to-alist encoded)))
      (format t "decoded: ~S~%" decoded)
      (format t "round-trip equal: ~A~%" (equal original decoded)))))