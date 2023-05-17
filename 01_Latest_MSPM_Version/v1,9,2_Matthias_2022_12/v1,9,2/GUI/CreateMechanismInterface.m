function varargout = CreateMechanismInterface(varargin)
    % CREATEMECHANISMINTERFACE MATLAB code for CreateMechanismInterface.fig
    %      CREATEMECHANISMINTERFACE, by itself, creates a new CREATEMECHANISMINTERFACE or raises the existing
    %      singleton*.
    %
    %      H = CREATEMECHANISMINTERFACE returns the handle to a new CREATEMECHANISMINTERFACE or the handle to
    %      the existing singleton*.
    %
    %      CREATEMECHANISMINTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in CREATEMECHANISMINTERFACE.M with the given input arguments.
    %
    %      CREATEMECHANISMINTERFACE('Property','Value',...) creates a new CREATEMECHANISMINTERFACE or raises
    %      the existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before CreateMechanismInterface_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to CreateMechanismInterface_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help CreateMechanismInterface

    % Last Modified by GUIDE v2.5 13-Dec-2018 14:29:58

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @CreateMechanismInterface_OpeningFcn, ...
        'gui_OutputFcn',  @CreateMechanismInterface_OutputFcn, ...
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
end

% --- Executes just before CreateMechanismInterface is made visible.
function CreateMechanismInterface_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to CreateMechanismInterface (see VARARGIN)

    % Choose default command line output for CreateMechanismInterface
    handles.output = hObject;
    switch length(varargin{1}.vars)
        case 0 % Create New
            handles.iType = [];
            handles.iData = [];
        case 2 % Modify Existing
            % assume it is a "Holder"
            handles.iType = varargin{1}.vars{1};
            handles.iData = varargin{1}.vars{2};
        case 1 % ???
            handles.iType = varargin{1}.vars{1};
            handles.iData = [];
    end
    handles.outData = varargin{1};
    handles.DataEstablished = false;

    % Setup MechType
    if ~isempty(handles.iType)
        % Find the index
        i = FindStringInCell(LinRotMechanism.Source,handles.iType);
        if i ~= 0
            set(handles.MechType,'Value',i);
        else
            % Type not found, erase handles.iData & handles.iType
            fprintf(['XXX Type not found in registry, make sure to include ' ...
                'support for "' handles.iType '" if you want to use it. XXX\n']);
            handles.iType = [];
            handles.iData = [];
        end
    end

    % Setup Data
    if ~isempty(handles.iData)
        % Make sure iType is valid
        i = FindStringInCell(LinRotMechanism.Source,handles.iType);
        if i ~= 0
            set(handles.PropertiesTable,'Data',handles.iData);
        else
            % Type not found, erase handles.iData & handles.iType
            fprintf(['XXX Type not found in registry, make sure to include ' ...
                'support for "' handles.iType '" if you want to use it. XXX\n']);
            handles.iType = [];
            handles.iData = [];
        end
        handles.DataEstablished = true;
    else
        set(handles.PropertiesTable,'Visible','off');
        handles.DataEstablished = false;
    end

    % Other things
    handles.MODE = '';

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes CreateMechanismInterface wait for user response (see UIRESUME)
    % uiwait(handles.TheWindow);
end

% --- Outputs from this function are returned to the command line.
function varargout = CreateMechanismInterface_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    % contents = cellstr(get(handles.MechType,'String'));
    % varargout{1} = contents{get(handles.MechType,'Value')};
    % varargout{2} = get(handles.PropertiesTable,'Data');\
end

% --- Executes on selection change in MechType.
function MechType_Callback(hObject, eventdata, handles)
    contents = cellstr(get(hObject,'String'));
    Type = contents{get(hObject,'Value')};
    if ~handles.DataEstablished
        [Data, Instructions] = ...
            LinRotMechanism.GetPropertyTableSource(Type);
        handles.DataEstablished = true;
    else
        [Data, Instructions] = ...
            LinRotMechanism.GetPropertyTableSource(...
            Type,...
            get(handles.PropertiesTable,'Data'));
    end
    set(handles.PropertiesTable,'Visible','on');
    set(handles.PropertiesTable,'Data',Data);
    handles.PropertiesTable.ColumnEditable = true(1,size(Data,2));
    handles.PropertiesTable.ColumnFormat = cell(1,size(Data,2));
    set(handles.Instructions,'String',Instructions);
    EstablishWidths(handles);
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function MechType_CreateFcn(hObject, eventdata, handles)
    set(hObject,'String',LinRotMechanism.Source);
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes during object creation, after setting all properties.
function PropertiesTable_CreateFcn(hObject, eventdata, handles)
end

