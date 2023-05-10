classdef Environment < handle
    %ENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
      StdPressure = 101325; % Pa
      StdTemperature = 298; % K
      Stdh = 20; % W/m*K
      StdGas = 'AIR';
    end
    
    properties
      Pressure double;
      Temperature double;
      h double;
      matl Material;
      nodeIndex double;
      name char;
      
      GUIObjects = [];
      
      isDiscretized logical = false; 
      Node Node;
    end
    
    properties (Dependent)
        Group
    end
        
    methods
      %% Constructor
      function this = Environment(Pressure,Temperature,h,MaterialRef)
          switch nargin
            case 0
              this.Pressure = Environment.StdPressure;
              this.Temperature = Environment.StdTemperature;
              this.h = Environment.Stdh;
              this.matl = Material(Environment.StdGas);
              this.name = 'Standard AIR Environment';
            case 1
              this.Pressure = Pressure;
              this.Temperature = Environment.StdTemperature;
              this.h = Environment.Stdh;
              this.matl = Material(Environment.StdGas);
              this.name = 'Untitled Environment';
            case 2
              this.Pressure = Pressure;
              this.Temperature = Temperature;
              this.h = Environment.Stdh;
              this.matl = Material(Environment.StdGas);
              this.name = 'Untitled Environment';
            case 3
              this.Pressure = Pressure;
              this.Temperature = Temperature;
              this.h = h;
              this.matl = Material(Environment.StdGas);
              this.name = 'Untitled Environment';
            case 4
              this.Pressure = Pressure;
              this.Temperature = Temperature;
              this.h = h;
              this.matl = MaterialRef;
              this.name = 'Untitled Environment';
          end
      end
      
      %% Get/Set Interface
      function Item = get(this,PropertyName)
        switch PropertyName
          case 'Pressure'
            Item = this.Pressure;
          case 'Temperature'
            Item = this.Temperature;
          case 'h'
            Item = this.h;
          case 'Gas'
            Item = this.matl;
          case 'Name'
            Item = this.name;
          otherwise
            fprintf(['XXX Environment GET Inteface for ' PropertyName ' is not found XXX\n']);
        end
      end
      function set(this,PropertyName,Item)
        switch PropertyName
          case 'Pressure'
            this.Pressure = Item;
            if this.isDiscretized
              this.Node.data.Pressure = Item;
            end
          case 'Temperature'
             this.Temperature = Item;
             if this.isDiscretized
               this.Node.data.Temperature = Item;
             end
          case 'h'
            this.h = Item;
            if this.isDiscretized
                 this.Node.data.h = Item;
               end
          case 'Name'
            this.customname = Item;
          otherwise
            fprintf(['XXX Environment SET Inteface for ' PropertyName ' is not found XXX\n']);
        end
      end
      
      %% Node Management
      function resetDiscretization(this)
        this.Node(:) = [];
        this.isDiscretized = false;
      end
      function discretize(this)
        this.Node = Node.empty;
        this.Node = Node(enumNType.EN,0,0,0,0,Face.empty,Node.empty,this,0);
        this.isDiscretized = true;
        this.Node.data.Dh = 1e8;
%         if ~this.isDiscretized
%           delete(this.Node);
%           this.Node = Node(enumNType.EN,0,0,0,0,Face.empty,Node.empty,this,0); %#ok<PROP>
%           this.isDiscretized = true;
%         end
      end
        
      %% Graphics
      function removeFromFigure(this,AxisReference)
      if ~isempty(this.GUIObjects)
        children = get(AxisReference,'Children');
        for obj = this.GUIObjects
          if isgraphics(obj)
            for i = length(children):-1:1
              if isgraphics(children(i)) && children(i) == obj
                children(i).delete;
                break;
              end
            end
          end
        end
        this.GUIObjects = [];
      end
      end
    
      function igroup = get.Group(this)
          igroup = Group([],Position(0,0,pi/2),Body.empty);
      end
    end
end

