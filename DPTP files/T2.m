classdef T2 < DYNAMIC_PROBLEM
    %% T2 - Huang2011
    %Huang, L., Suh, I. H., & Abraham, A. (2011). Dynamic multi-objective optimization 
    %based on membrane computing for control of time-varying unstable plants. 
    %Information Sciences, 181(11), 2370–2391. https://doi.org/10.1016/j.ins.2010.12.015
    
    % Type III
    % xi range [0,1]
    % Number of objective functions changes over time

    properties
        %t_val = 1; 
        PF=[];
        DecVarsSplit;
    end
    methods
        function thisProblem = T2(varargin)
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
            
            
            M=size(xpop,2); %Maximum number of objectives

            m=floor(M*sin(0.5*pi*t));
            g=sum(xpop(:,1:m).^2,2);
            halfpi=pi/2;

            f1=(1+g).*prod(cos(halfpi.*xpop(:,1:(m-1))),2);
            for k=2:m-1
                f=(1+g).*prod(cos(halfpi.*xpop(:,1:(m-1))).*rempat(sin(halfpi.*xpop(:,(m-k+1))),1,(m-1)),2);
                eval(['f' num2str(k) '=f;']);
            end
            f=(1+g).*(sin(halfpi.*xpop(:,1)).^(m-1));
            eval(['f' num2str(m) '=f;']);


            
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
