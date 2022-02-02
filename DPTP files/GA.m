function Offspring = GA(Parent,Problem,Parameter)
% Modififed by ----- ----- for DPTP 2021

% Some of the original code from the PlatEMO version has changed but major
% modifications were required to handle decision variable slicing with
% different ranges. The output and input formats for the population are
% also different. We acknowledge the core principle implemented in "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87". The original
% blurb is as below.


%GA - Genetic operators for real, binary, and permutation based encodings.
%
%   Off = GA(P) returns the offsprings generated by genetic operators,
%   where P1 is a set of parents. If P is an array of INDIVIDUAL objects,
%   then Off is also an array of INDIVIDUAL objects; while if P is a matrix
%   of decision variables, then Off is also a matrix of decision variables,
%   i.e., the offsprings will not be evaluated. P is split into two subsets
%   P1 and P2 with the same size, and each object/row of P1 and P2 is used
%   to generate TWO offsprings. Different operators are used for real,
%   binary, and permutation based encodings, respectively.
%
%   Off = GA(P,{proC,disC,proM,disM}) specifies the parameters of
%   operators, where proC is the probabilities of doing crossover, disC is
%   the distribution index of simulated binary crossover, proM is the
%   expectation of number of bits doing mutation, and disM is the
%   distribution index of polynomial mutation.
%
%   Example:
%       Off = GA(Parent)
%       Off = GA(Parent.decs,{1,20,1,20})
%
%   See also GAhalf

%------------------------------- Reference --------------------------------
% [1] K. Deb, K. Sindhya, and T. Okabe, Self-adaptive simulated binary
% crossover for real-parameter optimization, Proceedings of the 9th Annual
% Conference on Genetic and Evolutionary Computation, 2007, 1187-1194.
% [2] K. Deb and M. Goyal, A combined genetic adaptive search (GeneAS) for
% engineering design, Computer Science and informatics, 1996, 26: 30-45.
% [3] L. Davis, Applying adaptive algorithms to epistatic domains,
% Proceedings of the International Joint Conference on Artificial
% Intelligence, 1985, 162-164.
% [4] D. B. Fogel, An evolutionary approach to the traveling salesman
% problem, Biological Cybernetics, 1988, 60(2): 139-144.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    %% Parameter setting
    if nargin > 2
        [proC,disC,proM,disM] = deal(Parameter{:});
    else
        [proC,disC,proM,disM] = deal(1,20,1,20);
    end
%     if isa(Parent(1),'INDIVIDUAL')
%         calObj = true;
%         Parent = Parent.decs;
%     else
%         calObj = false;
%     end
%     Parent = Parent.decs; calObj = false;
    Parent1 = Parent(1:floor(end/2),:);                   %OLD
    Parent2 = Parent(floor(end/2)+1:floor(end/2)*2,:);    %OLD
    [N,D]   = size(Parent1);                              %OLD
%     Global  = GLOBAL.GetObj();                            %OLD
 
