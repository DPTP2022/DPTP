classdef dMOP2 < DYNAMIC_PROBLEM
    %% dMOP2
    %Goh, C. K., & Tan, K. C. (2009). A competitive-cooperative coevolutionary paradigm 
    %for dynamic multiobjective optimization. IEEE Transactions on Evolutionary Computation, 
    %13(1), 103–127. https://doi.org/10.1109/TEVC.2008.920671
    
    % Type II
    % Minimize f1=f1(xi); f2=g(xii,t)*h(f1,g,t);
    % xi,xii range [0,1]

    properties
        %t_val = 1; 
        PF=[];
        DecVarsSplit;
    end
    methods
        function thisProblem = dMOP2(varargin)
        %% Overloaded Constructor (must be public)
            thisProblem=thisProblem@DYNAMIC_PROBLEM(varargin{:});
            thisProblem.lowerDecBound=[0 0];
            thisProblem.upperDecBound=[1 1];
            
            if sum(strcmp(varargin,'DecVarsSplit'))>0 
                thisProblem.DecVarsSplit=varargin{find(strcmp(varargin,'DecVarsSplit')==1)+1};
            else 
                thisProblem.DecVarsSplit=[1 thisProblem.DecVars-1]; %VERIFY/JUSTIFY THESE NUMBERS
            end
            
            thisProblem.PF=ParetoFront(thisProblem,100);
            
        end
        
        

        
        %%
        function popObj = CalcObj(thisProblem,PopulationDecVars,t)
            %popObj is a N*M matrix of objective values
            if nargin<3 %t can be specified on the call of the function (DEBUGGING)
                t=thisProblem.t_val;
            end
            xsplit=[];
            for i=1:length(thisProblem.DecVarsSplit)
                if i==1
                    xsplit=[1 thisProblem.DecVarsSplit(1)];
                else
                    xsplit=[xsplit; xsplit(i-1,2)+1 xsplit(i-1,2)+thisProblem.DecVarsSplit(i)];
                end
            end
            
            xi=PopulationDecVars(:,xsplit(1,1):xsplit(1,2));
            xii=PopulationDecVars(:,xsplit(2,1):xsplit(2,2));
            
            
            f1=xi;
            G=sin(0.5*pi*t);
            g=1+(9*sum((xii-G).^2,2));
            H=0.75*sin(0.5*pi*t)+1.25;
            h=1-((f1./g).^H);
            f2=g.*h;
            
            popObj=[f1 f2];

            
        end
        %%
        function popCon = CalcCon(thisProblem,PopulationDecVars)
            popCon=zeros(size(PopulationDecVars));
        end
        
        %% Sample reference points on Pareto front
        function P = ParetoFront(thisProblem,N)

            xi = linspace(0,1,N)';
            H=0.75*sin(0.5*pi*thisProblem.t_val)+1.25;

            P=xi;
            P=[P (1-(xi.^(H)))];
        
        end
    end
    
end
