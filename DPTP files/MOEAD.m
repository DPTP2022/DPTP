function [Algorithm,Problem,Population] = MOEAD(Algorithm,Problem)
% Modififed by ----- ----- for DPTP 2021

% Some of the original code from the PlatEMO version of this function has changed but major
% modifications were required to handle dynamic changes and repsonse mechnaisms.
% The output and input formats and the utilised class structures are
% also very different. We acknowledge the core principle implemented in "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87". The original
% blurb is as below.


% Multiobjective evolutionary algorithm based on decomposition
% type --- 1 --- The type of aggregation function

%------------------------------- Reference --------------------------------
% Q. Zhang and H. Li, MOEA/D: A multiobjective evolutionary algorithm based
% on decomposition, IEEE Transactions on Evolutionary Computation, 2007,
% 11(6): 712-731.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    %% Parameter setting
    type = Algorithm.parameters(1);

    %% Generate the weight vectors
    [W,~] = UniformPoint(Algorithm.Npop,Problem.Mobjectives);
    T = ceil(Algorithm.Npop/10);

    %% Detect the neighbours of each solution
    B = pdist2(W,W);
    [~,B] = sort(B,2);
    B = B(:,1:T);
    
    %% Generate random population
    Population = Problem.initPop(Algorithm.Npop);
    Population.objs=Problem.CalcObj(Population.decs); Population.cons=Problem.CalcCon(Population.decs);
    Algorithm.evalConsumed=Algorithm.evalConsumed+size(Population.decs,1);
    Algorithm=Algorithm.Draw(Population.objs,'Obj',Problem);
    Algorithm=Algorithm.RecordMetrics(Problem,Population);
    
    Z = min(Population.objs,[],1); 

    %% Optimization
    while Algorithm.CheckTermination==0
        [Problem,Population]=Problem.UpdateTime(Algorithm,Population);
        if Problem.Dynamic_Response_Flag==1
            if Algorithm.Dynamic_Response(1)==3 %Random Restart replaces the entire population
                Population = Problem.initPop(Algorithm.Npop);
                Population.objs=Problem.CalcObj(Population.decs); Population.cons=Problem.CalcCon(Population.decs);
%                 Algorithm.evalConsumed=Algorithm.evalConsumed+size(Population.decs,1); % These evaluations are 'free' in the current implementation
                rand_insert_inds=[];
            else
                Response_Solutions=Algorithm.Execute_Dynamic_Response(Problem,Population);
                rand_insert_inds=randsample(Algorithm.Npop-2,size(Response_Solutions,1))+1; %First and last are removed from possibilities
            end
            Problem.Dynamic_Response_Flag=0;
        else
            rand_insert_inds=[];
        end
        

        % For each solution 
        for i = 1 : Algorithm.Npop      
            % Choose the parents
            P = B(i,randperm(size(B,2)));

            
            %%%%%% DYNAMIC RESPONSE %%%%%%
            if ismember(i,rand_insert_inds)==1
                %Insert Dynamic response solution
                Offspring=struct; Offspring.decs=Response_Solutions(1,:); Response_Solutions(1,:)=[];
            else
                %Generate an offspring
                Offspring = GAhalf(Population.decs(P(1:2),:),Problem);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            Offspring.objs=Problem.CalcObj(Offspring.decs); Algorithm.evalConsumed=Algorithm.evalConsumed+size(Offspring.decs,1);
            Offspring.cons=Problem.CalcCon(Offspring.decs); 
            % Update the ideal point
            Z = min(Z,Offspring.objs); 

            % Update the neighbours
            switch type
                case 1
                    % PBI approach
                    normW   = sqrt(sum(W(P,:).^2,2));
                    normP   = sqrt(sum((Population.objs(P,:)-repmat(Z,T,1)).^2,2));
                    normO   = sqrt(sum((Offspring.objs-Z).^2,2));
                    CosineP = sum((Population.objs(P,:)-repmat(Z,T,1)).*W(P,:),2)./normW./normP;
                    CosineO = sum(repmat(Offspring.objs-Z,T,1).*W(P,:),2)./normW./normO;
                    g_old   = normP.*CosineP + 5*normP.*sqrt(1-CosineP.^2);
                    g_new   = normO.*CosineO + 5*normO.*sqrt(1-CosineO.^2);
                case 2
                    % Tchebycheff approach
                    g_old = max(abs(Population.objs(P,:)-repmat(Z,T,1)).*W(P,:),[],2);
                    g_new = max(repmat(abs(Offspring.objs-Z),T,1).*W(P,:),[],2);
                case 3
                    % Tchebycheff approach with normalization
                    Zmax  = max(Population.objs,[],1);
                    g_old = max(abs(Population.objs(P,:)-repmat(Z,T,1))./repmat(Zmax-Z,T,1).*W(P,:),[],2);
                    g_new = max(repmat(abs(Offspring.objs-Z)./(Zmax-Z),T,1).*W(P,:),[],2);
                case 4
                    % Modified Tchebycheff approach
                    g_old = max(abs(Population.objs(P,:)-repmat(Z,T,1))./W(P,:),[],2);
                    g_new = max(repmat(abs(Offspring.objs-Z),T,1)./W(P,:),[],2);
            end
            Population.decs(P(g_old>=g_new),:)=repmat(Offspring.decs,length(P(g_old>=g_new)),1);
            Population.objs(P(g_old>=g_new),:)=repmat(Offspring.objs,length(P(g_old>=g_new)),1);
            Population.cons(P(g_old>=g_new),:)=repmat(Offspring.cons,length(P(g_old>=g_new)),1);
        end
        Algorithm=Algorithm.Draw(Population.objs,'Obj',Problem);
        Algorithm=Algorithm.RecordMetrics(Problem,Population);
    end
end