%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Before running the following scripts, you need to download and setup
% 'mosek' solver for matlab first
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add directory to matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('/proj/g2018024/nobackup/MetabolicModelWorkshop/RAVEN_sysmedicine/'))
savepath /proj/g2018024/nobackup/MetabolicModelWorkshop/RAVEN_sysmedicine/pathdef.m
addpath(genpath('/home/czhang/mosek7/'))
savepath /home/czhang/mosek7/pathdef.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Essentiality analysis for E.coli core model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('e_coli_core')
EScores = ESS(e_coli_core,1,0.01,'g');
EssentialGenes = e_coli_core.genes(EScores == 1);


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

