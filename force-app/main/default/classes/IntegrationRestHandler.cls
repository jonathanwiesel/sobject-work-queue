public with sharing abstract class IntegrationRestHandler implements SObjectProcessor {
    
    private List<Id> recordIds;
    private Map<String, Object> params;

    public String getFullClassName() {
        return String.valueOf(this).split(':')[0];
    }

    public void setRecordIds(List<Id> recordIds) {
        this.recordIds = recordIds;
    }

    public void setParameters(Map<String, Object> parameterMap) {
        this.params = parameterMap;
    }

    public virtual Boolean canRunSynchronously() {
        return false;
    }

    public virtual Map<String, String> getHeaders() {
        return new Map<String, String>{'Content-Type' => 'application/json'};
    }

    public Integer getProcessableWorksByChunk() {
        //TODO
    }

    public void process(SObjectWork.LastSuccessfulId lastSuccesfulId) {
        //TODO
    }
}