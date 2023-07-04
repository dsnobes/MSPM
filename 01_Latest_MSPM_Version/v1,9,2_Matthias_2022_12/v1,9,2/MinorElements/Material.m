classdef Material < handle
    % holds data about all possible materials that can be used
    % in parts of the model, specify a valid material name
    % and this defines a single material and its properties

    properties (Constant)
        Source = {...
            'Carbon Steel';
            'Forged Carbon Steel (Medium Carbon Steel)';
            '304 Stainless Steel';
            '6061 Aluminum';
            'Pure Copper';
            'Plastic, ABS';
            'Plastic, Acrylic';
            'Plastic, Polycarbonate (High Viscosity)';
            'Plastic, Poly-Ethylene (High Density)';
            'Plastic, Polyester (PET)';
            'Plastic, Polyetherimide (PEI / Ultem)';
            'Rubber, Polychloroprene (Neoprene)';
            'Rubber, Acrylonitrile-Butadiene (Nitrile)';
            'Rubber, Silicone';
            'Foam, Expanded Polystyrene';
            'Foam, Extruded Polystyrene';
            'Foam, Rigid Polyurethane';
            'Rigid Polyurethane Foam, General Plastics FR-4718';
            'AIR';
            'N2 Gas';
            'H2 Gas';
            'OLD Helium Gas';
            '100% Helium';  % Helium data aquired from NIST and interpolated with a 3rd degree polynomial
            '99% Helium';   % from 100-600K. dT_du(1/Cv) was approximated as a constant
            '95% Helium';
            '90% Helium';
            '85% Helium';
            '80% Helium';
            '50% Helium';
            'SIL 180 oil (as solid)'
            'Perfect Insulator';
            'Constant Temperature'};


        Gasses = {...
            'AIR';
            'N2 Gas';
            'H2 Gas';
            'OLD Helium Gas';
            '100% Helium';  % Helium data aquired from NIST and interpolated with a 3rd degree polynomial
            '99% Helium';   % from 100-600K. dT_du(1/Cv) was approximated as a constant
            '95% Helium';
            '90% Helium';
            '85% Helium';
            '80% Helium';
            '50% Helium';};
        
    end

    properties
        % General Properties
        name;
        Color double;
        Phase enumMaterial;
        ThermalConductivity double;
        dT_du double;   % 1/Cv [(kg*K)/J]
        dh_dT double;   % Cp [J/(kg*K)]
        u2T function_handle;
        Density double;

        % Gas Properties
        R double;
        dT_duFunc function_handle;
        dh_dTFunc function_handle;
        kFunc function_handle;
        muFunc function_handle;
        gammaFunc function_handle;

    end

    methods
        function this = Material(MaterialName)
            if nargin == 0
                return;
            end
            this.Configure(MaterialName)
        end
        function Modify(this)
            for index = 1:length(this.Source)
                if strcmp(this.Source{index},this.name)
                    break;
                end
            end
            index = listdlg('ListString',this.Source,...
                'SelectionMode','single',...
                'InitialValue',index);
            if ~isempty(index); this.Configure(this.Source{index}); end
        end

        function matl = ChooseGasType(this)
            % Function for selecting from the list of materials without changing any bodies
            for index = 1:length(this.Gasses)
                if strcmp(this.Gasses{index},this.name)
                    break;
                end
            end
            index = listdlg('ListString',this.Gasses,...
                'SelectionMode','single',...
                'InitialValue',index);

            matl = this.Gasses{index};
        end


        function Configure(this,MaterialName)
            % Matthias: moved this to end of function to be able to customize name in GUI
            %       this.name = MaterialName;

            % Thermal Conductivity
            % https://www.engineeringtoolbox.com/thermal-conductivity-d_429.html
            % All properties:
            % https://www.sciencedirect.com/book/9781895198478/handbook-of-polymers
            switch MaterialName
                case 'Carbon Steel' % Carbon Steel
                    this.Color = [0.400 0.384 0.384];% [102 98 98];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 43; % W/(m*K)
                    this.dT_du = 1/502.416; % J/(kg*K)
                    this.Density = 7850; % kg/(m^3)
                case 'Forged Carbon Steel (Medium Carbon Steel)'
                    % See Medium Carbon Steel - MatWeb.pdf
                    this.Color = [0.380 0.365 0.365];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 47.7; % W/(m*K)
                    this.dT_du = 1/477; % J/(kg*K)
                    this.Density = 7850; % kg/(m^3)
                case '304 Stainless Steel' % 304 Stainless Steel
                    this.Color = [0.510 0.526 0.537];% [130 134 137];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 14.4; % W/(m*K)
                    this.dT_du = 1/500; % J/(kg*K)
                    this.Density = 8000; % kg/(m^3)
                case '6061 Aluminum' % 6061 Aluminum
                    this.Color = [0.628 0.628 0.628];% [160 160 160];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 176.5; % 151-202 W/(m*K)
                    this.dT_du = 1/897; % J/(kg*K)
                    this.Density = 2700; % kg/(m^3)
                case 'Pure Copper' % Pure Copper
                    this.Color = [0.628 0.416 0.259];% [160 106 66];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 401; % W/(m*K) % At 0 C
                    this.dT_du = 1/385; % kg*K/J
                    this.Density = 8960; % kg/(m^3)
                case 'Plastic, ABS' % Acrylonitrile Butadiene Styrene
                    % http://www.substech.com/dokuwiki/doku.php?id=thermoplastic_acrylonitrile-butadiene-styrene_abs
                    % https://www.sciencedirect.com/topics/materials-science/acrylonitrile-butadiene-styrene
                    this.Color = [0.1 0.1 0.8]; % Blue
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 0.25; % W/(m*K)
                    this.dT_du = 1/1690; % Specific heat capacity	1,390	�	1,920	J/kg�K
                    this.Density = 1050;
                case 'Plastic, Acrylic'
                    % http://www.matweb.com/search/datasheet.aspx?bassnum=O1303&ckck=1
                    this.Color = [0.909 0.941 1]; %
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 0.198; % W/(m*K)
                    this.dT_du = 1/1810; % Specific heat capacity	1,460	�	2,160	J/kg�K
                    this.Density = 1185; % kg/(m^3)
                case 'Plastic, Polycarbonate (High Viscosity)'
                    % MatWeb
                    this.Color = [0.909 0.941 1]; %
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 0.198; % W/(m*K)
                    this.dT_du = 1/1810; % Specific heat capacity	1,460	�	2,160	J/kg�K
                    this.Density = 1200; % kg/(m^3)
                case 'Plastic, Poly-Ethylene (High Density)'
                    % MatWeb
                    this.Color = [0.909 0.941 1]; % faint Light blue
                    this.Phase = enumMaterial.Solid;
                    % Corrected by Matthias, Nov26 2021 (avg of various sources, e.g.
                    % engineeringtoolbox
                    this.ThermalConductivity = 0.453; % W/(m*K)
                    % this.ThermalConductivity = 0.196; % W/(m*K)
                    this.dT_du = 1/1540; % Specific heat capacity	1,460	�	2,160	J/kg�K
                    this.Density = 946; % kg/(m^3)
                case 'Plastic, Polyester (PET)'
                    % Added by Matthias, Nov26 2021
                    this.Color = [0.909 0.941 1]; % faint Light blue
                    this.Phase = enumMaterial.Solid;
                    % https://www.sciencedirect.com/book/9781895198478/handbook-of-polymers
                    this.ThermalConductivity = 0.15; % W/(m*K)
                    % https://www.professionalplastics.com/professionalplastics/ThermalPropertiesofPlasticMaterials.pdf
                    this.dT_du = 1/1275; % Specific heat capacity	1,200 - 1,350	J/kg�K
                    this.Density = 1350; % kg/(m^3)
                case 'SIL 180 oil (as solid)'
                    % Added by Matthias
                    this.Color = [1 1 0]; % yellow
                    this.Phase = enumMaterial.Solid;
                    temps_c = 20:10:170;
                    temps_d = [20 30 50:10:170];
                    c_values = [1511;1528;1545;1562;1579;1596;1613;1630;1647;1664;1681;1698;1715;1732;1749;1766]; % estimated from SYLTHERM 800
                    dens_values = [932.32 904 902 894.12 889.8 886.6 874.75 862.75 860.42 855.1 845.36 836.73 828.57 816.33 813.86]; %measured
                    done = false;
                    while ~done
                        op = {'150','0.1'}; % Default temperature and conductivity
                        op = inputdlg(...
                            {'Temperature for material properties (between 20C and 170C)','Thermal Conductivity in W/mK (default is from SIL180 datasheet)'},...
                            'SIL 180 oil',[1 100],op);
                        inputs = str2double(op);
                        if ~any(isnan(inputs))
                            done = true;
                            this.ThermalConductivity = inputs(2); % W/(m*K) (datasheet at 20C)
                            this.dT_du = 1/ interp1(temps_c,c_values,inputs(1)); % Specific heat capacity	J/kg�K (estimated from SYLTHERM 800)
                            this.Density = interp1(temps_d,dens_values,inputs(1)); % kg/(m^3) (measured)
                            MaterialName = [MaterialName ', k=' num2str(inputs(2)) ' W/mK, T=' num2str(inputs(1)) ' C'];
                        end
                    end
                case 'Plastic, Polyetherimide (PEI / Ultem)'
                    % Added by Matthias, Nov26 2021
                    this.Color = [1 0.72 0]; % Orange
                    this.Phase = enumMaterial.Solid;
                    % https://www.sciencedirect.com/book/9781895198478/handbook-of-polymers
                    this.ThermalConductivity = 0.22; % W/(m*K)
                    % https://dielectricmfg.com/knowledge-base/ultem/
                    % https://www.azom.com/properties.aspx?ArticleID=1883
                    % https://www.professionalplastics.com/professionalplastics/ThermalPropertiesofPlasticMaterials.pdf
                    this.dT_du = 1/1666; % Specific heat capacity	1500 (2 sources) - 2000	J/kg�K
                    this.Density = 1290; % kg/(m^3)
                case 'Rubber, Polychloroprene (Neoprene)'
                    % https://thermtest.com/materials-database#NEOPRENE
                    this.Color = [0.1 0.1 0.1];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 0.192; % W/(m*K)
                    this.dT_du = 1/1029; % Specific heat capacity	1,460	�	2,160	J/kg�K
                    this.Density = 1250; % kg/(m^3)
                case 'Rubber, Acrylonitrile-Butadiene (Nitrile)'
                    % https://thermtest.com/materials-database#NITRILE
                    this.Color = [33/255 16/255 0];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 0.243; % W/(m*K)
                    this.dT_du = 1/1966; % Specific heat capacity	1,460	�	2,160	J/kg�K
                    this.Density = 1000; % kg/(m^3)
                case 'Rubber, Silicone'
                    % https://thermtest.com/materials-database#SILICONE-RUBBER-(MEDIU
                    this.Color = [22/255 25/255 37/255];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 0.335; % W/(m*K)
                    this.dT_du = 1/1255; % Specific heat capacity	1,460	�	2,160	J/kg�K
                    this.Density = 1300; % kg/(m^3)
                case 'Foam, Expanded Polystyrene'
                    % http://www.eyoungindustry.com/uploadfile/file/20160612/20160612155656_94768.pdf
                    % Implement subtype interface
                    index = 0;
                    while index == 0
                        index = 1;
                        index = listdlg('ListString',{...
                            'L - 11 kg/m3','SL - 13.5 kg/m3',...
                            'S - 16 kg/m3','M - 19 kg/m3',...
                            'H - 24 kg/m3','VH - 28 kg/m3',...
                            'Custom Density'},...
                            'SelectionMode','single',...
                            'InitialValue',index);
                    end
                    if index < 7
                        Temp = [11 13.5 16 19 24 28];
                        this.Density = Temp(index);
                    else
                        this.Density = str2double(inputdlg('Enter EPS density',...
                            'Custom Expanded Polystyrene',[1 100],{'16'}));
                    end
                    this.Color = [1 0.83 0.83];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 0.1142*(this.Density)^(-0.371); % W/(m*K)
                    % https://www.engineeringtoolbox.com/specific-heat-capacity-d_391.html
                    this.dT_du = 1/(1400); % Specific heat capacity	1,300	�	1,500	J/kg�K
                case 'Foam, Extruded Polystyrene'
                    % http://www.eyoungindustry.com/uploadfile/file/20160612/20160612155656_94768.pdf
                    % Implement subtype interface
                    index = 0;
                    while index == 0
                        index = 1;
                        index = listdlg('ListString',{...
                            'Custom Density'},...
                            'SelectionMode','single',...
                            'InitialValue',index);
                    end
                    if index < 1
                        Temp = [];
                        this.Density = Temp(index);
                    else
                        this.Density = str2double(inputdlg('Enter XPS density',...
                            'Custom Expanded Polystyrene',[1 100],{'30'}));
                    end
                    this.Color = [1 0.83 0.83];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 0.036; % W/(m*K)
                    % https://www.engineeringtoolbox.com/specific-heat-capacity-d_391.html
                    this.dT_du = 1/(1400); % Specific heat capacity	1,300	�	1,500	J/kg�K
                case 'Foam, Rigid Polyurethane'
                    % http://www.react-ite.eu/uploads/tx_mddownloadbox/PP02_Thermal_insulation_materials_-_PP02_20130715.pdf
                    % Implement subtype interface
                    index = 0;
                    while index == 0
                        index = 1;
                        index = listdlg('ListString',{...
                            '30 kg/m3',...
                            '40 kg/m3',...
                            '80 kg/m3',...
                            'Custom Density'},...
                            'SelectionMode','single',...
                            'InitialValue',index);
                    end
                    if index < 4
                        Temp = [30 40 80];
                        this.Density = Temp(index);
                    else
                        this.Density = str2double(inputdlg('Enter PUR density',...
                            'Custom Rigid Polyurethane',[1 100],{'16'}));
                    end
                    this.Color = [0.957 0.937 0.745];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 0.0371*(this.Density)^(-0.098); % W/(m*K)
                    this.dT_du = 1/1500; % Specific heat capacity	1,300	�	1,500	J/kg�K
                case 'Rigid Polyurethane Foam, General Plastics FR-4718'
                    % https://www.generalplastics.com/products/fr-4700
                    this.Color = [0.957 0.937 0.745];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 0.06; % (at 24C) W/(m*K)
                    this.dT_du = 1/1500; % (as above) Specific heat capacity	J/kg�K
                    this.Density = 288; % kg/(m^3)
                case 'AIR' % Standard Air
                    this.Color = [0.906 0.906 0.906];% [231 231 231];
                    this.Phase = enumMaterial.Gas;
                    %           this.ThermalConductivity = NaN; % W/(m*K)
                    this.ThermalConductivity = 0.0262; % W/(m*K)
                    this.R = 287;
                    this.dT_duFunc = @(u) (-2.88367e-10)*u + (1.42462651e-3); % Verified
                    this.dT_du = this.dT_duFunc(298);
                    this.dh_dTFunc = @(T) 1013.5 - 0.15709*T + 0.00049079*T.^2 - 0.00000020552*T.^3;
                    this.dh_dT = this.dh_dTFunc(298);
                    this.u2T = @(u) (-1.44183718e-10)*u.^2 + (1.42462651e-3)*u; % Verified
                    this.kFunc = @(T) (-1.3974e-11)*T.^3 + (-4.5769e-8)*T.^2 + ...
                        (9.8961e-5)*T + 3.4920e-4; % Verified / Updated
                    this.muFunc = @(T) (1.6834E-14)*T.^3 - (4.7591E-11)*T.^2 + ...
                        7.1598E-08*T + 7.5908E-07; % Verified / Updated
                case 'N2 Gas' % Nitrogen
                    %           fprintf('XXX Need cv and u2T for nitrogen XXX\n');
                    this.Color = [0.906 0.906 0.906];
                    this.Phase = enumMaterial.Gas;
                    this.R = 296.8;
                    this.dT_duFunc = @(u) -3.7744e-10*u + 1.447e-3; % Verified
                    this.dT_du = this.dT_duFunc(298);
                    % http://www.colby.edu/chemistry/PChem/notes/Ch7Tables.pdf
                    this.dh_dTFunc = @(T) (28.882 - 0.00157*T + 0.00000808*T.^2 - 0.000000002871*T.^3)/0.0280134;
                    this.dh_dT = this.dh_dTFunc(298);
                    this.u2T = @(u) -1.8872e-10*(u.^2) + 1.447e-3*u - 1.2188e1; % Verified
                    this.kFunc = @(T) 3.3552E-11*(T.^3) - 7.3741E-08*(T.^2) + 1.0792E-04*T - 6.5862E-04; % Verified / Update
                    this.muFunc = @(T) 1.9072E-14*(T.^3) - 4.9344E-11*(T.^2) + 7.1568E-08*T + 3.4160E-07; % Verified / Updated
                case 'H2 Gas' % Hydrogen
                    this.Color = [0.906 0.906 0.906];% [231 231 231];
                    this.Phase = enumMaterial.Gas;
                    this.R = 4124.2;
                    %           this.dT_duFunc = @(u) -8.0404e-13*(T) + 1.0068E-04; % Verified
                    this.dT_duFunc = @(u) -8.0404e-13*(u) + 1.0068E-04; % Matthias: corrected variable
                    this.dT_du = this.dT_duFunc(298);
                    % http://www.colby.edu/chemistry/PChem/notes/Ch7Tables.pdf
                    this.dh_dTFunc = @(T) (29.088 - 0.00192*T + 0.00000400*T.^2 - 0.000000000870*T.^3)/0.002016;
                    this.dh_dT = this.dh_dTFunc(298);
                    %           this.u2T = @(u) - 4.0202E-13*(T.^2) + 1.0068E-04*T + 1.8779E+00; % Verified
                    this.u2T = @(u) - 4.0202E-13*(u.^2) + 1.0068E-04*u + 1.8779E+00; % Matthias: corrected variable
                    this.kFunc = @(T) 9.0864E-10*(T.^3) - 1.0269E-06*(T.^2) + 8.7129E-04*T - 7.4747E-03; % Verified
                    this.muFunc = @(T) 8.4578E-13*(T.^3) - 1.8183E-09*(T.^2) + 2.8432E-06*T+ 1.8282E-04; % Verified
                case 'OLD Helium Gas' % Helium Gas
                    this.Color = [1.0 0.0 1.0]; % [214 111 206];
                    this.Phase = enumMaterial.Gas;
                    this.R = 2077.27;
                    this.dT_duFunc = @(u) 0.00032096; % Verified  Change in temperature/unit change in internal energy
                    this.dT_du = this.dT_duFunc(298);
                    this.dh_dTFunc = @(T) 20.786/0.004002602;
                    this.dh_dT = this.dh_dTFunc(298);
                    this.u2T = @(u) 0.00032096*u; % Verified
                    this.kFunc = @(T) 1.7109E-10*(T.^3) - 3.3300E-07*(T.^2) + 4.5124E-04*(T) + 3.9533E-02; % Verified
                    this.muFunc = @(T) 2.8183E-14*(T.^3) - 5.6714E-11*(T.^2) + 7.0661E-08*(T) + 3.4685E-06; % Verified
                case '100% Helium' % 100/0 Helium/Air
                    this.Color = [1.0 0.65 1.0];    % Color in MSPM model
                    this.Phase = enumMaterial.Gas;  % Phase
                    this.R = 2077.27;   % Individual Gas Constant
                    this.dT_duFunc = @(u) 0.00032089;  % 1/Specific heat at constant volume C_v - 1/Cv [(kg*K)/J]
                    this.dT_du = this.dT_duFunc(298); 
                    this.dh_dTFunc = @(T) -5.3406e-08*(T.^3) + 6.8448842e-05*(T.^2) - 0.028154819*(T) + 5196.8234;
                    this.dh_dT = this.dh_dTFunc(298);   % Specific heat at constant pressure C_p - Cp [J/(kg*K)]
                    this.u2T = @(u) 0.00032089*u;   % Convert internal energy to temperature
                    this.kFunc = @(T) 2.3243e-10*(T.^3) - 4.0939e-07*(T.^2) + 0.00054371*(T) + 0.023579;    % Thermal conductivity
                    this.muFunc = @(T) 2.171e-14*(T.^3) - 4.1676e-11*(T.^2) + 6.4811e-08*(T) + 3.6548e-06;     % Dynamic viscocity
                case '99% Helium' % 99/1 Helium/Air
                    this.Color = [1.0 0.70 1.0];
                    this.Phase = enumMaterial.Gas;
                    this.R = 1955.33;
                    this.dT_duFunc = @(u) 0.00032334;
                    this.dT_du = this.dT_duFunc(298);
                    this.dh_dTFunc = @(T) -6.088e-08*(T.^3) + 8.1068432e-05*(T.^2) - 0.033304878*(T) + 5155.6355;
                    this.dh_dT = this.dh_dTFunc(298);
                    this.u2T = @(u) 0.00032334*u;
                    this.kFunc = @(T) 2.3175e-10*(T.^3) - 4.0764e-07*(T.^2) + 0.0005372*(T) + 0.022493;
                    this.muFunc = @(T) 2.2741e-14*(T.^3) - 4.339e-11*(T.^2) + 6.6019e-08*(T) + 3.5264e-06;
                case '95% Helium' % 95/5 Helium/Air
                    this.Color = [1.0 0.75 1.0];
                    this.Phase = enumMaterial.Gas;
                    this.R = 1583.50;
                    this.dT_duFunc = @(u) 0.00033355;  
                    this.dT_du = this.dT_duFunc(298);
                    this.dh_dTFunc = @(T) -9.0776e-08*(T.^3) + 0.00013154679*(T.^2) - 0.053905116*(T) + 4990.8843;
                    this.dh_dT = this.dh_dTFunc(298);
                    this.u2T = @(u) 0.00033355*u;
                    this.kFunc = @(T) 2.2683e-10*(T.^3) - 3.976e-07*(T.^2) + 0.00051085*(T) + 0.018682;
                    this.muFunc = @(T) 2.6206e-14*(T.^3) - 4.9223e-11*(T.^2) + 7.0094e-08*(T) + 3.059e-06;
                case '90% Helium' % 90/10 Helium/Air
                    this.Color = [1.0 0.80 1.0];
                    this.Phase = enumMaterial.Gas;
                    this.R = 1279.39;
                    this.dT_duFunc = @(u) 0.00034726;
                    this.dT_du = this.dT_duFunc(298);
                    this.dh_dTFunc = @(T) -1.2815e-07*(T.^3) + 0.00019464474*(T.^2) - 0.079655412*(T) + 4784.9453;
                    this.dh_dT = this.dh_dTFunc(298);
                    this.u2T = @(u) 0.00034726*u;
                    this.kFunc = @(T) 2.1731e-10*(T.^3) - 3.8042e-07*(T.^2) + 0.00047804*(T) + 0.014891;
                    this.muFunc = @(T) 2.9371e-14*(T.^3) - 5.4685e-11*(T.^2) + 7.3836e-08*(T) + 2.5658e-06;
                case '85% Helium' % 85/15 Helium/Air
                    this.Color = [1.0 0.85 1.0];
                    this.Phase = enumMaterial.Gas;
                    this.R = 1073.27;
                    this.dT_duFunc = @(u) 0.00036213;
                    this.dT_du = this.dT_duFunc(298);
                    this.dh_dTFunc = @(T) -1.6552e-07*(T.^3) + 0.00025774269*(T.^2) - 0.10540571*(T) + 4579.0062;
                    this.dh_dT = this.dh_dTFunc(298);
                    this.u2T = @(u) 0.00036213*u;
                    this.kFunc = @(T) 2.0571e-10*(T.^3) - 3.6039e-07*(T.^2) + 0.00044615*(T) + 0.011914;
                    this.muFunc = @(T) 3.1607e-14*(T.^3) - 5.8661e-11*(T.^2) + 7.6488e-08*(T) + 2.156e-06;
                case '80% Helium' % 80/20 Helium/Air
                    this.Color = [1.0 0.90 1.0];
                    this.Phase = enumMaterial.Gas;
                    this.R = 924.34;
                    this.dT_duFunc = @(u) 0.00037834;
                    this.dT_du = this.dT_duFunc(298);
                    this.dh_dTFunc = @(T) -2.0289e-07*(T.^3) + 0.00032084064*(T.^2) - 0.13115601*(T) + 4373.0672;
                    this.dh_dT = this.dh_dTFunc(298);
                    this.u2T = @(u) 0.00037834*u;
                    this.kFunc = @(T) 1.9314e-10*(T.^3) - 3.3907e-07*(T.^2) + 0.00041563*(T) + 0.009548;
                    this.muFunc = @(T) 3.3187e-14*(T.^3) - 6.1566e-11*(T.^2) + 7.8357e-08*(T) + 1.8136e-06;
                case '50% Helium' % 50/50 Helium/Air
                    this.Color = [1.0 0.95 1.0];
                    this.Phase = enumMaterial.Gas;
                    this.R = 504.41;
                    this.dT_duFunc = @(u) 0.00051727;
                    this.dT_du = this.dT_duFunc(298);
                    this.dh_dTFunc = @(T) -4.2711e-07*(T.^3) + 0.00069942834*(T.^2) - 0.28565779*(T) + 3137.4329;
                    this.dh_dT = this.dh_dTFunc(298);
                    this.u2T = @(u) 0.00051727*u;
                    this.kFunc = @(T) 1.2078e-10*(T.^3) - 2.1732e-07*(T.^2) + 0.00026548*(T) + 0.0022318;
                    this.muFunc = @(T) 3.6215e-14*(T.^3) - 6.8022e-11*(T.^2) + 8.1635e-08*(T) + 6.0603e-07;
                case 'Perfect Insulator'
                    this.Color = [0.15 0.15 0.15];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 0; % W/(m*K)
                    this.dT_du = -1; % J/(kg*K)
                    this.Density = 0.01; % kg/(m^3)
                case 'Constant Temperature'
                    this.Color = [1 1 1];
                    this.Phase = enumMaterial.Solid;
                    this.ThermalConductivity = 1e30; %W/(m*K)
                    this.dT_du = -1; % J/(kg*K)
                    this.Density = 0.01;
                otherwise
                    fprintf(['XXX MISSING PROPERTIES FOR MATERIAL: ' ...
                        MaterialName '.\n']);
            end

            this.name = MaterialName;
        end

        function a = thermaldiffusivity(this)
            a = this.ThermalConductivity*this.dT_du/(this.Density);
        end
        function u = initialInternalEnergy(this,T)
            switch this.Phase
                case enumMaterial.Gas
                    % Use u2T function
                    uold = 298;
                    r = this.u2T(uold) - T;
                    while true
                        uguess = uold - r/this.dT_duFunc(uold);
                        r = this.u2T(uguess) - T;
                        if abs(r) < 1e-8; break; end
                        uold = uguess;
                    end
                    u = uguess;
                case enumMaterial.Solid
                    if this.dT_du ~= 0
                        u = T/this.dT_du;
                    else
                        u = 0;
                    end
            end
        end
    end

end

