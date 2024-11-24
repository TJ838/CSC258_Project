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
virus_exist_1: .word 1 #existence of virus 1
virus_exist_2: .word 1 #existence of virus 2
virus_exist_3: .word 1 #existence of virus 3
virus_exist_4: .word 1 #existence of virus 4
column_start_pos: .word 0 # the starting position of capsules in a column
column_end_pos: .word 0 # the ending position of capsules in a column
row_start_pos: .word 0 # the starting position of capsules in a row
row_end_pos: .word 0 # the ending position of capsules in a row
count_consecutive: .word 1 # the number of consecutive capsules

#gravity variables
global_timer:  .word 0     # Tracks the passage of time (global loop counter)
gravity_timer: .word 0
gravity_threshold: .word 240    # Threshold for triggering gravity
min_gravity:       .word 30	 # Minimum threshold (fastest speed)

is_paused:        .word 0       # 0 = game running, 1 = game paused
paused_message:   .asciiz "Paused" # Message to display during pause

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
    
    li $t3, 0x000000           # Black color
    lw $t4, 128($t0)

    bne $t4, $t3, game_over      # If not black, the entrance is blocked, game over
    
    lw $t4, -4($t0)
    bne $t4, $t3, game_over
    
    lw $t4, 4($t0)
    bne $t4, $t3, game_over
    
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
    # Check if game is paused
    lw $t0, is_paused            # Load pause state
    bnez $t0, pause_handler      # If paused, handle pause logic

    jal erase_capsule
    jal check_input            # Handle key presses   
    
    jal play_theme_music
    
    # Increment global timer
    lw $t0, global_timer
    addi $t0, $t0, 1
    sw $t0, global_timer   
    
    # Increment gravity timer
    lw $t2, gravity_timer       # Load gravity_timer
    addi $t2, $t2, 1            # Increment timer by 1
    sw $t2, gravity_timer       # Store updated timer

    # Check if gravity timer reaches threshold
    lw $t3, gravity_threshold   # Load gravity threshold
    bge $t2, $t3, trigger_gravity # If timer >= threshold, trigger gravity
    
    # Check for gravity speed adjustment (over time)
    lw $t0, global_timer
    li $t4, 100                 # Time interval for adjusting gravity
    div $t0, $t4                 # Check if global_timer is divisible by 100
    mfhi $t5                     # Move the remainder (HI) to $t5           
    bnez $t5, skip_adjustment   # If not divisible, skip adjustment

    jal adjust_gravity_speed    # Adjust gravity speed
    jal draw_capsule
    jal check_collision
    jal frame_delay            # Delay for 60 FPS
    j game_loop                # Repeat
    

# The game loop ends here -----------------------------------------------------------------------------------

