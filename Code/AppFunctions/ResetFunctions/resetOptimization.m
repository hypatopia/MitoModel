function resetOptimization(app)
if app.ModelOptimized
    if strcmp(app.Model.Type, 'Baseline Model')
        % update model parameters
        app.params.f0_Vmax = 153.9776; %bounds: [0.01 10]
        app.params.f0_Km = 0.1012; %bounds: [0.1 1E4]
        app.params.fIV_Vmax = 3.4011; %bounds: [0.01 10]
        app.params.fIV_Km = 0.000101; %bounds: [0.1 1E4]
        app.params.fIV_K = 0.0061; %bounds: [0.1 1E4]
        app.params.fV_Vmax = 163.4067; %bounds: [1 1E4]
        app.params.fV_Km = 0.0012; %bounds: [1E-6 1]
        app.params.fV_K = 0.0357; %bounds: [1 1E4]
        app.params.p_alpha = 0.0068; %bounds: [1E-9 1]


        % Set bounds for the parameters
        app.params.rangeLow = [0.1, 1e2, 0.1, 0.001, 1e-7, 1e-6, 1, 1e-6, 1e-5, 1e-6, 0];
        app.params.rangeUp =  [1000, 7e2, 1000, 10, 1e-3, 0.01, 1e4, 0.01, 1e-1, 0.01, 1];

    else

        % update model parameters
        app.params.f0_Vmax = 41.479; %bounds: [0.01 10]
        app.params.f0_Km = 0.1012; %bounds: [0.1 1E4]
        app.params.fIV_Vmax = 0.75; %bounds: [0.01 10]
        app.params.fIV_Km = 1.46*1e-4; %bounds: [0.1 1E4]
        app.params.fIV_K = 0.023; %bounds: [0.1 1E4]
        app.params.fV_Vmax = 99.22; %bounds: [1 1E4]
        app.params.fV_Km = 3.72*1e-3; %bounds: [1E-6 1]
        app.params.fV_K = 5.6*1e-3; %bounds: [1 1E4]
        app.params.p_alpha = 0.00778; %bounds: [1E-9 1]

        app.params.attenuateProp = 2.12E-6;
        num_alphas = app.params.alphas.num_alphas;

        for i_alpha = 1:num_alphas
        amp_field = sprintf('amp_%d', i_alpha); 
        app.params.alphas.(amp_field) = app.params.alphas.init_vals(i_alpha);
        end

        range_low_alphas = app.params.range_low_alphas;
        range_up_alphas = app.params.range_up_alphas;

        % Set bounds for the parameters
        app.params.rangeLow = [0.1, 1e2, 0.1, 0.001, 1e-7, 1e-6, 1, 1e-6, 1e-5, 1e-6, 0, range_low_alphas, 1e-8];
        app.params.rangeUp =  [1000, 7e2, 1000, 10, 1e-3, 0.01, 1e4, 0.01, 1e-1, 0.01, 1, range_up_alphas, 1e-4];
    end

    % update initial values and relate parameters
    app.params.cytctot = app.TotalCytCEditField.Value;
    app.params.cytcox = app.CytCOxidizedEditField.Value;
    app.params.cytcred = app.params.cytctot - app.params.cytcox ;
    app.params.cytcredProp = app.params.cytcox  / app.params.cytctot;

    app.params.Hn = app.MatrixProtonHsubNsubEditField.Value;
    app.params.Hp = app.IMSProtonHsubPsubEditField.Value;
    app.params.pH = -log10(app.params.Hn *1E-6);

    app.results = struct();
    app.ModelOptimized = false;
    app.ResultsTypeDropDown.Enable = 'off';
end



