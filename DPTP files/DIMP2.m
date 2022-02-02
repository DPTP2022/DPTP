classdef DIMP2 < DYNAMIC_PROBLEM
    %% DIMP2
    %Koo, W. T., Goh, C. K., & Tan, K. C. (2010). A predictive gradient strategy for 
    %multiobjective evolutionary algorithms in a fast changing environment. 
    %Memetic Computing, 2(2), 87–110. https://doi.org/10.1007/s12293-009-0026-7
    
    % Type I
    % Minimize f1=f1(xi); f2=g(xii,t)*h(f1,g);
    % xi,xii range [0,1]
    
    properties
        %t_val = 1; 
        PF=[];
        DecVarsSplit;
    end
    methods
        function thisProblem = DIMP2(varargin)
        %% Overloaded Constructor (must be public)
            thisProblem=thisProblem@DYNAMIC_PROBLEM(varargin{:});
            thisProblem.lowerDecBound=[0 -2];
            thisProblem.upperDecBound=[1 2];
            
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
            %Different G for each decision variable column
            G=sin(0.5*pi*t + (2*pi)*((xsplit(2,1):1:xsplit(2,2))'./(size(PopulationDecVars,2)+1))).^2; G=reshape(G,1,numel(G)); G=repmat(G,size(xii,1),1);
            g=1+(2*(size(PopulationDecVars,2)-1))+sum(((xii-G).^2)-(2*cos(3*pi.*(xii-G))),2);
            h=1-sqrt(f1./g);
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

            P=xi;
            P=[P (1-sqrt(xi))];
        end
    end
    
end
