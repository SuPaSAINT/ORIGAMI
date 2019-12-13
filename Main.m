% Main - Stackelberg security game solved by ORIGAMI algorithm
% +HDR-------------------------------------------------------------------------
% FILE NAME      : Main.m
% TYPE           : MATLAB File
% COURSE         : Binghamton University
%                  EECE580A - Cyber Physical Systems Security
% CODER          : Joseph St. Cyr - B.S. ECE, Graduate Student (M.S. ECE)
%                  jstcyr1@binghamton.edu
% DATE           : 12/02/2019
% GITHUB         : https://github.com/SuPaSAINT/ORIGAMI.git
% -----------------------------------------------------------------------------
% DESCRIPTION    : Stackelberg security game solved by ORIGAMI algorithm
%                  2 players --> Leader:   defender
%                                Follower: attacker
% -----------------------------------------------------------------------------
% REFERENCE      : Computing_Optimal_Randomized_Resource_Allocations_for_Massive_Security_Games
%                     Christopher Kiekintveld, Manish Jain, Jason Tsai
%                     James Pita, Fernando Ordóñez, and Milind Tambe
%                     University of Southern California, Los Angeles, CA 90089
%                     {kiekintv, manishja, jasontts, jpita, fordon, tambe}@usc.edu
% -----------------------------------------------------------------------------
% SYNTAX         : N/A
% -----------------------------------------------------------------------------
% INPUTS         : NONE
% -----------------------------------------------------------------------------
% OUTPUTS        : figure1 - Contains several subplots with interesting data points
%                  figure2 - Contains elapsed time per game
% -HDR-------------------------------------------------------------------------
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% CLEAR THE WORKSPACE AND COMMAND WINDOW  %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
clear all;
clc;



% %%%%%%%%%%%%%%%%%% %
% START ELAPSED TIME %
% %%%%%%%%%%%%%%%%%% %
display = fprintf('=========================\n===== Starting Main =====\n=========================');
disp(display)
start_time = clock;



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% SET UP THE GAME CONFIGURABLES %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% WHAT ARE THE AVAILABLE DEFENDER RESOURCES FOR EACH GAME?
%   [GAME_1; GAME_2; GAME_3; ... GAME_N]
defender_resources = [2;3;4];

% WHAT IS THE PAYOFF OF EACH TARGET FOR EACH PLAYER?
%   RESTRICT PAYOFF SUCH THAT...
%     defender_uncovered_payoff(TARGET) < defender_covered_payoff(TARGET)
%   AND...
%     attacker_uncovered_payoff(TARGET) > attacker_covered_payoff(TARGET)
%   FOR ALL TARGETS (1;2;3;...;n)
attacker_uncovered_payoff = [ 10; 20; 30; 40];
attacker_covered_payoff   = [-10;-20;-30;-40];

defender_uncovered_payoff = [-10;-20;-30;-40];
defender_covered_payoff   = [ 10; 20; 30; 40];

config_time = clock;
config_time_seconds = etime(config_time,start_time);
config_time_minutes = floor(config_time_seconds/60);
config_time_seconds = rem(config_time_seconds,60);
display = fprintf('Configuration time (mm:ss): %g:%g',config_time_minutes,config_time_seconds);
disp(display)



% %%%%%%%%%%%%%%% %
% INITIALIZATIONS %
% %%%%%%%%%%%%%%% %
% DETERMINE NUMBER OF GAMES AND TARGETS
num_games = length(defender_resources(:,1));
num_targets = length(attacker_uncovered_payoff(:,1));

% INITIALIZE GAME OUTPUTS
coverage = zeros(num_games,num_targets);
defender_payoff = zeros(num_games,1);
attacker_payoff = zeros(num_games,1);

% INITIALIZE GAME TIME VARIABLES
game_time = zeros(num_games,length(clock));
game_time_seconds = zeros(num_games,1);
game_time_minutes = zeros(num_games,1);

% INITIALIZE MISCELLANEOUS VARIABLES
game_labels = strings(1,num_games);

init_time = clock;
init_time_seconds = etime(init_time,config_time);
init_time_minutes = floor(init_time_seconds/60);
init_time_seconds = rem(init_time_seconds,60);
display = fprintf('Initialization time (mm:ss): %g:%g',init_time_minutes,init_time_seconds);
disp(display)



% %%%%%%%%%%%%%%%%% %
%  EVALUATE GAME(S) %
% %%%%%%%%%%%%%%%%% %
for game = 1:num_games
    display = fprintf('===== Starting Game %d =====', game);
    disp(display)
    [coverage(game,:), defender_payoff(game,1), attacker_payoff(game,1)] = ORIGAMI(num_targets, ...
                                                                                   defender_resources(game), ...
                                                                                   defender_uncovered_payoff, defender_covered_payoff, ...
                                                                                   attacker_uncovered_payoff, attacker_covered_payoff);

    game_time(game,:) = clock;
    if (game == 1)
        game_time_seconds(game) = etime(game_time(game,:),init_time);
    else
        game_time_seconds(game) = etime(game_time(game,:),game_time(game-1,:));
    end % if
    game_time_minutes(game) = floor(game_time_seconds(game)/60);
    game_time_seconds(game) = rem(game_time_seconds(game),60);
    display = fprintf('Game %d time (mm:ss): %g:%g', game, game_time_minutes(game), game_time_seconds(game));
    disp(display)

    game_labels(game) = "Game " + game;
end % for



