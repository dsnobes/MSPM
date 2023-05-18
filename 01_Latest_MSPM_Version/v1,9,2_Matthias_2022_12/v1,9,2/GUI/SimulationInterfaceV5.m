function varargout = SimulationInterfaceV5(varargin)
    % SIMULATIONINTERFACEV5 MATLAB code for SimulationInterfaceV5.fig
    %      SIMULATIONINTERFACEV5, by itself, creates a new SIMULATIONINTERFACEV5 or raises the existing
    %      singleton*.
    %
    %      H = SIMULATIONINTERFACEV5 returns the handle to a new SIMULATIONINTERFACEV5 or the handle to
    %      the existing singleton*.
    %
    %      SIMULATIONINTERFACEV5('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in SIMULATIONINTERFACEV5.M with the given input arguments.
    %
    %      SIMULATIONINTERFACEV5('Property','Value',...) creates a new SIMULATIONINTERFACEV5 or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before SimulationInterfaceV5_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to SimulationInterfaceV5_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help SimulationInterfaceV5

    % Last Modified by GUIDE v2.5 09-Feb-2022 13:04:51

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @SimulationInterfaceV5_OpeningFcn, ...
        'gui_OutputFcn',  @SimulationInterfaceV5_OutputFcn, ...
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

% --- Executes just before SimulationInterfaceV5 is made visible.
function SimulationInterfaceV5_OpeningFcn(hObject, ~, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to SimulationInterfaceV5 (see VARARGIN)

    % UIWAIT makes SimulationInterfaceV5 wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

    %% Choose default command line output for SimulationInterfaceV5
    handles.output = hObject;

    %% Generate space for mouse events
    handles.MODE = '';
    handles.SelectCon = Connection.empty;
    handles.IndexC = 1;
    handles.SelectBod = Body();
    handles.IndexB = 1;
    handles.SelectGroup = Group.empty;
    handles.IndexG = 1;

    %% Set Initial Values for Display Options
    handles.InterGroupDistance = 0.05;
    handles.ClickTolerance = 0.1;

    %% Generate Default Model
    handles.Model = Model();
    handles.Model.AxisReference = handles.GUI;
    handles.corner_points = [];
    handles.SimulationParameters = cell(0);
    DistributeGroup(handles);
    show_Model(handles);

    %% Object Properties
    handles.SData = SelectionListData();
    handles.SData.Code = '';
    handles.SData.ListObjs = ListObj.empty;
    handles.DropDownMode = 'Default';
    updateSelectionList(handles);

    %% Optimization Stuff
    handles.OptimizationStudyIndex = 0;

    %% Show Options
    set(handles.showGroups,'Value',handles.Model.showGroups);
    set(handles.showBodies,'Value',handles.Model.showBodies);
    set(handles.showConnections,'Value',handles.Model.showConnections);
    set(handles.showLeaks,'Value',handles.Model.showLeaks);
    set(handles.showBridges,'Value',handles.Model.showBridges);
    set(handles.showInterConnections,'Value',handles.Model.showInterConnections);
    set(handles.showEnvironmentConnections,'Value',handles.Model.showEnvironmentConnections);
    set(handles.showNodes,'Value',handles.Model.showNodes);
    set(handles.showSensors,'Value',handles.Model.showSensors);
    set(handles.showRelations,'Value',handles.Model.showRelations);
    set(handles.RelationMode,'String','On')
    handles.Model.RelationOn = true;

    %% Update handles structure
    guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = SimulationInterfaceV5_OutputFcn(hObject, ~, handles) %#ok<INUSL>
    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

%% General button codes
function GUI_ButtonDownFcn(hObject, ~, h)
    C = get(hObject,'Currentpoint');
    C = C(1,1:2);
    if isempty(h.Model.ActiveGroup)
        % Select the group based on where the user clicked
        h.Model.FindGroup(C);
    end
    switch h.MODE
        case 'InsertBody'
            % Select 4 connections
            switch get(gcf,'SelectionType')
                case 'normal'
                    L = true;
                case 'alt'
                    L = false;
                case 'extend'
                    L = false;
                otherwise
                    L = true;
            end
            found = false;
            %% Get round specific information
            switch h.IndexC
                case 1
                    DIR = enumOrient.Vertical;
                    prompt = 'New Body Inner Radius 1: ';
                    OFFSET = 0;
                case 2
                    OFFSET = h.SelectCon(1).x;
                    if h.SelectCon(1).Orient == enumOrient.Vertical
                        DIR = enumOrient.Vertical;
                        prompt = 'New Body Radial Thickness: ';
                    else
                        DIR = enumOrient.Horizontal;
                        prompt = 'New Body Vertical Thickness: ';
                    end
                case 3
                    OFFSET = 0;
                    if h.SelectCon(2).Orient == enumOrient.Vertical
                        DIR = enumOrient.Horizontal;
                        prompt = 'New Body Lower Vertical Position: ';
                    else
                        DIR = enumOrient.Vertical;
                        prompt = 'New Body Inner Radius: ';
                    end
                case 4
                    OFFSET = h.SelectCon(3).x;
                    if h.SelectCon(2).Orient == enumOrient.Vertical
                        DIR = enumOrient.Horizontal;
                        prompt = 'New Body Thickness: ';
                    else
                        DIR = enumOrient.Vertical;
                        prompt = 'New Body Radial Thickness: ';
                    end
                otherwise % We are done here
                    found = true;
            end
            
            %% Find connection at click
            if L && found == false % Left Click
                if h.IndexC == 1
                    h.SelectCon(h.IndexC) = ...
                        h.Model.ActiveGroup.FindConnection(C);
                    found = true;
                    fprintf(['Selected Connection: ' ...
                        h.SelectCon(h.IndexC).name '.\n']);
                else
                    Con = h.Model.ActiveGroup.FindConnection(...
                        C,DIR,h.SelectCon(h.IndexC-1));
                    if ~isempty(Con)
                        h.SelectCon(h.IndexC) = Con;
                        fprintf(['Selected Connection: ' ...
                            h.SelectCon(h.IndexC).name '.\n']);
                        found = true;
                    else
                        found = false;
                    end
                end
            end
            
            %% Get user Input
            if found == false
                % Get User Radius Submission
                DIM = '';
                while ~isnumeric(DIM)
                    answer = inputdlg(prompt,'Specify Dimension Window');
                    if ~isempty(answer)
                        DIM = str2double(answer{1});
                    else
                        return;
                    end
                end
                % If this does not match any Group Connection then CreateNew
                found = false;
                for iCon = h.Model.ActiveGroup.Connections
                    if iCon.Orient == DIR && iCon.x == DIM+OFFSET
                        h.SelectCon(h.IndexC) = iCon;
                        found = true;
                    end
                end
                if ~found
                    h.SelectCon(h.IndexC) = Connection(DIM+OFFSET,DIR,h.Model.ActiveGroup);
                end
            end
            
            %% Iterate or finish up
            if h.IndexC == 4
                % Define the body
                matl = [];
                show_Model(h);
                while isempty(matl)
                    [matl, tf] = listdlg(...
                        'PromptString','Select a material type for this new body:',...
                        'SelectionMode','single',...
                        'ListString',Material.Source);
                end
                if tf
                    newBody = Body(...
                        h.Model.ActiveGroup,...
                        h.SelectCon,...
                        Material(Material.Source{matl}));
    %                 if handles.Model.ActiveGroup.isOverlaping(newBody)
    %                     fprintf('XXX New Body overlaps, creation cancelled XXX\n');
    %                     handles.Model.clearHighLighting();
    %                 else
                        h.Model.ActiveGroup.addBody(newBody);
    %                 end
                else
                    fprintf('XXX You must select a material, creation cancelled XXX\n');
                    h.Model.clearHighLighting();
                end
                h.IndexC = 1;
            else
                h.Model.HighLight(h.SelectCon(1:h.IndexC));
                h.IndexC = h.IndexC + 1;
            end
        case 'InsertGroup'
            % Will simply define a vertical Group at the next slot
            % Determine where the user clicked
            C = get(gca,'Currentpoint'); C = C(1,1:2);
            h.Model.addGroup(Group(h.Model,Position(C(1),0,pi/2),[]));
            h.Model.distributeGroup(h.InterGroupDistance);
        case 'InsertBridge'
            % Select 2 horizontal connections and 2 bodies
            if h.IndexC == 1
                if h.IndexB == 1
                    % Picking the first Connection
                    if isempty(h.Model.ActiveGroup)
                        ChangeGroup_Callback(hObject, [], h);
                    end
                    Con = h.Model.ActiveGroup.FindConnection(C);
                    if ~isempty(Con)
                        h.SelectCon(h.IndexC) = Con;
                        h.Model.HighLight(Con);
                        h.IndexC = 2;
                        set(h.message,'String','[click] Select the Foundation Body');
                    end
                end
            elseif h.IndexC == 2
                if h.IndexB == 1
                    % Picking the first Body
                    Bod = h.SelectCon(1).findConnectedBody(C);
                    if ~isempty(Bod)
                        h.SelectBody(h.IndexB) = Bod;
                        h.Model.HighLight(Bod);
                        h.IndexB = 2;
                        set(h.message,'String','[click] Select the Connection for the other body (the Body that may shift)');
                    end
                else
                    % Picking the second Connection
                    ChangeGroup_Callback(hObject, [], h);
                    Con = h.Model.ActiveGroup.FindConnection(C);
                    if ~isempty(Con)
                        h.SelectCon(h.IndexC) = Con;
                        h.Model.HighLight(Con);
                        h.IndexC = 3;
                        set(h.message,'String','[click] Select the associated body');
                    end
                end
            else
                if h.IndexB == 2
                    % Picking the second Body
                    Bod = h.SelectCon(2).findConnectedBody(C);
                    if ~isempty(Bod)
                        % Finish and Create
                        if h.SelectCon(1).Orient == h.SelectCon(2).Orient
                            if h.SelectCon(1).Orient == enumOrient.Vertical
                                prompt = 'Select the height adjustment for body 2 as it is placed around body 1';
                                [~,~,defaultval,~] = h.SelectBody(1).limits(enumOrient.Vertical);
                            else
                                prompt = 'Select the radial offset distance';
                                defaultval = 0;
                            end
                        else
                            prompt = 'Select the vertical center offset for the horizontal face to be up the vertical face';
                            if h.SelectCon(1).Orient == enumOrient.Vertical
                                [~,~,defaultval,~] = h.SelectBody(1).limits(enumOrient.Vertical);
                            else
                                [~,~,defaultval,~] = h.SelectBody(2).limits(enumOrient.Vertical);
                            end
                        end
                        x = inputdlg(prompt,'Specify Bridge Offset',[1, 200],{num2str(defaultval)});
                        % Define the Bridge
                        if ~isempty(x)
                            h.SelectBody(h.IndexB) = Bod;
                            h.Model.HighLight(Bod);
                            h.Model.addBridge(Bridge(...
                                h.SelectBody(1),h.SelectBody(2),...
                                h.SelectCon(1),h.SelectCon(2),str2double(x{1})));
                            h.IndexC = 1;
                            h.IndexB = 1;
                            set(h.message,'String','---');
                        end
                    end
                end
            end
        case 'InsertLeakConnection'
            % Select 2 horizontal connections and 2 bodies/Environments
            Bod = Body.empty;
            if h.IndexB == 1
                % Picking the first Body
                [~, objects] = h.Model.findNearest(C,h.ClickTolerance);
                for obj = objects; if isa(obj{1},'Body'); Bod = obj{1}; break; end; end
                if ~isempty(Bod)
                    h.SelectBody(h.IndexB) = Bod;
                    h.Model.HighLight(Bod);
                    h.IndexB = 2;
                    set(h.message,'String','[click] Select the second body, or click in open space to select the environment');
                end
            elseif h.IndexB == 2
                % Picking the first Body
                [~, objects] = h.Model.findNearest(C,h.ClickTolerance);
                for obj = objects; if isa(obj{1},'Body'); Bod = obj{1}; break; end; end
                if Bod ~= h.SelectBody(1)
                    if ~isempty(Bod)
                        h.SelectBody(h.IndexB) = Bod;
                        h.Model.HighLight(Bod);
                        set(h.message,'String','---');
                        [N,E] = LeakConnection.getParameters();
                        h.Model.addLeakConnection(...
                            LeakConnection(h.SelectBody(1),h.SelectBody(2),N,E));
                    end
                    return;
                end
                % No object was selected, select the environment instead
                set(h.message,'String','---');
                [N,E] = LeakConnection.getParameters();
                h.Model.addLeakConnection(LeakConnection(h.SelectBody(1),h.Model.surroundings,N,E));
            end
        case 'InsertSensor'
            % Select a group
            C = C(1,1:2);
            % Select a body
            [~, objects] = h.Model.findNearest(C,h.ClickTolerance);
            if ~isempty(objects)
                for obj = objects
                    if isa(obj{1},'Body')
                        h.Model.HighLight(obj{1});
                        h.Model.addSensor(Sensor(h.Model,obj{1}));
                    end
                end
            end
        case 'InsertPVoutput'
            % Find, within a radius of confidence, the nearest Body
            C = C(1,1:2);
            [~, objects] = h.Model.findNearest(C,h.ClickTolerance);
            if ~isempty(objects)
                for obj = objects
                    if isa(obj{1},'Body')
                        if obj{1}.matl.Phase == enumMaterial.Gas
                            h.Model.addPVoutput(PVoutput(obj{1}));
                            set(h.message,'String',['PVoutput added to Body: ' obj{1}.name]);
                        else
                            set(h.message,'String','Must select a Gas Body');
                        end
                    end
                end
            end
        case 'InsertNonConnection'
            % Select 2 horizontal connections and 2 bodies
            Bod = Body.empty;
            if h.IndexB == 1
                % Picking the first Body
                [~, objects] = h.Model.findNearest(C,h.ClickTolerance);
                for obj = objects; if isa(obj{1},'Body'); Bod = obj{1}; break; end; end
                if ~isempty(Bod)
                    h.SelectBody(h.IndexB) = Bod;
                    h.Model.HighLight(Bod);
                    h.IndexB = 2;
                    set(h.message,'String','[click] Select the second body, or click in open space to select the environment');
                end
            elseif h.IndexB == 2
                % Picking the first Body
                [~, objects] = h.Model.findNearest(C,h.ClickTolerance);
                for obj = objects; if isa(obj{1},'Body'); Bod = obj{1}; break; end; end
                if Bod ~= h.SelectBody(1)
                    if ~isempty(Bod)
                        h.SelectBody(h.IndexB) = Bod;
                        h.Model.HighLight(Bod);
                        set(h.message,'String','---');
                        h.Model.addNonConnection(...
                            NonConnection(h.SelectBody(1),h.SelectBody(2)));
                    end
                    return;
                end
                % No object was selected, select the environment instead
                set(h.message,'String','---');
                h.Model.addNonConnection(...
                    NonConnection(h.SelectBody(1),h.Model.surroundings));
            end
        case 'InsertCustomMinorLoss'
            % Find, within a radius of confidence, the nearest body
            C = C(1,1:2);
            [~, objects] = h.Model.findNearest(C,h.ClickTolerance);
            if ~isempty(objects)
                for obj = objects
                    if isa(obj{1},'Body')
                        h.SelectBody(h.IndexB) = obj{1};
                        if (h.IndexB == 2)
                            % Finalize Custom Minor Loss
                            h.IndexB = 1;
                            h.Model.addCustomMinorLoss(...
                                CustomMinorLoss(...
                                h.SelectBody(1),...
                                h.SelectBody(2)));
                        end
                        h.IndexB = 2;
                    end
                end
            end
        case 'Select'
            % Find, within a radius of confidence, the nearest...
            %   Body, Group, Connection, Bridge and Leak Connection
            C = C(1,1:2);
            [names, objects] = h.Model.findNearest(C,h.ClickTolerance);
            if ~isempty(names)
                if length(names) > 1
                    [index,tf] = listdlg(...
                        'PromptString','Which Object did you select?',...
                        'ListString',names,...
                        'SelectionMode','single',...
                        'ListSize',[400 250]);
                else
                    index = 1;
                    tf = true;
                end
                if tf
                    h.Model.switchHighLighting(objects{index});
                end
            end
        case 'MultiSelect'
            % Find, within a radius of confidence, the nearest...
            %   Body, Group, Connection, Bridge and Leak Connection
            C = C(1,1:2);
            [names, objects] = h.Model.findNearest(C,h.ClickTolerance);
            if ~isempty(names)
                if length(names) > 1
                    [index,tf] = listdlg(...
                        'PromptString','Which Object did you select?',...
                        'ListString',names,...
                        'SelectionMode','single',...
                        'ListSize',[400 250]);
                else
                    index = 1;
                    tf = true;
                end
                if tf
                    h.Model.HighLight(objects{index});
                end
            end
        case 'InsertRelation'
            % Find, within a radius of confidence, the nearest connection
            C = C(1,1:2);
            [~, objects] = h.Model.findNearest(C,h.ClickTolerance);
            if ~isempty(objects)
                for objcll = objects
                    obj = objcll{1};
                    if isa(obj,'Connection')
                        if h.IndexC == 1 || ...
                                (obj.Orient == h.SelectCon(1).Orient && ...
                                obj.Group == h.SelectCon(1).Group)
                            h.SelectCon(h.IndexC) = obj;
                            if (h.IndexC == 2)
                                % Finalize the new relation
                                % Ask the user about the type
                                names = {
                                    'Constant Offset', ...
                                    'Cross-Section Maintaining', ...
                                    'Zero x Based Scale', ...
                                    'Smallest x Based Scale', ...
                                    'Width Set'};
                                if obj.Orient == enumOrient.Horizontal
                                    names{end+1} = 'Defines Stroke Length';
                                    names{end+1} = 'Defines Piston Length';
                                end
                                for RMan = obj.Group.RelationManagers
                                    if RMan.Orient == obj.Orient; break; end
                                end
                                if ~isempty(RMan)
                                    [Type, tf] = listdlg(...
                                    'PromptString','What type of relationship?',...
                                    'ListString',names,...
                                    'SelectionMode','single',...
                                    'ListSize',[400 250]);
                                switch names{Type}
                                    case 'Constant Offset'
                                        EnumType = enumRelation.Constant;
                                    case 'Cross-Section Maintaining'
                                        EnumType = enumRelation.AreaConstant;
                                    case 'Zero x Based Scale'
                                        EnumType = enumRelation.Scaled;
                                    case 'Smallest x Based Scale'
                                        EnumType = enumRelation.LowestScaled;
                                    case 'Width Set'
                                        EnumType = enumRelation.Width;
                                    case 'Defines Stroke Length'
                                        EnumType = enumRelation.Stroke;
                                    case 'Defines Piston Length'
                                        EnumType = enumRelation.Piston;
                                end
                                if tf
                                    Label = RMan.getLabel(EnumType, ...
                                        h.SelectCon(1), h.SelectCon(2));
                                    if isempty(Label)
                                        Label = getProperName([names{Type} ' Relation']);
                                    end
                                    if isempty(Label); return; end
                                    if EnumType == enumRelation.Stroke || ...
                                            EnumType == enumRelation.Piston
                                        % Ask which mechanism?
                                        objs = h.Model.Converters;
                                        mecs = cell(0);
                                        for index = length(objs):-1:1
                                            mecs{index} = objs(index).name;
                                        end
                                        index = listdlg(...
                                            'ListString',mecs,...
                                            'SelectionMode','single');
                                        if isempty(index)
                                            break;
                                        else
                                            Mech = objs(index).Frames(1);
                                        end
                                    end
                                    switch EnumType
                                        case {enumRelation.Constant, ...
                                                enumRelation.AreaConstant, ...
                                                enumRelation.Scaled, ...
                                                enumRelation.LowestScaled, ...
                                                enumRelation.Width}
                                            success = RMan.addRelation(...
                                                Label, ...
                                                EnumType, ...
                                                h.SelectCon(1), ...
                                                h.SelectCon(2));
                                        case {enumRelation.Stroke, ...
                                                enumRelation.Piston}
                                            % Ask which mechanism?
                                            success = RMan.addRelation(...
                                                Label, ...
                                                EnumType, ...
                                                h.SelectCon(1), ...
                                                h.SelectCon(2), ...
                                                Mech);
                                        otherwise
                                            msgbox(['Selected relation type' ...
                                                ' is not implemented']);
                                            h.IndexC = 1;
                                            break;
                                    end
                                    if ~success
                                        msgbox(['Relationship was not ' ...
                                            'added successfully']);
                                    end
                                    h.IndexC = 1;
                                end
                                end
                                h.IndexC = 1;
                            end
                            h.IndexC = 2;
                        else
                            msgbox(['The two connections must have the ' ...
                                'same orientation.']);
                        end
                    end
                end
            end
        otherwise
    end
    show_Model(h);
    hP = pan(h.output);
    hP.ModeHandle.Blocking = false;
    hP.Enable = 'off';
    updateSelectionList(h);
    guidata(hObject,h);
    drawnow(); pause(0.05);
end

function objs = getButtonObjs(handles)
    objs = [...
            handles.InsertBody ...
            handles.InsertGroup ...
            handles.InsertBridge ...
            handles.InsertLeakConnection ...
            handles.InsertSensor ...
            handles.InsertPVoutput ...
            handles.NonConnection ...
            handles.CustomMinorLoss ...
            handles.InsertRelation ...
            handles.SelectObjects ...
            handles.MultiSelectObjects];
end

function ButtonCore(hObject,Mode,handles,message)
    inactivated = hObject.UserData(1) == 0;
    handles = clearButtons(handles);
    if inactivated
        handles.MODE = Mode;
        show_Model(handles);
        set(handles.message,'String',message);
        hObject.BackgroundColor = [0.33 0.67 0.33];
        hObject.UserData(1) = 1;
    else
        
    end
    show_Model(handles);
    updateSelectionList(handles);
    guidata(hObject, handles);
    drawnow(); pause(0.05);
end

function handles = clearButtons(handles)
    hObjects = getButtonObjs(handles);
    handles.Model.clearHighLighting();
    set(handles.message,'String','---');
    handles.MODE = '';
    for obj = hObjects
        if obj.UserData(1) == 1
            obj.UserData(1) = 0;
            obj.BackgroundColor = [0.94 0.94 0.94];
            break;
        end
    end
    handles.IndexC = 1;
    handles.IndexG = 1;
    handles.IndexB = 1;
    handles.SelectCon = Connection.empty;
    handles.SelectBody = Body.empty;
end

%% Individual button codes
function InsertBody_CreateFcn(hObject, ~, ~)
    hObject.UserData(1) = 0;
end

function InsertBody_Callback(hObject, ~, handles)
    ButtonCore(hObject,'InsertBody',handles,{'[left click] To select a connection.','[right click] to prescribe a dimension.'});
end

function InsertGroup_CreateFcn(hObject, ~, ~)
    hObject.UserData(1) = 0;
end

function InsertGroup_Callback(hObject, ~, handles)
    ButtonCore(hObject,'InsertGroup',handles,'[click] To select a position to place a new group.');
end

function InsertBridge_CreateFcn(hObject, ~, ~)
    hObject.UserData(1) = 0;
end

function InsertBridge_Callback(hObject, ~, handles)
    ButtonCore(hObject,'InsertBridge',handles,'[click] To select the connection associated with the foundation body');
end

function InsertLeakConnection_CreateFcn(hObject, ~, ~)
    hObject.UserData(1) = 0;
end

function InsertLeakConnection_Callback(hObject, ~, handles)
    ButtonCore(hObject,'InsertLeakConnection',handles,'[click] To select Connection 1');
end

function SelectObjects_CreateFcn(hObject, ~, ~)
    hObject.UserData(1) = 0;
end

function SelectObjects_Callback(hObject, ~, handles)
    ButtonCore(hObject,'Select',handles,'[click] To select a single object');
end

function MultiSelectObjects_CreateFcn(hObject, ~, ~)
    hObject.UserData(1) = 0;
end

function MultiSelectObjects_Callback(hObject, ~, handles)
    ButtonCore(hObject,'MultiSelect',handles,'[click] To add to select objects');
end

function InsertSensor_CreateFcn(hObject, ~, ~)
    hObject.UserData(1) = 0;
end

function InsertSensor_Callback(hObject,~,handles)
    ButtonCore(hObject,'InsertSensor',handles,'[click] To select a body');
end

function InsertPVoutput_CreateFcn(hObject, ~, ~)
    hObject.UserData(1) = 0;
end

function InsertPVoutput_Callback(hObject, ~, handles)
    ButtonCore(hObject,'InsertPVoutput',handles,'[click] To select a body');
end

function CustomMinorLoss_CreateFcn(hObject, ~, ~)
    hObject.UserData(1) = 0;
end

function CustomMinorLoss_Callback(hObject, ~, handles)
    ButtonCore(hObject,'InsertCustomMinorLoss',handles,'[click] To select a body');
end

function NonConnection_CreateFcn(hObject, ~, ~)
    hObject.UserData(1) = 0;
end

function NonConnection_Callback(hObject, ~, handles)
    ButtonCore(hObject,'InsertNonConnection',handles,'[click] To select a body');
end

function InsertRelation_CreateFcn(hObject, ~, ~)
    hObject.UserData(1) = 0;
end

function InsertRelation_Callback(hObject, ~, handles)
    ButtonCore(hObject,'InsertRelation',handles,'[click] To select a connection');
end

function ChangeGroup_Callback(hObject, ~, handles)
    [x,y] = ginput(1);
    Pnt = [x y];
    backupMessage = get(handles.message,'String');
    set(handles.message,'String','[click] Select A group');
    handles.Model.switchHighLightedGroup(...
        handles.Model.findNearestGroup(Pnt,handles.ClickTolerance^2) );
    set(handles.message,'String',backupMessage);
    guidata(hObject,handles);
    drawnow(); pause(0.05);
end

%% Selection Properties
function updateSelectionList(h,index)
    % index = index of row that was clicked
    switch h.DropDownMode
        case 'Default'
            if nargin == 2
                if index > length(h.SData.ListObjs) || index < 1
                    fprintf('Index Exceeds Matrix Dimensions: This may be caused by severe lag');
                    return;
                else
                    if strcmp(h.SData.ListObjs(index).MODE,'Deleteobj')
                        % Close all
                        Code = '';
                    else
                        Code = MakeCode(h.SData.ListObjs,index);
                    end
                end
            else
                Code = MakeCode(h.SData.ListObjs);
                Code = ResetCode(Code);
            end
            n = 1  + length(h.Model.Selection);
            SelectedObjs(n,1) = ListObj();
            for Obj = [h.Model.Selection {h.Model}]
                SelectedObjs(n) = ListObj('Expandobj',0,[],Obj{1});
                n = n - 1;
            end
            % 'Code' used to communicate which ListObjs to display
            h.SData.ListObjs = ReadCode(Code, SelectedObjs);
            ListString = cell(length(h.SData.ListObjs),1);
            % text for selection box comes from ListObjs, each ListObj
            % representing one row in the box
            for i = 1:length(h.SData.ListObjs)
                ListString{i} = h.SData.ListObjs(i).getString();
            end
            if nargin < 2; index = get(h.SelectionProps,'Value'); end
            set(h.SelectionProps,'Value',max([1 min([index length(ListString)])]));
            % This is where the contents of the dropdown selection box are
            % actuallzy updated.
            set(h.SelectionProps,'String',ListString);
        case 'Optimizer'
            h.DropDownMode = 'Default';
            if h.OptimizationStudyIndex == 0
                % Create a new study
                h.Model.OptimizationSchemes(end+1) = ...
                    OptimizationScheme(h.Model);
                h.OptimizationStudyIndex = ...
                    h.Model.OptimizationSchemes(end).ID;
            end
            % This appends the object and field to the optimization study
            if h.OptimizationStudyIndex > 0
                for scheme = h.Model.OptimizationSchemes
                    if h.OptimizationStudyIndex == scheme.ID
                        break;
                    end
                end
                if scheme.ID == h.OptimizationStudyIndex
                    if nargin > 1
                        obj = h.SData.ListObjs(index).Parent;
                        child = h.SData.ListObjs(index).Child;
                        if isa(obj,'Connection')
                            scheme.AddObj(obj,'x');
                        elseif isa(child,'LinRotMechanism')
                            scheme.AddObj(child,'Stroke');
                            % dosn't work as child is not a Connection object
                            % but the string 'Connection'
    %                     elseif isa(child,'Connection')
    %                         scheme.AddObj(child,'x');
                        end
                    end
                end
            end
    end
end

function SelectionProps_Callback(hObject, ~, h)
    % The user has clicked on the SelectionProp's listbox
    index = get(hObject,'Value');
    if index <= length(h.SData.ListObjs)
        h.SData.ListObjs(index).on_click();
    end
    updateSelectionList(h,index);
end

function SelectionProps_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%% Optimization
function SwitchDropdownMode_Callback(hObject, ~, h)
    % Interfaces with the drop down menu when selecting parameters
    if strcmp(h.DropDownMode,'Default')
        h.DropDownMode = 'Optimizer';
        set(h.DropDownModeUI,'String',h.DropDownMode, 'BackgroundColor',[0 1 0]);
    else
        h.DropDownMode = 'Default';
        set(h.DropDownModeUI,'String',h.DropDownMode, 'BackgroundColor',[0.94 0.94 0.94]);
    end
    guidata(hObject,h);
end

% --- Executes on button press in SwitchOptimizationStudy.
function SwitchOptimizationStudy_Callback(hObject, ~, h)
    % Find the optimization scheme after the current one
    % Find the current one
    if h.OptimizationStudyIndex == 0
        if ~isempty(h.Model.OptimizationSchemes)
            h.OptimizationStudyIndex = h.Model.OptimizationSchemes(1).ID;
            set(h.OptStudyName,'String',h.Model.OptimizationSchemes(1).name);
        else
            set(h.OptStudyName,'String','Create New Study');
        end
        guidata(hObject,h);
        return;
    end
    for i = 1:length(h.Model.OptimizationSchemes)
        if h.Model.OptimizationSchemes(i).ID == ...
                h.OptimizationStudyIndex
            set(h.OptStudyName,'String',h.Model.OptimizationSchemes(i).name);
        end
    end
    i = i + 1;
    if i > length(h.Model.OptimizationSchemes)
        h.OptimizationStudyIndex = 0;
        set(h.OptStudyName,'String','Create New Study');
    else
        h.OptimizationStudyIndex = h.Model.OptimizationSchemes(i).ID;
    end
    guidata(hObject,h);
end

function RunStudy_Callback(~,~,h)
    if h.OptimizationStudyIndex ~= 0
        found = false;
        for i = 1:length(h.Model.OptimizationSchemes)
            if h.Model.OptimizationSchemes(i).ID == h.OptimizationStudyIndex
                found = true;
                break;
            end
        end
        if found
            History = GradientAscent(h.Model,h.OptimizationStudyIndex);
            if ~isempty(History)
            save([h.Model.OptimizationSchemes(i).name ' - History','History']);
            end
        end
    end
end

%% Visual Appearance
function DistributeGroup(handles)
    % Look at handles.Model.Bridges
    %  Simultaneously minimize the distance that things move, as well as the
    %  bridge horizontal distance
    handles.Model.distributeGroup(handles.InterGroupDistance);
    show_Model(handles);
end

function GUI_CreateFcn(hObject,~,handles) %#ok<INUSD>
    %% Create a figure that has zoom & pan capabilities
    set(hObject,'NextPlot','add');
    % pan off;
    % mouse_figure(gcf);
end

%% Dynamics
function CreateMechanism_Callback(hObject, eventdata, handles)  %#ok<INUSL>
    % Open up user form asking for
    % ... Type from Source (mechanism type)
    % ... ... Stroke (m) (double)
    % ... ... Weight (kg) (double)
    % ... ... Phases (rad) (double)
    % ... ... TiltAngle (rad) (double)
    % ... ... MaximumCrankArmAngle (rad) (double)
    % ... ... CustomProfile Fcn
    Data = Holder({});
    [h] = CreateMechanismInterface(Data);
    uiwait(h);
    handles.Model.addConverter(LinRotMechanism(handles.Model,...
        Data.vars{1},Data.vars{2}));
end

% --- Executes on button press in Animate.
function Animate_Callback(hObject, ~, handles)
    % Temporarily turn off connections, ghosts, groups... etc.
    if handles.Model.isAnimating
        hObject.BackgroundColor = [0.94 0.94 0.94];
        handles.Model.isAnimating = false;
        if handles.ViewOptionBackup(1); showConnections_Callback(handles.showConnections, 0, handles); end
        if handles.ViewOptionBackup(2); showBodyGhosts_Callback(handles.showBodyGhosts, 0, handles); end
        show_Model(handles);
    else
        hObject.BackgroundColor = [0.33 0.67 0.33];
        handles.ViewOptionBackup = false(2,1);
        handles.ViewOptionBackup(1) = handles.Model.showConnections;
        handles.ViewOptionBackup(2) = handles.Model.showBodyGhosts;
        if handles.ViewOptionBackup(1); showConnections_Callback(handles.showConnections, 0, handles); end
        if handles.ViewOptionBackup(2); showBodyGhosts_Callback(handles.showBodyGhosts, 0, handles); end
        handles.Model.isAnimating = true;
        guidata(hObject,handles);
        drawnow(); pause(0.05);
        handles.Model.Animate(); % ANIMATE IT!
        if handles.Model.isAnimating
            hObject.BackgroundColor = [0.94 0.94 0.94];
            handles.Model.isAnimating = false;
            if handles.ViewOptionBackup(1); showConnections_Callback(handles.showConnections, 0, handles); end
            if handles.ViewOptionBackup(2); showBodyGhosts_Callback(handles.showBodyGhosts, 0, handles); end
            show_Model(handles);
        end
    end
end

% --- Executes on button press in Delete.
function Delete_Callback(~, ~, handles)
    % Delete Selection
    if length(handles.Model.Selection) == 1
    if handles.Model.ActiveGroup == handles.Model.Selection{1}
        handles.Model.ActiveGroup(:) = [];
        handles.Model.Selection{1}.deReference();
        handles.Model.Selection = cell(0);
        return;
    end
    end
    for obj = handles.Model.Selection
        if ~isa(obj{1},'Group')
            obj{1}.deReference();
        end
    end
    handles.Model.Selection = cell(0);
    % For all the selected items
end

% --- Executes on button press in Revive.
function Revive_Callback(hObject, eventdata, handles)  %#ok<INUSD>
% Open up the recycle bin, Full of Bodies and Special Components that
% have handles and dependencies
end

%% Save Functionality
function save_Callback(~, ~, handles)
    saveModel(false,handles);
end

function saveas_Callback(~,~,handles)
    saveModel(true,handles);
end

function saveModel(savenew,h)
    % The Model name is by default used, if the model name is blank, then the
    % userform asks for a name.
    if isempty(h.Model.name) || savenew
        
        notdone = true;
        while notdone
            if ~isempty(h.Model.name)
                name = inputdlg('Save as...','Save Model',1,{h.Model.name});
            else
                name = inputdlg('Save as...','Save Model');
            end
            if isempty(name); return; else; name = name{1}; end
            if ~isempty(regexp(name,'[/\*:?"<>|]','once'))
                fprintf(['XXX Invalid File name, a file name cannot contain ' ...
                    'the characters [/*:?"<>|] XXX\n']);
            else
                if all(ismember(name(1),'0123456789'))
                    fprintf(['XXX Invalid File name, a file name cannot start ' ...
                        'with a number. XXX\n']);
                else
                    notdone = false;
                end
            end
        end
        if length(name) > 4 && strcmp(name(end-3:end),'.mat')
            name = name(1:end-4);
        end
        ogname = name;
    else
        name = h.Model.name;
        ogname = name;
    end
    % If the name is already an existing file, it asks to overwrite, if false,
    % then asks for a new name, suggesting a variation.
    SavedModels = dir('Saved Files');
    start = 3;
    dupfound = false;
    notdone = true;
    naming = true;
    while naming
        while notdone
            for i = start:length(SavedModels)
                if strcmp(SavedModels(i).name,[name '.mat'])
                    % Devise an alternative
                    if strcmp(SavedModels(i).name(end-4),')')
                        offset = 1;
                        while ...
                                all(ismember(SavedModels(i).name(end-4-offset),'0123456789')) ||...
                                SavedModels(i).name(end-4-offset) == '.'
                            offset = offset + 1;
                        end
                        offset = offset - 1;
                        num = str2double(SavedModels(i).name(end-4-offset:end-5));
                        num = num + 1;
                        name = [SavedModels(i).name(1:end-5-offset) num2str(num) ')'];
                        notdone = true;
                        dupfound = true;
                        break;
                    else
                        name = [SavedModels(i).name(1:end-4) ' (1)'];
                        dupfound = true;
                    end
                end
            end
            if notdone
                notdone = false;
                % Double check that there are no duplicates
                for i = 3:length(SavedModels)
                    if strcmp(SavedModels(i).name,[name '.mat'])
                        notdone = true;
                        start = i;
                        break;
                    end
                end
            end
        end
        % We have the new unique name
        if dupfound
            switch questdlg(['Do you want to overwrite the existing file: ' ogname])
                case 'Yes'
                    name = ogname;
                    naming = false;
                case 'No'
                    cellname = inputdlg('Name: ',['Rename: ' ogname],1,{name});
                    if isempty(cellname); return; end
                    newname = cellname{1};
                    if strcmp(newname,name)
                        naming = false;
                    else
                        ogname = newname;
                        notdone = true;
                        dupfound = false;
                    end
                    name = newname;
                case {'Cancel',''}
                    return;
            end
        else
            naming = false;
        end
    end
    h.Model.name = name;
    backupAxis = h.Model.AxisReference;
    h.Model.AxisReference(:) = [];
    newfile = ['Saved Files\' name '.mat'];
    Model = h.Model; %#ok<NASGU>
    Model.saveME();
    h.Model.AxisReference = backupAxis;
    fprintf('Model Saved\n');
end

%% Load Functionality
% Matthias: 'name' is now full file path.
function h = load_sub(name, h)
    % newfile = [pwd '\Saved Files\' name];
    % File = load(newfile,'Model');
    File = load(name,'Model');
    h.Model = File.Model;
    h.Model.AxisReference = h.GUI;

    h.Model.showInterConnections = false;
    h.Model.showNodes = false;
    h.Model.RelationOn = true; set(h.RelationMode,'String','On');
    h.Model.showGroups = get(h.showGroups,'Value');
    h.Model.showBodies = get(h.showBodies,'Value');
    h.Model.showBodyGhosts = get(h.showBodyGhosts,'Value');
    h.Model.showConnections = get(h.showConnections,'Value');
    h.Model.showLeaks = get(h.showLeaks,'Value');
    h.Model.showBridges = get(h.showBridges,'Value');
    h.Model.showSensors = get(h.showSensors,'Value');
    h.Model.showRelations = get(h.showRelations,'Value');
    h.Model.showInterConnections = get(h.showInterConnections,'Value');
    h.Model.showEnvironmentConnections = get(h.showEnvironmentConnections,'Value');
    h.Model.showNodes = get(h.showNodes,'Value');

    h.Model.showPressureAnimation = get(h.ShowPressureAnimation,'Value');
    h.Model.recordPressure = get(h.RecordPressure,'Value');
    h.Model.showTemperatureAnimation = get(h.ShowTemperatureAnimation,'Value');
    h.Model.recordTemperature = get(h.RecordTemperature,'Value');
    h.Model.showVelocityAnimation = get(h.ShowVelocityAnimation,'Value');
    h.Model.recordVelocity = get(h.RecordVelocity,'Value');
    h.Model.showTurbulenceAnimation = get(h.ShowTurbulenceAnimation,'Value');
    h.Model.recordTurbulence = get(h.RecordTurbulence,'Value');
    h.Model.recordOnlyLastCycle = get(h.RecordOnlyLastCycle,'Value');
    h.Model.outputPath= get(h.OutputPath,'String');
    h.Model.warmUpPhaseLength = str2double(get(h.WarmUpPhaseLength,'String'));
    h.Model.animationFrameTime = str2double(get(h.AnimationFrameTime,'String'));

    cla;
    show_Model(h);
    drawnow(); pause(0.05);
end

function load_Callback(hObject, ~, h)
    % Asks the user if they want to save the current model
    % if True. Call save_Callback.
    switch questdlg('Do you want to save the current model?')
        case 'Yes'
            if ~isempty(h.Model.name)
                switch questdlg('Do you want to save as a new Model?')
                    case 'Yes'
                        saveModel(true,h);
                    case 'No'
                        saveModel(false,h);
                    case {'Cancel',''}
                        return;
                end
            else
                saveModel(true,h);
            end
        case 'No'
            % Do nothing
        case {'Cancel',''}
            return;
    end

    % Then provide the user with a list of saved models in the Saved Files
    % folder.
    % NOV26 2021: updated by Matthias to use uigetfile for convenience
    [file, path] = uigetfile('Saved Files\*.mat');
    if file
        name = fullfile(path,file);
    else
        return;
    end

    %ORIGINAL CODE
    % SavedModels = dir('Saved Files');
    % names = {SavedModels.name};
    % i = 1;
    % while names{i}(1) == '.'
    %     i = i + 1;
    % end
    % [selection, tf] = listdlg('ListString',names(i:end),...
    %     'SelectionMode','single');
    % if tf
    %     name = names{selection+i-1};
    % else
    %     return;
    % end

    % if the user selects one, then replace current model with the loaded one
    % and reset the userform.
    [h] = load_sub(name, h);
    guidata(h.load,h);
end

%% Show Options
function showGroups_Callback(hObject, ~, h) %#ok<*DEFNU>
    value = get(hObject,'Value');
    if (value ~= h.Model.showGroups)
        h.Model.showGroups = value;
        show_Model(h);
    end
end

function showBodies_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~=h.Model.showBodies)
        h.Model.showBodies = value;
        show_Model(h);
    end
end

function showConnections_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showConnections)
        h.Model.showConnections = value;
        show_Model(h);
    end
end

function showLeaks_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showLeaks)
        h.Model.showLeaks = value;
        show_Model(h);
    end
end

function showBridges_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showBridges)
        h.Model.showBridges = value;
        show_Model(h);
    end

    % function showInterConnections_Callback(hObject, ~, h)
    % % update value of 'Node Connections' radio box and related check boxes
    % value = get(hObject,'Value');
    % if (value ~= h.Model.showInterConnections)
    %     h.Model.showInterConnections = value;
    %     show_Model(h);
    % end
