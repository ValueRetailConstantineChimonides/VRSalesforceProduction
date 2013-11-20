@isTest (seeAllData=true)
private class OpportunityRatingCalculatorTest {

    static testMethod void testRatingUpdate() {
        Account testAccount = TestDataGenerator.setupB2BAccount(1, true);
        Village__c ratedVillage = TestDataGenerator.setupVillage(true);
        Village__c unratedVillage = TestDataGenerator.setupVillage(false);
        unratedVillage.Village_Code__c = 'ZY';
        unratedVillage.Name = 'UNRATEDVILLAGE';
        insert unratedVillage;
        List<Village_Rating__c> ratingList = new List<Village_Rating__c>();
        for (Integer i = 1; i <= 5; i++) {
        	Village_Rating__c rating = setupVillageRating(i, 'Income', ratedVillage.Id);
        	ratingList.add(rating);
        }
        for (Integer i = 1; i <= 10; i++) {
        	Village_Rating__c rating = setupVillageRating(i, 'Sales', ratedVillage.Id);
        	ratingList.add(rating);
        }
        insert ratingList;
        
        Opportunity ratedOpp = new Opportunity(Village__c = ratedVillage.Id, AccountId = testAccount.Id,
        									   Name = 'TESTOPP1', CloseDate = system.today(),
        									   StageName = 'Agreed in Principle');

        Opportunity unratedOpp = new Opportunity(Village__c = unratedVillage.Id, AccountId = testAccount.Id,
        									     Name = 'TESTOPP2', CloseDate = system.today(),
        									     StageName = 'Agreed in Principle');

        List<Opportunity> oppInsertList = new List<Opportunity> {ratedOpp, unratedOpp};
        test.startTest();
        insert oppInsertList;
        test.stopTest();
        
        List<Opportunity> updatedOppList1 = [SELECT Id, Name, Income_Rating__c, Sales_Rating__c
        						   	   		 FROM Opportunity
        						   	   		 WHERE Id IN :oppInsertList ORDER BY Name LIMIT 2];
        
        system.assertEquals(ratedOpp.Name, updatedOppList1.get(0).Name);
        system.assertEquals(0, updatedOppList1.get(0).Income_Rating__c);
        system.assertEquals(0, updatedOppList1.get(0).Sales_Rating__c);
        system.assertEquals(unratedOpp.Name, updatedOppList1.get(1).Name);
        system.assertEquals(0, updatedOppList1.get(1).Income_Rating__c);
        system.assertEquals(0, updatedOppList1.get(1).Sales_Rating__c);
        
        ratedOpp.Projected_Income_Yield__c = 1200;
        ratedOpp.Projected_Yield__c = 3500;
        unratedOpp.Projected_Income_Yield__c = 2200;
        unratedOpp.Projected_Yield__c = 4000;
        
        update oppInsertList;
        
        List<Opportunity> updatedOppList2 = [SELECT Id, Name, Income_Rating__c, Sales_Rating__c
        						   	   		 FROM Opportunity
        						   	   		 WHERE Id IN :oppInsertList ORDER BY Name LIMIT 2];
        
        system.assertEquals(ratedOpp.Name, updatedOppList2.get(0).Name);
        system.assertEquals(2, updatedOppList2.get(0).Income_Rating__c);
        system.assertEquals(4, updatedOppList2.get(0).Sales_Rating__c);
        system.assertEquals(unratedOpp.Name, updatedOppList2.get(1).Name);
        system.assertEquals(0, updatedOppList2.get(1).Income_Rating__c);
        system.assertEquals(0, updatedOppList2.get(1).Sales_Rating__c);

        ratedOpp.Projected_Income_Yield__c = 120000;
        ratedOpp.Projected_Yield__c = 0;
        unratedOpp.Projected_Income_Yield__c = 0;
        unratedOpp.Projected_Yield__c = 0;
        
        update oppInsertList;

        List<Opportunity> updatedOppList3 = [SELECT Id, Name, Income_Rating__c, Sales_Rating__c
        						   	   		 FROM Opportunity
        						   	   		 WHERE Id IN :oppInsertList ORDER BY Name LIMIT 2];
        
        system.assertEquals(ratedOpp.Name, updatedOppList3.get(0).Name);
        system.assertEquals(0, updatedOppList3.get(0).Income_Rating__c);
        system.assertEquals(0, updatedOppList3.get(0).Sales_Rating__c);
        system.assertEquals(unratedOpp.Name, updatedOppList3.get(1).Name);
        system.assertEquals(0, updatedOppList3.get(1).Income_Rating__c);
        system.assertEquals(0, updatedOppList3.get(1).Sales_Rating__c);
    }
    
    private static Village_Rating__c setupVillageRating(Integer identifier, String ratingType, Id villageId) {
    	Integer rangeMin = (identifier - 1) * 1000;
    	Integer rangeMax = identifier * 1000;
    	Integer year = system.today().year();
    	Village_Rating__c rating = new Village_Rating__c(Village__c = villageId,
    													 Range_Minimum__c = rangeMin,
    													 Range_Maximum__c = rangeMax,
    													 Rating__c = identifier,
    													 Year__c = year,
    													 Yield_Classification__c = ratingType,
    													 Yield_Type__c = 'Budget');
    	return rating;
    }
}