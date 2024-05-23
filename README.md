# CLUT

This collection of scripts helps with the use of https://gmic.eu with the generation of CLUT (Color Look-Up Table) files for "transferring" colors from a source image to a desired target. 

## Generating CLUT via G'MIC

The main script is `custom.gmic` file which contains a set of custom commands for generating and visualizing CLUTs, mainly  `clut_from_kp` and  `clut_from_ab`. 
The argument list for both commands are identical and comma-separated: (See the script for more details.):
```
gmic -m custom.gmic clut_from_kp src.png,dst.png,outFolder,clutName.ext,plotNsaveIntermediateResults,uniformSampling,keypointsInfluence,cubeResolution
```
The first two arguments are 2 one-column images `src.png` and `dst.png` in which each row corresponds to one color keypoint. Run `generate_keypoinImageFromTXT.sh` to generate such keypoint images from txt files containing RGB values of color samples (See the script for the format of the text file). 

```
$ ./generate_keypoinImageFromTXT.sh IN/kp_img01_apple_IT8.txt  OUT/ img01_apple_IT8.png
$ ./generate_keypoinImageFromTXT.sh IN/kp_img01_canon_IT8.txt  OUT/ img01_canon_IT8.png
```

Once the keypoint images are generated, run the custom script on them to generate the CLUT, e.g.:

```
$ gmic -m custom.gmic clut_from_kp OUT/img01_apple_IT8.png,OUT/img01_canon_IT8.png,OUT/CLUTs/,img01_IT8.png,plotNsaveIntermediateResults,3,100,64
```
or
```
$ gmic -m custom.gmic clut_from_ab IN/img02_apple.png,IN/img02_apple_graded_by_Humphrey.png,OUT/CLUTs/,img02.png,plotNsaveIntermediateResults,3,100,64
```

Among two, the most comprehensive command is the custom command `clut_from_kp`. It allows selecting various uniform samplings as well as the cube resolution and can be extended to lock some custom keypoints.
Run `clut_from_ab` instead if the input images are not one-column and there is not any topological/structural differences between two images. The advantage is that this commands can handle all pixels from even large images and there is no need for extracting RGB values of color samples into txt files and building keypoints images.

See each script for more details about the arguments and parameters.

## Installing GMIC
On MacOS, tested with GMIC v 2.9.1
* option 1: homebrew : `brew install gmic`
* option 2: download tarball : `https://github.com/Benitoite/gmic-osx/releases/download/continuous/gmic-cli.tgz`

## Background (and understanding the parameters)

Setting the Keypoints Influence to zero, will only affect/alter src keypoints in the color cube to their dst colors and the rest of cube will be identical to the neutral LUT. As we increase the influence, the dst color of the src keypoints will smoothly spread to the surrounding colors, creating a smoother transition and at the same time altering the surrounding `neutral` colors accordingly (this is especially visible when plotting the 3D color distribution of the LUT, where empty areas in the cube indicate missing destination colors).

As an example, assume that we would like to build a CLUT that will map only, and only, the pure black color (0,0,0) to a pure white (255,255.255). To do so, we need to build src and dst images with size 1pixel and fill them with black and white respectively and then call the script with keypoints influence and also the uniform sampling set to zero (we will explain the latter one later).
```
$ gmic -m custom.gmic clut_from_kp report/kp_src_1kp.png,report/kp_dst_1kp.png,report/OUT,black2white.cube,1,0,0,64
```
<img src="./report/OUT/cube_LUT_US0_KI0_CR64_clut_from_kp_black2white.cube.png" alt="" width="200"/>
<img src="./report/OUT/color_distribution_of_LUT_US0_KI0_CR64_clut_from_kp_black2white.cube.png" alt="" width="200"/>


For the sake of demonstration, we are plotting a small sphere at the src location inside the cube with the dst color. Also please note that the difference between the clut and its color distribution are visually undetectable since the difference is in only one color (out of 64^3=262144 colors).
The procedure for any number of colors is the same. For example consider the 96 colors of DigitalSG colorChecker from this image:
![DigitalSG colorChecker](IN/img01_canon.png)
and let's generate a CLUT which will map all these colors to pure black!
```
$ gmic -m custom.gmic clut_from_kp report/kp_img01_canon_DigitalSG_all96.png,report/kp_dst_1kp.png,report/OUT,black2white.cube,1,0,0,64
```
<img src="report/OUT/cube_LUT_US0_KI0_CR256_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>
<img src="report/OUT/color_distribution_of_LUT_US0_KI0_CR256_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>


Again, please note that the difference between the clut and its color distribution are visually undetectable but nevertheless, applying the lut on the original image will set all 96 colors to pure black, without touching/`influencing` any other color:
```
$ gmic -input_cube report/OUT/lut_US0_KI0_CR256_clut_from_kp_all96toBlack.cube IN/img01_canon.png +map_clut. [0] -o. report/OUT/src_colorGraded_by_lut_US0_KI0_CR256_clut_from_kp_all96toBlack.cube.png
```
<img src="report/OUT/src_colorGraded_by_lut_US0_KI0_CR256_clut_from_kp_all96toBlack.cube.png" alt="" width="400"/>

You may have noticed that we set the cube resolution to 256 instead of default 64 and there is a good reason for that:

important note: as long as the cube resolution is equal or higher than 256, the resulting LUT will always map the keypoints colors to their destination colors precisely, no matter what uniform sampling and influence values are chosen, otherwise the exact color transfer of the keypoints may not happen due to downsampling of the keypoints location during the optimization. Also when saving the cube as a 252x252 png file (hence reducing the cube resolution to 64), some precision is lost and keypoints may not be mapped exactly to their destination colors due to the interpolation during mapping.

Since 

<img src="report/OUT/cube_LUT_US0_KI50_CR128_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>
<img src="report/OUT/color_distribution_of_LUT_US0_KI50_CR128_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>