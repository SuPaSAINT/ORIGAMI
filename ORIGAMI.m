% ORIGAMI - Optimizing Resources In GAmes using Maximal Indifference
% 
% Computing_Optimal_Randomized_Resource_Allocations_for_Massive_Security_Games
%     Christopher Kiekintveld, Manish Jain, Jason Tsai
%     James Pita, Fernando Ordóñez, and Milind Tambe
%     University of Southern California, Los Angeles, CA 90089
%     {kiekintv, manishja, jasontts, jpita, fordon, tambe}@usc.edu
% 
% Syntax:  
% 
% Inputs:
%   attacker_uncovered_payoff - Attacker's vector of payoffs for each target given it is uncovered
%   attacker_covered_payoff -  Attacker's vector of payoffs for each target given it is covered
%   defender_resources - Defender's resources to cover targets
% 
% Outputs:
%   coverage - Defender's coverage vector
% 
% -----------------------------------------------------------------------------
function [coverage] = ORIGAMI(attacker_uncovered_payoff, attacker_covered_payoff, defender_resources)
    % IF DEBUG_PRINT = 1, THEN DEBUG PRINT STATEMENTS ENABLED, ELSE DISABLED;
    DEBUG_PRINT = 0;

    % THE SIZE OF THE VECTOR DETERMINES THE NUMBER OF TARGETS
    num_targets = length(attacker_uncovered_payoff(:,1));

    % NEED TO SORT TARGETS BY MAXIMAL attacker_uncovered_payoff IN DECENDING ORDER
    [payoff,target_index] = sort(attacker_uncovered_payoff, 'descend');

    % INITIALIZE REMAINING DEFENDER RESOURCES
    defender_resources_left = defender_resources;

    % INITIALIZE COVERAGE VECTOR
    coverage = zeros(num_targets,1);
    added_coverage = zeros(num_targets,1);

    % INITIALIZE THE COVERAGE BOUND TO BE THE MINIMAL EXPECTED PAYOFF OF THE ATTACKER
    coverage_bound = min(attacker_covered_payoff);
    min_coverage_bound = coverage_bound;

    % INITIALIZE THE RATIO VECTOR
    ratio = zeros(num_targets,1);

    % DETERMINE COVERAGE TO ADD
    t = 1; % t IS THE INDEX INTO THE PAYOFF VECTOR
    while (t <= num_targets-1)

        added_coverage(target_index(t)) = ( (attacker_uncovered_payoff(target_index(t+1)) - attacker_uncovered_payoff(target_index(t))) / (attacker_covered_payoff(target_index(t)) - attacker_uncovered_payoff(target_index(t))) ) - coverage(target_index(t));

        if ((coverage(target_index(t)) + added_coverage(target_index(t))) >= 1)
            if (DEBUG_PRINT == 1)
                display = fprintf('ORIGAMI_MSG01: Coverage probability of target %d >= 1.',target_index(t));
                disp(display)
            end % if
            coverage_bound = max(coverage_bound,attacker_covered_payoff(target_index(t)));
        end % if

        % NOTE: THAT INEQUALITIES DO NOT MATCH THE PROPOSED PSEUDO-CODE BECAUSE THEY WERE INCORRECT
        %   COVERAGE BOUND SHOULD CAUSE BREAK IF GREATER THAN THE MINIMAL ATTACKER PAYOFF FOR COVERED TARGET
        %   IF TOTAL ADDED COVERAGE IS >= TO REMAINING DEFENDER RESOURCES THEN BREAK
        if ((coverage_bound > min_coverage_bound) || sum(added_coverage(:,1)) >= defender_resources_left)
            if (DEBUG_PRINT == 1)
                display = fprintf('ORIGAMI_MSG02: Sum of added coverage probability is greater than the remaining defender resources so break. (target = %d)',target_index(t));
                disp(display)
            end % if
            break;
        end % if

        coverage(target_index(t)) = coverage(target_index(t)) + added_coverage(target_index(t));

        defender_resources_left = defender_resources_left - sum(added_coverage(:,1));

        t = t+1;
    end % while

    ratio(target_index(t)) = (1 / (attacker_uncovered_payoff(target_index(t)) - attacker_covered_payoff(target_index(t))) );

    coverage(target_index(t)) = coverage(target_index(t)) + ( (ratio(target_index(t))*defender_resources_left) / sum(ratio(:,1)));

    if (coverage(target_index(t)) >= 1)
        if (DEBUG_PRINT == 1)
            display = fprintf('ORIGAMI_MSG03: Coverage probability of target %d >= 1.',target_index(t));
            disp(display)
        end % if
        coverage_bound = max(coverage_bound,attacker_covered_payoff(target_index(t)));
    end % if
    
    if (coverage_bound > min_coverage_bound)
        coverage(target_index(t)) = ( (coverage_bound - attacker_uncovered_payoff(target_index(t))) / (attacker_covered_payoff(target_index(t)) - attacker_uncovered_payoff(target_index(t))) )
    end % if

    % if (DEBUG_PRINT == 1)
        coverage_sum = sum(coverage);
    % end % if

end % function