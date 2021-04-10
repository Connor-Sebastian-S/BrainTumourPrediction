function [] = LOOCV_SVM(model)

    % Run leave one out cross validation on data specified in the model
    %
    %   model	A model containing all information needed for feature extraction
    %		and cross validation
    %-------------------------------

    tic;

    % Get all the cross validation details from the model
    outLayer = model.FEATURE.VGG.layer;
    layerNo = model.FEATURE.VGG.layerNo;
    layers = model.FEATURE.VGG.layers;

    modality = model.FEATURE.modality;
    featSelection = model.FEATURE.selection;
    trainmode = model.FEATURE.VGG.trainingmethod;

    FeatureFolder = [model.DIR.FeatureFolder '_outputL_'];
    LabelFile = loadLabelFile(model.LabelFile);

    labels = [];
    modalities = [];

    % Get labels for all patients
    for k = 1:1:size(LabelFile,1)
        labels(end+1) = LabelFile{k,3};
    end   

    folder = [FeatureFolder char(outLayer) '/'];
    patientNames = getDirContent(folder, '.mat');

    % Get feature vector for all patients
    Feature = [];
    for k = 1:1:length(patientNames)
        name = patientNames{k};
        feat = [];
        mods = [];

        % Concatenate features from all layers into one feature vector
        % Ignore the first and middle 6 from all but first feature since
        % these are duplicates from the basic DKI and FLAIR images
        
        %folder = [FeatureFolder char(layers(1).Name) '/' name];
        folder = [FeatureFolder char(layers(1)) '/' name];
        load(folder);
        fLength = length(rawFeat)/2;
        feat = cat(2, feat, rawFeat);
        mods = cat(2, mods, [ones(1,fLength) zeros(1,fLength)]);
        for n = 2:layerNo
            %folder = [FeatureFolder char(layers(n).Name) '/' name];
            folder = [FeatureFolder char(layers(n)) '/' name];
            load(folder);
            f = rawFeat(7:fLength);
            f = cat(2, f, rawFeat(fLength+7:end));
            feat = cat(2, feat, f);
            mods = cat(2, mods, [ones(1,length(f)/2) zeros(1,length(f)/2)]);
        end
        Feature = cat(1, Feature, feat);

        % modalities keeps track of which features are from DKI images and
        % which are from FLAIR (1 DKI, 0 FLAIR)
        modalities = cat(1, modalities, mods);
    end

    % libsvm RBF grid search parameter
    cRange = [-10:2:10];
    gRange = [-10:2:10];

    isProb = 1;

    % Get the selected area (has to be of type logical)
    if strcmp(modality, 'DKI')
        selection = logical(modalities);
    elseif strcmp(modality, 'Flair')
        selection = ~logical(modalities);
    elseif strcmp(modality, 'Both')
        selection = true(size(Feature));
    end

    featSize = size(Feature, 2);
    fprintf('Features up to layer %i in the ', layerNo);
    if trainmode == 0
        fprintf('network 1 \n')
    elseif trainmode == 1
        fprintf('network 2 \n');
    else
        fprintf('network 3 \n');
    end
    fprintf('Size of the feature vector: %i \n', featSize);
    fprintf('Modality: %s \n', modality);
    
    fid = fopen([FeatureFolder model.NETWORK '_stats.txt'], 'a+');
    fprintf(fid, '%f %f\n\n', layerNo);
    fprintf(fid, '%f %f\n\n', featSize);
    fclose(fid);
    
    pred = zeros(length(labels),1);
    
    %% Outer LOOCV
    parfor i = 1:1:length(labels)
        fprintf('Starting to processing No %i out of %i cross validation\n', i, length(labels))
        ind = logical(zeros(length(labels),1));
        ind(i) = true;

        % Separate the train and test set
        trainFeature = Feature(~ind,:);
        trainLabels = double(labels(~ind));

        testFeature  = Feature(ind,:);
        testLabels = double(labels(ind));

        % Feature scaling
        mini = min(trainFeature, [], 1);
        range = max(trainFeature, [], 1) - min(trainFeature, [], 1);
        trainFeature = (trainFeature - repmat(mini,size(trainFeature,1),1))./repmat(range, size(trainFeature,1), 1);

        testFeature = (testFeature - mini)./range;
        
        trainFeature = double(trainFeature(:,selection(i,:)));
        testFeature = double(testFeature(:, selection(i,:)));
        
        [bestC, bestG, bestAcc, bestFeats] = innerLoop(trainFeature, trainLabels, cRange, gRange, isProb, featSelection);
        fprintf('Best C: %f   Best G: %f  Best Accuracy: %f\n', bestC, bestG, bestAcc);
        if ~isempty(bestFeats)
            fprintf('Best Features: ');
            fprintf('%i ', bestFeats);
            fprintf('\n');

            trainFeature = trainFeature(:, bestFeats);
            testFeature = testFeature(:, bestFeats);
        end

        % SVM training with LIBSVM
        l0 = length(find(trainLabels == 0));
        l1 = length(find(trainLabels == 1));
        options = ['-s 0 -t 2 -c ' num2str(bestC) ' -g ' num2str(bestG)  ' -w0 ' num2str((l0+l1)/2/l0) ' -w1 ' num2str((l0+l1)/2/l1) ' -q'];

        model = svmtrain(trainLabels', trainFeature, options);

        % Platt's scaling
        isBagging = 0;
        isLOOCV = 0;
        [A, B] = plattScaling(trainLabels, trainFeature, model, isBagging, isLOOCV, options);

        % SVM testing with LIBSVM
        [ll, ~, prob] = svmpredict_platt(testLabels', testFeature, model, A, B, isProb);

        pred(i) = ll;
        fprintf('\n')
    end

    fprintf('\n\n')
    [accuracy, sen, spe] = measure(pred,labels)
    
    fid = fopen([FeatureFolder model.NETWORK '_stats.txt'], 'a+');
    fprintf(fid, '%f %f %f\n', [accuracy, sen, spe]);
    fclose(fid);

    time = toc;

    fprintf('\n\n')
    fprintf('Cross Validation done. Total time: %i h %i m %i s\n', floor(time/3600), floor(mod(time,3600)/60), floor(mod(time,60)));
    
    timfid = fopen([FeatureFolder model.NETWORK '_loocvtimes.txt'], 'a+');
    fprintf(timfid, '%f %f\n\n', [floor(time/3600), floor(mod(time,3600)/60), floor(mod(time,60))]);
    fclose(timfid);
end