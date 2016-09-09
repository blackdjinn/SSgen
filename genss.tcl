source tables.tcl
source dice.tcl

array set hex {0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 A 11 B 12 C 13 D 14 E 15 F 16 G 17 H 18 I 19 J 20 K}
array set unhex {0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 A 10 B 11 C 12 D 13 E 14 F 15 G 16 H 17 I 18 J 19 K 20}
array set dubnum {0 00 1 01 2 02 3 03 4 04 5 05 6 06 7 07 8 08 9 09}
for {set i 10} {$i <= 99} {incr i} {set dubnum($i) $i}

proc techmods {upp} {
   set profile [string range $upp 0 5]

   switch -exact [string range $profile 0 0] \
      A {set mod 6} \
      B {set mod 4} \
      C {set mod 2} \
      X {set mod -4} \
      default {set mod 0}
   switch -glob [string range $profile 1 1]  {\
      [0-1] {incr mod 2} \
      [2-4] {incr mod} }
   switch -glob [string range $profile 2 2] {\
      [0-3] {incr mod} \
      [A-E] {incr mod} }
   switch -exact [string range $profile 3 3] \
      9 {incr mod} \
      A {incr mod 2}
   switch -glob [string range $profile 4 4] {\
      [1-5] {incr mod} \
      9 {incr mod 2} \
      A {incr mod 4} }
   switch -exact [string range $profile 5 5] \
      0 {incr mod} \
      5 {incr mod} \
      D {incr mod -2}
   #for Mileu 0 adjustment.
   incr mod -3
   return $mod
}

proc genEE {upp pbg codes} {
global unhex
global hex

   set sp [string range $upp 0 0]
   set p $unhex([string range $upp 4 4])
   set tl $unhex([string range $upp 8 8])
   set labor [expr {($p > 1)?($p -1):0}]
   set resmod 0
   set infmod 0
   set cultmod 0
   set isAs 0
   set isBa 0
   set isPo 0
   switch -exact $sp \
      A { incr resmod 2
         incr infmod 4 }\
      B { incr resmod 1
         incr infmod 3 }\
      C { incr infmod 2 }\
      D { incr infmod 1 }
   set cl [concat $codes]
   if {[lsearch -exact $cl "Ag"] != -1} {
      incr resmod 1
      incr resmod -1
   }
   if {[lsearch -exact $cl "As"] != -1} {
      incr infmod -1
      incr cultmod 1
      set isAs 1
   } else { 
      if {[lsearch -exact $cl "Va"] != -1} {
         incr resmod -1
         incr cultmod 1
      }
   }
   if {[lsearch -exact $cl "De"] != -1} {
      incr resmod -1
      incr cultmod 1
   }
   if {[lsearch -exact $cl "Fl"] != -1} {
      incr resmod -1
      incr cultmod 1
   }
   if {[lsearch -exact $cl "Hi"] != -1} {
      incr resmod 1
      incr infmod 1
   }
   if {[lsearch -exact $cl "Ic"] != -1} {
      incr resmod -1
      incr cultmod 1
   }
   if {[lsearch -exact $cl "In"] != -1} {
      incr resmod 1
      incr infmod 1
   }
   if {[lsearch -exact $cl "Lo"] != -1} {
      incr infmod -1
   }
   if {[lsearch -exact $cl "Ni"] != -1} {
      incr resmod -1
      incr infmod -1
   }
   if {[lsearch -exact $cl "Po"] != -1} {
      incr infmod -2
      incr cultmod 1
      set isPo 1
   }
   if {[lsearch -exact $cl "Ri"] != -1} {
      incr infmod 1
      incr resmod 2
      incr cultmod 1
   }
   if {[lsearch -exact $cl "Wa"] != -1} {
      incr infmod -1
   }
   if {$tl >= 8} {
      incr resmod [expr {[string range $pbg 1 1] + [string range $pbg 2 2]}]
   }
   set isBa [expr {[lsearch -exact $cl "Ba"] != -1}]
   if {$isAs || $isBa || $isPo} {
      set res [expr {[die] - 1 + $resmod}]
   } else {
      set res [expr {[die 2] - 2 + $resmod}]
   }
   if {$res < 0} {set res 0}
   if {$res > 15} {set res 15}
   if {$isBa} {
      switch -glob [die] {\
         [1-2] { set inf 0 }\
         [3-5] { set inf 1 }\
         6 {set inf 2} }
   } else {
      set inf [expr {[die 2] - 2}]
   }
   incr inf $infmod
   if {$inf < 0} {set inf 0}
   if {$inf > 15} {set inf 15}
   if {$inf > $tl} {set inf $tl}
   if {$inf > $res} {set inf $res}
   if {$isBa} {
      switch -glob [die] {\
         [1-4] { set cult 0 }\
         [5-6] { set cult 1 } }
   } else {
      set cult [die 2]
   }
   incr cult $cultmod
   if {$cult < 0} {set cult 0}
   if {$cult > 15} {set cult 15}
   set EE [list $hex($res) $hex($labor) $hex($inf) $hex($cult)]
   return [join $EE ""]
}

