################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Adeeb Nawshad, 1009812945
# Student 2: Taiyi Jin, 1009075796
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
capsule_x:          .word 10            # Initial X position (centered)
capsule_y:          .word 4            # Initial Y position (top of bottle)
capsule_orientation:.word 1             # Capsule orientation (1 = longitudinal, 0 = latitudinal)
capsule_top_color:  .word 0xff0000       # Red
capsule_bottom_color:.word 0xffff00      # Yellow
dr_mario_grid_copy: .space 4096
color_red:    .word 0xFF0000   # RGB value for red
color_blue:   .word 0x0000FF   # RGB value for blue
color_yellow: .word 0xFFFF00   # RGB value for yellow
virus_red:    .word 0x710627   # RGB value for red
virus_blue:   .word 0x73D2DE   # RGB value for blue
virus_yellow: .word 0xFFD972   # RGB value for yellow
virus_color_1:    .word 0xD88373   # RGB value for red
virus_color_2:   .word 0x73D2DE   # RGB value for blue
virus_color_3: .word 0xFFD972   # RGB value for yellow
virus_color_4:    .word 0xD88373   # RGB value for red
virus_position_1: .word 0x000000 #position for virus 1
virus_position_2: .word 0x000000 #position for virus 2
virus_position_3: .word 0x000000 #position for virus 3
virus_position_4: .word 0x000000 #position for virus 4
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
    
    
    # Choose random color for the capsule we would draw at the top
    end_draw_vertical3:
jal start_random_capsule
j draw_other_element

start_random_capsule:

    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $v0, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $a0, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $a1, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $ra, 0($sp)              # store $ra on the stack    


initial_random_top:

li $v0 , 42
li $a0 , 0
li $a1 , 3
syscall

beq $a0, 0, save_red_top        # If $a0 == 0, branch to save_red
    beq $a0, 1, save_blue_top       # If $a0 == 1, branch to save_blue
    beq $a0, 2, save_yellow_top     # If $a0 == 2, branch to save_yellow


save_red_top:
    lw $t0, color_red              # Load the red color into $t0
    sw $t0, capsule_top_color         # Save the red color to Capsule_color
    j initial_random_bottom                          # Jump to end

save_blue_top:
    lw $t0, color_blue             # Load the blue color into $t0
    sw $t0, capsule_top_color         # Save the blue color to Capsule_color
    j initial_random_bottom                          # Jump to end

save_yellow_top:
    lw $t0, color_yellow           # Load the yellow color into $t0
    sw $t0, capsule_top_color          # Save the yellow color to Capsule_color
    j initial_random_bottom


initial_random_bottom:
li $v0 , 42
li $a0 , 0
li $a1 , 3
syscall

beq $a0, 0, save_red_bottom        # If $a0 == 0, branch to save_red
    beq $a0, 1, save_blue_bottom      # If $a0 == 1, branch to save_blue
    beq $a0, 2, save_yellow_bottom     # If $a0 == 2, branch to save_yellow


save_red_bottom:
    lw $t0, color_red              # Load the red color into $t0
    sw $t0, capsule_bottom_color         # Save the red color to Capsule_color
    j initial_random_done                          # Jump to end

save_blue_bottom:
    lw $t0, color_blue             # Load the blue color into $t0
    sw $t0, capsule_bottom_color         # Save the blue color to Capsule_color
    j initial_random_done                          # Jump to end

save_yellow_bottom:
    lw $t0, color_yellow           # Load the yellow color into $t0
    sw $t0, capsule_bottom_color          # Save the yellow color to Capsule_color
    j initial_random_done
    
initial_random_done:

li $t0, 10
li $t1, 4
li $t2, 1


    sw $t0, capsule_x          # Save current X position
    sw $t1, capsule_y          # Save current Y position
    sw $t2, capsule_orientation # Save orientation

    # Calculate base address for capsule
    mul $t3, $t1, 32          # Row offset (row * bytes_per_row)
    add $t3, $t3, $t0          # Column offset
    sll $t3, $t3, 2            # Multiply by 4 (bytes_per_pixel)
    lw $t4, ADDR_DSPL          # Base display address
    add $t0, $t3, $t4          # Full address
    
    lw $t1, capsule_top_color
    lw $t2, capsule_bottom_color
    
    sw $t1, 0($t0)          # paint the top of the capusle
    sw $t2, 128($t0)        # paint the bottom of the capsule 
    
    # restore all the registers that were stored on the stack
