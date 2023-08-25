%{
   Modular Single Phase Model - MSPM. A program for simulating single phase cyclical thermodynamic machines.
   Copyright (C) 2023  David Nobes
      Mailing Address:
         University of Alberta
         Mechanical Engineering
         10-281 Donadeo Innovation Centre For Engineering
         9211-116 St
         Edmonton
         AB
         T6G 2H5
      Email: dnobes@ualberta.ca

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.
%}

classdef ListObj < handle
    %LISTOBJ Summary of this class goes here
    %   Detailed explanation goes here

    properties
        MODE = '';
        lvl int8;
        isExpanded logical = false;
        Parent;
        Child; % Various
        Info; % Various
        Subs ListObj;
    end

    methods
        function this = ListObj(MODE,lvl,Parent,Child,info)
            if nargin > 0
                this.MODE = MODE;
                this.lvl = lvl;
                this.Parent = Parent;
                this.Child = Child;
                if nargin > 4
                    this.Info = info;
                end
            end
        end

        function on_click(this)
            switch this.MODE
                case 'Editstr'
                    % Bring up user form inputdlg
                    newvalue = get(this.Parent,this.Child);
                    if isempty(newvalue); newvalue = ''; end
                    newvalue = inputdlg(['Property: ' this.Child ': '],...
                        'Edit Properties',1,{newvalue});
                    if ~isempty(newvalue) && isa(newvalue{1},'char')
                        set(this.Parent,this.Child,newvalue{1});
                    end
                case 'Editnum'
                    % Bring up user form inputdlg
                    newvalue = inputdlg(['Edit the value of ' this.Child ' in ' this.Info],...
                        'Edit Properties',1,...
                        {num2str(get(this.Parent,this.Child))});
                    if ~isempty(newvalue)
                        number = SymbolicMath(newvalue{1});
                        % Matthias: Custom Heat Transfer Coefficient is allowed to be NaN
                        if strcmp(this.Child,'Custom Heat Transfer Coefficient') && number <= 0
                            msgbox('Must be greater than zero.');
                        elseif ~strcmp(this.Child,'Custom Heat Transfer Coefficient') && isnan(number)
                            msgbox('Invalid formula: Ensure that your formula is complete and avoids scientific notation.');
                        else
                            set(this.Parent,this.Child,number);
                        end
                    end
                    %                     if strcmp(this.Child,'Custom Heat Transfer Coefficient')
                    %                         if number <= 0
                    %                             msgbox('Must be greater than zero.');
                    %                         end
                    %                     else
                    %                         if isnan(number)
                    %                             msgbox('Invalid formula: Ensure that your formula is complete and avoids scientific notation.');
                    %                         else
                    %                             set(this.Parent,this.Child,number);
                    %                         end
                    %                     end
                case 'Editnumconvert'
                    % Bring up user form inputdlg
                    newvalue = (inputdlg(['Edit the value of ' this.Child ' in ' this.Info{2}],...
                        'Edit Properties',1,...
                        {num2str(round(get(this.Parent,this.Child)*this.Info{1}))}));
                    number = SymbolicMath(newvalue{1});
                    if isnan(number)
                        msgbox('Invalid formula: Ensure that your formula is complete and avoids scientific notation.');
                    else
                        set(this.Parent,this.Child,number/this.Info{1});
                    end
                case {'Expandobj', 'Expandlist'}
                    this.isExpanded = ~this.isExpanded;
                case 'Configureobj'
                    % the Parent has a child that has a parameter labeled 'Source'
                    % this source is used as an input into the child's constructor
                    % Bring up a user form
                    if ischar(this.Child)
                        % Make a copy of the parent for Matrix Changes
                        if strcmp(this.Child, 'Change Matrix')
                            parentCopy = this.Parent;
                        end

                        % Get the item and modify
                        Item = get(this.Parent,this.Child);
                        Item.Modify();

                        % For Changing a body's matrix
                        if strcmp(this.Child, 'Change Matrix')
                            if isempty(Item.Dh)
                                % Revert the parent to the unmodified version
                                this.Parent = parentCopy;
                                return
                            end
                        end

                        if strcmp(this.Child, 'Material')
                            this.Parent.show(gca);
                        end
                    else
                        this.Child.Modify();
                    end
                case 'Pickobj'
                    % Info is a objarray
                    Item = get(this.Parent,this.Child);
                    objs = this.Info;
                    names = {'...'};
                    for index = length(objs):-1:1
                        names{index+1} = objs(index).name;
                    end
                    if ~isempty(Item)
                        for index = 1:length(objs)
                            if Item == objs(index)
                                break;
                            end
                        end
                    end
                    index = listdlg('ListString',names,...
                        'SelectionMode','single',...
                        'InitialValue',index); % ADD WIDTH, HEIGHT CONSTRAINTS
                    if index == 1
                        set(this.Parent,this.Child,[]);
                    else
                        set(this.Parent,this.Child,objs(index-1));
                    end
                case 'Pickfunction'
                    % Info is a folder name
                    % Bring up a user form listdlg from folder: Item
                    % Get index of current value
                    temp = get(this.Parent,this.Child);
                    if isempty(temp)
                        Item = '';
                    else
                        Item = func2str(temp);
                    end
                    files = dir(strcat('src/',this.Info));
                    names = {files.name};
                    names = names{3:end}; % Remove the first couple
                    if ~iscell(names)
                        names = {names};
                    end
                    for index = size(names,1):-1:1
                        names{index} = names{index}(1:end-2);
                    end
                    for index = 1:length(names)
                        if strcmp(names{index},Item); break; end
                    end
                    index = listdlg('ListString',names,...
                        'SelectionMode','single',...
                        'InitialValue',index);
                    if isempty(index)
                        set(this.Parent,this.Child,function_handle.empty);
                    else
                        set(this.Parent,this.Child,str2func(names{index}));
                    end
                case 'Function'
                    functions(this.Parent,this.Child);
                case 'Deleteobj'
                    this.Parent.deReference();
                case 'NamedList'
                    names = get(this.Parent,this.Child);
                    if ~isempty(names)
                        [indx, tf] = listdlg(...
                            'PromptString',['Select ' this.Child ' to Remove'],...
                            'ListString',names,'ListSize',[1000 800]);
                        if tf
                            answers = false(length(names),1);
                            answers(indx) = true;
                            set(this.Parent,this.Child,answers);
                        end
                    end
                case 'TrueFalse'
                    % Get the current state    
                    currState = get(this.Parent, this.Child);
                    % Get the correct index
                    if currState
                        set(this.Parent,this.Child,false)
                    else
                        set(this.Parent,this.Child,true)
                    end
            end
        end

        function [objects] = getObjs(this,expanded)
            if ischar(this.Child)
                if ~strcmp(this.Child,'Deleteobj')
                    Item = get(this.Parent,this.Child);
                end
                Text = this.Child;
            else
                Item = this.Child;
                Text = class(this.Child);
            end
            slvl = this.lvl+1;
            if nargin == 2
                switch this.MODE
                    case 'Expandobj'
                        if isempty(Item)
                            objects = this;
                        else
                            switch class(Item)
                                case 'Model'
                                    objects = [this; ...
                                        ListObj('Editstr',slvl,Item,'Name'); ...
                                        ListObj('Expandlist',slvl,Item,'Groups'); ...
                                        ListObj('Expandlist',slvl,Item,'Bridges'); ...
                                        ListObj('Expandlist',slvl,Item,'Leaks'); ...
                                        ListObj('Expandlist',slvl,Item,'Sensors'); ...
                                        ListObj('Expandlist',slvl,Item,'PVoutputs'); ...
                                        ListObj('NamedList',slvl,Item,'SnapShots'); ...
                                        ListObj('NamedList',slvl,Item,'NonConnections'); ...
                                        ListObj('NamedList',slvl,Item,'Custom Minor Losses'); ...
                                        ListObj('Expandlist',slvl,Item,'Lin. to Rot. Mechanisms'); ...
                                        ListObj('Expandlist',slvl,Item,'Optimization Studies'); ...
                                        ListObj('Expandobj',slvl,Item,'Initial Internal Conditions'); ...
                                        ListObj('Expandobj',slvl,Item,'External Conditions'); ...
                                        ListObj('Editnum',slvl,Item,'Engine Temperature','K'); ...
                                        ListObj('Editnum',slvl,Item,'Engine Pressure','Pa'); ...
                                        ListObj('Editnum',slvl,Item,'Minimum Speed','Hz'); ...
                                        ListObj('Expandobj',slvl,Item,'Mechanical System'); ...
                                        ListObj('Expandobj',slvl,Item,'Mesher'); ...
                                        ListObj('Editnum',slvl,Item,'Max Courant Final'); ...
                                        ListObj('Editnum',slvl,Item,'Max Fourier Final'); ...
                                        ListObj('Editnum',slvl,Item,'Max Courant Converging'); ...
                                        ListObj('Editnum',slvl,Item,'Max Fourier Converging')];
                                case 'Group'
                                    objects = [this; ...
                                        ListObj('Editstr',slvl,Item,'Name'); ...
                                        ListObj('Expandobj',slvl,Item,get(Item,'Position')); ...
                                        ListObj('Expandlist',slvl,Item,'Bodies'); ...
                                        ListObj('Expandlist',slvl,Item,'Connections'); ...
                                        ListObj('Expandlist',slvl,Item,'Relation Managers')];
                                case 'Body'
                                    objects = [this; ...
                                        ListObj('Editstr',slvl,Item,'Name'); ...
                                        ListObj('Expandobj',slvl,Item,'Bottom Connection'); ...
                                        ListObj('Expandobj',slvl,Item,'Top Connection'); ...
                                        ListObj('Expandobj',slvl,Item,'Inner Connection'); ...
                                        ListObj('Expandobj',slvl,Item,'Outer Connection'); ...
                                        ListObj('Configureobj',slvl,Item,'Material'); ...
                                        ListObj('Editnum',slvl,Item,'Temperature'); ...
                                        ListObj('Editnum',slvl,Item,'Pressure'); ...
                                        ListObj('Editnum',slvl,Item,'Radial Divides','divisions'); ...
                                        ListObj('Editnum',slvl,Item,'Axial Divides','divisions'); ...
                                        ListObj('Pickobj',slvl,Item,'RefFrame',Item.Group.Model.RefFrames); ...
                                        ListObj('Configureobj',slvl,Item,'Change Matrix');...
                                        ListObj('Expandobj',slvl,Item,'Expand Matrix');...
                                        ListObj('Pickfunction',slvl,Item,'Radial Discretization Function','Function - Discretization'); ...
                                        ListObj('Pickfunction',slvl,Item,'Axial Discretization Function','Function - Discretization'); ...
                                        % Matthias: Added to display and edit custom heat transfer coefficient
                                        ListObj('Editnum',slvl,Item,'Custom Heat Transfer Coefficient','W/m^2 K (Only for Solid Bodies or gas bodies with a matrix containing a source! ''NaN'' to disable.)')];

                                        % If the material is a gas
                                        if Item.matl.Phase == enumMaterial.Gas
                                            objects = [objects; ListObj('TrueFalse',slvl,Item,'Include in Volume Calculation', {'Will this body be included in the', 'volume calculation?'})];
                                        end
                                case 'Connection'
                                    objects = [this; ...
                                        ListObj('Editnum',slvl,Item,'x','m'); ...
                                        ListObj('Pickobj',slvl,Item,'RefFrame',Item.Group.Model.RefFrames); ...
                                        ListObj('Expandlist',slvl,Item,'Bodies'); ...
                                        ListObj('Expandlist',slvl,Item,'Isolated Bodies'); ...
                                        ListObj('Function',slvl,Item,'Add Bodies To Not Join'); ...
                                        ListObj('Function',slvl,Item,'Remove Bodies To Not Join')];
                                case 'Bridge'
                                    objects = [this; ...
                                        ListObj('Expandobj',slvl,Item,'Connection 1'); ...
                                        ListObj('Expandobj',slvl,Item,'Connection 2'); ...
                                        ListObj('Expandobj',slvl,Item,'Body 1'); ...
                                        ListObj('Expandobj',slvl,Item,'Body 2'); ...
                                        ListObj('Editnum',slvl,Item,'Offset'); ...
                                        ListObj('Deleteobj',slvl,Item,'[X] Delete')];
                                case 'LeakConnection'
                                    objects = [this; ...
                                        ListObj('Expandobj',slvl,Item,'Object 1'); ...
                                        ListObj('Expandobj',slvl,Item,'Object 2'); ...
                                        ListObj('Pickfunction',slvl,Item,'LeakFunc','Function - Leakage'); ...
                                        ListObj('Deleteobj',slvl,Item,'[X] Delete')];
                                case 'Environment'
                                    objects = [this; ...
                                        ListObj('Editstr',slvl,Item,'Name'); ...
                                        ListObj('Editnum',slvl,Item,'Pressure','Pa'); ...
                                        ListObj('Editnum',slvl,Item,'Temperature','K'); ...
                                        ListObj('Editnum',slvl,Item,'h','W/mK'); ...
                                        ListObj('Configureobj',slvl,Item,'Gas')];
                                case 'Position'
                                    objects = [this; ...
                                        ListObj('Editnum',slvl,Item,'x','m'); ...
                                        ListObj('Editnum',slvl,Item,'y','m'); ...
                                        ListObj('Editnumconvert',slvl,Item,'Theta',{180/pi; 'degrees'})];
                                case 'Matrix'
                                    objects = [this; ...
                                        ListObj('Configureobj',slvl,Item,'Material'); ...
                                        ListObj('Pickfunction',slvl,Item,'Laminar Friction Function','Function - Laminar Friction'); ...
                                        ListObj('Pickfunction',slvl,Item,'Turbulent Friction Function','Function - Turb Friction'); ...
                                        ListObj('Pickfunction',slvl,Item,'Laminar Nusselt Function','Function - Laminar Nusselt'); ...
                                        ListObj('Pickfunction',slvl,Item,'Turbulent Nusselt Function','Function - Turb Nusselt'); ...
                                        ListObj('Pickfunction',slvl,Item,'Laminar Streamwise Cond. Enhancement','Function - Laminar Cond Enhancement'); ...
                                        ListObj('Pickfunction',slvl,Item,'Turbulent Streamwise Cond. Enhancement','Function - Turb Cond Enhancement'); ...
                                        ListObj('Editnum',slvl,Item,'Source Temperature','K'); ...
                                        ListObj('Deleteobj',slvl,Item,'[X] Delete')];
                                case 'Mesher'
                                    objects = [this; ...
                                        ListObj('Editnum',slvl,Item,'Nodes through Oscillation Depth'); ...
                                        ListObj('Editnum',slvl,Item,'Maximum Node Thickness'); ...
                                        ListObj('Editnum',slvl,Item,'Maximum Growth Rate'); ...
                                        ListObj('Editnum',slvl,Item,'Heat Exchanger Fin Divisions'); ...
                                        ListObj('Editnum',slvl,Item,'Minimum Solid Time Step'); ...
                                        ListObj('Editnum',slvl,Item,'Gas Entrance Exit N'); ...
                                        ListObj('Editnum',slvl,Item,'Gas Maximum Size'); ...
                                        ListObj('Editnum',slvl,Item,'Gas Minimum Size')];
                                case 'Sensor'
                                    objects = [this; ...
                                        ListObj('Editstr',slvl,Item,'Name'); ...
                                        ListObj('Editnum',slvl,Item,'Samples')];
                                case 'PVoutput'
                                    objects = [this; ...
                                        ListObj('Editstr',slvl,Item,'name'); ...
                                        ListObj('Pickobj',slvl,Item,'Source Body/Region',Item.Model.BodyList); ...
                                        ListObj('Deleteobj',slvl,Item,'[X] Delete')];
                                case 'MechanicalSystem'
                                    objects = [this; ...
                                        ListObj('Editnum',slvl,Item,'Flywheel Inertia'); ...
                                        ListObj('Editnum',slvl,Item,'Drive Train Weight'); ...
                                        ListObj('Editnum',slvl,Item,'Drive Train Normal Friction Coefficient'); ...
                                        ListObj('Pickfunction',slvl,Item,'Load Function','Function - Load Function')];
                                case 'RelationManager'
                                    objects = [this; ...
                                        ListObj('Editstr',slvl,Item,'Name'); ...
                                        ListObj('Expandlist',slvl,Item,'Relations')];
                                case 'Relation'
                                    objects = [this; ...
                                        ListObj('Editstr',slvl,Item,'Name'); ...
                                        ListObj('Expandobj',slvl,Item,'Connection1'); ...
                                        ListObj('Expandobj',slvl,Item,'Connection2'); ...
                                        ListObj('Pickobj',slvl,Item,'Frame',Item.manager.Group.Model.RefFrames); ...
                                        ListObj('Deleteobj',slvl,Item,'[X] Delete')];
                                case 'OptimizationScheme'
                                    objects = [this; ...
                                        ListObj('Editstr',slvl,Item,'Name'); ...
                                        ListObj('NamedList',slvl,Item,'DOFs')];
                            end
                        end
                    case 'Expandlist'
                        objs = get(this.Parent,Text);
                        LEN = length(objs);
                        objects(LEN+1,1) = ListObj();
                        switch class(objs)
                            case {'LinRotMechanism', 'Material'}
                                % Modify rather than expand
                                for i = LEN:-1:1
                                    objects(i+1) = ListObj('Configureobj',slvl,Item,objs(i));
                                end
                            otherwise
                                for i = LEN:-1:1
                                    objects(i+1) = ListObj('Expandobj',slvl,Item,objs(i));
                                end
                        end
                        objects(1) = this;
                    otherwise
                        objects = this;
                end
            else % do not expand
                objects = this;
            end
        end

        function [output] = getString(this)
            starter = repmat('. . . ',1,this.lvl);
            if ischar(this.Child)
                if ~strcmp(this.Child,'[X] Delete') && ~strcmp(this.MODE,'Function')
                    Item = get(this.Parent,this.Child);
                end
                Text = this.Child;
            else
                Item = this.Child;
                Text = class(this.Child);
            end
            switch this.MODE
                case 'Editstr'
                    output = [starter Text ': [' Item ']'];
                case 'Editnum'
                    output = [starter Text ': [' num2str(Item) ' ' this.Info ']'];
                case 'Editnumconvert'
                    output = [starter Text ': [' num2str(Item*this.Info{1}) ' (' this.Info{2} ')]'];
                case 'Expandobj'
                    if isvalid(Item)
                        output = [starter Text ' (' class(Item) '): [' Item.name ']'];
                    else
                        output = [starter Text ' (' class(Item) '): [X Deleted Object]'];
                    end
                case 'Expandlist'
                    objs = get(this.Parent,Text);
                    if ~isempty(objs)
                        objs = objs(isvalid(objs));
                    end
                    if length(objs) < 1; output = [starter Text '[empty]'];
                    else; output = [starter Text '[...]'];
                    end
                case 'Configureobj'
                    output = [starter Text ': [' Item.name ']'];
                case 'Pickobj'
                    % info is the list of frames
                    output = [starter class(Item) ': ' Item.name];
                case 'Pickfunction'
                    if isempty(Item)
                        output = [starter Text ': [...]'];
                    else
                        output = [starter Text ': [@' func2str(Item) ']'];
                    end
                case 'Function'
                    output = [starter Text];
                case 'Deleteobj'
                    output = [starter Text];
                case 'NamedList'
                    if isempty(Item); output = [starter Text '[empty]'];
                    else; output = [starter Text '[...]'];
                    end
                case 'TrueFalse'
                    if get(this.Parent, this.Child)
                        output = [starter Text ': [' 'True' ']'];
                    else
                        output = [starter Text ': [' 'False' ']'];
                    end
            end
        end

        function [indicator] = isExpandable(this)
            switch this.MODE
                case {'Expandobj', 'Expandlist'}
                    indicator = true;
                otherwise
                    indicator = false;
            end
        end
    end

end

