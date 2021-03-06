This is a simple and easy to use Actor system in Common Lisp. 

# Requirements

- Requires a threaded Common Lisp (Thoroughly tested in vanilla SBCL; CLISP users will need to enable experimental features)
- Requires [Bordeaux threads](http://common-lisp.net/project/bordeaux-threads/)
- Requires [Optima pattern-matching library](https://github.com/m2ym/optima)

### Creating an actor class or template

    (define-actor actor-class (state) 
      (match-expression-1) (behavior-1)
      (match-expression-n) (behavior-n)
      ...)

### Creating an actor instance 

    (defparameter my-actor (actor-class (:state-var_1 value_1 ... :state-var_n value_n)))

### Connecting actors

Use the `link` method to connect one actor directly to one or more other actors.

    (link my-actor my-other-actor yet-another-actor...)

results in 

    my-actor
    ├──> my-other-actor
    ├──> yet-another-actor
    └──> ...

Use the `chain` function to sequentially string together a list of actors.

    (chain my-actor my-other-actor yet-another-actor...)    

results in  

    my-actor ───> my-other-actor ───> yet-another-actor ───> ...

set up circular networks by passing the first actor in again to `chain`

    (chain my-actor my-other-actor my-actor)
    
results in

    my-actor <──> my-other-actor

When an actor is connected to one or more other actors, it will automatically pass along its results.

### Sending a message manually

    (send my-actor message-args)
  
This should really only be used for a first send, if then. If you find yourself needing a manual `send`, there might be a better way to accomplish your goal. Yes, I know it's used in some examples below, but they're holdovers from the original version of this library and shouldn't be taken as anything more serious than thought exercises.

# Features

1. Concurrency using the actors model.
2. Trivial composeability of actors

# Examples

### A print actor
###### Prints the message which was sent to it. A very useful utility actor. 

    ; create the actor template
    (define-actor print-actor (stream) 
       msg (format stream "~a~%" msg))
       
    ; initialize a new instance
    (defparameter printer (print-actor :stream *standard-output*))
    
    ; send values for printing
    (send printer "hello, world")

### A ticker
###### Keeps printing out a count every 2 seconds, starting from 0 and incrementing it every 2 seconds. 

    ; create the ticker template
    (define-actor ticker ((counter 0)) 
       _ (progn (sleep 2)
                (- (incf counter) 1)))
       
    ; Create an instance
    (defparameter t1 (ticker))
    
    ; Connect actors (in this case, t1 is connected to printer and to itself)
    
    (link t1 (list t1 printer))
    
    ; send a message to start up the ticker
    (send t1 nil)
    
    ; to stop use
    (stop-actor t1)

### A factorial computing actor
###### The name says it all :)

    ; create the template
    (define-actor fact ((temp 1)) 
        (guard (list n cust) (eq 1 n)) (progn (send cust (* temp 1))
	                                      (setf temp 1))
        (list n cust) (progn (setf temp (* n temp))
                             (send self (- n 1) cust)))

    ; create a new instance 
    (defparameter f (fact))
    
    ; send a value
    (send f 4 printer)

Note that this use case requires manual `send` calls, which tells me that actors probably aren't the best way to model `factorial`.

### A nagger for fun. In a "no fun at all" kind of way.
###### Works only in Mac OS X. Keeps saying out aloud "please work" every 10 seconds :)

    (defactor nagger ()
       _ (progn (sleep 10)
                (trivial-shell:shell-command "say please work")
		(send self)))
       
    ; anonymous actor , no way to stop the nagging 
    (send (nagger))
