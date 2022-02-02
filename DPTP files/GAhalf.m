function Offspring = GAhalf(Parent,Problem,Parameter)
% Modififed by ----- ----- for DPTP 2021

% Some of the original code from the PlatEMO version has changed but major
% modifications were required to handle decision variable slicing with
% different ranges. The output and input formats for the population are
% also different. We acknowledge the core principle implemented in "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87". The original
% blurb is as below.


%GAhalf - Genetic operators for real, binary, and permutation based
%encodings.
%
%   This function is the same to GA, but only the first half of the
%   offsprings are returned.
%
%   See also GA

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
    Parent1 = Parent(1:floor(end/2),:);               
    Parent2 = Parent(floor(end/2)+1:floor(end/2)*2,:); 
    [N,D]   = size(Parent1);                           
 %     Global  = GLOBAL.GetObj();

    switch Problem.encoding
        case 'binary'
            %% Genetic operators for binary encoding
            % One point crossover
            k = repmat(1:D,N,1) > repmat(randi(D,N,1),1,D);
            k(repmat(rand(N,1)>proC,1,D)) = false;
            Offspring    = Parent1;
            Offspring(k) = Parent2(k);
            % Bitwise mutation
            Site = rand(N,D) < proM/D;
            Offspring(Site) = ~Offspring(Site);
        case 'permutation'
            %% Genetic operators for permutation based encoding
            % Order crossover
            Offspring = Parent1;
            k = randi(D,1,N);
            for i = 1 : N
                Offspring(i,k(i)+1:end) = setdiff(Parent2(i,:),Parent1(i,1:k(i)),'stable');
            end
            % Slight mutation
            k = randi(D,1,N);
            s = randi(D,1,N);
            for i = 1 : N
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
            Offspring = (Parent1+Parent2)/2+beta.*(Parent1-Parent2)/2;

            
            if isprop(Problem,'DecVarsSplit')==1
                tempOffspring=[];
                for i=1:length(Problem.DecVarsSplit)
                    OffspringSlice=Offspring(:,(Problem.DecVarsSplit(max([1 i-1]))+(i-1)):(Problem.DecVarsSplit(max([1 i-1]))+(i-1)+(Problem.DecVarsSplit(i)-1)));
                    % Polynomial mutation
                    Lower = repmat(Problem.lowerDecBound(i),N,Problem.DecVarsSplit(i));
                    Upper = repmat(Problem.upperDecBound(i),N,Problem.DecVarsSplit(i));
                    Site  = rand(N,Problem.DecVarsSplit(i)) < proM/D;
                    mu    = rand(N,Problem.DecVarsSplit(i));
                    temp  = Site & mu<=0.5;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    OffspringSlice       = min(max(OffspringSlice,Lower),Upper);
                    OffspringSlice(temp) = OffspringSlice(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                                      (1-(OffspringSlice(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
                    temp = Site & mu>0.5; 
                    OffspringSlice(temp) = OffspringSlice(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
                                      (1-(Upper(temp)-OffspringSlice(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%
                    tempOffspring=[tempOffspring OffspringSlice];
                end
                Offspring=tempOffspring;
            else
                % Polynomial mutation
                Lower = repmat(Problem.lowerDecBound,N,D);
                Upper = repmat(Problem.upperDecBound,N,D);
                Site  = rand(N,D) < proM/D;
                mu    = rand(N,D);
                temp  = Site & mu<=0.5;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Offspring       = min(max(Offspring,Lower),Upper);
                Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                                  (1-(Offspring(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
                temp = Site & mu>0.5; 
                Offspring(temp) = Offspring(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
                                  (1-(Upper(temp)-Offspring(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
            end 
    end
%     if calObj
%         Offspring = INDIVIDUAL(Offspring);
%     end
    temp=struct;
    temp.decs=Offspring;
    temp.objs=zeros(size(Offspring));
    temp.cons=zeros(size(Offspring));
    Offspring=temp;
end