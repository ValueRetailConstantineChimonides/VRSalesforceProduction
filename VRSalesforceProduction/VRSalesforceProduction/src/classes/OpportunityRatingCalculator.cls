public without sharing class OpportunityRatingCalculator {
	private static final Integer CURRENT_YEAR = system.today().year();

	public static void calculateRating(List<Opportunity> oldOpportunities, List<Opportunity> newOpportunities) {
		List<Opportunity> changedOpportunities = new List<Opportunity>();
		for (Integer i = 0; i < newOpportunities.size(); i++) {
			Opportunity oldOpp = oldOpportunities.get(i);
			Opportunity newOpp = newOpportunities.get(i);
			if (newOpp.Village__c != null && oldOpp.Projected_Income_Yield__c != newOpp.Projected_Income_Yield__c || oldOpp.Projected_Yield__c != newOpp.Projected_Yield__c) {
				changedOpportunities.add(newOpp);
			}
		}
		system.debug('CHANGED OPPS: ' + changedOpportunities);
		if (!changedOpportunities.isEmpty()) {
			calculateRating(changedOpportunities);
		}
	}
	
	public static void calculateRating(List<Opportunity> opportunities) {
		Set<Id> villageSet = new Set<Id>();
		Map<Id, VillageRatingWrapper> ratingMap = new Map<Id, VillageRatingWrapper>();
		for (Opportunity opp : opportunities) {
			villageSet.add(opp.Village__c);
		}
		system.debug('VILLAGES SET: ' + villageSet);
		
		List<Village_Rating__c> ratings = [SELECT Id, Name, Range_Maximum__c, Range_Minimum__c,
										   Rating__c, Village__c, Year__c, Yield_Classification__c,
										   Yield_Type__c
										   FROM Village_Rating__c
										   WHERE Village__c IN :villageSet AND Year__c = :CURRENT_YEAR
										   ORDER BY Village__c, Year__c, Yield_Classification__c, Rating__c];
		
		system.debug('RATINGS FOUND: ' + ratings.size());

		if (!ratings.isEmpty()) {
			// Run through Village ratings and build them into ratingMap
			for (Village_Rating__c r : ratings) {
				VillageRatingWrapper wrapper;
				if (ratingMap.containsKey(r.Village__c)) {
					wrapper = ratingMap.get(r.Village__c);
				} else {
					wrapper = new VillageRatingWrapper(); 
					ratingMap.put(r.Village__c, wrapper);
				}
				if (r.Yield_Classification__c == 'Income') {
					wrapper.incomeRatings.add(r);
				} else if (r.Yield_Classification__c == 'Sales') {
					wrapper.salesRatings.add(r);
				}
			}
		}
		system.debug('RATINGS MAP: ' + ratingMap);
		
		// Run through Opportunities and update from ratingMap
		for (Opportunity opp : opportunities) {
			if (opp.Projected_Income_Yield__c == null || opp.Projected_Income_Yield__c == 0 || !ratingMap.containsKey(opp.Village__c)) {
				opp.Income_Rating__c = 0;
			} else {
				opp.Income_Rating__c = getRatingValue(opp.Projected_Income_Yield__c, ratingMap.get(opp.Village__c).incomeRatings);
			}
			system.debug('OPP ' + opp.Id + ' INCOME RATING SET TO ' + opp.Income_Rating__c);
			if (opp.Projected_Yield__c == null || opp.Projected_Yield__c == 0 || !ratingMap.containsKey(opp.Village__c)) {
				opp.Sales_Rating__c = 0;
			} else {
				opp.Sales_Rating__c = getRatingValue(opp.Projected_Yield__c, ratingMap.get(opp.Village__c).salesRatings);
			}
			system.debug('OPP ' + opp.Id + ' SALES RATING SET TO ' + opp.Sales_Rating__c);
		}
	}
	
	private static Decimal getRatingValue(Decimal projectedValue, List<Village_Rating__c> ratingList) {
		Decimal retVal = 0;
		for (Village_Rating__c r : ratingList) {
			if (r.Range_Maximum__c != null && r.Range_Minimum__c != null && projectedValue >= r.Range_Minimum__c && projectedValue <= r.Range_Maximum__c) {
				retVal = r.Rating__c;
			}
		}
		return retVal;		
	}
	
	private class VillageRatingWrapper {
		List<Village_Rating__c> incomeRatings;
		List<Village_Rating__c> salesRatings;
		
		VillageRatingWrapper() {
			incomeRatings = new List<Village_Rating__c>();
			salesRatings = new List<Village_Rating__c>();
		}
	}
}