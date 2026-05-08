function r_sq = getRsquared(data, pred)
% Calculate unadjusted R-squared for a model prediction.

residual = data(:) - pred(:);
residual_sq = sum(residual.^2);

mean_data = mean(data);
ssq = sum((data - mean_data).^2);

r_sq = 1 - (residual_sq / ssq);

end
