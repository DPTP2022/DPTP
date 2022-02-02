function [Algorithm,Problem,Population] = SPEA2(Algorithm,Problem)
% Modififed by ----- ----- for DPTP 2021

% Some of the original code from the PlatEMO version of this function has changed but major
% modifications were required to handle dynamic changes and repsonse mechnaisms.
% The output and input formats and the utilised class structures are
% also very different. We acknowledge the core principle implemented in "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87". The original
% blurb is as below.

% <algorithm> <S>
% Strength Pareto evolutionary algorithm 2

%------------------------------- Reference --------------------------------
% E. Zitzler, M. Laumanns, and L. Thiele, SPEA2: Improving the strength
% Pareto evolutionary algorithm, Proceedings of the Fifth Conference on
% Evolutionary Methods for Design, Optimization and Control with
% Applications to Industrial Problems, 2001, 95-100.
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
    Algorithm=Algorithm.Draw(Population.objs,'Obj',Problem);
    Algorithm=Algorithm.RecordMetrics(Problem,Population);
    
    Fitness    = CalFitness(Population.objs);
    
    %% Optimization
    while Algorithm.CheckTermination==0
        [Problem,Population]=Problem.UpdateTime(Algorithm,Population);
        if Problem.Dynamic_Response_Flag==1
            if Algorithm.Dynamic_Response(1)==3 %Random Restart replaces the entire population
                Population = Problem.initPop(Algorithm.Npop);
                Population.objs=Problem.CalcObj(Population.decs); Population.cons=Problem.CalcCon(Population.decs);
%                 Algorithm.evalConsumed=Algorithm.evalConsumed+size(Population.decs,1);
                rand_insert_inds=[];
            else
                Response_Solutions=Algorithm.Execute_Dynamic_Response(Problem,Population);
                rand_insert_inds=randsample(Algorithm.Npop-2,size(Response_Solutions,1))+1; %First and last are removed from possibilities
                %Offspring.decs(rand_insert_inds,:)=Response_Solutions;
            end
            Problem.Dynamic_Response_Flag=0;
        else
            rand_insert_inds=[];
        end
        
        MatingPool = TournamentSelection(2,Algorithm.Npop,Fitness);
        Offspring  = GA(Population.decs(MatingPool,:),Problem);
        for i=1:length(rand_insert_inds) %Add in the response solutions if there has been a change event
            Offspring.decs(rand_insert_inds,:)=Response_Solutions;
        end
        Offspring.objs=Problem.CalcObj(Offspring.decs); Algorithm.evalConsumed=Algorithm.evalConsumed+size(Offspring.decs,1);
        Offspring.cons=Problem.CalcCon(Offspring.decs); 

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        Population.objs=[Population.objs; Offspring.objs]; 
        Population.decs=[Population.decs; Offspring.decs]; 
        Population.cons=[Population.cons; Offspring.cons]; 
        [Population,Fitness] = EnvironmentalSelection(Population,Algorithm.Npop);
        Algorithm=Algorithm.Draw(Population.objs,'Obj',Problem);
        Algorithm=Algorithm.RecordMetrics(Problem,Population);
    end
end

function Fitness = CalFitness(PopObj)
% Calculate the fitness of each solution

%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    N = size(PopObj,1);

    %% Detect the dominance relation between each two solutions
    Dominate = false(N);
    for i = 1 : N-1
        for j = i+1 : N
            k = any(PopObj(i,:)<PopObj(j,:)) - any(PopObj(i,:)>PopObj(j,:));
            if k == 1
                Dominate(i,j) = true;
            elseif k == -1
                Dominate(j,i) = true;
            end
        end
    end
    
    %% Calculate S(i)
    S = sum(Dominate,2);
    
    %% Calculate R(i)
    R = zeros(1,N);
    for i = 1 : N
        R(i) = sum(S(Dominate(:,i)));
    end
    
    %% Calculate D(i)
    Distance = pdist2(PopObj,PopObj);
    Distance(logical(eye(length(Distance)))) = inf;
    Distance = sort(Distance,2);
    D = 1./(Distance(:,floor(sqrt(N)))+2);
    
    %% Calculate the fitnesses
    Fitness = R + D';
end

function [Population,Fitness] = EnvironmentalSelection(Population,N)
% The environmental selection of SPEA2

%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    %% Calculate the fitness of each solution
    Fitness = CalFitness(Population.objs);

    %% Environmental selection
    Next = Fitness < 1;
    if sum(Next) < N
        [~,Rank] = sort(Fitness);
        Next(Rank(1:N)) = true;
    elseif sum(Next) > N
        Del  = Truncation(Population.objs(Next,:),sum(Next)-N);
        Temp = find(Next);
        Next(Temp(Del)) = false;
    end
    %%% Population for next generation
%     Population = Population(Next);
    Population.objs = Population.objs(Next,:); Population.decs = Population.decs(Next,:); Population.cons = Population.cons(Next,:);
    Fitness    = Fitness(Next);
end

function Del = Truncation(PopObj,K)
% Select part of the solutions by truncation

    %% Truncation
    Distance = pdist2(PopObj,PopObj);
    Distance(logical(eye(length(Distance)))) = inf;
    Del = false(1,size(PopObj,1));
    while sum(Del) < K
        Remain   = find(~Del);
        Temp     = sort(Distance(Remain,Remain),2);
        [~,Rank] = sortrows(Temp);
        Del(Remain(Rank(1))) = true;
    end
end