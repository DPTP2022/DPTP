classdef T1 < DYNAMIC_PROBLEM
    %% T1 - Huang2011
    %Huang, L., Suh, I. H., & Abraham, A. (2011). Dynamic multi-objective optimization 
    %based on membrane computing for control of time-varying unstable plants. 
    %Information Sciences, 181(11), 2370–2391. https://doi.org/10.1016/j.ins.2010.12.015

    % Type IV
    % Minimize f1=f1(xi); f2=g(xii,t)*h(f1,g);
    % xi,xii range [0,1]
    % Number of decision variables changes
    
    properties
        %t_val = 1; 
        PF=[];
        DecVarsSplit;
    end
%     properties (Dependent)
%         %Calculated each time the value is requested
%     end
    methods
        function thisProblem = T1(varargin)
        %% Overloaded Constructor (must be public)
            thisProblem=thisProblem@DYNAMIC_PROBLEM(varargin{:});
            thisProblem.lowerDecBound=[0 0]; %Not specified in Helbig2013
            thisProblem.upperDecBound=[1 1]; %Not specified in Helbig2013
            
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
            
            
%             xpop=[linspace(0,1,Npop)' zeros(Npop,5)];

            d1=floor(size(xpop,2)*abs(sin(t)));
            d2=floor(size(xpop,2)*(abs(cos(2*t).^3)));

            f1=sum((xpop(:,1:d1).^2)-10*cos(2*pi.*xpop(:,1:d1))+10,2);
            f2=((xpop(:,1)-1).^2)+sum((((xpop(:,(d1+2):(d1+d2))).^2)-xpop(:,(d1+1):(d1+d2-1))).^2,2);


            
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
