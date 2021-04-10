function [bestC, bestG, bestAcc, bestFeats] = innerLoop(Feature, labels, cRange, gRange, isProb, featSelection)

    % Find the best c and g values in the inner loop of nested cross validation
    %
    %   bestC       C value of the best performing svm model
    %   bestG       G value of the best performing svm model
    %   bestAcc     Best accuracy achieved through all loops
    %   bestFeats   The most popular features of the best performing svm
    %               model
    %-------------------------------

    % How many top features are returned if feature selection is used
    featSize = 100; %should be 100 originally
    
    accArray = zeros(length(cRange), length(gRange));
    featArray = cell(length(cRange), length(gRange));
    for m = 1:1:length(cRange)
        for n = 1:1:length(gRange)
            c = 2.^ cRange(m);
            g = 2.^ gRange(n);

            feats = [];

            acc = zeros(length(labels),1);
            pred = zeros(length(labels),1);
            for i = 1:1:length(labels)
                ind = logical(zeros(length(labels),1));
                ind(i) = true;

                % Separate the train and test set
                trainFeature = Feature(~ind,:);
                trainLabels = labels(~ind);

                testFeature  = Feature(ind,:);
                testLabels = labels(ind);

                % Perform feature selection
                if featSelection
                    param = struct('rfeC', c, 'refG', g);
                    [ftRank, ~] = ftSel_SVMRFECBR(trainFeature, trainLabels.', param);
                    selected_ind = ftRank(1:featSize);
                    feats = cat(2, feats, selected_ind);
                    trainFeature = trainFeature(:,selected_ind);
                    testFeature = testFeature(:, selected_ind);
                end

                % SVM training with LIBSVM
                l0 = length(find(labels == 0));
                l1 = length(find(labels == 1));
                options = ['-s 0 -t 2 -c ' num2str(c) ' -g ' num2str(g)  ' -w0 ' num2str((l0+l1)/2/l0) ' -w1 ' num2str((l0+l1)/2/l1) ' -q'];
                model = svmtrain(trainLabels', trainFeature, options);

                % Platt's scaling
                isBagging = 0;
                isLOOCV = 0;
                [A, B] = plattScaling(trainLabels, trainFeature, model,isBagging, isLOOCV, options);

                % SVM testing with LIBSVM
                [ll, ~, prob] = svmpredict_platt(testLabels', testFeature, model, A, B, isProb);

                pred(i) = ll;
                if ll == testLabels
                    acc(i) = 1;
                end
            end
            Acc = sum(acc)/length(acc)*100;
            accArray(m,n) = Acc;

            % Select the most common features
            if featSelection
                ufeatures = unique(feats);
                [~, indx] = sort(histc(feats(:), ufeatures), 'descend');
                featArray(m,n) = {ufeatures(indx(1:featSize))};
            end
        end
    end

    bestAcc = max(max(accArray));

    bestInd = find(accArray == bestAcc);
    [r,c] = ind2sub(size(accArray), bestInd(1));

    if featSelection
        bestFeats = featArray{r, c};
    else
	bestFeats = [];
    end

    bestC = 2.^cRange(r);
    bestG = 2.^gRange(c);
end
