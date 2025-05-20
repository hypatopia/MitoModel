function fileMenuSelected(app, event)
    % Get the label of the selected menu item
    selectedMenuItem = event.Source.Text;

    % Handle the selected menu item
    switch selectedMenuItem
        case 'Save Graphs'
            saveGraphs(app);

        case 'Save Session'
            saveSession(app);

        case 'Load Previous Session'
            app.loadSessions();

        case 'Save Results'
            saveResults(app);

        case 'Load Previous Results'
            loadPreviousResults(app);

        case 'Exit'
            exitApplication(app);

        otherwise
            disp('Unknown menu item selected.');
    end
end

function saveGraphs(app)
    % Prompt the user to choose a file name and location
    [file, path, filterIndex] = uiputfile({'*.png'; '*.jpg'; '*.tif'; '*.pdf'; '*.eps'}, 'Save Graphs As');

    if isequal(file, 0)
        % User canceled the operation
        return;
    end

    % Define the list of axes to save
    axesList = {app.O2_plot, app.OCR_plot, app.Cytc_plot, app.H_N_plot, app.H_P_plot};

    % Save each plot using exportgraphics
    for i = 1:length(axesList)
        currentFilePath = fullfile(path, sprintf('%s_plot%d%s', file, i, fileparts(file)));
        exportgraphics(axesList{i}, currentFilePath);
    end

    % Notify the user that the graphs have been saved
    msgbox('Graphs have been successfully saved.', 'Save Graphs');
end

function saveSession(app)
    % Prompt the user to select a file to save the session
    [fileName, pathName] = uiputfile('*.mat', 'Save Session As');

    if isequal(fileName, 0)
        % User canceled the operation
        return;
    end

    % Prepare session data to save
    sessionData = struct(...
        'ResultsTableData', app.ResultsTable.Data, ...
        'GAInfoTableData', app.GAInfoTable.Data, ...
        'MCMCResults', app.MCMCResults, ...
        'CorrMatrixData', app.CorrMatrixTable.Data, ...
        'DynamicAxesData', app.DynamicAxes);

    % Save session data to .mat file
    try
        save(fullfile(pathName, fileName), '-struct', 'sessionData');
        msgbox('Session saved successfully.', 'Save Session');
    catch ME
        msgbox(['Failed to save session: ', ME.message], 'Save Session', 'error');
    end
end

function saveResults(app)
    % Get the params struct from the app
    params = app.params;

    % Convert the struct to a table
    paramsTable = struct2table(params);

    % Prompt the user to select a file location to save the CSV
    [fileName, pathName] = uiputfile('*.csv', 'Save Params as CSV');

    if isequal(fileName, 0)
        disp('User canceled the operation.');
        return;
    end

    % Create the full file path and save the table to a CSV file
    filePath = fullfile(pathName, fileName);

    try
        writetable(paramsTable, filePath);
        disp(['Params saved to: ', filePath]);
    catch ME
        msgbox(['Failed to save results: ', ME.message], 'Save Results', 'error');
    end
end

function loadPreviousResults(app)
    % Prompt the user to select a .mat file
    [file, path] = uigetfile('OptimizedSolutions/*.mat', 'Select an Optimized Solution File');

    if isequal(file, 0)
        % User canceled the operation
        return;
    end

    % Load the selected .mat file
    loadedData = load(fullfile(path, file));

    % Extract optimized parameters from the loaded data
    loadedParams = extractOptimizedParams(loadedData);

    if isempty(loadedParams)
        errordlg('Selected file does not contain optimized parameters.', 'Error');
        return;
    end

    % Update app with loaded parameters and solve the model
    updateAppWithLoadedParams(app, loadedParams);
    solveAndPlotModel(app, loadedParams);
    msgbox('Results loaded from file successfully.', 'Results Loaded');
end

