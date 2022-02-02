function [Algorithm,Problem,Population] = NSGAIII(Algorithm,Problem)
% Modififed by ----- ----- for DPTP 2021

% Some of the original code from the PlatEMO version of this function has changed but major
% modifications were required to handle dynamic changes and repsonse mechnaisms.
% The output and input formats and the utilised class structures are
% also very different. We acknowledge the core principle implemented in "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87". The original
% blurb is as below.


% <algorithm> <N>
% Nondominated sorting genetic algorithm III

%------------------------------- Reference --------------------------------
% K. Deb and H. Jain, An evolutionary many-objective optimization algorithm
% using reference-point based non-dominated sorting approach, part I:
% Solving problems with box constraints, IEEE Transactions on Evolutionary
% Computation, 2014, 18(4): 577-601.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    %% Generate the reference points and random population
    [Z,~] = UniformPoint(Algorithm.Npop,Problem.Mobjectives);
    Population = Problem.initPop(Algorithm.Npop);
    Population.objs=Problem.CalcObj(Population.decs); Population.cons=Problem.CalcCon(Population.decs);
    Algorithm.evalConsumed=Algorithm.evalConsumed+size(Population.decs,1);
    Algorithm=Algorithm.Draw(Population.objs,'Obj',Problem);
    Algorithm=Algorithm.RecordMetrics(Problem,Population);
        
%     Zmin         = min(Population(all(Population.cons<=0,2)).objs,[],1);
    Zmin = min(Population.objs(all(Population.cons<=0,2),:),[],1);
    
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
                Response_Solutions=Algorithm.Execute_Dynamic_Response(Problem,Population); %Random or Mutated solutions are inserted here
                rand_insert_inds=randsample(size(Offspring.decs,1),size(Response_Solutions,1));
                %The Environmental selection and min-min dominance relation limits optimization of concave->convex directions
                  %Toggle ability and show side-by side?
            end
            Problem.Dynamic_Response_Flag=0;
        else
            rand_insert_inds=[];
        end
        
        MatingPool = TournamentSelection(2,Algorithm.Npop,sum(max(0,Population.cons),2));
        Offspring  = GA(Population.decs(MatingPool,:),Problem);
        for i=1:length(rand_insert_inds) %Add in the response solutions if there has been a change event
            Offspring.decs(rand_insert_inds,:)=Response_Solutions;
        end
        Offspring.objs=Problem.CalcObj(Offspring.decs); Algorithm.evalConsumed=Algorithm.evalConsumed+size(Offspring.decs,1);
        Offspring.cons=Problem.CalcCon(Offspring.decs); 
        Zmin       = min([Zmin; Offspring.objs(all(Offspring.cons<=0,2),:)],[],1);
        


        Population.objs=[Population.objs; Offspring.objs]; 
        Population.decs=[Population.decs; Offspring.decs]; 
        Population.cons=[Population.cons; Offspring.cons]; 
        Population = EnvironmentalSelection(Population,Algorithm.Npop,Z,Zmin);
        Algorithm=Algorithm.Draw(Population.objs,'Obj',Problem);
        Algorithm=Algorithm.RecordMetrics(Problem,Population);
    
    end
end

function Population = EnvironmentalSelection(Population,N,Z,Zmin)
% The environmental selection of NSGA-III

%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    if isempty(Zmin)
        Zmin = ones(1,size(Z,2));
    end

    %% Non-dominated sorting
    [FrontNo,MaxFNo] = NDSort(Population.objs,Population.cons,N);
    Next = FrontNo < MaxFNo;
    
    %% Select the solutions in the last front
    Last   = find(FrontNo==MaxFNo);
    Choose = LastSelection(Population.objs(Next,:),Population.objs(Last,:),N-sum(Next),Z,Zmin);
    Next(Last(Choose)) = true;
    % Population for next generation
    Population.objs = Population.objs(Next,:); Population.decs = Population.decs(Next,:); Population.cons = Population.cons(Next,:); 
%     Population = Population(Next);
end

function Choose = LastSelection(PopObj1,PopObj2,K,Z,Zmin)
% Select part of the solutions in the last front

    PopObj = [PopObj1;PopObj2] - repmat(Zmin,size(PopObj1,1)+size(PopObj2,1),1);
    [N,M]  = size(PopObj);
    N1     = size(PopObj1,1);
    N2     = size(PopObj2,1);
    NZ     = size(Z,1);

    %% Normalization
    % Detect the extreme points
    Extreme = zeros(1,M);
    w       = zeros(M)+1e-6+eye(M);
    for i = 1 : M
        [~,Extreme(i)] = min(max(PopObj./repmat(w(i,:),N,1),[],2));
    end
    % Calculate the intercepts of the hyperplane constructed by the extreme
    % points and the axes
    Hyperplane = PopObj(Extreme,:)\ones(M,1);
    a = 1./Hyperplane;
    if any(isnan(a))
        a = max(PopObj,[],1)';
    end
    % Normalization
    PopObj = PopObj./repmat(a',N,1);
    
    %% Associate each solution with one reference point
    % Calculate the distance of each solution to each reference vector
    Cosine   = 1 - pdist2(PopObj,Z,'cosine');
    Distance = repmat(sqrt(sum(PopObj.^2,2)),1,NZ).*sqrt(1-Cosine.^2);
    % Associate each solution with its nearest reference point
    [d,pi] = min(Distance',[],1);

    %% Calculate the number of associated solutions except for the last front of each reference point
    rho = hist(pi(1:N1),1:NZ);
    
    %% Environmental selection
    Choose  = false(1,N2);
    Zchoose = true(1,NZ);
    % Select K solutions one by one
    while sum(Choose) < K
        % Select the least crowded reference point
        Temp = find(Zchoose);
        Jmin = find(rho(Temp)==min(rho(Temp)));
        j    = Temp(Jmin(randi(length(Jmin))));
        I    = find(Choose==0 & pi(N1+1:end)==j);
        % Then select one solution associated with this reference point
        if ~isempty(I)
            if rho(j) == 0
                [~,s] = min(d(N1+I));
            else
                s = randi(length(I));
            end
            Choose(I(s)) = true;
            rho(j) = rho(j) + 1;
        else
            Zchoose(j) = false;
        end
    end
end