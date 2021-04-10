function [DKI, Flair, VOI_K, VOI_F, PixelDimensions] = Read_Images_VOIs(model, name)


%% read dicom image

ImageFolder = model.DIR.ImageFolder;

% read DKI image
DICOM_folder = [ImageFolder '/' name '/DKI_K/DICOM'];
num1 = getDirContent(DICOM_folder);
num2 = getDirContent([DICOM_folder '/' num1{:}]);

Image_Path = [[DICOM_folder '/' num1{:}] '/' num2{:}];

info = dicom_read_header(Image_Path);
DKI = dicom_read_volume(info);
% the first slice z position is negative, if not, convert (flip) it
if info.ImagePositionPatient(3) > 0
    ind = 1:1:size(DKI,3);
    ind = flip(ind);
    DKI = DKI(:,:,ind);
end

% read Flair image
DICOM_folder = [ImageFolder '/' name '/FLAIR/DICOM'];
num1 = getDirContent(DICOM_folder);
num2 = getDirContent([DICOM_folder '/' num1{:}]);

Image_Path = [[DICOM_folder '/' num1{:}] '/' num2{:}];

info = dicom_read_header(Image_Path);
PixelDimensions = info.PixelDimensions;
Flair = dicom_read_volume(info);
% the first slice z position is negative, if not, convert (flip) it
if info.ImagePositionPatient(3) > 0
    ind = 1:1:size(Flair,3);
    ind = flip(ind);
    Flair = Flair(:,:,ind);
end


%% read annotation
% annotation the first slice always postive -> negative
% read DKI_VOI
lblsName = dir([ImageFolder '/' name '/DKI_K/*_smask.mat']);
lbls_path = [ImageFolder '/' name '/DKI_K/' lblsName.name];
lbls = load(lbls_path);
lbls = lbls.matArray;
% flip along the slice direction
ind = 1:1:size(DKI,3);
ind = flip(ind);
VOI_K = lbls(:,:,ind);

% read Flair_VOI
lblsName = dir([ImageFolder '/' name '/FLAIR/*_smask.mat']);
lbls_path = [ImageFolder '/' name '/FLAIR/' lblsName.name];
lbls = load(lbls_path);
lbls = lbls.matArray;
% flip along the slice direction
ind = 1:1:size(Flair,3);
ind = flip(ind);
VOI_F = lbls(:,:,ind);

% visualization
% slice1 = DecideSliceBasedonArea(VOI_F);
% slice2 = DecideSliceBasedonArea(VOI_K);
% sz = get(0,'screensize');
% figure('outerposition', sz);
% suptitle(name(end-1:end))
% subplot(2,2,1), imagesc(Flair(:,:,slice1));
% subplot(2,2,2), imagesc(VOI_F(:,:,slice1));
% subplot(2,2,3), imagesc(DKI(:,:,slice2));
% subplot(2,2,4), imagesc(VOI_K(:,:,slice2));
    

end
