function varargout = DPTP(varargin)
% DPTP MATLAB code for DPTP.fig
%      DPTP, by itself, creates a new DPTP or raises the existing
%      singleton*.
%
%      H = DPTP returns the handle to a new DPTP or the handle to
%      the existing singleton*.
%
%      DPTP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DPTP.M with the given input arguments.
%
%      DPTP('Property','Value',...) creates a new DPTP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DPTP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DPTP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DPTP

% Last Modified by GUIDE v2.5 01-Feb-2022 18:22:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DPTP_OpeningFcn, ...
                   'gui_OutputFcn',  @DPTP_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before DPTP is made visible.
function DPTP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
 
 
% varargin   command line arguments to DPTP (see VARARGIN)

% Choose default command line output for DPTP
handles.output = hObject;


handles.data=struct;
handles.data.AlgorithmDefaults={};
AlgorithmList=textread('AlgorithmList.txt','%s')'; AlgorithmList=reshape(AlgorithmList',4,length(AlgorithmList)/4)';
handles.data.AlgorithmDefaults=AlgorithmList(2:end,:);


handles.data.ProblemDefaults={};
ProblemList=textread('ProblemList.txt','%s')'; ProblemList=reshape(ProblemList',15,length(ProblemList)/15)';
handles.data.ProblemDefaults=ProblemList(2:end,:);

BulkExperimentsParameterList={'t_change_frequency','t_change_severity',...
               'Dynamic Onset Delay','Population Size',...
               'Dynamic Response Percentage','Number of Decision Variables'};
handles.Parameter1SelectMenu.String=BulkExperimentsParameterList;
handles.Parameter2SelectMenu.String=BulkExperimentsParameterList([2 1 3:length(BulkExperimentsParameterList)]);

% cla(handles.ProgressBarAxes)
handles.ProgressBarAxes.Position=[0.082,0.835,0.809,0.065];
handles.ProgressBarAxes.Visible='on'; axis(handles.ProgressBarAxes,'normal'); %axis(handles.ProgressBarAxes,'off')
set(handles.ProgressBarAxes,'XTick',[],'YTick',[],'Box','on'); 


% Update handles structure
guidata(hObject, handles);


% UIWAIT makes DPTP wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DPTP_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
 
 

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunButton (see GCBO)
 
 

addpath(genpath('Metrics'));
savepath
axes(handles.axes1);
cla;
handles.SingleToggleButton.Value=1;

%Load in all problem, algorithm and plotting parameters:
n_changes=30; %Make a box in the GUI for this
EvalBudget=(str2double(handles.DynamicOnsetDelayEdit.String)+(n_changes*str2double(handles.TChangeFrequencyEdit.String)))*str2double(handles.PopSizeEdit.String);
A1=ALGORITHM(handles.AlgorithmMenu.String{handles.AlgorithmMenu.Value},[str2double(handles.AddParamsEdit.String) 0 0],str2double(handles.PopSizeEdit.String),EvalBudget); 
A1.DrawFlag=str2double(handles.DisplayPlotsButton.Value); 
A1.SaveDataFlag=str2double(handles.SaveOutputsCheckbox.Value);
A1.AllMetricsFlag=str2double(handles.RecordAllMetricsButton.Value);

if handles.RandomResponseButton.Value==1
    DR=1;
elseif handles.MutatedResponseButton.Value==1
    DR=2;
elseif handles.RestartRepsonseButton.Value==1
    DR=3;
else
    DR=0;
end
A1.Dynamic_Response=[DR str2double(handles.DynamicResponsePercentageEdit.String)];

DecVarsSplit_alt=[];
if strcmp(handles.DecVarSplitIIEdit.Visible,'on')==1; DecVarsSplit_alt=[DecVarsSplit_alt str2double(handles.DecVarSplitIIEdit.String)]; end
if strcmp(handles.DecVarSplitIIIEdit.Visible,'on')==1; DecVarsSplit_alt=[DecVarsSplit_alt str2double(handles.DecVarSplitIIIEdit.String)]; end
Time_Units_String='generations'; if handles.TChangeFrequencyEvaluationsButton.Value==1; Time_Units_String='evaluations'; end
T_Loop_Behaviour='mirror'; if handles.TRangeCycleButton.Value==1; T_Loop_Behaviour='cycle'; end

VariableHandles={'DecVarsSplit','t_step_size','t_change_time_units','t_change_frequency','t_range','t_loop_behaviour','dynamic_onset_delay'};
P1=eval([handles.ProblemMenu.String{handles.ProblemMenu.Value} '(handles.EncodingEdit.String, str2double(handles.NumberOfDecisionVariablesEdit.String), str2double(handles.NumberOfObjectivesEdit.String),'...
       'VariableHandles{1},      [str2double(handles.DecVarSplitIEdit.String) DecVarsSplit_alt],'...
       'VariableHandles{2},      str2double(handles.TChangeMagnitudeEdit.String),'... 
       'VariableHandles{3},      Time_Units_String,'...
       'VariableHandles{4},      str2double(handles.TChangeFrequencyEdit.String),'...
       'VariableHandles{5},      [str2double(handles.TRangeLowerEdit.String) str2double(handles.TRangeUpperEdit.String)],'...
       'VariableHandles{6},      T_Loop_Behaviour,'...
       'VariableHandles{7},      str2double(handles.DynamicOnsetDelayEdit.String));']);
   