end

function showInterConnections_Callback(~, ~, h)
    % update value of 'Node Connections' radio box and related check boxes
    changed = false;
    value = h.showInterConnections.Value;
    if (value ~= h.Model.showInterConnections)
        h.Model.showInterConnections = value;
        changed = true;
    end
    value = h.checkboxFacesGas.Value;
    if (value ~= h.Model.showFacesGas)
        h.Model.showFacesGas = value;
        changed = true;
    end
    value = h.checkboxFacesSolid.Value;
    if (value ~= h.Model.showFacesSolid)
        h.Model.showFacesSolid = value;
        changed = true;
    end
    value = h.checkboxFacesMix.Value;
    if (value ~= h.Model.showFacesMix)
        h.Model.showFacesMix = value;
        changed = true;
    end
    value = h.checkboxFacesLeak.Value;
    if (value ~= h.Model.showFacesLeak)
        h.Model.showFacesLeak = value;
        changed = true;
    end
    value = h.checkboxFacesMatrixTransition.Value;
    if (value ~= h.Model.showFacesMatrixTransition)
        h.Model.showFacesMatrixTransition = value;
        changed = true;
    end
    value = h.checkboxFacesEnvironment.Value;
    if (value ~= h.Model.showFacesEnvironment)
        h.Model.showFacesEnvironment = value;
        changed = true;
    end

    if changed
        show_Model(h);
    end
