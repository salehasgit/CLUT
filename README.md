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
The main engine behind the script is an inpainting technique that uses a multiscale delaunay-guided diffusion algorithm developed by Greyc's IMAGE team to fill a RGB color cube which is already partially filled by a set of target/destination colors. In the following, we will further explain the script and its arguments via some examples.

### keypoint influence percentage

Consider the following image and its 96 color patches of DigitalSG colorChecker:

<img src="IN/img01_canon.png" alt="" width="400"/>

Let's assume that we would like to build a CLUT that will map all but only, and only, these 96 colors to the pure black color (0,0,0). To do so, we build a one-column 96x1 src image, filled with samples from 96 patches (using a 11x11 average window) as well as a pure black dst image with the same size and then call the script (we will explain the arguments shortly):
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

 By setting the Keypoint influence to zero, we are generating a lut that will only affect/alter src keypoints in the color cube to their dst colors and the rest of cube will be identical to the neutral LUT.

To further visualize the effect of this argument,let's set the keypoint influence to 50% and also plot some cross sections of the clut cube:  
```
$ gmic -m custom.gmic clut_from_kp doc_materials/kp_img01_apple_DigitalSG_96colors.png,doc_materials/kp_img01_apple_DigitalSG_all96toBlack.png,doc_materials/OUT,all96toBlack.cube,1,0,50,128
```

<img src="doc_materials/OUT/cube_LUT_US0_KI50_CR128_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>
<img src="doc_materials/OUT/color_distribution_of_LUT_US0_KI50_CR128_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>

<img src="doc_materials/50%.png" alt="" width="400"/>

<img src="doc_materials/OUT/src_colorGraded_by_lut_US0_KI50_CR64_clut_from_kp_all96toBlack.cube.png" alt="" width="400"/>

As we increase the influence percentage, the dst color of the src keypoints will smoothly spread to the surrounding colors, creating a smoother transition and at the same time altering the surrounding `neutral` colors accordingly (this is especially visible in the 3D color distribution of the LUT, where empty areas in the cube indicate missing destination colors).
By spreading black into the surrounding colors, we are pushing highly saturated colors to the zero saturation corner of the color cube. At 100% influence, it should not come as a surprise then to see the content of the lut to be reduced to a pure black color sitting on (0,0,0) corner of the cube and the lut to map each and every color to the black: 

<img src="doc_materials/OUT/cube_LUT_US0_KI100_CR64_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>
<img src="doc_materials/OUT/color_distribution_of_LUT_US0_KI100_CR64_clut_from_kp_all96toBlack.cube.png" alt="" width="200"/>

<img src="doc_materials/OUT/src_colorGraded_by_lut_US0_KI100_CR64_clut_from_kp_all96toBlack.cube.png" alt="" width="400"/>

We conclude this section with a realistic example (the last image is showing the difference between the dst image (canon) and the src image (apple) color-graded by the resulting CLUT):

```
$ gmic -m custom.gmic clut_from_kp doc_materials/kp_img01_apple_DigitalSG_96colors.png,doc_materials/kp_img01_apple_DigitalSG_all96toBlack.png,doc_materials/OUT,all96toBlack.cube,1,0,50,128
```

<img src="doc_materials/OUT/cube_LUT_US0_KI50_CR64_clut_from_kp_apple2canon.cube.png" alt="" width="200"/>
<img src="doc_materials/OUT/color_distribution_of_LUT_US0_KI50_CR64_clut_from_kp_apple2canon.cube.png" alt="" width="200"/>

<img src="doc_materials/OUT/src_colorGraded_by_lut_US0_KI50_CR64_clut_from_kp_apple2canon.cube.png" alt="" width="400"/>

<img src="doc_materials/OUT/diff_apple2canon.png" alt="" width="400"/>

### Cube resolution

In the previous section, When generating the clut with 50% keypoint influence, we set the cube resolution to 128 instead of default 64, despite a higher computational time. We did so to have a more dense visualization of the cube voxels but there is also a practical advantage in setting the cube resolution to higher values:

`As long as the cube resolution is equal or higher than 256, the resulting LUT will always map, precisely, the keypoint colors to their destination colors, no matter what uniform sampling and influence percentage values are chosen, otherwise the exact color transfer of the keypoints may not happen due to downsampling of the keypoints location during the optimization. Some precision is also lost, even if the cube resolution is hight enough, when saving the cube as a 252x252 png file (hence reducing the cube resolution to 64), in which case the keypoints can only be mapped to their destination colors up to the interpolation accuracy.`

To better understand this argument, consider the following image, composed of 5 column images, where the first and last images are src and dst images respectively and 2th, 3th and 4th images are result of applying the cluts generated at 64, 128 and 256 cube resolutions respectively, on the first image.

