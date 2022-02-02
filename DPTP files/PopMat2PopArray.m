 function Population = PopMat2PopArray(Population,inds)
    %DPTP 2021

    %Convert the population to an array of individual structures from
    %matrices.
    
    if nargin < 2
        inds=1:size(Population.objs,1);
    end
    
    
    POParray=struct;
    POParray.objs=Population.objs(inds(1),:);
    POParray.decs=Population.decs(inds(1),:);
    POParray.cons=Population.cons(inds(1),:);
    
    for i=2:length(inds)
        T=struct;
        T.objs=Population.objs(inds(i),:);
        T.decs=Population.decs(inds(i),:);
        T.cons=Population.cons(inds(i),:);
        POParray=cat(1,POParray,T);
    end
 
    Population=POParray;
 
 end