P1.ShowParetoFrontFlag=handles.PlotParetoFrontButton.Value;
   
[A1,P1,Population]=A1.startAlgorithm(P1);

if handles.SaveOutputsCheckbox.Value==1
    ObjectiveFigure=handles.axes1;
    if isempty(handles.SaveOutputsNameEdit.String)==1
        timestamp=datestr(now); timestamp=timestamp(end-7:end); timestamp(timestamp==':')='_';
        savefilename=['SavedOutputs_' timestamp '.mat'];
    else
        savefilename=[handles.SaveOutputsNameEdit.String '.mat'];
    end
    save(savefilename,'ObjectiveFigure', 'A1', 'P1', 'Population')
    disp(['Saved as ' savefilename])
end

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
 
 


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in AlgorithmMenu.
function AlgorithmMenu_Callback(hObject, eventdata, handles)
% hObject    handle to AlgorithmMenu (see GCBO)
n_changes=30;

% Hints: contents = get(hObject,'String') returns AlgorithmMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AlgorithmMenu
if get(hObject,'Value')>1
    Selected=get(hObject,'String'); Selected=Selected{get(hObject,'Value')};
    disp(['Algorithm <' Selected '> selected'])
    handles.PopSizeEdit.String=handles.data.AlgorithmDefaults{get(hObject,'Value')-1,2};
    handles.EvalBudgetEdit.String=num2str((str2double(handles.DynamicOnsetDelayEdit.String)+(n_changes*str2double(handles.TChangeFrequencyEdit.String)))*str2double(handles.PopSizeEdit.String));
    handles.AddParamsEdit.String=handles.data.AlgorithmDefaults{get(hObject,'Value')-1,4};
else
    handles.PopSizeEdit.String='';
    handles.EvalBudgetEdit.String='';
    handles.AddParamsEdit.String='';
end

% Auto-fill the boxes with the specified default values




