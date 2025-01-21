#To run EDPDB, one needs to include the following into one's 	
# .cshrc file.							
								
# variables for EDPDB						
setenv  EDPDBIN    /usr/share/xtal/edpdb_v22
setenv  EDP_DATA   $EDPDBIN/data					
setenv  edp_data   $EDPDBIN/data					

alias	edpdb      $EDPDBIN/edpdb_v22

exit

#for .bashrc, use the following

declare -x EDPDBIN=/usr/local/edpdb
declare -x EDP_DATA=$EDPDBIN/data
alias edpdb=$EDPDBIN/edpdb_v06a
