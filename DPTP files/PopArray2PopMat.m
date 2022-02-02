 function Population = PopArray2PopMat(Population,inds)
 %DPTP 2021
 
if nargin < 2
    inds=1:length(Population);
end


POPmat=struct;
POPmat.objs=Population(inds(1)).objs;
POPmat.decs=Population(inds(1)).objs;
POPmat.cons=Population(inds(1)).objs;
if isfield(Population(1),'adds')==1
    POPmat.adds=Population(inds(1)).adds;
end


for i= 2:length(inds)
    POPmat.objs=[POPmat.objs; Population(inds(i)).objs];
    POPmat.decs=[POPmat.decs; Population(inds(i)).decs];
    POPmat.cons=[POPmat.cons; Population(inds(i)).cons];
    if isfield(Population(1),'adds')==1
        POPmat.adds=[POPmat.adds; Population(inds(i)).adds];
    end
end

Population=POPmat;


end