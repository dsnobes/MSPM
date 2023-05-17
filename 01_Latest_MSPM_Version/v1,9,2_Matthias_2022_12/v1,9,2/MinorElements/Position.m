classdef Position < handle
    %POSITION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        x double = 0;
        y double = 0;
        Rot double = pi/2;
    end

    properties (Dependent)
        name;
    end

    methods
        function this = Position(x,y,Rot)
            switch nargin
                case 1
                    this.x = x;
                case 2
                    this.x = x;
                    this.y = y;
                case 3
                    this.x = x;
                    this.y = y;
                    this.Rot = Rot;
            end
        end
        function newPosition = plus(base,offset)
            newPosition.x = base.x + offset.x;
            newPosition.y = base.y + offset.y;
            newPosition.Rot = base.Rot;
            newPosition.Model = base.Model;
        end
        function name = get.name(this)
            name = sprintf('x: %f.0 y: %f.0 Rot: %f.00',this.x,this.y,this.Rot);
        end
        function Item = get(this,PropertyName)
            switch PropertyName
                case 'x'
                    Item = this.x;
                case 'y'
                    Item = this.y;
                case 'Theta'
                    Item = this.Rot;
                otherwise
                    fprintf(['XXX Position GET Inteface for ' PropertyName ' is not found XXX\n']);
            end
        end
        function set(this,PropertyName,Item)
            switch PropertyName
                case 'x'
                    this.x = Item;
                case 'y'
                    this.y = Item;
                case 'Theta'
                    this.Rot = Item;
                otherwise
                    fprintf(['XXX Position SET Inteface for ' PropertyName ' is not found XXX\n']);
            end
        end
    end

end

