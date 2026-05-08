% Description:
% Calculate adjusted R-squared for a model prediction.
%
% Reference: https://uk.mathworks.com/help/stats/coefficient-of-determination-r-squared.html
function adj_r_sq = getAdjustedRsquared(data, pred, num_params)

residual = data(:) - pred(:);
residual_sq = sum(residual.^2);

mean_data = mean(data);
ssq = sum((data - mean_data).^2);

n = length(data); % Number of observations

% Adjusted R-squared formula
adj_r_sq = 1 - ((n-1)/(n-num_params))*(residual_sq/ssq);

end
