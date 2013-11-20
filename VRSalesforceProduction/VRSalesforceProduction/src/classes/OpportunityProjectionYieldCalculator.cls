public without sharing class OpportunityProjectionYieldCalculator {
	public static Boolean hasRun = false;
	
	public static void calculateProjectionYield(List<Opportunity> oldOpportunities, List<Opportunity> newOpportunities) {
		system.debug('HAS RUN: ' + hasRun);
		if (!hasRun) {
			hasRun = true;
			Set<Id> incomeOpportunities = new Set<Id>();
			Set<Id> incomeYieldOpportunities = new Set<Id>();
			Set<Id> salesOpportunities = new Set<Id>();
			Set<Id> salesYieldOpportunities = new Set<Id>();
			Map<Id, Opportunity> allChangedOpportunities = new Map<Id, Opportunity>();
			for (Integer i = 0; i < newOpportunities.size(); i++) {
				Opportunity oldOpp = oldOpportunities.get(i);
				Opportunity newOpp = newOpportunities.get(i);
				if (newOpp.Projected_Income__c != null && oldOpp.Projected_Income__c != newOpp.Projected_Income__c && 
						(newOpp.Projected_Income_Yield__c == null || oldOpp.Projected_Income_Yield__c == newOpp.Projected_Income_Yield__c)) {
					system.debug('INCOME CHANGED ON ' + newOpp.Id);
					incomeOpportunities.add(newOpp.Id);
					allChangedOpportunities.put(newOpp.Id, newOpp);
				} else if (newOpp.Projected_Income_Yield__c != null && oldOpp.Projected_Income_Yield__c != newOpp.Projected_Income_Yield__c && 
						(newOpp.Projected_Income__c == null || oldOpp.Projected_Income__c == newOpp.Projected_Income__c)) {
					system.debug('INCOME YIELD CHANGED ON ' + newOpp.Id);
					incomeYieldOpportunities.add(newOpp.Id);
					allChangedOpportunities.put(newOpp.Id, newOpp);
				}
				if (newOpp.Projected_Sales__c != null && oldOpp.Projected_Sales__c != newOpp.Projected_Sales__c && 
						(newOpp.Projected_Yield__c == null || oldOpp.Projected_Yield__c == newOpp.Projected_Yield__c)) {
					system.debug('SALES CHANGED ON ' + newOpp.Id);
					salesOpportunities.add(newOpp.Id);
					allChangedOpportunities.put(newOpp.Id, newOpp);
				} else if (newOpp.Projected_Yield__c != null && oldOpp.Projected_Yield__c != newOpp.Projected_Yield__c && 
						(newOpp.Projected_Sales__c == null || oldOpp.Projected_Sales__c == newOpp.Projected_Sales__c)) {
					system.debug('SALES YIELD CHANGED ON ' + newOpp.Id);
					salesYieldOpportunities.add(newOpp.Id);
					allChangedOpportunities.put(newOpp.Id, newOpp);
				}
			}
			if (!allChangedOpportunities.isEmpty()) {
				Map<Id, Integer> conCounter = new Map<Id, Integer>();
				List<Contract> conList = [SELECT Id, Unit_Size__c, Opportunity__c
										  FROM Contract
										  WHERE Opportunity__c IN :allChangedOpportunities.keySet() AND Unit_Size__c > 0];
				// First loop through and build dupe check counter contracts
				for(Contract con : conList) {
					Integer i;
					if (conCounter.containsKey(con.Opportunity__c)) {
						i = conCounter.get(con.Opportunity__c);
						i++;
					} else {
						i = 1;
					}
					conCounter.put(con.Opportunity__c, i);
				}
				// Loop through contracts and update opportunity fields
				for(Contract con : conList) {
					if (conCounter.get(con.Opportunity__c) == 1) {
						Opportunity op = allChangedOpportunities.get(con.Opportunity__c);
						if (incomeOpportunities.contains(con.Opportunity__c)) {
							op.Projected_Income_Yield__c = op.Projected_Income__c / con.Unit_Size__c;
							system.debug('INCOME YIELD ON ' + op.Id + ' CHANGED TO ' + op.Projected_Income_Yield__c);
						} else if (incomeYieldOpportunities.contains(con.Opportunity__c)) {
							op.Projected_Income__c = op.Projected_Income_Yield__c * con.Unit_Size__c;
							system.debug('INCOME ON ' + op.Id + ' CHANGED TO ' + op.Projected_Income__c);
						}
						if (salesOpportunities.contains(con.Opportunity__c)) {
							op.Projected_Yield__c = op.Projected_Sales__c / con.Unit_Size__c;
							system.debug('SALES YIELD ON ' + op.Id + ' CHANGED TO ' + op.Projected_Yield__c);
						} else if (salesYieldOpportunities.contains(con.Opportunity__c)) {
							op.Projected_Sales__c = op.Projected_Yield__c * con.Unit_Size__c;
							system.debug('SALES ON ' + op.Id + ' CHANGED TO ' + op.Projected_Sales__c);
						}
					}
				}
			}
		}
	}
	
	public static void calculateProjectionYieldFromContract(List<Contract> oldContracts, List<Contract> newContracts, Boolean isUpdate) {
		system.debug('HAS RUN: ' + hasRun);
		if (!hasRun) {
			hasRun = true;
			List<Id> allChangedContracts = new List<Id>();
			for (Integer i = 0; i < newContracts.size(); i++) {
				Contract newCon = newContracts.get(i);
				if (newCon.Opportunity__c != null && (newCon.Unit__c != null || newCon.Notional_Size__c != null)) {
					if (isUpdate) {
						Contract oldCon = oldContracts.get(i);
						if (newCon.Unit__c != oldCon.Unit__c || newCon.Notional_Size__c != oldCon.Notional_Size__c) {
							allChangedContracts.add(newCon.Id);
						} 
					} else {
						allChangedContracts.add(newCon.Id);
					}
				}
			}
			if (!allChangedContracts.isEmpty()) {
				List<Contract> updConList = [SELECT Id, Opportunity__c, Opportunity__r.Projected_Income_Yield__c,
											 Opportunity__r.Projected_Income__c, Opportunity__r.Projected_Yield__c,
											 Opportunity__r.Projected_Sales__c, Unit_Size__c
											 FROM Contract
											 WHERE Id IN :allChangedContracts AND Unit_Size__c > 0];
				updateOpportunitiesFromContracts(updConList);
			}
		}
	}
	
	public static void calculateProjectionYieldFromUnit(List<Unit__c> oldUnits, List<Unit__c> newUnits) {
		system.debug('HAS RUN: ' + hasRun);
		if (!hasRun) {
			hasRun = true;
			List<Id> allChangedUnits = new List<Id>();
			for (Integer i = 0; i < newUnits.size(); i++) {
				Unit__c oldUnit = oldUnits.get(i);
				Unit__c newUnit = newUnits.get(i);
				if (newUnit.Size_GEA__c != null && newUnit.Size_GEA__c != oldUnit.Size_GEA__c) {
					allChangedUnits.add(newUnit.Id);
				}
			}
			if (!allChangedUnits.isEmpty()) {
				List<Contract> updConList = [SELECT Id, Opportunity__c, Opportunity__r.Projected_Income_Yield__c,
											 Opportunity__r.Projected_Income__c, Opportunity__r.Projected_Yield__c,
											 Opportunity__r.Projected_Sales__c, Unit_Size__c
											 FROM Contract
											 WHERE Unit__c IN :allChangedUnits AND Unit_Size__c > 0];
				updateOpportunitiesFromContracts(updConList);
			}
		}
	}
	
	private static void updateOpportunitiesFromContracts(List<Contract> conList) {
		if (!(conList == null || conList.isEmpty())) {
			List<Opportunity> opList = new List<Opportunity>();
			for (Contract con : conList) {
				Opportunity op = new Opportunity(Id = con.Opportunity__c);
				Boolean opChanged = false;
				system.debug('INCOME YIELD: ' + con.Opportunity__r.Projected_Income_Yield__c);
				system.debug('INCOME: ' + con.Opportunity__r.Projected_Income__c);
				system.debug('SALES YIELD: ' + con.Opportunity__r.Projected_Yield__c);
				system.debug('SALES: ' + con.Opportunity__r.Projected_Sales__c);
				system.debug('UNIT SIZE: ' + con.Unit_Size__c);
				if (con.Unit_Size__c != null && con.Unit_Size__c > 0) {
					if (con.Opportunity__r.Projected_Income_Yield__c != null && con.Opportunity__r.Projected_Income_Yield__c > 0) {
						op.Projected_Income__c = con.Opportunity__r.Projected_Income_Yield__c * con.Unit_Size__c;
						opChanged = true;
					} else if (con.Opportunity__r.Projected_Income__c != null && con.Opportunity__r.Projected_Income__c > 0) {
						op.Projected_Income_Yield__c = op.Projected_Income__c / con.Unit_Size__c;
						opChanged = true;
					}
					if (con.Opportunity__r.Projected_Yield__c != null && con.Opportunity__r.Projected_Yield__c > 0) {
						op.Projected_Sales__c = con.Opportunity__r.Projected_Yield__c * con.Unit_Size__c;
						opChanged = true;
					} else if (con.Opportunity__r.Projected_Sales__c != null && con.Opportunity__r.Projected_Sales__c > 0) {
						op.Projected_Yield__c = op.Projected_Sales__c / con.Unit_Size__c;
						opChanged = true;
					}
				}
				if (opChanged) {
					opList.add(op);
				}
			}
			if (!opList.isEmpty()) {
				update opList;
			}
		}
	}
}