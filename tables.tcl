# Support for tables, build and load.
namespace eval ttable {
   namespace export lookup

   variable tables
}

proc ttable::add {table key value} {
   variable tables

   set tables($table,$key) $value
}

proc ttable::lookup {table key} {
   variable tables

   if {[lsearch -exact [array names tables] "$table,$key"] != -1} {
      return $tables($table,$key)
   } elseif {[lsearch -glob [array names tables] "$table,*"] == -1} {
      error "Unknown table: $table."
   } else {
      error "($key) not defined for table $table."
   }
}

proc ttable::addrange {table keytemplate start end value} {
   variable tables

   set loc [string first % $keytemplate]
   for {set x $start} {$x <= $end} {incr x} {
      add $table [string replace $keytemplate $loc $loc $x] $value
   }
}



namespace eval ttable { source tabledata }
