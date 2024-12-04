public with sharing class SObjectWork {
	
	public List<Id> recordIds { get; private set; }
	public SObjectProcessor processor { get; private set; }
	public Map<String, Object> parameters { get; private set; }
	public Boolean stopOnError { get; private set; }
	
	// Note: Made default constructor private to enforce use of Builder
	private SObjectWork() {}
	
	
    // INNER CLASSES
    
    public class Builder {
    	
    	private List<SObjectWork> works;
    	
    	
    	public Builder(List<Id> recordIds, SObjectProcessor processor) {
    		
			works = new List<SObjectWork>();

			if(recordIds == null) {
				throw new IllegalArgumentException('Id list cannot be null.');
			}
			if(recordIds.isEmpty()) {
				throw new IllegalArgumentException('Id list cannot be empty.');
			}
			if(processor == null) {
				throw new IllegalArgumentException('SObject Processor cannot be null.');
			}
			
			Integer chunkSize = processor.getProcessableWorksByChunk();

			for (Integer i = 0; i < recordIds.size(); i+= chunkSize) {
				
				List<Id> idsForChunk = new List<Id>();
				for (Integer j = 0; j < chunkSize; j++) {
					idsForChunk.add(recordIds[i + j]);
				}

				SObjectWork work = new SObjectWork();
				work.processor = processor;
				work.recordIds = idsForChunk;
				work.processor.setRecordIds(idsForChunk);
				work.parameters = new Map<String, Object>();
				work.stopOnError = false;

				works.add(work);
			}
    	}
    	
    	
    	public Builder withParam(String key, Object value) {
    		if(key == null || value == null) {
    			throw new IllegalArgumentException('Parameter keys and values cannot be null.');
    		}

			for (SObjectWork work : works) {
				work.parameters.put(key, value);
			}
			
    		return this;
    	}
    	
    	
    	public Builder withParams(Map<String, Object> paramMap) {
    		if(paramMap == null) {
    			throw new IllegalArgumentException('Parameter map cannot be null.');
    		}

			for (SObjectWork work : works) {
				work.parameters.putAll(paramMap);
			}
			
    		return this;
    	}
    	
    	
    	public Builder shouldStopOnError() {

			for (SObjectWork work : works) {
    			work.stopOnError = true;
			}

    		return this;
    	}
    	
    	
    	public List<SObjectWork> build() {

			for (SObjectWork work : works) {
    			work.processor.setParameters(work.parameters);
			}

    		return works;
    	}
    }
    
    
    public class LastSuccessfulId {
        private Id id;
        
        public void set(Id id) {
        	this.id = id;
        }
        
        public Id get() {
        	return id;
        }
    }
    
    
    public enum State {
    	QUEUED, PROCESSING, FAILED, DONE
    }
}