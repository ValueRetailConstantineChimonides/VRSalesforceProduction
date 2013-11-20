@isTest (seeAllData=true)
private class OpportunityProjectionYieldCalculatorTest {
	static testMethod void opportunityChangeRecalcTest() {
		OpportunityProjectionYieldCalculator.hasRun = true;
		Account testAccount = TestDataGenerator.setupB2BAccount(1, true);
		Village__c testVillage = TestDataGenerator.setupVillage(true);
		Unit__c testUnit1 = createTestUnit(testVillage.Id, 100);
		insert testUnit1;
		Opportunity testOpp1 = createTestOpportunity(testAccount.Id, testVillage.Id, 1, 100, 100, 200, 200);
		Opportunity testOpp2 = createTestOpportunity(testAccount.Id, testVillage.Id, 2, 100, 100, 200, 200);
		Opportunity testOpp3 = createTestOpportunity(testAccount.Id, testVillage.Id, 3, 300, 300, 400, 400);
		Opportunity testOpp4 = createTestOpportunity(testAccount.Id, testVillage.Id, 4, 400, 400, 800, 800);
		Opportunity testOpp5 = createTestOpportunity(testAccount.Id, testVillage.Id, 5, 100, 100, 200, 200);
		Opportunity testOpp6 = createTestOpportunity(testAccount.Id, testVillage.Id, 6, 100, 100, 200, 200);
		List<Opportunity> oppInsertList = new List<Opportunity> {testOpp1, testOpp2, testOpp3, testOpp4, testOpp5, testOpp6};
		insert oppInsertList;
		Contract testContract1 = createTestContract(testAccount.Id, testUnit1.Id, testOpp1.Id);
		Contract testContract2 = createTestContract(testAccount.Id, testUnit1.Id, testOpp3.Id);
		Contract testContract3 = createTestContract(testAccount.Id, testUnit1.Id, testOpp4.Id);
		Contract testContract4 = createTestContract(testAccount.Id, testUnit1.Id, testOpp5.Id);
		Contract testContract5 = createTestContract(testAccount.Id, null, testOpp6.Id);
		testContract5.Notional_Size__c = 200;
		List<Contract> conInsertList = new List<Contract> {testContract1, testContract2, testContract3, testContract4, testContract5};
		insert conInsertList;
		
		OpportunityProjectionYieldCalculator.hasRun = false;
		test.startTest();
		testOpp1.Projected_Income_Yield__c = 200;
		testOpp1.Projected_Yield__c = 100;
		testOpp2.Projected_Income_Yield__c = 200;
		testOpp2.Projected_Yield__c = 100;
		testOpp3.Projected_Income_Yield__c = 350;
		testOpp3.Projected_Income__c = 350;
		testOpp3.Projected_Sales__c = 450;
		testOpp3.Projected_Yield__c = 450;
		testOpp4.Projected_Income__c = 3000;
		testOpp4.Projected_Sales__c = 6000;
		testOpp5.Projected_Income__c = null;
		testOpp5.Projected_Income_Yield__c = null;
		testOpp5.Projected_Sales__c = null;
		testOpp5.Projected_Yield__c = 100;
		testOpp6.Projected_Income_Yield__c = 200;
		testOpp6.Projected_Yield__c = 100;
		update oppInsertList;
		test.stopTest();
		
		List<Opportunity> updatedOppList = [SELECT Id, Projected_Income__c, Projected_Income_Yield__c,
											Projected_Sales__c, Projected_Yield__c
											FROM Opportunity
											WHERE Id IN :oppInsertList];
		
		system.debug('OpportunityProjectionYieldCalculatorTest - UPDATED OPP LIST: ' + updatedOppList);
		system.assertEquals(oppInsertList.size(), updatedOppList.size());
		for (Opportunity opp : updatedOppList) {
			if (opp.Id == testOpp1.Id) {
				system.assertEquals(200, opp.Projected_Income_Yield__c);
				system.assertEquals(20000, opp.Projected_Income__c);
				system.assertEquals(100, opp.Projected_Yield__c);
				system.assertEquals(10000, opp.Projected_Sales__c);
			} else if (opp.Id == testOpp2.Id) {
				system.assertEquals(200, opp.Projected_Income_Yield__c);
				system.assertEquals(100, opp.Projected_Income__c);
				system.assertEquals(100, opp.Projected_Yield__c);
				system.assertEquals(200, opp.Projected_Sales__c);
			} else if (opp.Id == testOpp3.Id) {
				system.assertEquals(350, opp.Projected_Income_Yield__c);
				system.assertEquals(350, opp.Projected_Income__c);
				system.assertEquals(450, opp.Projected_Yield__c);
				system.assertEquals(450, opp.Projected_Sales__c);
			} else if (opp.Id == testOpp4.Id) {
				system.assertEquals(30, opp.Projected_Income_Yield__c);
				system.assertEquals(3000, opp.Projected_Income__c);
				system.assertEquals(60, opp.Projected_Yield__c);
				system.assertEquals(6000, opp.Projected_Sales__c);
			} else if (opp.Id == testOpp5.Id) {
				system.assertEquals(null, opp.Projected_Income_Yield__c);
				system.assertEquals(null, opp.Projected_Income__c);
				system.assertEquals(100, opp.Projected_Yield__c);
				system.assertEquals(10000, opp.Projected_Sales__c);
			} else if (opp.Id == testOpp6.Id) {
				system.assertEquals(200, opp.Projected_Income_Yield__c);
				system.assertEquals(40000, opp.Projected_Income__c);
				system.assertEquals(100, opp.Projected_Yield__c);
				system.assertEquals(20000, opp.Projected_Sales__c);
			} else {
				system.assert(false);
			}
		}
	}
	
