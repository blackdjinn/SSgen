proc die {{number 1}} {
   set sum 0

   for {set x 0} {$x < $number} {incr x} {
      set sum [expr {$sum + int(6 * rand()) + 1}]
   }
   return $sum
}

proc dx {number} { return [expr {int($number * rand()) + 1}] }
