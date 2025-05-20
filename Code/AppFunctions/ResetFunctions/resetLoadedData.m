function resetLoadedData(app)
if app.DataLoaded == true
    % Display a dialog box asking the user for their preference
    choice = questdlg('Would you like to proceed with the existing parameter values and model type or start fresh with the Baseline model and the original parameter values?', ...
        'Load Data Reset', ...
        'Proceed with Existing', 'Start Fresh', 'Proceed with Existing');

    % Handle the user's response
    switch choice
        case 'Proceed with Existing'
            % Do nothing and proceed with existing parameter set
            disp('Proceed with current parameter values.');
            return;

        case 'Start Fresh'
            % Clear parameters, data and results
            app.params = struct();
            app.data = struct();
            app.results = struct();

            % Reset UI elements and properties
            app.DataLoaded = false;
            app.CurrentTimeUnit = 'Second'; % Default to 'Second'
            app.ModelOptimized = false;
            app.EditTableButton.Enable = 'off';
            app.VisualizationTypeDropDown.Enable = 'off';
            app.OptimizationAlgTypeDropDown.Enable = 'off';
            app.ResultsTypeDropDown.Enable = 'off';
            app.ButtonGroupPenalty.Enable = 'off';
            app.UIWeightTable.Enable = 'off';
            % app.FullModelGlobalButton.Enable = 'off';
            app.Model.Type = 'BaselineModel';
            app.Model.PenaltyType = 'Disable Penalty';
            app.Model.Weight = ones(6, 1);
            app.UITable.Data = [];
            app.UIWeightTable.Data = [];
            % app.BaselineModelButton.Value = true;
            app.ButtonGroupModel.SelectedObject = app.BaselineModelButton;
            app.FullModelGlobalButton.Enable = 'off';
            app.UnweightedButton.Enable = 'on';

            app.params.f0_Vmax = 153.9776; %bounds: [0.01 10]
            app.params.f0_Km = 0.1012; %bounds: [0.1 1E4]
            app.params.fIV_Vmax = 3.4011; %bounds: [0.01 10]
            app.params.fIV_Km = 0.000101; %bounds: [0.1 1E4]
            app.params.fIV_K = 0.0061; %bounds: [0.1 1E4]
            app.params.fV_Vmax = 163.4067; %bounds: [1 1E4]
            app.params.fV_Km = 0.0012; %bounds: [1E-6 1]
            app.params.fV_K = 0.0357; %bounds: [1 1E4]
            app.params.p_alpha = 0.0068; %bounds: [1E-9 1]

            app.params = app.parameters;

            app.TotalCytCEditField.Value = app.params.cytctot;
            app.CytCOxidizedEditField.Value = app.params.cytcox;
            app.MatrixProtonHsubNsubEditFieldStatus = app.params.Hn;
            app.IMSProtonHsubPsubEditField.Value = app.params.Hp;

            app.cytctotEditFieldStatus = false;
            app.cytcoxEditFieldStatus = false;
            app.OxygenEditFieldStatus = false;
            app.MatrixProtonHsubNsubEditFieldStatus = false;
            app.cytcoxEditFieldStatus = false;

            app.params.cytcred = app.params.cytctot - app.params.cytcox ;
            app.params.cytcredProp = app.params.cytcox  / app.params.cytctot;

            % Set bounds for the parameters
            app.params.rangeLow = [0.1, 1e2, 0.1, 0.001, 1e-7, 1e-6, 1, 1e-6, 1e-5, 1e-6, 0];
            app.params.rangeUp = [1000, 7e2, 1000, 10, 1e-3, 0.01, 1e4, 0.01, 1e-1, 0.01, 1];

            disp('Starting fresh with the Baseline Model and GUI original initial parameters.');

    end
end
end

