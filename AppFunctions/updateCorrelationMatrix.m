function updateCorrelationMatrix(app, lowerLimit, upperLimit)
    % Clear previous results
    if ~isempty(app.CorrMatrixTable.Data)
        app.CorrMatrixTable.Data = {};
        app.CorrMatrixTable.ColumnName = {};
    end

    % Retrieve MCMC samples
    samples = app.MCMCResults.samples;

    % Compute the correlation matrix
    correlationMatrix = corr(samples);

    % Apply the filtering criteria to the correlation matrix
    filteredCorrelationMatrix = correlationMatrix;
    filteredCorrelationMatrix(correlationMatrix < lowerLimit | correlationMatrix > upperLimit) = NaN;

    % Fill the correlation matrix table with filtered data
    parameterNames = app.results.parameterNames;
    for i = 1:length(parameterNames)
        formattedParameter = ['<html><span style="font-size:14px;"><b>', parameterNames{i}, '</b></span></html>'];
        app.CorrMatrixTable.Data{1, i + 1} = formattedParameter;
        app.CorrMatrixTable.Data{i + 1, 1} = formattedParameter;
    end

    for i = 1:length(parameterNames)
        for j = 1:length(parameterNames)
            if isnan(filteredCorrelationMatrix(i, j))
                app.CorrMatrixTable.Data{i + 1, j + 1} = '';
            else
                app.CorrMatrixTable.Data{i + 1, j + 1} = filteredCorrelationMatrix(i, j);
            end
        end
    end

    % Update heatmap if it exists
    if isfield(app, 'heatmap')
        delete(app.heatmap);
    end

    % Define and apply custom colormap
    customColormap = createCustomColormap();

    % Create the heatmap
    app.heatmap = heatmap(app.CorrelationAnalysisTab, filteredCorrelationMatrix, ...
        'Colormap', customColormap, 'ColorLimits', [-1, 1], ...
        'Interpreter', 'latex');

    app.heatmap.Visible = 'off';    % Make the heatmap invisible

    % Customize the heatmap appearance
    if lowerLimit == -1 && upperLimit == 1
        app.heatmap.Title = 'Correlation Matrix Heatmap';
    else
        app.heatmap.Title = 'Filtered Correlation Matrix Heatmap';
    end
    app.heatmap.XDisplayLabels = app.results.parameterNames_LaTeX;
    app.heatmap.YDisplayLabels = app.results.parameterNames_LaTeX;
    app.heatmap.XLabel = 'Parameters';
    app.heatmap.YLabel = 'Parameters';
    app.heatmap.CellLabelColor = 'none';
    app.heatmap.FontSize = 14;
end