function loadedParams = extractOptimizedParams(loadedData)
    % Check and extract optimized parameters from the loaded data
    if isfield(loadedData, 'optimizedParams')
        loadedParams = loadedData.optimizedParams;
    elseif isfield(loadedData, 'optParams')
        loadedParams = loadedData.optParams;
    elseif isfield(loadedData, 'x')
        loadedParams = loadedData.x;
    else
        loadedParams = [];
    end
end

function updateAppWithLoadedParams(app, loadedParams)
    % Update ResultsTable and app's parameters with loaded values
    data = arrayfun(@(i) {sprintf('Parameter %d', i), loadedParams(i)}, 1:length(loadedParams), 'UniformOutput', false);
    app.ResultsTable.Data = data;

    % Assign loaded parameters to app's params
    app.params.optimized = loadedParams;
    app.params = updateMitoParams(app.params, loadedParams);
end

function params = updateMitoParams(params, optimized)
    % Update the mitochondrial model parameters with optimized values
    params.f0_Vmax = optimized(1);
    params.cytctot = optimized(2);
    params.f0_Km = optimized(3);
    params.fIV_Vmax = optimized(4);
    params.fIV_Km = optimized(5);
    params.fIV_K = optimized(6);
    params.fV_Vmax = optimized(7);
    params.fV_K = optimized(8);
    params.fV_Km = optimized(9);
    params.p_alpha = optimized(10);
    params.cytcredProp = optimized(11);

    params.cytcox = params.cytctot * params.cytcredProp;
    params.cytcred = params.cytctot - params.cytcox;

    if numel(optimized) == 16
        params.amp_1 = optimized(12);
        params.amp_2 = optimized(13);
        params.amp_3 = optimized(14);
        params.amp_4 = optimized(15);
        params.cyt_c_drop = optimized(16);
    end
end

function solveAndPlotModel(app, optimizedParams)
    % Solve the model using the loaded parameters
    [t, y] = solver_mito(optimizedParams, app.data, app.Model, app.modeleqns);

    % Extract variables from the model output
    cytcred = y(:, 1);
    o2 = y(:, 2);
    Hn = y(:, 3);
    Hp = y(:, 4);

    % Calculate the OCR values
    calcOCR = .5 * ((app.params.fIV_Vmax .* o2) ./ (app.params.fIV_Km .* (1 + (app.params.fIV_K ./ cytcred)) + o2)) .* Hn ./ Hp;
    calcOCR = calcOCR * 1e6;

    % Plot the results using the loaded parameters
    plot_vis(app.O2_plot, t, [o2, Real_O2], app.data.Injection_Times, app.data.Injection_Types, ...
        2, 0, 0.4470, 0.7410, .4, .4, .4, '--', 'Loaded Optimized Model', 'Raw Data');
    plot_vis(app.OCR_plot, t(2:end), [calcOCR(2:end), Real_OCR], app.data.Injection_Times, app.data.Injection_Types, ...
        2, 0, 0.4470, 0.7410, .4, .4, .4, '--', 'Loaded Optimized Model', 'Raw Data');
    plot_vis(app.Cytc_plot, t(2:end), cytcred(2:end), app.data.Injection_Times, app.data.Injection_Types, ...
        2, 0, 0.4470, 0.7410, .4, .4, .4, '--', 'Loaded Optimized Model');
    plot_vis(app.H_N_plot, t(2:end), Hn(2:end), app.data.Injection_Times, app.data.Injection_Types, ...
        2, 0, 0.4470, 0.7410, .4, .4, .4, '--', 'Loaded Optimized Model');
    plot_vis(app.H_P_plot, t(2:end), Hp(2:end), app.data.Injection_Times, app.data.Injection_Types, ...
        2, 0, 0.4470, 0.7410, .4, .4, .4, '--', 'Loaded Optimized Model');
end

function exitApplication(app)
    % Confirm with the user before closing the application
    choice = questdlg('Are you sure you want to exit?', 'Exit', 'Yes', 'No', 'No');

    if strcmp(choice, 'Yes')
        delete(app.UIFigure);
    end
end
