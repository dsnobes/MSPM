classdef LoopNode
  %LOOPNODE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    parent LoopNode;
    parentFc Face;
    Nd Node;
  end
  
  properties (Dependent)
    lvl int8;
  end
  
  methods
    function this = LoopNode(iparent, iparentFc, iNd)
      if nargin == 1
        this.Nd = iparent;
      elseif nargin == 3
        this.parent = iparent;
        this.parentFc = iparentFc;
        this.Nd = iNd;
      end
    end
    
    function lvl = get.lvl(this)
      if ~isempty(this.parent)
        lvl = this.parent.lvl + 1;
      else
        lvl = 1;
      end
    end
  end
  
end

