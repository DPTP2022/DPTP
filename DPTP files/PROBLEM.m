classdef PROBLEM
    % Novel class structure designed for DPTP 2021 (inspired by PlatEMO format). 
    % Properties inherited by the class DYNAMIC_PROBLEM. Together with an Algorithm Object can be used to
    % carry out experiments on DMOP parameter settings. See ALGORITHM for
    % more details.
    
    %Example Command Window Usage: (GUI usage is recommended - simply type " DPTP " into the command window and hit enter.
    %1. Define a Problem Object: P1=dMOP1('dMOP1','real',<NumberOfDecisionVariables>,<NumberOfObjectives>)
    %2. Additional settings for the problem such as dynamic parameters can
    %be set as input by including the label for the variable immediately
    %before it in the inputs e.g.: ...,'t_change_frequency',20,...
    
    properties
        name
        encoding
        DecVars
        Mobjectives
        lowerDecBound = 0;
        upperDecBound = 1;
        ShowParetoFrontFlag = 1;
    end
    
    methods
        %% Overloaded Constructor (must be public)
        function thisProblem = PROBLEM(encoding, DecVars, Mobjectives, varargin)
            if nargin >= 4
%                 thisProblem.name=name;
                temp=dbstack; temp={temp.name}; temp=temp{3}; temp=temp(1:floor(length(temp)/2));
                thisProblem.name=temp; clearvars temp;
                thisProblem.encoding=encoding;         
                thisProblem.DecVars=DecVars;                 
                thisProblem.Mobjectives=Mobjectives;                 
            end
            if nargin == 5
                thisProblem.lowerDecBound=varargin{1}(1);
                thisProblem.upperDecBound=varargin{1}(2);
            end
        end
        
        function pop = initPop(thisProblem,Npop)
            switch thisProblem.encoding
                case 'binary'
                    popdec = randi([0,1],Npop,thisProblem.DecVars);
                case 'permutation'
                    [~,popdec] = sort(rand(Npop,thisProblem.DecVars),2);
                otherwise %real valued
                    if isprop(thisProblem,'DecVarsSplit')==1
                        popdec=[];
                        %Handle DecVarsSplit
                        for i=1:length(thisProblem.DecVarsSplit)
                            popdec=[popdec unifrnd(repmat(thisProblem.lowerDecBound(i),Npop,thisProblem.DecVarsSplit(i)),repmat(thisProblem.upperDecBound(i),Npop,thisProblem.DecVarsSplit(i)));];
                        end
                    else
                        popdec = unifrnd(repmat(thisProblem.lowerDecBound,Npop,thisProblem.DecVars),repmat(thisProblem.upperDecBound,Npop,thisProblem.DecVars));
                    end
            end
            popobj=zeros(Npop,thisProblem.Mobjectives);
            pop=struct;
            pop.objs=popobj;
            pop.decs=popdec;   
            pop.cons=zeros(size(popdec));
        end
        
        
        function thisProblem = UpdateTime(thisProblem,AlgorithmObj)
            %% placeholder for non-dynamic problems to function the same as dynamic problems
        end
        
        function ShowParetoFront(thisProblem)
        %% placeholder for non-dynamic problems to function the same as dynamic problems
            if thisProblem.ShowParetoFrontFlag==1
                plot(gca,thisProblem.PF(:,1),thisProblem.PF(:,2),'k','LineWidth',1)
            end
        end
        
    end
end














%         %% Generate initial population
%         function PopDec = Init(obj,N)
%             switch obj.Global.encoding
%                 case 'binary'
%                     PopDec = randi([0,1],N,obj.Global.D);
%                 case 'permutation'
%                     [~,PopDec] = sort(rand(N,obj.Global.D),2);
%                 otherwise
%                     PopDec = unifrnd(repmat(obj.Global.lower,N,1),repmat(obj.Global.upper,N,1));
%             end
%         end
% %         %% Calculate objective values - WHY IS THIS NEEDED IN THE SUPERCLASS
% %         function PopObj = CalObj(obj,PopDec)
% %             PopObj(:,1) = PopDec(:,1)   + sum(PopDec(:,2:end),2);
% %             PopObj(:,2) = 1-PopDec(:,1) + sum(PopDec(:,2:end),2);
% %         end
