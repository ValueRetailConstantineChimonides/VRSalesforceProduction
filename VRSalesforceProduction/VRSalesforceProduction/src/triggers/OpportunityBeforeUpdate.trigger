trigger OpportunityBeforeUpdate on Opportunity (before update) {
	OpportunityProjectionYieldCalculator.calculateProjectionYield(Trigger.old, Trigger.new);
	OpportunityRatingCalculator.calculateRating(Trigger.old, Trigger.new);
}