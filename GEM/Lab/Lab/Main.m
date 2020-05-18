%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Before running the following scripts, you need to download and setup
% 'mosek' solver for matlab first
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add directory to matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('RAVEN_sysmedicine/'))
savepath RAVEN_sysmedicine/pathdef.m
addpath(genpath('/mosek/'))
savepath /mosek/pathdef.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reconstruct HepG2 model using tINIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read gene expression from text file and convert it into tINIT format
content = readTXT('HepG2_exp.txt');
genes = content(2:end,1);
expression = str2double(content(2:end,2));
modelName = 'HepG2';
tINITinput = exp2tINITinput(genes,expression,modelName);

% Load reference model for human
refModel = importExcelModel('iCancer_Core.xlsx',false);

% Load predefined metabolic tasks for tINIT
tasksLC = parseTaskList('common_tasks_growth_RPMI1640.xlsx');

% Set parameters for solver
params.MSK_DPAR_OPTIMIZER_MAX_TIME = 30000; % added for Mosek 7
params.MSK_DPAR_MIO_TOL_REL_GAP    = 0.02;  % added for Mosek 7

% Start reconstruction of model
model = getINITModel(refModel, 'HepG2', 'HepG2', tINITinput, [],[], [],[], true,tasksLC,params,[]); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Model based simulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load premade HepG2 model
load('HepG2')

model = simplifyModel(model);
model.b = model.b(:,1); % Standardize RAVEN model
model = setParam(model,'obj','HCC_biomass',1); % Set objective function to be growth
biomassEqn = constructEquations(model,'HCC_biomass'); % Retrieve biomass equation from model

sol = solveLP(model); % FBA
printFluxes(model,sol.x,true,10^-5,[],'%rxnID (%eqn):%flux\n'); %true is only for input and output
sol = solveLP(model,1); % pFBA
printFluxes(model,sol.x,true,10^-5,[],'%rxnID (%eqn):%flux\n'); %true is only for input and output

EScores_1 = ESS(model,1,0.01,'g');
EssentialGenes_1 = model.genes(EScores_1 == 1);

% Load constraints for RPMI-1640
[NUM,STR] = xlsread('RPMI-1640 Media Formulation Model Input.xlsx');
cRxns = STR(2:end,1); 
cLB = NUM(:,1);
cUB = NUM(:,2);
excRxn = getExchangeRxns(model,'in');
model = setParam(model,'ub',excRxn,0);
model = setParam(model,'lb',cRxns,cLB);
model = setParam(model,'ub',cRxns,cUB);

sol = solveLP(model); % FBA
printFluxes(model,sol.x,true,10^-5,[],'%rxnID (%eqn):%flux\n'); %true is only for input and output
sol = solveLP(model,1); % pFBA
printFluxes(model,sol.x,true,10^-5,[],'%rxnID (%eqn):%flux\n'); %true is only for input and output

EScores_2 = ESS(model,1,0.01,'g');
EssentialGenes_2 = model.genes(EScores_2 == 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Integrate transcriptomic data into model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load premade HepG2 model
load('HepG2')
model = simplifyModel(model);
model.b = model.b(:,1); % Standardize RAVEN model
model = setParam(model,'obj','HCC_biomass',1); % Set objective function to be growth
[NUM,STR] = xlsread('RPMI-1640 Media Formulation Model Input.xlsx');
cRxns = STR(2:end,1); 
cLB = NUM(:,1);
cUB = NUM(:,2);
excRxn = getExchangeRxns(model,'in');
model = setParam(model,'ub',excRxn,0);
model = setParam(model,'lb',cRxns,cLB);
model = setParam(model,'ub',cRxns,cUB);



% Load transcriptomics data
[NUM,STR] = xlsread('PKLR_inhibition_tpm.xlsx');
genes = STR(3:end-1,1);
GXD_ref = mean(NUM(:,1:3),2);
GXD_dif = mean(NUM(:,4:6),2);

% Scale rxns
scale_rxn = 'HCC_biomass'; % Set scale reaction for E-Flux
scale_value_1 = 1.2; % Set scale value 1
scale_value_2 = 1.2*0.85; % Set scale value 2

% Run E-Flux
v1 = call_EFlux(model, genes, GXD_ref, scale_rxn, scale_value_1);
v2 = call_EFlux(model, genes, GXD_dif, scale_rxn, scale_value_2);
printFluxes(model,v1,true,10^-5,[],'%rxnID (%eqn):%flux\n'); %true is only for input and output
printFluxes(model,v2,true,10^-5,[],'%rxnID (%eqn):%flux\n'); %true is only for input and output


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run reporter metabolite analysis with DE genes from PKLR inhibition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load premade HepG2 model
load('HepG2')

% Load differential expression results
content = readTXT('PKLR_inhibition.txt');
genes = content(2:end,1);
lgFC = str2double(content(2:end,3));
pvalues = str2double(content(2:end,6));

% Run reporter metabolite analysis
outFileName = 'reporterMetabolites_Cheng.txt';
repMets = reporterMets(model,genes,pvalues,true,outFileName,lgFC);

