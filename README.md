# CLUT

This collection of scripts helps with the use of https://gmic.eu with the generation of CLUT (Color Look-Up Table) files for "transferring" colors from a source image to a desired target. 

## Generating CLUT via G'MIC

The main script is `custom.gmic` file which contains a set of custom commands for generating and visualizing CLUTs, mainly  `clut_from_customKeypoints` and  `clut_from_ab`. 
The argument list for both commands are identical and comma-separated: (See the script for more details.):
```
gmic -m custom.gmic clut_from_ab src.png,dst.png,outFolder,clutName.ext,uniformSampling,keypointsInfluence,cubeResolution
```
The first two arguments are 2 one-column images `src.png` and `dst.png` in which each row corresponds to one color keypoint. Run `generate_keypoinImageFromTXT.sh` to generate such keypoint images from txt files containing RGB values of color samples (See the script for the format of the text file). 

```
$ ./generate_keypoinImageFromTXT.sh IN/img01_apple_IT8.txt  OUT/ img01_apple_IT8.png
$ ./generate_keypoinImageFromTXT.sh IN/img01_canon_IT8.txt  OUT/ img01_canon_IT8.png
```

Once the keypoint images are generated, run the custom script on them to generate the CLUT, e.g.:

```
$ gmic -m custom.gmic clut_from_customKeypoints OUT/keypoints_img01_apple_IT8.png,OUT/keypoints_img01_canon_IT8.png,OUT/CLUTs/,img01_IT8.png,3,100,64
```
or
```
$ gmic -m custom.gmic clut_from_ab IN/img02_apple.png,IN/img02_apple_graded_by_Humphrey.png,OUT/CLUTs/,img02.png,3,100,64
```

The most comprehensive command is the custom command `clut_from_customKeypoints`. It allows selecting various uniform samplings as well as the cube resolution and can be extended to lock some custom keypoints.
Run `clut_from_ab` instead if the input images are not one-column and there is not any topological/structural differences between two images. The advantage is that this commands can handle all pixels from even large images and there is no need for extracting RGB values of color samples into txt files and building keypoints images.

See each script for more details about the arguments and parameters.

Refer to `LUT%20experiments/Real/G'MIC` and `Apple\ RAW\ converter/LUT_revisited_2020/refrence_RAWs_and_TIFFs` for a dataset of sample shots from various machines, various cameras, taken with various exposures and converted on various OSes using Apple and Canon converter.

## Installing GMIC
On MacOS, tested with GMIC v 2.9.1
* option 1: homebrew : `brew install gmic`
* option 2: download tarball : `https://github.com/Benitoite/gmic-osx/releases/download/continuous/gmic-cli.tgz`