	static testMethod void contractUnitChangeRecalcTest() {
		OpportunityProjectionYieldCalculator.hasRun = true;
		Account testAccount = TestDataGenerator.setupB2BAccount(1, true);
		Village__c testVillage = TestDataGenerator.setupVillage(true);
		Unit__c testUnit1 = createTestUnit(testVillage.Id, 100);
		Unit__c testUnit2 = createTestUnit(testVillage.Id, 200);
		List<Unit__c> unitInsertList = new List<Unit__c> {testUnit1, testUnit2};
		insert unitInsertList;
		Opportunity testOpp1 = createTestOpportunity(testAccount.Id, testVillage.Id, 1, 100, 100, 200, 200);
		Opportunity testOpp2 = createTestOpportunity(testAccount.Id, testVillage.Id, 1, 100, 100, 200, 200);
		List<Opportunity> oppInsertList = new List<Opportunity> {testOpp1, testOpp2};
		insert oppInsertList;
		Contract testContract1 = createTestContract(testAccount.Id, testUnit1.Id, testOpp1.Id);
		Contract testContract2 = createTestContract(testAccount.Id, null, testOpp2.Id);
		testContract2.Notional_Size__c = 100;
		List<Contract> conInsertList = new List<Contract> {testContract1, testContract2};
		insert conInsertList;

		OpportunityProjectionYieldCalculator.hasRun = false;
		test.startTest();
		testContract1.Unit__c = testUnit2.Id;
		testContract2.Notional_Size__c = 200;
		update conInsertList;
		test.stopTest();
		
		List<Opportunity> updatedOppList = [SELECT Id, Projected_Income__c, Projected_Income_Yield__c,
											Projected_Sales__c, Projected_Yield__c
											FROM Opportunity
											WHERE Id IN :oppInsertList];
		
		system.debug('contractUnitChangeRecalcTest - UPDATED OPP LIST: ' + updatedOppList);
		system.assertEquals(oppInsertList.size(), updatedOppList.size());
		for (Opportunity opp : updatedOppList) {
			if (opp.Id == testOpp1.Id) {
				system.assertEquals(100, opp.Projected_Income_Yield__c);
				system.assertEquals(20000, opp.Projected_Income__c);
				system.assertEquals(200, opp.Projected_Yield__c);
				system.assertEquals(40000, opp.Projected_Sales__c);
			} else if (opp.Id == testOpp2.Id) {
				system.assertEquals(100, opp.Projected_Income_Yield__c);
				system.assertEquals(20000, opp.Projected_Income__c);
				system.assertEquals(200, opp.Projected_Yield__c);
				system.assertEquals(40000, opp.Projected_Sales__c);
			} else {
				system.assert(false);
			}
		}
	}
	
