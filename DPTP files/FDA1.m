classdef FDA1 < DYNAMIC_PROBLEM
    %Farina, M., Deb, K., & Amato, P. (2003). Dynamic Multiobjective Optimization Problems: 
    %Test Cases Approximation and Applications. Evolutionary Multi-Criterion Optimization. 
    %Second International Conference EMO 2003, 8(5), 311–326. 
    %https://doi.org/10.1109/TEVC.2004.831456
    
    properties
        PF=[];
        DecVarsSplit;
    end
    methods
        function thisProblem = FDA1(varargin)
        %% Overloaded Constructor (must be public)
            thisProblem=thisProblem@DYNAMIC_PROBLEM(varargin{:});
            thisProblem.lowerDecBound=[0 -1];
            thisProblem.upperDecBound=[1 1];
            
            if sum(strcmp(varargin,'DecVarsSplit'))>0 
                thisProblem.DecVarsSplit=varargin{find(strcmp(varargin,'DecVarsSplit')==1)+1};
            else %Default t_range for FDA1:
                thisProblem.DecVarsSplit=[1 thisProblem.DecVars-1]; %VERIFY/JUSTIFY THESE NUMBERS
            end
            
            thisProblem.PF=ParetoFront(thisProblem,100);
        end
        
        

        
        %%
        function popObj = CalcObj(thisProblem,PopulationDecVars)
            %popObj is a N*M matrix of objective values
            t=thisProblem.t_val;
            
            f1=PopulationDecVars(:,1);
            G=sin(0.5*pi*t);
            g=1+sum((PopulationDecVars(:,2:end)-G).^2,2);
            f2=1-sqrt(f1./g);
            
            
            
            popObj=[f1 f2];
            
        end
        %%
        function popCon = CalcCon(thisProblem,PopulationDecVars)
            popCon=zeros(size(PopulationDecVars));
        end
        
        %% Sample reference points on Pareto front
        function P = ParetoFront(thisProblem,N)
            P = (0:(1/(N-1)):1)';
            P = [P (1-sqrt((0:(1/(N-1)):1)'))];
            %pd=[(0:1/(N-1):1)' 0.5*ones(N,thisProblem.DecVars-1)]; %Optimal decision vairables population

        end
    end
    
end
