classdef Node < handle
  %NODE Summary of this class goes here
  %   Detailed explanation goes here
         
  properties
    isDynamic logical;
    Type enumNType;
    data;
    iPressure double;
    iTemperature double;
    xmin double;
    xmax double;
    ymin double;
    ymax double;
    Faces Face;
    Nodes Node;
    Body;
    
    isEnd logical; % Allows for the required distance calculation
    
    index int32; % For translation to array for solving
  end
  
  properties (Hidden)
    stateLocation Pnt2D;
    isminCenterCoordsCalcd logical = false;
    stateminCenterCoords Pnt2D;
    useStoredVolume logical;
    StoredVolume double;
  end
  
  properties (Dependent)
    minCenterCoords Pnt2D;
  end
  
  methods
    function this = Node(Type,xmin,xmax,ymin,ymax,Faces,Nodes,theBody,index)
      if nargin == 0; return; end
      % Node(Type, data, iPressure, iTemperature, xmin, xmax, ymin, ymax, Faces, Nodes, matl)
      this.Type = Type;
      
      this.xmin = xmin;
      this.xmax = xmax;
      this.ymin = ymin;
      this.ymax = ymax;
      if nargin == 5; return; end
      this.Faces = Faces;
      this.Nodes = Nodes;
      
      if this.vol() < 0
        fprintf('err');
      end
      
      this.index = index;
      this.Body = theBody;
      if isempty(this.data); this.calcData(); end
      
      this.updateisDynamic();
    end
    function [success, nd2del, fc2del] = combineSolid(this,other,refinementfactor)
      % Set outputs to default values
      nd2del = Node.empty;
      fc2del = Face.empty;
      success = false;
      
      % It must be a Face between two solid nodes
      if this.Type == enumNType.SN && other.Type == enumNType.SN
        
        % Find the face between the two nodes
        for fc = this.Faces
          if (fc.Nodes(1) == this && fc.Nodes(2) == other) || (...
              fc.Nodes(2) == this && fc.Nodes(1) == other)
            
            % Get the two materials
            if isfield(this.data,'matl'); matl1 = this.data.matl;
            else; matl1 = this.Body.matl;
            end
            if isfield(other.data,'matl'); matl2 = other.data.matl;
            else; matl2 = other.Body.matl;
            end
            
            % Calculate the timestep based on a Fourier Number of 0.25
            if matl1.dT_du == -1
              dT_du1 = 1e-30; else; dT_du1 = matl1.dT_du; end
            if matl2.dT_du == -1
              dT_du2 = 1e-30; else; dT_du2 = matl2.dT_du; end
            
            timestep1 = (0.25*matl1.Density/dT_du1)*this.vol()./fc.data.U;
            timestep2 = (0.25*matl2.Density/dT_du2)*other.vol()./fc.data.U;
            
            % If the timestep for this interaction would be too small
            if all(timestep1 < 1e-3) || all(timestep2 < 1e-3)
              % 
              if sum(timestep1 < timestep2) > length(timestep1)/2
                collector = other;
                nd2del = this;
              else
                collector = this;
                nd2del = other;
              end
              fc2del = fc;
              success = true;
              break;
            end
            
            % Exit because only one face will be between these nodes
            break;
          end
        end
        
        if success
          % Calculate the updated properties
          collector.StoredVolume = this.vol() + other.vol();
          vol1 = this.vol();
          vol2 = other.vol();
          collector.useStoredVolume = true;
          if matl1.dT_du == -1
            collector.data.matl = matl1;
          elseif matl2.dT_du == -1
            collector.data.matl = matl2;
          elseif matl1 ~= matl2
            if isfield(collector.data,'matl'); matl = collector.data.matl;
            else; matl = collector.Body.matl;
            end
            mass = vol1*matl1.Density + vol2*matl2.Density;
            collector.data.matl = Material();
            collector.data.matl.Color = matl1.Color;
            collector.data.matl.Phase = enumMaterial.Solid;
            collector.data.matl.ThermalConductivity = ...
              (vol1*matl1.Density*matl1.ThermalConductivity + ...
              vol2*matl2.Density*matl2.ThermalConductivity)/...
              (vol1*matl1.Density + vol2*matl2.Density);
            collector.data.matl.Density = (vol1*matl1.Density + ...
              vol2*matl.Density)/collector.StoredVolume;
            collector.data.matl.dT_du = (vol1*matl1.Density*dT_du1 + ...
              vol2*matl2.Density*dT_du2)/mass;
          end
          
          % Modify the faces in the weaker node so that they reference the
          % ... collector instead.
          keep = true(size(nd2del.Faces));
          i = 1;
          for fc = nd2del.Faces
            if fc ~= fc2del
              if fc.Nodes(1) == nd2del
                fc.Nodes(1) = collector;
              elseif fc.Nodes(2) == nd2del
                fc.Nodes(2) = collector;
              end
            else
              keep(i) = false;
            end
            i = i + 1;
          end
          nd2del.Faces = nd2del.Faces(keep);
          
          % Remove the face that goes between the two nodes
          keep = true(size(collector.Faces));
          for i = 1:length(collector.Faces)
            if collector.Faces(i) == fc2del
              keep(i) = false;
            end
          end
          collector.Faces = collector.Faces(keep);
          collector.Faces(end+1:end+length(nd2del.Faces)) = nd2del.Faces;
        end
      end
    end
    
    function calcData(this)
      if this.Type ~= enumNType.EN
        matl = this.Body.matl;
        switch matl.Phase
          case enumMaterial.Solid
            %% Solids
            this.data.T = this.Body.Temperature();
            this.data.dT_dU = matl.dT_du;
            
          case {enumMaterial.Gas, enumMaterial.Liquid}
            %% Fluids
            this.data.P = this.Body.Pressure();
            this.data.T = this.Body.Temperature();
            if ~isempty(this.Body.Matrix) && ~isempty(this.Body.Matrix.Dh)
              %% Not an empty Volume
              % Scale the volume