<img src="doc_materials/cube-resolution.png" alt="" width="400"/>

In summary, if we can handle heavy .cube or large .png lut files, then we can set the cube resolution to 256 to be sure that all src colors are mapped exactly to dst colors.

### Uniform Sampling
In this section, we use the difference between an image and its color-graded version to show how well a certain lut is performing. While fully aware that this is not the best metric for measuring the performance of the lut, it is simple and serves the purpose adequately! 

Let's create two small images from our 96 samples (left:src, right:dst)

<img src="doc_materials/keypoints_src_SG8x12_x100.png" alt="" width="200"/>
<img src="doc_materials/keypoints_dst_SG8x12_x100.png" alt="" width="200"/>

and use before-after version of our script on left half of the images to generate the lut at 50% influence (we are not plotting the keypoints in this version to avoid the clutter, especially for big src/dst images):
```
gmic -m custom.gmic clut_from_ab doc_materials/keypoints_src_SG8x6_left-half.png,doc_materials/keypoints_dst_SG8x6_left-half.png,doc_materials/OUT,48samples_apple2canon.cube,1,0,50,64
```

<img src="doc_materials/OUT/cube_LUT_US0_KI50_CR64_clut_from_ab_48samples_apple2canon.cube.png" alt="" width="200"/>
<img src="doc_materials/OUT/color_distribution_of_LUT_US0_KI50_CR64_clut_from_ab_48samples_apple2canon.cube.png" alt="" width="200"/>

Applying the resulting lut on the full src image and looking at the differences with the dst image shows how accurate the lut is in transferring the first half of the colors from the dst to the src (i.e. the left half is showing almost zero differences)

<img src="doc_materials/diff_srcGraded-US0_and_dst_x100.png" alt="" width="400"/>

but also how it is `randomly` manipulating the rest of the colors on the right half of the src image if we look at the difference between the graded src and the original src and also the difference between the graded src and the dst image above  (i.e. below, the right half is showing some color manipulations which is far from dst colors, otherwise we should see very small differences on the right half of the above image)
<img src="doc_materials/diff_srcGraded-US0_and_src_x100.png" alt="" width="400"/>

Ideally, if we would have a large number of src color keypoints covering all areas of the RGB cube, the resulting lut would not only transfer all src colors to their dst colors very accurately, but also it would do a very decent job in guessing the dst color for any other color. In the above example, however, the keypoints distribution is far from the ideal.

We have two options to avoid such random mapping: either add more src/dst color keypoints that will cover all areas of the RGB cube OR decide to limit the lut to only src keypoints and their neighboring areas (defied by the influence argument) and keep it neutral elsewhere.

Uniform sampling argument is what we need if we decided to opt for the second option. It works by adding uniformly distributed src samples to the RGB cube and keeping their src colors. The new samples work as anchors that will stop custom src colors from spreading too far. Setting uniform sampling to 1 will lock 8=(1+1)^3 corners of the cube, setting it to 2 will lock 27=(1+2)^3 points etc.

To demonsterate, let's repeat the above example with the uniform sampling set to 3 (64 anchors):
```
gmic -m custom.gmic clut_from_ab doc_materials/keypoints_src_SG8x6_left-half.png,doc_materials/keypoints_dst_SG8x6_left-half.png,doc_materials/OUT,48samples_apple2canon.cube,1,3,50,64
```

<img src="doc_materials/OUT/cube_LUT_US3_KI50_CR64_clut_from_ab_48samples_apple2canon.cube.png" alt="" width="200"/>
<img src="doc_materials/OUT/color_distribution_of_LUT_US3_KI50_CR64_clut_from_ab_48samples_apple2canon.cube.png" alt="" width="200"/>

Applying the resulting lut on the full src image and looking at the differences with the dst image shows accurate and targeted mapping of the first half of the colors from the dst to the src 

<img src="doc_materials/diff_srcGraded-US3_and_dst_x100.png" alt="" width="400"/>

as well as negligible manipulation of the rest of the colors on the right half of the src image (i.e. below, showing the difference between the graded src and the original src, the colors on the right half are mapped to themselves, hence zero differences).
<img src="doc_materials/diff_srcGraded-US3_and_src_x100.png" alt="" width="400"/>

The careful reader, may have already figured it out by himself! that adding extra anchors can affect the smoothness of the resulting lut especially when they are too close to some keypoints. However, they will become handy if we need to generate specific luts by locking some colors in place to mimic a certain style.

## Generic CLUT
now that we have explained the arguments, in this final section we will explain the steps for generating an enough generic CLUT, capable of transferring colors from any Apple-converted image to match the Canon version.


