echo -n "gmic fromRawCon_off8bit.tif -fx_customize_clut 100,3,10,0,0,0,0,0,0,1,8,0.5,"; paste <(sed '$ d' shot_user.txt | tail -n '+8') <(sed '$ d' fromRawCon_user8bit_beforeCA.txt | tail -n '+8') | awk '{print "2,"int($11*255)","int($12*255)","int($13*255)","int($3*255)","int($4*255)","int($5*255)}' | tr "\n" ,| sed -e "s/,$/ -o color_graded.tif/g"