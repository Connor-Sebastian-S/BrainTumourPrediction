function content = getDirContent(directory, ext)


% get the file/ fold names in the directory.
% directory needs to a folder containing sub-folders.

% if nargin == 1;    
%     d = dir(directory);
%     content = {d(:).name}';
%     ind = find(ismember(content,'.'));
%     ind = [ind, find(ismember(content,'..'))];
%     content(ind) = [];
% else
%     d = dir([directory '/*' ext]);
%     content = {d(:).name}';
%     ind = find(ismember(content,'.'));
%     ind = [ind, find(ismember(content,'..'))];
%     content(ind) = [];
% 
% end

if nargin == 1
    subjects = dir(directory)';
    caseNames = {};
    for subject = subjects
        %ignore ., .., and files
        if (isempty(strfind(subject.name, '.')))
            caseNames{end+1} = subject.name;
        end
    end
    content = caseNames';
else
    d = dir([directory '/*' ext]);
    content = {d(:).name}';
    ind = find(ismember(content,'.'));
    ind = [ind, find(ismember(content,'..'))];
    content(ind) = [];
end


 