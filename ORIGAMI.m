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

    % THE SIZE OF THE VECTOR DETERMINES THE NUMBER OF TARGETS
    num_targets = length(attacker_uncovered_payoff(:,1));

    % NEED TO SORT TARGETS BY MAXIMAL attacker_uncovered_payoff IN DECENDING ORDER
    [payoff,target_index] = sort(attacker_uncovered_payoff, 'descend');

    % INITIALIZE REMAINING DEFENDER RESOURCES
    defender_resources_left = defender_resources;

    % INITIALIZE COVERAGE VECTOR
    coverage = zeros(num_targets,1);
    added_coverage = zeros(num_targets,1);

    % INITIALIZE THE COVERAGE BOUND (I THINK x = coverage_bound...so put this here for now...)
    coverage_bound = (coverage(target_index(1))*attacker_covered_payoff(target_index(1))) + ((1-coverage(target_index(1)))*attacker_uncovered_payoff(target_index(1)));

    % INITIALIZE THE RATIO VECTOR
    ratio = zeros(num_targets,1);

    % DETERMINE COVERAGE TO ADD
    t = 1; % t IS THE INDEX INTO THE PAYOFF VECTOR
    while (t <= num_targets-1)

        added_coverage(target_index(t)) = ( (attacker_uncovered_payoff(target_index(t+1)) - attacker_uncovered_payoff(target_index(t))) / (attacker_covered_payoff(target_index(t)) - attacker_uncovered_payoff(target_index(t))) ) - coverage(target_index(t));

        if ( (coverage(target_index(t)) + added_coverage(target_index(t))) > 1)
            display = fprintf('Coverage probability of target %d exceeded 1 so break.',target_index(t));
            disp(display)
            break;
        end % if

        if ( sum(added_coverage(:,1)) > defender_resources_left )
            display = fprintf('Sum of added coverage probability is greater than the remaining defender resources so break. (target = %d)',target_index(t));
            disp(display)
            break;
        end % if

        coverage(target_index(t)) = coverage(target_index(t)) + added_coverage(target_index(t));

        defender_resources_left = defender_resources_left - sum(added_coverage(:,1));

        t = t+1;
    end % while

    ratio(target_index(t)) = (1 / (attacker_uncovered_payoff(target_index(t)) - attacker_covered_payoff(target_index(t))) );

    coverage(target_index(t)) = coverage(target_index(t)) + ( (ratio(target_index(t))*defender_resources_left) / sum(ratio(:,1)));

    if ( coverage(target_index(t)) > 1)
        display = fprintf('Coverage probability of target %d exceeded 1.',target_index(t));
        disp(display)
    end % if

breakpoint = 0; % DUMMY OPERATION TO SET BREAKPOINT

end % function