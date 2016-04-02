#!/bin/bash 

CAR_SHAPE=" # \n###\n # \n# #"
declare -i car_x
declare -i car_y
car_x=6
car_y=13
pc=5
BDR_L=3
BDR_R=9
BDR_T=1
BDR_B=14
opp_exist=0
death=0
score=0
echo -e "\33[1m"
trap on_exit ERR EXIT 
function on_exit() {
	printf "\e[?9l"          # Turn off mouse reading
	printf "\e[?12l\e[?25h"  # Turn on cursor
	stty "$_STTY"            # reinitialize terminal settings
	tput sgr0
	clear
}

function echo_boderline() {
	bdr=("#" " " "#")
	offset=$((${2}%3))
	bdr_pos=$1
	for ((i=0; i<$(($height-3)); i++)) ; do
		echo -e "\e[$((${i}*3));${bdr_pos}H${bdr[$((($offset+2)%3))]}"
		echo -e "\e[$((${i}*3+1));${bdr_pos}H${bdr[$((($offset+1)%3))]}"
		echo -e "\e[$((${i}*3+2));${bdr_pos}H${bdr[$((($offset+0)%3))]}"
	done
}
function echo_border() {
	width=$1
	height=$2
	offset=$3
	echo_boderline 0 $offset
	echo_boderline $width $offset
}
function echo_car() {
	if (($1 >= 0)); then
	echo -e "\e[${1};${2}H # "
	fi
	
	if (($1 >= -1)); then
	echo -e "\e[$((${1}+1));${2}H###"
	fi
	
	if (($1 >= -2)); then
	echo -e "\e[$((${1}+2));${2}H # "
	fi
	
	if (($1 >= -3)); then
	echo -e "\e[$((${1}+3));${2}H# #"
	fi
}

bdr_offset=0
function die() {
		clear
		echo -e "\e[5;5HGAME OVER"
		echo -e "\e[7;5HSCORE:" $score
}
function move() {
	
	( sleep 0.07; kill -ALRM $$ ) &
	
	clear
	if [ $death -eq 1 ]; then
		die
	else
		bdr_offset=$(($bdr_offset+1))
		echo -e "\e[5;15HSCORE:${score}"

		echo_car $car_y $car_x
		echo_border 13 9 $bdr_offset
		let score+=1
		if [ $opp_exist -eq 0 -a $(($RANDOM%2)) -eq 1 ]
		then
			opp_exist=1
			opp_y=-1
		case $(($RANDOM%3)) in
			0) opp_x=3 ;;
			1) opp_x=6 ;;
			2) opp_x=9 ;;
		esac
			
		fi

		opp_y=$(($opp_y+1))
		
		if (($opp_y > BDR_B+3)); then
			opp_exist=0
		fi
		
		if [ $opp_exist -eq 1 ] ; then
			echo_car $opp_y $opp_x
		fi
		
		if [ $opp_exist -eq 1 ] && [ $car_x -gt $(($opp_x-1)) ] && [ $car_x -lt $(($opp_x+3)) ]  && [ $car_y -gt $(($opp_y-1)) ] && [ $car_y -lt $(($opp_y+4)) ] ; then
			death=1
		elif [ $opp_exist -eq 1 ] && [ $(($car_x+2)) -gt $(($opp_x-1)) ] && [ $(($car_x+2)) -lt $(($opp_x+3)) ]  && [ $car_y -gt $(($opp_y-1)) ] && [ $car_y -lt $(($opp_y+4)) ] ; then
			death=1
		elif [ $opp_exist -eq 1 ] && [ $(($car_x+2)) -gt $(($opp_x-1)) ] && [ $(($car_x+2)) -lt $(($opp_x+3)) ]  && [ $(($car_y+3)) -gt $(($opp_y-1)) ] && [ $(($car_y+3))  -lt $(($opp_y+4)) ] ; then
			death=1
		elif [ $opp_exist -eq 1 ] && [ $car_x -gt $(($opp_x-1)) ] && [ $car_x -lt $(($opp_x+3)) ]  && [ $(($car_y+3))  -gt $(($opp_y-1)) ] && [ $(($car_y+3))  -lt $(($opp_y+4)) ] ; then
			death=1
		fi
	fi
}


trap move ALRM

# Hide the cursor
printf "\e[?25l"

move

while :
do
	read -rsn3 -d '' PRESS
	
	KEY=${PRESS:2}
	
		case "$KEY" in
			A) car_y=$((car_y-1)) ;;		# Up
			B) car_y=$((car_y+1)) ;; 		# Down
			C) car_x=$((car_x+1)) ;; 		# Right	
			D) car_x=$((car_x-1)) ;;		# Left
		esac

		if (( $car_x < $BDR_L )) ; then
			car_x=$BDR_L
		elif (( $car_x > $BDR_R )) ; then
			car_x=$BDR_R
		fi

		if (( $car_y > $BDR_B )) ; then
			car_y=$BDR_B
		elif (( $car_y < $BDR_T )) ; then
			car_y=$BDR_T
		fi	
done
