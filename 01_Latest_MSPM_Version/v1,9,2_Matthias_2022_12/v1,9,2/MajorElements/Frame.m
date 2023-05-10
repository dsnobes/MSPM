classdef Frame < handle
   %FRAME Summary of this class goes here
   %   Detailed explanation goes here
   properties (Constant)
      NTheta = 200;
      DecimateFactor = 10;
   end
      
   properties
      % Kinematic frames can be precalculated
      isKinematic = true;
      %           = false; is for free piston designs
      % In these cases the position array simply defines a
      % uniformly spaced position array between the motion
      % extents

      Positions double = []; % no negative positions, pistons should be sketched at minimum, not center.
      Mechanism LinRotMechanism; % as MechanicalSystem; % Defines a reference to the mechanism output that defines the motion of this frame
      MechanismIndex int8 = 1; % By Default
      CustomName char = [];
   end
   
   properties (Dependent)
      CurrentPosition;
      name;
   end
   
   methods      
     function name = get.name(this)
       if isvalid(this)
          if isempty(this.CustomName)
            ii = this.MechanismIndex;
            name = [this.Mechanism.Type ...
              ' L= ' num2str(this.Mechanism.Stroke(ii)) ...
              ' m , P= ' num2str(this.Mechanism.Phase(ii)) ' rad.\n'];
          end
       else
         name = '...';
       end
     end
   end
   
end

