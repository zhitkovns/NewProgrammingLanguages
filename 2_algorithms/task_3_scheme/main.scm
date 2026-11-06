(define (hanoi n from to via)
  (if (= n 0)
      '()
      (append
        (hanoi (- n 1) from via to)
        (list (list from to))
        (hanoi (- n 1) via to from))))

(define (print-moves moves)
  (for-each
    (lambda (m)
      (display (car m))
      (display " -> ")
      (display (cadr m))
      (newline))
    moves))

(display "hanoi with 3 disks:\n")
(let* ((moves (hanoi 3 'A 'C 'B))
       (count (length moves)))
  (print-moves moves)
  (display "total moves: ")
  (display count)
  (newline))