end

% Added by Matthias to show Node Outlines/Boundaries as rectangles.
% Both showNodes and showNodeBounds buttons and related checkboxes share
% this callback function.
function showNodeBounds_Callback(~, ~, h)
    changed = false;
    value = h.showNodeBounds.Value;
    if (value ~= h.Model.showNodeBounds)
        h.Model.showNodeBounds = value;
        changed = true;
    end
    value = h.showNodes.Value;
    if (value ~= h.Model.showNodes)
        h.Model.showNodes = value;
        changed = true;
    end
    value = h.checkboxSVGN.Value;
    if (value ~= h.Model.showNodesSVGN)
        h.Model.showNodesSVGN = value;
        changed = true;
    end
    value = h.checkboxVVGN.Value;
    if (value ~= h.Model.showNodesVVGN)
        h.Model.showNodesVVGN = value;
        changed = true;
    end
    value = h.checkboxSAGN.Value;
    if (value ~= h.Model.showNodesSAGN)
        h.Model.showNodesSAGN = value;
        changed = true;
    end
    value = h.checkboxSN.Value;
    if (value ~= h.Model.showNodesSN)
        h.Model.showNodesSN = value;
        changed = true;
    end
    value = h.checkboxEN.Value;
    if (value ~= h.Model.showNodesEN)
        h.Model.showNodesEN = value;
        changed = true;
    end

    if changed
        show_Model(h)
    end

    % function showNodeBounds_Callback(hObject, ~, h)
    % value = get(hObject,'Value');
    % if (value ~= h.Model.showNodeBounds)
    %     h.Model.showNodeBounds = value;
    %     show_Model(h);
    % end
    % function showNodes_Callback(hObject, ~, h)
    % value = get(hObject,'Value');
    % if (value ~= h.Model.showNodes)
    %     h.Model.showNodes = value;
    %     show_Model(h);
    % end
