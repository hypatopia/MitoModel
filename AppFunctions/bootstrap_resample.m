function resampledData = bootstrap_resample(data)
%{
Bootstrap resampling function
This function resamples the data with replacement
%}
    n = size(data, 1);
    resampledIdx = randi(n, n, 1);
    resampledData = data(resampledIdx, :);
end