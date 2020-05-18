function model = importExcelModel(fileName,simplify)
% model = importExcelRAVENModel(fileName,simplify)
% import an model in RAVEN excel format
% Match METID in EQUATION
% Cheng Zhang edited, 2018-02-16

if nargin < 2 || isempty(simplify)
    simplify = false;
end

%This is to match the order of the fields to those you get from importing
%from SBML
model=[];
model.id=[];
model.description=[];
model.annotation=[];
%Default bounds if not defined
model.annotation.defaultLB=-1000;
model.annotation.defaultUB=1000;
model.rxns={};
model.mets={};
model.S=[];
model.lb=[];
model.ub=[];
model.rev=[];
model.c=[];
model.b=[];
model.comps={};
model.compNames={};
model.compOutside={};
model.compMiriams={};
model.rxnNames={};
model.rxnComps={}; %Will be double later
model.grRules={};
model.rxnGeneMat=[];
model.subSystems={};
model.eccodes={};
model.rxnMiriams={};
model.rxnNotes={};
model.rxnReferences={};
model.rxnConfidenceScores={};
model.genes={};
model.geneComps={}; %Will be double later
model.geneMiriams={};
model.geneShortNames={};
model.metNames={};
model.metComps=[];
model.inchis={};
model.metFormulas={};
model.metMiriams={};
model.metCharges={}; %Will be double later
model.unconstrained=[];



%% Check if file exist
content = readExcel(fileName);

%% Load MODEL
try
    content = readExcel(fileName,'MODEL');