play_theme_music:
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t0, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t1, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t2, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a0, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a1, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a2, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a3, 0($sp)              # store $ra on the stack
    
    
    lw $t0, global_timer
    #li $t1, 2
    #mul $t0, $t0, $t1
    li $t1, 1920
    div $t0, $t1                 # Check if global_timer is divisible by 64
    mfhi $t2                     # Move the remainder (HI) to $t2 
    
    beq $t2, 0, play_theme_note_1
    beq $t2, 60, play_theme_note_2
    beq $t2, 120, play_theme_note_3
    beq $t2, 180, play_theme_note_4
    beq $t2, 240, play_theme_note_5
    beq $t2, 300, play_theme_note_6
    beq $t2, 360, play_theme_note_7
    beq $t2, 420, play_theme_note_8
    beq $t2, 480, play_theme_note_9
    beq $t2, 540, play_theme_note_10
    beq $t2, 600, play_theme_note_11
    beq $t2, 660, play_theme_note_12
    beq $t2, 720, play_theme_note_13
    beq $t2, 960, play_theme_note_14
    beq $t2, 1020, play_theme_note_15
    beq $t2, 1080, play_theme_note_16
    beq $t2, 1140, play_theme_note_17
    beq $t2, 1200, play_theme_note_18
    beq $t2, 1260, play_theme_note_19
    beq $t2, 1320, play_theme_note_20
    beq $t2, 1380, play_theme_note_21
    beq $t2, 1440, play_theme_note_22
    beq $t2, 1470, play_theme_note_23
    beq $t2, 1500, play_theme_note_24
    beq $t2, 1560, play_theme_note_25
    beq $t2, 1590, play_theme_note_26
    beq $t2, 1620, play_theme_note_27
    beq $t2, 1680, play_theme_note_28
    beq $t2, 1710, play_theme_note_29
    beq $t2, 1740, play_theme_note_30
    beq $t2, 1800, play_theme_note_31
    beq $t2, 1830, play_theme_note_32
    beq $t2, 1860, play_theme_note_33




    
    j finish_one_loop_theme_music
    
    
    play_theme_note_1:
    li $v0, 31
    li $a0, 70   # Bb pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_2:
    li $v0, 31
    li $a0, 71   # B pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_3:
    li $v0, 31
    li $a0, 70   # Bb pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_4:
    li $v0, 31
    li $a0, 71   # B pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_5:
    li $v0, 31
    li $a0, 69   # A pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_6:
    li $v0, 31
    li $a0, 55   # G- pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_7:
    li $v0, 31
    li $a0, 55   # G- pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_8:
    li $v0, 31
    li $a0, 69   # A pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_9:
    li $v0, 31
    li $a0, 70   # Bb pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_10:
    li $v0, 31
    li $a0, 71   # B pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_11:
    li $v0, 31
    li $a0, 69   # A pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_12:
    li $v0, 31
    li $a0, 55   # G- pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_13:
    li $v0, 31
    li $a0, 55   # G- pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_14:
    li $v0, 31
    li $a0, 70   # Bb pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_15:
    li $v0, 31
    li $a0, 71   # B pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_16:
    li $v0, 31
    li $a0, 70   # Bb pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_17:
    li $v0, 31
    li $a0, 71   # B pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_18:
    li $v0, 31
    li $a0, 69   # A pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_19:
    li $v0, 31
    li $a0, 55   # G- pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_20:
    li $v0, 31
    li $a0, 55   # G- pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_21:
    li $v0, 31
    li $a0, 69   # D pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_22:
    li $v0, 31
    li $a0, 47   # E pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_23:
    li $v0, 31
    li $a0, 47   # F pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_24:
    li $v0, 31
    li $a0, 47   # D pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_25:
    li $v0, 31
    li $a0, 48   # E pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_26:
    li $v0, 31
    li $a0, 48   # F pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_27:
    li $v0, 31
    li $a0, 48   # Bb pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_28:
    li $v0, 31
    li $a0, 49   # B pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_29:
    li $v0, 31
    li $a0, 49   # A pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_30:
    li $v0, 31
    li $a0, 49   # G- pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_31:
    li $v0, 31
    li $a0, 50   # G- pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_32:
    li $v0, 31
    li $a0, 50   # A pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music

