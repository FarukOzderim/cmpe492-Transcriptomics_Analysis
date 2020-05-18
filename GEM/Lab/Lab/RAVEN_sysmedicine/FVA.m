function [LB,UB] = FVA(model,rxns,ObjSense,printOut)
% [LB,UB] = FVA(model,rxns,ObjSense,printOut)
if nargin<2||isempty(rxns)
    rxns = model.rxns;
end

if nargin<3||isempty(ObjSense)
    ObjSense = 0;
end

if nargin<4||isempty(printOut)
    printOut = false;
end
if sum(logical(model.c))>0
    sol = solveLP(model);
    model.lb(logical(model.c)) = max(0.01*ObjSense*sol.x(logical(model.c)),model.lb(logical(model.c)));
end

nR = length(rxns);
UB = zeros(nR,1);
LB = zeros(nR,1);
[IndA,IndB] = ismember(rxns,model.rxns);
h = waitbar(0,'Performing FVA...');
sol0 = solveLP(model);
for i = 1:nR
    waitbar(i/nR)
    if IndA(i) == 1
        imodel = model;
        imodel.c = zeros(length(imodel.rxns),1);
        imodel.c(IndB(i)) = 1;
%         [x,~] = linprog(imodel.c,[],[],imodel.S,imodel.b,imodel.lb,imodel.ub);
        sol = solveLP(imodel);
        try
            UB(i) = sol.x(logical(imodel.c));
        catch
            UB(i) = sol0.x(logical(imodel.c));
        end
        imodel.c(IndB(i)) = -1;
%         [x,~] = linprog(imodel.c,[],[],imodel.S,imodel.b,imodel.lb,imodel.ub);
        sol = solveLP(imodel);
        try
            LB(i) = sol.x(logical(imodel.c));
        catch
            LB(i) = sol0.x(logical(imodel.c));
        end
        if printOut
            eqn = constructEquations(model,model.rxns(IndB(i)));
            fprintf('%s %s LB:%.8f UB:%.8f\n',model.rxns{IndB(i)},eqn{1},LB(i),UB(i));
        end
    end
end
close(h);
end