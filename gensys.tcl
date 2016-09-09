#!/usr/bin/tclsh
source tables.tcl
source dice.tcl

proc gensys {{subsector 00} {location 0000}} {
   array set system {}

   set system(nature) [ttable::lookup sysnature [die 2]]
   set system(typeroll,A) [die 2]
   set system(sizeroll,A) [die 2]
   set system(A,star) [join [list \
      [ttable::lookup pritype $system(typeroll,A)]\
      [expr {[dx 10] - 1}]\
      [ttable::lookup prisize $system(sizeroll,A)] ] ""]
   foreach e [lreplace {B C X} [expr {$system(nature)-1}] end] {
      set system(typeroll,$e)\
	  [expr {$system(typeroll,A) + [die 2]}]
      set system(sizeroll,$e)\
	  [expr {$system(sizeroll,A) + [die 2]}]
      set system($e,star) [join [list \
	 [ttable::lookup comtype $system(typeroll,$e)]\
	 [expr {[dx 10] - 1}]\
	 [ttable::lookup comsize $system(sizeroll,$e)] ] ""]
   }
   puts -nonewline  [array names system "?,star"]
   foreach e [array names system "?,star"] {
      puts -nonewline " : "
      puts -nonewline $system($e)
   }
   puts " |"
}

gensys
gensys
gensys
gensys
gensys
gensys
