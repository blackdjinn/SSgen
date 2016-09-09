# -= Tcl/Tk Script =-
cd i:/gensys

proc gamma {l} {
   set R [lindex $l 0]
   set G [lindex $l 1]
   set B [lindex $l 2]

   return [expr "($R+$G+$B)/(3.0*255.0)"]]
}

set state Loading
image create photo inmap -file densemap.gif
canvas .c1 -scrollregion [list 0 0 [image width inmap] [image height inmap]]
.c1 create image 0 0 -image inmap
button .b1 -textvariable state -command { makemap }

pack .c1 .b1 -fill both

proc makemap {} {
global state

   .b1 configure -command { bell }
   for {set x 0} {$x < [image width inmap]} {incr x} {
      for {set y 0} {$y < [image height inmap]} {incr y} {
	 set state "Processing: $x,$y"
	 if {rand()<=[gamma [inmap get $x $y]]} {
	    inmap put {#FFFFFF} -to $x $y
	 } else {
	    inmap put {#000000} -to $x $y
	 }
      }
   }
   set state "Writing outmap.gif"
   inmap write outmap.gif
   set state "Done!"
   .b1 configure -command {wm destroy .}
}

set state "Go!"