end

function showEnvironmentConnections_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showEnvironmentConnections)
        h.Model.showEnvironmentConnections = value;
        show_Model(h);
    end
end

function showBodyGhosts_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showBodyGhosts)
        h.Model.showBodyGhosts = value;
        show_Model(h);
    end
end

function showSensors_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showSensors)
        h.Model.showSensors = value;
        show_Model(h);
    end
end

function showRelations_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showRelations)
        h.Model.showRelations = value;
        show_Model(h);
    end
end

function BoxZoom_Callback(hObject, eventdata, h) %#ok<INUSL>
    %handles.corner_points = ginput(2);
    show_Model(h,ginput(2));
end

function show_Model(h,cornerpoints)
    h.Model.show();
    if nargin == 2
        % Preserve aspect ratio
        axes = gca;
        width = abs(cornerpoints(1,1) - cornerpoints(2,1));
        height = abs(cornerpoints(1,2) - cornerpoints(2,2));
        r_new = width/height;
        
        % Get current aspect ratio
        r_old = axes.PlotBoxAspectRatio(1)/axes.PlotBoxAspectRatio(2);
        
        if r_old > r_new
            width = width*r_old/r_new;
        else
            height = height*r_new/r_old;
        end
        
        % Determine the center
        c_x = 0.5*(cornerpoints(1,1) + cornerpoints(2,1));
        c_y = 0.5*(cornerpoints(1,2) + cornerpoints(2,2));
        % Adjust the axes
        axes.XLim = [c_x-width/2 c_x+width/2];
        axes.YLim = [c_y-height/2 c_y+height/2];
    end
    drawnow(); pause(0.05);
