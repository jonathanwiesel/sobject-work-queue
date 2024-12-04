@isTest
private class SObjectWorkDeserializer_Test {
			
	@isTest
	private static void instantiatesProcessorForValidClassName() {
		// Setup
		Boolean noExceptionWasThrown = true;
		
		SObjectWork__c serializedWork = new SObjectWork__c();
		serializedWork.SObjectIds__c = 'a0Cd000000COKdj,a0Cd000000COKdk,a0Cd000000COKdp';
		serializedWork.ProcessorClassName__c = 'SObjectWorkTestHelper.ExampleSObjectProcessor';
		
		
		// Execute
		SObjectWork work = SObjectWorkDeserializer.toObject(serializedWork);
		
		
		// Verify
		System.assertNotEquals(null, work.processor);
		System.assertEquals(serializedWork.ProcessorClassName__c, work.processor.getFullClassName());
	}
	
	
	@isTest
	private static void throwsExceptionOnEmptyClassName() {
		
		// Setup
		Boolean expectedExceptionWasThrown = false;
		
		SObjectWork__c serializedWork = new SObjectWork__c();
		serializedWork.SObjectIds__c = 'a0Cd000000COKdj,a0Cd000000COKdk,a0Cd000000COKdp';
		
		
		// Execute
		try {
			SObjectWork work = SObjectWorkDeserializer.toObject(serializedWork);
		} 
		catch(SObjectWorkDeserializer.DeserializationException dse) {
			expectedExceptionWasThrown = true;
		}
		
		
		// Verify
		System.assert(expectedExceptionWasThrown);
	}
	
	
	@isTest
	private static void throwsExceptionOnNonExistingClassName() {
		
		// Setup
		Boolean expectedExceptionWasThrown = false;
		
		SObjectWork__c serializedWork = new SObjectWork__c();
		serializedWork.SObjectIds__c = 'a0Cd000000COKdj,a0Cd000000COKdk,a0Cd000000COKdp';
		serializedWork.ProcessorClassName__c = 'NonExistingClass';
		
		
		// Execute
		try {
			SObjectWork work = SObjectWorkDeserializer.toObject(serializedWork);
		} 
		catch(SObjectWorkDeserializer.DeserializationException dse) {
			expectedExceptionWasThrown = true;
		}
		
		
		// Verify
		System.assert(expectedExceptionWasThrown);
	}
    
    
	@isTest
	private static void throwsExceptionOnNonProcessorClass() {
		// Setup
		Boolean expectedExceptionWasThrown = false;
		
		SObjectWork__c serializedWork = new SObjectWork__c();
		serializedWork.SObjectIds__c = 'a0Cd000000COKdj,a0Cd000000COKdk,a0Cd000000COKdp';
		serializedWork.ProcessorClassName__c = 'SObjectWorkDeserializer_Test';
		
		
		// Execute
		try {
			SObjectWork work = SObjectWorkDeserializer.toObject(serializedWork);
		} 
		catch(SObjectWorkDeserializer.DeserializationException dse) {
			expectedExceptionWasThrown = true;
		}
		
		
		// Verify
		System.assert(expectedExceptionWasThrown);
	}
    
    
	@isTest
	private static void throwsExceptionOnEmptyIdList() {
		// Setup
		Boolean expectedExceptionWasThrown = false;
		
		SObjectWork__c workWithNoIds = new SObjectWork__c();
		workWithNoIds.ProcessorClassName__c = 'SObjectWorkTestHelper.ExampleSObjectProcessor';
		workWithNoIds.SObjectIds__c = '';
		
		// Execute
		try {
			SObjectWork work = SObjectWorkDeserializer.toObject(workWithNoIds);
		} 
		catch(SObjectWorkDeserializer.DeserializationException dse) {
			expectedExceptionWasThrown = true;
		}
		
		
		// Verify
		System.assert(expectedExceptionWasThrown);
	}
    
    
	@isTest
	private static void throwsExceptionOnUnparsableIdList() {
		
		// Setup
		Boolean expectedExceptionWasThrown = false;
		
		SObjectWork__c workWithUnparsableIds = new SObjectWork__c();
		workWithUnparsableIds.SObjectIds__c = 'asfd,sdf,sd,fds,sdfds';
		workWithUnparsableIds.ProcessorClassName__c = 'SObjectWorkTestHelper.ExampleSObjectProcessor';
		
		
		// Execute
		try {
			SObjectWork work = SObjectWorkDeserializer.toObject(workWithUnparsableIds);
		} 
		catch(SObjectWorkDeserializer.DeserializationException dse) {
			expectedExceptionWasThrown = true;
		}
		
		
		// Verify
		System.assert(expectedExceptionWasThrown);
	}    
    
    
	@isTest
	private static void throwsExceptionIfAnyIdInListIsNotValid() {
		// Setup
		Boolean expectedExceptionWasThrown = false;
		
		SObjectWork__c workWithInvalidIds = new SObjectWork__c();
		workWithInvalidIds.SObjectIds__c = 'a0Cd000000COKdj,a0Cd000000COKdk,THIS_IS_NO_ID,a0Cd000000COKdk';
		workWithInvalidIds.ProcessorClassName__c = 'SObjectWorkTestHelper.ExampleSObjectProcessor';
		
		
		// Execute
		try {
			SObjectWork work = SObjectWorkDeserializer.toObject(workWithInvalidIds);
		} 
		catch(SObjectWorkDeserializer.DeserializationException dse) {
			expectedExceptionWasThrown = true;
		}
		
		
		// Verify
		System.assert(expectedExceptionWasThrown);
	}
}