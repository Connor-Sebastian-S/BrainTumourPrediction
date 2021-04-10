function layers = initLayerWeightsVGG(layers)

    % Initialises the layer array with the weights from the pretrained
    % VGG16 model.
    %
    %   layers  VGGNet layer array with uninitialised weights
    %-------------------------------

    net = vgg19;
    vgg_layers = net.Layers;

    if length(vgg_layers) ~= length(layers)
        error('Number of layers does not match to number of layers in VGGNet')
    end
    
    for j = 1:length(vgg_layers)
        if isprop(vgg_layers(j), 'Weights')
            % Transform the weights of the first convolutional layer from
            % RGB to grayscale
            if j == 2
                weights = vgg_layers(j).Weights;
                gray_weights = [];
                weights = mat2gray(weights);
                for i = 1:size(weights, 4)
                    g_weight = rgb2gray(weights(:,:,:,i));
                    gray_weights = cat(4, gray_weights, g_weight);
                end
                layers(j).Weights = gray_weights;
            % Deal with weights of fully connected layers
            elseif j == 33
                layers(j).Weights = imresize(vgg_layers(j).Weights, [layers(j).OutputSize layers(j).InputSize]);
            elseif j == 39
                layers(j).Weights = imresize(vgg_layers(j).Weights, [layers(j).OutputSize layers(j).InputSize]);
            else
                % Copy all other weights as they are
                layers(j).Weights = vgg_layers(j).Weights;
            end
        end
    end
    
end