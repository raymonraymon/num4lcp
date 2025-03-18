%
% Copyright 2010, Kenny Erleben, DIKU.
%

close all;
clear ;
clc;
dbstop if error;

%--- Create a configuration to simulate
fig = figure(1);
set(gcf,'position',[50/0.277 50/0.277 200/0.277 200/0.277],'Color',[0.314 0.314 0.314]);
config = setup_config( 75, 100, 100, 5 );
config_SI = config;
%--- Create data structures for making a small movie of the simulation

T         = 10.0;    % The total number of seconds that should be simulated simulate
T_SI      = 10.0;    % The total number of seconds that should be simulated simulate
fps       = 30;      % The number of frames of per second that should be displayed
%nb_frames = T*fps-1; % Compute the total number of frames, we do not visualize first frame
%frame     = 1;       % Initialize frame counter

%mov(1:nb_frames) = struct('cdata', [],'colormap', []); % Preallocate movie structure.
vidObj = VideoWriter('run_dynamics_demo.avi');
gifname = 'compare.gif';
open(vidObj);
%--- Create a simulation loop

while T > 0 || T_SI > 0

    dt_wanted = min(T,1/fps);  % How much time do we want to simulate before showing next frame?
    dt_done   = 0;             % How much time has passed

    while( dt_done < dt_wanted )

        info         = collision_detection(config);
        dt           = dt_wanted - dt_done;
        [config, dt]  = simulate(config,info,dt);
        dt_done      = dt_done + dt;

    end


    T = T - dt_wanted;

    dt_wanted_SI = min(T_SI,1/fps);  % How much time do we want to simulate before showing next frame?
    dt_done_SI   = 0;             % How much time has passed
    while( dt_done_SI < dt_wanted_SI )

        info_SI         = collision_detection(config_SI);
        dt              = dt_wanted_SI - dt_done_SI;
        [config_SI, dt] = simulate_SI(config_SI,info_SI,dt);
        dt_done_SI      = dt_done_SI + dt;

    end

    T_SI = T_SI - dt_wanted_SI;



    %figure(1);
    clf;
    title(num2str(10-T));
    subplot(1,2,1)
    hold on;
    draw_config( config );
    draw_info( config, info );
    title(num2str(10-T));
    hold off
    axis square;

    subplot(1,2,2)
    hold on;
    draw_config( config_SI );
    draw_info( config_SI, info_SI );
    title(num2str(10-T));
    
    hold off;
    axis square;
    %suptitle('PGS vs SI')
    sgtitle('PGS vs SI','color','white','Fontsize',20);
    %if(frame<=nb_frames)
    % mov(frame) = getframe(gcf);  % Record a frame for a movie
    % frame = frame + 1;

    currFrame = getframe(fig);
    writeVideo(vidObj,currFrame);
    
    im = frame2im(currFrame);
    [imind,cm] = rgb2ind(im,256);


    outputgif = './';
    if T > 10.0-1.1/fps
        imwrite(imind,cm, [outputgif,gifname], 'gif', 'Loopcount', inf, 'DelayTime', 0.05);
    else
        imwrite(imind,cm, [outputgif,gifname], 'gif', 'WriteMode', 'append', 'DelayTime', 0.05);
    end

    %end

end
close(vidObj);
