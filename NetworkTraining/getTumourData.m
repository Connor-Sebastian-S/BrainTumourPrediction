function sample = getTumourData(MRI, VOI, cube)

    % Return cubes of brain tumour tissue areas
    %
    %   MRI     3D MR image
    %   VOI     3D tumour region
    %   cube    The size of the cube to extract
    %-------------------------------

    [MRI, VOI] = cropImage(MRI, VOI);
    MRI = rot90(MRI);
    VOI = rot90(VOI);
    [MRI, VOI] = cropImage(MRI, VOI);
    MRI = rot90(MRI, -1);
    VOI = rot90(VOI, -1);
    for i = 1:size(MRI, 3)
        if sum(sum(VOI(:,:,i))) ~= 0
            MRI = MRI(:, :,i+1:end);
            VOI = VOI(:, :,i+1:end);
            break;
        end
    end
    
    % Crop the image until the tumour from the bottom
    for i = size(MRI, 3):-1:1
        if sum(sum(VOI(:,:,i))) ~= 0
            MRI = MRI(:,:,1:i-1);
            VOI = VOI(:,:,1:i-1);
            break;
        end
    end
    
    
    sample = [];
    flag = 0;
    % Find the cube inside the MRI
    for i = 1:(size(MRI, 1) - cube)
        for k = 1:(size(MRI, 2) - cube)
            for n = 1:(size(MRI, 3) - cube)
                if (i+cube)<size(MRI, 1) && (k+cube)<size(MRI, 2) && (n+cube)<size(MRI, 3)
                    if sum(sum(sum(VOI(i:(i+cube-1), k:(k+cube-1), n:(n+cube-1))))) == cube^3
                        sample = cat(4, sample, MRI(i:(i+cube-1), k:(k+cube-1), n:(n+cube-1)));
                        VOI(i:(i+cube-1), k:(k+cube-1), n:(n+cube-1)) = 0;
                        flag = flag + 1;
                        if flag == 4
                            break;
                        end
                    end
                end
            end
            if flag == 4
                break;
            end
        end
        if flag == 4
            break;
        end
    end
end

function [cropped, croppedVOI] = cropImage(MRI, VOI)
    % Crop the image until the tumour from the top
    for i = 1:size(MRI, 1)
        if sum(sum(VOI(i,:,:))) ~= 0
            MRI = MRI(i+1:end, :,:);
            VOI = VOI(i+1:end, :,:);
            break;
        end
    end
    
    % Crop the image until the tumour from the bottom
    for i = size(MRI, 1):-1:1
        if sum(sum(VOI(i,:,:))) ~= 0
            cropped = MRI(1:i-1,:,:);
            croppedVOI = VOI(1:i-1,:,:);
            break;
        end
    end
end