end

function RecenterView_Callback(~, ~, h)
    axes = gca;
    xlim = h.Model.getXLim();
    ylim = h.Model.getYLim();
    ar = abs(ylim(1)-ylim(2))/abs(xlim(1)-xlim(2));
    cur_xlim = axes.XLim;
    cur_ylim = axes.YLim;
    cur_ar = abs(cur_ylim(1)-cur_ylim(2))/abs(cur_xlim(1)-cur_xlim(2));
    if ar > cur_ar
        % ylim is the base
        cx = mean(xlim);
        dx = 0.5*abs(ylim(1)-ylim(2))/cur_ar;
        xlim = [cx - dx, cx + dx];
    else
        % xlim is the base
        cy = mean(ylim);
        dy = 0.5*cur_ar*abs(xlim(1)-xlim(2));
        ylim = [cy - dy, cy + dy];
    end
    if any(isnan(xlim)) || any(isinf(xlim))
        return
    end
    if any(isnan(ylim)) || any(isinf(ylim))
        return
    end
    axes.XLim = xlim;
    axes.YLim = ylim;
    show_Model(h);
end

%% RunTime Show Options
function showLivePV_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showLivePV)
        h.Model.showLivePV = value;
    end
end

function stopSimulation_Callback(~, ~, h)
    h.Model.stopSimulation();