% %%%%%%%%%%%%%%%%%%%%%%%%% %
%  GENERATE RESULTS FIGURE  %
% %%%%%%%%%%%%%%%%%%%%%%%%% %
figure1 = figure;
    subplot(2,2,1);
        fig1_bar1 = bar(categorical(game_labels),defender_resources);
        set(fig1_bar1(1),'CData',1,'FaceColor',[0 0.4470 0.7410]); % DEFENDER (BLUE-ISH)
        legend({'Defender'},'Location','bestoutside');
        title('Available Resources Per Game');
        ylabel('Available Resources');
        fig1_bar1_y_axis_min = 0;
        fig1_bar1_y_axis_max = max(unique(defender_resources)) + 1;
        ylim([fig1_bar1_y_axis_min fig1_bar1_y_axis_max]);
        grid on;
        box on;
    subplot(2,2,2);
        for game = 1:num_games
            if (game == 1)
                fig1_bar2_y_axis = num_targets;
            else
                fig1_bar2_y_axis = [fig1_bar2_y_axis, num_targets];
          end % if
        end % for
        fig1_bar2 = bar(categorical(game_labels),fig1_bar2_y_axis);
        set(fig1_bar2(1),'CData',1,'FaceColor',[1 0 1]); % TARGETS (MAGENTA)
        legend({'Targets'},'Location','bestoutside');
        title('Total Targets Per Game');
        ylabel('Number of Targets');
        fig1_bar2_y_axis_min = 0;
        fig1_bar2_y_axis_max = num_targets + 1;
        ylim([fig1_bar2_y_axis_min fig1_bar2_y_axis_max]);
        grid on;
        box on;
    subplot(2,2,3);
        for game = 1:num_games
            if (game == 1)
                fig1_bar3_y_axis = [sum(coverage(game,:)), defender_resources(game)-sum(coverage(game,:));];
            else
                fig1_bar3_y_axis = [fig1_bar3_y_axis; [sum(coverage(game,:)), defender_resources(game)-sum(coverage(game,:));]];
          end % if
        end % for
        fig1_bar3 = bar(categorical(game_labels),fig1_bar3_y_axis, 'FaceColor','flat');
        set(fig1_bar3(1),'CData',1,'FaceColor',[0 1 0]); % UTILIZED (GREEN)
        set(fig1_bar3(2),'CData',2,'FaceColor',[1 0 0]); % NON-UTILIZED (RED)
        legend({'Utilized','Non-utilized '},'Location','bestoutside');
        title('Defender Resource Utilization @ Strong Stackelberg Equilibrium');
        ylabel('Resources');
        fig1_bar3_y_axis_min = 0;
        fig1_bar3_y_axis_max = max(unique(fig1_bar3_y_axis)) * 1.1;
        ylim([fig1_bar3_y_axis_min fig1_bar3_y_axis_max]);
        grid on;
        box on;
    subplot(2,2,4);
        for game = 1:num_games
            if (game == 1)
                fig1_bar4_y_axis = [defender_payoff(game), attacker_payoff(game);];
            else
                fig1_bar4_y_axis = [fig1_bar4_y_axis; [defender_payoff(game), attacker_payoff(game);]];
          end % if
        end % for
        fig1_bar4 = bar(categorical(game_labels),fig1_bar4_y_axis);
        set(fig1_bar4(1),'CData',1,'FaceColor',[0 0.4470 0.7410]);      % DEFENDER (BLUE-ISH)
        set(fig1_bar4(2),'CData',1,'FaceColor',[0.8500 0.3250 0.0980]); % ATTACKER (ORANGE-ISH)
        legend({'Defender / Leader','Attacker / Follower'},'Location','bestoutside');
        title('Player Payoff @ Strong Stackelberg Equilibrium');
        ylabel('Payoff');
        fig1_bar4_y_axis_min = min(unique(fig1_bar4_y_axis)) * 1.1;
        fig1_bar4_y_axis_max = max(unique(fig1_bar4_y_axis)) * 1.1;
        ylim([fig1_bar4_y_axis_min fig1_bar4_y_axis_max]);
        grid on;
        box on;

figure2 = figure;
    for game = 1:num_games
        if (game == 1)
            fig2_bar1_y_axis = etime(game_time(game,:),init_time);
        else
            fig2_bar1_y_axis = [fig2_bar1_y_axis, etime(game_time(game,:),game_time(game-1,:))];
      end % if
    end % for
    fig2_bar1 = bar(categorical(game_labels),fig2_bar1_y_axis);
    set(fig2_bar1(1),'CData',1,'FaceColor',[0.9290 0.6940 0.1250]); % ELAPSED TIME (YELLOW-ISH)
    title('Elapsed Time Per Game');
    ylabel('Time (Seconds)');
    fig2_bar1_y_axis_min = 0;
    fig2_bar1_y_axis_max = max(unique(fig2_bar1_y_axis)) * 1.1;
    ylim([fig2_bar1_y_axis_min fig2_bar1_y_axis_max]);
    grid on;
    box on;



% %%%%%%%%%%%%%%%%%%% %
%  STOP ELAPSED TIME  %
% %%%%%%%%%%%%%%%%%%% %
stop_time = clock;
elapsed_seconds = etime(stop_time,start_time);
elapsed_minutes = floor(elapsed_seconds/60);
elapsed_seconds = rem(elapsed_seconds,60);
display = fprintf('Total elapsed time (mm:ss): %g:%g',elapsed_minutes,elapsed_seconds);
disp(display)

display = fprintf('=========================\n=====  Ending Main  =====\n=========================');
disp(display)
