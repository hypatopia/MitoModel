% function updateOptimizedParameters(app, optimizedParams)
%{
Created by: Marzieh Eini Keleshteri, June 2024
==================================================
Update Optimized Parameters
==================================================
This function updates the app's parameters with the optimized values
obtained from the GA optimization process.

Inputs:
- app: The app object containing the parameters to be updated
- optimizedParams: The array of optimized parameters

Outputs:
- None (the function updates the app's parameters directly)
%}


    % Check the length of optimizedParams to determine the ModelType
    numParams = length(optimizedParams);

    if numParams == 16
        % FullModelGlobal case
        app.params.f0_Vmax = optimizedParams(1);
        app.params.cytctot = optimizedParams(2);
        app.params.f0_Km = optimizedParams(3);
        app.params.fIV_Vmax = optimizedParams(4);
        app.params.fIV_Km = optimizedParams(5);
        app.params.fIV_K = optimizedParams(6);
        app.params.fV_Vmax = optimizedParams(7);
        app.params.fV_K = optimizedParams(8);
        app.params.fV_Km = optimizedParams(9);
        app.params.p_alpha = optimizedParams(10);
        app.params.cytcredProp = optimizedParams(11);

        app.params.cytcox = optimizedParams(2) * optimizedParams(11);
        app.params.cytcred = app.params.cytctot - app.params.cytcox;

        % Additional parameters for FullModelGlobal
        app.params.amp_1 = optimizedParams(12);
        app.params.amp_2 = optimizedParams(13);
        app.params.amp_3 = optimizedParams(14);
        app.params.amp_4 = optimizedParams(15);
        app.params.cyt_c_drop = optimizedParams(16);
    elseif numParams == 11
        % BaselineModel case
        app.params.f0_Vmax = optimizedParams(1);
        app.params.cytctot = optimizedParams(2);
        app.params.f0_Km = optimizedParams(3);
        app.params.fIV_Vmax = optimizedParams(4);
        app.params.fIV_Km = optimizedParams(5);
        app.params.fIV_K = optimizedParams(6);
        app.params.fV_Vmax = optimizedParams(7);
        app.params.fV_K = optimizedParams(8);
        app.params.fV_Km = optimizedParams(9);
        app.params.p_alpha = optimizedParams(10);
        app.params.cytcredProp = optimizedParams(11);

        app.params.cytcox = optimizedParams(2) * optimizedParams(11);
        app.params.cytcred = app.params.cytctot - app.params.cytcox;
    else
        error('Unknown ModelType or incorrect number of parameters.');
    end
% end