play_theme_note_33:
    li $v0, 31
    li $a0, 50   # Bb pitch
    li $a1, 100  # duration
    li $a2, 1    # instrument
    li $a3, 30   # volume
    syscall
    j finish_one_loop_theme_music


    
    
    finish_one_loop_theme_music:
    
    # restore all the registers that were stored on the stack
    lw $a3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $a0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
    jr $ra




    play_move_sound:
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a0, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a1, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a2, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a3, 0($sp)              # store $ra on the stack
    
    li $v0, 31
    li $a0, 70 # pitch
    li $a1, 100 # duration
    li $a2, 87 # instrument
    li $a3, 30 # volume
    syscall
    
    # restore all the registers that were stored on the stack
    lw $a3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $a0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
    jr $ra
    
    
    play_move_fail_sound:
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a0, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a1, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a2, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a3, 0($sp)              # store $ra on the stack
    
    li $v0, 31
    li $a0, 50 # pitch
    li $a1, 100 # duration
    li $a2, 87 # instrument
    li $a3, 30 # volume
    syscall
    
    # restore all the registers that were stored on the stack
    lw $a3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $a0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
    jr $ra
    
    
    play_drop_capsule_sound:
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a0, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a1, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a2, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a3, 0($sp)              # store $ra on the stack
    
    li $v0, 31
    li $a0, 80 # pitch
    li $a1, 100 # duration
    li $a2, 87 # instrument
    li $a3, 30 # volume
    syscall
    
    # restore all the registers that were stored on the stack
    lw $a3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $a0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
    jr $ra
    
    
     play_remove_capsule_sound:
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a0, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a1, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a2, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a3, 0($sp)              # store $ra on the stack
    
    li $v0, 31
    li $a0, 100 # pitch
    li $a1, 100 # duration
    li $a2, 87 # instrument
    li $a3, 30 # volume
    syscall
    
    # restore all the registers that were stored on the stack
    lw $a3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $a0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
    jr $ra
    
    
    
    play_game_over_fail_sound:
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a0, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a1, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a2, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a3, 0($sp)              # store $ra on the stack
    
    li $v0, 31
    li $a0, 60 # pitch
    li $a1, 100 # duration
    li $a2, 87 # instrument
    li $a3, 30 # volume
    syscall
    
    li $v0, 31
    li $a0, 55 # pitch
    li $a1, 100 # duration
    li $a2, 87 # instrument
    li $a3, 30 # volume
    syscall
    
    li $v0, 31
    li $a0, 50 # pitch
    li $a1, 100 # duration
    li $a2, 87 # instrument
    li $a3, 30 # volume
    syscall
    
    # restore all the registers that were stored on the stack
    lw $a3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $a0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
    jr $ra
    
    
    
    play_game_over_success_sound:
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a0, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a1, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a2, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $a3, 0($sp)              # store $ra on the stack
    
    li $v0, 31
    li $a0, 90 # pitch
    li $a1, 100 # duration
    li $a2, 87 # instrument
    li $a3, 30 # volume
    syscall
    
    li $v0, 31
    li $a0, 95 # pitch
    li $a1, 100 # duration
    li $a2, 87 # instrument
    li $a3, 30 # volume
    syscall
    
    li $v0, 31
    li $a0, 100 # pitch
    li $a1, 100 # duration
    li $a2, 87 # instrument
    li $a3, 30 # volume
    syscall
    
    # restore all the registers that were stored on the stack
    lw $a3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $a1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $a0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
    jr $ra
    
    
    
    
    
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
    
    # Pause game (P key)
    li $t2, 0x70
    beq $a1, $t2, toggle_pause
    
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
    
    #If vertical, change the two colors so that it rotates 360 degrees
    lw $t0, capsule_top_color             
    lw $t1, capsule_bottom_color 
    sw $t1, capsule_top_color
    sw $t0, capsule_bottom_color
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_move_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
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
    
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_move_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
    jr $ra

no_rotate:
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_move_fail_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
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
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_move_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
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
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_move_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
    jr $ra

no_movge:
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_move_fail_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
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
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_move_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
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
    
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_move_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
    jr $ra

no_move:
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_move_fail_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
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
    
    

skip_adjustment:
    jal draw_capsule            # Draw capsule at the current position
    jal check_collision         # Check for collisions
    jal frame_delay             # Delay for 60 FPS
    j game_loop                 # Repeat

# Trigger Gravity
trigger_gravity:
    li $t2, 0                   # Reset gravity_timer
    sw $t2, gravity_timer       # Store updated timer

    # Call move_down subroutine
    jal move_down               # Move the capsule down

    j game_loop                 # Return to game loop
    
adjust_gravity_speed:
    lw $t3, gravity_threshold   # Load current gravity threshold
    subi $t3, $t3, 1          # Reduce threshold by 1(speeds up gravity)
    lw $t4, min_gravity         # Load minimum gravity threshold
    bge $t3, $t4, update_threshold # Ensure threshold doesn't go below min_gravity
    move $t3, $t4               # Set threshold to min_gravity if exceeded

update_threshold:
    sw $t3, gravity_threshold   # Update gravity threshold
    jr $ra                      # Return to game loop


toggle_pause:
    lw $t0, is_paused        # Load current pause state
    xori $t0, $t0, 1         # Toggle pause state (0 <-> 1)
    sw $t0, is_paused        # Store updated state

    # If now paused, display "Paused" message
    li $t1, 1                # Check if game is paused
    beq $t0, $t1, display_pause_message

    # If now resumed, clear screen or continue
    jr $ra                   # Return to game loop

