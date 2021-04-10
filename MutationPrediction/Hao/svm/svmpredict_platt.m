function [ll, acc, prob] = svmpredict_platt(lbls, feature, model, A, B, isProb)

if isProb
    [ll, acc, score] = svmpredict(lbls, feature, model, ' -q');

    probArr = zeros(length(lbls),size(A,1));
    for i = 1:1:length(A)
        probArr(:,i) = getLabelsFrom_dv(score, A(i), B(i));
    end

    prob = mean(probArr,2);

    ll = zeros(size(prob));
    ll(prob > 0.5) = 1;
else
    [ll, acc, prob] = svmpredict(lbls, feature, model, ' -q');
end

end
%%
function prob = getLabelsFrom_dv(score, A, B)

% high prob corresponds to the +ve (lbl = 1) class
prob = getP(score, A, B);

end

%%
function y = getP(x, A, B)
y = 1./(1+exp((A.*x+B)));
end
