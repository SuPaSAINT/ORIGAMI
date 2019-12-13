% ORIGAMI - Optimizing Resources In GAmes using Maximal Indifference
% +HDR-------------------------------------------------------------------------
% FILE NAME      : ORIGAMI.m
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
% SYNTAX         : [coverage, defender_payoff, attacker_payoff] = ORIGAMI(num_targets, ...
%                                                                         defender_resources, ...
%                                                                         defender_uncovered_payoff, defender_covered_payoff, ...
%                                                                         attacker_uncovered_payoff, attacker_covered_payoff);
%                                                                         
% -----------------------------------------------------------------------------
% INPUTS         : num_targets               - Number of potential targets in the game
%                  defender_resources        - Defender's resources to cover targets
%                  defender_uncovered_payoff - Defender's vector of payoffs for each target given it is uncovered
%                  defender_covered_payoff   - Defender's vector of payoffs for each target given it is covered
%                  attacker_uncovered_payoff - Attacker's vector of payoffs for each target given it is uncovered
%                  attacker_covered_payoff   - Attacker's vector of payoffs for each target given it is covered
% -----------------------------------------------------------------------------
% OUTPUTS        : coverage        - Defender's coverage vector
%                  defender_payoff - Defender's final payoff given the calculated coverage vector
%                  attacker_payoff - Attacker's final payoff given the calculated coverage vector
% -HDR-------------------------------------------------------------------------
function [coverage, defender_payoff, attacker_payoff] = ORIGAMI(num_targets, ...
                                                                defender_resources, ...
                                                                defender_uncovered_payoff, defender_covered_payoff, ...
                                                                attacker_uncovered_payoff, attacker_covered_payoff);
    % %%%%%%%%%%%%%%% %
    % INITIALIZATIONS %
    % %%%%%%%%%%%%%%% %
    % IF DEBUG_PRINT = 1, THEN DEBUG PRINT STATEMENTS ENABLED, ELSE DISABLED;
    DEBUG_PRINT = 0;

    % NEED TO SORT TARGETS BY MAXIMAL attacker_uncovered_payoff IN DECENDING ORDER.
    % NOTE: target_index(t) WILL TRANSLATE THE LOOP INDEX TO TARGET INDEX
    %       DON'T USE SORTED PAYOFFS TO SAVE ON MEMORY RESOURCES
    [~,target_index] = sort(attacker_uncovered_payoff, 'descend');

    % INITIALIZE REMAINING DEFENDER RESOURCES
    defender_resources_left = defender_resources;

    % INITIALIZE COVERAGE VECTORS
    coverage = zeros(num_targets,1);
    added_coverage = zeros(num_targets,1);

    % INITIALIZE THE COVERAGE BOUND TO BE THE MINIMAL EXPECTED PAYOFF OF THE ATTACKER
    coverage_bound_min = min(attacker_covered_payoff);
    coverage_bound = coverage_bound_min;

    % INITIALIZE THE RATIO VECTOR
    ratio = zeros(num_targets,1);

    % INITIALIZE THE FINAL DEFENDER AND ATTACKER PAYOFF VECTORS
    defender_payoff_vector = zeros(num_targets,1);
    attacker_payoff_vector = zeros(num_targets,1);

    % INITIALIZE THE FINAL DEFENDER AND ATTACKER PAYOFFS
    defender_payoff = 0;
    attacker_payoff = 0;

    % %%%%%%%%%%%%%%%%%%%%%%%%% %
    % CALCULATE COVERAGE VECTOR %
    % %%%%%%%%%%%%%%%%%%%%%%%%% %
    next = 2; % next IS THE CURRENT TARGET TO ADD TO THE ATTACK VECTOR + 1
    while (next <= num_targets)
        for t = next-1:-1:1 % ENSURE ADDED COVERAGE IS CLEARED FOR ALL TARGETS IN ATTACK SET AT BEGINNING OF EACH LOOP
            added_coverage(target_index(t)) = 0;
        end % for

        for t = next-1:-1:1
            % DETERMINE COVERAGE TO BE ADDED TO THE CURRENT TARGET
            added_coverage(target_index(t)) = (   (attacker_uncovered_payoff(target_index(next)) - attacker_uncovered_payoff(target_index(t))) ...
                                                / (attacker_covered_payoff(target_index(t)) - attacker_uncovered_payoff(target_index(t))) ...
                                              ) - coverage(target_index(t));

            % CHECK TO SEE IF THE CURRENT TARGET'S EXISTING COVERAGE PLUS ADDED COVERAGE IS >= 1
            if ((coverage(target_index(t)) + added_coverage(target_index(t))) >= 1)
                if (DEBUG_PRINT == 1)
                    display = fprintf('ORIGAMI_MSG01: Target %d.',target_index(t));
                    disp(display)
                end % if
                % IF THE CURRENT TARGET'S EXISTING COVERAGE PLUS ADDED COVERAGE IS >= 1 THIS SIGNALS
                % WE HAVE HIT TERMINATION CONDITION 2 (REFERENCED IN PAPER) SO UPDATE COVERAGE BOUND.
                %   THE SECOND TERMINATION CONDITION OCCURS WHEN ANY TARGET T IS COVERED WITH
                %   PROBABILITY 1. THE EXPECTED VALUE FOR AN ATTACK ON THIS TARGET CANNOT
                %   BE REDUCED BELOW attacker_covered_payoff(target_index(t)),
                %   SO THIS DEFINE THE FINAL EXPECTED PAYOFFS FOR THE ATTACK SET.
                coverage_bound = max(coverage_bound,attacker_covered_payoff(target_index(t)));
            end % if

            % THE FIRST TERMINATION CONDITION OCCURS WHEN ADDING THE NEXT TARGET TO THE ATTACK SET
            % REQUIRES MORE TOTAL COVERAGE PROBABILITY THAN THE DEFENDER HAS RESOURCES AVAILABLE. AT THIS
            % POINT, THE SIZE OF THE ATTACK SET CANNOT BE INCREASED FURTHER, BUT ADDITIONAL
            % PROBABILITY CAN STILL BE ADDED TO THE TARGETS IN THE ATTACK SET
            % IN THE SPECIFIC RATIO NECESSARY TO MAINTAIN INDIFFERENCE.
            % NOTE: THAT INEQUALITY DOES NOT MATCH THE PROPOSED PSEUDO-CODE BECAUSE IT WAS INCORRECT
            %   IF TOTAL ADDED COVERAGE THIS ITERATION IS > TO REMAINING DEFENDER RESOURCES THEN BREAK
            if (sum(added_coverage(target_index(1:next-1),1)) > defender_resources_left)
                if (DEBUG_PRINT == 1)
                    display = fprintf('ORIGAMI_MSG02: Target %d.',target_index(t));
                    disp(display)
                end % if
                break;
            end % if

            % THE SECOND TERMINATION CONDITION OCCURS WHEN ANY TARGET T IS COVERED WITH
            % PROBABILITY 1. THE EXPECTED VALUE FOR AN ATTACK ON THIS TARGET CANNOT
            % BE REDUCED BELOW attacker_covered_payoff(target_index(t)),
            % SO THIS DEFINE THE FINAL EXPECTED PAYOFFS FOR THE ATTACK SET. THE FINAL COVERAGE PROBABILITIES ARE COMPUTED
            % SETTING THE COVERAGES SO THAT AS MANY TARGETS AS POSSIBLE HAVE AN
            % EXPECTED PAYOFF OF attacker_covered_payoff(target_index(t)).
            % NOTE: THAT INEQUALITY DOES NOT MATCH THE PROPOSED PSEUDO-CODE BECAUSE IT WAS INCORRECT
            %   COVERAGE BOUND SHOULD CAUSE BREAK IF GREATER THAN THE MINIMAL ATTACKER PAYOFF FOR COVERED TARGET
            if (coverage_bound > coverage_bound_min)
                if (DEBUG_PRINT == 1)
                    display = fprintf('ORIGAMI_MSG03: Target %d.',target_index(t));
                    disp(display)
                end % if
                break;
            end % if

            % UPDATE COVERAGE FOR THIS TARGET
            coverage(target_index(t)) = coverage(target_index(t)) + added_coverage(target_index(t));

            % UPDATE THE REMAINING DEFERNDER RESOURCES
            defender_resources_left = defender_resources_left - sum(added_coverage(target_index(1:next-1),1));
        end % for

        next = next+1;
    end % while

    % COLLECT RATIO FOR EACH TARGET IN THE ATTACK SET TO ALLOCATE REMAINING COVERAGE PROBABILITY
    for t = next-1:-1:1
        ratio(target_index(t)) = (1 / (attacker_uncovered_payoff(target_index(t)) - attacker_covered_payoff(target_index(t))) );
    end % for

    % ALLOCATE REMAINING COVERAGE PROBABLITY GIVEN REMAINING DEFENDER RESOURCES AND TARGET RATIOS
    for t = next-1:-1:1
        coverage(target_index(t)) = coverage(target_index(t)) ...
                                    + ( (ratio(target_index(t))*defender_resources_left) / sum(ratio(target_index(1:next-1),1)) );

        % CHECK TO SEE IF THE CURRENT TARGET'S EXISTING COVERAGE IS >= 1
        if (coverage(target_index(t)) >= 1)
            if (DEBUG_PRINT == 1)
                display = fprintf('ORIGAMI_MSG04: Target %d.',target_index(t));
                disp(display)
            end % if
            % UPDATE THE COVERAGE BOUND
            coverage_bound = max(coverage_bound,attacker_covered_payoff(target_index(t)));
        end % if

        % CHECK TO SEE IF THE COVERAGE BOUND IS > MINIMAL COVERAGE BOUND
        if (coverage_bound > coverage_bound_min)
            % ADJUST ALLOCATION SO TARGET DOES NOT HAVE HIGHER PROBABILITY THAN 1
            coverage(target_index(t)) = (   (coverage_bound - attacker_uncovered_payoff(target_index(t))) ...
                                          / (attacker_covered_payoff(target_index(t)) - attacker_uncovered_payoff(target_index(t))) ...
                                        );
        end % if
    end % for

    % %%%%%%%%%%%%%%%%%%%%%%% %
    % CALCULATE FINAL PAYOFFS %
    % %%%%%%%%%%%%%%%%%%%%%%% %
    
    if (DEBUG_PRINT == 1)
        display = fprintf('Sum(coverage) = %f.',sum(coverage));
        disp(display)
    end % if
    
    % CHECK TO SEE IF THE TOTAL COVERAGE PROBABILITY IS > THE TOTAL DEFENDER RESOURCES
    %   IF IT IS, SOMETHING WENT WRONG AS THIS SHOULDN'T HAPPEN
    if (sum(coverage) > defender_resources)
        % warning('ORIGAMI_WRN01: Total coverage probability is greater than defender_resources!');
        error('ORIGAMI_ERR01: Total coverage probability is greater than defender_resources!');
    end % if

    % CALCULATE PAYOFF VECTORS GIVEN THE COVERAGE VECTOR FOR THE DEFENDER AND ATTACKER
    for target = 1:num_targets
        defender_payoff_vector(target) = (coverage(target)*defender_covered_payoff(target)) + ((1-coverage(target))*defender_uncovered_payoff(target));
        attacker_payoff_vector(target) = (coverage(target)*attacker_covered_payoff(target)) + ((1-coverage(target))*attacker_uncovered_payoff(target));
    end % for

    % IN A STRONG STACKELBERG EQUILIBRIUM, THE ATTACKER SELECTS THE TARGET
    % IN THE ATTACK SET WITH MAXIMUM PAYOFF FOR THE DEFENDER.
    [defender_payoff, optimal_target] = max(defender_payoff_vector);
    attacker_payoff = attacker_payoff_vector(optimal_target);

end % function