display_pause_message:
    la $a0, paused_message   # Load "Paused" message
    li $v0, 4                # Syscall for print string
    syscall
    jr $ra                   # Return to game loop
pause_handler:
    # Wait for 'p' key to resume
    jal check_input          # Handle input
    j game_loop              # Stay in pause handler until resumed

 draw_pause_logo:
    # Set white color for the logo
    li $t4, 0xFFFFFF          # $t4 = white
    # Start drawing the first vertical bar
    lw $t0, ADDR_DSPL         # Load base address of display
    addi $a1, $zero, 4 # Set height = 4
    # Draw a line
    add $t5, $zero, $zero	# Set index value ($t5) to zero
    draw_vertical_bar1:
    beq $t5, $a1, end_draw_vertical_bar1  # If $t5 == width ($a1), jump to end
    sw $t4, 248($t0)	#	- Draw a pixel at memory location $t0
    addi $t0, $t0, 128	#	- Increment $t0 by 128
    addi $t5, $t5, 1	#	- Increment $t5 by 1
    j draw_vertical_bar1	#	- Jump to start of line drawing loop
    
    end_draw_vertical_bar1:
    
    lw $t0, ADDR_DSPL         # Load base address of display
    addi $a1, $zero, 4 # Set height = 4
    # Draw a line
    add $t5, $zero, $zero	# Set index value ($t5) to zero
    draw_vertical_bar2:
    beq $t5, $a1, end_draw_vertical_bar2  # If $t5 == width ($a1), jump to end
    sw $t4, 240($t0)	#	- Draw a pixel at memory location $t0
    addi $t0, $t0, 128	#	- Increment $t0 by 128
    addi $t5, $t5, 1	#	- Increment $t5 by 1
    j draw_vertical_bar2	#- Jump to start of line drawing loop
    
    end_draw_vertical_bar2:

end_draw_logo:
    jr $ra
clear_pause_logo:
    # Set white color for the logo
    li $t4, 0x000000          # $t4 = blaxk
    # Start drawing the first vertical bar
    lw $t0, ADDR_DSPL         # Load base address of display
    addi $a1, $zero, 4 # Set height = 4
    # Draw a line
    add $t5, $zero, $zero	# Set index value ($t5) to zero
    clear_vertical_bar1:
    beq $t5, $a1, end_clear_vertical_bar1  # If $t5 == width ($a1), jump to end
    sw $t4, 248($t0)	#	- Draw a pixel at memory location $t0
    addi $t0, $t0, 128	#	- Increment $t0 by 128
    addi $t5, $t5, 1	#	- Increment $t5 by 1
    j clear_vertical_bar1	# - Jump to start of line drawing loop
    
    end_clear_vertical_bar1:
    
    lw $t0, ADDR_DSPL         # Load base address of display
    addi $a1, $zero, 4 # Set height = 4
    # Draw a line
    add $t5, $zero, $zero	# Set index value ($t5) to zero
    clear_vertical_bar2:
    beq $t5, $a1, end_clear_vertical_bar2  # If $t5 == width ($a1), jump to end
    sw $t4, 240($t0)	#	- Draw a pixel at memory location $t0
    addi $t0, $t0, 128	#	- Increment $t0 by 128
    addi $t5, $t5, 1	#	- Increment $t5 by 1
    j clear_vertical_bar2	#- Jump to start of line drawing loop
    
    end_clear_vertical_bar2:

end_clear_logo:
    jr $ra
    
    
    
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
    bne $v0, $t3, destroy_capsules_column      # If not black, skip move

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
    bne $v0, $t3, destroy_capsules_column      # If not black, skip move

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
    bne $v0, $t3, destroy_capsules_column      # If not black, skip move

    jr $ra




# Destroy any capsules that appear in a column
destroy_capsules_column:

addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_drop_capsule_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element

 addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t0, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t1, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t2, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t3, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t4, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t5, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t6, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t7, 0($sp)              # store $ra on the stack
    
    
start_destroy_capsule_column_loop:
li $t6, 5 #lower limit for the rows to check 
li $t7, 30 #upper limit for the rows to check 
li $t8, 2 #lower limit for the columns to check 
li $t9, 19 #upper limit for the columns to check 


