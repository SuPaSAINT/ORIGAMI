% ORIGAMI - Optimizing Resources In GAmes using Maximal Indifference
% 
% Computing_Optimal_Randomized_Resource_Allocations_for_Massive_Security_Games
%     Christopher Kiekintveld, Manish Jain, Jason Tsai
%     James Pita, Fernando Ordóñez, and Milind Tambe
%     University of Southern California, Los Angeles, CA 90089
%     {kiekintv, manishja, jasontts, jpita, fordon, tambe}@usc.edu
% 
% Syntax:  [coverage, attacker_payoff, defender_payoff] = ORIGAMI(attacker_uncovered_payoff, attacker_covered_payoff, ...
%                                                                 defender_uncovered_payoff,
%                                                                 defender_covered_payoff, defender_resources);
% 
% Inputs:
%   attacker_uncovered_payoff - Attacker's vector of payoffs for each target given it is uncovered
%   attacker_covered_payoff   - Attacker's vector of payoffs for each target given it is covered
%   defender_resources        - Defender's resources to cover targets
%   defender_uncovered_payoff - Defender's vector of payoffs for each target given it is uncovered
%   defender_covered_payoff   - Defender's vector of payoffs for each target given it is covered
% 
% Outputs:
%   coverage - Defender's coverage vector
%   attacker_payoff - Attacker's vector of final payoffs given the calculated coverage vector
%   defender_payoff - Defender's vector of final payoffs given the calculated coverage vector
% 
% -----------------------------------------------------------------------------
function [coverage, attacker_payoff, defender_payoff] = ORIGAMI(attacker_uncovered_payoff, attacker_covered_payoff, ...
                                                                defender_uncovered_payoff, defender_covered_payoff, defender_resources)
    % IF DEBUG_PRINT = 1, THEN DEBUG PRINT STATEMENTS ENABLED, ELSE DISABLED;
    DEBUG_PRINT = 1;

    % THE SIZE OF THE VECTOR DETERMINES THE NUMBER OF TARGETS
    num_targets = length(attacker_uncovered_payoff(:,1));

    % NEED TO SORT TARGETS BY MAXIMAL attacker_uncovered_payoff IN DECENDING ORDER.
    % NOTE: target_index(t) WILL TRANSLATE THE LOOP INDEX TO TARGET INDEX
    [~,target_index] = sort(attacker_uncovered_payoff, 'descend');

    % INITIALIZE REMAINING DEFENDER RESOURCES
    defender_resources_left = defender_resources;

    % INITIALIZE COVERAGE VECTOR
    coverage = zeros(num_targets,1);
    added_coverage = zeros(num_targets,1);

    % INITIALIZE THE COVERAGE BOUND TO BE THE MINIMAL EXPECTED PAYOFF OF THE ATTACKER
    coverage_bound = min(attacker_covered_payoff);
    coverage_bound_min = coverage_bound;

    % INITIALIZE THE RATIO VECTOR
    ratio = zeros(num_targets,1);

    % INITIALIZE THE FINAL ATTACKER AND DEFENDER PAYOFF VECTORS
    attacker_payoff_vector = zeros(num_targets,1);
    defender_payoff_vector = zeros(num_targets,1);
    attacker_payoff = 0;
    defender_payoff = 0;

    % DETERMINE COVERAGE TO ADD
    next = 2; % next IS THE NEXT TARGET TO ADD TO THE ATTACK VECTOR
    while (next <= num_targets)
        for t = 1:next-1 % ENSURE ADDED COVERAGE IS CLEARED FOR 1 TO NEXT AT BEGINNIGN OF EACH LOOP
            added_coverage(target_index(t)) = 0;
        end % for

        for t = 1:next-1
            added_coverage(target_index(t)) = ( (attacker_uncovered_payoff(target_index(next)) - attacker_uncovered_payoff(target_index(t))) / ...
                                                (attacker_covered_payoff(target_index(t)) - attacker_uncovered_payoff(target_index(t))) ...
                                              ) - coverage(target_index(t));

            if ((coverage(target_index(t)) + added_coverage(target_index(t))) >= 1)
                if (DEBUG_PRINT == 1)
                    display = fprintf('ORIGAMI_MSG01: Target %d.',target_index(t));
                    disp(display)
                end % if
                coverage_bound = max(coverage_bound,attacker_covered_payoff(target_index(t)));
            end % if

            % NOTE: THAT INEQUALITIES DO NOT MATCH THE PROPOSED PSEUDO-CODE BECAUSE THEY WERE INCORRECT
            %   COVERAGE BOUND SHOULD CAUSE BREAK IF GREATER THAN THE MINIMAL ATTACKER PAYOFF FOR COVERED TARGET
            %   IF TOTAL ADDED COVERAGE THIS ITERATION IS > TO REMAINING DEFENDER RESOURCES THEN BREAK
            if ((coverage_bound > coverage_bound_min) || sum(added_coverage(1:next-1,1)) > defender_resources_left)
                if (DEBUG_PRINT == 1)
                    display = fprintf('ORIGAMI_MSG02: Target %d.',target_index(t));
                    disp(display)
                end % if
                break;
            end % if

            coverage(target_index(t)) = coverage(target_index(t)) + added_coverage(target_index(t));

            defender_resources_left = defender_resources_left - sum(added_coverage(1:next-1,1));
        end % for

        next = next+1;
    end % while

    for t = 1:next-1 % COLLECT RATIO FOR EACH TARGET IN THE ATTACK SET TO ALLOCATE REMAINING COVERAGE PROBABILITY
        ratio(target_index(t)) = (1 / (attacker_uncovered_payoff(target_index(t)) - attacker_covered_payoff(target_index(t))) );
    end % for

    for t = 1:next-1 % ALLOCATE REMAINING COVERAGE PROBABLITY GIVEN REMAINING DEFENDER RESOURCES AND TARGET RATIOS
        coverage(target_index(t)) = coverage(target_index(t)) + ( (ratio(target_index(t))*defender_resources_left) / sum(ratio(1:next-1,1)));

        if (coverage(target_index(t)) >= 1)
            if (DEBUG_PRINT == 1)
                display = fprintf('ORIGAMI_MSG03: Target %d.',target_index(t));
                disp(display)
            end % if
            coverage_bound = max(coverage_bound,attacker_covered_payoff(target_index(t)));
        end % if

        if (coverage_bound > coverage_bound_min)
            coverage(target_index(t)) = ( (coverage_bound - attacker_uncovered_payoff(target_index(t))) / (attacker_covered_payoff(target_index(t)) - attacker_uncovered_payoff(target_index(t))) )
        end % if
    end % for

    if (DEBUG_PRINT == 1)
        display = fprintf('Sum(coverage) = %f.',sum(coverage));
        disp(display)
    end % if
    
    if (sum(coverage) > defender_resources)
        display = fprintf('ORIGAMI_ERR01: Total coverage probability is greater than defender_resources!');
        disp(display)
        % error('ORIGAMI_ERR01: Total coverage probability is greater than defender_resources!');
    end % if

    for target = 1:num_targets
        attacker_payoff_vector(target) = (coverage(target)*attacker_covered_payoff(target)) + ((1-coverage(target))*attacker_uncovered_payoff(target));
        defender_payoff_vector(target) = (coverage(target)*defender_covered_payoff(target)) + ((1-coverage(target))*defender_uncovered_payoff(target));
    end % for

    attacker_payoff = sum(attacker_payoff_vector);
    defender_payoff = sum(defender_payoff_vector);

end % function