lw $ra, 0($sp)              # restore $ra from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
# restore all the registers that were stored on the stack
lw $a1, 0($sp)              # restore $ra from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
# restore all the registers that were stored on the stack
lw $a0, 0($sp)              # restore $ra from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
# restore all the registers that were stored on the stack
lw $v0, 0($sp)              # restore $ra from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
    
    jr $ra
    
    
draw_other_element:    
    
    #capsule outside of bottle
    lw $t0, ADDR_DSPL       # Load the base address of the display
    addi $t0, $t0, 996      # Starting position
    sw $t3, 0($t0)	# New capsule top blue
    sw $t2, 128($t0)	# New capsule bottom yellow
    

    
    
draw_virus:

    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $v0, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $a0, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $a1, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
sw $ra, 0($sp)              # store $ra on the stack  


jal draw_one_virus_color
sw $t0, virus_color_1
jal draw_one_virus_position
lw $t0, virus_color_1
sw $a1, virus_position_1
sw $t0, 0($a1)          # paint virus 1

jal draw_one_virus_color
sw $t0, virus_color_2
jal draw_one_virus_position
lw $t0, virus_color_2
sw $a1, virus_position_2
sw $t0, 0($a1)          # paint virus 2

jal draw_one_virus_color
sw $t0, virus_color_3
jal draw_one_virus_position
lw $t0, virus_color_3
sw $a1, virus_position_3
sw $t0, 0($a1)          # paint virus 3

jal draw_one_virus_color
sw $t0, virus_color_4
jal draw_one_virus_position
lw $t0, virus_color_4
sw $a1, virus_position_4
sw $t0, 0($a1)          # paint virus 4

    # restore all the registers that were stored on the stack
lw $ra, 0($sp)              # restore $ra from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
# restore all the registers that were stored on the stack
lw $a1, 0($sp)              # restore $ra from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
# restore all the registers that were stored on the stack
lw $a0, 0($sp)              # restore $ra from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element
# restore all the registers that were stored on the stack
lw $v0, 0($sp)              # restore $ra from the stack
addi $sp, $sp, 4            # move the stack pointer to the new top element


#the last thing to draw before the game starts is the viruses
j game_loop

draw_one_virus_color:
li $v0 , 42
li $a0 , 0
li $a1 , 3
syscall

beq $a0, 0, save_red_virus        # If $a0 == 0, branch to save_red
    beq $a0, 1, save_blue_virus      # If $a0 == 1, branch to save_blue
    beq $a0, 2, save_yellow_virus     # If $a0 == 2, branch to save_yellow


save_red_virus:
    lw $t0, virus_red              # Load the red color into $t0

    jr $ra                          # Jump to end

save_blue_virus:
    lw $t0, virus_blue             # Load the blue color into $t0

    jr $ra                          # Jump to end

save_yellow_virus:
    lw $t0, virus_yellow           # Load the yellow color into $t0

    jr $ra                          # Jump to end
 

draw_one_virus_position:
#random position for x
li $v0 , 42
li $a0 , 0
li $a1 , 16
syscall

addi $t8, $a0, 3


#random position for y
li $v0 , 42
li $a0 , 0
li $a1 , 11
syscall

addi $t9, $a0, 19


# Calculate base address for capsule
    mul $t3, $t9, 32          # Row offset (row * bytes_per_row)
    add $t3, $t3, $t8          # Column offset
    sll $t3, $t3, 2            # Multiply by 4 (bytes_per_pixel)
    lw $t4, ADDR_DSPL          # Base display address
    add $a1, $t3, $t4          # Full address

jr $ra




# The game loop starts here ---------------------------------------------------------------------------------


game_loop:

    jal erase_capsule
    jal check_input            # Handle key presses
    jal draw_capsule
    jal check_collision
    jal frame_delay            # Delay for 60 FPS
    j game_loop                # Repeat
    

# The game loop ends here -----------------------------------------------------------------------------------
    
    erase_capsule:
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
    lw $t2, capsule_orientation # Load orientation

    # Calculate base address for capsule
    mul $t3, $t1, 32         # Row offset (row * bytes_per_row)
    add $t3, $t3, $t0          # Column offset
    sll $t3, $t3, 2            # Multiply by 4 (bytes_per_pixel)
    lw $t4, ADDR_DSPL          # Base display address
    add $t3, $t3, $t4          # Full address

    li $t5, 0x000000           # Black color (to erase capsule)

    # Erase top half
    sw $t5, 0($t3)

    # Check orientation
    bnez $t2, erase_vertical_capsule

    # Horizontal: Erase right half
    addi $t3, $t3, 4           # Move to the right
    sw $t5, 0($t3)
    jr $ra

