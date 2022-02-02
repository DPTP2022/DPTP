classdef HE1 < DYNAMIC_PROBLEM
    %% HE1
    %Helbig, M., & Engelbrecht, A. P. (2013). Benchmarks for dynamic multi-objective optimisation. 
    %Proceedings of the 2013 IEEE Symposium on Computational Intelligence in Dynamic and Uncertain 
    %Environments, CIDUE 2013 - 2013 IEEE Symposium Series on Computational Intelligence, 
    %SSCI 2013, 46(3), 84–91. https://doi.org/10.1109/CIDUE.2013.6595776
        
    % Type III
    % Minimize f1=f1(xi); f2=g(xii,t)*h(f1,g);
    % xi,xii range [0,1]
    
    properties
        %t_val = 1; 
        PF=[];
        DecVarsSplit;
    end
    methods
        function thisProblem = HE1(varargin)
        %% Overloaded Constructor (must be public)
            thisProblem=thisProblem@DYNAMIC_PROBLEM(varargin{:});
            thisProblem.lowerDecBound=[0 0];
            thisProblem.upperDecBound=[1 1];
            
            if sum(strcmp(varargin,'DecVarsSplit'))>0 
                thisProblem.DecVarsSplit=varargin{find(strcmp(varargin,'DecVarsSplit')==1)+1};
            else 
                thisProblem.DecVarsSplit=[1 thisProblem.DecVars-1]; 
            end
            
            thisProblem.PF=ParetoFront(thisProblem,100);
            
        end
        
        

        
        %%
        function popObj = CalcObj(thisProblem,PopulationDecVars,t)
            %popObj is a N*M matrix of objective values
            if nargin<3 
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
            g=1+(9/(size(PopulationDecVars,2)-1)).*sum(xii,2);
            h=1-sqrt(f1./g)-((f1./g).*sin(10*pi*t.*f1));
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
            P=[P (1-sqrt(xi)-(xi.*sin(10*pi*thisProblem.t_val.*xi)))];
%             plot(P(:,1),P(:,2),'k','LineWidth',1)
        end
    end
    
end
