(define (min-vertex-cover tree)
  (define (solve node)
    (if (null? (cdr node))
        (cons 1 0)
        (let* ((children (map solve (cdr node)))
               (inc (+ 1 (apply + (map (lambda (r) (min (car r) (cdr r))) children))))
               (exc (apply + (map car children))))
          (cons inc exc))))
  (let ((res (solve tree)))
    (min (car res) (cdr res))))

(define example-tree
  '(1
     (2 (4) (5))
     (3)))

(display "Min vertex cover size: ")
(display (min-vertex-cover example-tree))
(newline)