erase_vertical_capsule:
    # Vertical: Erase bottom half
    addi $t3, $t3, 128         # Move down
    sw $t5, 0($t3)
    jr $ra

    # 1a. Check if key has been pressed
    check_input:
    lw $t1, ADDR_KBRD       # Load keyboard input (address of keyboard)
    lw $t8, 0($t1)
    beq $t8, $zero, no_key  # If no key is pressed, skip input handling
    
    lw $a1, 4($t1)
    
    # 1b. Check which key has been pressed
    # Rotate (W key)
    li $t2, 0x77            # ASCII for 'w'
    beq $a1, $t2, rotate_capsule

    # Move left (A key)
    li $t2, 0x61            # ASCII for 'a'
    beq $a1, $t2, move_left

    # Move right (D key)
    li $t2, 0x64            # ASCII for 'd'
    beq $a1, $t2, move_right

    # Move down (S key)
    li $t2, 0x73            # ASCII for 's'
    beq $a1, $t2, move_down
    
    
    # Quit game (Q key)
    li $t2, 0x71            # ASCII for 'q'
    beq $a1, $t2, quit_game
    
    no_key:
    jr $ra                  # Return if no key matched
    
rotate_capsule:
    lw $t0, capsule_x              # Load current X position
    lw $t1, capsule_y              # Load current Y position
    lw $t2, capsule_orientation    # Load current orientation

    # If longitudinal, check horizontal validity
    beqz $t2, rotate_to_horizontal

    # Check if longitudinal position is valid
    # Left pixel of horizontal capsule (x - 1, y)
    subi $a0, $t0, -1               # X - 1
    move $a1, $t1                  # Y
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    li $t3, 0x000000               # Black color
    bne $v0, $t3, no_rotate        # If not black, skip rotation

    # Right pixel of horizontal capsule (x + 1, y)
    addi $a0, $t0, 1               # X + 1
    move $a1, $t1                  # Y
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    bne $v0, $t3, no_rotate        # If not black, skip rotation

    # Rotate to horizontal
    li $t2, 0                      # Update to horizontal
    sw $t2, capsule_orientation
    jr $ra

rotate_to_horizontal:
    # If horizontal, check longitudinal validity
    # Bottom pixel of vertical capsule (x, y + 1)
    move $a0, $t0                  # X
    addi $a1, $t1, 1               # Y + 1
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    li $t3, 0x000000               # Black color
    bne $v0, $t3, no_rotate        # If not black, skip rotation

    # Rotate to longitudinal
    li $t2, 1                      # Update to longitudinal
    sw $t2, capsule_orientation
    jr $ra

no_rotate:
    jr $ra

move_left:
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
    lw $t2, capsule_orientation # Load current orientation

    beqz $t2, horizontal_left  # If horizontal, check left pixel of left part

    # Longitudinal: Check left of top half
    subi $a0, $t0, 1           # X - 1 (left pixel)
    move $a1, $t1              # Y (same row as top half)
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel

    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    li $t3, 0x000000           # Black color
    bne $v0, $t3, no_move      # If not black, skip move

    # Longitudinal: Check left of bottom half
    addi $a1, $t1, 1           # Y + 1 (row below for bottom half)
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    bne $v0, $t3, no_move      # If not black, skip move

    # Move left
    subi $t0, $t0, 1           # Decrease X position
    sw $t0, capsule_x          # Update position
    jr $ra

horizontal_left:
    # Latitudinal: Check left of left part
    subi $a0, $t0, 1           # X - 1 (left pixel)
    move $a1, $t1              # Y (same row)
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    bne $v0, $t3, no_move      # If not black, skip move

    # Move left
    subi $t0, $t0, 1           # Decrease X position
    sw $t0, capsule_x          # Update position
    jr $ra

no_movge:
    jr $ra
    
move_right:
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
    lw $t2, capsule_orientation # Load current orientation

    beqz $t2, horizontal_right  # If horizontal, check right pixel of right part

    # Longitudinal: Check right of top half
    addi $a0, $t0, 1           # X + 1 (right pixel)
    move $a1, $t1              # Y (same row as top half)
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    li $t3, 0x000000           # Black color
    bne $v0, $t3, no_move      # If not black, skip move

    # Longitudinal: Check right of bottom half
    addi $a1, $t1, 1           # Y + 1 (row below for bottom half)
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    bne $v0, $t3, no_move      # If not black, skip move

    # Move right
    addi $t0, $t0, 1           # Increase X position
    sw $t0, capsule_x          # Update position
    jr $ra

