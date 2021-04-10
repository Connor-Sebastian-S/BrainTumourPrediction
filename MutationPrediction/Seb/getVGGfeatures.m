function feature = getVGGfeatures(V, v_index, origSize, outLayer, model)

    % Get response images given by the specified
    % convolutional layer in VGGnet architecture
    % 
    %   V           Flair or DKI images in size and format accepted by given VGGnet
    %   v_index     the index of the interest voxels in the volumes could be VOIs
    %   outLayer    The convolutional output layer from the VGGnet
    %-------------------------------------

    featureMat = [];
    feature = [];
    VGGnet = model.FEATURE.VGG.net;

    % Get the response images from the specified convolution layer
    for i = 1:1:size(V,4)
        
        I = V(:,:,:,i);
        features = activations(VGGnet, I, outLayer, 'outputAs', 'channels');
        featureMat = cat(4, featureMat, features);
    end

    % Get the volume of interest from the response images
    for j = 1:size(featureMat, 3)
        im = [];
        for k = 1:size(featureMat, 4)
            im = cat(3, im, double(featureMat(:,:,j,k)));
        end
        VOI = imresize(im, origSize);
        VOI = VOI(v_index);
        feature = cat(2,feature, VOI);
    end

    clearvars featureMat features

end

