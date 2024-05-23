#  custom.gmic
#
#  Created by Saleh Mosaddegh on 28/07/2020, Haarlem.
#  Copyright © 2020 StyleShoots. All rights reserved.
#=================================================================================================================================
# Run this script first to generate the one-column color keypoint image for the custom script "clut_from_customKeypoints".
#
# $ ./generate_keypoinImageFromTXT.sh keypoints.txt result_folder image_nameWithExt
# keypoints.txt           : txt file with RGB values in columns 3,4 and 5, each row one color, starting from row 9 with an extra line after the last color. This format corresponds with 3DLUTCreator colorChart format.
# result_folder        : output folder
# image_nameWithExt        : name of the one-column image of color keypoints and format (via extension)

# e.g. $./generate_keypoinImageFromTXT.sh dropBox/IN/keypoints/IT8/+1_apple_IT8.txt  dropBox/OUT/IT8_dev-vertical/ +1_apple_IT8.png

args=("$@")
OUT_folder="${args[1]}"
mkdir $OUT_folder

src_keypoints_txt="${args[0]}"

src_r=$(echo -n ""; (sed '$ d' $src_keypoints_txt | tail -n '+9') | awk '{print ""int($3*255)}' | tr "\n" ,| sed -e "s/,$//g")
src_g=$(echo -n ""; (sed '$ d' $src_keypoints_txt | tail -n '+9') | awk '{print ""int($4*255)}' | tr "\n" ,| sed -e "s/,$//g")
src_b=$(echo -n ""; (sed '$ d' $src_keypoints_txt | tail -n '+9') | awk '{print ""int($5*255)}' | tr "\n" ,)

src_RGB=("${src_r[@]}","${src_g[@]}","${src_b[@]}")
echo $src_RGB

gridSizeBY3=$(echo "$src_RGB" | awk '{print gsub(/,/, "")}')

image_nameWithExt="${args[2]}"
gmic -input 1,{$gridSizeBY3/3},1,3  -fill. $src_RGB -rotate 180 c. 0,255 o $OUT_folder/kp_$image_nameWithExt -d
