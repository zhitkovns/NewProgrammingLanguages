(defun read-token (stream)
  (let ((word ""))
    (loop
      (let ((ch (read-char stream nil nil)))
        (cond
          ((null ch) (return word))
          ((char= ch #\#) (read-line stream))
          ((member ch '(#\Space #\Newline #\Tab #\Return))
           (when (> (length word) 0) (return word)))
          (t (setf word (concatenate 'string word (string ch)))))))))

(defun pbm-to-svg (pbm-path svg-path)
  (with-open-file (in pbm-path :direction :input)
    (let ((magic (read-token in))
          (width-str (read-token in))
          (height-str (read-token in)))
      
      (unless (string= magic "P1")
        (error "Invalid PBM format: expected P1, got ~a" magic))
      
      (let ((width (parse-integer width-str))
            (height (parse-integer height-str)))
        
        (with-open-file (out svg-path :direction :output :if-exists :supersede)
          ;; width и height в пикселях умножаем на 50 для отображения
          (format out "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"~d\" height=\"~d\" viewBox=\"0 0 ~d ~d\">~%" 
                  (* width 50) (* height 50) (* width 50) (* height 50))
          
          ;; Оборачиваем все прямоугольники в группу с масштабированием
          (format out "<g transform=\"scale(50)\">~%")
          
          (dotimes (y height)
            (dotimes (x width)
              (let ((pixel-str (read-token in)))
                (when (string= pixel-str "1")
                  (format out "<rect x=\"~d\" y=\"~d\" width=\"1\" height=\"1\" fill=\"black\"/>~%" x y)))))
                  
          (format out "</g>~%")
          (format out "</svg>~%"))))))

(defun main ()
  (handler-case
      (progn
        (pbm-to-svg "test.pbm" "output.svg")
        (format t "Successfully converted test.pbm to output.svg~%"))
    (error (e)
      (format *error-output* "Error: ~a~%" e))))

(main)