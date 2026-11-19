function string_simulation_template01()
close all; clf;

    % System Parameters
    num_masses = 4;
    total_mass = 150;
    tension_force = total_mass*9.81;
    string_length = 50;
    damping_coeff = 2.4;
    
    dx = string_length/(num_masses+1);
    
    amplitude_Uf = 0.1;
    omega_Uf = 2;
    
    %list of x points (including the two endpoints)
    xlist = linspace(0,string_length,num_masses+2);
    
    Uf_func = @(t_in) amplitude_Uf*cos(omega_Uf*t_in);
    dUfdt_func = @(t_in) -omega_Uf*amplitude_Uf*sin(omega_Uf*t_in);
    
    %generate the struct
    string_params = struct();
    string_params.n = num_masses;
    string_params.M = total_mass;
    string_params.Uf_func = Uf_func;
    string_params.dUfdt_func = dUfdt_func;
    string_params.Tf = tension_force;
    string_params.L = string_length;
    string_params.c = damping_coeff;
    string_params.dx = dx;
    
    %load string_params into rate function
    my_rate_func = @(t_in,V_in) string_rate_func01(t_in,V_in,string_params);
    
    
    %initial conditions
    U0 = [2 4 2 4]';
    dUdt0 = [0 2 0 4]';
    V0 = [U0;dUdt0];
    
    tspan = linspace(0,30,1000);
    
    %run the integration
    [tlist, Vlist] = ode45(my_rate_func,tspan,V0);


% Animation

    fname = 'vibrating_string_animation.avi';
    
    writerObj = VideoWriter(fname);
    writerObj.FrameRate = 30;
    open(writerObj);
    
    fig1 = figure(1);
    
    xlabel('Position Along the String ($x$) (-)', 'Interpreter','latex');
    ylabel('Transverse Displacement $u(x,t) (-)$', 'Interpreter','latex');
    title('Vibrating String Simulation', 'Interpreter','latex');
    set(gca, 'TickLabelInterpreter','latex', 'FontSize',14);
    
    hold on;
    
    % Plot initial string
    U_initial = Vlist(1,1:num_masses)';
    
    y_initial = [0; U_initial; Uf_func(tlist(1))];
    
    string_plot = plot(xlist, y_initial, 'k-o', 'LineWidth',2, 'MarkerSize',12, 'MarkerFaceColor','r');
    
    % Keep axes fixed during animation
    xlim([0 string_length]);
    
    % Choose y limits based on the expected motion
    y_n = 6;
    ylim([-y_n y_n]);
    
    
    % Animation
    
    for frame = 1:length(tlist)
    
        % Displacements of all n masses
        U_current = Vlist(frame,1:num_masses)';
    
        % Right boundary displacement
        Uf_current = Uf_func(tlist(frame));
    
        % Complete string:
        % fixed left endpoint + masses + moving right endpoint
        y_current = [0; U_current; Uf_current];
    
        % Update the string
        set(string_plot, 'XData',xlist, 'YData',y_current);
    
        title(sprintf('Vibrating String Simulation', 'Interpreter','latex'));
        drawnow;
 
        % Capture and save frame
        current_frame = getframe(fig1);
        writeVideo(writerObj,current_frame);
    end
    close(writerObj);
end