catch
    disp(['Can not find the work sheet named ' '''' 'MODEL' '''']);
end

titles = content(1,:);
content = content(2:end,:);
eInds = cellfun(@isempty,content);
content(sum(eInds,2)==size(eInds,2),:) = [];
titles = strrep(titles,'MODELNAME','DESCRIPTION');
titles = strrep(titles,'ID','MODELID');

if ismember('#',titles) && any(~cellfun(@isempty,content(:,ismember(titles,'#'))))
    hInd = ~cellfun(@isempty,content(:,ismember(titles,'#')));
    content(hInd,:) = [];
end

if ~ismember('MODELID',titles)
    model.id = 'Unknown1';
elseif sum(cellfun(@isempty,content(:,ismember(titles,'MODELID'))))>1
    warning('Annotation for more than one model presents, and only the first one will be selected!');
    model.id = content{1,ismember(titles,'MODELID')};
else
    model.id = content{:,ismember(titles,'MODELID')};
end

if ~ismember('DESCRIPTION',titles)
    model.description = 'The author is too lazy to leave something here!';
elseif sum(cellfun(@isempty,content(:,ismember(titles,'DESCRIPTION'))))>1
    model.description = content{1,ismember(titles,'DESCRIPTION')};
else
    model.description = content{:,ismember(titles,'DESCRIPTION')};
end

if ismember('DEFAULT LOWER',titles) 
    if sum(cellfun(@isempty,content(:,ismember(titles,'DEFAULT LOWER'))))>1
        model.annotation.defaultLB = str2double(content{1,ismember(titles,'DEFAULT LOWER')});
    else
        model.annotation.defaultLB = str2double(content{:,ismember(titles,'DEFAULT LOWER')});
    end
end

if ismember('DEFAULT UPPER',titles) 
    if sum(cellfun(@isempty,content(:,ismember(titles,'DEFAULT UPPER'))))>1
        model.annotation.defaultUB = str2double(content{1,ismember(titles,'DEFAULT UPPER')});
    else
        model.annotation.defaultUB = str2double(content{:,ismember(titles,'DEFAULT UPPER')});
    end
end

if ismember('CONTACT GIVEN NAME',titles) 
    if sum(cellfun(@isempty,content(:,ismember(titles,'CONTACT GIVEN NAME'))))>1
        model.annotation.givenName = content{1,ismember(titles,'CONTACT GIVEN NAME')};
    else
        model.annotation.givenName = content{:,ismember(titles,'CONTACT GIVEN NAME')};
    end
end

if ismember('CONTACT FAMILY NAME',titles) 
    if sum(cellfun(@isempty,content(:,ismember(titles,'CONTACT FAMILY NAME'))))>1
        model.annotation.familyName = content{1,ismember(titles,'CONTACT FAMILY NAME')};
    else
        model.annotation.familyName = content{:,ismember(titles,'CONTACT FAMILY NAME')};
    end
end

if ismember('CONTACT EMAIL',titles) 
    if sum(cellfun(@isempty,content(:,ismember(titles,'CONTACT EMAIL'))))>1
        model.annotation.email = content{1,ismember(titles,'CONTACT EMAIL')};
    else
        model.annotation.email = content{:,ismember(titles,'CONTACT EMAIL')};
    end
end

if ismember('ORGANIZATION',titles) 
    if sum(cellfun(@isempty,content(:,ismember(titles,'ORGANIZATION'))))>1
        model.annotation.organization = content{1,ismember(titles,'ORGANIZATION')};
    else
        model.annotation.organization = content{:,ismember(titles,'ORGANIZATION')};
    end
end

if ismember('TAXONOMY',titles) 
    if sum(cellfun(@isempty,content(:,ismember(titles,'TAXONOMY'))))>1
        model.annotation.taxonomy = content{1,ismember(titles,'TAXONOMY')};
    else
        model.annotation.taxonomy = content{:,ismember(titles,'TAXONOMY')};
    end
end
%% Load METS
try
    content = readExcel(fileName,'METS');
catch
    error(['Can not find the work sheet named ' '''' 'METS' '''']);
end

titles = content(1,:);
content = content(2:end,:);
eInds = cellfun(@isempty,content);
content(sum(eInds,2)==size(eInds,2),:) = [];
if ismember('ID',titles)
    titles(ismember(titles,'ID')) = {'METID'};
end
if ismember('NAME',titles)
    titles(ismember(titles,'NAME')) = {'METNAME'};
end
% Required Inputs
requiredFields = {'REPLACEMENT ID','COMPARTMENT','METNAME','METID'};

A = ismember(requiredFields,upper(titles));
if any(~A)
    error([strjoin(requiredFields(~A),' and ') ' cannot be found!']);
end

if ismember('#',titles) && any(~cellfun(@isempty,content(:,ismember(titles,'#'))))
    hInd = ~cellfun(@isempty,content(:,ismember(titles,'#')));
    content(hInd,:) = [];
end

if any(cellfun(@isempty,content(:,ismember(titles,'REPLACEMENT ID'))))
    error('Not all replacement IDs are presented in the file!');
else
    model.mets = content(:,ismember(titles,'REPLACEMENT ID'));
end

if any(cellfun(@isempty,content(:,ismember(titles,'METNAME'))))
    error('Not all metabolite names are presented in the file!');
else
    model.metNames = content(:,ismember(titles,'METNAME'));
end

if any(cellfun(@isempty,content(:,ismember(titles,'METID'))))
    error('Not all metabolite IDs are presented in the file!');
else
    metIDs = content(:,ismember(titles,'METID'));
end

if any(cellfun(@isempty,content(:,ismember(titles,'COMPARTMENT'))))
    error('Not all metabolite compartments are presented in the file!');
else
    model.metComps = content(:,ismember(titles,'COMPARTMENT'));
end

% Check duplicated metabolites
[~,ind] = unique(strcat(model.mets,model.metComps));
if length(ind)~=length(model.mets)
    warning('Duplicated metabolites has been found, and only the first unique ones are kept!');
    model.mets = model.mets(ind);
    model.metComps = model.metComps(ind);
    content = content(ind,:);
end

if ~ismember('COMPOSITION',titles)
    model.metFormulas = cell(size(model.mets));
    model.metFormulas(:) = {''};
elseif any(cellfun(@isempty,content(:,ismember(titles,'COMPOSITION'))))
%     warning('Not all metabolite compositions are presented in the file!');
    model.metFormulas = content(:,ismember(titles,'COMPOSITION'));
    model.metFormulas(cellfun(@isempty,content(:,ismember(titles,'COMPOSITION')))) = {''};
else
    model.metFormulas = content(:,ismember(titles,'COMPOSITION'));
end

if ~ismember('UNCONSTRAINED',titles)
    model.unconstrained = zeros(size(model.mets));
    model.check = [];
else
    model.unconstrained = content(:,ismember(titles,'UNCONSTRAINED'));
    model.unconstrained = cellfun(@(x)(isequal(x,true)), model.unconstrained);
end

if ~ismember('MIRIAM',titles)
    model = rmfield(model,'metMiriams');
elseif any(cellfun(@isempty,content(:,ismember(titles,'MIRIAM'))))
    model.metMiriams = content(:,ismember(titles,'MIRIAM'));
    model.metMiriams(cellfun(@isempty,content(:,ismember(titles,'MIRIAM')))) = {''};
else
    model.metMiriams = content(:,ismember(titles,'MIRIAM'));
end

if ~ismember('InChI',titles)
    model = rmfield(model,'inchis');
elseif any(cellfun(@isempty,content(:,ismember(titles,'InChI'))))
    model.inchis = content(:,ismember(titles,'InChI'));
    model.inchis(cellfun(@isempty,content(:,ismember(titles,'InChI')))) = {''};
else
    model.inchis = content(:,ismember(titles,'InChI'));
end

if ~ismember('CHARGE',titles)
    model = rmfield(model,'metCharges');
elseif any(cellfun(@isempty,content(:,ismember(titles,'CHARGE'))))
    model.metCharges = content(:,ismember(titles,'CHARGE'));
    model.metCharges(cellfun(@isempty,content(:,ismember(titles,'CHARGE')))) = {''};
else
    model.metCharges = content(:,ismember(titles,'CHARGE'));
end

model.b = zeros(size(model.mets));


%% Load RXNS
try
    content = readExcel(fileName,'RXNS');
catch
    error(['Can not find the work sheet named ' '''' 'RXNS' '''']);
end

titles = content(1,:);
content = content(2:end,:);
eInds = cellfun(@isempty,content);
content(sum(eInds,2)==size(eInds,2),:) = [];
if ismember('ID',titles)
    titles(ismember(titles,'ID')) = {'RXNID'};
end
if ismember('NAME',titles)
    titles(ismember(titles,'NAME')) = {'RXNNAME'};
end
% Required Inputs
requiredFields = {'RXNID','EQUATION'};

A = ismember(requiredFields,upper(titles));
if any(~A)
    error([strjoin(requiredFields(~A),' and ') ' cannot be found!']);
end

if ismember('#',titles) && any(~cellfun(@isempty,content(:,ismember(titles,'#'))))
    hInd = ~cellfun(@isempty,content(:,ismember(titles,'#')));
    content(hInd,:) = [];
end

if any(cellfun(@isempty,content(:,ismember(titles,'RXNID'))))
    error('Not all reaction IDs are presented in the file!');
else
    model.rxns = content(:,ismember(titles,'RXNID'));
end

if any(cellfun(@isempty,content(:,ismember(titles,'EQUATION'))))
    error('Not all reaction equations are presented in the file!');
end  
% model.metComps = content(:,ismember(titles,'EQUATION'));
model.rev = zeros(size(model.rxns));
equations = content(:,ismember(titles,'EQUATION'));

model.rev(contains(equations,' <=> ')|contains(equations,'<=> ')|contains(equations,' <=>')) = 1;
if any(contains(equations,'<=')&~contains(equations,' <=> ')&~contains(equations,'<=> ')&~contains(equations,' <=>'))
    error('Unexpected reaction equation with a "<=" mark!');
end

model.ub = model.annotation.defaultUB*ones(size(model.rxns));
model.lb = zeros(size(model.rxns));
model.lb(contains(equations,' <=> ')) = model.annotation.defaultLB;
model.c = zeros(size(model.rxns));
equations = strrep(equations,' => ',' <=> ');
model.S = sparse(length(model.mets),length(model.rxns));
for i = 1:length(equations)
	iTemp = equations{i};
    if isequaln(iTemp(1),' ')
        iTemp = iTemp(2:end);
    end
    if isequaln(iTemp(end),' ')
        iTemp = iTemp(1:end-1);
    end
    
    if contains(iTemp,' <=> ')
        iTemp = strsplit(iTemp,' <=> ');
        iLeqn = iTemp{1};
        iLmets = strsplit(iLeqn,' + ');
        for j = 1:length(iLmets)
            jTemp = strsplit(iLmets{j},' ');
            if ismember(strjoin(jTemp(1:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(1:end),' ')),i) = -1;
            elseif ismember(strjoin(jTemp(2:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(2:end),' ')),i) = -str2double(strrep(strrep(jTemp{1},'(',''),')',''));
            elseif ~isempty(jTemp)
                error(['Equation of rxn No.' num2str(i) ' is illegal!']);
            end
        end
        iReqn = iTemp{2};
        iRmets = strsplit(iReqn,' + ');
        for j = 1:length(iRmets)
            jTemp = strsplit(iRmets{j},' ');
            if ismember(strjoin(jTemp(1:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(1:end),' ')),i) = 1;
            elseif ismember(strjoin(jTemp(2:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(2:end),' ')),i) = str2double(strrep(strrep(jTemp{1},'(',''),')',''));
            elseif ~isempty(jTemp)
                error(['Equation of rxn No.' num2str(i) ' is illegal!']);
            end
        end
    elseif contains(iTemp,' <=>')
        iTemp = strsplit(iTemp,' <=>');
        iLeqn = iTemp{1};
        iLmets = strsplit(iLeqn,' + ');
        for j = 1:length(iLmets)
            jTemp = strsplit(iLmets{j},' ');
            if ismember(strjoin(jTemp(1:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(1:end),' ')),i) = -1;
            elseif ismember(strjoin(jTemp(2:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(2:end),' ')),i) = -str2double(strrep(strrep(jTemp{1},'(',''),')',''));
            elseif ~isempty(jTemp)
                error(['Equation of rxn No.' num2str(i) ' is illegal!']);
            end
        end
    elseif contains(iTemp,'<=> ')
        iTemp = strsplit(iTemp,'<=> ');
        iReqn = iTemp{2};
        iRmets = strsplit(iReqn,' + ');
        for j = 1:length(iRmets)
            jTemp = strsplit(iRmets{j},' ');
            if ismember(strjoin(jTemp(1:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(1:end),' ')),i) = 1;
            elseif ismember(strjoin(jTemp(2:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(2:end),' ')),i) = str2double(strrep(strrep(jTemp{1},'(',''),')',''));
            elseif ~isempty(jTemp)
                error(['Equation of rxn No.' num2str(i) ' is illegal!']);
            end
        end
    elseif contains(iTemp,' =>')
        iTemp = strsplit(iTemp,' =>');
        iLeqn = iTemp{1};
        iLmets = strsplit(iLeqn,' + ');
        for j = 1:length(iLmets)
            jTemp = strsplit(iLmets{j},' ');
            if ismember(strjoin(jTemp(1:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(1:end),' ')),i) = -1;
            elseif ismember(strjoin(jTemp(2:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(2:end),' ')),i) = -str2double(strrep(strrep(jTemp{1},'(',''),')',''));
            elseif ~isempty(jTemp)
                error(['Equation of rxn No.' num2str(i) ' is illegal!']);
            end
        end
	elseif contains(iTemp,'=> ')
        iTemp = strsplit(iTemp,'=> ');
        iReqn = iTemp{2};
        iRmets = strsplit(iReqn,' + ');
        for j = 1:length(iRmets)
            jTemp = strsplit(iRmets{j},' ');
            if ismember(strjoin(jTemp(1:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(1:end),' ')),i) = 1;
            elseif ismember(strjoin(jTemp(2:end),' '),metIDs)
                model.S(ismember(metIDs,strjoin(jTemp(2:end),' ')),i) = str2double(strrep(strrep(jTemp{1},'(',''),')',''));
            elseif ~isempty(jTemp)
                error(['Equation of rxn No.' num2str(i) ' is illegal!']);
            end
        end
    else
        error(['Equation of rxn No.' num2str(i) ' is illegal!']);
    end
end

if ismember('UPPER BOUND',titles)
    temp = content(:,ismember(titles,'UPPER BOUND'));
    Ind = ~cellfun(@isempty,temp);
    model.ub(Ind) = str2double(temp(Ind));
end

if ismember('LOWER BOUND',titles)
    temp = content(:,ismember(titles,'LOWER BOUND'));
    Ind = ~cellfun(@isempty,temp);
    model.lb(Ind) = str2double(temp(Ind));
end

if ismember('OBJECTIVE',titles)
    temp = content(:,ismember(titles,'OBJECTIVE'));
    Ind = ~cellfun(@isempty,temp);
    model.c(Ind) = str2double(temp(Ind));
end

if ~ismember('RXNNAME',titles)
    model.rxnNames = cell(size(model.rxns));
    model.rxnNames(:) = {''};
elseif any(cellfun(@isempty,content(:,ismember(titles,'RXNNAME'))))
    model.rxnNames = content(:,ismember(titles,'RXNNAME'));
    model.rxnNames(cellfun(@isempty,content(:,ismember(titles,'RXNNAME')))) = {''};
else
    model.rxnNames = content(:,ismember(titles,'RXNNAME'));
end

if ~ismember('MIRIAM',titles)
    model = rmfield(model,'rxnMiriams');
elseif any(cellfun(@isempty,content(:,ismember(titles,'MIRIAM'))))
    model.rxnMiriams = content(:,ismember(titles,'MIRIAM'));
    model.rxnMiriams(cellfun(@isempty,content(:,ismember(titles,'MIRIAM')))) = {''};
else
    model.rxnMiriams = content(:,ismember(titles,'MIRIAM'));
end

if ~ismember('REFERENCES',titles)
    model = rmfield(model,'rxnReferences');
elseif any(cellfun(@isempty,content(:,ismember(titles,'REFERENCES'))))
    model.rxnReferences = content(:,ismember(titles,'REFERENCES'));
    model.rxnReferences(cellfun(@isempty,content(:,ismember(titles,'REFERENCES')))) = {''};
else
    model.rxnReferences = content(:,ismember(titles,'REFERENCES'));
end

if ~ismember('NOTES',titles)
    model = rmfield(model,'rxnNotes');
elseif any(cellfun(@isempty,content(:,ismember(titles,'NOTES'))))
    model.rxnNotes = content(:,ismember(titles,'NOTES'));
    model.rxnNotes(cellfun(@isempty,content(:,ismember(titles,'NOTES')))) = {''};
else
    model.rxnNotes = content(:,ismember(titles,'NOTES'));
end

if ~ismember('EC-NUMBER',titles)
    model = rmfield(model,'eccodes');
elseif any(cellfun(@isempty,content(:,ismember(titles,'EC-NUMBER'))))
    model.eccodes = content(:,ismember(titles,'EC-NUMBER'));
    model.eccodes(cellfun(@isempty,content(:,ismember(titles,'EC-NUMBER')))) = {''};
else
    model.eccodes = content(:,ismember(titles,'EC-NUMBER'));
end

if ~ismember('GENE ASSOCIATION',titles)
    model.grRules = cell(size(model.rxns));
    model.grRules(:) = {''};
elseif any(cellfun(@isempty,content(:,ismember(titles,'GENE ASSOCIATION'))))
    model.grRules = content(:,ismember(titles,'GENE ASSOCIATION'));
    model.grRules(cellfun(@isempty,content(:,ismember(titles,'GENE ASSOCIATION')))) = {''};
    model.grRules = strrep(model.grRules,';',' or ');
    if any(contains(model.grRules,':'))
        model.grRules = strrep(model.grRules,':',' and ');
        disp('The : mark is treated as and, but I am not sure if it is true. Please let me know if you find a model with : in grRules. Thank you!');
    end
    model.grRules(contains(model.grRules,'and')|contains(model.grRules,'or')) = strcat('(',model.grRules(contains(model.grRules,'and')|contains(model.grRules,'or')),')');
else
    model.grRules = content(:,ismember(titles,'GENE ASSOCIATION'));
    model.grRules = strrep(model.grRules,';',' or ');
    if any(contains(model.grRules,':'))
        model.grRules = strrep(model.grRules,':',' and ');
        disp('The : mark is treated as and, but I am not sure if it is true. Please let me know if you find a model with : in grRules. Thank you!');
    end
    model.grRules(contains(model.grRules,'and')|contains(model.grRules,'or')) = strcat('(',model.grRules(contains(model.grRules,'and')|contains(model.grRules,'or')),')');
end

if ~ismember('COMPARTMENT',titles)
    model = rmfield(model,'rxnComps');
elseif any(cellfun(@isempty,content(:,ismember(titles,'COMPARTMENT'))))
    model.rxnComps = content(:,ismember(titles,'COMPARTMENT'));
    model.rxnComps(cellfun(@isempty,content(:,ismember(titles,'COMPARTMENT')))) = {''};
else
    model.rxnComps = content(:,ismember(titles,'COMPARTMENT'));
end

if ~ismember('CONFIDENCE SCORE',titles)
    model = rmfield(model,'rxnConfidenceScores');
elseif any(cellfun(@isempty,content(:,ismember(titles,'CONFIDENCE SCORE'))))
    model.rxnConfidenceScores = content(:,ismember(titles,'CONFIDENCE SCORE'));
    model.rxnConfidenceScores(cellfun(@isempty,content(:,ismember(titles,'CONFIDENCE SCORE')))) = {''};
else
    model.rxnConfidenceScores = content(:,ismember(titles,'CONFIDENCE SCORE'));
end

if ~ismember('SUBSYSTEM',titles)
    model = rmfield(model,'subSystems');
elseif any(cellfun(@isempty,content(:,ismember(titles,'SUBSYSTEM'))))
    model.subSystems = content(:,ismember(titles,'SUBSYSTEM'));
    model.subSystems(cellfun(@isempty,content(:,ismember(titles,'SUBSYSTEM')))) = {''};
else
    model.subSystems = content(:,ismember(titles,'SUBSYSTEM'));
end

%% Load GENES
try
    content = readExcel(fileName,'GENES');
catch
    error(['Can not find the work sheet named ' '''' 'GENES' '''']);
end

titles = content(1,:);
content = content(2:end,:);
eInds = cellfun(@isempty,content);
content(sum(eInds,2)==size(eInds,2),:) = [];
if ismember('NAME',titles)
    titles(ismember(titles,'NAME')) = {'GENE NAME'};
end

% Required Inputs
requiredFields = {'GENE NAME'};

A = ismember(requiredFields,upper(titles));
if any(~A)
    error([strjoin(requiredFields(~A),' and ') ' cannot be found!']);
end

if ismember('#',titles) && any(~cellfun(@isempty,content(:,ismember(titles,'#'))))
    hInd = ~cellfun(@isempty,content(:,ismember(titles,'#')));
    content(hInd,:) = [];
end

if any(cellfun(@isempty,content(:,ismember(titles,'GENE NAME'))))
    error('Not all genes are presented in the file!');
else
    model.genes = content(:,ismember(titles,'GENE NAME'));
end

if ~ismember('SHORT NAME',titles)
    model = rmfield(model,'geneShortNames');
elseif any(cellfun(@isempty,content(:,ismember(titles,'SHORT NAME'))))
    model.geneShortNames = content(:,ismember(titles,'SHORT NAME'));
    model.geneShortNames(cellfun(@isempty,content(:,ismember(titles,'SHORT NAME')))) = {''};
else
    model.geneShortNames = content(:,ismember(titles,'SHORT NAME'));
end

if ~ismember('COMPARTMENT',titles)
    model = rmfield(model,'geneComps');
elseif any(cellfun(@isempty,content(:,ismember(titles,'COMPARTMENT'))))
    model.geneComps = content(:,ismember(titles,'COMPARTMENT'));
    model.geneComps(cellfun(@isempty,content(:,ismember(titles,'COMPARTMENT')))) = {''};
else
    model.geneComps = content(:,ismember(titles,'COMPARTMENT'));
end

if ~ismember('MIRIAM',titles)
    model = rmfield(model,'geneMiriams');
elseif any(cellfun(@isempty,content(:,ismember(titles,'MIRIAM'))))
    model.geneMiriams = content(:,ismember(titles,'MIRIAM'));
    model.geneMiriams(cellfun(@isempty,content(:,ismember(titles,'MIRIAM')))) = {''};
else
    model.geneMiriams = content(:,ismember(titles,'MIRIAM'));
end

model.rxnGeneMat = sparse(length(model.rxns),length(model.genes));
for i = 1:length(model.genes)
    model.rxnGeneMat(:,i) = contains(model.grRules,model.genes{i});
end

%% Load COMPS
try
    content = readExcel(fileName,'COMPS');
catch
    error(['Can not find the work sheet named ' '''' 'COMPS' '''']);
end

titles = content(1,:);
content = content(2:end,:);
eInds = cellfun(@isempty,content);
content(sum(eInds,2)==size(eInds,2),:) = [];
if ismember('NAME',titles)
    titles(ismember(titles,'NAME')) = {'COMPNAME'};
end
if ismember('ABBREV',titles)||ismember('ABBREVIATION',titles)
    titles(ismember(titles,'ABBREV')|ismember(titles,'ABBREVIATION')) = {'COMPABBREV'};
end
if ismember('GO TERM',titles)
    titles(ismember(titles,'GO TERM')) = {'MIRIAM'};
end

% Required Inputs
requiredFields = {'COMPABBREV','COMPNAME','INSIDE'};

A = ismember(requiredFields,upper(titles));
if any(~A)
    error([strjoin(requiredFields(~A),' and ') ' cannot be found!']);
end

if ismember('#',titles) && any(~cellfun(@isempty,content(:,ismember(titles,'#'))))
    hInd = ~cellfun(@isempty,content(:,ismember(titles,'#')));
    content(hInd,:) = [];
end

if any(cellfun(@isempty,content(:,ismember(titles,'COMPABBREV'))))
    error('Not all compartment abbrevations are presented in the file!');
else
    model.comps = content(:,ismember(titles,'COMPABBREV'));
    [~,model.metComps] = ismember(model.metComps,model.comps);
    [~,model.rxnComps] = ismember(model.rxnComps,model.comps);
    [~,model.geneComps] = ismember(model.geneComps,model.comps);
end

if ismember('COMPNAME',titles) 
    if any(cellfun(@isempty,content(:,ismember(titles,'COMPNAME'))))
        error('Not all compartment names are presented in the file!');
    else
        model.compNames = content(:,ismember(titles,'COMPNAME'));
    end
else
    model.geneMiriams(:) = model.comps;
end


if ismember('INSIDE',titles)
    model.compOutside = content(:,ismember(titles,'INSIDE'));
else
    model.compOutside(:) = {''};
end

if ~ismember('MIRIAM',titles)
    model = rmfield(model,'compMiriams');
elseif any(cellfun(@isempty,content(:,ismember(titles,'MIRIAM'))))
%     warning('Not all metabolite charges are presented in the file!');
    model.compMiriams = content(:,ismember(titles,'MIRIAM'));
    model.compMiriams(cellfun(@isempty,content(:,ismember(titles,'MIRIAM')))) = {''};
else
    model.compMiriams = content(:,ismember(titles,'MIRIAM'));
end

%% Check unused
rmIndR = sum(logical(model.S),1) == 0;
rmIndM = sum(logical(model.S),2) == 0;
rmIndG = sum(logical(model.rxnGeneMat),1) == 0;
model.rxns(rmIndR) = [];
model.mets(rmIndM) = [];
model.S(rmIndM,:) = [];
model.S(:,rmIndR) = [];
model.lb(rmIndR) = [];
model.ub(rmIndR) = [];
model.rev(rmIndR) = [];
model.c(rmIndR) = [];
model.b(rmIndM) = [];
if isfield(model,'rxnNames')
    model.rxnNames(rmIndR) = [];
end
if isfield(model,'rxnComps')
    model.rxnComps(rmIndR) = [];
end
model.grRules(rmIndR) = [];
model.rxnGeneMat(:,rmIndG) = [];
model.subSystems(rmIndR) = [];
model.eccodes(rmIndR) = [];
if isfield(model,'rxnMiriams')
    model.rxnMiriams(rmIndR) = [];
end
if isfield(model,'rxnNotes')
    model.rxnNotes(rmIndR) = [];
end
if isfield(model,'rxnReferences')
    model.rxnReferences(rmIndR) = [];
end
if isfield(model,'rxnConfidenceScores')
    model.rxnConfidenceScores(rmIndR) = [];
end
model.genes(rmIndG) = [];
if isfield(model,'geneComps')
    model.geneComps(rmIndG) = [];
end
if isfield(model,'geneMiriams')
    model.geneMiriams(rmIndG) = [];
end
if isfield(model,'geneShortNames')
    model.geneShortNames(rmIndG) = [];
end
model.metNames(rmIndM) = [];
model.metComps(rmIndM) = [];
if isfield(model,'inchis')
    model.inchis(rmIndM) = [];
end
model.metFormulas(rmIndM) = [];
if isfield(model,'metMiriams')
    model.metMiriams(rmIndM) = [];
end
if isfield(model,'metCharges')
    model.metCharges(rmIndM) = [];
end
model.unconstrained(rmIndM) = [];
if isfield(model,'check')
    model.unconstrained = sum(logical(model.S),1)==1;
    model = rmfield(model,'check');
end

%% Simplify model by removing unconstrained mets
if simplify
    ind = logical(model.unconstrained);
    model.mets(ind) = [];
    model.S(ind,:) = [];
    model.b(ind) = [];
    model.metNames(ind) = [];
    model.metComps(ind) = [];
    model.metFormulas(ind) = [];
    model.inchis(ind) = [];
    model.metMiriams(ind) = [];
    if isfield(model,'metCharges')
        model.metCharges(ind) = [];
    end
    model = rmfield(model,'unconstrained');
end

end

function content = readExcel(fileName,sheetName)
% content = readExcel(fileName,sheetName)
% sheetName is set as the first one by default unless otherwise specified
% Cheng Zhang edited, 2018-02-16
if nargin < 2 || isempty(sheetName)
    [~,~,content] = xlsread(fileName);
else
    [~,~,content] = xlsread(fileName,sheetName);
end

% content{cellfun(@isnumeric,content)} == [NaN];

ind = find(cellfun(@isnumeric,content));
for i = 1:length(ind)
    if isnan(content{ind(i)})
        content{ind(i)} = '';
    else
        content{ind(i)} = num2str(content{ind(i)});
    end
end


end
