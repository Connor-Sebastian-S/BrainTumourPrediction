function [accracy, sen, spe] = measure(pred,labels)

% convert labels
labels(find(labels == 0)) = -1;
% 
pred(find(pred == 0)) = -1;

confusionMat = zeros(2,2);

for i = 1:1:length(labels)
    gt = labels(i);
    pp = pred(i);
    
    if gt == -1 && pp == -1
        confusionMat(2,2) = confusionMat(2,2) + 1;
    end
    
    if gt == -1 && pp == 1
        confusionMat(2,1) = confusionMat(2,1) + 1;
    end
    
    if gt == 1 && pp == -1
        confusionMat(1,2) = confusionMat(1,2) + 1;
    end
    
    if gt == 1 && pp == 1
        confusionMat(1,1) = confusionMat(1,1) + 1;
    end
end
    

sen = confusionMat(1,1)./ (confusionMat(1,1) + confusionMat(1,2));
spe = confusionMat(2,2) ./ (confusionMat(2,2) + confusionMat(2,1));
accracy = (confusionMat(2,2) + confusionMat(1,1))./length(labels);