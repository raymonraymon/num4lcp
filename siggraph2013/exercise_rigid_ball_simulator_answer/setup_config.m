function [config] = setup_config( N, width, height, border )
% SETUP_CONFIG - Create a config structure with simulationinformation
% INPUT:
%       N      - The number of rigid balls
%       width  - The size of the width of the world box
%       height - The size of the height of the world box
%       border - The size of the border
% RESULTS:
%    config    - The simulation configuration structure object.
% Copyright 2009, Kenny Erleben, DIKU.

% Compute some geometry of the world box
dimW = floor( width/border  );
dimH = floor( height/border );
width  = border*dimW - border;
height = border*dimH - border;
offset = border/2.0;

% Compute how many world box balls we need
M = dimW*2+dimH*2 - 4;

% Compute X and Y positions of world box balls
TX = (offset:border:(border*dimW))';
tmp = offset+(border*(dimH-2));
LY = (offset+border:border:tmp)';
BX = TX;
RY = LY;
BY = ones(size(BX))*LY(1)-border;
TY = ones(size(TX))*(LY(end)+border);
LX = ones(size(LY))*TX(1);
RX = ones(size(RY))*TX(end);

% Setup configuration positions
X = [ TX; BX; LX; RX; (rand(N,1)*(width-border)  + border) ];
Y = [ TY; BY; LY; RY; (rand(N,1)*(height-border) + border) ];
Vx      = zeros( M+N, 1);
Vy      = zeros( M+N, 1);
W       = [zeros( M,1); ones(N,1)];
Fx      = zeros( M+N,1);
Fy      = [zeros( M,1); -ones(N,1)*9.81];
R      = [(ones(M,1)*offset);  zeros( N,1)];

config = struct( 'X', X, 'Y', Y, 'W', W, 'Vx', Vx, 'Vy', Vy, 'R', R, 'Fx', Fx, 'Fy', Fy );

% Finally we must determine the radious of all the balls in the scene
info = collision_detection( config );
D = info.D./2;
for i=M+1:M+N
    idx = info.O(:,1)==i | info.O(:,2)==i;
    DD = D(idx==1);
    r = min( DD(DD>0) );
%     if r<1
%         r = 2*r;
%     end
    config.R(i) = r;
    config.W(i) = 1.0/r/r;
    config.Fy(i) = -9.81*r*r;
end


