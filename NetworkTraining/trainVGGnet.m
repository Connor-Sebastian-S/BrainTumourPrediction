function trainedNet = trainVGGnet()

    % A function to train a VGG net to categorise a 3D cube to either
    % tumour or no tumour texture. Returns the trained network and saves it
    % to file.
    %
    %   cube_size           A trained VGGnet of type SeriesNetwork
    %   get_data            Whether data is to be collected or loaded from files.
    %   initialise_weights  Whether weights should be initialised from a
    %                       pretrained VGGNet or not initialised at all.
    % ---------------------------------------------

    network_type = 'vgg19';
    cube_size = 2;
    get_data = true;
    initialise_weights = false;
    if get_data
        [data, labels] = getTrainingData(cube_size);

        saveDir = (['Networks/' network_type '/' num2str(cube_size) '_' num2str(size(data, 4)) '/']);
        if ~isdir(saveDir)
            mkdir(saveDir);
        end
        save([saveDir 'data.mat'], 'data', '-v7.3');
        save([saveDir 'labels.mat'], 'labels', '-v7.3');
    else
        saveDir = (['Networks/' network_type '/']);
        load(['Networks/'  network_type  '/data.mat']);
        load(['Networks/'  network_type  '/labels.mat']);
    end
    
    path = (['vgg19.prototxt']);
    layers = importCaffeLayers(path);
    
    if initialise_weights
        layers = initLayerWeightsVGG(layers);
    end
    
    [trainindex, valindex, testindex] = dividerand(size(data, 4), 0.6, 0.2, 0.2);
    
    val_data = data(:,:,:,valindex);
    val_labels = labels(valindex);
    
    test_data = data(:,:,:,testindex);
    test_labels = labels(testindex);
    
    data = data(:,:,:,trainindex);
    labels = labels(trainindex);
    
    options = trainingOptions('sgdm', 'MaxEpochs', 300, ...
        'L2Regularization', 0.0005, ...
        'ValidationData', {val_data, categorical(val_labels)}, ...
        'ValidationFrequency', 250, ...
        'InitialLearnRate', 0.01, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',0.1, ...
        'LearnRateDropPeriod', 40, ...
        'Plots', 'training-progress');
    trainedNet = trainNetwork(data, categorical(labels), layers, options);
    
    save([saveDir 'network.mat'], 'trainedNet', '-v7.3');
    
    accuracy = testNetwork(trainedNet, test_data, test_labels);
    
    fprintf('Accuracy of trained network on test set: %.4f', accuracy);

end