% --- Executes during object creation, after setting all properties.
function AlgorithmMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AlgorithmMenu (see GCBO)
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end
AlgorithmList=textread('AlgorithmList.txt','%s')'; AlgorithmList=reshape(AlgorithmList',4,length(AlgorithmList)/4)';
AlgorithmList=['<Select Algorithm>', AlgorithmList(2:end,1)'];
set(hObject, 'String', AlgorithmList);


% --- Executes on selection change in ProblemMenu.
function ProblemMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ProblemMenu (see GCBO)

% Hints: contents = cellstr(get(hObject,'String')) returns ProblemMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ProblemMenu
if get(hObject,'Value')>1
    Selected=get(hObject,'String'); Selected=Selected{get(hObject,'Value')};
    disp(['Problem <' Selected '> selected'])
end
% Encoding NDecVars LowerBound UpperBound DVsplitI DVsplitII DVsplitIII
if get(hObject,'Value')>1
    Selected=get(hObject,'String'); Selected=Selected{get(hObject,'Value')};
    disp(['Problem <' Selected '> selected'])
    handles.EncodingEdit.String=handles.data.ProblemDefaults{get(hObject,'Value')-1,2};
    handles.NumberOfObjectivesEdit.String=handles.data.ProblemDefaults{get(hObject,'Value')-1,3};
    handles.NumberOfDecisionVariablesEdit.String=handles.data.ProblemDefaults{get(hObject,'Value')-1,4};
    handles.DecVarSplitIEdit.String=handles.data.ProblemDefaults{get(hObject,'Value')-1,5};
    handles.BoundsLowerIEdit.String=handles.data.ProblemDefaults{get(hObject,'Value')-1,6};
    handles.BoundsUpperIEdit.String=handles.data.ProblemDefaults{get(hObject,'Value')-1,7};
    if isnan(str2double(handles.data.ProblemDefaults{get(hObject,'Value')-1,8}))==0
        handles.DecVarSplitIIEdit.Visible=1; handles.text14.Visible=1; 
        handles.DecVarSplitIIEdit.String=num2str(max([1 str2double(handles.data.ProblemDefaults{get(hObject,'Value')-1,8})]));
        handles.BoundsLowerIIEdit.Visible=1; handles.text19.Visible=1; handles.BoundsUpperIIEdit.Visible=1;
        handles.BoundsLowerIIEdit.String=num2str(handles.data.ProblemDefaults{get(hObject,'Value')-1,9});
        handles.BoundsUpperIIEdit.String=num2str(handles.data.ProblemDefaults{get(hObject,'Value')-1,10});
    else
        handles.DecVarSplitIIEdit.Visible=0; handles.text14.Visible=0; 
        handles.BoundsLowerIIEdit.Visible=0; handles.text19.Visible=0;
        handles.BoundsUpperIIEdit.Visible=0; 
    end
    if isnan(str2double(handles.data.ProblemDefaults{get(hObject,'Value')-1,11}))==0
        handles.DecVarSplitIIIEdit.Visible=1; handles.text15.Visible=1; 
        handles.DecVarSplitIIIEdit.String=num2str(max([1 str2double(handles.data.ProblemDefaults{get(hObject,'Value')-1,11})]));
        handles.BoundsLowerIIIEdit.Visible=1; handles.text20.Visible=1; handles.BoundsUpperIIIEdit.Visible=1; 
        handles.BoundsLowerIIIEdit.String=num2str(handles.data.ProblemDefaults{get(hObject,'Value')-1,12});
        handles.BoundsUpperIIIEdit.String=num2str(handles.data.ProblemDefaults{get(hObject,'Value')-1,13});    
    else
        handles.DecVarSplitIIIEdit.Visible=0; handles.text15.Visible=0; 
        handles.BoundsLowerIIIEdit.Visible=0; handles.text20.Visible=0;
        handles.BoundsUpperIIIEdit.Visible=0; 
    end
    handles.TRangeLowerEdit.String=handles.data.ProblemDefaults{get(hObject,'Value')-1,14};
    handles.TRangeUpperEdit.String=handles.data.ProblemDefaults{get(hObject,'Value')-1,15};

else
    handles.EncodingEdit.String='';
    handles.NumberOfObjectivesEdit.String='';
    handles.NumberOfDecisionVariablesEdit.String='';
    handles.BoundsLowerIEdit.String='';
    handles.BoundsUpperIEdit.String='';
    handles.DecVarSplitIEdit.String='';
    handles.DecVarSplitIIEdit.String='';
    handles.DecVarSplitIIIEdit.String='';
    handles.TRangeLowerEdit.String='0';
    handles.TRangeUpperEdit.String='1';
    
end


% --- Executes during object creation, after setting all properties.
function ProblemMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProblemMenu (see GCBO)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
ProblemList=textread('ProblemList.txt','%s')'; ProblemList=reshape(ProblemList',15,length(ProblemList)/15)';
ProblemList=['<Select Problem>', ProblemList(2:end,1)'];
set(hObject, 'String', ProblemList);


function TChangeFrequencyEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TChangeFrequencyEdit (see GCBO) 
% Hints: get(hObject,'String') returns contents of TChangeFrequencyEdit as text
%        str2double(get(hObject,'String')) returns contents of TChangeFrequencyEdit as a double
n_changes=30;
handles.EvalBudgetEdit.String=num2str((str2double(handles.DynamicOnsetDelayEdit.String)+(n_changes*str2double(handles.TChangeFrequencyEdit.String)))*str2double(handles.PopSizeEdit.String));


% --- Executes during object creation, after setting all properties.
function TChangeFrequencyEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TChangeFrequencyEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotParetoFrontButton.
function PlotParetoFrontButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlotParetoFrontButton (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of PlotParetoFrontButton


% --- Executes on button press in SaveOutputsCheckbox.
function SaveOutputsCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to SaveOutputsCheckbox (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of SaveOutputsCheckbox

%Auto generated save filename
% if handles.SaveOutputsCheckbox==1
%    handles.SaveOutputsNameEdit=[handles.AlgorithmMenu.String{handles.AlgorithmMenu.Value} '_' handles.ProblemMenu.String{handles.ProblemMenu.Value} '_' ];
% end


% --- Executes on button press in TChangeFrequencyGenerationsButton.
function TChangeFrequencyGenerationsButton_Callback(hObject, eventdata, handles)
% hObject    handle to TChangeFrequencyGenerationsButton (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of TChangeFrequencyGenerationsButton
if handles.TChangeFrequencyGenerationsButton.Value==1
    handles.TChangeFrequencyEvaluationsButton.Value=0;
end
    

% --- Executes on button press in TChangeFrequencyEvaluationsButton.
function TChangeFrequencyEvaluationsButton_Callback(hObject, eventdata, handles)
% hObject    handle to TChangeFrequencyEvaluationsButton (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of TChangeFrequencyEvaluationsButton
if handles.TChangeFrequencyEvaluationsButton.Value==1
    handles.TChangeFrequencyGenerationsButton.Value=0;
end


function TChangeMagnitudeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TChangeMagnitudeEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of TChangeMagnitudeEdit as text
%        str2double(get(hObject,'String')) returns contents of TChangeMagnitudeEdit as a double


% --- Executes during object creation, after setting all properties.
function TChangeMagnitudeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TChangeMagnitudeEdit (see GCBO)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TRangeUpperEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TRangeUpperEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of TRangeUpperEdit as text
%        str2double(get(hObject,'String')) returns contents of TRangeUpperEdit as a double


% --- Executes during object creation, after setting all properties.
function TRangeUpperEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TRangeUpperEdit (see GCBO)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TRangeLowerEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TRangeLowerEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of TRangeLowerEdit as text
%        str2double(get(hObject,'String')) returns contents of TRangeLowerEdit as a double


% --- Executes during object creation, after setting all properties.
function TRangeLowerEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TRangeLowerEdit (see GCBO)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TRangeCycleButton.
function TRangeCycleButton_Callback(hObject, eventdata, handles)
% hObject    handle to TRangeCycleButton (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of TRangeCycleButton
if handles.TRangeCycleButton.Value==1
    handles.TRangeMirrorButton.Value=0;
end

% --- Executes on button press in TRangeMirrorButton.
function TRangeMirrorButton_Callback(hObject, eventdata, handles)
% hObject    handle to TRangeMirrorButton (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of TRangeMirrorButton
if handles.TRangeMirrorButton.Value==1
    handles.TRangeCycleButton.Value=0;
end


function EvalBudgetEdit_Callback(hObject, eventdata, handles)
% hObject    handle to EvalBudgetEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of EvalBudgetEdit as text
%        str2double(get(hObject,'String')) returns contents of EvalBudgetEdit as a double


% --- Executes during object creation, after setting all properties.
function EvalBudgetEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EvalBudgetEdit (see GCBO)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PopSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PopSizeEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of PopSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of PopSizeEdit as a double


% --- Executes during object creation, after setting all properties.
function PopSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopSizeEdit (see GCBO)
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AddParamsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to AddParamsEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of AddParamsEdit as text
%        str2double(get(hObject,'String')) returns contents of AddParamsEdit as a double


% --- Executes during object creation, after setting all properties.
function AddParamsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AddParamsEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumberOfDecisionVariablesEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NumberOfDecisionVariablesEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of NumberOfDecisionVariablesEdit as text
%        str2double(get(hObject,'String')) returns contents of NumberOfDecisionVariablesEdit as a double


% --- Executes during object creation, after setting all properties.
function NumberOfDecisionVariablesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberOfDecisionVariablesEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BoundsLowerIEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BoundsLowerIEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of BoundsLowerIEdit as text
%        str2double(get(hObject,'String')) returns contents of BoundsLowerIEdit as a double


% --- Executes during object creation, after setting all properties.
function BoundsLowerIEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BoundsLowerIEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BoundsUpperIEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BoundsUpperIEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of BoundsUpperIEdit as text
%        str2double(get(hObject,'String')) returns contents of BoundsUpperIEdit as a double


% --- Executes during object creation, after setting all properties.
function BoundsUpperIEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BoundsUpperIEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DecVarSplitIEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DecVarSplitIEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of DecVarSplitIEdit as text
%        str2double(get(hObject,'String')) returns contents of DecVarSplitIEdit as a double


% --- Executes during object creation, after setting all properties.
function DecVarSplitIEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DecVarSplitIEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DecVarSplitIIEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DecVarSplitIIEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of DecVarSplitIIEdit as text
%        str2double(get(hObject,'String')) returns contents of DecVarSplitIIEdit as a double


% --- Executes during object creation, after setting all properties.
function DecVarSplitIIEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DecVarSplitIIEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DecVarSplitIIIEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DecVarSplitIIIEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of DecVarSplitIIIEdit as text
%        str2double(get(hObject,'String')) returns contents of DecVarSplitIIIEdit as a double


% --- Executes during object creation, after setting all properties.
function DecVarSplitIIIEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DecVarSplitIIIEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EncodingEdit_Callback(hObject, eventdata, handles)
% hObject    handle to EncodingEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of EncodingEdit as text
%        str2double(get(hObject,'String')) returns contents of EncodingEdit as a double


% --- Executes during object creation, after setting all properties.
function EncodingEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EncodingEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RecordAllMetricsButton.
function RecordAllMetricsButton_Callback(hObject, eventdata, handles)
% hObject    handle to RecordAllMetricsButton (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of RecordAllMetricsButton


% --- Executes on button press in DisplayPlotsButton.
function DisplayPlotsButton_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayPlotsButton (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of DisplayPlotsButton


function SaveOutputsNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to SaveOutputsNameEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of SaveOutputsNameEdit as text
%        str2double(get(hObject,'String')) returns contents of SaveOutputsNameEdit as a double


% --- Executes during object creation, after setting all properties.
function SaveOutputsNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveOutputsNameEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in RestartRepsonseButton.
function RestartRepsonseButton_Callback(hObject, eventdata, handles)
% hObject    handle to RestartRepsonseButton (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of RestartRepsonseButton
if handles.RestartRepsonseButton.Value==1
    handles.DynamicResponsePercentageEdit.Visible='off';
    handles.text21.Visible='off';
    handles.RandomResponseButton.Value=0;
    handles.MutatedResponseButton.Value=0;
end


% --- Executes on button press in RandomResponseButton.
function RandomResponseButton_Callback(hObject, eventdata, handles)
% hObject    handle to RandomResponseButton (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of RandomResponseButton
if handles.RandomResponseButton.Value==1
    handles.DynamicResponsePercentageEdit.Visible='on';
    handles.text21.Visible='on';
    handles.RestartRepsonseButton.Value=0;
    handles.MutatedResponseButton.Value=0;
end

% --- Executes on button press in MutatedResponseButton.
function MutatedResponseButton_Callback(hObject, eventdata, handles)
% hObject    handle to MutatedResponseButton (see GCBO)
% Hint: get(hObject,'Value') returns toggle state of MutatedResponseButton
if handles.MutatedResponseButton.Value==1
    handles.DynamicResponsePercentageEdit.Visible='on';
    handles.text21.Visible='on';
    handles.RestartRepsonseButton.Value=0;
    handles.RandomResponseButton.Value=0;
end


function NumberOfObjectivesEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NumberOfObjectivesEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of NumberOfObjectivesEdit as text
%        str2double(get(hObject,'String')) returns contents of NumberOfObjectivesEdit as a double


% --- Executes during object creation, after setting all properties.
function NumberOfObjectivesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberOfObjectivesEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DynamicResponsePercentageEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DynamicResponsePercentageEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of DynamicResponsePercentageEdit as text
%        str2double(get(hObject,'String')) returns contents of DynamicResponsePercentageEdit as a double


% --- Executes during object creation, after setting all properties.
function DynamicResponsePercentageEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DynamicResponsePercentageEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BoundsLowerIIEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BoundsLowerIIEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of BoundsLowerIIEdit as text
%        str2double(get(hObject,'String')) returns contents of BoundsLowerIIEdit as a double


% --- Executes during object creation, after setting all properties.
function BoundsLowerIIEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BoundsLowerIIEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BoundsUpperIIEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BoundsUpperIIEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of BoundsUpperIIEdit as text
%        str2double(get(hObject,'String')) returns contents of BoundsUpperIIEdit as a double


% --- Executes during object creation, after setting all properties.
function BoundsUpperIIEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BoundsUpperIIEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BoundsLowerIIIEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BoundsLowerIIIEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of BoundsLowerIIIEdit as text
%        str2double(get(hObject,'String')) returns contents of BoundsLowerIIIEdit as a double


% --- Executes during object creation, after setting all properties.
function BoundsLowerIIIEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BoundsLowerIIIEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BoundsUpperIIIEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BoundsUpperIIIEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of BoundsUpperIIIEdit as text
%        str2double(get(hObject,'String')) returns contents of BoundsUpperIIIEdit as a double


% --- Executes during object creation, after setting all properties.
function BoundsUpperIIIEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BoundsUpperIIIEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
 
 
return



function DynamicOnsetDelayEdit_Callback(hObject, eventdata, handles)
% hObject    handle to DynamicOnsetDelayEdit (see GCBO)
% Hints: get(hObject,'String') returns contents of DynamicOnsetDelayEdit as text
%        str2double(get(hObject,'String')) returns contents of DynamicOnsetDelayEdit as a double
n_changes=30;
handles.EvalBudgetEdit.String=num2str((str2double(handles.DynamicOnsetDelayEdit.String)+(n_changes*str2double(handles.TChangeFrequencyEdit.String)))*str2double(handles.PopSizeEdit.String));


% --- Executes during object creation, after setting all properties.
function DynamicOnsetDelayEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DynamicOnsetDelayEdit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in Parameter1SelectMenu.
function Parameter1SelectMenu_Callback(hObject, eventdata, handles)
% hObject    handle to Parameter1SelectMenu (see GCBO)
% Hints: contents = cellstr(get(hObject,'String')) returns Parameter1SelectMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Parameter1SelectMenu

%%%%%%%%%% ---- REMOVAL FROM OTHER DROPDOWN MENU --- %%%%%%%%%% (Needs fixing)
% ParameterList={'t_change_frequency','t_change_severity',...
%                'Dynamic Onset Delay','Population Size',...
%                'Dynamic Response Percentage','Number of Decision Variables'};
% exc_ind=1:length(ParameterList); 
% if isempty(handles.Parameter1SelectMenu.String{1})==1
%     exc_ind=exc_ind(exc_ind~=(handles.Parameter1SelectMenu.Value-1));
%     handles.Parameter1SelectMenu.String=ParameterList; handles.Parameter1SelectMenu.Value=handles.Parameter1SelectMenu.Value-1;
% else
%     exc_ind=exc_ind(exc_ind~=(handles.Parameter1SelectMenu.Value));
% end
% handles.Parameter2SelectMenu.String=ParameterList(exc_ind);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes during object creation, after setting all properties.
function Parameter1SelectMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Parameter1SelectMenu (see GCBO)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function BulkParameterRange1Edit_Callback(hObject, eventdata, handles)
% hObject    handle to BulkParameterRange1Edit (see GCBO)
% Hints: get(hObject,'String') returns contents of BulkParameterRange1Edit as text
%        str2double(get(hObject,'String')) returns contents of BulkParameterRange1Edit as a double


% --- Executes during object creation, after setting all properties.
function BulkParameterRange1Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BulkParameterRange1Edit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Parameter2SelectMenu.
function Parameter2SelectMenu_Callback(hObject, eventdata, handles)
% hObject    handle to Parameter2SelectMenu (see GCBO)
% Hints: contents = cellstr(get(hObject,'String')) returns Parameter2SelectMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Parameter2SelectMenu

%%%%%%%%%% ---- REMOVAL FROM OTHER DROPDOWN MENU --- %%%%%%%%%% (Needs fixing)
% ParameterList={'t_change_frequency','t_change_severity',...
%                'Dynamic Onset Delay','Population Size',...
%                'Dynamic Response Percentage','Number of Decision Variables'};
% exc_ind=1:length(ParameterList); 
% if isempty(handles.Parameter2SelectMenu.String{1})==1
%     exc_ind=exc_ind(exc_ind~=(handles.Parameter2SelectMenu.Value-1));
%     handles.Parameter2SelectMenu.String=ParameterList; handles.Parameter2SelectMenu.Value=handles.Parameter2SelectMenu.Value-1;
% else
%     exc_ind=exc_ind(exc_ind~=(handles.Parameter2SelectMenu.Value));
% end
% handles.Parameter1SelectMenu.String=ParameterList(exc_ind);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% --- Executes during object creation, after setting all properties.
function Parameter2SelectMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Parameter2SelectMenu (see GCBO)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BulkParameterRange2Edit_Callback(hObject, eventdata, handles)
% hObject    handle to BulkParameterRange2Edit (see GCBO)
% Hints: get(hObject,'String') returns contents of BulkParameterRange2Edit as text
%        str2double(get(hObject,'String')) returns contents of BulkParameterRange2Edit as a double


% --- Executes during object creation, after setting all properties.
function BulkParameterRange2Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BulkParameterRange2Edit (see GCBO)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BulkExperimentRunButton.
function BulkExperimentRunButton_Callback(hObject, eventdata, handles)
% hObject    handle to BulkExperimentRunButton (see GCBO)
 
addpath(genpath('Metrics'));
savepath
cla(handles.axes6);
handles.BulkToggleButton.Value=1;
% axis(handles.ProgressBarAxes,'normal'); 
% handles.ProgressBarAxes.Visible='on'; hold(handles.ProgressBarAxes,'off')
% handles.ProgressBarAxes.Position=[0.082,0.885,0.809,0.065];

%Load Parameter ranges
pr1=handles.BulkParameterRange1Edit.String;
pr2=handles.BulkParameterRange2Edit.String;

pr1(pr1=='[')=''; pr1(pr1==']')=''; eval(['pr1=[' pr1 '];'])
pr2(pr2=='[')=''; pr2(pr2==']')=''; eval(['pr2=[' pr2 '];'])

firstLoopRange=length(pr1); secondLoopRange=length(pr2);

%Identify parameter labels and assign to variables
pr1_label=handles.Parameter1SelectMenu.String{handles.Parameter1SelectMenu.Value};
pr2_label=handles.Parameter2SelectMenu.String{handles.Parameter2SelectMenu.Value};

OutputUpdateFlags=zeros(1,6);
               
               
if strcmp(pr1_label,'Population Size')==1; ParamPopSize=pr1; OutputUpdateFlags(1)=1;
elseif strcmp(pr2_label,'Population Size')==1; ParamPopSize=pr2; OutputUpdateFlags(1)=2;
else ParamPopSize=str2double(handles.PopSizeEdit.String); end

if strcmp(pr1_label,'Dynamic Response Percentage')==1; ParamDynamicResponsePercentage=pr1; OutputUpdateFlags(2)=1;
elseif strcmp(pr2_label,'Dynamic Response Percentage')==1; ParamDynamicResponsePercentage=pr2; OutputUpdateFlags(2)=2;
else ParamDynamicResponsePercentage=str2double(handles.DynamicResponsePercentageEdit.String); end

if strcmp(pr1_label,'t_change_severity')==1; ParamChangeMagnitude=pr1; OutputUpdateFlags(3)=1;
elseif strcmp(pr2_label,'t_change_severity')==1; ParamChangeMagnitude=pr2; OutputUpdateFlags(3)=2;
else ParamChangeMagnitude=str2double(handles.TChangeMagnitudeEdit.String); end

if strcmp(pr1_label,'t_change_frequency')==1;ParamChangeFrequency=pr1; OutputUpdateFlags(4)=1;
elseif strcmp(pr2_label,'t_change_frequency')==1; ParamChangeFrequency=pr2; OutputUpdateFlags(4)=2;
else ParamChangeFrequency=str2double(handles.TChangeFrequencyEdit.String); end

if strcmp(pr1_label,'Dynamic Onset Delay')==1; ParamDynamicOnsetDelay=pr1; OutputUpdateFlags(5)=1;
elseif strcmp(pr2_label,'Dynamic Onset Delay')==1; ParamDynamicOnsetDelay=pr2; OutputUpdateFlags(5)=2;
else ParamDynamicOnsetDelay=str2double(handles.DynamicOnsetDelayEdit.String); end

if strcmp(pr1_label,'Number of Decision Variables')==1; ParamDecisionVariableNumber=pr1; OutputUpdateFlags(6)=1;
elseif strcmp(pr2_label,'Number of Decision Variables')==1; ParamDecisionVariableNumber=pr2; OutputUpdateFlags(6)=2;
else ParamDecisionVariableNumber=str2double(handles.NumberOfDecisionVariablesEdit.String); end

%Create Output data table
OutputDataTable=cell(length(pr1),length(pr2));
%NOTE: there is currently some repeated data writing in the following loop:
%a more efficient version is in development

%Start Progress Bar
cla(handles.ProgressBarAxes); 
axes(handles.ProgressBarAxes); hold(handles.ProgressBarAxes,'on')
set(gca,'XTick',[],'YTick',[],'Box','on'); 
% ylim(gca,[0.9975 1.0025]); xlim(gca,[0 1]); 
% handles.ProgressBarAxes.Position=handles.ProgressBarAxes.Position-[0 0.05 0 0];
%Pass to algorithm
for p1ind=1:length(ParamPopSize)
    for p2ind=1:length(ParamDynamicResponsePercentage)
        for p3ind=1:length(ParamChangeMagnitude)
            for p4ind=1:length(ParamChangeFrequency)
                for p5ind=1:length(ParamDynamicOnsetDelay)
                    for p6ind=1:length(ParamDecisionVariableNumber)
                        disp(['Starting ' pr1_label ' ' num2str(pr1(eval(['p' num2str(find(OutputUpdateFlags==1)) 'ind']))) ' and ' pr2_label ' ' num2str(pr2(eval(['p' num2str(find(OutputUpdateFlags==2)) 'ind']))) ' @' char(datetime)])
                        
                        axes(handles.axes1)
                        %Load in all problem, algorithm and plotting parameters:
                        n_changes=30; %A GUI input will be added for this in future
                        EvalBudget=(str2double(handles.DynamicOnsetDelayEdit.String)+(n_changes*ParamChangeFrequency(p4ind)))*ParamPopSize(p1ind);
                        A1=ALGORITHM(handles.AlgorithmMenu.String{handles.AlgorithmMenu.Value},[str2double(handles.AddParamsEdit.String) 0 0],ParamPopSize(p1ind),EvalBudget); 
                        A1.DrawFlag=handles.DisplayPlotsButton.Value; if A1.DrawFlag==1; cla; end
                        A1.SaveDataFlag=handles.SaveOutputsCheckbox.Value;
                        A1.AllMetricsFlag=handles.RecordAllMetricsButton.Value;

                        if handles.RandomResponseButton.Value==1; DR=1;
                        elseif handles.MutatedResponseButton.Value==1; DR=2;
                        elseif handles.RestartRepsonseButton.Value==1; DR=3;
                        else; DR=0; end
                        A1.Dynamic_Response=[DR ParamDynamicResponsePercentage(p2ind)];

                        DecVarsSplit_alt=[];
                        if strcmp(handles.DecVarSplitIIEdit.Visible,'on')==1; DecVarsSplit_alt=[DecVarsSplit_alt str2double(handles.DecVarSplitIIEdit.String)]; end
                        if strcmp(handles.DecVarSplitIIIEdit.Visible,'on')==1; DecVarsSplit_alt=[DecVarsSplit_alt str2double(handles.DecVarSplitIIIEdit.String)]; end
                        Time_Units_String='generations'; if handles.TChangeFrequencyEvaluationsButton.Value==1; Time_Units_String='evaluations'; end
                        T_Loop_Behaviour='mirror'; if handles.TRangeCycleButton.Value==1; T_Loop_Behaviour='cycle'; end

                        VariableHandles={'DecVarsSplit','t_step_size','t_change_time_units','t_change_frequency','t_range','t_loop_behaviour','dynamic_onset_delay'};
                        P1=eval([handles.ProblemMenu.String{handles.ProblemMenu.Value} '(handles.EncodingEdit.String, ParamDecisionVariableNumber(p6ind), str2double(handles.NumberOfObjectivesEdit.String),'...
                               'VariableHandles{1},      [str2double(handles.DecVarSplitIEdit.String) DecVarsSplit_alt],'...
                               'VariableHandles{2},      ParamChangeMagnitude(p3ind),'... 
                               'VariableHandles{3},      Time_Units_String,'...
                               'VariableHandles{4},      ParamChangeFrequency(p4ind),'...
                               'VariableHandles{5},      [str2double(handles.TRangeLowerEdit.String) str2double(handles.TRangeUpperEdit.String)],'...
                               'VariableHandles{6},      T_Loop_Behaviour,'...
                               'VariableHandles{7},      ParamDynamicOnsetDelay(p5ind));']);

                        P1.ShowParetoFrontFlag=handles.PlotParetoFrontButton.Value;

                        [A1,P1,Population]=A1.startAlgorithm(P1);
                        
                        %%%%%%%%%%      Measurement being saved        %%%%%%%%%%%
                        %Hypervolume Difference (concatenated repeats version)
                        t_last_inds=[];
                        unique_tStates=unique(A1.metrics.tState);
                        for i=1:length(unique_tStates); t_last_inds=[t_last_inds find(A1.metrics.tState==unique_tStates(i),1,'last')]; end
            %             eval(['x_' num2str(mag_ind) '=[x_' num2str(mag_ind) ' abs(A1.metrics.PerfectHV(t_last_inds)-A1.metrics.HV(t_last_inds))];'])
                        OutputData=abs(A1.metrics.PerfectHV(t_last_inds)-A1.metrics.HV(t_last_inds));
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                        if OutputUpdateFlags(6)==1
                            OutputDataTable{p6ind,eval(['p' num2str(find(OutputUpdateFlags==2)) 'ind'])}=OutputData;
                        elseif OutputUpdateFlags(6)==2
                            OutputDataTable{eval(['p' num2str(find(OutputUpdateFlags==1)) 'ind']),p6ind}=OutputData;
                        end
                        save('tempdata_heatmap.mat','OutputDataTable','OutputData','pr1','pr2','pr1_label','pr2_label')
                        
                        
                        %Update Progress Bar
                        axes(handles.ProgressBarAxes)
                        outer=min(find(OutputUpdateFlags>0));
                        inner=max(find(OutputUpdateFlags>0));
                        eval(['prog=(((p' num2str(outer) 'ind-1)*length(pr' num2str(OutputUpdateFlags(inner)) '))+p' num2str(inner) 'ind)/(length(pr1)*length(pr2));'])
                        plot(gca,[0 prog],[0.5 0.5],'k','LineWidth',25);
%                         set(gca,'XColor',[1 1 1],'YColor',[1 1 1],'XTick',[],'YTick',[]); ylim(gca,[0.9975 1.0025]); xlim(gca,[0 1]); hold(gca,'on')

                    end %p6ind loop
                    
                    if OutputUpdateFlags(5)==1
                        OutputDataTable{p5ind,eval(['p' num2str(find(OutputUpdateFlags==2)) 'ind'])}=OutputData;
                    elseif OutputUpdateFlags(5)==2
                        OutputDataTable{eval(['p' num2str(find(OutputUpdateFlags==1)) 'ind']),p5ind}=OutputData;
                    end
                    save('tempdata_heatmap.mat','OutputDataTable','OutputData','pr1','pr2','pr1_label','pr2_label')
                end %p5ind loop
                
                if OutputUpdateFlags(4)==1
                    OutputDataTable{p4ind,eval(['p' num2str(find(OutputUpdateFlags==2)) 'ind'])}=OutputData;
                elseif OutputUpdateFlags(4)==2
                    OutputDataTable{eval(['p' num2str(find(OutputUpdateFlags==1)) 'ind']),p4ind}=OutputData;
                end
                save('tempdata_heatmap.mat','OutputDataTable','OutputData','pr1','pr2','pr1_label','pr2_label')
            end %p4ind loop
            
            if OutputUpdateFlags(3)==1
                OutputDataTable{p3ind,eval(['p' num2str(find(OutputUpdateFlags==2)) 'ind'])}=OutputData;
            elseif OutputUpdateFlags(3)==2
                OutputDataTable{eval(['p' num2str(find(OutputUpdateFlags==1)) 'ind']),p3ind}=OutputData;
            end
            save('tempdata_heatmap.mat','OutputDataTable','OutputData','pr1','pr2','pr1_label','pr2_label')
        end %p3ind loop
        
        if OutputUpdateFlags(2)==1
            OutputDataTable{p2ind,eval(['p' num2str(find(OutputUpdateFlags==2)) 'ind'])}=OutputData;
        elseif OutputUpdateFlags(2)==2
            OutputDataTable{eval(['p' num2str(find(OutputUpdateFlags==1)) 'ind']),p2ind}=OutputData;
        end
        save('tempdata_heatmap.mat','OutputDataTable','OutputData','pr1','pr2','pr1_label','pr2_label')
    end %p2ind loop
    
    if OutputUpdateFlags(1)==1
        OutputDataTable{p1ind,eval(['p' num2str(find(OutputUpdateFlags==2)) 'ind'])}=OutputData;
    elseif OutputUpdateFlags(1)==2
        OutputDataTable{eval(['p' num2str(find(OutputUpdateFlags==1)) 'ind']),p1ind}=OutputData;
    end
    save('tempdata_heatmap.mat','OutputDataTable','OutputData','pr1','pr2','pr1_label','pr2_label')
end %p1ind loop


disp('Finished.')
%Collate results OutputDataTable (temp save them) and plot
axes(handles.axes6); cla; hold on
hmd=zeros(size(OutputDataTable))';
for i=1:length(pr1)
    for j=1:length(pr2)
        hmd(j,i)=mean(mean(OutputDataTable{i,j}(2:end,:))); %The (2:end) indexing ignores the first interval where the dynamic onset delay is enacted and t=0
    end
end


bxs=[1/length(pr1) (1/length(pr1))*(length(pr1)/length(pr2))];
xcurr=0; ycurr=1;
% xlim([0 1]); ylim([0 1])
for i=1:length(pr2)
    for j=1:length(pr1)
        cind=(1.*ones(1,3))-hmd(i,j);
        arx=[xcurr xcurr+bxs(1) xcurr+bxs(1) xcurr];
        ary=[ycurr ycurr ycurr-bxs(2) ycurr-bxs(2)];
        fill(gca,arx,ary,cind,'EdgeColor',cind); 
        xcurr=xcurr+bxs(1);
    end
    ycurr=ycurr-bxs(2);
    xcurr=0;
    drawnow
end

% set(gca,'YTick',[bxs(2)/2:bxs(2):1],'YTickLabel',num2str(flip(t_magnitude_range)'),'Box','on','LineWidth',4)
% set(gca,'FontSize',12,'XTick',[bxs(1)/2:bxs(1):1],'XTickLabel',num2str(t_frequency_range'))
% 
% %Small version
% set(gcf,'Position',[223.4000  342.6000  544.0000  362.4000])
set(gca,'YTick',[bxs(2)/2:(bxs(2)):1],'YTickLabel',num2str(flip(pr2)'))
set(gca,'XTick',[bxs(1)/2:bxs(1):((length(pr1)*bxs(1))+(bxs(1)/2))],'XTickLabel',num2str(pr1'))

% set(gcf,'Colormap','Gray')
cbar=colorbar(gca,'Limits',[1-max(max(hmd)) 1]); colormap('gray'); temp=num2str(1-cbar.Ticks'); temp2={}; for i=1:size(temp,1); temp2=[temp2; strtrim(temp(i,:))]; end
cbar.TickLabels=temp2;
titlestrings=[A1.name ' on ' P1.name];
xlabel(pr1_label)
ylabel(pr2_label)

if handles.SaveOutputsCheckbox.Value==1
    ObjectiveFigure=handles.axes1; HeatmapFigure=handles.axes6;
    if isempty(handles.SaveOutputsNameEdit.String)==1
        timestamp=datestr(now); timestamp=timestamp(end-7:end); timestamp(timestamp==':')='_';
        savefilename=['SavedBulkOutputs_' timestamp '.mat'];
    else
        savefilename=[handles.SaveOutputsNameEdit.String '.mat'];
    end
    save(savefilename,'ObjectiveFigure', 'HeatmapFigure', 'OutputDataTable', 'pr1', 'pr1_label', 'pr2', 'pr2_label', 'A1', 'P1')
    disp(['Saved as ' savefilename])
end

 


% --- Executes on button press in BulkToggleButton.
function BulkToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to BulkToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BulkToggleButton


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6
