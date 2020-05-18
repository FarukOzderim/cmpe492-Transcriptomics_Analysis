function tINITinput = exp2tINITinput(genes,expVec,modelName)
% tINITinput = exp2tINITinput(genes,expVec,modelName)
tINITinput.genes = genes;
tINITinput.tissues = {modelName};
tINITinput.celltypes = {modelName};
tINITinput.levels = {'High','Low','Medium','None'};
tINITinput.types = {'Staining'};
tINITinput.reliabilities = {'Supportive'};
tINITinput.gene2Level = sparse(length(genes),1);
tINITinput.gene2Level(expVec<1) = 4;
tINITinput.gene2Level(expVec>=1&expVec<10) = 2;
tINITinput.gene2Level(expVec>=10&expVec<50) = 3;
tINITinput.gene2Level(expVec>=50) = 1;
tINITinput.gene2Type = sparse(length(genes),1);
tINITinput.gene2Reliability = sparse(length(genes),1);


end