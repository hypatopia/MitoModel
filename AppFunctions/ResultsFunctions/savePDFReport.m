function savePDFReport(app, folderName)
    % Define the current time and date for file naming
    curr_time = datestr(now, 'HH_MM_SS');
    curr_date = datestr(now, 'yyyy-mm-dd');
    COMPUTERNAME = getenv('COMPUTERNAME');
    pdfFileName = sprintf('Results_%s_%s_%s.pdf', curr_date, curr_time, COMPUTERNAME);
    fullPDFFileName = fullfile(folderName, pdfFileName);

    % Check if MATLAB Report Generator license is available
    if ~license('test', 'Report_Generator')
        errordlg('MATLAB Report Generator license not available. Cannot generate PDF report.', 'License Error');
        return;
    end

    % Create a new PDF document
    pdf = mlreportgen.dom.Document(fullPDFFileName, 'pdf');

    % Add title to the PDF document
    title = mlreportgen.dom.Paragraph('Model Optimization Results');
    title.Bold = true;
    title.FontSize = '18pt';
    append(pdf, title);

    % Add optimized parameters section
    append(pdf, mlreportgen.dom.Paragraph('Optimized Parameters:'));
    paramTable = mlreportgen.dom.Table({'Parameter', 'Optimized Value'});
    for i = 1:size(app.ResultsTable.Data, 1)
        row = mlreportgen.dom.TableRow({app.ResultsTable.Data{i, 1}, num2str(app.ResultsTable.Data{i, 2})});
        append(paramTable, row);
    end
    append(pdf, paramTable);

    % Add MCMC results section if present
    if size(app.ResultsTable.Data, 2) >= 4
        append(pdf, mlreportgen.dom.Paragraph('MCMC Analysis Results:'));
        mcmcTable = mlreportgen.dom.Table({'Parameter', 'Optimized Value', 'Mean Value', 'Confidence Interval (CI)'});
        for i = 1:size(app.ResultsTable.Data, 1)
            row = mlreportgen.dom.TableRow({app.ResultsTable.Data{i, 1}, ...
                num2str(app.ResultsTable.Data{i, 2}), ...
                num2str(app.ResultsTable.Data{i, 3}), ...
                app.ResultsTable.Data{i, 4}});
            append(mcmcTable, row);
        end
        append(pdf, mcmcTable);
    end

    % Add Bootstrap Confidence Intervals section if available
    if size(app.ResultsTable.Data, 2) == 5
        append(pdf, mlreportgen.dom.Paragraph('Bootstrap Confidence Intervals:'));
        bootstrapTable = mlreportgen.dom.Table({'Parameter', 'Optimized Value', 'Mean Value', 'Confidence Interval (CI)', 'CI by Bootstrap Samples'});
        for i = 1:size(app.ResultsTable.Data, 1)
            row = mlreportgen.dom.TableRow({app.ResultsTable.Data{i, 1}, ...
                num2str(app.ResultsTable.Data{i, 2}), ...
                num2str(app.ResultsTable.Data{i, 3}), ...
                app.ResultsTable.Data{i, 4}, ...
                app.ResultsTable.Data{i, 5}});
            append(bootstrapTable, row);
        end
        append(pdf, bootstrapTable);
    end

    % Add GA Information section if present
    if ~isempty(app.GAInfoTable.Data)
        append(pdf, mlreportgen.dom.Paragraph('Genetic Algorithm (GA) Information:'));
        gaTable = mlreportgen.dom.Table({'Generation', 'Best Score'});
        for i = 1:size(app.GAInfoTable.Data, 1)
            row = mlreportgen.dom.TableRow({num2str(app.GAInfoTable.Data{i, 1}), num2str(app.GAInfoTable.Data{i, 2})});
            append(gaTable, row);
        end
        append(pdf, gaTable);
    end

    % Add Correlation Matrix section
    append(pdf, mlreportgen.dom.Paragraph('Correlation Matrix:'));
    corrMatrixTable = mlreportgen.dom.Table({'Parameter 1', 'Parameter 2', 'Correlation'});
    for i = 1:size(app.CorrMatrixTable.Data, 1)
        row = mlreportgen.dom.TableRow({app.CorrMatrixTable.Data{i, 1}, ...
            app.CorrMatrixTable.Data{i, 2}, ...
            num2str(app.CorrMatrixTable.Data{i, 3})});
        append(corrMatrixTable, row);
    end
    append(pdf, corrMatrixTable);

    % Add Heatmap if available
    if isfield(app, 'heatMapFigure')
        heatMapImage = 'heatmap.png';
        saveas(app.heatMapFigure, heatMapImage);
        heatMapImageDOM = mlreportgen.dom.Image(heatMapImage);
        heatMapImageDOM.Height = '4in';
        heatMapImageDOM.Width = '6in';
        append(pdf, heatMapImageDOM);
    end

    % Add Error Analysis plots if available
    append(pdf, mlreportgen.dom.Paragraph('Error Analysis:'));
    for i = 1:numel(app.ErrorPlots)
        plotFileName = sprintf('plot%d.png', i);
        saveas(app.ErrorPlots(i), plotFileName);
        plotImageDOM = mlreportgen.dom.Image(plotFileName);
        plotImageDOM.Height = '4in';
        plotImageDOM.Width = '6in';
        append(pdf, plotImageDOM);
    end

    % Close the PDF document
    close(pdf);

    % Notify the user that the PDF has been generated
    msgbox(sprintf('PDF report has been created: %s', pdfFileName), 'PDF Generated');
