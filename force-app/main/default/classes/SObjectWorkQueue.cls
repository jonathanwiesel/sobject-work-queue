// Note: Made abstract to enforce static nature
public abstract class SObjectWorkQueue {
	
	private static final Integer SINGLE_WORK_PER_BATCH = 1;
	private static final Integer BATCH_DELAY = 1;
	
	
	// PUBLIC METHODS
	
	public static void addWorks(List<SObjectWork> works, Boolean delay) {
		
		abortIfContainsCorruptedRecords(works);
		
		if(canRunSynchronously(works)) {
			runSynchronously(works);
		}
		else {
			runAsynchronously(works, delay);
		}
	}
	
	
	
	public static Set<Id> extractIdsWithPendingWork(List<SObjectWork> works) {
		List<String> pending = new List<String>{ SObjectWork.State.QUEUED.name(), SObjectWork.State.PROCESSING.name() };
		return findIdsWithUnfinishedWork(works, pending);
	}
		
	
	public static Set<Id> extractIdsWithFailedWork(List<SObjectWork> works) {
		List<String> failed = new List<String>{ SObjectWork.State.FAILED.name() };
		return findIdsWithUnfinishedWork(works, failed);
	}
	
	
	// PRIVATE STATIC 
	
	private static void abortIfContainsCorruptedRecords(List<SObjectWork> works) {
		Set<Id> idsWithFailedWork = extractIdsWithFailedWork(works);
		
		if(idsWithFailedWork.size() > 0) {
			throw new DataInconsitencyException('This operation is currently not possible due to a data inconsitency. Please contact your administrator.');
		}
	}
	
	
	private static Set<Id> findIdsWithUnfinishedWork(List<SObjectWork> works, List<String> states) {
        Set<Id> idsWithPendingWork = new Set<Id>();
        Set<Id> potentiallyConflictingIds = new Set<Id>();

		for (SObjectWork work : works) {
			potentiallyConflictingIds.addAll(work.recordIds);
		}
        
        // Compile Set of ids of all existing work records
        for(SObjectWork__c workRecord : [SELECT SObjectIds__c
                                         FROM SObjectWork__c
                                         WHERE CurrentState__c IN :states]) {
            // Note: Written as an ugly one-liner to save code statements                             	
        	idsWithPendingWork.addAll( new Set<Id>( (List<Id>) workRecord.SObjectIds__c.split(',') ) );                               
        }
        
        // If this set contains any of the requested ids return true
        potentiallyConflictingIds.retainAll(idsWithPendingWork);
        
        return potentiallyConflictingIds;
    }
    
    
	private static Boolean canRunSynchronously(List<SObjectWork> works) {
		Boolean processorResponses = true;
		
		for (SObjectWork work : works) {
			processorResponses &= work.processor.canRunSynchronously();
			if (!processorResponses) break;
		}

		return extractIdsWithPendingWork(works).isEmpty() && processorResponses;
	}
    
	
	private static void runSynchronously(List<SObjectWork> works) {

		for (SObjectWork work : works) {

			SObjectWork.LastSuccessfulId lastSuccessfulId = new SObjectWork.LastSuccessfulId();
			work.processor.process(lastSuccessfulId);
		}
	}
	
	
	private static void runAsynchronously(List<SObjectWork> works, Boolean delay) {
		persistWork(works);
			
		if(noQueueWorkerRunning()) {
			startQueueWorker(delay);
		}
	}
	
	
	private static void persistWork(List<SObjectWork> works) {
		List<SObjectWork__c> workRecords = SObjectWorkSerializer.toOneOrMoreSObjectRecords(works);
		insert workRecords;
	}
	
	
	private static Boolean noQueueWorkerRunning() {
		Integer runningWorker = [SELECT COUNT() 
				                 FROM AsyncApexJob
								 WHERE JobType = 'BatchApex'
								 AND ApexClass.Name = 'SObjectWorkQueue_Batch'
								 AND Status IN ('Processing', 'Preparing', 'Queued' )];
								 
		return (runningWorker == 0);
	}
	
	
	private static void startQueueWorker(Boolean delay) {
		SObjectWorkQueue_Batch worker = new SObjectWorkQueue_Batch();

		if (delay) {
			System.scheduleBatch(worker, 'SObjectWorkQueue_Batch', BATCH_DELAY);
		} else {
			Database.executeBatch(worker, SINGLE_WORK_PER_BATCH);
		}
	}
	
	
	// INNER CLASSES
	
	public class DataInconsitencyException extends Exception {}
}