proc genPBG {{pop 1}} {

   set p [expr {($pop==0)?0:[dx 9]}]
   set g [ttable::lookup PEgasnum [die 2]]
   set b [ttable::lookup PEbeltnum [expr {[die 2] + $g}]]
   return [join [list $p $b $g] ""]
}

proc misccodes {upp {pbg "xxx"}} {
global subsect
global unhex

   set sp [string range $upp 0 0]
   if {[string equal $pbg "xxx"]} {
      if {[die 2] <= 9} {lappend l GG}
   } else {
      if {[string range $pbg 2 2] != 0} {lappend l GG}
   }
   if {[string equal $sp A] || [string equal $sp B]} {
      if {[die 2] >= 8} {lappend l N} }
   set t [die 2]
   switch -exact [string range $upp 0 0] \
      A {incr t -3} \
      B {incr t -2} \
      C {incr t -1} \
      E {set t 0} \
      X {set t 0}
   if {$t >= 8} {lappend l S}
   set s $unhex([string range $upp 1 1])
   set a $unhex([string range $upp 2 2])
   set h $unhex([string range $upp 3 3])
   set p $unhex([string range $upp 4 4])
   set g $unhex([string range $upp 5 5])
   set w $unhex([string range $upp 6 6])
   if {(($a >= 4) && ($a <= 9)) && \
       (($h >= 4) && ($h <= 8)) && \
       (($p >= 5) && ($p <= 7))} {lappend l Ag}
   if {($s == 0) && ($a == 0) && ($h == 0)} {lappend l As}
   if {($p == 0) && ($g == 0) && ($w == 0)} {lappend l Ba}
   if {($a >= 2) && ($h == 0)} {lappend l De}
   if {($a >= 10) && ($h != 0)} {lappend l Fl}
   if {$p >= 9} {lappend l Hi}
   if {(($a == 0) || ($a == 1)) && ($h != 0)} {lappend l IC}
   if {([lsearch {0 1 2 4 7 9} $a] != -1) &&\
       ($p >= 9)} {lappend l In}
   if {$p <= 3} {lappend l Lo}
   if {($a <=3) && ($h <=3) && ($p >=6)} {lappend l Na}
   if {$p <= 6} {lappend l Ni}
   if {($a >= 2) && ($a <=5) && ($h<=3)} {lappend l Po}
   if {(($a == 6) || ($a == 8)) &&\
       ($p >= 6) && ($p <= 8) &&\
       ($g >= 4) && ($g <= 9)} {lappend l Ri}
   if {$a == 0} {lappend l Va}
   if {$h == 10} {lappend l Wa}
   lappend l " "
   return [join $l]
}   

proc gensystem {} {
global hex

   set syst [list [ttable::lookup starport [die 2]]]
   #Size
   set size [expr {[die 2] - 2}]
   lappend syst $hex($size)
   #atmosphere
   set a [expr {($size==0)?0:([die 2] + $size - 7)}]
   lappend syst $hex([expr {($a < 0)?0:$a}])
   #hydro
   set x [expr {($size<=1)?0:([die 2] + $size - 7)}]
   switch -glob $hex([expr {($a < 0)?0:$a}]) {\
      [0-1] {incr x -4} \
      [A-Z] {incr x -4} }
   lappend syst $hex([expr {($x < 0)?0:($x > 10)?10:$x}])
   #population
   set a [expr {[die 2] - 2}]
   lappend syst $hex($a)
   #Government
   set x [expr {($a==0)?0:([die 2] + $a - 7)}]
   lappend syst $hex([expr {($x < 0)?0:$x}])
   #Law Level
   set x [expr {($x==0)?0:([die 2] + (($x < 0)?0:$x) - 7)}]
   lappend syst $hex([expr {($x < 0)?0:$x}])
   lappend syst "-"
   #Tech Level
   set x [die 1]
   incr x [techmods [join $syst ""]]
   lappend syst $hex([expr {($x < 0)?0:$x}])
   return [join $syst ""]
}