outer_loop_column_check_capsule:
    bge $t8, $t9, end_outer_column_check_capsule      # If i >= outer_limit, exit outer loop
    li $t6, 5 #lower limit for the rows to check 

inner_loop_column_check_capsule:
    bge $t6, $t7, end_inner_column_check_capsule      # If j >= inner_limit, exit inner loop
    
    # find current address, save the current address
    mul $t3, $t6, 32         # Row offset (row * bytes_per_row)
    add $t3, $t3, $t8          # Column offset
    sll $t3, $t3, 2            # Multiply by 4 (bytes_per_pixel)
    lw $t4, ADDR_DSPL          # Base display address
    add $t3, $t3, $t4          # Full address    
    
    #save the starting position of the consecutive capsules
    sw $t3, column_start_pos
    
    # Load the colors to check
    lw $s0, color_red
    lw $s1, color_blue
    lw $s2, color_yellow
    lw $s3, virus_red
    lw $s4, virus_blue
    lw $s5, virus_yellow
    
    
    # if current address has color red, yellow, or blue, including the virus colors
    lw $v0, 0($t3)
    
    beq $v0, $s0, column_red_loop
    beq $v0, $s3, column_red_loop
    beq $v0, $s1, column_blue_loop
    beq $v0, $s4, column_blue_loop
    beq $v0, $s2, column_yellow_loop
    beq $v0, $s5, column_yellow_loop
    j column_no_loop
    
    column_red_loop:
    addi $t3, $t3, 128
    
    lw $v0, 0($t3)
    
    beq $v0, $s0, column_red_loop_continue
    beq $v0, $s3, column_red_loop_continue
    j column_consecutive_end
    
    column_red_loop_continue:
    
    lw $t0, count_consecutive
    addi $t0, $t0, 1
    sw $t0, count_consecutive
    j column_red_loop
    
    
    column_blue_loop:
    addi $t3, $t3, 128
    
    lw $v0, 0($t3)
    
    beq $v0, $s1, column_blue_loop_continue
    beq $v0, $s4, column_blue_loop_continue
    j column_consecutive_end
    
    column_blue_loop_continue:
    
    lw $t0, count_consecutive
    addi $t0, $t0, 1
    sw $t0, count_consecutive
    j column_blue_loop
    
    
    column_yellow_loop:
    addi $t3, $t3, 128
    
    lw $v0, 0($t3)
    
    beq $v0, $s2, column_yellow_loop_continue
    beq $v0, $s5, column_yellow_loop_continue
    j column_consecutive_end
    
    column_yellow_loop_continue:
    
    lw $t0, count_consecutive
    addi $t0, $t0, 1
    sw $t0, count_consecutive
    j column_yellow_loop
    
    
    # finished until the next capsule is not the same color
    column_consecutive_end:
    # if count is greater equal to 4, calculate and save the current address as the end address, jump and link to the clear function
    lw $t0, count_consecutive    # Load count_consecutive into $t0
    li $t1, 4
    # Return count_consecutive to 1
    li $t2, 1
    sw $t2, count_consecutive
    
    bge $t0, $t1, column_to_clear
    
    j column_no_loop
    
    column_to_clear:
    # calculate and save the end address
    sw $t3, column_end_pos
    jal clear_column
    # jump back to start_destroy_capsule_column_loop
    j start_destroy_capsule_column_loop
    
    
column_no_loop:
    addi $t6, $t6, 1             # j++
    
    j inner_loop_column_check_capsule                 # Repeat inner loop

end_inner_column_check_capsule:
    addi $t8, $t8, 1             # i++
    j outer_loop_column_check_capsule               # Repeat outer loop

end_outer_column_check_capsule:

# restore all the registers that were stored on the stack
lw $t7, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t6, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t5, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t4, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $t0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    

j destroy_capsules_row







# Destroy any capsules that appear in a column
destroy_capsules_row:


 addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t0, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t1, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t2, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t3, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t4, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t5, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t6, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t7, 0($sp)              # store $ra on the stack
    
    
start_destroy_capsule_row_loop:
li $t6, 5 #lower limit for the rows to check 
li $t7, 30 #upper limit for the rows to check 
li $t8, 2 #lower limit for the columns to check 
li $t9, 19 #upper limit for the columns to check 


