
            % value = app.ResultsTypeDropDown.Value;
            %
            % % Retrieve the optimization results from app properties
            % optimizedParams = app.optimizedParams;
            % fval = app.optimizedFval;
            %
            % % Display the results in a new window
            % createResultsWindow(app, optimizedParams, fval);
            % value = app.ResultsTypeDropDown.Value;
            %
            % % Retrieve the optimization results from app properties
            % optimizedParams = app.optimizedParams;
            % fval = app.optimizedFval;
            %
            % % Display the results in a new window
            % createResultsWindow(app, optimizedParams, fval);


            switch
    case 'Load Results from File'
        % Let user select a .mat file
        [filename, pathname] = uigetfile('*.mat', 'Select .mat file');

        if filename == 0
            % User canceled the operation
            return;
        end

        % Load the .mat file
        matFilePath = fullfile(pathname, filename);
        loadedData = load(matFilePath);

        % Extract the relevant results (adjust this based on your saved data structure)
        if isfield(loadedData, 'optimizedParams')
            loadedParams = loadedData.optimizedParams;

            % Update ResultsTable with loaded parameters
            data = cell(length(loadedParams), 2);
            for i = 1:length(loadedParams)
                data{i, 1} = sprintf('Parameter %d', i);
                data{i, 2} = loadedParams(i);
            end

            app.ResultsTable.Data = data;

            % Optionally, notify the user that the data has been loaded
            msgbox('Results loaded from file successfully.', 'Results Loaded');
        else
            errordlg('Selected file does not contain optimized parameters.', 'Error');
        end

        % Add other cases as needed (e.g., additional result types)
    case 'Other Result Type'
        % Handle other result types if applicable
        % Update ResultsTable accordingly
        % Example: app.ResultsTable.Data = { ... };

    case 'Download'
        % Create a table for optimized parameters and their confidence intervals
        paramNames = arrayfun(@(i) sprintf('Param %d', i), 1:length(app.OptimOutput.Params), 'UniformOutput', false);
        T = table(paramNames', app.OptimOutput.Params', app.confIntervals(:, 1), app.confIntervals(:, 2), 'VariableNames', {'Parameter', 'OptimizedValue', 'CI_Lower', 'CI_Upper'});
        % Save the table to a file
        filename = 'optimized_params.xlsx';
        writetable(T, filename);
        app.ResultsTextArea.Value = sprintf('Results have been saved to %s', filename);


end