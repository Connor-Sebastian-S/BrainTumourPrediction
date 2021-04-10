function samples = getNonTumourData(MRI, VOI, cube)

    % Return cubes of normal brain tissue areas
    %
    %   MRI     3D MR image
    %   VOI     3D tumour region
    %   cube    The size of the cube to extract
    %-------------------------------
    
    samples = [];
    for n = 1:3
        MRI = rot90(MRI);
        sample = getSample(MRI, VOI, cube);
        if ~isempty(sample)
            % Rotate the sampled cube back so all samples are consistent
            sample = rot90(sample, -n);
            samples = cat(4, samples, sample);
        end
    end
end

function sample = getSample(MRI, VOI, cube)
    % Crop the tumour out of the image
    for i = 1:size(MRI, 1)
        if sum(sum(VOI(i,:,:))) ~= 0
            MRI = MRI(1:i, :,:);
            break;
        end
    end
    
    % Cut the black background out
    for i = 1:size(MRI, 1)
        if sum(sum(MRI(i,:,:))) ~= 0
            MRI = MRI(i+1:end, :,:);
            break;
        end
    end
    
    sample = [];
    flag = 0;
    if size(MRI, 1) >= cube
        for i = 1:(size(MRI, 1) - cube)
            for k = 1:(size(MRI, 2) - cube)
                for n = 1:(size(MRI, 3) - cube)
                    if (i+cube)<size(MRI, 1) && (k+cube)<size(MRI, 2) && (n+cube)<size(MRI, 3)
                        if ~ismember(0, MRI(i:(i+cube-1), k:(k+cube-1), n:(n+cube-1)))
                            sample = cat(4, sample, MRI(i:(i+cube-1), k:(k+cube-1), n:(n+cube-1)));
                            MRI(i:(i+cube-1), k:(k+cube-1), n:(n+cube-1)) = 0;
                            flag = flag + 1;
                            if flag == 2
                                break;
                            end
                        end
                    end
                end
                if flag == 2
                    break;
                end
            end
            if flag == 2
                break;
            end
        end
    end

end