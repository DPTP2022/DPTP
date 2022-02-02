function [Algorithm,Problem,Population] = NSGAII(Algorithm,Problem)
% Modififed by ----- ----- for DPTP 2021

% Some of the original code from the PlatEMO version of this function has changed but major
% modifications were required to handle dynamic changes and repsonse mechnaisms.
% The output and input formats and the utilised class structures are
% also very different. We acknowledge the core principle implemented in "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87". The original
% blurb is as below.




% Nondominated sorting genetic algorithm II

%------------------------------- Reference --------------------------------
% K. Deb, A. Pratap, S. Agarwal, and T. Meyarivan, A fast and elitist
% multiobjective genetic algorithm: NSGA-II, IEEE Transactions on
% Evolutionary Computation, 2002, 6(2): 182-197.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    %% Generate random population
    Population = Problem.initPop(Algorithm.Npop);
    Population.objs=Problem.CalcObj(Population.decs); Population.cons=Problem.CalcCon(Population.decs);
    Algorithm.evalConsumed=Algorithm.evalConsumed+size(Population.decs,1);
    [~,FrontNo,CrowdDis] = EnvironmentalSelection(Population,Algorithm.Npop);
    Algorithm=Algorithm.RecordMetrics(Problem,Population);
    Algorithm=Algorithm.Draw(Population.objs,'Obj',Problem);

    
    %% Optimization
    while Algorithm.CheckTermination==0
        [Problem,Population]=Problem.UpdateTime(Algorithm,Population);
        if Problem.Dynamic_Response_Flag==1
            if Algorithm.Dynamic_Response(1)==3 %Random Restart replaces the entire population
                Population = Problem.initPop(Algorithm.Npop);
                Population.objs=Problem.CalcObj(Population.decs); Population.cons=Problem.CalcCon(Population.decs);
                %Algorithm.evalConsumed=Algorithm.evalConsumed+size(Population.decs,1);
                rand_insert_inds=[];
            else
                Response_Solutions=Algorithm.Execute_Dynamic_Response(Problem,Population); %Random or Mutated solutions are inserted here
                rand_insert_inds=randsample(size(Offspring.decs,1),size(Response_Solutions,1));
                %The Environmental selection and min-min dominance relation limits optimization of concave->convex directions
                  %Toggle ability and show side-by side?
            end
            Problem.Dynamic_Response_Flag=0;
        else
            rand_insert_inds=[];
        end
        
        
        MatingPool = TournamentSelection(2,Algorithm.Npop,FrontNo,-CrowdDis);
        Offspring  = GA(Population.decs(MatingPool,:),Problem);
        for i=1:length(rand_insert_inds) %Add in the response solutions if there has been a change event
            Offspring.decs(rand_insert_inds,:)=Response_Solutions;
        end
        %Calculate objective function values
        Offspring.objs=Problem.CalcObj(Offspring.decs); Algorithm.evalConsumed=Algorithm.evalConsumed+size(Offspring.decs,1);
        Offspring.cons=Problem.CalcCon(Offspring.decs); 

        Population.objs=[Population.objs; Offspring.objs]; 
        Population.decs=[Population.decs; Offspring.decs]; 
        Population.cons=[Population.cons; Offspring.cons]; 
        [Population,FrontNo,CrowdDis] = EnvironmentalSelection(Population,Algorithm.Npop);
        Algorithm=Algorithm.RecordMetrics(Problem,Population);
        Algorithm=Algorithm.Draw(Population.objs,'Obj',Problem);
    end
end

function [Population,FrontNo,CrowdDis] = EnvironmentalSelection(Population,N)
% The environmental selection of NSGA-II

%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    %% Non-dominated sorting
    [FrontNo,MaxFNo] = NDSort(Population.objs,Population.cons,N);
    Next = FrontNo < MaxFNo;
    
    %% Calculate the crowding distance of each solution
    CrowdDis = CrowdingDistance(Population.objs,FrontNo);
    
    %% Select the solutions in the last front based on their crowding distances
    Last     = find(FrontNo==MaxFNo);
    [~,Rank] = sort(CrowdDis(Last),'descend');
    Next(Last(Rank(1:N-sum(Next)))) = true;
    
    %% Population for next generation
    Population.objs = Population.objs(Next,:); Population.decs = Population.decs(Next,:); Population.cons = Population.cons(Next,:); 
%     Population = Population(Next);
    FrontNo    = FrontNo(Next);
    CrowdDis   = CrowdDis(Next);
    
    
    
end

function CrowdDis = CrowdingDistance(PopObj,FrontNo)
% Calculate the crowding distance of each solution front by front

%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    [N,M]    = size(PopObj);
    CrowdDis = zeros(1,N);
    Fronts   = setdiff(unique(FrontNo),inf);
    for f = 1 : length(Fronts)
        Front = find(FrontNo==Fronts(f));
        Fmax  = max(PopObj(Front,:),[],1);
        Fmin  = min(PopObj(Front,:),[],1);
        for i = 1 : M
            [~,Rank] = sortrows(PopObj(Front,i));
            CrowdDis(Front(Rank(1)))   = inf;
            CrowdDis(Front(Rank(end))) = inf;
            for j = 2 : length(Front)-1
                CrowdDis(Front(Rank(j))) = CrowdDis(Front(Rank(j)))+(PopObj(Front(Rank(j+1)),i)-PopObj(Front(Rank(j-1)),i))/(Fmax(i)-Fmin(i));
            end
        end
    end
end