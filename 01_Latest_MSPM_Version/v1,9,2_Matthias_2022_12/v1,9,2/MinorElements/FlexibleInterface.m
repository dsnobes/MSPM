classdef FlexibleInterface < handle
    %FLEXIBLEVOLUME Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Body1 Body;
        Body2 Body;
        Connection Connection;
        PressureExpansionFunc function_handle;
        WallThickness;
        matl Material;
        Area;
    end

    methods
        function this = FlexibleInterface(...
                iBody1,iBody2,iConnection,...
                iPressureExpansionFunc,iWallThickness,...
                iWallMaterial,iWallSurfaceArea)
            if nargin > 6
                this.Body1 = iBody1;
                this.Body2 = iBody2;
                this.Connection = iConnection;
                this.PressureExpansionFunc = iPressureExpansionFunc;
                this.WallThickness = iWallThickness;
                this.matl = iWallMaterial;
                this.Area = iWallSurfaceArea;
            end
        end

        function item = get(this,propertyName)
            switch propertyName
                case 'InnerBody'
                    item = this.Body1;
                case 'OuterBody'
                    item = this.Body2;
                case 'Connection'
                    item = this.Connection;
                case 'Pressure Expansion Function'
                    item = this.PressureExpansionFunction;
                case 'Unstretched Wall Thickness'
                    item = this.WallThickness;
                case 'Wall Material'
                    item = this.matl;
                case 'Nominal Wall Area'
                    item = this.Area;
            end
        end

        function set(this,propertyName,item)
            switch propertyName
                case 'InnerBody'
                    this.Body1 = item;
                case 'OuterBody'
                    this.Body2 = item;
                case 'Connection'
                    this.Connection = item;
                case 'Pressure Expansion Function'
                    this.PressureExpansionFunction = item;
                case 'Unstretched Wall Thickness'
                    this.WallThickness = item;
                case 'Wall Material'
                    this.matl = item;
                case 'Nominal Wall Area'
                    this.Area = item;
            end
        end

        function isit = isvalid(this)
            isit = false;
            if ~isempty(this.Body1) && ...
                    ~isempty(this.Body2) && ...
                    ~isempty(this.Connection) && ...
                    ~isempty(this.PressureExpansionFunc) && ...
                    ~isempty(this.WallThickness) && ...
                    ~isempty(this.matl) && ...
                    ~isempty(this.Area)
                for iBodies = this.Connection.Bodies
                    if this.Body1 == iBody
                        one = true;
                    elseif this.Body2 == iBody
                        two = true;
                    end
                end
                isit = one && two;
            end
        end

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