outer_loop_row_check_capsule:
    bge $t6, $t7, end_outer_row_check_capsule      # If i >= outer_limit, exit outer loop
    li $t8, 2 #lower limit for the columns to check
inner_loop_row_check_capsule:
    bge $t8, $t9, end_inner_row_check_capsule      # If j >= inner_limit, exit inner loop
    
    # find current address, save the current address
    mul $t3, $t6, 32         # Row offset (row * bytes_per_row)
    add $t3, $t3, $t8          # Column offset
    sll $t3, $t3, 2            # Multiply by 4 (bytes_per_pixel)
    lw $t4, ADDR_DSPL          # Base display address
    add $t3, $t3, $t4          # Full address    
    
    #save the starting position of the consecutive capsules
    sw $t3, row_start_pos
    
    # Load the colors to check
    lw $s0, color_red
    lw $s1, color_blue
    lw $s2, color_yellow
    lw $s3, virus_red
    lw $s4, virus_blue
    lw $s5, virus_yellow
    
    
    # if current address has color red, yellow, or blue, including the virus colors
    lw $v0, 0($t3)
    
    beq $v0, $s0, row_red_loop
    beq $v0, $s3, row_red_loop
    beq $v0, $s1, row_blue_loop
    beq $v0, $s4, row_blue_loop
    beq $v0, $s2, row_yellow_loop
    beq $v0, $s5, row_yellow_loop
    j row_no_loop
    
    row_red_loop:
    addi $t3, $t3, 4
    
    lw $v0, 0($t3)
    
    beq $v0, $s0, row_red_loop_continue
    beq $v0, $s3, row_red_loop_continue
    j row_consecutive_end
    
    row_red_loop_continue:
    
    lw $t0, count_consecutive
    addi $t0, $t0, 1
    sw $t0, count_consecutive
    j row_red_loop
    
    
    row_blue_loop:
    addi $t3, $t3, 4
    
    lw $v0, 0($t3)
    
    beq $v0, $s1, row_blue_loop_continue
    beq $v0, $s4, row_blue_loop_continue
    j row_consecutive_end
    
    row_blue_loop_continue:
    
    lw $t0, count_consecutive
    addi $t0, $t0, 1
    sw $t0, count_consecutive
    j row_blue_loop
    
    
    row_yellow_loop:
    addi $t3, $t3, 4
    
    lw $v0, 0($t3)
    
    beq $v0, $s2, row_yellow_loop_continue
    beq $v0, $s5, row_yellow_loop_continue
    j row_consecutive_end
    
    row_yellow_loop_continue:
    
    lw $t0, count_consecutive
    addi $t0, $t0, 1
    sw $t0, count_consecutive
    j row_yellow_loop
    
    
    # finished until the next capsule is not the same color
    row_consecutive_end:
    # if count is greater equal to 4, calculate and save the current address as the end address, jump and link to the clear function
    lw $t0, count_consecutive    # Load count_consecutive into $t0
    li $t1, 4
    # Return count_consecutive to 1
    li $t2, 1
    sw $t2, count_consecutive
    
    bge $t0, $t1, row_to_clear
    
    j row_no_loop
    
    row_to_clear:
    # calculate and save the end address
    sw $t3, row_end_pos
    jal clear_row
    # jump back to start_destroy_capsule_column_loop
    j start_destroy_capsule_row_loop
    
    
row_no_loop:
    addi $t8, $t8, 1             # j++
    
    j inner_loop_row_check_capsule                 # Repeat inner loop

end_inner_row_check_capsule:
    addi $t6, $t6, 1             # i++
    j outer_loop_row_check_capsule               # Repeat outer loop

end_outer_row_check_capsule:

# restore all the registers that were stored on the stack
lw $t7, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t6, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t5, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t4, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $t0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    


j virus_existence_check





# End the game if all viruses have been destroyed
virus_existence_check:

