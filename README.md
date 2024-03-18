# Membrane to cortex attachment determines different mechanical phenotypes in LGR5+ and LGR5- colorectal cancer cells, by Sefora Conti et al.

This repository contains the code for the paper Membrane to cortex attachment determines different mechanical phenotypes in LGR5+ and LGR5- colorectal cancer cells, by Sefora Conti, Valeria Venturini, Adrià Cañellas-Socias, Carme Cortina, Juan F. Abenza, Camille Stephan-Otto Attolini, Emily Middendorp Guerra, Catherine K Xu, Jia Hui Li, Leone Rossetti, Giorgio Stassi, Pere Roca-Cusachs, Alba Diz-Muñoz, Verena Ruprecht, Jochen Guck, Eduard Batlle, Anna Labernadie, Xavier Trepat1.

# Codes details 

## 1. System requirements 

The scripts have been used in a Windows7 PC. The Matlab version used was: R2023b.  

## 2. Installation guide 

The codes do not require any installation except for the Matlab software.  

## 3. Demo and instructions to run on data 

The published Matlab codes are part of a multistep workflow aimed to calculate the ratio between nuclear YAP and cytoplasmic YAP of cells seeded on 2D substrates. Cells are fixed and immunostained for YAP, nuclei (Hoechst), actin (phalloidin). Cells also express LGR5_Tdtomato.  

The first code, entitled “Nuclei_Dapi_Segmentation_1”, uses an input image of Hoechst labelled nuclei, to create a binary mask.  

The second code, “Actin_Segmentation_2”, creates a binary image using Actin staining, loads and inverts the previously created nuclei mask, and using these two inputs creates the following images:  

* An inverted binary image of the nuclei 
* Mask of cells 
* A mask of the cytoplasm (mask cells * inverted mask nuclei) 

The third code calculates the mean fluorescence value of cytoplasms and nuclei.  

Output files:  

1. Fluo_Background: background mean fluorescence table. 
2. Mean Fluorescence measurements 
3. Pos(x)_mask: Cell mask 
4. Pos(x)_mask_cytoplasm 
5. Pos(x)_nucleus 
6. Pos(x)_nucleus_inverted 
7. Pos1_singlenuclei 
8. Yap+Masks_1 

Time required: a few seconds.  

## 4. Instructions for use 

The codes can be downloaded from the online repository with the demo data. Explanations on the tasks performed by each line are contained in the codes. To run properly, the codes require [Figure export toolbox](https://mathworks.com/matlabcentral/fileexchange/23629-export_fig) and [image thresholding method](https://mathworks.com/matlabcentral/fileexchange/74479-image-thresholding-triangle-method-and-kittler-method) that can be downloaded from the provided links and should be saved in the same folder where the codes are saved.  
