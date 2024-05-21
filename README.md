# CLUT
generating CLUT via G'MIC

The most comprehensive command is the custom command "generate_CLUT" in the custom.gmic file. It allows selecting various uniform samplings and can be extended to lock some custom keypoints. However, it takes a keypoints correspondence image as the first parameter. To generate the keypoints image from two txt files, one first needs to directly run generate_CLUT.sh which in return generates the keypoints image as well as the CLUT that maps the src colors to the dst colors with no uniform sampling. Once the keypoints image is generated, one can run the custom script to generate the CLUT with a different uniform sampling.

see each script for more details about the arguments and parameters.

$ ./generate_CLUT.sh src.txt dst.txt colorCard interpolation_tech cube_resolution setup_exposure result_folder
$ cd result_folder
$ gmic -m ../custom.gmic -generate_CLUT keypoints.png,uniformSampling
