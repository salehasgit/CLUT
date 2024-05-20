# given src and dst keypoints, this script generates the CLUT that maps the src colors to the dst colors
#
# $ ./generate_CLUT.sh src.txt dst.txt colorCard interpolation_tech cube_resolution setup_exposure result_folder
# src/dst.txt           : txt file with RGB values in columns 3,4 and 5, each row one color, starting from row 9 with an extra line after the last color. This format corresponds with 3DLUTCreator colorChart format.
# colorCard              : SG, IT8 or SG+IT8
# cube_resolution       : resolution higher than 64 is not usually noticable.
# setup_exposure        : the exposure corresponding to the src snd dst keypoints, only for the purpose of proper naming(no effect on the final CLUT)
# result_folder        : output folder


args=("$@")
OUT_folder="${args[6]}"
mkdir $OUT_folder

src_keypoints_txt="${args[0]}"
dst_keypoints_txt="${args[1]}"

# src_dst_keypoints=$(echo -n ""; paste <(sed '$ d' shot_user.txt | tail -n '+8') <(sed '$ d' fromRawCon_user8bit_beforeCA.txt | tail -n '+8') | awk '{print ""int($11*255)","int($12*255)","int($13*255)","int($3*255)","int($4*255)","int($5*255)}' | tr "\n" ,| sed -e "s/,$//g")

src_r=$(echo -n ""; (sed '$ d' $src_keypoints_txt | tail -n '+9') | awk '{print ""int($3*255)}' | tr "\n" ,| sed -e "s/,$//g")
src_g=$(echo -n ""; (sed '$ d' $src_keypoints_txt | tail -n '+9') | awk '{print ""int($4*255)}' | tr "\n" ,| sed -e "s/,$//g")
src_b=$(echo -n ""; (sed '$ d' $src_keypoints_txt | tail -n '+9') | awk '{print ""int($5*255)}' | tr "\n" ,| sed -e "s/,$//g")
dst_r=$(echo -n ""; (sed '$ d' $dst_keypoints_txt | tail -n '+9')  | awk '{print ""int($3*255)}' | tr "\n" ,| sed -e "s/,$//g")
dst_g=$(echo -n ""; (sed '$ d' $dst_keypoints_txt | tail -n '+9')  | awk '{print ""int($4*255)}' | tr "\n" ,| sed -e "s/,$//g")
dst_b=$(echo -n ""; (sed '$ d' $dst_keypoints_txt | tail -n '+9')  | awk '{print ""int($5*255)}' | tr "\n" ,| sed -e "s/,$//g")

# src_r=$(echo -n ""; (cat -- $src_keypoints_txt ) | awk '{print ""int($3*255)}' | tr "\n" ,| sed -e "s/,$//g")
# src_g=$(echo -n ""; (cat -- $src_keypoints_txt ) | awk '{print ""int($4*255)}' | tr "\n" ,| sed -e "s/,$//g")
# src_b=$(echo -n ""; (cat -- $src_keypoints_txt ) | awk '{print ""int($5*255)}' | tr "\n" ,| sed -e "s/,$//g")
# dst_r=$(echo -n ""; (cat -- $dst_keypoints_txt ) | awk '{print ""int($3*255)}' | tr "\n" ,| sed -e "s/,$//g")
# dst_g=$(echo -n ""; (cat -- $dst_keypoints_txt ) | awk '{print ""int($4*255)}' | tr "\n" ,| sed -e "s/,$//g")
# dst_b=$(echo -n ""; (cat -- $dst_keypoints_txt ) | awk '{print ""int($5*255)}' | tr "\n" ,| sed -e "s/,$//g")

src_dst_R=("${src_r[@]}","${dst_r[@]}")
src_dst_G=("${src_g[@]}","${dst_g[@]}")
src_dst_B=("${src_b[@]}","${dst_b[@]}")
src_RGB=("${src_r[@]}","${src_g[@]}","${src_b[@]}")
dst_RGB=("${dst_r[@]}","${dst_g[@]}","${dst_b[@]}")

src_dst_RGB=("${src_dst_R[@]}","${src_dst_G[@]}","${src_dst_B[@]}")
# echo $src_dst_RGB

#find the grid size
card="${args[2]}"
case $card in
SG)
    grid_size="12,8"
    keypoins_size="96"
    ;;

SGmix2)
    grid_size="24,8"
    keypoins_size="192"
    ;;

SGmix4)
    grid_size="48,8"
    keypoins_size="384"
    ;;

IT8)
    grid_size="22,12"
    keypoins_size="264"
    ;;

SG+IT8)
    grid_size="12,30"
    keypoins_size="360"
    ;;

1Pixel)
    grid_size="1,1"
    keypoins_size="1"
    ;;

2Pixel)
    grid_size="2,1"
    keypoins_size="2"
    ;;

*)
    echo -n "card is unknown"
    ;;
esac

gmic -input $grid_size,1,3  -fill. $src_RGB -output. $OUT_folder/keypoints_src_$card.png
gmic -input $grid_size,1,3  -fill. $dst_RGB -output. $OUT_folder/keypoints_dst_$card.png

gmic -input $keypoins_size,2,1,3  -fill. $src_dst_RGB  -rotate -90 -output. $OUT_folder/keypoints_${card}_${keypoins_size}x2.png

# interpolate using decompress_clut_rbf (cld be decompress_clut_pde which is better for large keypoint sets)
# first argument is interpolation technique
interpolation_method="${args[3]}"
case $interpolation_method in
rbf)
    method="decompress_clut_rbf"
    ;;

pde)
    method="decompress_clut_pde"
    ;;

rbf+pde)
    method="decompress_clut"
    ;;

*)
    echo -n "method is unknown"
    ;;
esac

cube_resolution="${args[4]}"
setup_exposure="${args[5]}"
gmic $OUT_folder/keypoints_${card}_${keypoins_size}x2.png s x a c $method $cube_resolution c. 0,255 -o. $OUT_folder/lut${cube_resolution}_${card}_${method}_exp_$setup_exposure.cube # puts srs and dst in chennel 0 and 1 of a 1 column img, then runs the decompress on it, cut the result to 0-255 and save it in .cube file

#visualize the cube 
gmic $OUT_folder/lut${cube_resolution}_${card}_${method}_exp_$setup_exposure.cube distribution3d colorcube3d primitives3d 1 add3d

#test: compress again!
# gmic -input_cube lut64_${card}_$method.cube -compress_clut 1.25,0.75,${keypoins_size} -o keypoints_${card}_compressed.png

#convert to Haldclut png    
gmic -input_cube $OUT_folder/lut${cube_resolution}_${card}_${method}_exp_$setup_exposure.cube  -r ${cube_resolution},${cube_resolution},${cube_resolution},3,3 -r 512,512,1,3,-1 -o $OUT_folder/lut${cube_resolution}_${card}_${method}_exp_$setup_exposure.png

# checking:
# fx_apply_haldclut 2,"/Users/sm/Dropbox (VR Holding BV)/LUT experiments/Real/Lab_transfer_test/lut64.png",100,0,0,0,0,0,0,0,50,50
gmic $OUT_folder/keypoints_src_$card.png -input_cube $OUT_folder/lut${cube_resolution}_${card}_${method}_exp_$setup_exposure.cube  +map_clut[0] [1] -o. $OUT_folder/keypoints_src_${card}_mapped_BY_lut${cube_resolution}_${card}_${method}_exp_$setup_exposure.png -d

# [G'MIC] Customize CLUT: fx_customize_clut 100,1,10,0,0,0,0,0,0,1,8,0.5,2,0,0,0,255,255,255,1,255,0,0,255,255,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 #1
