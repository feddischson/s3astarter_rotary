#!/bin/bash



xst -ifn s3astarter_rotary.xst -ofn s3astarter_rotary.syr
ngdbuild -p xc3s700an-4-fgg484 -dd _ngo -nt timestamp -uc ./s3astarter.ucf s3astarter_top.ngc s3astarter_top.ngd
map -bp -timing -cm speed -equivalent_register_removal on -logic_opt on -ol high -power off -register_duplication on -retiming on -w -xe n -o s3astarter_top.ncd s3astarter_top.ngd s3astarter_top.pcf
par -ol high -w -xe c s3astarter_top.ncd s3astarter_top_par.ncd  s3astarter_top.pcf  
bitgen -w s3astarter_top_par.ncd s3astarter_top.bit 
