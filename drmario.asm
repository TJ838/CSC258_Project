################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Adeeb Nawshad, 1009812945
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    # Initialize the game
    
    # Milestone 1
    li $t4, 0x707070        # $t4 = grey
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 648
    
    addi $a1, $zero, 7  	# set width = 7 
    # Draw a line
    add $t5, $zero, $zero	# Set index value ($t5) to zero
    draw_line_loop:
    beq $t5, $a1, end_draw_line  # If $t5 == width ($a1), jump to end
    sw $t4, 0($t0)	#	- Draw a pixel at memory location $t0
    addi $t0, $t0, 4	#	- Increment $t0 by 4
    addi $t5, $t5, 1	#	- Increment $t5 by 1
    j draw_line_loop	#	- Jump to start of line drawing loop
    
    end_draw_line:
    
    lw $t0, ADDR_DSPL       # Load the base address of the display
    addi $t0, $t0, 648      # Starting position (same as horizontal line start)

    addi $a1, $zero, 26     # Set height = 26
    li $t6, 128		# Row increment
    
    # Draw a vertical line
    add $t5, $zero, $zero   # Set index value ($t5) to zero
    draw_vertical_loop:
    beq $t5, $a1, end_draw_vertical  # If $t5 == height ($a1), jump to end
    sw $t4, 0($t0)          # Draw a pixel at memory location $t0
    add $t0, $t0, $t6       # Increment $t0 to the next row
    addi $t5, $t5, 1        # Increment $t5 by 1
    j draw_vertical_loop    # Jump to start of vertical drawing loop
    
    end_draw_vertical:
    
    lw $t0, ADDR_DSPL       # Load the base address of the display
    addi $t0, $t0, 648      # Starting position of the vertical line

    # Calculate starting point for the horizontal line
    li $t6, 128            # Row increment
    li $t5, 25              # Height of the vertical line
    mul $t7, $t5, $t6       # Total offset in bytes to reach the bottom of the vertical line
    add $t0, $t0, $t7       # Add the offset to $t0 to reach the new starting position

    addi $a1, $zero, 17     # Set width = 17 pixels

    # Draw the horizontal line
    add $t5, $zero, $zero   # Set index value ($t5) to zero
    draw_horizontal_loop:
    beq $t5, $a1, end_draw_horizontal  # If $t5 == width ($a1), jump to end
    sw $t4, 0($t0)          # Draw a pixel at memory location $t0
    addi $t0, $t0, 4        # Increment $t0 to the next column (4 bytes)
    addi $t5, $t5, 1        # Increment $t5 by 1
    j draw_horizontal_loop  # Jump to start of horizontal drawing loop

    end_draw_horizontal:
 
    lw $t0, ADDR_DSPL       # Load the base address of the display
    addi $t0, $t0, 716      # Starting position

    addi $a1, $zero, 26    # Set height = 26
    li $t6, 128		# Row increment
    
    # Draw a vertical line
    add $t5, $zero, $zero   # Set index value ($t5) to zero
    draw_vertical_loop1:
    beq $t5, $a1, end_draw_vertical1  # If $t5 == height ($a1), jump to end
    sw $t4, 0($t0)          # Draw a pixel at memory location $t0
    add $t0, $t0, $t6       # Increment $t0 to the next row
    addi $t5, $t5, 1        # Increment $t5 by 1
    j draw_vertical_loop1    # Jump to start of vertical drawing loop
    
    end_draw_vertical1:
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 688
    
    addi $a1, $zero, 7  	# set width = 7 
    # Draw a line
    add $t5, $zero, $zero	# Set index value ($t5) to zero
    draw_line_loop1:
    beq $t5, $a1, end_draw_line1  # If $t5 == width ($a1), jump to end
    sw $t4, 0($t0)	#	- Draw a pixel at memory location $t0
    addi $t0, $t0, 4	#	- Increment $t0 by 4
    addi $t5, $t5, 1	#	- Increment $t5 by 1
    j draw_line_loop1	#	- Jump to start of line drawing loop
    
    end_draw_line1:
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 432
    
    addi $a1, $zero, 2   # Set height = 2
    li $t6, 128		# Row increment
    
    # Draw a vertical line
    add $t5, $zero, $zero   # Set index value ($t5) to zero
    draw_vertical_loop2:
    beq $t5, $a1, end_draw_vertical2  # If $t5 == height ($a1), jump to end
    sw $t4, 0($t0)          # Draw a pixel at memory location $t0
    add $t0, $t0, $t6       # Increment $t0 to the next row
    addi $t5, $t5, 1        # Increment $t5 by 1
    j draw_vertical_loop2    # Jump to start of vertical drawing loop
    
    end_draw_vertical2:
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 416
    
    addi $a1, $zero, 2   # Set height = 2
    li $t6, 128		# Row increment
    
    # Draw a vertical line
    add $t5, $zero, $zero   # Set index value ($t5) to zero
    draw_vertical_loop3:
    beq $t5, $a1, end_draw_vertical3  # If $t5 == height ($a1), jump to end
    sw $t4, 0($t0)          # Draw a pixel at memory location $t0
    add $t0, $t0, $t6       # Increment $t0 to the next row
    addi $t5, $t5, 1        # Increment $t5 by 1
    j draw_vertical_loop3    # Jump to start of vertical drawing loop
    
    end_draw_vertical3:
    
    li $t1, 0xff0000	# $t1 = red
    li $t2, 0xffff00	# $t2 = yellow
    li $t3, 0x0000ff	# t3 = blue
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 424
    sw $t1, 0($t0)          # paint the top of the capusle red
    sw $t2, 128($t0)        # paint the bottom of the capsule yellow
    
    lw $t0, ADDR_DSPL       # Load the base address of the display
    addi $t0, $t0, 996      # Starting position
    sw $t3, 0($t0)	# New capsule top blue
    sw $t2, 128($t0)	# New capsule bottom yellow
    
    lw $t0, ADDR_DSPL       # Load the base address of the display
    addi $t0, $t0, 1216      # Starting position
    sw $t3, 0($t0)
    
    lw $t0, ADDR_DSPL       # Load the base address of the display
    addi $t0, $t0, 2224     # Starting position
    sw $t3, 0($t0)
    
    lw $t0, ADDR_DSPL       # Load the base address of the display
    addi $t0, $t0, 2452
    sw $t2, 0($t0)
    
    lw $t0, ADDR_DSPL       # Load the base address of the display
    addi $t0, $t0, 3104
    sw $t2, 0($t0)
    
    Exit:
    li, $v0, 10
    syscall
game_loop:
    # 1a. Check if key has been pressed
    
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop
