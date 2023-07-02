.data
WelcomeMsg: 	.asciiz 	"-- CYPHER Plant Monitoring System --"
menu: 		.asciiz 	"Press F to continue"
menuinput:	.space 		2

waterpumpsum:	.asciiz 	"Water Pump Status [0:Off/1:On]: "	

errormsg:	.asciiz 	"Input is incorrect"
menu1:		.asciiz 	"a. Water Pump Status"
menu2:		.asciiz 	"b. Moisture Level Limit Settings"
menu3:		.asciiz 	"c. Return to Summary"
menu4:		.asciiz 	"d. Exit Program"
input:		.asciiz 	"Enter: "

pumpOn: 	.asciiz 	"Water pump status: Pump is on"
pumpOff: 	.asciiz 	"Water pump status: Pump is off"
pumpStats:	.byte 0
on: 		.byte 1
off: 		.byte 0
threshold: 	.byte 40

Update: 			.asciiz "It will take up to 60 seconds to update the moisture level.\nPlease wait, thank you!"
PromptMoistureLevelLimit: 	.asciiz "Please enter plant moisture level: "
thresholdUpdateMsg: 		.asciiz "Threshold value has been updated"

SoilMoistureLevelLimit:		.asciiz "Soil Moisture Threshold: "
SoilMoisture:			.byte 14 # Adjust this value to immitate the soil moisture

escapeSequence: .asciiz "\n"

.text 
summary:	#Display the summary of the water pump status and the soil moisture level limit
		la $a0, escapeSequence
		jal printstring

		# Display welcome prompt 	
		la $a0, WelcomeMsg
		jal printstring
	
		la $a0, escapeSequence
		jal printstring
	
		# Display soil moisture level limit
		la $a0,SoilMoistureLevelLimit
		jal printstring
	
		# Retrieve the threshold value
		li $v0,1
		lb $a0,threshold
		syscall
	
		la $a0, escapeSequence
		jal printstring
	
		# Display the water pump status
		la $a0, waterpumpsum
		jal printstring
	
		# Retrieve water pump status value
		li $v0,1
		lb $a0,pumpStats
		syscall
	
		la $a0, escapeSequence
		jal printstring
	
		j MenuInput1	#go to menuinput1
	
MenuInput1:	# Prompt the F character input to go to the Menu		
		la $a0, menu
		jal printstring
	
		la $a0, escapeSequence
		jal printstring
	
		# Prompt the user the input
		li $v0, 12
		la $a0, menuinput
		syscall
	
		addi $s1, $v0, 0	# Saves the user input into $s1
	
		beq $s1, 'f', Menu	# Checking if the user input is valid, if it is it will go to the Menu, if not it will display error message 
	
		j error1	# Display error message
	
Menu:	# Display all settings menu that are available
	la $a0, escapeSequence
	jal printstring
	la $a0, escapeSequence
	jal printstring
	
	la $a0, menu1
	jal printstring
	la $a0, escapeSequence
	jal printstring
	
	la $a0, menu2
	jal printstring
	la $a0, escapeSequence
	jal printstring
	
	la $a0, menu3
	jal printstring
	la $a0, escapeSequence
	jal printstring
	
	la $a0, menu4
	jal printstring
	la $a0, escapeSequence
	jal printstring
	
MenuInput2:	# Prompt the user the input of the character corresponding to the menu list
		la $a0, input
		jal printstring
	
		li $v0, 12 	# Prompt the user input
		la $a0, menuinput
		syscall
		
		addi $s2, $v0, 0 # Saving the user input into $s2

		beq $s2, 'a', Waterpump		# Checking if the user input is the character a, if it is it will go to the waterpump settings, if not, it will display error message
		beq $s2, 'b', ThresholdSettings	# Checking if the user input is the character b, if it is it will go to the moisture level limit settings, if not, it will display error message
		beq $s2, 'c', summary		# Checking if the user input is the character c, if it is it will go back to the summary, if not, it will display error message
		beq $s2, 'd', endprog		# Checking if the user input is the character d, if it is it will terminate the program, if not, it will display error message
	
		j error2	# Display error message
	
		
printstring:	# Print String
		li $v0, 4
		syscall
		jr $ra	
	
error1:		# Print error message
		la $a0, errormsg
		jal printstring
		la $a0, escapeSequence
		jal printstring
		j MenuInput1
	
error2:		# Print error message
		la $a0, errormsg
		jal printstring	
		la $a0, escapeSequence
		jal printstring
		j MenuInput2	
	
endprog:	# Terminate the program
		li $v0,10
		syscall	

Waterpump:	# Waterpump Settings
		lb $t1, SoilMoisture
		
		la $a0, escapeSequence
		jal printstring
		la $a0, escapeSequence
		jal printstring
		
		# Compare if $t1 < $s1, branch to turnPumpOn label
		lb $t5,threshold
		blt $t1,$t5,turnPumpOn
		
		# Otherwise, jump to turnPumpOff
		j turnPumpOff
		
turnPumpOff:
		# Display prompt message
		li $v0,4
		la $a0,pumpOff
		syscall
		
		# Play sound (piano)
		li $v0,31
		la $a0,69
		la $a1,100
		la $a2,1
		la $a3,127
		syscall
		
		# Sleep the program (for 70 ms)
		li $v0,32
		la $a0,70
		syscall
		
		# Play sound
		li $v0,31
		la $a0,64
		la $a1,100
		la $a2,1
		la $a3,127
		syscall
		
		# Update pump stats
		lb $s2,off
		sb $s2,pumpStats
		
		# Return to menu
		j Menu
		
turnPumpOn:
		# Display prompt message
		li $v0,4
		la $a0,pumpOn
		syscall
		
		# Play sound (piano)
		li $v0,31
		la $a0,64
		la $a1,100
		la $a2,1
		la $a3,127
		syscall
		
		# Sleep the program (for 70 ms)
		li $v0,32
		la $a0,70
		syscall
		
		# Play sound
		li $v0,31
		la $a0,69
		la $a1,100
		la $a2,1
		la $a3,127
		syscall
		
		# Update pump stats
		lb $s2,on
		sb $s2,pumpStats
		
		# Return to menu
		j Menu	
			
ThresholdSettings:	#moist level settings
		la $a0, escapeSequence
		jal printstring
		
		# Printing out the update alert
		la $a0, Update
		jal printstring
		
		la $a0, escapeSequence
		jal printstring
		
		#Input the moisture level
		la $a0, SoilMoistureLevelLimit
		jal printstring
	
		# getting integer from user to change the threshold value
		li $v0,5
		syscall

		# store the new threshold value into threshold variable
		sb $v0, threshold
	
		# print out threshold update message
		la $a0, thresholdUpdateMsg
		jal printstring
	
		# jump to menu
		j Menu

		