end

function Run_Callback(~, ~, h)
    h.Model.Run();
end

function CreateMechanism_CreateFcn(~, ~, ~)
end

function Animate_CreateFcn(~, ~, ~)
end

%% Simulation Options
function Reset_Discretization_Callback(~, ~, h)
    h.Model.resetDiscretization();
    show_Model(h);
end

function DispNumbers_Callback(~, ~, h)
    h.Model.dispNodeIndexes();
end

function clearAxes_Callback(~, ~, ~)
    cla;
end

function ShowPressureAnimation_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showPressureAnimation)
        h.Model.showPressureAnimation = value;
    end
    if value
        set(h.RecordPressure,'Value',value);
        RecordPressure_Callback(h.RecordPressure,[],h);
    end
end

function RecordPressure_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.recordPressure)
        h.Model.recordPressure = value;
    end
    if ~value
        set(h.ShowPressureAnimation,'Value',value);
        ShowPressureAnimation_Callback(h.ShowPressureAnimation,[],h);
    end
end

function ShowTemperatureAnimation_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showTemperatureAnimation)
        h.Model.showTemperatureAnimation = value;
    end
    if value
        set(h.RecordTemperature,'Value',value);
        RecordTemperature_Callback(h.RecordTemperature,[],h);
    end
end

function RecordTemperature_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.recordTemperature)
        h.Model.recordTemperature = value;
    end
    if ~value
        set(h.ShowTemperatureAnimation,'Value',value);
        ShowTemperatureAnimation_Callback(h.ShowTemperatureAnimation,[],h);
    end