% Parent1=Parent; Parent1.objs=Parent1.objs(1:floor(end/2),:); Parent1.decs=Parent1.decs(1:floor(end/2),:); Parent1.cons=Parent1.cons(1:floor(end/2),:); 
% Parent2=Parent; Parent2.objs=Parent2.objs(floor(end/2)+1:floor(end/2)*2,:); Parent2.decs=Parent2.decs(floor(end/2)+1:floor(end/2)*2,:); Parent2.cons=Parent2.cons(floor(end/2)+1:floor(end/2)*2,:); 
% [N,D]   = size(Parent1.objs);  

    switch Problem.encoding
        case 'binary'
            %% Genetic operators for binary encoding
            % One point crossover
            k = repmat(1:D,N,1) > repmat(randi(D,N,1),1,D);
            k(repmat(rand(N,1)>proC,1,D)) = false;
            Offspring1    = Parent1;
            Offspring2    = Parent2;
            Offspring1(k) = Parent2(k);
            Offspring2(k) = Parent1(k);
            Offspring     = [Offspring1;Offspring2];
            % Bitwise mutation
            Site = rand(2*N,D) < proM/D;
            Offspring(Site) = ~Offspring(Site);
        case 'permutation'
            %% Genetic operators for permutation based encoding
            % Order crossover
            Offspring = [Parent1;Parent2];
            k = randi(D,1,2*N);
            for i = 1 : N
                Offspring(i,k(i)+1:end)   = setdiff(Parent2(i,:),Parent1(i,1:k(i)),'stable');
                Offspring(i+N,k(i)+1:end) = setdiff(Parent1(i,:),Parent2(i,1:k(i)),'stable');
            end
            % Slight mutation
            k = randi(D,1,2*N);
            s = randi(D,1,2*N);
            for i = 1 : 2*N
                if s(i) < k(i)
                    Offspring(i,:) = Offspring(i,[1:s(i)-1,k(i),s(i):k(i)-1,k(i)+1:end]);
                elseif s(i) > k(i)
                    Offspring(i,:) = Offspring(i,[1:k(i)-1,k(i)+1:s(i)-1,k(i),s(i):end]);
                end
            end
        otherwise
            %% Genetic operators for real encoding
            % Simulated binary crossover
            beta = zeros(N,D);
            mu   = rand(N,D);
            beta(mu<=0.5) = (2*mu(mu<=0.5)).^(1/(disC+1));
            beta(mu>0.5)  = (2-2*mu(mu>0.5)).^(-1/(disC+1));
            beta = beta.*(-1).^randi([0,1],N,D);
            beta(rand(N,D)<0.5) = 1;
            beta(repmat(rand(N,1)>proC,1,D)) = 1;
            Offspring = [(Parent1+Parent2)/2+beta.*(Parent1-Parent2)/2
                         (Parent1+Parent2)/2-beta.*(Parent1-Parent2)/2];
            
            if isprop(Problem,'DecVarsSplit')==1
                tempOffspring=[];
                for i=1:length(Problem.DecVarsSplit)
                    OffspringSlice=Offspring(:,(Problem.DecVarsSplit(max([1 i-1]))+(i-1)):(Problem.DecVarsSplit(max([1 i-1]))+(i-1)+(Problem.DecVarsSplit(i)-1)));
                    % Polynomial mutation
                    Lower = repmat(Problem.lowerDecBound(i),2*N,Problem.DecVarsSplit(i));
                    Upper = repmat(Problem.upperDecBound(i),2*N,Problem.DecVarsSplit(i));
                    Site  = rand(2*N,Problem.DecVarsSplit(i)) < proM/D;
                    mu    = rand(2*N,Problem.DecVarsSplit(i));
                    temp  = Site & mu<=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    OffspringSlice       = min(max(OffspringSlice,Lower),Upper);
                    OffspringSlice(temp) = OffspringSlice(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                                      (1-(OffspringSlice(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
                    temp = Site & mu>0.5; 
                    OffspringSlice(temp) = OffspringSlice(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
                                      (1-(Upper(temp)-OffspringSlice(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    %Correct for mutation outside the decision variable boundaries:
                    OffspringSlice(OffspringSlice>Problem.upperDecBound(i))=OffspringSlice(OffspringSlice>Problem.upperDecBound(i))-((OffspringSlice(OffspringSlice>Problem.upperDecBound(i))-Problem.upperDecBound(i))*2);
                    OffspringSlice(OffspringSlice<Problem.lowerDecBound(i))=OffspringSlice(OffspringSlice<Problem.lowerDecBound(i))+((abs(OffspringSlice(OffspringSlice<Problem.lowerDecBound(i)))-Problem.lowerDecBound(i))*2);

                    
                    tempOffspring=[tempOffspring OffspringSlice];
                end
                Offspring=tempOffspring;
            else
                % Polynomial mutation
                Lower = repmat(Problem.lowerDecBound,2*N,D);
                Upper = repmat(Problem.upperDecBound,2*N,D);
                Site  = rand(2*N,D) < proM/D;
                mu    = rand(2*N,D);
                temp  = Site & mu<=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Offspring       = min(max(Offspring,Lower),Upper);
                Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                                  (1-(Offspring(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
                temp = Site & mu>0.5; 
                Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
                                  (1-(Upper(temp)-Offspring(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Correct for mutation outside the decision variable boundaries:
                Offspring(Offspring>Problem.upperDecBound)=Offspring(Offspring>Problem.upperDecBound)-((Offspring(Offspring>Problem.upperDecBound)-Problem.upperDecBound)*2);
                Offspring(Offspring>Problem.lowerDecBound)=Offspring(Offspring<Problem.lowerDecBound)+((abs(Offspring(Offspring<Problem.lowerDecBound))-Problem.lowerDecBound)*2);

                
            end 
                          
    end
%     if calObj                                     %OLD
%         Offspring = INDIVIDUAL(Offspring);        %OLD
%     end                                           %OLD
    temp=struct;
    temp.decs=Offspring;
    temp.objs=zeros(size(Offspring));
    temp.cons=zeros(size(Offspring));
    Offspring=temp;
end