% Matthias: the gas node volume is calculated incorrecty here! 'this.vol()'
% already takes the matrix porosity into account, so multiplying it here
% again leads to the volume being too small by factor of the porosity.
%               this.data.vol = this.vol()*this.Body.Matrix.data.Porosity;
              this.data.vol = this.vol(); % Added by Matthias
              this.data.Dh = this.Body.Matrix.Dh;
              % Assign the Nusselt number function (Re,Pr)
              this.data.NuFunc_l = this.Body.Matrix.NuFunc_l;
              if ~this.Body.Matrix.isFullyLaminar
                this.data.NuFunc_t = this.Body.Matrix.NuFunc_t;
              else
                this.data.NuFunc_t = this.data.NuFunc_l;
              end
              dir = getBodyDirection(this.Body);
              if dir == 1
                % Horizontal
                this.data.Area = (this.ymax-this.ymin)*pi*(this.xmax + this.xmin)*...
                  this.Body.Matrix.data.Porosity;
              else
                % Vertical
                this.data.Area = pi*(this.xmax^2 - this.xmin^2)*...
                  this.Body.Matrix.data.Porosity;
              end
            else
              %% An empty channel
              this.data.vol = this.vol();
              dir = getBodyDirection(this.Body);
              if dir == 1
                % Horizontal
                this.data.Orient = enumOrient.Horizontal;
                this.data.Dh = 2.*(this.ymax-this.ymin);
                this.data.Area = (this.ymax-this.ymin)*pi*(this.xmax + this.xmin);
                % Assign default Nusselt Number Correlation
                this.data.NuFunc_l = @(Re) 3.66; % Fully Developed, Uniform Surface Temperature
              else
                this.data.Orient = enumOrient.Vertical;
                this.data.Dh = 2.*(this.xmax-this.xmin);
                this.data.Area = pi*(this.xmax^2 - this.xmin^2);
                % Assign default Nusselt Number Correlation
                ri_ro = this.xmin/this.xmax;
                if ri_ro == 0
                  Nuo = 3.66;
                  Nui = 0;
                else
                  Nuo = 4.6961*(ri_ro)^(0.0548);
                  Nui = 4.4438*(ri_ro)^(-0.43);
                end
                this.data.NuiFunc_l = @(Re) Nui;
                this.data.NuoFunc_l = @(Re) Nuo;
              end
              this.data.NuFunc_t = @(Re,Pr) 0.035*(Re.^0.75).*(Pr.^0.33);
            end
            if ~isscalar(this.data.Dh); this.data.Dh = CollapseVector(this.data.Dh); end
            if ~isscalar(this.data.Area); this.data.Area = CollapseVector(this.data.Area); end
        end
      else
        % Body is actually an environment
        this.data.T = this.Body.Temperature;
        this.data.P = this.Body.Pressure;
        this.data.h = this.Body.h;
        if isempty(this.Body.matl)
          this.Body.matl = Material('AIR');
        end
        this.data.rho = this.data.P/(this.data.T*this.Body.matl.R);
      end
    end
    function addFace(this,Face)
      this.Faces(end+length(Face):-1:end+1) = Face;
    end
    function updateisDynamic(this)
      if length(this.xmin) > 1 || length(this.xmax) > 1 || length(this.ymin) > 1 || length(this.ymax) > 1 % this.Type ~= enumNType.SN
        this.isDynamic = true;
      else
        for Face = this.Faces
          if Face.isDynamic
            this.isDynamic = true;
            return;
          end
        end
        this.isDynamic = false;
      end
    end
    function var = total_vol(this)
      var = (pi*(this.xmax^2 - this.xmin^2)).*(this.ymax - this.ymin);
    end
    
    function var = vol(this)
      if this.Type == enumNType.SN
        if this.useStoredVolume
          var = this.StoredVolume;
        else
          var = pi.*(this.xmax.^2-this.xmin.^2)*...
            (this.ymax(1)-this.ymin(1));
        end
      else
        if ~isa(this.Body,'Body')
          P = 1;
        elseif isempty(this.Body.Matrix)
          P = 1;
        else
          if isfield(this.Body.Matrix.data,'Porosity')
            P = this.Body.Matrix.data.Porosity;
          else
            P = 1;
          end
        end
        var = P*pi.*(this.xmax.^2-this.xmin.^2)*...
          (this.ymax-this.ymin);
        var = CollapseVector(var);
      end
    end
    function recalc_Dh(this)
      if this.Type ~= enumNType.SN && this.Type ~= enumNType.EN
        % Dh = 4 * Volume / Surface Area
        
        V = this.vol();
