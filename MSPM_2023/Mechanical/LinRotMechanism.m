classdef LinRotMechanism < handle
    % models a mechanism that converts linear
    % reciprocating motion into rotational motion.
    % contains a pointer to the Model

    properties (Constant)
        g = 9.81;
        Source = {...
            'Ideal Sinusoid';
            'Custom Profile Mechanism';
            'Slider Crank'};
        %       'Scotch Yoke';
        %       'Ross Yoke';
        %       'Rhombic Drive'};
        StrokeText = 'Stroke (m)';
        PhaseText = 'Phase (rad)';
        PistonMassText = 'Piston Mass (kg)';
        TiltAngleText = 'Tilt from Hor. (rad)';
        %Matthias: Wrote below 'OrientationText' to be more clear. Cannot use it
        %with old models as their mechanisms have the old text saved in them so the
        %'orientation' property will not be found if looking for the new one.
        %     OrientationText = 'Orientation: "u" starting at top position, "d" starting at bottom position (as modeled)'; %changed by Matthias
        OrientationText = 'Orientation: "u" aligned with positive y, "d" opposite';
        EfficiencyText = 'Mechanical Efficiency (0.##)';
        %     isPropertyEditable ...
        %       = {'Stroke (m)', 'Phase (rad)', 'Weight (kg)', 'Tilt from Hor. (rad)', 'Aspect Ratio', 'Custom Profile Fcn';
        %          true        , true         , true         , true                  , false         , true                ;
        %          true        , true         , true         , true                  , true          , false               ;
        %          true        , true         , true         , true                  , false         , false               };

    end

    properties
        ID;
        Model Model;

        isValid logical = true;
        Type char;
        Stroke double = [];
        Phase double = [];
        Frames Frame;

        STilt double;
        CTilt double;
        %     lengths double = [];
        %     masses double = [];
        %     descriptions char = [];

        originalInput = [];

        outputFcn function_handle;

        Data;

        dont_propegate logical = false;

    end

    properties (Dependent)
        name;
    end

    methods (Static)
        function [Source, Instructions, Widths] = GetPropertyTableSource(Type,originalSource)
            switch Type
                case 'Ideal Sinusoid'
                    Source = {...
                        LinRotMechanism.StrokeText, ...
                        LinRotMechanism.PhaseText, ...
                        LinRotMechanism.PistonMassText, ...
                        'Other Mass (kg)', ...
                        LinRotMechanism.TiltAngleText, ...
                        LinRotMechanism.OrientationText, ...
                        LinRotMechanism.EfficiencyText};
                    Source = AddRow(Source,1);
                    Instructions = [...
                        'The ideal Sinusoid produces N frictionless osscilating ' ...
                        'mass mechanism that follows a perfect sinusoidal motion. ' ...
                        'This is best used when the mechanism is unknown or seal ' ...
                        'and pumping losses are much greater than mechanism friction.'];
                case 'Custom Profile Mechanism'
                    Source = {...
                        LinRotMechanism.StrokeText, ...
                        LinRotMechanism.PhaseText, ...
                        LinRotMechanism.PistonMassText, ...
                        'Other Mass (kg)', ...
                        'Mech. Mom. Inert. (kg m^2)', ...
                        LinRotMechanism.TiltAngleText, ...
                        'Custom Profile Fcn', ...
                        LinRotMechanism.OrientationText, ...
                        LinRotMechanism.EfficiencyText};
                    Source = AddRow(Source,1);
                    Instructions = [...
                        'The Custom Profile Mechanism produces N simulated osscilating ' ...
                        'mass mechanism that follow a custom motion profile. ' ...
                        'Piston Mass includes the mass of any attached components. ' ...
                        'The user has the option to simulate the mass effects of ' ...
                        'non-circular gear pairs or cam drives.'];
                case 'Slider Crank'
                    Source = {...
                        LinRotMechanism.StrokeText, ...
                        LinRotMechanism.PhaseText, ...
                        'Crank Mass (kg)', ...
                        'Crank C.O.M Radius (m)', ...
                        'Crank C.O.M Angle (rad)', ...
                        'Crank Rot. Inertia (kgn^2)',...
                        'Crank-Con Fric. Fcn', ...
                        'Con Length (m)' , ...
                        'Con. Mass (kg)', ...
                        'Con. C.O.M Radius from CR-CN pin (m)', ...
                        'Con. Rot. Inertia (kgn^2)',...
                        'Con-Piston Fric. Fcn', ...
                        LinRotMechanism.PistonMassText, ...
                        'Piston Fric. Fcn', ...
                        LinRotMechanism.TiltAngleText, ...
                        'Slider-Offset (m)', ...
                        LinRotMechanism.OrientationText};
                    Source = AddRow(Source,1);
                    Instructions = [...
                        'The slider crank produces N psuedo sinusoidal motions. ' ...
                        'It auto-defines mechanism lengths based on ' ...
                        'Stroke and Aspect Ratio. Piston, Crank and Connecting Arm ' ...
                        'Masses are by default placed in the center of their bars; ' ...
                        'the user can modify this location or choose the ' ...
                        'AutoBalance option. Friction Fcns take an input of a normal '...
                        'force and provide back a opposing force.'];
                    %         case 'Scotch Yoke'
                    %           Source = {...
                    %             LinRotMechanism.StrokeText, ...
                    %             LinRotMechanism.PhaseText, ...
                    %             LinRotMechanism.PistonMassText, ...
                    %             'Crank Mass (kg)', ...
                    %             'Crank Length (m)', ...
                    %             'Crank C.O.M Radius (m)', ...
                    %             'Crank C.O.M Angle (rad)', ...
                    %             'Roller Fric. Fcn', ...
                    %             'Linear Bearing Fric. Fcn', ...
                    %             'Mech. Mom. Inter. (kg m^2)', ...
                    %             LinRotMechanism.TiltAngleText
                    %             LinRotMechanism.OrientationText};
                    %           Source = AddRow(Source,1);
                    %           Instructions = [...
                    %             'The scotch yoke produces N perfect sinusoidal motions. ' ...
                    %             'It auto-defines mechanism lengths based on ' ...
                    %             'Stroke. Crank structural masses are placed in the center ' ...
                    %             'of its bar, the user can modify this location or choose ' ...
                    %             'the AutoBalance option. Piston Mass includes the mass of ' ...
                    %             'attached components. Friction Fcns take an input of a ' ...
                    %             'normal force and provide back an opposing force.'];
                    %         case 'Rhombic Drive'
                    %           Source = {...
                    %             LinRotMechanism.StrokeText, ...
                    %             LinRotMechanism.PhaseText, ...
                    %             'Crank Mass (kg)', ...
                    %             'Crank C.O.M Radius (m)', ...
                    %             'Crank C.O.M Angle (rad)', ...
                    %             'Crank Rot. Inertia (kgn^2)',...
                    %             'Crank-Con Fric. Fcn', ...
                    %             'Con Length (m)' , ...
                    %             'Con. Mass (kg)', ...
                    %             'Con. C.O.M Radius from CR-CN pin (m)', ...
                    %             'Con. Rot. Inertia (kgn^2)',...
                    %             'Con-Piston Fric. Fcn', ...
                    %             LinRotMechanism.PistonMassText, ...
                    %             'Piston Fric. Fcn', ...
                    %             LinRotMechanism.TiltAngleText, ...
                    %             'Slider-Offset (m)', ...
                    %             LinRotMechanism.OrientationText};
                    %           Source = AddRow(Source,1);
                    %           Instructions = [...
                    %             'The rhombic drive is a type of slider crank mechanism ' ...
                    %             'that uses 2 sets of cranks that are mirrored in such a ' ...
                    %             'way that they have 0 side loads. The Type of Rhombic ' ...
                    %             'drive used in Beta Type Stirling engines contains two ' ...
                    %             'sets one of which is phased at 180 degrees relative and ' ...
                    %             'of opposite orientation.'];
            end
            if nargin > 1
                % Then try to prefill it as best as you can
                Source = MergeTables(Source,originalSource);
            end
            for col = size(Source,2):-1:1
                Widths{col} = length(Source{1,col})*6;
            end
        end
    end

    methods
        function this = LinRotMechanism(Model,Type,PropertyTable)
            if nargin > 1
                this.Model = Model;
                this.ID = Model.getLRMID();
                this.Populate(Type,PropertyTable);
            end
        end
        function deReference(this)
            % Get index of this LinRotMechanism
            ind = 1;
            for iLinRotMech = this.Model.Converters
                if iLinRotMech == this; break;
                else; ind = ind + 1;
                end
            end

            for iGroup = this.Model.Groups
                for iCon = this.Model.Connections
                    if ~isempty(iCon.RefFrame)
                        if iCon.RefFrame.Mechanism == ind
                            iCon.RefFrame = [];
                            iCon.change();
                        end
                    end
                end
            end

            for i = length(this.Model.RefFrames):-1:1
                if this.Model.RefFrames(i).Mechanism == ind
                    this.Model.RefFrames(i) = [];
                elseif this.Model.RefFrames(i).Mechanism > ind
                    this.Model.RefFrames(i).Mechanism = ...
                        this.Model.RefFrames(i).Mechanism - 1;
                end
            end

            this.Model.Converters(ind) = [];
            this.Model.change();
            this.delete();
        end

        %%
        function Populate(this,Type,PropertyTable)
            if isempty(this.ID)
                this.ID = this.Model.getLRMID();
            end
            this.Data = struct.empty;
            this.Type = Type;
            this.originalInput = PropertyTable;
            LEN = size(PropertyTable,1)-1;
            if isempty(this.Frames)
                this.Frames(LEN) = Frame();
            elseif length(this.Frames) < LEN
                % Chop off
                for i = length(this.Frames):-1:LEN+1
                    this.Frames(i).deReference();
                    this.Frames(i) = [];
                end
            elseif length(this.Frames) > LEN
                % Top up
                this.Frames(LEN) = Frame();
            end
            this.populateTilt();
            for i = 1:LEN
                newValue = str2double(FindInTable(this,this.StrokeText,i+1));
                if length(this.Stroke) >= i
                    shift = newValue - this.Stroke(i);
                    if shift ~= 0
                        % Stroke
                        if ~this.dont_propegate && this.Model.RelationOn
                            for iGroup = this.Model.Groups
                                for RMan = iGroup.RelationManagers
                                    if RMan.Orient == enumOrient.Horizontal
                                        maxconPiston = Connection.empty;
                                        maxconStroke = Connection.empty;
                                        maxxPiston = -inf;
                                        maxxStroke = -inf;
                                        for rel = RMan.Relations
                                            if ~isempty(rel.frame) && ...
                                                    rel.frame == this.Frames(i)
                                                switch rel.mode
                                                    case enumRelation.Piston
                                                        if rel.con1.x > maxxPiston
                                                            maxxPiston = rel.con1.x;
                                                            maxconPiston = rel.con1;
                                                        end
                                                        if rel.con2.x > maxxPiston
                                                            maxxPiston = rel.con2.x;
                                                            maxconPiston = rel.con2;
                                                        end
                                                    case enumRelation.Stroke
                                                        if rel.con1.x > maxxStroke
                                                            maxxStroke = rel.con1.x;
                                                            maxconStroke = rel.con1;
                                                        end
                                                        if rel.con2.x > maxxStroke
                                                            maxxStroke = rel.con2.x;
                                                            maxconStroke = rel.con2;
                                                        end
                                                end
                                            end
                                        end
                                        success = true;
                                        if ~isempty(maxconStroke)
                                            [success, ~] = ...
                                                RMan.Edit(maxconStroke, shift);
                                        end
                                        if success && ...
                                                isempty(maxconStroke) && ~isempty(maxconPiston)
                                            [success, ~] = ...
                                                RMan.Edit(maxconPiston, -shift);
                                        end
                                        if ~success
                                            fprintf(['XXX Could not edit mechanism ' ...
                                                'due to geometric conflict XXX\n']);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                this.Stroke(i) = newValue;
            end
            this.dont_propegate = false;
            switch Type
                case {'Ideal Sinusoid', 'Custom Profile Mechanism'}
                    for i = 1:LEN
                        Im1 = 0;
                        % Find Properties
                        % Phase
                        this.Phase(i) = str2double(FindInTable(this,this.PhaseText,i+1));
                        % Piston Mass
                        mp = str2double(FindInTable(this,this.PistonMassText,i+1));
                        % Other Mass
                        m1 = str2double(FindInTable(this,'Other Mass (kg)',i+1));
                        % Tilt is already covered
                        % Orientation
                        orientation = FindInTable(this,LinRotMechanism.OrientationText,i+1);
                        switch orientation
                            case 'u'; orient = 1;
                            case 'd'; orient = -1;
                            otherwise; orient = nan();
                        end
                        % Mechanical Efficiency
                        eff = str2double(FindInTable(this,LinRotMechanism.EfficiencyText,i+1));

                        if strcmp(Type,'Custom Profile Mechanism')
                            CustomFcn = str2func(FindInTable(this,'Custom Profile Fcn',i+1));
                            fh = functions(CustomFcn);
                            isFcnValid = ~isempty(fh.file);
                        else
                            isFcnValid = true;
                        end
                        if isnan(this.Stroke(i)) || isnan(this.Phase(i)) || ...
                                isnan(mp) || isnan(m1) || isnan(orient) ||...
                                isnan(eff) || ~isFcnValid
                            fprintf(...
                                ['XXX ' Type ' is invalid, Frames not created. Trouble Components below. XXX\n']);
                            if isnan(this.Stroke(i))
                                fprintf(...
                                    ['Stroke = ' FindInTable(this,this.StrokeText,i+1) '\n']);
                            end
                            if isnan(this.Phase(i))
                                fprintf(...
                                    ['Phase = ' FindInTable(this,this.PhaseText,i+1) '\n']);
                            end
                            if isnan(mp)
                                fprintf(...
                                    ['mp = ' FindInTable(this,this.PistonMassText,i+1) '\n']);
                            end
                            if isnan(m1)
                                fprintf(...
                                    ['m1 = ' FindInTable(this,'Other Mass (kg)',i+1) '\n']);
                            end
                            if isnan(orient)
                                fprintf(...
                                    ['Orient = ' orientation '\n']);
                            end
                            if isnan(eff)
                                fprintf(...
                                    ['Eff. = ' FindInTable(this,this.EfficiencyText,i+1) '\n']);
                            end
                            if isFcnValid
                                fprintf(...
                                    ['Fcn. = ' FindInTable(this,'Custom Profile Fcn',i+1) '\n']);
                            end
                            this.isValid = false;
                            return;
                        end
                        %% Define motion of Frames
                        if strcmp(Type,'Custom Profile Mechanism')
                            CustomProfile = CustomFcn(Frame.NTheta,this.Phase(i));
                        else
                            Ang = (0:Frame.NTheta-1)/(Frame.NTheta-1)*2*pi + this.Phase(i);
                            CustomProfile = this.Stroke(i)/2 + this.Stroke(i)*cos(Ang)/2;
                        end
                        if orient == 1
                            xmin = min(CustomProfile);
                            xmax = max(CustomProfile);
                        else
                            xmin = max(CustomProfile);
                            xmax = min(CustomProfile);
                        end
                        this.Frames(i).Positions = (CustomProfile-xmin).*...
                            (this.Stroke(i)/(xmax-xmin));
                        this.Frames(i).MechanismIndex = i;
                        this.Frames(i).Mechanism = this;
                        defineDataFromMotionProfile(Im1,mp,m1,eff,orient,this,i); % (Im1,mp,m1,eff,this,ind)
                    end
                case 'Slider Crank'
                    Ang = zeros(LEN,Frame.NTheta);
                    for i = 1:LEN
                        % Phase
                        this.Phase(i) = str2double(FindInTable(this,this.PhaseText,i+1));
                        Ang(i,:) = (0:Frame.NTheta-1)/(Frame.NTheta-1)*2*pi + this.Phase(i);
                    end
                    % Added by Matthias, Nov 17 2021, to fix error on line 420. %%%%%
                    this.Data = struct('F12',[]);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for i = 1:LEN
                        d1 = this.Stroke(i);
                        % Crank Mass (kg)
                        m1 = str2double(FindInTable(this,'Crank Mass (kg)',i+1));
                        % Crank C.O.M Radius (m)
                        r1 = str2double(FindInTable(this,'Crank C.O.M Radius (m)',i+1));
                        % Crank C.O.M Angle (rad)
                        Ang_g1 = str2double(FindInTable(this,'Crank C.O.M Angle (rad)',i+1));
                        % Crank Rot. Inertia (kgn^2)
                        Im1 = str2double(FindInTable(this,'Crank Rot. Inertia (kgn^2)',i+1));
                        % Crank-Con Fric. Fcn
                        this.Data.F12{i} = str2func(FindInTable(this,'Crank-Con Fric. Fcn',i+1));
                        fh = functions(this.Data.F12{i});
                        isF12Valid = ~isempty(fh.file);
                        % Con Length (m)
                        d2 = str2double(FindInTable(this,'Con Length (m)',i+1));
                        % Con. Mass (kg)
                        m2 = str2double(FindInTable(this,'Con. Mass (kg)',i+1));
                        % Con. C.O.M Radius from CR-CN pin (m)
                        r2 = str2double(FindInTable(this,'Con. C.O.M Radius from CR-CN pin (m)',i+1));
                        % Con. Rot. Inertia (kgn^2)
                        Im2 = str2double(FindInTable(this,'Con. Rot. Inertia (kgn^2)',i+1));
                        % Con-Piston Fric. Fcn
                        this.Data.F23{i} = str2func(FindInTable(this,'Con-Piston Fric. Fcn',i+1));
                        fh = functions(this.Data.F23{i});
                        isF23Valid = ~isempty(fh.file);
                        % Piston Mass (kg)
                        m3 = str2double(FindInTable(this,'Piston Mass (kg)',i+1));
                        % Piston Fric. Fcn
                        this.Data.F3{i} = str2func(FindInTable(this,'Piston Fric. Fcn',i+1));
                        fh = functions(this.Data.F3{i});
                        isF3Valid = ~isempty(fh.file);
                        % Tilt Angle
                        Tilt = str2double(FindInTable(this,LinRotMechanism.TiltAngleText,i+1));
                        % Slider-Offset (m)
                        d3 = str2double(FindInTable(this,'Slider-Offset (m)',i+1));
                        % Orientation: "u" aligned with positive y, "d" opposite
                        % Edited by Matthias, Nov 17 2021 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        orientation = FindInTable(this, this.OrientationText, i+1);
                        %             orientation = FindInTable(this,'Orientation: "u" aligned with positive y, "d" opposite',i+1);
                        %             orientation = str2double(FindInTable(this,'Orientation: "u" aligned with positive y, "d" opposite',i+1));
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        switch orientation
                            case 'u'; orient = 1;
                            case 'd'; orient = -1;
                            otherwise; orient = nan();
                        end

                        if isnan(d1) || isnan(this.Phase(i)) || isnan(m1) || ...
                                isnan(r1) || isnan(Ang_g1) || isnan(Im1) || ...
                                ~isF12Valid || isnan(d2) || isnan(m2) || ...
                                isnan(r2) || isnan(Im2) || ~isF23Valid || ...
                                isnan(m3) || ~isF3Valid || isnan(Tilt) || ...
                                isnan(d3) || isnan(orient)
                            fprintf(...
                                ['XXX ' Type ' is invalid, Frames not created. Trouble Components below. XXX\n']);
                            if isnan(d1)
                                fprintf(...
                                    ['Stroke = ' FindInTable(this,this.StrokeText,i+1) '\n']);
                            end
                            if isnan(this.Phase(i))
                                fprintf(...
                                    ['Phase = ' FindInTable(this,this.PhaseText,i+1) '\n']);
                            end
                            if isnan(m1)
                                fprintf(...
                                    ['Crank Mass (kg) = ' FindInTable(this,'Crank Mass (kg)',i+1) '\n']);
                            end
                            if isnan(r1)
                                fprintf(...
                                    ['Crank C.O.M Radius (m) = ' FindInTable(this,'Crank C.O.M Radius (m)',i+1) '\n']);
                            end
                            if isnan(Ang_g1)
                                fprintf(...
                                    ['Crank C.O.M Angle (rad) = ' FindInTable(this,'Crank C.O.M Angle (rad)',i+1)]);
                            end
                            if isnan(Im1)
                                fprintf(...
                                    ['Crank Rot. Inertia (kgn^2) = ' FindInTable(this,'Crank Rot. Inertia (kgn^2)',i+1) '\n']);
                            end
                            if isF12Valid
                                fprintf(...
                                    ['Crank-Con Fric. Fcn = ' FindInTable(this,'Crank-Con Fric. Fcn',i+1) '\n']);
                            end
                            if isnan(d2)
                                fprintf(...
                                    ['Con Length (m) = ' FindInTable(this,'Con Length (m)',i+1) '\n']);
                            end
                            if isnan(m2)
                                fprintf(...
                                    ['Con. Mass (kg) = ' FindInTable(this,'Con. Mass (kg)',i+1) '\n']);
                            end
                            if isnan(r2)
                                fprintf(...
                                    ['Con. C.O.M Radius from CR-CN pin (m) = ' FindInTable(this,'Con. C.O.M Radius from CR-CN pin (m)',i+1) '\n']);
                            end
                            if isnan(Im2)
                                fprintf(...
                                    ['Con. Rot. Inertia (kgn^2) = ' FindInTable(this,'Con. Rot. Inertia (kgn^2)',i+1) '\n']);
                            end
                            if isF23Valid
                                fprintf(...
                                    ['Con-Piston Fric. Fcn = ' FindInTable(this,'Con-Piston Fric. Fcn',i+1) '\n']);
                            end
                            if isnan(m3)
                                fprintf(...
                                    ['Piston Mass (kg) = ' FindInTable(this,'Piston Mass (kg)',i+1) '\n']);
                            end
                            if isF3Valid
                                fprintf(...
                                    ['Piston Fric. Fcn = ' FindInTable(this,'Piston Fric. Fcn',i+1) '\n']);
                            end
                            if isnan(Tilt)
                                fprintf(...
                                    [LinRotMechanism.TiltAngleText ' = ' FindInTable(this,LinRotMechanism.TiltAngleText,i+1) '\n']);
                            end
                            if isnan(d3)
                                fprintf(...
                                    ['Slider-Offset (m) = ' FindInTable(this,'Slider-Offset (m)',i+1) '\n']);
                            end
                            if isnan(orient)
                                fprintf(...
                                    [this.OrientationText ' = ' orientation '\n']);
                            end
                            this.isValid = false;
                            return;
                        end

                        % Theta_SC is defined as Ang(i,:)
                        Ang_sc = Ang(i,:)';
                        C1 = cos(Ang_sc);
                        S1 = sin(Ang_sc);
                        Beta_sc = asin((d3 - d1*S1)/d2);
                        C2 = cos(Beta_sc);
                        S2 = sin(Beta_sc);
                        Beta_g = Beta_sc + Tilt;
                        Ang_g = Ang_sc + Tilt + Ang_g1;
                        this.Data.T2(:,i) = tan(Beta_sc);

                        % Coefficients on Alpha_2
                        C_Omega2 = (-d1/d2).*(C1./C2);
                        this.Data.Omega2(:,i) = C_Omega2;
                        B_Alpha2 = ((d1*S1+d2*S2.*C_Omega2.^2)./(d2*C2));

                        % Coefficients on Acceleration 1 x
                        B_a1x = -r1*cos(Ang_sc + Ang_g1);
                        C_a1x = -r1*sin(Ang_sc + Ang_g1);

                        % Coefficients on Acceleration 1 y
                        B_a1y = -r1*sin(Ang_sc + Ang_g1);
                        C_a1y = r1*cos(Ang_sc + Ang_g1);

                        % Coefficients on Acceleration 2 x
                        B_a2x = (-d1*C1 - r2*C2.*C_Omega2.^2 - r2*S2.*B_Alpha2);
                        C_a2x = (-d1*S1 - r2*S2.*C_Omega2);

                        % Coefficients on Acceleration 2 y
                        B_a2y = (-d1*S1 - r2*S2.*C_Omega2.^2 + r2*C2.*B_Alpha2);
                        C_a2y = (d1*C1 + r2*C2.*C_Omega2);

                        % Coefficients on Acceleration 3 x
                        B_a3x = (-d1*C1 - d2*C2.*C_Omega2.^2 - d2*S2.*B_Alpha2);
                        C_a3x = (-d1*S1 - d2*S2.*C_Omega2);

                        % Piston Position & Velocity Coefficient on Omega
                        this.Data.x_p(:,i) = d1*C1 + d2*C2 - sqrt((d2-d1)^2 - d3^2);
                        this.Data.v_p(:,i) = -d1*S1 - d2*S2.*C_Omega2;

                        this.Data.A1(:,i) = m3*C_a3x;
                        this.Data.A2(:,i) = m2*C_a2x + this.Data.A1(:,i);
                        this.Data.A3(:,i) = (-Im2*C_Omega2./(d2*C2) + this.Data.T2(:,i).*this.Data.A1(:,i));
                        this.Data.A4(:,i) = m2*C_a2y + this.Data.A3(:,i);
                        this.Data.A5(:,i) = m1*C_a1x + this.Data.A2(:,i);
                        this.Data.A6(:,i) = m1*C_a1y + this.Data.A4(:,i);

                        this.Data.B1(:,i) = m3*B_a3x;
                        this.Data.B2(:,i) = m2*B_a2x + this.Data.B1(:,i);
                        this.Data.B3(:,i) = (-Im2*B_Alpha2./(d2*C2) + this.Data.T2(:,i).*this.Data.B1(:,i));
                        this.Data.B4(:,i) = m2*B_a2y + this.Data.B3(:,i);
                        this.Data.B5(:,i) = m1*B_a1x + this.Data.B2(:,i);
                        this.Data.B6(:,i) = m1*B_a1y + this.Data.B4(:,i);

                        this.Data.G1(:,i) = this.g*m3*this.STilt(i);
                        this.Data.G2(:,i) = this.g*m2*this.STilt(i) + this.Data.G1(:,i);
                        this.Data.G3(:,i) = (-this.g*r2*cos(Beta_g)./(d2*C2) + this.Data.T2(:,i).*this.Data.G1(:,i));
                        this.Data.G4(:,i) = this.g*m2*cos(Beta_g) + this.Data.G3(:,i);
                        temp_G5 = this.g*m1*this.STilt(i) + this.Data.G2(:,i);
                        %             this.Data.G5(:,i) = this.g*m1*this.STilt(i) + this.Data.G2(:,i);
                        this.Data.G6(:,i) = this.g*m1*this.CTilt(i) + this.Data.G4(:,i);

                        temp_5 = -this.CTilt(i)*this.Data.A5(:,i) + this.STilt(i)*this.Data.A6(:,i);
                        this.Data.A6(:,i) = -this.STilt(i)*this.Data.A5(:,i) - this.CTilt(i)*this.Data.A6(:,i);
                        this.Data.A5(:,i) = temp_5;

                        temp_5 = -this.CTilt(i)*this.Data.B5(:,i) + this.STilt(i)*this.Data.B6(:,i);
                        this.Data.B6(:,i) = -this.STilt(i)*this.Data.B5(:,i) - this.CTilt(i)*this.Data.B6(:,i);
                        this.Data.B5(:,i) = temp_5;

                        temp_5 = -this.CTilt(i)*temp_G5 + this.STilt(i)*this.Data.G6(:,i);
                        this.Data.G6(:,i) = -this.STilt(i)*temp_G5 - this.CTilt(i)*this.Data.G6(:,i);
                        %             temp_5 = -this.CTilt(i)*this.Data.G5(:,i) + this.STilt(i)*this.Data.G6(:,i);
                        %             this.Data.G6(:,i) = -this.STilt(i)*this.Data.G5(:,i) - this.CTilt(i)*this.Data.G6(:,i);
                        this.Data.G5(:,i) = temp_5;

                        %%%%%%%%%%%%Stuck on following line. What is 'Inc'? %%%%%%%%%%%%%%%%%%%%%%%
                        this.Data.E5(:,i) = orient*(-this.CTilt(i) + this.STilt(i)*this.Data.T2(:,i));
                        this.Data.E6(:,i) = orient*(-this.STilt(i) - this.CTilt(i)*this.Data.T2(:,i));

                        this.Data.AM(:,i) = -(Im1 - d1*S1.*this.Data.A2(:,i) + d1*C1.*this.Data.A4(:,i));
                        this.Data.BM(:,i) = -(-d1*S1.*this.Data.B2(:,i) + d1*C1.*this.Data.B4(:,i));
                        this.Data.GM(:,i) = -(this.g*m1*r1*cos(Ang_g) - ...
                            d1*S1.*this.Data.A2(:,i) + d1*C1.*this.Data.A4(:,i));
                        this.Data.EM(:,i) = orient*-1*(-d1*S1 + d1*C1*this.Data.T2(:,i));
                        this.outputFcn = @this.SliderCrank;

                        if strcmp(Type,'Custom Profile Mechanism')
                            CustomProfile = CustomFcn(Frame.NTheta,this.Phase(i));
                        else
                            Ang = (0:Frame.NTheta-1)/(Frame.NTheta-1)*2*pi + this.Phase(i);
                            CustomProfile = this.Stroke(i)/2 + this.Stroke(i)*cos(Ang)/2;
                        end
                        if orient == 1
                            xmin = min(CustomProfile);
                            xmax = max(CustomProfile);
                        else
                            xmin = max(CustomProfile);
                            xmax = min(CustomProfile);
                        end
                        this.Frames(i).Positions = (CustomProfile-xmin).*...
                            (this.Stroke/(xmax-xmin));
                        this.Frames(i).MechanismIndex = i;
                        this.Frames(i).Mechanism = this;
                    end
                    %         case 'Scotch Yoke'
                    %           Ang = zeros(LEN,Frame.NTheta);
                    %           for i = 1:LEN
                    %             Ang(i,:) = (0:Frame.NTheta-1)/(Frame.NTheta-1)*2*pi + this.Phase(i);
                    %           end
                    %           for i = 1:LEN
                    %
                    %           end
                    %         case 'Rhombic Drive'
                    %
            end
        end
        function Modify(this)
            persistentData = Holder({this.Type,this.originalInput});
            h = CreateMechanismInterface(persistentData);
            uiwait(h);
            if isempty(persistentData.vars)
                this.deReference();
            else
                this.Populate(persistentData.vars{1},persistentData.vars{2});
            end

            % Find all Connections that have frames that reference this index
            for iGroup = this.Model.Groups
                for iCon = iGroup.Connections
                    if ~isempty(iCon.RefFrame)
                        if iCon.RefFrame.Mechanism == this
                            iCon.change();
                        end
                    end
                end
            end
        end

        %% Get/Set Interface
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'Name'
                    Item = this.name;
                case 'Stroke'
                    if size(this.originalInput,1)-1 == 1
                        for c = 1:size(this.originalInput,2)
                            if contains(this.originalInput{1,c},'Stroke')
                                if isStrNumeric(this.originalInput{2,c})
                                    Item = str2double(this.originalInput{2,c});
                                    return;
                                end
                            end
                        end
                    else
                        fprintf(['XXX Gradient Descent does ' ...
                            'not support mechanisms with ' ...
                            'multiple strokes XXX\n']);
                        return;
                    end
                otherwise
                    fprintf(['XXX Lin Rot Mechanism GET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'Stroke'
                    if size(this.originalInput,1)-1 == 1
                        for c = 1:size(this.originalInput,2)
                            if contains(this.originalInput{1,c},'Stroke')
                                if isStrNumeric(this.originalInput{2,c})
                                    this.originalInput{2,c} = num2str(Item);
                                    return;
                                end
                            end
                        end
                        this.Populate(this.Type,this.originalInput);
                    else
                        fprintf(['XXX Gradient Descent does ' ...
                            'not support mechanisms with ' ...
                            'multiple strokes XXX\n']);
                        return;
                    end
                otherwise
                    fprintf(['XXX Lin Rot Mechanism SET Inteface for ' PropertyName ...
                        ' is not found XXX\n']);
            end
        end

        function Uniform_Scale(this, Uniform_Scale)
            for c = 1:size(this.originalInput,2)
                if contains(this.originalInput{1,c},'(m)')
                    factor = Uniform_Scale;
                elseif contains(this.originalInput{1,c},'(kg)')
                    factor = Uniform_Scale ^ 3;
                elseif contains(this.originalInput{1,c},'(kg m^2)')
                    factor = Uniform_Scale ^ 5;
                else
                    continue;
                end
                for r = 2:size(this.originalInput,1)
                    if isStrNumeric(this.originalInput{r,c})
                        this.originalInput{r,c} = ...
                            num2str(...
                            factor * str2double(this.originalInput{r,c}));
                    end
                end
            end
            this.dont_propegate = true;
            this.Populate(this.Type,this.originalInput);
        end

        %% Dependent
        function var = get.name(this)
            var = this.Type;
            for i = 1:length(this.Stroke)
                var = [var ' ' num2str(i) ':(L=' num2str(this.Stroke(i)) ', P=' num2str(this.Phase(i)) ')'];
            end
        end

        %% Internal Helpers
        function populateTilt(this)
            for i = 2:size(this.originalInput,1)
                Tilt = str2double(FindInTable(this,this.TiltAngleText,i));
                if isnan(Tilt)
                    fprintf('XXX Invalid value for Tilt from Horizontal, perfectly horizontal assumed. XXX\n');
                    ReplaceInTable(this,'0',this.TiltAngleText,i)
                    this.STilt(i-1) = 0;
                    this.CTilt(i-1) = 1;
                else
                    this.STilt(i-1) = sin(Tilt);
                    this.CTilt(i-1) = cos(Tilt);
                end
            end
        end

        % Ideal Motions
        function defineDataFromMotionProfile(Im1,mp,m1,eff,~,this,ind)
            %% Define Loads
            dx_dtheta = getFirstDer(this.Frames(ind).Positions);
            d2x_dtheta2 = getSecondDer(this.Frames(ind).Positions);

            Ax = -this.CTilt(ind)*mp*dx_dtheta;
            Bx = -this.CTilt(ind)*mp*d2x_dtheta2;
            Gx = -this.g*(mp + m1)*this.STilt(ind);
            Ex = this.CTilt(ind); % * Fp

            Ay = -this.STilt(ind)*mp*dx_dtheta;
            By = -this.STilt(ind)*mp*d2x_dtheta2;
            Gy = -this.g*(mp + m1)*this.CTilt(ind);
            Ey = this.STilt(ind); % * Fp

            Am = -Im1 - mp*(dx_dtheta).^2;
            Bm = -mp*dx_dtheta.*d2x_dtheta2;
            Gm = -this.g*this.STilt(ind)*mp*dx_dtheta;
            Em = dx_dtheta; % * Fp

            if isfield(this.Data,'Ax')
                appendData(this,'Ax',Ax,ind);
                appendData(this,'Bx',Bx,ind);
                appendData(this,'Gx',Gx,ind);
                appendData(this,'Ex',Ex,ind);

                appendData(this,'Ay',Ay,ind);
                appendData(this,'By',By,ind);
                appendData(this,'Gy',Gy,ind);
                appendData(this,'Ey',Ey,ind);

                appendData(this,'Am',Am,ind);
                appendData(this,'Bm',Bm,ind);
                appendData(this,'Gm',Gm,ind);
                appendData(this,'Em',Em,ind);
                this.Data.Eff(ind) = eff;
            else
                this.Data = struct(...
                    'Ax',Ax,'Bx',Bx,'Gx',Bx,'Ex',Ex,...
                    'Ay',Ay,'By',By,'Gy',Gy,'Ey',Ey,...
                    'Am',Am,'Bm',Bm,'Gm',Gm,'Em',Em,...
                    'Eff',eff);
            end

            this.outputFcn = @this.MotionWithEfficiency;
        end

        function output = MotionWithEfficiency(this,input)
            % input = [dA, ddA, Fp, Inc, mechindex]
            % output = [Fx, Fy, M]
            output = zeros(3,1);
            inc = input(4);
            i = input(5);
            if inc > 1
                incp = inc - 1;
            else
                incp = size(this.Data.Ax,1) - 1;
            end

            % Horizontal Load, as felt by the drive shaft
            if size(this.Data.Gx,1) == 1
                output(1) = (this.Data.Ax(incp,i) + this.Data.Ax(inc,i))*input(2) + ...
                    (this.Data.Bx(incp,i) + this.Data.Bx(inc,i))*input(1)^2 + ...
                    2*this.Data.Gx(1,i) + ...
                    2*this.Data.Ex(i)*input(3);
            else
                output(1) = (this.Data.Ax(incp,i) + this.Data.Ax(inc,i))*input(2) + ...
                    (this.Data.Bx(incp,i) + this.Data.Bx(inc,i))*input(1)^2 + ...
                    (this.Data.Gx(incp,i) + this.Data.Gx(inc,i)) + ...
                    2*this.Data.Ex(i)*input(3);
            end

            % Vertical Load, as felt by the drive shaft\
            if size(this.Data.Gy,1) == 1
                output(2) = (this.Data.Ay(incp,i) + this.Data.Ay(inc,i))*input(2) + ...
                    (this.Data.By(incp,i) + this.Data.By(inc,i))*input(1)^2 + ...
                    2*this.Data.Gy(i) + ...
                    2*this.Data.Ey(i)*input(3);
            else
                output(2) = (this.Data.Ay(incp,i) + this.Data.Ay(inc,i))*input(2) + ...
                    (this.Data.By(incp,i) + this.Data.By(inc,i))*input(1)^2 + ...
                    (this.Data.Gy(incp,i) + this.Data.Gy(inc,i)) + ...
                    2*this.Data.Ey(i)*input(3);
            end

            % Moment as felt by shaft
            if (this.Data.Em(incp,i) + this.Data.Em(inc,i))*input(3) < 0
                % Power is leaving the flywheel
                output(3) =(this.Data.Am(incp,i) + this.Data.Am(inc,i))*input(2) + ...
                    (this.Data.Bm(incp,i) + this.Data.Bm(inc,i))*input(1)^2 + ...
                    (this.Data.Gm(incp,i) + this.Data.Gm(inc,i)) + ...
                    (this.Data.Em(incp,i) + this.Data.Em(inc,i))*input(3)/double(this.Data.Eff(i));
            else
                % Power is entering the flywheel
                output(3) =(this.Data.Am(incp,i) + this.Data.Am(inc,i))*input(2) + ...
                    (this.Data.Bm(incp,i) + this.Data.Bm(inc,i))*input(1)^2 + ...
                    (this.Data.Gm(incp,i) + this.Data.Gm(inc,i)) + ...
                    (this.Data.Em(incp,i) + this.Data.Em(inc,i))*input(3)*double(this.Data.Eff(i));
            end
            output = output / 2;
        end

        %{
    % Simplified Arbitrary Motions
function defineDataForComplexCustomProfile(L,Mp,Ip,Mr,Iconst,Eff,this,ind)
      dx_dtheta = getFirstDer(this.Frames(ind).Positions);
      d2x_dtheta2 = getSecondDer(this.Frames(ind).Positions);
      if Ip ~= 0
        % Gears
        A2 = asin_omni(this.Frames(ind).Positions/L - 1);
        dA2_dtheta = getFirstDer(A2);
        d2A2_dtheta2 = getSecondDer(A2);
        % Coefficient on omega1^2
        BddA2 = Ip.*d2A2_dtheta2;
        % Coefficient on alpha1
        AddA2 = -Ip.*dA2_dtheta;
      else
        % Cam Drive
        BddA2 = 0; % no pulsing rotational elements
        AddA2 = 0; % " " "
      end
      % C1 - Coeff on ddA for Fx as felt by drive shaft
      this.Data(1,:,ind) = -dx_dtheta;
      % C2 - Coeff on dA^2 for Fx as felt by drive shaft
      this.Data(2,:,ind) = -d2x_dtheta2;
      % C3 - Gravity contribution for Fx as felt by drive shaft
      this.Data(3,:,ind) = -this.STilt*this.g*(Mp + Mr);
      % C4 - Coeff on ddA for Fy
      this.Data(4,:,ind) = -this.CTilt*this.g*(Mr);
      % Maybe consider a pressure angle, but center distance also
      % required

      % C - Coeff on Fp for M
      this.Data(5,:,ind) = -dx_dtheta;
      % C - Coeff on ddA for M
      this.Data(6,:,ind) = (Mp.*(dx_dtheta.^2) - AddA2)*Eff;
      % C - Coeff on dA^2 for M
      this.Data(7,:,ind) = ...
        (-Mp.*(dx_dtheta).*(d2x_dtheta2) - BddA2)*Eff - Iconst;

      this.outputFcn = @this.CustomProfileMechanism;
    end
    
function output = CustomProfileMechanism(this,input)
      % input = [dA, ddA, Fp, Inc, mechindex]
      % output = [Fx, Fy, M]
      output = zeros(3,1);
      output(1) ...
        = input(3)... = Fp
        + this.Data(1,input(4))*input(2)... + C1*ddA
        + this.Data(2,input(4))*input(1)^2 ... + C2*dA^2
        + this.Data(3,input(4)); % + C3
      output(2) ... Vertical Load, as felt by the drive shaft
        = this.STilt*output(1);
      output(1) ... Horizontal Load, as felt by the drive shaft
        = this.CTilt*output(1);
      % M =
      output(3) ... Moment as felt by shaft
        = this.Data(4,input(4))*input(3)... % C4*Fp
        + this.Data(5,input(4))*input(2)... % C5*ddA
        + this.Data(6,input(4))*input(1)^2; % C6*dA^2
    end
        %}

        % Slider Crank
        function output = SliderCrank(this,input)
            % input = [dA, ddA, Fp, Inc, mechindex]
            % output = [Fx, Fy, M]
            dA = input(1);
            ddA = input(2);
            Fp = input(3);
            Inc = input(4);
            i = input(5);
            F12 = this.Data.F12{i}(sqrt((...
                this.Data.A2(Inc,i)*ddA + ...
                this.Data.B2(Inc,i)*dA^2 + ...
                this.Data.G2(Inc,i) + Fp)^2 + ...
                (this.Data.A4(Inc,i)*ddA + ...
                this.Data.B4(Inc,i)*dA^2 + ...
                this.Data.G4(Inc,i) - ...
                this.Data.T2(Inc,i)*Fp)^2));
            F3y = abs(this.Data.A3(Inc,i)*ddA + ...
                this.Data.B3(Inc,i)*dA^2 + ...
                this.Data.G3(Inc,i) - ...
                this.Data.T2(Inc,i)*Fp);
            F23 = this.Data.F23{i}(...
                sqrt((this.Data.A1(Inc,i)*ddA + ...
                this.Data.B1(Inc,i)*dA^2 + ...
                this.Data.G1(Inc,i) + Fp)^2 + (F3y)^2));
            F3y = this.Data.F3{i}(F3y);
            LostTorque = -dA*(...
                abs(F12*(this.Data.Omega2(Inc,i)-1)) + ...
                abs(F23*this.Data.Omega2(Inc,i)) + ...
                abs(F3y*this.Data.v_p(Inc,i)));

            output = zeros(3,1);
            output(1) = ... % Horizontal Load
                this.Data.A5(Inc,i)*ddA + this.Data.B5(Inc,i)*dA^2 + ...
                this.Data.G5(Inc,i) + ...
                this.Data.E5(Inc,i)*Fp;
            output(2) = ... % Vertical Load
                this.Data.A6(Inc,i)*ddA + this.Data.B6(Inc,i)*dA^2 + ...
                this.Data.G6(Inc,i) + ...
                this.Data.E6(Inc,i)*Fp;
            output(3) = ... % Moment as felt by shaft
                this.Data.AM(Inc,i)*ddA + this.Data.BM(Inc,i)*dA^2 + ...
                this.Data.GM(Inc,i) + this.Data.EM(Inc,i)*Fp + ...
                LostTorque;
        end

        function output = ScotchYoke(this,input)
            % input = [dA, ddA, Fp, Inc, mechindex]
            % output = [Fx, Fy, M]

        end

        function output = RhombicDrive(this,input)
            % input = [dA, ddA, Fp, Inc, mechindex]
            % output = [Fx, Fy, M]
            dA = input(1);
            ddA = input(2);
            Fp = input(3);
            Inc = input(4);
            i = input(5);
            F12 = this.Data.F12{i}(sqrt((...
                this.Data.A2(Inc,i)*ddA + ...
                this.Data.B2(Inc,i)*dA^2 + ...
                this.Data.G2(Inc,i) + Fp)^2 + ...
                (this.Data.A4(Inc,i)*ddA + ...
                this.Data.B4(Inc,i)*dA^2 + ...
                this.Data.G4(Inc,i) - ...
                this.Data.T2(Inc,i)*Fp)^2));
            F3y = abs(this.Data.A3(Inc,i)*ddA + ...
                this.Data.B3(Inc,i)*dA^2 + ...
                this.Data.G3(Inc,i) - ...
                this.Data.T2(Inc,i)*Fp);
            F23 = this.Data.F23{i}(...
                sqrt((this.Data.A1(Inc,i)*ddA + ...
                this.Data.B1(Inc,i)*dA^2 + ...
                this.Data.G1(Inc,i) + Fp)^2 + (F3y)^2));
            F3y = this.Data.F3{i}(F3y);

            % TANalpha_2L4 = tan(pressure angle)/(2*l4)

            output = zeros(3,1);
            output(3) = ... % Moment as felt by shaft
                this.Data.AM(Inc,i)*ddA + this.Data.BM(Inc,i)*dA^2 + ...
                this.Data.GM(Inc,i) + this.Data.EM(Inc,i)*Fp;
            output(1) = 0.5*(... % Horizontal Load
                this.Data.A5(Inc,i)*ddA + this.Data.B5(Inc,i)*dA^2 + ...
                this.Data.G5(Inc,i) + ...
                this.Data.E5(Inc,i)*Fp + ...
                output(3)*this.Data.TANalpha_2L4(i)*this.STilt(i));
            output(2) = 0.5*(... % Vertical Load
                this.Data.A6(Inc,i)*ddA + this.Data.B6(Inc,i)*dA^2 + ...
                this.Data.G6(Inc,i) + ...
                this.Data.E6(Inc,i)*Fp - ...
                output(3)*this.Data.TANalpha_2L4(i)*this.CTilt(i));

            LostTorque = -dA*(...
                abs(F12*(this.Data.Omega2(Inc,i)-1)) + ...
                abs(F23*this.Data.Omega2(Inc,i)) + ...
                abs(F3y*this.Data.v_p(Inc,i)) + ...
                abs(this.Data.Faux{i}(sqrt(output(1)^2+output(2)^2))));

            output(3) = output(3) + LostTorque;
        end
    end

end

function PropertyValue = FindInTable(LinRotMech,Item,row)
    for col = 1:size(LinRotMech.originalInput,2)
        if strcmp(LinRotMech.originalInput{1,col},Item)
            PropertyValue = LinRotMech.originalInput{row,col};
            return;
        end
    end
    fprintf(['XXX no property called "' Item '" for LinRotMechanism/Type = "' ...
        LinRotMech.Type '". Value of "" applied. XXX\n']);
    PropertyValue = '';
end

function ReplaceInTable(LinRotMech,PropertyValue,Item,row)
    for col = 1:size(LinRotMech.originalInput,2)
        if strcmp(LinRotMech.originalInput{1,col},Item)
            LinRotMech.originalInput{row,col} = PropertyValue;
            return;
        end
    end
    fprintf(['XXX no property called "' Item '" for LinRotMechanism/Type = "' ...
        LinRotMech.Type '". Value of "" applied. XXX\n']);
end

function Template = MergeTables(Template,Data)
    for Dcol = 1:size(Data,2)
        % For each column of Data
        % Find the representative column in Template
        for Tcol = 1:size(Template,2)
            if strcmp(Data{1,Dcol},Template{1,Tcol})
                for row = 2:size(Data,1)
                    Template{row,Tcol} = Data{row,Dcol};
                end
                break;
            end
        end
    end
end

function appendData(ME,field,Data,ind)
    if isfield(ME.Data,field)
        if size(ME.Data.(field),1) == size(Data,1)
            ME.Data.(field)(:,ind) = Data;
        elseif size(ME.Data.(field),1) == 1
            temp = repmat(ME.Data.(field),size(Data,1),1);
            ME.Data.(field) = temp;
            ME.Data.(field)(:,ind) = Data;
        elseif size(Data,1) == 1
            ME.Data.(field)(:,ind) = Data;
        else
            fprintf('XXX Frame divisions have changed, please implement a fix XXX\n');
        end
    else
        ME.Data.(field)(:,ind) = Data;
    end
end

