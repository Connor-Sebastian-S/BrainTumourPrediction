function six_biomarkers = cal_statistics(data)

% This function calculate the following 6 statistics for the feature
%
% mean
% median
% standard devidation
% kurtosis
% 5th percentiles
% 95th percentiles

mean_value = mean(data);
median_value = median(data);
std_value = std(data);
kurtosis_value = kurtosis(data);

% skewness_value = skewness(data,0);

percent_5 = prctile(data, 5);
percent_95 = prctile(data, 95);

six_biomarkers = cat(2, mean_value, median_value, std_value, kurtosis_value, percent_5, percent_95);

end