%         for fc = this.Faces
%           if fc.Type == enumFType.Mix
%             S_total = S_total + fc.data.Area;
%           end
%         end

        S_total = 2*pi*(this.xmin + this.xmax)*(this.ymax-this.ymin) + ...% Sides
          2*pi*(this.xmax^2-this.xmin^2); % Top & Bottom
        if isempty(this.Body.Matrix) || ...
            strcmp(this.Body.Matrix.name,'Undefined Matrix') == 1
          for fc = this.Faces
            if fc.Type == enumFType.Gas
              S_total = S_total - fc.data.Area;
            end
          end
        else
          if isfield(this.Body.Matrix.data,'ignore_canister') && ...
                  this.Body.Matrix.data.ignore_canister
             S_total = 0;
             includeGas = false;
          else
% Matthias: Calculation of surface area S_total here leads to
% incorrect Dh. E.g. for first (bottom) node in 'Cooler main part', S_total
% becomes 0.0579 while it should be (from geometry) about 0.0383.
% (Fin side surface 0.0365 + base/tip surfaces 0.00182)
% TESTED: Fin side surface is correct: 0.0365
% ISSUE is the initial S_total not considering the area on the vertical
% walls that is occupied by the solid of the matrix. I.e. initial S_total
% is overestimated.
% Matthias: Added below line to correct surface area calculation for the
% inside/outside and top/bottom areas of the node that are occupied by the matrix.
             S_total = S_total * this.Body.Matrix.data.Porosity;
             
             includeGas = true; 
          end
          for fc = this.Faces
            if fc.Type == enumFType.Mix
              % Include only matrix faces when it is a matrix, as the heat
              % ... exchange equations assume that it is just the heat
              % ... exchanger geometry.
              if fc.Nodes(1).Body == fc.Nodes(2).Body
                S_total = S_total + fc.data.Area;
              end
            end
            if includeGas
                if fc.Type == enumFType.Gas
                  S_total = S_total - fc.data.Area;
                end
            end
          end
        end
        Dh = 4*V./S_total; % 4*A*L/(P*L)
        this.data.Dh = CollapseVector(Dh);
      end
    end
    function center = get.minCenterCoords(this)
      if ~this.isminCenterCoordsCalcd || isempty(this.stateminCenterCoords)
        if this.isDynamic
          this.stateminCenterCoords = ...
            Pnt2D(0.5*(this.xmin+this.xmax),...
            0.5*(min(this.ymin)+min(this.ymax)));
        else
          this.stateminCenterCoords = ...
            Pnt2D(0.5*(this.xmin+this.xmax),...
            0.5*(this.ymin+this.ymax));
        end
      end
      if isa(this.Body,'Body')
        center = this.Body.Group.TranslatePnt2D(this.stateminCenterCoords);
      else
        center = this.stateminCenterCoords;
      end
    end
    function center = CenterCoords(this,Inc)
      if this.isDynamic
        if isscalar(this.ymin)
          if isscalar(this.ymax)
            center = this.minCenterCoords;
          else
            center = ...
              Pnt2D(0.5*(this.xmin+this.xmax), ...
              0.5*(this.ymin+this.ymax(Inc)));
          end
        else
          if isscalar(this.ymax)
            center = ...
              Pnt2D(0.5*(this.xmin+this.xmax), ...
              0.5*(this.ymin(Inc)+this.ymax));
          else
            center = ...
              Pnt2D(0.5*(this.xmin+this.xmax), ...
              0.5*(this.ymin(Inc)+this.ymax(Inc)));
          end
        end
      else
        center = this.stateminCenterCoords;
      end
      if isa(this.Body,'Body')
        center = this.Body.Group.TranslatePnt2D(center);
      else
        center = this.stateminCenterCoords;
      end
    end
    function Struct = getGrouping(this,Struct,n,sourceFace)
      % if this node is a transition, stop this recursion
      if nargin == 4
        for Fc = this.Faces
          if isfield(Fc.data,'K12') || ...
              (isfield(Fc.data,'dx') &&  ...
              abs(Fc.data.dx - sourceFace.data.dx)/sourceFace.data.dx > 0.1)
            return;
          end
        end
        this.data.Group = n;
        Struct.Nds = [Struct.Nds this];
      elseif nargin == 3
        val = 0;
        for Fc = this.Faces
          if isfield(Fc.data,'dx')
            
            if isscalar(val)
              if isscalar(Fc.data.dx)
                if Fc.data.dx > val
                  val = Fc.data.dx;
                end
              else
                val = max([val(ones(size(Fc.data.dx))); Fc.data.dx]);
              end
            else
              if isscalar(Fc.data.dx)
                val(val<Fc.data.dx) = Fc.data.dx;
              else
                val = max([val; Fc.data.dx]);
              end
            end
            
          end
        end
        if isscalar(val) && val == 0
          return;
        end
        for Fc = this.Faces
          if isfield(Fc.data,'K12') || ...
              (isfield(Fc.data,'dx') && ...
              any(abs(Fc.data.dx - val)./val > 0.1))
            return;
          end
        end
      end
      for Fc = this.Faces
        if ~isfield(Fc.data,'Group') && isfield(Fc.data,'dx')
          Struct.Fcs = [Struct.Fcs Fc];
        end
      end
      for i = 1:length(this.Nodes)
        if isfield(this.Nodes(i).data,'P') && isfield(this.Faces(i).data,'dx')
          Struct = getGrouping(this.Nodes(i),Struct,n,this.Faces(i));
        end
      end
    end
    function value = getArea(this,ind,Connection)
      if ~isa(this.Body,'Body')
        value = 1e8;
        return;
      end
      if this.Body.divides(1) ~= this.Body.divides(2) || nargin < 3
        if isfield(this.data,'Area')
          if isscalar(this.data.Area)
            value = this.data.Area;
          else
            if ind == 0
              value = this.data.Area(end);
            else
              value = this.data.Area(ind);
            end
          end
        else
          value = 0;
        end
      else
       switch Connection.Orient
         case enumOrient.Vertical
           if ind == 0
             imin = 1;
             imax = 1;
           else
             imin = min(length(this.ymin),ind);
             imax = min(length(this.ymax),ind);
           end
           value = 2*pi*Connection.x*(this.ymax(imax)-this.ymin(imin));
         case enumOrient.Horizontal
           value = pi*(this.xmax^2-this.xmin^2);
       end
      end
    end
    function istouching = isTouching(this,other)
      istouching = ~(this.xmin > other.xmax || this.xmax < other.xmin) && ...
        ~(this.ymin(1) > other.ymax(1) || this.ymax(1) < other.ymin(1));
    end
    function totalGasSurfaceArea = getTotalGasSurfaceArea(this,Orientation)
      if isempty(this.data.WSNG) || length(this.data.WSNG.members) ~= 1
        for fc = this.Faces
          if fc.Type == enumFType.Mix && fc.Orient == Orientation
            totalGasSurfaceArea = totalGasSurfaceArea + fc.data.Area;
          end
        end
      else
        % Consider the total area, because this is a corner
        for fc = this.Faces
          if fc.Type == enumFType.Mix
            totalGasSurfaceArea = totalGasSurfaceArea + fc.data.Area;
          end
        end
      end
    end
  end
end