end

function ShowVelocityAnimation_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showVelocityAnimation)
        h.Model.showVelocityAnimation = value;
    end
    if value
        set(h.RecordVelocity,'Value',value);
        RecordVelocity_Callback(h.RecordVelocity,[],h);
    end
end

function RecordVelocity_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.recordVelocity)
        h.Model.recordVelocity = value;
    end
    if ~value
        set(h.ShowVelocityAnimation,'Value',value);
        ShowVelocityAnimation_Callback(h.ShowVelocityAnimation,[],h);
    end
end

function ShowTurbulenceAnimation_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showTurbulenceAnimation)
        h.Model.showTurbulenceAnimation = value;
    end
    if value
        set(h.RecordTurbulence,'Value',value);
        RecordTurbulence_Callback(h.RecordTurbulence,[],h);
    end
end

function RecordTurbulence_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.recordTurbulence)
        h.Model.recordTurbulence = value;
    end
    if ~value
        set(h.ShowTurbulenceAnimation,'Value',value);
        ShowTurbulenceAnimation_Callback(h.ShowVelocityAnimation,[],h);
    end
end

function ShowConductionAnimation_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showConductionAnimation)
        h.Model.showTurbulenceAnimation = value;
    end
    if value
        set(h.RecordConductionFlux,'Value',value);
        RecordConductionFlux_Callback(h.RecordConductionFlux,[],h);
    end
end

function RecordConductionFlux_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.recordConductionFlux)
        h.Model.recordTurbulence = value;
    end
    if ~value
        set(h.ShowConductionAnimation,'Value',value);
        ShowConductionAnimation_Callback(h.ShowConductionAnimation,[],h);
    end