proc genchar {upp ee} {
global hex
global unhex

   set sp [string range $upp 0 0]
   set p $unhex([string range $upp 4 4])
   set g $unhex([string range $upp 5 5])
   set ll $unhex([string range $upp 6 6])
   set cult $unhex([string range $ee 3 3])
   set progression [die 2]
   if {$p >= 6} {incr progression}
   if {$p >= 9} {incr progression}
   if {$ll >= 10} {incr progression}
   if {$cult <= 3} {incr progression -1}
   if {$cult >= 8} {incr progression 1}
   lappend char $hex($progression)
   set planning [die 2]
   if {$progression >= 8} {incr planning 2}
   if {$progression <= 3} {incr planning -2}
   lappend char $hex($planning)
   set advancement [die 2]
   if {$ll >= 10} {incr advancement}
   if {$progression >=8} {incr advancement 3}
   if {$progression >=12} {incr advancement 3}
   lappend char $hex($advancement)
   set growth [die 2]
   if {$ll >= 10} {incr growth}
   if {$cult <= 3} {incr growth -1}
   if {$cult >= 8} {incr growth 1}
   lappend char $hex($growth)
   set militancy [die 2]
   if {$ll >= 10} {incr militancy}
   if {$growth <= 6} {incr militancy -1}
   if {$growth <= 3} {incr militancy -1}
   if {$growth >= 11} {incr militancy 2}
   lappend char $hex($militancy)
   set unity [die 2]
   if {$ll <= 4} {incr unity}
   if {$ll >= 10} {incr unity -1}
   if {$g <= 2} {incr unity}
   if {$g == 7} {incr unity 3}
   if {$g == 15} {incr unity -1}
   if {$growth >= 11} {incr unity 2}
   lappend char $hex($unity)
   set tolerance [die 2]
   switch -exact $sp \
      A {incr tolerance -2}\
      B {incr tolerance -1}\
      D {incr tolerance 1}\
      E {incr tolerance 3}
   if {$progression >=8} {incr tolerance 2}
   if {$progression >=12} {incr tolerance 2}
   if {$ll >= 10} {incr tolerance}
   lappend char $hex($tolerance)
   return [join $char ""]
}

proc genss {} {
global subsect
global dubnum
global unhex

   array set subsect {}
   for {set i 1} {$i <= 8} {incr i} {
      for {set j 1} {$j <= 10} {incr j} {
	 if {rand() < 0.67ZZ
	    set s [join [list $dubnum($i) $dubnum($j)] ""]
	    set u [gensystem]
	    set subsect($s) $u
	    set pbg [genPBG $unhex([string range $u 4 4])]
	    set subsect($s,pbg) $pbg
	    set codes [misccodes $u $subsect($s,pbg)]
	    set subsect($s,codes) $codes
            set EE [genEE $u $pbg $codes]
            set subsect($s,EE) $EE
            set char [genchar $u $EE]
            set subsect($s,char) $char
	 }
      }
   }
}

proc gensect {} {
global subsect
global dubnum
global unhex

   array set subsect {}
   for {set i 1} {$i <= 32} {incr i} {
      for {set j 1} {$j <= 40} {incr j} {
	 if {rand() < 0.5} {
	    set s [join [list $dubnum($i) $dubnum($j)] ""]
	    set u [gensystem]
	    set subsect($s) $u
	    set pbg [genPBG $unhex([string range $u 4 4])]
	    set subsect($s,pbg) $pbg
	    set codes [misccodes $u $subsect($s,pbg)]
	    set subsect($s,codes) $codes
            set EE [genEE $u $pbg $codes]
            set subsect($s,EE) $EE
            set char [genchar $u $EE]
            set subsect($s,char) $char
	 }
      }
   }
}

proc ss2txt {} {
global subsect

   puts "(loc)\t\t(  UPP  ) (EE) PBG (char )" 
   set stars [lsort [array names subsect ????]]
   foreach s $stars {
      puts [format "%4s\t\t%8s %4s %3s %7s %s" \
         $s \
         $subsect($s) \
         $subsect($s,EE) \
         $subsect($s,pbg) \
         $subsect($s,char) \
         $subsect($s,codes)]
   }
}


