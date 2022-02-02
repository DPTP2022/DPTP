classdef ALGORITHM
    % Novel class structure designed for DPTP 2021 (inspired by PlatEMO format). Together with a
    % (Dynamic) Problem Object and a Population structure can be used to
    % carry out experiments on DMOP parameter settings.
    
    %Example Command Window Usage: (GUI usage is recommended - simply type " DPTP " into the command window and hit enter.
    %1. Define a Problem Object: P1=dMOP1('dMOP1','real',<NumberOfDecisionVariables>,<NumberOfObjectives>)
    %2. Define Algorithm Object: A1=ALGORITHM(<'Name'>,[0 0 0],<Population size>,<Evaluation Budget>)
    %3. Set algorithm settings for plotting, saving etc.
    %4. [A1,P1,Population]=A1.startAlgorithm(P1)
    %5. A1.metrics has all the metric measurements contained in it.

    
    properties
        name
        parameters
        Npop
        evalBudget
        evalConsumed
        metrics
        History
        AllMetricsFlag = 0;
        SaveDataFlag = 0;
        DrawFlag = 1;
        Dynamic_Response = [0 0];
    end
    properties (Access = private)
%         DrawFlag = 1;
%         DrawMetricsFlag = 1;
        Fighandle_obj = 1
        Fighandle_metrics = 2
    end
    
    methods
        function thisAlgorithm = ALGORITHM(name,parameters,Npop,evalBudget)
            %ALGORITHM Construct an instance of this class
            %   Detailed explanation goes here
            thisAlgorithm.name       = name;
            thisAlgorithm.parameters = parameters;
            thisAlgorithm.Npop = Npop;
            thisAlgorithm.evalBudget = evalBudget;
            thisAlgorithm.evalConsumed = 0;
            thisAlgorithm.metrics=struct;
            thisAlgorithm.History = {};
            
        end
        %%
        function [Algorithm,Problem,Population] = startAlgorithm(Algorithm,Problem)
            %Start the optimization - specific algorithms are functions not
            %class objects
     
            %Reset if using the same algorithm again:
            if Algorithm.evalConsumed > 0
                Algorithm.evalConsumed=0;
                Algorithm.metrics=struct;
                Algorithm.History = {};
            end
            
            %The inputs cell array contains {'Problem Object'}
            disp(['Starting algorithm <' Algorithm.name '> on <' Problem.name '> with parameters:'])
            disp(['Npop(' num2str(Algorithm.Npop) '), DecVars(' num2str(Problem.DecVars) '), Mobj(' num2str(Problem.Mobjectives) ') for ' num2str(Algorithm.evalBudget) ' evals.'])
            eval(['[Algorithm,Problem,Population]=' Algorithm.name '(Algorithm,Problem);'])

            
            %%%% Saving has moved outside, into the GUI
%             if Algorithm.SaveDataFlag==1
%                 savepath=[cd '\Data\'];
%                 namestr=[Algorithm.name '_' Problem.name '_M' num2str(Problem.Mobjectives) '_Dec' num2str(Problem.DecVars) ...
%                          '_Pop' num2str(Algorithm.Npop) '_1.mat'];
%                          '_Pop' num2str(AlgorithmObj.Npop) '_dyn0' '_1.mat'];
%                 a=1;
%                 if exist([savepath namestr])>0
%                     a=a+1;
%                     namestr=[namestr(1:find(namestr=='_',1,'last')) num2str(a) '.mat'];
%                 end
%                 save([savepath namestr],'Algorithm','Problem','PopStruct')
%             end
            
        end
        %%
        function TerminationFlag = CheckTermination(thisAlgorithm)
            if thisAlgorithm.evalConsumed >= thisAlgorithm.evalBudget
                TerminationFlag=1;
            else
                TerminationFlag=0;
            end            
        end
        %%
        function thisAlgorithm = RecordMetrics(thisAlgorithm,ProblemObj,PopulationStruct)
            
            %Do a selection of metrics
            if thisAlgorithm.evalConsumed<=thisAlgorithm.Npop
                thisAlgorithm.metrics.HV=[];
                thisAlgorithm.metrics.IGD=[];
                thisAlgorithm.metrics.GD=[];
                thisAlgorithm.metrics.Spread=[];
                thisAlgorithm.metrics.PerfectHV=[];
                thisAlgorithm.metrics.EvalCounter=[];
                thisAlgorithm.metrics.tState=[];
            end
            thisAlgorithm.metrics.HV=           [thisAlgorithm.metrics.HV;     HV(PopulationStruct.objs,ProblemObj.PF)];
            thisAlgorithm.metrics.IGD=          [thisAlgorithm.metrics.IGD;    IGD(PopulationStruct.objs,ProblemObj.PF)];
            thisAlgorithm.metrics.GD=           [thisAlgorithm.metrics.GD;     GD(PopulationStruct.objs,ProblemObj.PF)];
            thisAlgorithm.metrics.Spread=       [thisAlgorithm.metrics.Spread; Spread(PopulationStruct.objs,ProblemObj.PF)];
            thisAlgorithm.metrics.PerfectHV=    [thisAlgorithm.metrics.PerfectHV; HV(ProblemObj.ParetoFront(size(PopulationStruct.objs,1)),ProblemObj.PF)];
            thisAlgorithm.metrics.EvalCounter=  [thisAlgorithm.metrics.EvalCounter; thisAlgorithm.evalConsumed];
            thisAlgorithm.metrics.tState=  [thisAlgorithm.metrics.tState; ProblemObj.t_val];
            
            
            if thisAlgorithm.AllMetricsFlag==1  %Do all metrics
                if thisAlgorithm.evalConsumed<=thisAlgorithm.Npop
                    thisAlgorithm.metrics.DeltaP=[];
                    thisAlgorithm.metrics.CPF=[];
                    thisAlgorithm.metrics.PD=[];
                    thisAlgorithm.metrics.DM=[];
                    thisAlgorithm.metrics.Coverage=[];
                    thisAlgorithm.metrics.Spacing=[];
                end
                thisAlgorithm.metrics.DeltaP =   [thisAlgorithm.metrics.DeltaP; DeltaP(PopulationStruct.objs,ProblemObj.PF)];
                thisAlgorithm.metrics.CPF =      [thisAlgorithm.metrics.CPF; CPF(PopulationStruct.objs,ProblemObj.PF)];
                thisAlgorithm.metrics.PD =       [thisAlgorithm.metrics.PD; PD(PopulationStruct.objs,ProblemObj.PF)];
                thisAlgorithm.metrics.DM =       [thisAlgorithm.metrics.DM; DM(PopulationStruct.objs,ProblemObj.PF)];
                thisAlgorithm.metrics.Coverage = [thisAlgorithm.metrics.Coverage; Coverage(PopulationStruct.objs,ProblemObj.PF)];
                thisAlgorithm.metrics.Spacing =  [thisAlgorithm.metrics.Spacing; Spacing(PopulationStruct.objs,ProblemObj.PF)];
            end
                %--------------%
                %Temp halt afer 1 round
                if ProblemObj.t_val==ProblemObj.t_range(2) && thisAlgorithm.evalConsumed<thisAlgorithm.evalBudget-(ProblemObj.t_change_frequency*thisAlgorithm.Npop)
                    thisAlgorithm.evalConsumed=thisAlgorithm.evalBudget-(ProblemObj.t_change_frequency*thisAlgorithm.Npop);
                end
                %--------------%
        end
        %%
        %function dynamicDetectionFlag = Dynamic_Detection(thisAlgorithm,ProblemObj,PopulationStruct)
            %Compare previous populations objective values to current ones
            %and flag changes 
            %Called within the startAlgorithm function while the
            %optimization is running
            
            
       %end
        %%
        function Response_Solutions = Execute_Dynamic_Response(thisAlgorithm,ProblemObj,PopulationStruct)
            %Based on the input parameters of the <Dynamic_Response> parameters
            if thisAlgorithm.Dynamic_Response(1)==1 %Random solution insertion
                RandPop = ProblemObj.initPop(thisAlgorithm.Npop*(thisAlgorithm.Dynamic_Response(2)/100));
                Response_Solutions=RandPop.decs;
            elseif thisAlgorithm.Dynamic_Response(1)==2
                sample_inds=randsample(thisAlgorithm.Npop,thisAlgorithm.Npop*(thisAlgorithm.Dynamic_Response(2)/100));
                Response_Solutions = thisAlgorithm.Dynamic_Response_Mutation(ProblemObj,[PopulationStruct.decs(sample_inds,:)]);
%             elseif thisAlgorithm.Dynamic_Response(1)==3 %Full restart
%                 RandPop = ProblemObj.initPop(thisAlgorithm.Npop);
%                 Response_Solutions=RandPop.decs;
            end
            
        end
        

        %%
        function [thisAlgorithm] = Draw(thisAlgorithm,Data,varargin)
            if isempty(varargin)==0
                DataType=char(varargin{1});
            else
                DataType='Obj';
            end
            if length(varargin)>1; if isprop(varargin{2},'PF')==1; ProblemObj=varargin{2}; end; end
            [N,M] = size(Data);
            Colours=[0.3000    0.8000    1.0000
                    0.7000    0.7000    0.3000
                    0.2000    0.2000         0
                    1.0000    0.8000    0.8000
                    0.1000    0.4000    0.8000
                    0.1000    0.6000    0.1000
                    0.4000    0.4000    0.4000
                    0.2000         0    0.6000
                    0.1000    0.1000    1.0000
                         0         0         0
                    0.6000    0.2000    0.3000
                    0.8000    0.7000    0.5000
                    0.5000    0.5000    1.0000
                         0         0    0.5000];
            if thisAlgorithm.DrawFlag==1
                ct=get(gca,'Children'); 
                if isempty(ct)==0 && thisAlgorithm.evalConsumed<=thisAlgorithm.Npop; 
                    hold(gca,'off'); 
                end
                set(gca,'NextPlot','add','Box','on','FontUnits','points','Fontname','Arial','FontSize',14);
                switch DataType
                    case 'Obj'
%                         figure(thisAlgorithm.Fighandle_obj); 
                        thisAlgorithm.Fighandle_obj=gcf; try thisAlgorithm.Fighandle_obj=thisAlgorithm.Fighandle_obj.Children(2).Children(1); end %******* 
                        plotargs={60,'Marker','.','Markerfacecolor',[0 0 0],'Markeredgecolor',[0 0 0]};
                        delete(findobj(gca,'type','Text'));
                        ct=get(gca,'Children'); try ct(2).MarkerEdgeColor=[0.6 0.6 0.6]; ct(2).MarkerEdgeAlpha=0.4; ct(2).MarkerFaceAlpha=0.4; end
                        if M==2
                            scatter(gca,Data(:,1),Data(:,2),plotargs{:}); 
                            xlabel('\it f\rm_1'); ylabel('\it f\rm_2');
                             set(gca,'XTickMode','auto','YTickMode','auto','View',[0 90]);
%                             axis tight; 
                            if exist('ProblemObj')>0; if ProblemObj.ShowParetoFrontFlag==1; delete(findobj(gca,'type','Line')); ProblemObj.ShowParetoFront; end; end
                        elseif M==3
                            scatter3(Data(:,1),Data(:,2),Data(:,3),plotargs{:});
                            xlabel('\it f\rm_1'); ylabel('\it f\rm_2'); zlabel('\it f\rm_3');
                            set(gca,'XTickMode','auto','YTickMode','auto','ZTickMode','auto','View',[135 30]);
                            axis tight;
                            %Add statement here: PF for 3 objectives
                        elseif M>3
                            plotargs={'LineWidth',1.5};
                            disp(['Visualisation for ' num2str(M) ' objectives is not advised'])
                            Label = repmat([0.99,2:M-1,M+0.01],N,1);
                            Data(2:2:end,:)  = fliplr(Data(2:2:end,:));
                            Label(2:2:end,:) = fliplr(Label(2:2:end,:));
                            Data  = Data';
                            Label = Label';
                            plot(Label(:),Data(:),'Color',Colours(1,:),plotargs{:});
                            xlabel('Dimension No.'); ylabel('Value');
                            set(gca,'XTick',1:ceil(M/10):M,'XLim',[1,M],'YTickMode','auto','View',[0 90]);
                            %Add statement here: PF for >3 objectives
                        end
                        axis(gca,'square'); t1=[get(gca,'XLim') get(gca,'YLim')]; set(gca,'XLim',[0 t1(2)],'YLim',[0 t1(4)]); ylim([0 1])
                        if exist('ProblemObj')>0; title(gca,[thisAlgorithm.name ' - ' ProblemObj.name ' - tval: ' num2str(ProblemObj.t_val)]); end
    %                     text(1[])
                        %eval counter labels
                        getpos=[get(gca,'Position')];
                        getpos=[getpos(3)-(0.15*getpos(3)) 0.98];
                        text(getpos(1),getpos(2),[num2str(thisAlgorithm.evalConsumed) '/' num2str(thisAlgorithm.evalBudget)])
                        %Non concave->convex 
                        %try; text(getpos(1),getpos(2)-0.05, ['optHV: ' num2str(100*(thisAlgorithm.metrics.HV(end)/thisAlgorithm.metrics.PerfectHV(end)),4) '%']); end
                        %Copes with convex_optHV>concave_optHV -> optHV is the goal
                        try; text(getpos(1),getpos(2)-0.05, ['optHV: ' num2str(100*(1-abs(thisAlgorithm.metrics.PerfectHV(end)-thisAlgorithm.metrics.HV(end))/thisAlgorithm.metrics.PerfectHV(end)),4) '%']); end
                        drawnow  
                        thisAlgorithm.History=[thisAlgorithm.History; {Data thisAlgorithm.Fighandle_obj}];

                    case 'Metric'
                        figure(thisAlgorithm.Fighandle_metrics); thisAlgorithm.Fighandle_metrics=gcf;
                        plotargs={'LineWidth',1.5};

                        %Get metric field names
                        metricLabels=fields(thisAlgorithm.metrics);
                        %Based on length, use Nplots for metric diplay
                        if length(metricLabels)<=4+3
                            ax=Nplots(2,2);
                            for m=1:length(metricLabels)-3
                                eval(['plot(ax.ax' num2str(m) ',thisAlgorithm.metrics.(metricLabels{m}),"Color",Colours(m,:));'])
                                eval(['title(ax.ax' num2str(m) ',metricLabels{m});'])
                            end
                        else
                            ax=Nplots(3,3); %Plot GD and IGD on the same plot)
                            for m=1:length(metricLabels)-4
                                if m<2
                                    eval(['plot(ax.ax' num2str(m) ',thisAlgorithm.metrics.(metricLabels{m}),"Color",Colours(m,:));'])
                                    eval(['title(ax.ax' num2str(m) ',metricLabels{m});'])
                                elseif m==2 %Plot GD on IGD's axis
                                    eval(['plot(ax.ax' num2str(m) ',thisAlgorithm.metrics.(metricLabels{m}),"Color",Colours(m,:));'])
                                    eval(['hold(ax.ax' num2str(m)  ',"on")'])
                                    eval(['plot(ax.ax' num2str(m) ',thisAlgorithm.metrics.(metricLabels{m+1}),"Color",Colours(m+1,:));'])
                                    titlestring=[metricLabels{m} '/' metricLabels{m+1}];
                                    eval(['title(ax.ax' num2str(m) ',titlestring);'])
                                    eval(['legend(ax.ax' num2str(m) ',metricLabels{m:m+1},"Orientation","Horizontal","Box","off","Location","NorthEast")'])
                                elseif m>=3
                                    n=m+1;
                                    eval(['plot(ax.ax' num2str(m) ',thisAlgorithm.metrics.(metricLabels{n}),"Color",Colours(n,:));'])
                                    eval(['title(ax.ax' num2str(m) ',metricLabels{n});'])
                                end
                            end

                        end
                        drawnow


                        %Dynamic interval boundaries with handles off
                        %3rd dimension averaging for aggregated data accross multiple runs: mean(Data,3)
                    otherwise
                        disp('WARNING: Cannot display data')

                end
            end
        end
          
        
        %%
        function Mutated_Solutions = Dynamic_Response_Mutation(thisAlgorithm,ProblemObj,Parent_Solutions)
            %% Parameter setting
            [proC,disC,proM,disM] = deal(1,20,1,20);
            [N,D]   = size(Parent_Solutions);    
            switch ProblemObj.encoding
                case 'binary'
                    %% Genetic mutation for binary encoding
                    % Bitwise mutation
                    Site = rand(2*N,D) < proM/D;
                    Parent_Solutions(Site) = ~Parent_Solutions(Site);
                    Mutated_Solutions=Parent_Solutions;
                case 'permutation'
                    %% Genetic operators for permutation based encoding
                    % Slight mutation
                    k = randi(D,1,2*N);
                    s = randi(D,1,2*N);
                    for i = 1 : 2*N
                        if s(i) < k(i)
                            Parent_Solutions(i,:) = Parent_Solutions(i,[1:s(i)-1,k(i),s(i):k(i)-1,k(i)+1:end]);
                        elseif s(i) > k(i)
                            Parent_Solutions(i,:) = Parent_Solutions(i,[1:k(i)-1,k(i)+1:s(i)-1,k(i),s(i):end]);
                        end
                    end
                    Mutated_Solutions=Parent_Solutions;
                otherwise
                    %% Genetic mutation for real encoding

                    if isprop(ProblemObj,'DecVarsSplit')==1
                        tempMutated_Solutions=[];
                        for i=1:length(ProblemObj.DecVarsSplit)
                            Mutated_SolutionsSlice=Parent_Solutions(:,(ProblemObj.DecVarsSplit(max([1 i-1]))+(i-1)):(ProblemObj.DecVarsSplit(max([1 i-1]))+(i-1)+(ProblemObj.DecVarsSplit(i)-1)));
                            % Polynomial mutation
                            Lower = repmat(ProblemObj.lowerDecBound(i),N,ProblemObj.DecVarsSplit(i));
                            Upper = repmat(ProblemObj.upperDecBound(i),N,ProblemObj.DecVarsSplit(i));
                            Site  = rand(N,ProblemObj.DecVarsSplit(i)) < proM/D;
                            mu    = rand(N,ProblemObj.DecVarsSplit(i));
                            temp  = Site & mu<=0.5;
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            Mutated_SolutionsSlice       = min(max(Mutated_SolutionsSlice,Lower),Upper);
                            Mutated_SolutionsSlice(temp) = Mutated_SolutionsSlice(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                                              (1-(Mutated_SolutionsSlice(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
                            temp = Site & mu>0.5; 
                            Mutated_SolutionsSlice(temp) = Mutated_SolutionsSlice(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
                                              (1-(Upper(temp)-Mutated_SolutionsSlice(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%

                            %Correct for mutation outside the decision variable boundaries:
                            Mutated_SolutionsSlice(Mutated_SolutionsSlice>ProblemObj.upperDecBound(i))=Mutated_SolutionsSlice(Mutated_SolutionsSlice>ProblemObj.upperDecBound(i))-((Mutated_SolutionsSlice(Mutated_SolutionsSlice>ProblemObj.upperDecBound(i))-ProblemObj.upperDecBound(i))*2);
                            Mutated_SolutionsSlice(Mutated_SolutionsSlice<ProblemObj.lowerDecBound(i))=Mutated_SolutionsSlice(Mutated_SolutionsSlice<ProblemObj.lowerDecBound(i))+((abs(Mutated_SolutionsSlice(Mutated_SolutionsSlice<ProblemObj.lowerDecBound(i)))-ProblemObj.lowerDecBound(i))*2);


                            tempMutated_Solutions=[tempMutated_Solutions Mutated_SolutionsSlice];
                        end
                        Mutated_Solutions=tempMutated_Solutions;
                    else
                        Mutated_Solutions=Parent_Solutions;
                        % Polynomial mutation
                        Lower = repmat(ProblemObj.lowerDecBound,N,D);
                        Upper = repmat(ProblemObj.upperDecBound,N,D);
                        Site  = rand(N,D) < proM/D;
                        mu    = rand(N,D);
                        temp  = Site & mu<=0.5;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        Mutated_Solutions       = min(max(Mutated_Solutions,Lower),Upper);
                        Mutated_Solutions(temp) = Mutated_Solutions(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                                          (1-(Mutated_Solutions(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
                        temp = Site & mu>0.5; 
                        Mutated_Solutions(temp) = Mutated_Solutions(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
                                          (1-(Upper(temp)-Mutated_Solutions(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %Correct for mutation outside the decision variable boundaries:
                        Mutated_Solutions(Mutated_Solutions>ProblemObj.upperDecBound)=Mutated_Solutions(Mutated_Solutions>ProblemObj.upperDecBound)-((Mutated_Solutions(Mutated_Solutions>Problem.upperDecBound)-ProblemObj.upperDecBound)*2);
                        Mutated_Solutions(Mutated_Solutions>ProblemObj.lowerDecBound)=Mutated_Solutions(Mutated_Solutions<ProblemObj.lowerDecBound)+((abs(Mutated_Solutions(Mutated_Solutions<Problem.lowerDecBound))-ProblemObj.lowerDecBound)*2);


                    end
                end
            end
    end
end

