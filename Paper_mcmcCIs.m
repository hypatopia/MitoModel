 
    % Update parameters with optimized values
                        app.params.f0_Vmax = app.PrevResults.params.f0_Vmax;
                        app.params.cytctot = app.PrevResults.params.cytctot;
                        app.params.f0_Km = app.PrevResults.params.f0_Km;
                        app.params.fIV_Vmax = app.PrevResults.params.fIV_Vmax;
                        app.params.fIV_Km = app.PrevResults.params.fIV_Km;
                        app.params.fIV_K = app.PrevResults.params.fIV_K;
                        app.params.fV_Vmax = app.PrevResults.params.fV_Vmax;
                        app.params.fV_K = app.PrevResults.params.fV_K;
                        app.params.fV_Km = app.PrevResults.params.fV_K;
                        app.params.p_alpha = app.PrevResults.params.p_alpha;
                        app.params.cytcredProp = app.PrevResults.params.cytcredProp;

                        app.params.cytcox = app.params.cytctot  * app.params.cytcredProp;
                        app.params.cytcred = app.params.cytctot - app.params.cytcox;

                        app.params.alphas.amp_1 = app.PrevResults.params.alphas.amp_1;
                        app.params.alphas.amp_2 = app.PrevResults.params.alphas.amp_2;
                        app.params.alphas.amp_3 = app.PrevResults.params.alphas.amp_3;
                        app.params.alphas.amp_4 = app.PrevResults.params.alphas.amp_4;

% Dataset III:
app.OptimOutput.Params = [856.1306678
100.0669098
0.1
0.39702239
0.000993442
0.009856986
2.078404427
0.009997972
0.008936392
0.01
0.321964321
2.034279688
0.000230666
0.000195744
0.00013127
0.001
]

% % Dataset I - Baseline Model:
% app.OptimOutput.Params = [716.3911
%     527.3689
%     493.9444
%     9.0593
%     6.7196e-04
%     0.0039
%     3
%     0.0099
%     0.0932
%     0.0100
%     0.0299
%     ]


% % Dataset I - Full Model:
% app.OptimOutput.Params = [4.511867174590992e+02
% 1.000351562500000e+02
% 0.522118090247727
% 2.495094753703318
% 3.558549214921851e-04
% 0.003907250000000
% 2.712890625000000
% 0.008884002722942
% 0.015635000000000
% 0.01000000000000
% 0.219470731712196
% 1.793583697272764
% 4.312768186159733e-04
% ]

% % Dataset II:
% app.OptimOutput.Params = [840.4067
% 184.4990
% 0.1183
% 3.9239
% 8.4011e-04
% 0.0094
% 2.0178
% 0.0022
% 1.3815e-05
% 0.0039
% 0.1676
% 2.2291
% 0.1522
% 1.9257e-05
% ]


optimizedParams = num2cell(app.OptimOutput.Params);
 