proc ss2html {} {
global subsect
global dubnum

puts {<html>}
puts {<head>}
puts {<meta http-equiv="Content-Type" content="text/html;">}
puts {<title>Subsector</title>}
puts {<meta name="GENERATOR" content="htmlss.tcl">}
puts {</head>}
puts {<body text="#999999" bgcolor="#000000" link="#FFCC00" vlink="#C0C0C0" alink="#FFFF00">}
puts {<h1>Subsector</h1>}
puts {<table border="3" cellpadding="0" bordercolor="#FFFFFF" cellspacing="0">}
puts {<tr>}
puts {<td valign="top" align="center" width="50" height="10"><font size="1">01<br>}
puts {</font>&nbsp;<font size="1"><br>}
puts {&nbsp;</font></td>}
puts {<td valign="top" align="center" width="50" height="30" rowspan="2"><font size="1">02<br>}
puts {</font>&nbsp;<font size="1"><br>}
puts {&nbsp;</font></td>}
puts {<td valign="top" align="center" width="50" height="10"><font size="1">03<br>}
puts {</font>&nbsp;<font size="1"><br>}
puts {&nbsp;</font></td>}
puts {<td valign="top" align="center" width="50" height="30" rowspan="2"><font size="1">04<br>}
puts {</font>&nbsp;<font size="1"><br>}
puts {&nbsp;</font></td>}
puts {<td valign="top" align="center" width="50" height="10"><font size="1">05<br>}
puts {</font>&nbsp;<font size="1"><br>}
puts {&nbsp;</font></td>}
puts {<td valign="top" align="center" width="50" height="30" rowspan="2"><font size="1">06<br>}
puts {</font>&nbsp;<font size="1"><br>}
puts {&nbsp;</font></td>}
puts {<td valign="top" align="center" width="50" height="10"><font size="1">07<br>}
puts {</font>&nbsp;<font size="1"><br>}
puts {&nbsp;</font></td>}
puts {<td valign="top" align="center" width="50" height="30" rowspan="2"><font size="1">08<br>}
puts {</font>&nbsp;<font size="1"><br>}
puts {&nbsp;</font></td>}
puts {</tr>}

   set stars [lsort [array names subsect "????"]]
   for {set j 1} {$j <= 10} {incr j} {
      puts "<tr>"
      for {set i 1} {$i <= 8} {incr i 2} {
	 set s [join [list $dubnum($i) $dubnum($j)] ""]
	 puts [format {<td valign="middle" align="center" width="50" height="25" rowspan="2"><font size="1">%s<br>} $s]
	 puts -nonewline </font>
	 if {[lsearch -exact $stars $s] == -1} {
	    puts -nonewline {&nbsp;}
	 } else {
	    puts -nonewline O
	 }
	 puts {<font size="1"><br>&nbsp;</font></td>}
      }
      puts {</tr><tr>}
      for {set i 2} {$i <= 8} {incr i 2} {
	 set s [join [list $dubnum($i) $dubnum($j)] ""]
	 puts [format {<td valign="middle" align="center" width="50" height="25" rowspan="2"><font size="1">%s<br>} $s]
	 puts -nonewline </font>
	 if {[lsearch -exact $stars $s] == -1} {
	    puts -nonewline {&nbsp;}
	 } else {
	    puts -nonewline O
	 }
	 puts {<font size="1"><br>&nbsp;</font></td>}
      }
      puts {</tr>}
   }

puts {<td valign="middle" align="center" width="50" height="30" rowspan="2"><font size="1">&nbsp;</font></td>}
puts {<td valign="middle" align="center" width="50" height="30" rowspan="2"><font size="1">&nbsp;</font></td>}
puts {<td valign="middle" align="center" width="50" height="30" rowspan="2"><font size="1">&nbsp;</font></td>}
puts {<td valign="middle" align="center" width="50" height="30" rowspan="2"><font size="1">&nbsp;</font></td>}
puts {</tr>}
puts {<tr>}
puts {<td valign="middle" align="center" width="50" height="10"><font size="1">&nbsp;</font></td>}
puts {<td valign="middle" align="center" width="50" height="10"><font size="1">&nbsp;</font></td>}
puts {<td valign="middle" align="center" width="50" height="10"><font size="1">&nbsp;</font></td>}
puts {<td valign="middle" align="center" width="50" height="10"><font size="1">&nbsp;</font></td>}
puts {</tr>}
puts {</table>}
puts {<HR NOSHADE>}
puts {<table border="1" cellpadding="0" cellspacing="0">}
puts {<tr>}
puts {<td nowrap valign="middle" align="left"><font size="1">Location</font></td>}
puts {<td nowrap valign="middle" align="left"><font size="1">Name</font></td>}
puts {<td nowrap valign="middle" align="left"><font size="1">UPP</font></td>}
puts {<td nowrap valign="middle" align="left"><font size="1">Notes</font></td>}
puts {</tr>}

   foreach s $stars {
      puts {<tr><td nowrap valign="middle" align="left">}
      puts [format {<pre>%s</pre>} $s]
      puts </td>
      puts {<td nowrap valign="middle" align="left">&nbsp;</td>}
      puts {<td nowrap valign="middle" align="left">}
      puts [format {<pre>%s</pre>} $subsect($s)]
      puts </td>
      puts -nonewline {<td nowrap valign="middle" align="left">}
      puts -nonewline $subsect($s,codes)
      puts </td>
      puts </tr>
   }
puts </table></body></html>
}
