function restoreDynamicAxes(app, axesConfig)
    % Restore dynamic axes from saved configuration
    [numRows, numCols] = size(axesConfig);
    app.DynamicAxes = cell(numRows, numCols);

    for i = 1:numRows
        for j = 1:numCols
            if ~isempty(axesConfig(i, j))
                ax = uiaxes(app.ErrorAnalysisTab, 'Position', axesConfig(i, j).Position);
                plot(ax, axesConfig(i, j).XData, axesConfig(i, j).YData);
                title(ax, axesConfig(i, j).Title);
                xlabel(ax, axesConfig(i, j).XLabel);
                ylabel(ax, axesConfig(i, j).YLabel);
                app.DynamicAxes{i, j} = ax;
            end
        end
    end
end