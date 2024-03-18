%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is meant to be used as part of a wrokflow aimed to  calculate yap overal expression and YAP
% nuc/cytoplasm ratio in fixed cells seeded on PAA gels. 
% It is the first one to use in order to segment single cells
% immunostained for YAP (based on the BF channel)-nuclear segmentation. The
% second script to use is: "Actin_Segmentation" to segment cytoplasm. 
% Written by Sefora Conti
% Affilition: Xavier Trepat Group, IBEC, Barcelona. 
% Used in the following study: "Membrane to cortex attachment determines different mechanical phenotypes in LGR5+ and LGR5- colorectal cancer
% cells". S. Conti,.., X. Trepat. Nat. Comm. 2024. 
% If you find this code useful, please cite our work. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
clc;

dirBase = 'YAP_Measurement_DataDemo';

% Segment Images
count = 1;
for iPos = 1:1:1

    disp(['File #', num2str(iPos)]);
    clear im meanIm

    
    if ~exist(dirBase), mkdir(dirBase); end
    if ~exist([dirBase, filesep, 'Matlab_Analysis']), mkdir([dirBase, filesep, 'Matlab_Analysis']); end
   
    im = imread([dirBase, filesep, 'Pos', num2str(iPos), '_Dapi.tif']);
    level = graythresh(im);
    BW = imbinarize(im,'adaptive','Sensitivity',0.40);  
%     Dilate Images
    se90 = strel('line',3,90);
    se0 = strel('line',3,0);
    ImDil = imdilate(BW,[se90 se0]);
%     Filling gaps
    se = strel('disk',3);
    ImCl = imclose(ImDil,se);
    conn = conndef(2,'maximal');
    IMdfill = imfill(ImCl,conn,'holes');
%     Clearing Borders
    IMnobord = imclearborder(IMdfill,4);
        
%     Smoothing the object
    seD = strel('disk',3);
    bw = imerode(IMnobord,seD);
    bw2 = imerode(bw,seD);
        
%     Removing small objects from binary image
    IMfinal = bwareaopen(bw2,3000,8);
        
%     Inverting Mask
    ImInverted = imcomplement(IMfinal);
    imshow(IMfinal)
 
%     Save images (mask and inverted Mask)
    imwrite(IMfinal,[dirBase, filesep, 'Matlab_Analysis', filesep, 'Pos', num2str(iPos), '_nucleus.tif'] ,'tif', 'compression', 'none');
    imwrite(ImInverted,[dirBase, filesep, 'Matlab_Analysis', filesep, 'Pos', num2str(iPos), '_nucleus_inverted.tif'] ,'tif', 'compression', 'none');
    clear im BW IMfinal ImDil ImCl IMdfill IMnobord ImInverted
%         
end
count = count +1;