% --- Executes when entered data in editable cell(s) in PropertiesTable.
function PropertiesTable_CellEditCallback(hObject, eventdata, handles)
    % hObject    handle to PropertiesTable (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
    %	Indices: row and column indices of the cell(s) edited
    %	PreviousData: previous data for the cell(s) edited
    %	EditData: string(s) entered by the user
    %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
    %	Error: error string when failed to convert EditData to appropriate value for Data
    % handles    structure with handles and user data (see GUIDATA)
    if eventdata.Indices(1) == 1
        Data = get(hObject,'Data');
        Data{eventdata.Indices(1),eventdata.Indices(1)} = eventdata.PreviousData;
        set(hObject,'Data',Data);
        fprintf('XXX You cannot edit column headers, no matter how hard you try. XXX\n');
    end
end

function EstablishWidths(handles)
    Source = get(handles.PropertiesTable,'Data');
    for col = size(Source,2):-1:1
        Widths{col} = length(Source{1,col})*6;
    end
    set(handles.PropertiesTable,'ColumnWidth',Widths);

    % Sum of widths
    totalWidth = 0;
    for i = 1:length(Widths)
        totalWidth = totalWidth + Widths{i};
    end

    PosInst = get(handles.Instructions,'Position');
    PosTable = get(handles.PropertiesTable,'Position');
    PosFrame = get(handles.PropertiesFrame,'Position');
    PosWin = get(handles.TheWindow,'Position');

    % Table Size
    PosTable(3) = totalWidth+32;
    set(handles.PropertiesTable,'Position',PosTable);

    % Instructions Size
    PosInst(3) = min([400 PosTable(3)]);
    set(handles.Instructions,'Position',PosInst);

    % Frame Size
    PosFrame(3) = PosTable(3) + 2*PosTable(1);
    set(handles.PropertiesFrame,'Position',PosFrame);

    % Window Size
    PosWin(3) = PosTable(3) + 4*PosTable(1);
    set(handles.TheWindow,'Position',PosWin);
    guidata(handles.TheWindow, handles);
end

function Ok_Callback(~, ~, handles)
    Types = get(handles.MechType,'String');
    Type = Types{get(handles.MechType,'Value')};
    Source = get(handles.PropertiesTable,'Data');
    handles.outData.vars = {Type, Source};
    close(handles.TheWindow);
    % Close it.
end

% --- Executes when selected cell(s) is changed in PropertiesTable.
function PropertiesTable_CellSelectionCallback(hObject, eventdata, handles)
    if ~isempty(eventdata.Indices)
        row = eventdata.Indices(1);
        if row ~= 1
            switch handles.MODE
                case 'delete'
                    Data = get(handles.PropertiesTable,'Data');
                    NewData = cell(size(Data)-[1 0]);
                    k = 0;
                    for i = 1:size(Data,1)
                        if i ~= row
                            for j = 1:size(Data,2)
                                NewData{i-k,j} = Data{i,j};
                            end
                        else
                            k = 1;
                        end
                    end
                    set(handles.PropertiesTable,'Data',NewData);
                case 'copy'
                    Data = get(handles.PropertiesTable,'Data');
                    NewData = cell(size(Data)+[1 0]);
                    for i = 1:size(Data,1)
                        for j = 1:size(Data,2)
                            NewData{i,j} = Data{i,j};
                        end
                    end
                    for i = 1:size(Data,2)
                        NewData{size(Data,1)+1,i} = Data{row,i};
                    end
                    set(handles.PropertiesTable,'Data',NewData);
                otherwise
            end
        end
    end
end

% --- Executes on button press in DeleteOnClick.
function DeleteOnClick_Callback(hObject, eventdata, handles)
    if strcmp(handles.MODE,'delete')
        handles.MODE = '';
        set(hObject,'BackgroundColor',[0.94 0.94 0.94]);
    else
        handles.MODE = 'delete';
        set(hObject,'BackgroundColor',[0 1 0]);
        set(handles.CopyOnClick,'BackgroundColor',[0.94 0.94 0.94]);
    end
    guidata(hObject, handles);
end

% --- Executes on button press in CopyOnClick.
function CopyOnClick_Callback(hObject, eventdata, handles)
    if strcmp(handles.MODE,'copy')
        handles.MODE = '';
        set(hObject,'BackgroundColor',[0.94 0.94 0.94]);
    else
        handles.MODE = 'copy';
        set(hObject,'BackgroundColor',[0 1 0]);
        set(handles.DeleteOnClick,'BackgroundColor',[0.94 0.94 0.94]);
    end
    guidata(hObject, handles);
end

% --- Executes on button press in AddBlankRow.
function AddBlankRow_Callback(hObject, eventdata, handles)
    handles.MODE = '';
    set(handles.CopyOnClick,'BackgroundColor',[0.94 0.94 0.94]);
    set(handles.DeleteOnClick,'BackgroundColor',[0.94 0.94 0.94]);
    Data = get(handles.PropertiesTable,'Data');
    Data = AddRow(Data,1);
    set(handles.PropertiesTable,'Data',Data);
    guidata(hObject, handles);
end
