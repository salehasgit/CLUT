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

Let's start with an example and consider 96 swatch colors of DigitalSG colorChecker from this image:

<img src="IN/img01_canon.png" alt="" width="400"/>

Now let's assume that we would like to build a CLUT that will map all but only, and only, these 96 colors to the pure black color (0,0,0). To do so, we build a one-column 96x1 src image, filled with samples from 96 patches (using a 11x11 average window) as well as a pure black dst image with the same size and then call the script (we will explain the arguments shortly):
```
$ gmic -m custom.gmic clut_from_kp doc_materials/kp_img01_apple_DigitalSG_96colors.png,doc_materials/kp_img01_apple_DigitalSG_all96toBlack.png,doc_materials/OUT,all96toBlack.cube,1,0,0,64
```
Now let's plot the generated clut (left) and its color distribution (right):

<img src="doc_materials/OUT/cube_LUT_US0_KI0_CR64_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>
<img src="doc_materials/OUT/color_distribution_of_LUT_US0_KI0_CR64_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>

For the sake of demonstration, for each keypoint, we also plot a small sphere at the src location inside the cube and set its color to the dst color. 

Please note that, for this particular lut, the difference between the clut and its color distribution are visually undetectable since only a small number of colors (96 out of 64^3=262144 colors) are being manipulated. Nevertheless, applying the lut on the original image will map all 96 colors to pure black, without touching/`influencing` any other color:
```
$ gmic -input_cube doc_materials/OUT/lut_US0_KI0_CR64_clut_from_kp_all96toBlack.cube IN/img01_canon.png +map_clut. [0] -o. doc_materials/OUT/src_colorGraded_by_lut_US0_KI0_CR64_clut_from_kp_all96toBlack.cube.png
```
<img src="doc_materials/OUT/src_colorGraded_by_lut_US0_KI0_CR64_clut_from_kp_all96toBlack.cube.png" alt="" width="400"/>

 Hopefully it is clear that by setting the Keypoint influence to zero, we are generating a lut that will only affect/alter src keypoints in the color cube to their dst colors and the rest of cube will be identical to the neutral LUT.

To further visualize the effect of this argument,let's set the keypoint influence to 50% and also plot some cross sections of the clut cube:  
```
$ gmic -m custom.gmic clut_from_kp doc_materials/kp_img01_apple_DigitalSG_96colors.png,doc_materials/kp_img01_apple_DigitalSG_all96toBlack.png,doc_materials/OUT,all96toBlack.cube,1,0,50,128
```

<img src="doc_materials/OUT/cube_LUT_US0_KI50_CR128_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>
<img src="doc_materials/OUT/color_distribution_of_LUT_US0_KI50_CR128_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>

<img src="doc_materials/50%.png" alt="" width="400"/>

<img src="doc_materials/OUT/src_colorGraded_by_lut_US0_KI50_CR64_clut_from_kp_all96toBlack.cube.png" alt="" width="400"/>

As we increase the influence percentage, the dst color of the src keypoints will smoothly spread to the surrounding colors, creating a smoother transition and at the same time altering the surrounding `neutral` colors accordingly (this is especially visible in the 3D color distribution of the LUT, where empty areas in the cube indicate missing destination colors).
By spreading black into the surrounding colors, we are pushing highly saturated colors to the zero saturation corner of the color cube. At 100% influence, it should not come as a surprise then to see the content of the lut to be reduced to a pure black color sitting on (0,0,0) corner of the cube and the lut to map each and evry color to the black: 

<img src="doc_materials/OUT/cube_LUT_US0_KI100_CR64_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>
<img src="doc_materials/OUT/color_distribution_of_LUT_US0_KI100_CR64_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>

<img src="doc_materials/OUT/src_colorGraded_by_lut_US0_KI100_CR64_clut_from_kp_all96toBlack.cube.png" alt="" width="400"/>


## Cube resolution

You may have noticed that when generating the clut with 50% keypoint influence above, we set the cube resolution to 128 instead of default 64, despite a higher computational time. We did so to have a more dense visualization of the cube voxels but there is also a practical advantage in setting the cube resolution to higher values:

`As long as the cube resolution is equal or higher than 256, the resulting LUT will always map, precisely, the keypoint colors to their destination colors, no matter what uniform sampling and influence values are chosen, otherwise the exact color transfer of the keypoints may not happen due to downsampling of the keypoints location during the optimization. Also, even if the cube resolution is hight enough, when saving the cube as a 252x252 png file (hence reducing the cube resolution to 64), some precision is lost and keypoints can only be mapped to their destination colors up to the interpolation accuracy.`

To better understand, consider the following image, composed of 5 column images, where the first and last images are src and dst images respectively and 2th, 3th and 4th images are result of applying luts generated at 64, 128 and 256 cube resolutions on the first image.

<img src="doc_materials/cube-resolution.png" alt="" width="400"/>

In summary, if we can handle heavy .cube or large .png lut files, then we can set the cube resolution to 256 to be sure that all src colors are mapped exactly to dst colors.

## Uniform Sampling
to demonstrate this, let's create two small images from our src and dst 96 samples:

<img src="doc_materials/keypoints_src_SG8x6_left-half.png" alt="" width="200"/>
<img src="doc_materials/keypoints_dst_SG8x6_left-half.png" alt="" width="200"/>
