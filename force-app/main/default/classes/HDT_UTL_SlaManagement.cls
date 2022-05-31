@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ClassNamingConventions, PMD.ExcessiveParameterList, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces, PMD.LocalVariableNamingConventions')
public inherited sharing class HDT_UTL_SlaManagement {
    
    private Set<Id> recordIdList;
    private List<HDT_WRP_SlaManagement.HDT_WRP_sObject> wrpCaseList;
    private List<SlaTracking__c> trackingRecordsList;
    private Map<Id, HDT_WRP_SlaManagement.HDT_WRP_sObject> wrpEventObjMap;

    public HDT_UTL_SlaManagement() {
        System.debug('>>> HDT_UTL_SlaManagement...');
    }

    public void setChangedObjList(Map<Id, HDT_WRP_SlaManagement.HDT_WRP_sObject> wrpEventObjMap){
        this.wrpCaseList = wrpEventObjMap.values();
        recordIdList = wrpEventObjMap.keySet();
    }
    
    public void execute(){

        try{

            List<SlaTracking__c> trackToUpsert = new List<SlaTracking__c>();
            Map<Id, List<SlaTracking__c>> trackingMap = new Map<Id, List<SlaTracking__c>>();
            Map<Id, HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin> wrpAdminMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin>();

            trackingRecordsList = new List<SlaTracking__c>();
            getTrackingRecords();

            if(trackingRecordsList.size() > 0){
                for(SlaTracking__c track : trackingRecordsList){
                    if(trackingMap.containsKey(track.Case__c)){
                        trackingMap.get(track.Case__c).add(track);
                    } else {
                        trackingMap.put(track.Case__c, new List<SlaTracking__c>{track});
                    }
                    
                }
            }

            List<HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin> wrpAdminList = buildSlaRules('HDT_RT_CaseSLA');

            for(HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin wrpAdmin : wrpAdminList){
                wrpAdminMap.put(wrpAdmin.slaAdminId, wrpAdmin);
            }

            HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin wrpAdmin;
            String startField;
            String endField;

            SlaTracking__c currentTrack;
            for(HDT_WRP_SlaManagement.HDT_WRP_sObject eventObj : wrpCaseList){
                
                if(trackingMap.containsKey(eventObj.recordId)){

                    List<SlaTracking__c> trackingList = trackingMap.get(eventObj.recordId);
                    Set<Id> adminIds = new Set<Id>();

                    for(SlaTracking__c track : trackingMap.get(eventObj.recordId)){
                        System.debug('>>> checking trckSla: ' + track.Id);
                        adminIds.add(track.SlaAdministration__c);

                        if(wrpAdminMap.containsKey(track.SlaAdministration__c) && track.Status__c.equalsIgnoreCase('Aperto')){

                            System.debug('>>> update existing sla....');
                            track = updateTrackingRecord(track, wrpAdminMap.get(track.SlaAdministration__c), eventObj);
                            if(track != null){
                                System.debug('>>> add new track...');
                                trackToUpsert.add(track);
                            }

                        }
                    }

                    // check for new tracking record to insert
                    System.debug('>>> check for new tracking record to insert...');
                    for(Id adminRuleId : wrpAdminMap.keySet()){
                        if(!adminIds.contains(adminRuleId)){
                            /// check if this rule have to create new tracking record
                            System.debug('>>> check if this rule have to create new tracking record...');
                            currentTrack = createNewTrackingRecord(currentTrack, wrpAdminMap.get(adminRuleId), eventObj);
                            if(currentTrack != null){
                                System.debug('>>> add new track...');
                                trackToUpsert.add(currentTrack);
                            }
                        }
                    }

                } else {
                    System.debug('>>> no record...');
                }

            }

            if(trackToUpsert.size() > 0){
                System.debug('>>> ' + String.valueOf(trackToUpsert));
                upsert trackToUpsert;
            }
            
            sendCustomNotification('ok');

        } catch(Exception e){
            System.debug('>>> Exception ' + e.getMessage() + ' at line ' + String.valueOf(e.getLineNumber()));
            sendCustomNotification(e.getMessage());
        }
    }

    public void getTrackingRecords(){
        trackingRecordsList = [
            SELECT Id, Activity__c, SlaAdministration__c, Case__c, EndDateTime__c, StartDateTime__c, Description__c,
                   SlaName__c, Order__c, Status__c, Name
            FROM SlaTracking__c
            WHERE Case__c IN :recordIdList
        ];
    }

    public static List<HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin> buildSlaRules(String slaRuleType){
        
        List<HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin> slaAdminRules = new List<HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin>();

        List<SlaAdministration__c> slaAdminList = [ 
            SELECT Id, CaseField__c, OrderField__c, Cluster__c, CompanyOwner__c, CreatedById, EndDate__c, StartDate__c,
                   Description__c, EndCasePhase__c, StartCasePhase__c, Range__c, LastModifiedById, Name, OwnerId, Process__c,
                   RecordTypeId, Commodity__c, SalesCompany__c, CustomerType__c, RangeType__c, Type__c
            FROM SlaAdministration__c
            WHERE RecordType.DeveloperName = :slaRuleType
            AND IsActive__c = true
        ];

        if(slaAdminList.size() == 0){
            return slaAdminRules;
        }

        HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin slaMgmt;
        for(SlaAdministration__c slaAdmin : slaAdminList){
            slaMgmt = new HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin();
            slaMgmt = buildSingleRule(slaMgmt, slaAdmin);
            slaAdminRules.add(slaMgmt);
        }

        return slaAdminRules;

    }

    public static HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin buildSingleRule(HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin slaMgmt, SlaAdministration__c slaAdmin){

        slaMgmt.slaAdminId = slaAdmin.Id;

        switch on slaAdmin.Type__c {
            when '01' {
                // Transizione Fasi Case
                slaMgmt.startRule.isDate = false;
                slaMgmt.startRule.obj = 'Case';
                //slaMgmt.startRule.field = 'Phase__c';
                slaMgmt.startRule.field = 'Status';
                slaMgmt.startRule.value = slaAdmin.StartCasePhase__c;

                slaMgmt.endRule.isDate = false;
                slaMgmt.endRule.obj = 'Case';
                //slaMgmt.endRule.field = 'Phase__c';
                slaMgmt.endRule.field = 'Status';
                slaMgmt.endRule.value = slaAdmin.EndCasePhase__c;
            }	
            when '02' {
                // Data presente sul Case –> Apertura Activity
                slaMgmt.startRule.isDate = true;
                slaMgmt.startRule.obj = 'Case';
                slaMgmt.startRule.field = slaAdmin.CaseField__c;
                slaMgmt.startRule.value = '';

                slaMgmt.endRule.isDate = true;
                slaMgmt.endRule.obj = 'Activity';
                slaMgmt.endRule.field = '';
                slaMgmt.endRule.value = '';
            }
            when '03' {
                // Data presente sul Case –> Chiusura Activity
            }	
            when '04' {
                // Data presente sul Case –> Fase Case
            }
        }

        return slaMgmt;
    }

    public static SlaTracking__c updateTrackingRecord(SlaTracking__c currentTrack, HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin singleRule, HDT_WRP_SlaManagement.HDT_WRP_sObject eventObj){

        if(singleRule.endRule.obj.equalsIgnoreCase('Case')){
            String endField = String.valueOf(eventObj.fieldMap.get(singleRule.endRule.field));

            if(endField.equalsIgnoreCase(singleRule.endRule.value)){
                System.debug('>>> update...');
                Object objField = eventObj.fieldMap.get('LastModifiedDate');
                currentTrack.EndDateTime__c = Datetime.valueOf(objField);
                currentTrack.Status__c = 'Chiuso';
            } else {
                return null;
            }

        } else {
            return null;
        }
        return currentTrack;
    }

    public static SlaTracking__c createNewTrackingRecord(SlaTracking__c currentTrack, HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin singleRule, HDT_WRP_SlaManagement.HDT_WRP_sObject eventObj){

        System.debug('>>> check this rule ' + singleRule.slaAdminId);

        if(eventObj.fieldMap.containsKey(singleRule.startRule.field)){

            System.debug('>>> startRule.field: ' +singleRule.startRule.field);
            currentTrack = new SlaTracking__c();
            currentTrack.Status__c = 'Aperto';
            currentTrack.Case__c = eventObj.recordId;
            currentTrack.SlaAdministration__c = singleRule.slaAdminId;

            Object dt;
            if(singleRule.startRule.isDate){
                System.debug('>>> isDate -> ' + singleRule.startRule.field);
                if(!eventObj.fieldMap.containsKey(singleRule.startRule.field)){
                    return null;  
                }
                dt = eventObj.fieldMap.get(singleRule.startRule.field);
            } else {
                System.debug('>>> isNotDate -> ' + singleRule.startRule.field);
                String startField = String.valueOf(eventObj.fieldMap.get(singleRule.startRule.field));
                if(startField.equalsIgnoreCase(singleRule.startRule.value)){
                    dt = eventObj.fieldMap.get('LastModifiedDate');
                } else {
                    return null;
                }
            }

            currentTrack.StartDateTime__c = Datetime.valueOf(dt);
            
        }
        return currentTrack;

    }

    public static void sendCustomNotification(String message){

        try{
            Id typeId = [SELECT Id FROM CUstomNotificationType LIMIT 1].Id;
            Id userId = '0051X0000055rbNQAQ';
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Event notification');
            notification.setBody(message);
            notification.setSenderId(userId);
            notification.setNotificationTypeId(typeId);
            notification.setTargetId(userId);
            notification.send(new Set<String> {userId});
        } catch(Exception ex){
            System.debug(logginglevel.DEBUG, '>>> somethig goes wrong with comunication: ' + ex.getMessage() + ' [' + String.valueOf(ex.getLineNumber()) + ']');
        }

    }

}