% Define base parameter names
            app.results.parameterNames = {
                '<div style="padding: 30px 0;"><i>V<sub>max<sub>c<sub>0</sub></sub></i></div>', ...
                '<div style="padding: 30px 0;"><i>cyt c<sub>tot</sub></i></div>', ...
                '<div style="padding: 30px 0;"><i>K<sub>m<sub>c<sub>0</sub></sub></i></div>', ...
                '<div style="padding: 30px 0;"><i>V<sub>max<sub>c<sub>IV</sub></sub></i></div>', ...
                '<div style="padding: 30px 0;"><i>K<sub>m<sub>c<sub>IV</sub></sub></i></div>', ...
                '<div style="padding: 30px 0;"><i>K<sub>c<sub>IV</sub></sub></i></div>', ...
                '<div style="padding: 30px 0;"><i>V<sub>max<sub>c<sub>V</sub></sub></i></div>', ...
                '<div style="padding: 30px 0;"><i>K<sub>c<sub>V</sub></sub></i></div>', ...
                '<div style="padding: 30px 0;"><i>K<sub>m<sub>c<sub>V</sub></sub></i></div>', ...
                '<div style="padding: 30px 0;"><i>P<sub>leak</sub></i></div>', ...
                '<div style="padding: 30px 0;"><i>cyt c red<sub>Prop</sub></i></div>'
                };

            % Define parameter names for labeling
            app.results.parameterNames_LaTeX = {
                '$V_{max_{c_0}}$', ...
                '$Cyt c_{tot}$', ...
                '$K_{m_{c_0}}$', ...
                '$V_{max_{c_{IV}}}$', ...
                '$K_{m_{c_{IV}}}$', ...
                '$K_{c_{IV}}$', ...
                '$V_{max_{c_V}}$', ...
                '$K_{c_V}$', ...
                '$K_{m_{c_V}}$', ...
                '$P_{leak}$', ...
                '$Cyt c_{red_{Prop}}$'
                };


            % Dynamically append alpha parameters if the model type is FullModelGlobal
            if strcmp(app.Model.Type, 'FullModelGlobal')
                % Get the number of alphas dynamically
                num_alphas = app.params.alphas.num_alphas;

                % Generate alpha parameter names
                alphaNamesHTML = arrayfun(@(i) sprintf('<div style="padding: 30px 0;"><i>&#x0251<sub>%d</sub></i></div>', i), 1:num_alphas, 'UniformOutput', false);
                alphaNamesLaTeX = arrayfun(@(i) sprintf('$\\alpha_%d$', i), 1:num_alphas, 'UniformOutput', false);

                % Add alpha parameter names to the results lists
                app.results.parameterNames = [app.results.parameterNames, alphaNamesHTML];
                app.results.parameterNames_LaTeX = [app.results.parameterNames_LaTeX, alphaNamesLaTeX];

                % Add the attenuateProp parameter
                app.results.parameterNames{end+1} = '<div style="padding: 30px 0;"><i>r<sub>attenuate</sub></i></div>';
                app.results.parameterNames_LaTeX{end+1} = '$r_{attenuate}$';
            end

            parameterNames = app.results.parameterNames;
            parameterNames_LaTeX = app.results.parameterNames_LaTeX;
            app.TabGroup.SelectedTab = app.ResultsTab;
                    app.OptimizedParametersPanel.Visible = 'on';
                    app.GAInfo.Visible = 'on';
                    % Clear previous results
                    if ~isempty(app.ResultsTable.Data)
                        app.ResultsTable.Data= {};
                    end
                    if ~isempty(app.GAInfoTable.Data)
                        app.GAInfoTable.Data = {};
                    end

                    % Prepare data for the table
                    tableData = cell(length(parameterNames), 2);
                    for i = 1:length(parameterNames)
                        tableData{i, 1} = parameterNames{i};
                        tableData{i, 2} = optimizedParams{i};
                    end

                    % Update the data in ResultsTable
                    app.ResultsTable.Data = tableData;
                    app.ResultsTable.ColumnName = {'Parameter', 'Optimized Value'};
                    app.ResultsTable.ColumnEditable = [false false];

                    % Create and apply the HTML interpreter style
                    htmlStyle = uistyle('Interpreter', 'html');
                    addStyle(app.ResultsTable, htmlStyle);


                    % Update GA info in the table
                    gaInfoData = {
                        'Optimization Success', app.gaInfo.successInfo;
                        'Number of Iterations', app.gaInfo.numIterations;
                        'Population Size', app.gaInfo.PopulationSize;
                        'Max Generations', app.gaInfo.MaxGenerations;
                        'GA Error', app.gaInfo.gaError;
                        'Duration (s)', app.gaInfo.Duration
                        };


                    if isfield(app.gaInfo, 'bootstrapSamples')
                        gaInfoData = [gaInfoData; {'Bootstrap Samples', app.gaInfo.bootstrapSamples}];
                    end


                    % Update the data in GAInfoTable
                    app.GAInfoTable.Data = gaInfoData;

                    % Create and apply the HTML interpreter style
                    htmlStyle = uistyle('Interpreter', 'html');
                    addStyle(app.GAInfoTable, htmlStyle);
                     if isempty(app.ResultsTable.Data)
                        msgbox('Please first choose Display to fill the required records, then choose this item.');
                        return;
                    end
                    app.TabGroup.SelectedTab = app.ResultsTab;

                    if ~isempty(app.mcmcInfoTable.Data)
                        app.mcmcInfoTable.Data = {};
                    end

                    % Prompt user for MCMC parameters
                    prompt = {'Enter the number of MCMC iterations:', ...
                        'Enter the thinning factor:', ...
                        'Enter the step size for proposal distribution:', ...
                        'Enter the confidence level (%):'};
                    dlgtitle = 'MCMC Parameters';
                    dims = [1 35];
                    definput = {'1000', '10', '0.1', '95'};
                    answer = inputdlg(prompt, dlgtitle, dims, definput);

                    if isempty(answer)
                        return; % User canceled the dialog
                    end

                    % Parse user inputs
                    mccount = str2double(answer{1});
                    skip = str2double(answer{2});
                    stepSize = str2double(answer{3});
                    confidenceLevel = str2double(answer{4}) / 100;

                    % Run MCMC and store results in app.MCMCResults
                    runMCMC(app, mccount, skip, stepSize, confidenceLevel);

                    % Retrieve MCMC results
                    mcmcResults = app.MCMCResults;
                    meanParams = num2cell(mcmcResults.meanParams);
                    confidenceIntervals = mcmcResults.confidenceIntervals;


                    % Prepare data for the Results Table
                    tableData = cell(length(parameterNames), 4);
                    for i = 1:length(parameterNames)
                        tableData{i, 1} = parameterNames{i};
                        tableData{i, 2} = optimizedParams{i};
                        tableData{i, 3} = meanParams{i};
                        tableData{i, 4} = sprintf('[%.5f, %.5f]', confidenceIntervals(i, :));
                    end

                    % Make mcmcInfoTable visible
                    app.mcmcInfoPanel.Visible = 'on';

                    % Update the data in MCMC Results Table
                    app.ResultsTable.Data = tableData;
                    app.ResultsTable.ColumnName = {'Parameter', 'Optimized Value', 'Mean Value', 'Confidence Interval (CI)'};
                    app.ResultsTable.ColumnEditable = [false false false false];

                    % Create and apply the HTML interpreter style
                    htmlStyle = uistyle('Interpreter', 'html');
                    addStyle(app.ResultsTable, htmlStyle);

                    % Display log-prior and log-likelihood in mcmcInfoTable
                    finalLogPrior = mcmcResults.logP(end, 1);
                    finalLogLikelihood = mcmcResults.logP(end, 2);

                    % Update mcmcInfoTable
                    infoTableData = {
                        'Final Log-Prior', finalLogPrior;
                        'Final Log-Likelihood', finalLogLikelihood;
                        'Overall Acceptance Rate', mcmcResults.overallAcceptanceRate;
                        'Log-Prior Acceptance Rate', mcmcResults.acceptanceRate; % Assuming this is correct
                        'Log-Likelihood Acceptance Rate', mcmcResults.acceptanceRate; % Needs confirmation if this is correct
                        'Average Log-Prior', mcmcResults.avgLogPrior;
                        'Average Log-Likelihood', mcmcResults.avgLogLikelihood;
                        };

                    if ~isempty(app.GAInfoTable.Data)
                        app.mcmcInfoTable.Data = infoTableData;
                    end

                    % Create and apply HTML interpreter style for mcmcInfoTable
                    addStyle(app.mcmcInfoTable, htmlStyle);
