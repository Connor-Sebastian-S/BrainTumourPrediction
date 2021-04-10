function [data, labels] = getTrainingData(cube_size)

    % Returns data and labels to train a network
    %   data    Tumour and non-tumour layers extracted from FLAIR images
    %   labels  Ones and zeros where 1 indicates tumour image and 0 non-tumour
    %           image
    % ----------------------------------------
    
    VOI_filepath = '../BRATS2019/data/BraTS19_*/*.nii';
    VOI_files = dir(VOI_filepath);
    
    data = [];
    labels = [];
    size(VOI_files)
    % Get the data to be processed (FLAIRs and VOIs)
    for file = VOI_files'
       % splitfile = strsplit(file.folder, '/VSD');
        %data_filepath = [splitfile{1} '/*_seg.nii.gz'];
        data_filepath = [file.folder '/*.nii'];
        data_file = dir(data_filepath);
        data_filepath = [data_file(1).folder '/' data_file(1).name]
       
        info = nii_read_header(data_filepath);
        MRI_data = nii_read_volume(info);
        
        filepath = [file.folder '/' file.name];
        info = nii_read_header(filepath);
        VOI_data = nii_read_volume(info);
        VOI_data(VOI_data>0) = 1;
        
        tumour_samples = getTumourData(MRI_data, VOI_data, cube_size);
        nontumour_samples = getNonTumourData(MRI_data, VOI_data, cube_size);
        
        if (~isempty(tumour_samples)) && (~isempty(nontumour_samples))
            for k = 1:size(tumour_samples, 4)
                tumour_sample = tumour_samples(:,:,:,k);
                tumour_sample = returnLayers(tumour_sample);
                tumour_sample = tumour_sample(:,:,:,1:3:end);
                data = cat(4, data, tumour_sample);
                labels = cat(1, labels, ones(size(tumour_sample, 4), 1));
            end
            for k = 1:size(nontumour_samples, 4)
                nontumour_sample = nontumour_samples(:,:,:,k);
                nontumour_sample = returnLayers(nontumour_sample);
                nontumour_sample = nontumour_sample(:,:,:,1:3:end);
                data = cat(4, data, nontumour_sample);
                labels = cat(1, labels, zeros(size(nontumour_sample, 4), 1));
            end
        end
        fprintf('%i samples collected. \n', size(data, 4))
    end
    
    clearvars MRI_data VOI_data
end

function layers = returnLayers(cube)
    
    % 
    layers = [];
    for s = 1:size(cube, 1)
        l = cube(:,:,s);
        l = imresize(l, [32 32]);
        layers = cat(4, layers, l);
    end
end