	static testMethod void unitSizeChangeRecalcTest() {
		OpportunityProjectionYieldCalculator.hasRun = true;
		Account testAccount = TestDataGenerator.setupB2BAccount(1, true);
		Village__c testVillage = TestDataGenerator.setupVillage(true);
		Unit__c testUnit1 = createTestUnit(testVillage.Id, 100);
		insert testUnit1;
		Opportunity testOpp1 = createTestOpportunity(testAccount.Id, testVillage.Id, 1, 100, 100, 200, 200);
		insert testOpp1;
		Contract testContract1 = createTestContract(testAccount.Id, testUnit1.Id, testOpp1.Id);
		insert testContract1;

		OpportunityProjectionYieldCalculator.hasRun = false;
		test.startTest();
		testUnit1.Size_GEA__c = 300;
		update testUnit1;
		test.stopTest();
		
		List<Opportunity> updatedOppList = [SELECT Id, Projected_Income__c, Projected_Income_Yield__c,
											Projected_Sales__c, Projected_Yield__c
											FROM Opportunity
											WHERE Id = :testOpp1.Id];
		
		system.debug('unitSizeChangeRecalcTest - UPDATED OPP LIST: ' + updatedOppList);
		system.assertEquals(1, updatedOppList.size());
		Opportunity opp = updatedOppList.get(0);
		system.assertEquals(testOpp1.Id, opp.Id);
		system.assertEquals(100, opp.Projected_Income_Yield__c);
		system.assertEquals(30000, opp.Projected_Income__c);
		system.assertEquals(200, opp.Projected_Yield__c);
		system.assertEquals(60000, opp.Projected_Sales__c);
	}

	/*
	static testMethod void opportunityChangeBulkTest() {
		OpportunityProjectionYieldCalculator.hasRun = true;
		Account testAccount = TestDataGenerator.setupB2BAccount(1, true);
		Village__c testVillage = TestDataGenerator.setupVillage(true);
		Unit__c testUnit1 = createTestUnit(testVillage.Id, 100);
		insert testUnit1;
		List<Opportunity> oppInsertList = new List<Opportunity>();
		for (Integer i = 1; i <= 200; i++) {
			Opportunity testOpp = createTestOpportunity(testAccount.Id, testVillage.Id, i, 100, 100, 200, 200);
			oppInsertList.add(testOpp);
		}
		insert oppInsertList;

		List<Contract> conInsertList = new List<Contract>();
		for (Integer i = 1; i <= 200; i++) {
			Integer pos = i - 1;
			Contract testContract = createTestContract(testAccount.Id, testUnit1.Id, oppInsertList.get(pos).Id);
			conInsertList.add(testContract);
		}
		insert conInsertList;
		
		for (Integer i = 0; i < 200; i++) {
			Opportunity testOpp = oppInsertList.get(i);
			testOpp.Projected_Income_Yield__c = 400;
			testOpp.Projected_Yield__c = 300;
		}
		OpportunityProjectionYieldCalculator.hasRun = false;
		test.startTest();
		update oppInsertList;
		test.stopTest();
		
		List<Opportunity> updatedOppList = [SELECT Id, Projected_Income__c, Projected_Income_Yield__c,
											Projected_Sales__c, Projected_Yield__c
											FROM Opportunity
											WHERE Id IN :oppInsertList];
		
		system.debug('opportunityChangeBulkTest - UPDATED OPP LIST: ' + updatedOppList);
		system.assertEquals(oppInsertList.size(), updatedOppList.size());
		for (Opportunity opp : updatedOppList) {
			system.assertEquals(400, opp.Projected_Income_Yield__c);
			system.assertEquals(40000, opp.Projected_Income__c);
			system.assertEquals(300, opp.Projected_Yield__c);
			system.assertEquals(30000, opp.Projected_Sales__c);
		}
	}
	*/

	private static Unit__c createTestUnit(Id villageId, Integer size) {
		Unit__c testUnit = new Unit__c(Village__c = villageId, Unit_Status__c = 'Available', Size_GEA__c = size);
		return testUnit;
	}
	
	private static Contract createTestContract(Id accountId, Id unitId, Id opportunityId) {
		Contract testCon = new Contract(AccountId = accountId, Unit__c = unitId, Opportunity__c = opportunityId);
		return testCon;
	}
	
	private static Opportunity createTestOpportunity(Id accountId, Id villageId, Integer identifier, Integer incomeValue,
													 Integer incomeYield, Integer salesValue, Integer salesYield) {
		Opportunity testOpp = new Opportunity(AccountId = accountId, Village__c = villageId, Name = 'TESTOPP' + identifier,
											  CloseDate = system.today(), StageName = 'Agreed in Principle', Projected_Income__c = incomeValue,
											  Projected_Income_Yield__c = incomeYield, Projected_Sales__c = salesValue,
											  Projected_Yield__c = salesYield);
		return testOpp;
	}
}