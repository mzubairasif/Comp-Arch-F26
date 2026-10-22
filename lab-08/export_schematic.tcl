open_project Lab6CA.xpr
open_run synth_1
set sch_file [write_schematic -format pdf -force [file normalize "rtl_schematic.pdf"]]
puts "SCHEMATIC WRITTEN TO: $sch_file"
exit
