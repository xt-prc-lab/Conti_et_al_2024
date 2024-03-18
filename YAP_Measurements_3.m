%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is meant to be used to calculate yap overal expression and YAP
% nuc/cytoplasm ratio in fixed cells seeded on PAA gels.. 
% Written by Sefora Conti
% Affilition: Xavier Trepat Group, IBEC, Barcelona. 
% Used in the following study: "Membrane to cortex attachment determines different mechanical phenotypes in LGR5+ and LGR5- colorectal cancer
% cells". S. Conti,.., X. Trepat. Nat. Comm. 2024. 
% If you find this code useful, please cite our work. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dirBase = 'YAP_Measurement_DataDemo';

threshold = 50000;
for iPos = 1:1:1

    disp(['File #', num2str(iPos)]);
%     dirDest = [dirBase,filesep,'Analysis_Results'];
%     if ~exist(dirDest), mkdir(dirDest); end    
    disp(['Position #', num2str(iPos), ' ... Calculating Mean Intensity']);

    % Load LGR5, Dapi and YAP im
    im1 = imread([dirBase, filesep, 'Pos', num2str(iPos), '_LGR5.tif' ]);
    im2 = imread([dirBase, filesep, 'Pos', num2str(iPos), '_YAP.tif' ]);
    im3 = imread([dirBase, filesep, 'Pos', num2str(iPos),'_Dapi.tif' ]);
    tdtom = double(im1);
    Yap = double(im2);
    Dapi = double(im3);

    % Load black & white images (whole cell+only Cytoplasm+Nucleus)
    imSegPath = [dirBase,filesep, 'Matlab_Analysis'];
    bw = imread([imSegPath, filesep, 'Pos', num2str(iPos), '_mask.tif']);
    bw_Cyt = imread([imSegPath, filesep, 'Pos', num2str(iPos), '_mask_cytoplasm.tif']);
    bw_Nuc = imread([imSegPath, filesep,'Pos', num2str(iPos), '_nucleus.tif']); %for background porpuses
    bw_SingleNuc = imread([imSegPath, filesep,'Pos', num2str(iPos), '_singlenuclei.tif']); %Nuclei mask without the nuclei belonging to blobs bigger than 40000

    % clear border
    bw = imclearborder(bw);
    bw_Cyt = imclearborder(bw_Cyt);
    bw_Nuc = imclearborder(bw_Nuc);
    bw_SingleNuc = imclearborder(bw_SingleNuc);

    % Label Blobs
    bwL = bwlabel(bw);
    bwC = bwlabel(bw_Cyt);
    bwN = bwlabel(bw_SingleNuc);
    bwInverse = imcomplement(bw); %reverting the Mask for Background Calculation
    bwLInverse = bwlabel(bwInverse);
    bwInvNuc = imcomplement(bw_Nuc); %reverting the Mask for Background Calculation
    bwLInvNuc = bwlabel(bwInvNuc);
%     imshow(bw)
    im1=imadjust(im1);
    imshow(im1)

    % Find Mean Intensity of "blobs" in the tdtom Image
    mtdtom = regionprops('table',bwL, tdtom , 'MeanIntensity', 'Area', 'Centroid', 'Eccentricity', 'Circularity'); %mean intensity of all the blobs.
    idtdtom = find([mtdtom.Area] > 2000 & [mtdtom.Area] < threshold );
    bw1 = ismember(bwL, idtdtom);

    % Find Mean Intensity of "blobs" in the YAP Image (YAP Overall
    % Expression)
    mYap = regionprops('table',bwL, Yap , 'MeanIntensity', 'Area', 'Centroid', 'Eccentricity', 'Circularity'); %mean intensity of all the blobs.
    idYap = find([mYap.Area] > 2000 & [mYap.Area] < threshold);
    bw2 = ismember(bwL, idYap);

    % Find Mean Intensity of "blobs" in the YAP Image (YAP cytoplasmic
    % Expression)
    cYap = regionprops('table',bwC, Yap , 'MeanIntensity', 'Area', 'Centroid', 'Eccentricity', 'Circularity'); %mean intensity of all the blobs.
    idcYap = find([cYap.Area] > 2000 &  [cYap.Area] < threshold);
    bw3 = ismember(bwC, idcYap);

    % Find Mean Intensity of "blobs" in the YAP Image (YAP nuclear
    % Expression)
    nYap = regionprops('table',bwN, Yap , 'MeanIntensity', 'Area', 'Centroid', 'Eccentricity', 'Circularity'); %mean intensity of all the blobs.
    idnYap = find([nYap.Area] > 2000 & [nYap.Eccentricity] < 1);
    bw4 = ismember(bwN, idnYap);

    % Find Mean Intensity of "blobs" in the Dapi Image
    mDapi = regionprops('table',bwN, Dapi , 'MeanIntensity', 'Area', 'Centroid', 'Eccentricity', 'Circularity'); %mean intensity of all the blobs.
    idDapi = find([mDapi.Area] > 2000 & [mDapi.Eccentricity] < 1);
    bw5 = ismember(bwN, idDapi);

    % Find Mean Intensity of backgroung
    Bgtdtom= regionprops('table',bwLInverse, tdtom, 'MeanIntensity', 'Area');
    BgYap= regionprops('table',bwLInverse, Yap, 'MeanIntensity', 'Area');
    BgDapi= regionprops('table',bwLInvNuc, Dapi, 'MeanIntensity', 'Area');

    % Extract Data from calculation
    Meantdtom = mtdtom.MeanIntensity(idtdtom,:);
    MeanYap = mYap.MeanIntensity(idYap,:);
    cytoYap = cYap.MeanIntensity(idcYap,:);
    nucYap = nYap.MeanIntensity(idnYap,:);
    MeanDapi = mDapi.MeanIntensity(idDapi,:);
    Areatdtom = mtdtom.Area(idtdtom,:)*(0.1075^2);
    Areacyt = cYap.Area(idcYap,:)*(0.1075^2);
    Areanuc = nYap.Area(idnYap,:)*(0.1075^2);
    CentroidNuc = nYap.Centroid(idnYap,:);
    CentroidCyt = cYap.Centroid(idcYap,:);

    % Create Yap image with overlayed labelled nuclear+cytoplasmic blobs
    im2 = uint8(im2); %transforms the image into the correct format for the given histogram
    imadjust(im2);
    imshow(im2)
    title('YAP Labelled');
    hold on
    numObj = numel(idnYap); %adding the centroid coordinates of each nucleus
    for k = 1 : numObj
        plot(CentroidNuc(k,1), CentroidNuc(k,2), 'b*')
        txt = idnYap(k,1);
        txt = num2str(txt);
        text((CentroidNuc(k,1)-30), (CentroidNuc(k,2)-30), txt, 'Color', 'blue', 'FontSize',11)
    end
    n = numel(idcYap); %adding the centroid coordinates of each cytoplasm
    for k = 1 : n
        plot(CentroidCyt(k,1), CentroidCyt(k,2), 'rx')
        txt = idcYap(k,1);
        txt = num2str(txt);
        text((CentroidCyt(k,1)+30), (CentroidCyt(k,2)+30), txt, 'Color', 'r' , 'FontSize',11)
    end
    [F,L] = bwboundaries(bw_Cyt,'noholes'); %adding external borders of the cell
    for k = 1:length(F)
        boundary = F{k};
        plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
    end
    [G,M] = bwboundaries(bw_SingleNuc,'noholes');
    for k = 1:length(G)
        boundary = G{k};
        plot(boundary(:,2), boundary(:,1), 'b--', 'LineWidth', 1)
    end
    hold off
    % Save images
    export_fig(gcf, [dirBase,filesep, 'Matlab_Analysis', filesep,'Yap+Masks_',num2str(iPos),'.png'])

    % Background of all channels
    mBgtdtom = Bgtdtom.MeanIntensity(:);
    mBgYap = BgYap.MeanIntensity(:);
    mBgDapi = BgDapi.MeanIntensity(:);

    % Subtract Background from mean intensity
    NoBgmtdtom = Meantdtom-mBgtdtom; %mean tdtom with no Background
    NoBgmYap = MeanYap-mBgYap; %mean Yap with no Background
    NoBgmDapi = MeanDapi-mBgDapi; %mean Yap with no Background

    % Arranging sizes of different arrays (all the ones based on
    % cytoplasmic segmentation)
    H = nan(size(NoBgmDapi)); %creating a matrix of the same size as AreaDapi containing NANs
    H(1:length(Areatdtom), 1) = Areatdtom; %assigning to H the values of AreaGFP
    Areatdtom = H;
    C = nan(size(NoBgmDapi)); %creating a matrix of the same size as AreaDapi containing NANs
    C(1:length(NoBgmtdtom), 1) = NoBgmtdtom;
    NoBgmtdtom = C;
    E = nan(size(NoBgmDapi)); %creating a matrix of the same size as AreaDapi containing NANs
    E(1:length(NoBgmYap), 1) = NoBgmYap;
    NoBgmYap = E;
    D = nan(size(NoBgmDapi)); %creating a matrix of the same size as AreaDapi containing NANs
    D(1:length(cytoYap), 1) = cytoYap;
    cytoYap = D;
    D = nan(size(NoBgmDapi)); %creating a matrix of the same size as AreaDapi containing NANs
    D(1:length(idcYap), 1) = idcYap;
    idcYap = D;

    idcYap = idcYap';
    idnYap = idnYap';
    nucYap = nucYap';
    cytoYap = cytoYap';
    NoBgmYap = NoBgmYap';
    Areanuc = Areanuc';
    NoBgmtdtom = NoBgmtdtom';
    NoBgmDapi = NoBgmDapi';
    Areacyt = Areacyt';
    Areatdtom = Areatdtom';

    A = table(idnYap(:),...
        nucYap(:),...
        Areanuc(:),...
        NoBgmDapi(:),...
        idcYap(:),...
        cytoYap(:),...
        NoBgmYap(:),...
        NoBgmtdtom(:),...
        Areatdtom(:),...
        'VariableNames',{'Nuc_label' 'nucYap' 'AreaNuc' 'Dapi_noBg' 'Cyto_label'  'cytoYap' 'meanYap' 'tdtom_noBg' 'AreaCell'});
    writetable(A,[dirBase, filesep, 'Matlab_Analysis', filesep,'Fluo_Measurements_',num2str(iPos), '.xlsx']);

    B = table(mBgtdtom(:), mBgYap (:), mBgDapi(:), 'VariableNames',{'Meantdtom_Background',...
        'Yap_Background','Dapi_Background'}); 
    writetable(B,[dirBase,filesep, 'Matlab_Analysis', filesep,'Fluo_Background_',num2str(iPos), '.xlsx']);    

end
clear all;
clc;
