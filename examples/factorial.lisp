(define-actor fact ((temp 1)) 
  (guard (list n cust) (eq 1 n)) (progn (send cust (* temp 1))
					(setf temp 1))
  (list n cust) (progn (setf temp (* n temp))
		       (send self (list (- n 1) cust))))