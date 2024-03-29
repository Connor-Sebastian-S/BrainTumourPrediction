function runTextureAnalysis()
    % Run the texture analysis by first extracting features up to the specified
    % layer and then run the cross validation.
    %---------------------------------
    
    % Specify network, the layers to perform classification on, the name of
    % the network, which network model to use, and whether it used DKI or
    % FLAIR images, Can override by declaring a new variable after the preset
    % ones, i.e. layers = ["conv1_2"];

     %RESNET-18 variables
%     network = "resnet18";
%     net = resnet18;
%     disp(net.Layers);
%     layers = [];
    
     %Alexnet variables
%     network = 'alexnet';
%     net = alexnet;
%     disp(net.Layers);
%     layers = ["conv1", "conv2", "conv3", "conv4", "conv5", "fc6", "fc7", "fc8", "output"];

    %VGG19 variables
    network = 'vgg19';
    net = vgg19();
     layers = ["conv1_1", "conv1_2", "conv2_1", "conv2_2", "conv3_1", "conv3_2", ...
        "conv3_3", "conv3_4", "conv4_1", "conv4_2", "conv4_3", "conv4_4", ...
       "conv5_1", "conv5_2", "conv5_3", "conv5_4", "fc6", "fc7", "my-fc8", "output"];

%     %VGG16 variables
%     network = 'vgg16';
%     net = vgg16();  
%     layers = ["conv1_1", "conv1_2", "conv2_1", "conv2_2", "conv3_1", "conv3_2", ...
%         "conv3_3", "conv4_1", "conv4_2", "conv4_3", "conv5_1", "conv5_2", "conv5_3", ...
%         "fc6", "fc7", "fc8"];

    %InceptionV3 variables
%     network = 'inceptionv3';
%     net = inceptionv3();  
%     layers = ["conv2d_1", "conv2d_2", "conv2d_3", "conv2d_4", "conv2d_5", "conv2d_9", ...
%         "conv2d_7", "conv2d_10", "conv2d_6", "conv2d_8", "conv2d_11", "conv2d_12", "conv2d_16", ...
%         "conv2d_14", "conv2d_17", "conv2d_13", "conv2d_15", "conv2d_18", "conv2d_19", "conv2d_23", ...
%         "conv2d_21", "conv2d_24", "conv2d_20", "conv2d_22", "conv2d_25", "conv2d_26", "conv2d_28", ...
%         "conv2d_29", "conv2d_27", "conv2d_30", "conv2d_35", "conv2d_36", "conv2d_32", "conv2d_37", ...
%         "conv2d_33", "conv2d_38", "conv2d_31", "conv2d_34", "conv2d_39", "conv2d_40", "conv2d_45", ...
%         "conv2d_46", "conv2d_42", "conv2d_47", "conv2d_43", "conv2d_48", "conv2d_41", "conv2d_44", ...
%         "conv2d_49", "conv2d_50", "conv2d_55", "conv2d_56", "conv2d_52", "conv2d_57", "conv2d_53", ...
%         "conv2d_58", "conv2d_51", "conv2d_54", "conv2d_59", "conv2d_60", "conv2d_65", "conv2d_66", ...
%         "conv2d_62", "conv2d_67", "conv2d_63", "conv2d_68", "conv2d_61", "conv2d_64", "conv2d_69", ...
%         "conv2d_70", "conv2d_73", "conv2d_74", "conv2d_71", "conv2d_75", "conv2d_72", "conv2d_76", ...
%         "conv2d_81", "conv2d_78", "conv2d_82", "conv2d_79", "conv2d_80", "conv2d_83", "conv2d_84", ...
%         "conv2d_77", "conv2d_85", "conv2d_90", "conv2d_87", "conv2d_91", "conv2d_88", "conv2d_89", ...
%         "conv2d_92", "conv2d_93", "conv2d_86", "conv2d_94", "predictions", "predictions_softmax", ...
%         "ClassificationLayer_predictions"];
    
%     l = 12;
%     n = net.Layers(l).Name;
%     channels = 1:56;
%     I = deepDreamImage(net,l,channels,'PyramidLevels',1);
%     figure
%     I = imtile(I,'ThumbnailSize',[64 64]);
%     imshow(I)
%     title(['Layer ',n,' Features'])
    
    trainingMethod = 1; %0 = pre-trained, 1 = BRATS2015 trained
    modality = 'DKI'; %DKI or Flair
    %buildFeatures = false; %create feature image for network
    startLayerNo = 1; %start loop on layer n
    endLayerNo = length(layers); %end loop on layer n

%     for a = startLayerNo:1:endLayerNo
%         model = getTextureModelVGG(a, net, layers, network, trainingMethod, modality);
% %         if buildFeatures == true
% %             buildVGGFeature(model, net);
% %         end
%         LOOCV_SVM(model);
%     end

    for i = startLayerNo:endLayerNo
        disp(i);
        for a = i:1:i
            model = getTextureModelVGG(a, net, layers, network, trainingMethod, modality);
            buildVGGFeature(model, net);
        end

        LOOCV_SVM(model);
    end
end
