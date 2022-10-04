# A computational tool for 3D analysis of vascular networks 

This repository contains the source code for 3D quantitative analysis of vascular networks. This MATLAB implementation can be simply compiled through installer package. 

### Installation
There is 2 options for implementation. By running `3D_Vessel_Analysis.exe` in the `..\Installer\for_redistribution` folder, you can install the application. As another choice, run `ExampleApp.mlapp` to skip a lenghty installation. Make sure the search path include the proper pulled directory.


### Implementation Detail
<p align="center">
<img src="https://user-images.githubusercontent.com/86834176/193609517-ee0f14b9-c7d8-448d-8148-49b5341fa92c.png" width="600">
</p>

First, choose the folder that contains the 2D slice images of the vascular network. Each image should be binarized for loading. You can apply pertinent pre-processing for those images. Loaded 3D vascular network can be previewed in the `Options` tab. Details for each parameter is explained in `modulized_dimensional_analysis.m` file. After calibration, you can confirm parameter values through clicking `Set` button. 

<p align="center">
<img src="https://user-images.githubusercontent.com/86834176/193718287-7981a269-26ce-45fa-b2c6-61d2eb276fcd.png" width="600">
</p>

Following confirmation, you may finally analyze the provided vascular network by pressing the `Show` button. By choosing the relevant number, you may explore each node point or link. On the left side of the application panel are specific study parameters, and on the right are images that correspond to the selected node and link.