end


% % % case 'Download PDF'
% % %                     % Create a new PDF report
% % %                     pdfFileName = 'MitoModel_Results_Report.pdf';
% % %                     pdf = mlreportgen.dom.Document(pdfFileName, 'pdf');
% % % 
% % %                     % Add a title to the PDF
% % %                     title = mlreportgen.dom.Paragraph('Model Optimization Results');
% % %                     title.Bold = true;
% % %                     title.FontSize = '18pt';
% % %                     append(pdf, title);
% % % 
% % %                     % Add results from the Results tab
% % %                     append(pdf, mlreportgen.dom.Paragraph('Optimized Parameters:'));
% % %                     paramTable = mlreportgen.dom.Table({'Parameter', 'Optimized Value'});
% % %                     for i = 1:size(app.ResultsTable.Data, 1)
% % %                         row = mlreportgen.dom.TableRow({app.ResultsTable.Data{i, 1}, num2str(app.ResultsTable.Data{i, 2})});
% % %                         append(paramTable, row);
% % %                     end
% % %                     append(pdf, paramTable);
% % % 
% % %                     % If MCMC results are present, add them to the PDF
% % %                     if ~isempty(app.mcmcInfoTable.Data)
% % %                         append(pdf, mlreportgen.dom.Paragraph('MCMC Analysis Results:'));
% % %                         mcmcTable = mlreportgen.dom.Table({'Parameter', 'Optimized Value', 'Mean Value', 'Confidence Interval (CI)'});
% % %                         for i = 1:size(app.ResultsTable.Data, 1)
% % %                             row = mlreportgen.dom.TableRow({app.ResultsTable.Data{i, 1}, ...
% % %                                 num2str(app.ResultsTable.Data{i, 2}), ...
% % %                                 num2str(app.ResultsTable.Data{i, 3}), ...
% % %                                 app.ResultsTable.Data{i, 4}});
% % %                             append(mcmcTable, row);
% % %                         end
% % %                         append(pdf, mcmcTable);
% % %                     end
% % % 
% % %                     % If bootstrap confidence intervals are available, add them to the PDF
% % %                     if size(app.ResultsTable.Data, 2) == 5
% % %                         append(pdf, mlreportgen.dom.Paragraph('Bootstrap Confidence Intervals:'));
% % %                         bootstrapTable = mlreportgen.dom.Table({'Parameter', 'Optimized Value', 'Mean Value', 'Confidence Interval (CI)', 'CI by Bootstrap Samples'});
% % %                         for i = 1:size(app.ResultsTable.Data, 1)
% % %                             row = mlreportgen.dom.TableRow({app.ResultsTable.Data{i, 1}, ...
% % %                                 num2str(app.ResultsTable.Data{i, 2}), ...
% % %                                 num2str(app.ResultsTable.Data{i, 3}), ...
% % %                                 app.ResultsTable.Data{i, 4}, ...
% % %                                 app.ResultsTable.Data{i, 5}});
% % %                             append(bootstrapTable, row);
% % %                         end
% % %                         append(pdf, bootstrapTable);
% % %                     end
% % % 
% % %                     % Add the correlation matrix and heatmap to the PDF
% % %                     append(pdf, mlreportgen.dom.Paragraph('Correlation Analysis:'));
% % %                     corrMatrixTable = mlreportgen.dom.Table({'Parameter 1', 'Parameter 2', 'Correlation'});
% % %                     for i = 1:size(app.CorrMatrixTable.Data, 1)
% % %                         row = mlreportgen.dom.TableRow({app.CorrMatrixTable.Data{i, 1}, ...
% % %                             app.CorrMatrixTable.Data{i, 2}, ...
% % %                             num2str(app.CorrMatrixTable.Data{i, 3})});
% % %                         append(corrMatrixTable, row);
% % %                     end
% % %                     append(pdf, corrMatrixTable);
% % % 
% % %                     % If heatmap is present, add it as an image
% % %                     if isfield(app, 'heatMapFigure')
% % %                         heatMapImage = 'heatmap.png';
% % %                         saveas(app.heatMapFigure, heatMapImage);
% % %                         heatMapImageDOM = mlreportgen.dom.Image(heatMapImage);
% % %                         heatMapImageDOM.Height = '4in';
% % %                         heatMapImageDOM.Width = '6in';
% % %                         append(pdf, heatMapImageDOM);
% % %                     end
% % % 
% % %                     % Add plots from the Error Analysis tab
% % %                     append(pdf, mlreportgen.dom.Paragraph('Error Analysis:'));
% % %                     for i = 1:numel(app.ErrorPlots)
% % %                         plotFileName = sprintf('plot%d.png', i);
% % %                         saveas(app.ErrorPlots(i), plotFileName);
% % %                         plotImageDOM = mlreportgen.dom.Image(plotFileName);
% % %                         plotImageDOM.Height = '4in';
% % %                         plotImageDOM.Width = '6in';
% % %                         append(pdf, plotImageDOM);
% % %                     end
% % % 
% % %                     % Close the PDF document
% % %                     close(pdf);
% % % 
% % %                     % Notify the user that the PDF has been generated
% % %                     msgbox(sprintf('PDF report has been created: %s', pdfFileName), 'PDF Generated');