horizontal_right:
    # Latitudinal: Check right of right part
    addi $a0, $t0, 2           # X + 1 (right pixel)
    move $a1, $t1              # Y (same row)
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    bne $v0, $t3, no_move      # If not black, skip move

    # Move right
    addi $t0, $t0, 1           # Increase X position
    sw $t0, capsule_x          # Update position
    jr $ra

no_move:
    jr $ra
    
move_down:
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
    lw $t2, capsule_orientation # Load current orientation

    beqz $t2, horizontal_down  # If horizontal, check below both parts

    # Longitudinal: Check below the bottom half
    move $a0, $t0              # X (same column)
    addi $a1, $t1, 2           # Y + 2 (row below bottom half)
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    li $t3, 0x000000           # Black color
    bne $v0, $t3, no_move      # If not black, skip move

    # Move down
    addi $t1, $t1, 1           # Increase Y position
    sw $t1, capsule_y          # Update position
    jr $ra

horizontal_down:
    # Latitudinal: Check below left part
    move $a0, $t0              # X (left part)
    addi $a1, $t1, 1           # Y + 1
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    bne $v0, $t3, no_move      # If not black, skip move

    # Latitudinal: Check below right part
    addi $a0, $t0, 1           # X + 1 (right part)
    addi $a1, $t1, 1           # Y + 1
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    bne $v0, $t3, no_move      # If not black, skip move

    # Move down
    addi $t1, $t1, 1           # Increase Y position
    sw $t1, capsule_y          # Update position

    
# Check Pixel Subroutine
check_pixel:
    mul $t0, $a1, 32       # Y * row increment (128 bytes per row)
    add $t0, $t0, $a0       # Add X position
    sll $t0, $t0, 2         # Multiply by 4 (word size)
    lw $t9, ADDR_DSPL       # Load base display base address
    add $t0, $t0, $t9       # Add base address to get pixel address

    lw $v0, 0($t0)          # Load the pixel color
    jr $ra

# Draw Capsule Subroutine
draw_capsule:
    lw $t0, capsule_x          # X position
    lw $t1, capsule_y          # Y position
    lw $t2, capsule_orientation # Orientation

    mul $t3, $t1, 32          # Calculate base address
    add $t3, $t3, $t0
    sll $t3, $t3, 2
    lw $t4, ADDR_DSPL          # Base address

    add $t3, $t3, $t4          # Full address

    lw $t5, capsule_top_color
    lw $t6, capsule_bottom_color

    sw $t5, 0($t3)             # Top half
    
    bnez $t2, vertical_capsule # If vertical, handle vertical case

    # Horizontal: Draw right half
    addi $t3, $t3, 4           # Move right
    sw $t6, 0($t3)
    jr $ra

vertical_capsule:
    addi $t3, $t3, 128         # Move down
    sw $t6, 0($t3)
    jr $ra

# Check collision and generate a new capsule at the top
check_collision:
lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
    lw $t2, capsule_orientation # Load current orientation

    beqz $t2, horizontal_collision_check  # If horizontal, check below both parts

    # Longitudinal: Check below the bottom half
    move $a0, $t0              # X (same column)
    addi $a1, $t1, 2           # Y + 2 (row below bottom half)
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    li $t3, 0x000000           # Black color
    bne $v0, $t3, start_random_capsule      # If not black, skip move

jr $ra

horizontal_collision_check:
    # Latitudinal: Check below left part
    move $a0, $t0              # X (left part)
    addi $a1, $t1, 1           # Y + 1
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    bne $v0, $t3, start_random_capsule      # If not black, skip move

    # Latitudinal: Check below right part
    addi $a0, $t0, 1           # X + 1 (right part)
    addi $a1, $t1, 1           # Y + 1
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack

    jal check_pixel
    lw $t0, capsule_x          # Load current X position
    lw $t1, capsule_y          # Load current Y position
        li $t3, 0x000000           # Black color
    # restore all the registers that were stored on the stack
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    bne $v0, $t3, start_random_capsule      # If not black, skip move

    jr $ra



# Frame Delay Subroutine
frame_delay:
    li $t0, 100         # Adjust this value for your system
frame_delay_loop:
    subi $t0, $t0, 1
    bnez $t0, frame_delay_loop
    jr $ra
# Quit Game Subroutine
quit_game:
    li $v0, 10              # Exit syscall
    syscall
    # 2a. Check for collisions
    
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop

