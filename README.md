# CLUT
generating CLUT via G'MIC

The most comprehensive command is the custom command "clut_from_customKeypoints" in the custom.gmic file. It allows selecting various uniform samplings as well as the cube resolution and can be extended to lock some custom keypoints. The first two arguments are 2 one-column images src.png and dst.png in which each row corresponds to one color keypoint. Run "generate_keypoinImageFromTXT.sh" to generate a keypoint image from a txt file. Once the keypoint images are generated, one can run the custom script on them to generate the CLUT .

See each script for more details about the arguments and parameters.

$ ./generate_keypoinImageFromTXT.sh dropBox/IN/keypoints/IT8/+1_apple_IT8.txt  dropBox/OUT/IT8_dev-vertical/ +1_apple_IT8.png
$ ./generate_keypoinImageFromTXT.sh dropBox/IN/keypoints/IT8/+1_canon_IT8.txt  dropBox/OUT/IT8_dev-vertical/ +1_canon_IT8.png
$ gmic -m custom.gmic clut_from_customKeypoints dropBox/OUT/IT8_dev-vertical/keypoints_+1_apple_IT8.png,dropBox/OUT/IT8_dev-vertical/keypoints_+1_canon_IT8.png,dropBox/OUT/IT8_dev-vertical/,IT8.png,3,100,64
or
$ gmic -m custom.gmic clut_from_ab dropBox/OUT/IT8_dev-vertical/keypoints_+1_apple_IT8.png,dropBox/OUT/IT8_dev-vertical/keypoints_+1_canon_IT8.png,dropBox/OUT/IT8_dev-vertical/,IT8.png,3,100,64

