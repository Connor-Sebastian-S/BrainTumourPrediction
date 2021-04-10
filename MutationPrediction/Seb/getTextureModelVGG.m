function model = getTextureModelVGG(layerNo, net, layersList, name, trainingMethod, modality)
    
    % Returns a model where all details about the feature extraction and cross
    % validation are stored in
    % 
    %   layerNo    Number of the convolutional output layer from the VGGnet
    %-------------------------------------

    % Set feature selection details
    FEATURE = struct;
    
    FEATURE.selection = 0;
    
    %Flair, DKI, or Both
    FEATURE.modality = modality;

    % Path to dataset
    DIR = struct;
    DIR.ImageFolder = './MRIData';

    % Get the VGG network. 
    % 0 for pretrained, 1 for self-trained and 2 for tweaked
    FEATURE.VGG.trainingmethod = trainingMethod;
    
    if FEATURE.VGG.trainingmethod == 0
        DIR.FeatureFolder = ['FeatureFolder/' name '/' modality '/network1/'];
    elseif FEATURE.VGG.trainingmethod == 1
        data = load(['../NetworkTraining/Networks/' name '/2/network.mat']);
        net = data.trainedNet;
        DIR.FeatureFolder = ['FeatureFolder/'  name '/' modality '/network2/'];
    else
        data = load(['../NetworkTraining/Networks/' name '/3/network.mat']);
        net = data.trainedNet;
        DIR.FeatureFolder = ['FeatureFolder/' name '/' modality '/' 'network3/'];
    end

    model.DIR = DIR;
    model.NETWORK = name;
    FEATURE.VGG.net = net;

    FEATURE.VGG.layers = layersList;
    FEATURE.VGG.layerNo = layerNo; 
    
    FEATURE.VGG.layer = char(FEATURE.VGG.layers(layerNo));

    model.FEATURE = FEATURE;
    
    model.LabelFile = './MRIData/37_Patients_Data.xlsx';
    model.ITKSNAP = {'NR_Diff_16', 'NR_Diff_18', 'NR_Diff_19', 'NR_Diff_26', 'NR_Diff_27', 'NR_Diff_28', 'NR_Diff_31', 'NR_Diff_33'};
    model.BoundaryOnly = {'NR_Diff_45', 'NR_Diff_55'};
end

