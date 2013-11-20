trigger ContractAfterInsert on Contract (after insert) {
	OpportunityProjectionYieldCalculator.calculateProjectionYieldFromContract(null, Trigger.new, false);
}