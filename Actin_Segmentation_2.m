%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is meant to be used as part of a wrokflow aimed to  calculate yap overal expression and YAP
% nuc/cytoplasm ratio in fixed cells seeded on PAA gels. 
% Written by Sefora Conti
% Affilition: Xavier Trepat Group, IBEC, Barcelona. 
% Used in the following study: "Membrane to cortex attachment determines different mechanical phenotypes in LGR5+ and LGR5- colorectal cancer
% cells". S. Conti,.., X. Trepat. Nat. Comm. 2024. 
% If you find this code useful, please cite our work. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
clc;

dirBase = 'YAP_Measurement_DataDemo';

threshold = 50000;
% Segment Image
count = 1;
for iPos = 1:1:1

    disp(['File #', num2str(iPos)]);
    clear im meanIm
    if ~exist(dirBase), mkdir(dirBase); end
    im = imread([dirBase, filesep, 'Pos', num2str(iPos), '_Actin.tif']);
    level = graythresh(im);
    BW = imbinarize(im,'adaptive','Sensitivity',0.41);  
%     Dilate Images
    se90 = strel('line',4,90);
    se0 = strel('line',4,0);
    ImDil = imdilate(BW,[se90 se0]);
%     Filling gaps
    se = strel('disk',3);
    ImCl = imclose(ImDil,se);
    conn = conndef(2,'maximal');
    IMdfill = imfill(ImCl,conn,'holes');
%     Clearing Borders
%     IMnobord = imclearborder(IMdfill,4);
        
%     Smoothing the object
    seD = strel('disk',3);
    IMfinal = imerode(IMdfill,seD);
    bw2 = imerode(IMfinal,seD);
        
%     Removing small objects from binary image
    bwfinal = bwareaopen(bw2,8000,8);
    bw_clusters = bwareaopen(bw2,threshold,8);

%     Save image: Mask of all the detected bjects(cells+clusters)
    imwrite(bwfinal,[dirBase, filesep, 'Matlab_Analysis', filesep,  'Pos', num2str(iPos),'_mask.tif'] ,'tif', 'compression', 'none');
        
%     Remove from cells mask all objects bigger than 40000
    cc = bwconncomp(bwfinal);
    stats = regionprops(cc);
    removeMask = [stats.Area]>threshold;
    bwfinal(cat(1,cc.PixelIdxList{removeMask})) = false;
        
%     Loading Nucleus Mask
    Nucleus_inverted = imread([dirBase, filesep, 'Matlab_Analysis',  filesep,  'Pos', num2str(iPos), '_nucleus_inverted.tif']);
    mask_cytoplasm = immultiply(bwfinal, Nucleus_inverted);
    imshow(mask_cytoplasm)

%     Multiply inverted clusters mask with nuclei to obtain only single
%     nuclei
    single_nuclei = immultiply(imcomplement(Nucleus_inverted), imcomplement(bw_clusters));
%     Save images
    imwrite(mask_cytoplasm,[dirBase, filesep, 'Matlab_Analysis', filesep, 'Pos', num2str(iPos), '_mask_cytoplasm.tif'] ,'tif', 'compression', 'none');
    imwrite(single_nuclei,[dirBase, filesep, 'Matlab_Analysis', filesep,  'Pos', num2str(iPos), '_singlenuclei.tif'] ,'tif', 'compression', 'none');

    clear im2 bw2 bwfinal ImDil mask_cytoplasm Nucleus_inverted
%         
end
count = count +1;
