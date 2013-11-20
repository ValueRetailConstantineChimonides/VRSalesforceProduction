trigger ContractAfterUpdate on Contract (after update) {
	OpportunityProjectionYieldCalculator.calculateProjectionYieldFromContract(Trigger.old, Trigger.new, true);
}