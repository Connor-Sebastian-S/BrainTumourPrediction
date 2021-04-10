function [A, B] = plattScaling(lbls, feature, model, isBagging, isLOOCV, options)

if isLOOCV
    scores = [];
    for i = 1:1:length(lbls)
        ind = logical(zeros(length(lbls),1));
        ind(i) = true;
            
        % train feature and lbls
        trainFeature = feature(~ind,:);
        trainlbls = lbls(~ind);

        % test feature and lbls
        testFeature  = feature(ind,:);
        testlbls = lbls(ind);
        
        svmmodel = svmtrain1(trainlbls', trainFeature, options);
        [~, ~, dv] = svmpredict(testlbls, testFeature, svmmodel, ' -q');
        scores = [scores; dv];
    end
else
    [~,~,scores] = svmpredict(lbls', feature, model, ' -q');
end

if isBagging   
    % learn Platt using Bagging
    iter = 50;
    A = zeros(iter,1);
    B = zeros(iter,1);
    
    lbls(lbls~=1) = -1;
    n = min(length(find(lbls==1)), length(find(lbls~=1)));
    negIdx = find(lbls==-1);
    posIdx = find(lbls==1);
    
    for i = 1:1:iter
        negIdx = negIdx(randperm(length(negIdx)));
        negIdx = negIdx(1:n);
        posIdx = posIdx(randperm(length(posIdx)));
        posIdx = posIdx(1:n);
        idx = [posIdx, negIdx];
    
        lbly = lbls(idx);
        score_ = scores(idx);
        [a, b] = platt(score_, lbly', length(find(lbly==-1)), length(find(lbly==1)));
        A(i) = a;
        B(i) = b;
    
    end
else
    % learn Platt without Bagging
    lbls(lbls~=1) = -1;
    [A, B] = platt(scores, lbls', length(find(lbls==-1)), length(find(lbls==1)));
end


end
