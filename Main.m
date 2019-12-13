% Main - Stackelberg security game solved by ORIGAMI algorithm
% +HDR-------------------------------------------------------------------------
% FILE NAME      : Main.m
% TYPE           : MATLAB File
% COURSE         : Binghamton University
%                  EECE580A - Cyber Physical Systems Security
% -----------------------------------------------------------------------------
% PURPOSE : Stackelberg security game solved by ORIGAMI algorithm
%           2 players --> Leader:   defender
%                         Follower: attacker
% 
% -HDR-------------------------------------------------------------------------
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% CLEAR THE WORKSPACE AND COMMAND WINDOW  %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
clear all;
clc;



% %%%%%%%%%%%%%%%%%% %
% START ELAPSED TIME %
% %%%%%%%%%%%%%%%%%% %
start_time = clock;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% SET UP THE GAME CONFIGURABLES %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% WHAT ARE THE AVAILABLE DEFENDER RESOURCES FOR EACH GAME?
%   [GAME_1; GAME_2; GAME_3]
defender_resources = [2;3;4];

% WHAT IS THE PAYOFF OF EACH TARGET FOR EACH PLAYER?
%   RESTRICT PAYOFF SUCH THAT...
%     defender_uncovered_payoff(TARGET) < defender_covered_payoff(TARGET)
%   AND...
%     attacker_uncovered_payoff(TARGET) > attacker_covered_payoff(TARGET)
%   FOR ALL TARGETS (1;2;...;n)
attacker_uncovered_payoff = [ 10; 20; 30; 40];
attacker_covered_payoff   = [-10;-20;-30;-40];

defender_uncovered_payoff = [-10;-20;-30;-40];
defender_covered_payoff   = [ 10; 20; 30; 40];

config_time = clock;
config_time_seconds = etime(config_time,start_time);
config_time_minutes = floor(config_time_seconds/60);
config_time_seconds = rem(config_time_seconds,60);
display = fprintf('Config time (mm:ss): %g:%g.',config_time_minutes,config_time_seconds);
disp(display)



% %%%%%%%%%%%%%%%%%% %
%  EVALUATE GAME #1  %
% %%%%%%%%%%%%%%%%%% %
display = fprintf('%%%%% Starting Game 1 %%%%%');
disp(display)
[coverage_game1, attacker_payoff_game1, defender_payoff_game1] = ORIGAMI(attacker_uncovered_payoff, attacker_covered_payoff, ...
                                                                         defender_uncovered_payoff, defender_covered_payoff, defender_resources(1));

game_1_time = clock;
game_1_time_seconds = etime(game_1_time,config_time);
game_1_time_minutes = floor(game_1_time_seconds/60);
game_1_time_seconds = rem(game_1_time_seconds,60);
display = fprintf('Game 1 time (mm:ss): %g:%g.',game_1_time_minutes,game_1_time_seconds);
disp(display)



% %%%%%%%%%%%%%%%%%% %
%  EVALUATE GAME #2  %
% %%%%%%%%%%%%%%%%%% %
display = fprintf('%%%%% Starting Game 2 %%%%%');
disp(display)
[coverage_game2, attacker_payoff_game2, defender_payoff_game2] = ORIGAMI(attacker_uncovered_payoff, attacker_covered_payoff, ...
                                                                         defender_uncovered_payoff, defender_covered_payoff, defender_resources(2));

game_2_time = clock;
game_2_time_seconds = etime(game_2_time,game_1_time);
game_2_time_minutes = floor(game_2_time_seconds/60);
game_2_time_seconds = rem(game_2_time_seconds,60);
display = fprintf('Game 2 time (mm:ss): %g:%g.',game_2_time_minutes,game_2_time_seconds);
disp(display)



% %%%%%%%%%%%%%%%%%% %
%  EVALUATE GAME #3  %
% %%%%%%%%%%%%%%%%%% %
display = fprintf('%%%%% Starting Game 3 %%%%%');
disp(display)
[coverage_game3, attacker_payoff_game3, defender_payoff_game3] = ORIGAMI(attacker_uncovered_payoff, attacker_covered_payoff, ...
                                                                         defender_uncovered_payoff, defender_covered_payoff, defender_resources(3));

game_3_time = clock;
game_3_time_seconds = etime(game_3_time,game_2_time);
game_3_time_minutes = floor(game_3_time_seconds/60);
game_3_time_seconds = rem(game_3_time_seconds,60);
display = fprintf('Game 3 time (mm:ss): %g:%g.',game_3_time_minutes,game_3_time_seconds);
disp(display)



% %%%%%%%%%%%%%%%%%%%%%%% %
%  GENERATE RESULTS PLOT  %
% %%%%%%%%%%%%%%%%%%%%%%% %
figure1 = figure;
    fig1_x_axis = categorical({'Game 1', 'Game 2', 'Game 3'});
    fig1_x_axis = reordercats(fig1_x_axis,{'Game 1', 'Game 2', 'Game 3'});
    subplot(2,1,1);
        fig1_bar1 = bar(fig1_x_axis,defender_resources);
        legend({'Defender'},'Location','bestoutside');
        title('Available Resources Per Game');
        ylabel('Available Resources');
        fig1_bar1_y_axis_min = 0;
        fig1_bar1_y_axis_max = max(unique(defender_resources)) + 1;
        ylim([fig1_bar1_y_axis_min fig1_bar1_y_axis_max]);
        grid on;
        box on;
    subplot(2,1,2);
        fig1_bar2 = bar(fig1_x_axis,[attacker_payoff_game1, defender_payoff_game1; ...
                                     attacker_payoff_game2, defender_payoff_game2; ...
                                     attacker_payoff_game3, defender_payoff_game3]);
        legend({'Attacker','Defender'},'Location','bestoutside');
        title('Player Payoff @ Strong Stackelberg Equilibrium');
        ylabel('Payoff');
        fig1_bar2_y_axis_min = min(unique([attacker_payoff_game1, defender_payoff_game1; ...
                                           attacker_payoff_game2, defender_payoff_game2; ...
                                           attacker_payoff_game3, defender_payoff_game3])) * 1.1;
        fig1_bar2_y_axis_max = max(unique([attacker_payoff_game1, defender_payoff_game1; ...
                                           attacker_payoff_game2, defender_payoff_game2; ...
                                           attacker_payoff_game3, defender_payoff_game3])) * 1.1;
        ylim([fig1_bar2_y_axis_min fig1_bar2_y_axis_max]);
        grid on;
        box on;

figure2 = figure;
    fig2_bar1_x_axis = categorical({'Game 1', 'Game 2', 'Game 3'});
    fig2_bar1_x_axis = reordercats(fig2_bar1_x_axis,{'Game 1', 'Game 2', 'Game 3'});
    fig2_bar1 = bar(fig2_bar1_x_axis, [etime(game_1_time,config_time), ...
                                       etime(game_2_time,game_1_time), ...
                                       etime(game_3_time,game_2_time)]);
    title('Elapsed Time Per Game');
    ylabel('Time (Seconds)');
    grid on;
    box on;



% %%%%%%%%%%%%%%%%%%% %
%  STOP ELAPSED TIME  %
% %%%%%%%%%%%%%%%%%%% %
stop_time = clock;
elapsed_seconds = etime(stop_time,start_time);
elapsed_minutes = floor(elapsed_seconds/60);
elapsed_seconds = rem(elapsed_seconds,60);
display = fprintf('Total elapsed time (mm:ss): %g:%g.',elapsed_minutes,elapsed_seconds);
disp(display)


