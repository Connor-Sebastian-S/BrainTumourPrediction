function outImages = reformatImages(images, trainingmethod, net)

    % Function to reformat a set of images into a form accepted by VGG net
    %
    % Reformats 3D matrix of images into a 4D array of RGB images and
    % resizes images to size 224 x 224 px
    %
    %   outImages	4D-matrix containing resized images with 3 channels

    outImages = [];

    for i = 1:size(images, 3)
        X = images(:,:,i);

	% Copy image to three channels and resize if VGGNet is pretrained
        if trainingmethod < 1
            X = cat(3, X, X, X);
            X = imresize(X, [299 299]);
           % X = imresize(X, net.Layers(1).InputSize(1:2));
        end
        if trainingmethod >= 1
            X = cat(3, X, X, X);
            X = imresize(X, [32 32]);
           % X = imresize(X, net.Layers(1).InputSize(1:2));
        end
        outImages = cat(4, outImages, X);
    end

    clearvars X
end
