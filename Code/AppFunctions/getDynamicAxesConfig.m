function axesConfig = getDynamicAxesConfig(dynamicAxes)
    % Gather configuration data for dynamic axes
    axesConfig = struct();
    [numRows, numCols] = size(dynamicAxes);

    for i = 1:numRows
        for j = 1:numCols
            if i >= j && isvalid(dynamicAxes{i, j})
                axesConfig(i, j).Position = dynamicAxes{i, j}.Position;
                axesConfig(i, j).XData = dynamicAxes{i, j}.Children.XData;
                axesConfig(i, j).YData = dynamicAxes{i, j}.Children.YData;
                axesConfig(i, j).Title = dynamicAxes{i, j}.Title.String;
                axesConfig(i, j).XLabel = dynamicAxes{i, j}.XLabel.String;
                axesConfig(i, j).YLabel = dynamicAxes{i, j}.YLabel.String;
            end
        end
    end
end