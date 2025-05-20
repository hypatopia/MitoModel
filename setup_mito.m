function parameters = setup_mito
%{
Title: Setup Function for Mitochondrial Model Parameters
Created by: Chris Cadonic
Revised by: Marzieh Eini Keleshteri June 2024
==============================================================
The setup function handles the values for each variable in the
system in a structure known as 'parameters'. parameters contains
all of the model's parameters and also the data, graph labels.
%}

%% Define the Parameters of the Model
% control condition parameter values

parameters.f0_Vmax = 153.9776; %bounds: [0.01 10]
parameters.f0_Km = 0.1012; %bounds: [0.1 1E4]
parameters.fIV_Vmax = 3.4011; %bounds: [0.01 10]
parameters.fIV_Km = 0.000101; %bounds: [0.1 1E4]
parameters.fIV_K = 0.0061; %bounds: [0.1 1E4]
parameters.fV_Vmax = 163.4067; %bounds: [1 1E4]
parameters.fV_Km = 0.0012; %bounds: [1E-6 1]
parameters.fV_K = 0.0357; %bounds: [1 1E4]
parameters.p_alpha = 0.0068; %bounds: [1E-9 1]

% attenuation coefficient used in the initial condition in the inhibit phase of the full model
parameters.attenuateProp = 2.12E-6; 

% multiplier to reduce proportion of cyt c red in inhibit step
parameters.cytcredProp = 0.4;


% Corresponding initial values for each coefficient alpha including max effect of FCCP in each injection
parameters.alphas.init_vals = [10, 0.0912, 0.002, 0.002];

parameters.alphas.range_low = [1e-4, 1e-4,  1e-4, 1e-4];
parameters.alphas.range_up = [1e4, 1e4, 1e4, 1e4];

%define the initial condition fields
parameters.conditionNames = {'cytctot', 'cytcox', 'cytcred', 'oxygen', ...
    'omega', 'rho'};

%% Define Initial Values and Conditions
%initial conditions in nmol/mL; conversion: 1 nmol/mL = 1E-6 mol/L
% omega
parameters.Hn = 0.015848931924611; % pH = 7.8
% rho
parameters.Hp = 0.025118864315096; % pH = 7.6

parameters.cytctot = 250; %bounds: [1E-6 1]
parameters.cytcox = 100; %bounds: [1E-6 1]
parameters.cytcred = parameters.cytctot - parameters.cytcox;

%% Load Additional Functions
% Define subdirectories to add to the path
subdirs = {'AppFunctions', 'OptimizedSolutions', 'Reports', 'ResetFunctions', 'Results', 'ResultsFunctions', 'SystemFunctions'};

% Get the current directory of the script
curdir = fileparts(which(mfilename));

% Add each subdirectory to the path
cellfun(@(subdir) addpath(fullfile(curdir, subdir)), subdirs);

%% Define the labels and titles for GUI Graphs
%titles and labels for the output graphs
[parameters.title{1:5}] = deal(['Cyt c Reduced Concentration Over'...
    ' Time'],'Oxygen Concentration Over Time', ...
    'OCR Over Time', ...
    'Matrix Proton Concentration Over Time',...
    'IMS Proton Concentration Over Time');
[parameters.ylab{1:5}] = deal('Cyt c_{red} (nmol/mL)', ...
    'O_2 (nmol/mL)','OCR (pmol/(mL*sec))','H_N (nmol/mL)', ...
    'H_P (nmol/mL)');
parameters.xlab = 'Time (sec)';

