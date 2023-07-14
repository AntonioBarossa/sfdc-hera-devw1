@SuppressWarnings('PMD.ExcessiveParameterList,PMD.AvoidDebugStatements')
public with sharing class HDT_SRV_LogService {
    private HDT_UTL_LogUtility logUtility;
    List<SObject> massiveLogRecords;


    public HDT_SRV_LogService(String configName) {
        this.logUtility = new HDT_UTL_LogUtility(configName);
        this.massiveLogRecords = new List<SObject>();
    }

    public void insertSingleLog(String service,
                                String method,
                                String request,
                                String response,
                                String error,
                                String recordId,
                                Datetime requestDate,
                                Datetime responseDate){
        System.Debug(LoggingLevel.DEBUG,'HDT_SRV_LogService - insertSingleLog(): init');
        if (this.logUtility.newRecord()){
            try{
                this.logUtility
                    .setService(service)
                    .setMethod(method)
                    .setRequest(request)
                    .setResponse(response)
                    .setError(error)
                    .setRequestDate(requestDate)
                    .setResponseDate(responseDate)
                    .setRecordId(recordId)
                    .workRecord(true);
                System.Debug(LoggingLevel.DEBUG,'HDT_SRV_LogService - insertSingleLog(): complete');
            }catch(Exception ex){
                System.Debug(LoggingLevel.ERROR,'HDT_SRV_LogService - insertSingleLog(): ' +ex.getMessage());
            }   
        }                              
    }

    public void addLog(String service,
                                String method,
                                String request,
                                String response,
                                String error,
                                String recordId,
                                Datetime requestDate,
                                Datetime responseDate){
        System.Debug(LoggingLevel.DEBUG,'HDT_SRV_LogService - addLog(): init');
        if (this.logUtility.newRecord()){
            try{
                SObject logRecord = this.logUtility
                    .setService(service)
                    .setMethod(method)
                    .setRequest(request)
                    .setResponse(response)
                    .setError(error)
                    .setRequestDate(requestDate)
                    .setResponseDate(responseDate)
                    .setRecordId(recordId)
                    .workRecord(false);
                if (logRecord != null){
                    this.massiveLogRecords.add(logRecord);
                }
                System.Debug(LoggingLevel.DEBUG,'HDT_SRV_LogService - addLog(): complete');
            }catch(Exception ex){
                System.Debug(LoggingLevel.ERROR,'HDT_SRV_LogService - addLog(): ' +ex.getMessage());
            }   
        }                              
    }

    public void saveMassiveRecords(){
        System.Debug(LoggingLevel.DEBUG,'HDT_SRV_LogService - saveMassiveRecords(): init');
        if (this.massiveLogRecords.size()>0){
            try{
                HDT_UTL_DatabaseService.insertSObject(this.massiveLogRecords);
                System.Debug(LoggingLevel.DEBUG,'HDT_SRV_LogService - saveMassiveRecords(): complete');
            }catch(Exception ex){
                System.Debug(LoggingLevel.ERROR,'HDT_SRV_LogService - saveMassiveRecords(): ' +ex.getMessage());
            }  
        }
    }
    

}
