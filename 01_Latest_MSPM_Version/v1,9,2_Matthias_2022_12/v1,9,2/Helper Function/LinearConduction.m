function [U] = LinearConduction(Node,r1,r2,matl)
    % Matthias: The conduction distance 'L' should be halved, and the factor
    % '2' at begining of 'U' should be removed. These two errors cancel out,
    % so the result is correct.
    L = Node.ymax(1) - Node.ymin(1);
    U = (2*pi*(r2*r2-r1*r1)*matl.ThermalConductivity)/L;
end