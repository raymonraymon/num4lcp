%
% Copyright 2010, Kenny Erleben, DIKU.
%

close all;
clear all;

%--- Create a configuration to simulate

config = setup_config( 150, 100, 100, 5 );

%--- Create data structures for making a small movie of the simulation

T         = 10.0;    % The total number of seconds that should be simulated simulate
fps       = 30;      % The number of frames of per second that should be displayed
nb_frames = T*fps-1; % Compute the total number of frames, we do not visualize first frame
frame     = 1;       % Initialize frame counter

mov(1:nb_frames) = struct('cdata', [],'colormap', []); % Preallocate movie structure.

%--- Create a simulation loop

while T > 0
  
  dt_wanted = min(T,1/fps);  % How much time do we want to simulate before showing next frame?
  dt_done   = 0;             % How much time has passed
  
  while( dt_done < dt_wanted )
    
    info         = collision_detection(config);
    dt           = dt_wanted - dt_done;
    [config dt]  = simulate(config,info,dt);
    dt_done      = dt_done + dt;
    
  end
  
  T = T - dt_wanted;
  
  figure(1);
  clf;
  hold on;
  draw_config( config );
  draw_info( config, info );
  hold off;
  axis square;
  
  if(frame<=nb_frames)
    mov(frame) = getframe(gcf);  % Record a frame for a movie
    frame = frame + 1;
  end
  
end

% Create AVI file
movie2avi(mov, 'run_dynamics_demo.avi', 'compression', 'None');
