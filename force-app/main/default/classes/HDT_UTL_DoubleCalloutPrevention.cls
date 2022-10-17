@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_UTL_DoubleCalloutPrevention {
    private final Datetime LAST_JOB_DATE = Test.isRunningTest()? Datetime.now().addDays(-1) : Datetime.now().addSeconds(-30); // il tempo entro cui vado a verificare l'esistenza della callout     

    //Mappa finale che conterrà gli oggetti (newRecord => oldRecord) da sottoporre al metodo di integrazione;
    Map<SObject,SObject> newOldRecordMap;
    //Configurazione per ogni phase;
    Map<String,List<HDT_DoubleCalloutPrevention__mdt>> phaseConfigMap;
    //Mappa che conterrà per ogni item le callout degli ultimi 30 secondi per le classi e i metodi di interesse.
    Map<Id, List<wrts_prcgvr__AsyncJob__c>> jobItemCalloutMap;
    
    public HDT_UTL_DoubleCalloutPrevention(List<SObject> newRecordList, Map<Id,SObject> oldRecordMap,String objectName) {
        Set<Id> recordIdSet = new Set<Id>();
        Set<String> phasesToCheck = new Set<String>();
        Set<String> processTypeToCheck = new Set<String>();
        this.newOldRecordMap = new Map<SObject,SObject>();
        this.jobItemCalloutMap = new Map<Id, List<wrts_prcgvr__AsyncJob__c>>();
        for (SObject newRecord : newRecordList){
            Id recordId = (Id) newRecord.get('Id');
            this.newOldRecordMap.put(newRecord, oldRecordMap.get(recordId));
            if (String.isBlank(objectName) || !objectName.equalsIgnoreCase(newRecord.getSObjectType().getDescribe().getName())){
                continue;
            }
            recordIdSet.add(recordId);
            String processTypeField = 'Case'.equalsIgnoreCase(objectName) ? 'Type' :  'Order'.equalsIgnoreCase(objectName)? 'ProcessType__c' : ''; 
            if (String.isNotEmpty(processTypeField) && newRecord.get(processTypeField) != null){
                processTypeToCheck.add((String)newRecord.get(processTypeField));
            }
            if (newRecord.get('Phase__c') != null ){
                phasesToCheck.add((String)newRecord.get('Phase__c'));
            }
        }
        System.debug(LoggingLevel.DEBUG,'@@@@@RecordIdSet ' + JSON.serialize(recordIdSet));
        System.debug(LoggingLevel.DEBUG,'@@@@@newOldRecordMap ' + JSON.serialize(this.newOldRecordMap));
        this.phaseConfigMap = new Map<String,List<HDT_DoubleCalloutPrevention__mdt>>();
        Set<String> apexClasses = new Set<String>();
        Set<String> methods = new Set<String>();
        for(HDT_DoubleCalloutPrevention__mdt config : HDT_QR_DoubleCalloutPrevention.getDoubleCalloutPreventionRecords(phasesToCheck,processTypeToCheck,objectName)){
            if (!this.phaseConfigMap.containsKey(config.PhaseToCheck__c)){
                this.phaseConfigMap.put(config.PhaseToCheck__c,new List<HDT_DoubleCalloutPrevention__mdt>());
            }
            this.phaseConfigMap.get(config.PhaseToCheck__c).add(config);
            apexClasses.add(config.ApexClass__c);
            methods.add(config.MethodToCheck__c);
        }
        if (!apexClasses.isEmpty() && !methods.isEmpty()){
            this.jobItemCalloutMap = HDT_QR_DoubleCalloutPrevention.getExistingCalloutByJobItem(new Map<String,Object>{
                'recordIdList' => recordIdSet,
                'apexClasses' => apexClasses,
                'methods' => methods,
                'objectName' => objectName,
                'date' => LAST_JOB_DATE 
            });
        }
        System.debug(LoggingLevel.DEBUG,'@@@@@phaseConfigMap ' + JSON.serialize(this.phaseConfigMap));
        System.debug(LoggingLevel.DEBUG,'@@@@@jobItemCalloutMap ' + JSON.serialize(this.jobItemCalloutMap));

    }

    public Boolean skipIntegrationCall(){
        for (SObject newRecord : newOldRecordMap.keySet()){
            String phase = (String)newRecord.get('Phase__c');
            Id recordId = (Id)newRecord.get('Id');
            String history = newRecord.get('PhaseStory__c') != null ? (String)newRecord.get('PhaseStory__c') : '';
            if (this.skipRecord(phase, recordId, history)){
                this.newOldRecordMap.remove(newRecord);
            }
        }
        System.debug(LoggingLevel.DEBUG,'@@@@@newOldRecordMap ' + JSON.serialize(this.newOldRecordMap));
        return this.newOldRecordMap.isEmpty();
    }

    public List<SObject> getNewRecords(){
        return new List<SObject>(this.newOldRecordMap.keySet());
    }

    public List<SObject> getOldRecords(){
        return this.newOldRecordMap.values();
    }


    private Boolean skipRecord(String phase, Id recordId, String history){
        if (!this.jobItemCalloutMap.containsKey(recordId) || !this.phaseConfigMap.containsKey(phase)){
            return false;
        }
        /**
         * Le regole 1 e 2 inserite nella descrizione del custom metadata type HDT_DoubleCalloutPrevention sono garantite dalla
         * Where condition del metodo HDT_QR_DoubleCalloutPrevention.getDoubleCalloutPreventionRecords
         * la regola 3 è garantita dal fatto che vado solo a verificare le query per quella fase.
         */
        for (HDT_DoubleCalloutPrevention__mdt config : this.phaseConfigMap.get(phase)){
            for(wrts_prcgvr__AsyncJob__c asyncJob : this.jobItemCalloutMap.get(recordId)){
                //regola 4 descrizione cmdt HDT_DoubleCalloutPrevention
                if (config.ApexClass__c.equalsIgnoreCase(asyncJob.wrts_prcgvr__ApexClassName__c) && config.MethodToCheck__c.equalsIgnoreCase(asyncJob.wrts_prcgvr__MethodName__c)
                //regola 5 descrizione cmdt HDT_DoubleCalloutPrevention
                && (String.isBlank(config.Arguments__c) || config.Arguments__c.equalsIgnoreCase(asyncJob.wrts_prcgvr__Arguments__c))
                //regola 6 descrizione cmdt HDT_DoubleCalloutPrevention
                && (String.isBlank(config.CheckOnPhaseStory__c) || (String.isNotBlank(history) && history.containsIgnoreCase(config.CheckOnPhaseStory__c)))){
                    return true;
                }
            }
        }
        return false;
    }

    public static void checkAndCallout(List<SObject> newRecordList, Map<Id,SObject> oldRecordMap,String objectName){
        HDT_UTL_DoubleCalloutPrevention prevention = new HDT_UTL_DoubleCalloutPrevention(newRecordList,oldRecordMap,objectName);
        if (!prevention.skipIntegrationCall()){
            ((wrts_prcgvr.Interfaces_1_0.ICalloutUtils) wrts_prcgvr.VersionManager.newClassInstance('CalloutUtils')).bulkSend(new Map<String,Object>{'newObjects'=>prevention.getNewRecords(), 'oldObjects' => prevention.getOldRecords()});
        }
    }
}