function dimensions = findTumourSize()

    % Find the smallest tumour size to determine the size of the cubes to
    % be used for testing and training of brain scans
    %
    %   dimensions	The dimensions of the cube found to fit
    %               inside the smallest tumour
    %-------------------------------
    
    filepath = '../BRATS2015_Training/brats_*/VSD.Brain_3more.*/*.mha';
    files = dir(filepath);
    
    smallest_sum = 400000;
    
    % Get all the VOI images
    for file = files'
        filepath = [file.folder '/' file.name];
        info = mha_read_header(filepath);
        data = mha_read_volume(info);
        data(data>0) = 1;
        sum1 = sum(sum(data(:,:,1)));
        for i=2:size(data,3)
            sum1 = sum1 + sum(sum(data(:,:,i)));
        end
        
        if sum1 < smallest_sum
            smallest_sum = sum1;
            smallest_tumour = data;
        end
    end
    
    % Crop the image to a cube containing just the tumour
    for i = 1:size(smallest_tumour, 1)
        if sum(sum(smallest_tumour(i,:,:))) ~= 0
            smallest_tumour = smallest_tumour(i+1:end, :,:);
            break;
        end
    end
    
    for i = 1:size(smallest_tumour, 2)
        if sum(sum(smallest_tumour(:,i,:))) ~= 0
            smallest_tumour = smallest_tumour(:,i+1:end,:);
            break;
        end
    end
    
    for i = 1:size(smallest_tumour, 3)
        if sum(sum(smallest_tumour(:,:,i))) ~= 0
            smallest_tumour = smallest_tumour(:, :,i+1:end);
            break;
        end
    end
    
    for i = size(smallest_tumour, 1):-1:1
        if sum(sum(smallest_tumour(i,:,:))) ~= 0
            smallest_tumour = smallest_tumour(1:i-1,:,:);
            break;
        end
    end
    
    for i = size(smallest_tumour, 2):-1:1
        if sum(sum(smallest_tumour(:,i,:))) ~= 0
            smallest_tumour = smallest_tumour(:,1:i-1,:);
            break;
        end
    end
    
    for i = size(smallest_tumour, 3):-1:1
        if sum(sum(smallest_tumour(:,:,i))) ~= 0
            smallest_tumour = smallest_tumour(:,:,1:i-1);
            break;
        end
    end
    
    dimensions = 3;
    % Find the largest cube inside the smallest tumour
    for i = 1:(size(smallest_tumour, 1) - dimensions)
        for k = 1:(size(smallest_tumour, 2) - dimensions)
            for n = 1:(size(smallest_tumour, 3) - dimensions)
                if (i+dimensions)<size(smallest_tumour, 1) && (k+dimensions)<size(smallest_tumour, 2) && (n+dimensions)<size(smallest_tumour, 3)
                    if sum(sum(sum(smallest_tumour(i:(i+dimensions), k:(k+dimensions), n:(n+dimensions))))) == dimensions^3
                        dimensions = dimensions + 1;
                    end
                end
            end
        end
    end
        
    fprintf( 'The smallest tumour size (in pixels): %d x %d x %d\n', size(smallest_tumour,1), size(smallest_tumour,2),size(smallest_tumour, 3));
    fprintf( 'The dimesions of the largest cube to fit inside the tumour: %d', dimensions);
    
end