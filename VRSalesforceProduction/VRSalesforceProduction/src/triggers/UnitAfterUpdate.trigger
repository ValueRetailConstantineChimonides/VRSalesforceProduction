trigger UnitAfterUpdate on Unit__c (after update) {
	OpportunityProjectionYieldCalculator.calculateProjectionYieldFromUnit(Trigger.old, Trigger.new);
}