lw $t0, virus_exist_1        # Load value of virus_exist_1
    lw $t1, virus_exist_2        # Load value of virus_exist_2
    lw $t2, virus_exist_3        # Load value of virus_exist_3
    lw $t3, virus_exist_4        # Load value of virus_exist_4

    beq $t0, 1, start_random_capsule          # If virus_exist_1 == 1, check virus_exist_2


    beq $t1, 1, start_random_capsule          # If virus_exist_2 == 1, check virus_exist_3


    beq $t2, 1, start_random_capsule          # If virus_exist_3 == 1, check virus_exist_4


    beq $t3, 1, start_random_capsule        # If virus_exist_4 == 1, all viruses exist
    
    
    j game_over             # Otherwise, branch to not_all_exist



clear_column:

addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_remove_capsule_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element

 addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t0, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t1, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t2, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t3, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t4, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t5, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t6, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t7, 0($sp)              # store $ra on the stack

# load the start and end positions
lw $t0, column_start_pos
lw $t1, column_end_pos
li $t2, 0x000000           # Black color 
lw $t3, virus_position_1
lw $t4, virus_position_2
lw $t5, virus_position_3
lw $t6, virus_position_4
li $t7, 0

lw $s3, virus_red
    lw $s4, virus_blue
    lw $s5, virus_yellow
    
# start from the start position, make the color black

clear_column_for_loop:
    bge $t0, $t1, clear_column_end_loop        # Exit loop if $t0 >= $t1
    
    sw $t2, 0($t0)
    
    # if the position is the position of a virus, change the virus existence value
    beq $t0, $t3, clear_column_existence_virus_1
    
    beq $t0, $t4, clear_column_existence_virus_2
    
    beq $t0, $t5, clear_column_existence_virus_3
    
    beq $t0, $t6, clear_column_existence_virus_4
    
    j clear_column_no_existence_virus
    
    clear_column_existence_virus_1:
    sw $t7, virus_exist_1
    j clear_column_no_existence_virus
    clear_column_existence_virus_2:
    sw $t7, virus_exist_2
    j clear_column_no_existence_virus
    clear_column_existence_virus_3:
    sw $t7, virus_exist_3
    j clear_column_no_existence_virus
    clear_column_existence_virus_4:
    sw $t7, virus_exist_4
    j clear_column_no_existence_virus
    
    
    clear_column_no_existence_virus:

    addi $t0, $t0, 128             # Increment loop counter ($t0++)
    j clear_column_for_loop                   # Jump back to the start of the loop

clear_column_end_loop:

jal drop_capsule

# restore all the registers that were stored on the stack
lw $t7, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t6, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t5, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t4, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $t0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    

jr $ra




clear_row:

addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_remove_capsule_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
 addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t0, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t1, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t2, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t3, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t4, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t5, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t6, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t7, 0($sp)              # store $ra on the stack
        addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t8, 0($sp)              # store $ra on the stack

# load the start and end positions
lw $t0, row_start_pos
lw $t1, row_end_pos
li $t2, 0x000000           # Black color 
lw $t3, virus_position_1
lw $t4, virus_position_2
lw $t5, virus_position_3
lw $t6, virus_position_4
li $t7, 0

lw $s3, virus_red
    lw $s4, virus_blue
    lw $s5, virus_yellow
    
# start from the start position, make the color black

clear_row_for_loop:
    bge $t0, $t1, clear_row_end_loop        # Exit loop if $t0 >= $t1
    
    sw $t2, 0($t0)
    
    # if the position is the position of a virus, change the virus existence value
    beq $t0, $t3, clear_row_existence_virus_1
    
    beq $t0, $t4, clear_row_existence_virus_2
    
    beq $t0, $t5, clear_row_existence_virus_3
    
    beq $t0, $t6, clear_row_existence_virus_4
    
    j clear_row_no_existence_virus
    
    clear_row_existence_virus_1:
    sw $t7, virus_exist_1
    j clear_row_no_existence_virus
    clear_row_existence_virus_2:
    sw $t7, virus_exist_2
    j clear_row_no_existence_virus
    clear_row_existence_virus_3:
    sw $t7, virus_exist_3
    j clear_row_no_existence_virus
    clear_row_existence_virus_4:
    sw $t7, virus_exist_4
    j clear_row_no_existence_virus
    
    
    clear_row_no_existence_virus:

    addi $t0, $t0, 4             # Increment loop counter ($t0++)
    j clear_row_for_loop                   # Jump back to the start of the loop

clear_row_end_loop:

jal drop_capsule

# restore all the registers that were stored on the stack
lw $t8, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
lw $t7, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t6, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t5, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t4, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $t0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    

jr $ra




# Drop all the capsules on the screen
drop_capsule:

addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t0, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t1, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t2, 0($sp)              # store $ra on the stack
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t3, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t4, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t5, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t6, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $t7, 0($sp)              # store $ra on the stack
    addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $v0, 0($sp)              # store $ra on the stack
    
    
start_drop_check_loop:
li $t0, 5 #lower limit for the rows to check 
li $t1, 30 #upper limit for the rows to check 
li $t2, 2 #lower limit for the columns to check 
li $t3, 19 #upper limit for the columns to check 


# start from the bottom left, check every pixel
outer_loop_drop_check_capsule:
    bge $t2, $t3, end_outer_drop_check_capsule      # If i >= outer_limit, exit outer loop
    li $t1, 30 #upper limit for the rows to check 
inner_loop_drop_check_capsule:
    bge $t0, $t1, end_inner_drop_check_capsule      # If j >= inner_limit, exit inner loop
    
    # find current address, save the current address
    mul $t4, $t1, 32         # Row offset (row * bytes_per_row)
    add $t4, $t4, $t2          # Column offset
    sll $t4, $t4, 2            # Multiply by 4 (bytes_per_pixel)
    lw $t5, ADDR_DSPL          # Base display address
    add $t4, $t4, $t5          # Full address    
    
    
# if the capsule is red or blue or yellow, store the color of the capsule, go to drop function
    lw $v0, 0($t4)
    lw $t5, color_red
    lw $t6, color_blue
    lw $t7, color_yellow
    
    beq $v0, $t5, drop_red_capsule
    beq $v0, $t6, drop_blue_capsule
    beq $v0, $t7, drop_yellow_capsule

    j drop_no_loop
    
    
    drop_red_capsule:
    li $t8, 0x000000           # Black color 
    lw $v0, 128($t4)
    beq $v0, $t8, paint_drop_red_capsule
    
    j drop_no_loop
    paint_drop_red_capsule:
    sw $t8, 0($t4)
    sw $t5, 128($t4)
    j start_drop_check_loop
    
    drop_blue_capsule:
    li $t8, 0x000000           # Black color 
    lw $v0, 128($t4)
    beq $v0, $t8, paint_drop_blue_capsule
    
    j drop_no_loop
    paint_drop_blue_capsule:
    sw $t8, 0($t4)
    sw $t6, 128($t4)
    j start_drop_check_loop
    
    
    drop_yellow_capsule:
    li $t8, 0x000000           # Black color 
    lw $v0, 128($t4)
    beq $v0, $t8, paint_drop_yellow_capsule
    
    j drop_no_loop
    paint_drop_yellow_capsule:
    sw $t8, 0($t4)
    sw $t7, 128($t4)
    j start_drop_check_loop
    
    
    
drop_no_loop:
    subi $t1, $t1, 1             # j--
    
    j inner_loop_drop_check_capsule                 # Repeat inner loop

end_inner_drop_check_capsule:
    addi $t2, $t2, 1             # i++
    j outer_loop_drop_check_capsule               # Repeat outer loop

end_outer_drop_check_capsule:

# restore all the registers that were stored on the stack
lw $v0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
lw $t7, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t6, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t5, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t4, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t3, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t2, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $t1, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
     lw $t0, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    


jr $ra



# Frame Delay Subroutine
frame_delay:
    li $t0, 100         # Adjust this value for your system
frame_delay_loop:
    subi $t0, $t0, 1
    bnez $t0, frame_delay_loop
    jr $ra

game_over_success:
addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_game_over_success_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
j quit_game

game_over:
# Quit Game Subroutine

addi $sp, $sp, -4           # move the stack pointer to the next empty spot on the stack
    sw $ra, 0($sp)              # store $ra on the stack
    jal play_game_over_fail_sound
    lw $ra, 0($sp)              # restore $ra from the stack
    addi $sp, $sp, 4            # move the stack pointer to the new top element
    
quit_game:
    li $v0, 10              # Exit syscall
    syscall
    # 2a. Check for collisions
    
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop

