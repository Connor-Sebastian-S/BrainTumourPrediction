function [] = buildVGGFeature(model, net)

    % Function to compute and features for DKI and Flair images based on
    % response images from a convolutional neural network. Each feature
    % contains mean, median, 5th and 95th percentiles, standard deviation
    % and kurtosis.
    %
    % 	model	A model containing all information needed for feature extraction
    %		and cross validation
    %---------------------------------------------

    tic;
    imgFolder = model.DIR.ImageFolder;
    FeatureFolder = model.DIR.FeatureFolder;
    if ~isfolder(FeatureFolder)
        mkdir(FeatureFolder);
    end
    patientNames = getDirContent(imgFolder);

    ITKSNAP = model.ITKSNAP;
    boundaryOnly = model.BoundaryOnly;

    trainingMethod = model.FEATURE.VGG.trainingmethod;
    outLayer = model.FEATURE.VGG.layer;

    for i = 1:1:length(patientNames)
        name = patientNames{i};
        fprintf('Extracting feature vector for %i out of %i patients: %s\n', i, length(patientNames), name);

        % Deal with abnormal cases
        if ismember(name, ITKSNAP)
            [DKI, Flair, VOI_K, VOI_F] = Read_Images_VOIs_ITKSNAP(model, name);
        elseif ismember(name, boundaryOnly)
            [DKI, Flair, VOI_K, VOI_F] = Read_Images_VOIs_Only_Boundary(model, name);
        else
            [DKI, Flair, VOI_K, VOI_F] = Read_Images_VOIs(model, name);
        end

        % Move images to GPU server if GPU is available
%         if gpuDeviceCount > 0
%             DKI = gpuArray(DKI);
%             Flair = gpuArray(Flair);
%             VOI_K = gpuArray(VOI_K);
%             VOI_F = gpuArray(VOI_F);
%         end

        % DKI
        fprintf('Dealing with DKI modality...\n')

        DKISize = [size(DKI, 1) size(DKI, 2)];

        % intensity statistics for DKI
        tumourIndex = find(VOI_K > 0);
        tumour = double(DKI(tumourIndex));

        DKI_I = cat(2, mean(tumour), median(tumour), std(tumour), kurtosis(tumour), prctile(tumour,5), prctile(tumour,95));

        % Reformat the images to fit VGG net
        DKI = reformatImages(double(DKI), model.FEATURE.VGG.trainingmethod, net);

        % Apply filters to DKI image
        DKI_VGG = getVGGfeatures(double(DKI), tumourIndex, DKISize, outLayer, model);

        % Calculate features from response images
        DKI_VGG_marker = [];
        for k = 1:1:size(DKI_VGG,2)
	    t = DKI_VGG(:,k);
            DKI_VGG_sub = cat(2, mean(t), median(t), std(t), kurtosis(t), prctile(t,5), prctile(t,95));
            DKI_VGG_marker = cat(2, DKI_VGG_marker, DKI_VGG_sub);
        end

        % Flair
        fprintf('Dealing with Flair modality...\n')

        FlairSize = [size(Flair, 1) size(Flair, 2)];
        % intensity statistics for Flair
        tumourIndex = find(VOI_F > 0);
        tumour = double(Flair(tumourIndex));

        Flair_I = cat(2, mean(tumour), median(tumour), std(tumour), kurtosis(tumour), prctile(tumour,5), prctile(tumour,95));

        % Reformat the images to fit VGG net
        Flair = reformatImages(double(Flair), trainingMethod, net);

        % Apply filters to Flair image
        Flair_VGG = getVGGfeatures(double(Flair), tumourIndex, FlairSize, outLayer, model);
        Flair_VGG_marker = [];
        for k = 1:1:size(Flair_VGG,2)
	    t = Flair_VGG(:,k);
            Flair_VGG_sub = cat(2, mean(t), median(t), std(t), kurtosis(t), prctile(t,5), prctile(t,95));
            Flair_VGG_marker = cat(2, Flair_VGG_marker, Flair_VGG_sub);
        end
        clearvars Flair_VGG

%         if gpuDeviceCount > 0
%             DKI_I = gather(DKI_I);
%             Flair_I = gather(Flair_I);
%         end

        rawFeat = cat(2, DKI_I, DKI_VGG_marker, Flair_I, Flair_VGG_marker);
        
        
        saveDir = ([FeatureFolder '_outputL_' outLayer '/']);
        %saveDir = ([FeatureFolder 'VGG_outputL_' outLayer '/']);
        if ~isfolder(saveDir)
            mkdir(saveDir);
        end
        c = [saveDir name];
        
        save(c, 'rawFeat', '-v7.3');
        
        clearvars rawFeat

    end
    time = toc;

    fprintf('\n\n')
    fprintf('Feature vectors computed. Total time: %i h %i m %i s\n', floor(time/3600), floor(mod(time,3600)/60), floor(mod(time,60)));
    timfid = fopen([FeatureFolder model.NETWORK '_featuretimes.txt'], 'a+');
    fprintf(timfid, '%f %f\n\n', [floor(time/3600), floor(mod(time,3600)/60), floor(mod(time,60))]);
    fclose(timfid);
end