end

function PressureDropAnimation_Callback(hObject,~,h)
    value = get(hObject,'Value');
    if (value ~= h.Model.showPressureDropAnimation)
        h.Model.showPressureDropAnimation = value;
    end
    if value
        set(h.recordPressureDrop,'Value',value);
        recordPressureDrop_Callback(h.recordPressureDrop,[],h);
    end
end

function recordPressureDrop_Callback(hObject,~,h)
    value = get(hObject,'Value');
    if (value ~= h.Model.recordPressureDrop)
        h.Model.recordPressureDrop = value;
    end
    if ~value
        set(h.PressureDropAnimation,'Value',value);
        PressureDropAnimation_Callback(h.PressureDropAnimation,[],h);
    end
end

function RecordOnlyLastCycle_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.recordOnlyLastCycle)
        h.Model.recordOnlyLastCycle = value;
    end
end

function RecordStatistics_Callback(hObject, ~, h)
    value = get(hObject,'Value');
    if (value ~= h.Model.recordStatistics)
        h.Model.recordStatistics = value;
    end
end

function OutputPath_CreateFcn(~, ~, ~)
end

function OutputPath_ButtonDownFcn(hObject, ~, h)
    value = uigetdir;
    set(hObject,'String',value);
    h.Model.outputPath = value;
end

function WarmUpPhaseLength_Callback(hObject, ~, h)
    value = get(hObject,'String');
    if isempty(value); value = '0'; end
    if all(ismember(value,'.0123456789'))
        set(hObject,'UserData',value);
        h.Model.warmUpPhaseLength = str2double(value);
    else
        msgbox('The length must be a number, the units are already defined as seconds');
        set(hObject,'String',get(hObject,'UserData'));
    end
end

function WarmUpPhaseLength_CreateFcn(hObject, ~, ~)
    set(hObject,'UserData','0');
    set(hObject,'String','0');
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function AnimationFrameTime_Callback(hObject, ~, h)
    value = get(hObject,'String');
    if isempty(value); value = '0.05'; end
    if all(ismember(value,'.0123456789'))
        set(hObject,'UserData',value);
        h.Model.animationFrameTime = str2double(value);
    else
        msgbox('The length must be a number, the units are already defined as seconds');
        set(hObject,'String',get(hObject,'UserData'));
    end
end

function AnimationFrameTime_CreateFcn(hObject, ~, ~)
    set(hObject,'UserData','0.05');
    set(hObject,'String','0.05');
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function RecordSnapShot_Callback(~, ~, handles)
    if ~isempty(handles.Model.Result)
        name = getProperName( 'SnapShot' );
        handles.Model.Result.getSnapShot(this,handles.Model,name)
    end
end

function RunTestSet_Callback(~, ~, h)
    % NOV26 2021: updated by Matthias to use uigetfile for convenience
    sel = uigetfile('Test_Running\*.m');
    if sel
        func = str2func(sel(1:end-2)); % cut off '.m' file ending
        Test_Set = func();
        
    % ORIGINAL CODE
    % % Find the Folder "Test_Running"
    % files = dir('Test_Running');
    % names = {files.name};
    % names(1:2) = [];
    % if ~iscell(names)
    %     names = {names};
    % end
    % for index = size(names,1):-1:1
    %     names{index} = names{index}(1:end-2);
    % end
    % index = listdlg('ListString',names,...
    %     'SelectionMode','single',...
    %     'InitialValue',index);
    % if ~isempty(index)
    %     if strfind(names{index},'.m')
    %         func = str2func(names{index}(1:end-2));
    %     else
    %         func = str2func(names{index});
    %     end
    %     Test_Set = func();
        
        % Chunk the test set into groups that have the same model
        group_start = 1;
        group_end = 1;
        while group_end <= length(Test_Set)
            Model = Test_Set(group_start).Model;
            while group_end <= length(Test_Set) && ...
                    strcmp(Model,Test_Set(group_end).Model)
                group_end = group_end + 1;
            end
            group_end = group_end - 1;
            h = load_sub(Model, h);
            h.Model.Run(Test_Set(group_start:group_end));
            group_start = group_end + 1;
            group_end = group_start;
            
            
            % The Model name is the default name used, it overwrites automatically
            %     name = h.Model.name;
            %     newfile = ['Saved Files\' name '.mat'];
            %     Model = h.Model;
            %     save(newfile,'Model');
            %     fprintf('Model Saved.\n');
        end
    end
end

function DerefinementFactor_Callback(hObject, ~, handles)
    value = str2double(get(hObject,'String'));
    if isnan(value)
        set(hObject,'String','1');
        return;
    end
    if value >= 0.01 && value <= 100
        handles.Model.deRefinementFactorInput = value;
    else
        if value < 0.01
            set(hObject,'String','0.01');
            handles.Model.deRefinementFactorInput = 0.01;
        else
            set(hObject,'String','100');
            handles.Model.deRefinementFactorInput = 100;
        end
    end
    handles.Model.resetDiscretization();
    guidata(hObject,handles);
end

function DerefinementFactor_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end


% --- Executes on button press in SwitchRelationMode.
function SwitchRelationMode_Callback(~, ~, handles)
    if strcmp(get(handles.RelationMode,'String'),'On')
    set(handles.RelationMode,'String','Off', 'BackgroundColor',[1 0 0]);
    handles.Model.RelationOn = false;
    else
    set(handles.RelationMode,'String','On', 'BackgroundColor',[0.94 0.94 0.94]);
    handles.Model.RelationOn = true;
    end
end


% --- Executes on button press in ManualDiscretize.
function ManualDiscretize_Callback(~, ~, h)
    crun = struct('Model',h.Model.name,...
        'title',[h.Model.name ' test: ' date],...
        'rpm',h.Model.engineSpeed,...
        'NodeFactor',h.Model.deRefinementFactorInput);
    h.Model.discretize(crun);
end


% --- Executes on button press in checkboxGasFaces.
function checkboxGasFaces_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxGasFaces (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxGasFaces
end


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
    % hObject    handle to Untitled_2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on button press in checkboxFacesGas.
function checkboxFacesGas_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxFacesGas (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxFacesGas
end


% --- Executes on button press in checkboxFacesSolid.
function checkboxFacesSolid_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxFacesSolid (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxFacesSolid
end


% --- Executes on button press in checkboxFacesMix.
function checkboxFacesMix_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxFacesMix (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxFacesMix
end


% --- Executes on button press in checkboxFacesLeak.
function checkboxFacesLeak_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxFacesLeak (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxFacesLeak
end


% --- Executes on button press in checkboxFacesMatrixTransition.
function checkboxFacesMatrixTransition_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxFacesMatrixTransition (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxFacesMatrixTransition
end


% --- Executes on button press in checkboxFacesEnvironment.
function checkboxFacesEnvironment_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxFacesEnvironment (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxFacesEnvironment
end


% --- Executes on button press in checkboxSVGN.
function checkboxSVGN_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxSVGN (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxSVGN
end


% --- Executes on button press in checkboxVVGN.
function checkboxVVGN_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxVVGN (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxVVGN
end


% --- Executes on button press in checkboxSAGN.
function checkboxSAGN_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxSAGN (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxSAGN
end


% --- Executes on button press in checkboxSN.
function checkboxSN_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxSN (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxSN
end


% --- Executes on button press in checkboxEN.
function checkboxEN_Callback(hObject, eventdata, handles)
    % hObject    handle to checkboxEN (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of checkboxEN
end
