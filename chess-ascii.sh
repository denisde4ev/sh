#!/bin/sh

set -f
IFS=' 
'

esc=$(printf \\33)

# note: no detection if terminal supports rgb collors
fgcolor_black=$esc'[38;2;0;0;0m'
fgcolor_gray=$esc'[38;2;127;127;127m'
fgcolor_white=$esc'[38;2;255;255;255m'

bgcolor_light=$esc'[48;2;240;218;181m'
bgcolor_dark=$esc'[48;2;181;135;99m'
colors_reset=$esc'[0m'

esc_move_right=$esc'[C'
esc_move_right2=$esc'[2C'

#peaces='♔ ♕ ♖ ♗ ♘ ♙'
#peaces_filled='♚ ♛ ♜ ♝ ♞ ♟'

#board_peaces_line1='♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖ '
board_peaces_line1_from1_by2='♖ ♗ ♔ ♘ '
board_peaces_line1_from2_by2='♘ ♕ ♗ ♖ '
#board_peaces_line2='♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙ '
board_peaces_line2_half='♙ ♙ ♙ ♙ '



printf %s "$fgcolor_black" # for lines 1 2
{ # line 1

	printf %s "$bgcolor_light"
	printf %s" $esc_move_right2" ${board_peaces_line1_from1_by2}

	printf \\r"$esc_move_right2"

	printf %s "$bgcolor_dark"
	printf %s" $esc_move_right2" ${board_peaces_line1_from2_by2}

	printf \\n
}

{ # line 2

	printf %s "$bgcolor_dark"
	printf %s" $esc_move_right2" ${board_peaces_line2_half}

	printf \\r"$esc_move_right2"

	printf %s "$bgcolor_light"
	printf %s" $esc_move_right2" ${board_peaces_line2_half}

	printf \\n
}


{ # line 3 4 5 6

	printf %s "$fgcolor_gray" # just because
	printf %s\\n\
		"$bgcolor_light  $bgcolor_dark  $bgcolor_light  $bgcolor_dark  $bgcolor_light  $bgcolor_dark  $bgcolor_light  $bgcolor_dark  " \
		"$bgcolor_dark  $bgcolor_light  $bgcolor_dark  $bgcolor_light  $bgcolor_dark  $bgcolor_light  $bgcolor_dark  $bgcolor_light  " \
		"$bgcolor_light  $bgcolor_dark  $bgcolor_light  $bgcolor_dark  $bgcolor_light  $bgcolor_dark  $bgcolor_light  $bgcolor_dark  " \
		"$bgcolor_dark  $bgcolor_light  $bgcolor_dark  $bgcolor_light  $bgcolor_dark  $bgcolor_light  $bgcolor_dark  $bgcolor_light  " \
	;

}



printf %s "$fgcolor_white" # for lines 7 8
{ # line 7

	printf %s "$bgcolor_light"
	printf %s" $esc_move_right2" ${board_peaces_line2_half}

	printf \\r"$esc_move_right2"

	printf %s "$bgcolor_dark"
	printf %s" $esc_move_right2" ${board_peaces_line2_half}

	printf \\n
}

{ # line 8

	printf %s "$bgcolor_dark"
	printf %s" $esc_move_right2" ${board_peaces_line1_from1_by2}

	printf \\r"$esc_move_right2"

	printf %s "$bgcolor_light"
	printf %s" $esc_move_right2" ${board_peaces_line1_from2_by2}

	printf \\n
}

printf "\\r"



printf %s "$colors_reset"
