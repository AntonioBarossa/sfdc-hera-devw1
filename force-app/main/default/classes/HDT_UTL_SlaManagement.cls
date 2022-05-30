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
                System.debug('>>> WRP_SlaAdmin ' + wrpAdmin);
                wrpAdminMap.put(wrpAdmin.slaAdminId, wrpAdmin);
            }

            HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin wrpAdmin;
            String startField;
            String endField;

            SlaTracking__c currentTrack;
            for(HDT_WRP_SlaManagement.HDT_WRP_sObject eventObj : wrpCaseList){
                
                if(trackingMap.containsKey(eventObj.recordId)){

                    for(SlaTracking__c track : trackingMap.get(eventObj.recordId)){
                        if(wrpAdminMap.containsKey(track.SlaAdministration__c)){
                            wrpAdmin = wrpAdminMap.get(track.SlaAdministration__c);

                            endField = String.valueOf(eventObj.fieldMap.get(wrpAdmin.endRule.field));

                            if(endField.equalsIgnoreCase(wrpAdmin.endRule.value)){
                                System.debug('>>> update...');
                                Object o = eventObj.fieldMap.get('LastModifiedDate');
                                track.EndDateTime__c = Datetime.valueOf(o);
                                trackToUpsert.add(track);
                            }
                        }
                    }

                } else {
                    for(HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin singleRule : wrpAdminList){

                        if(eventObj.fieldMap.containsKey(singleRule.startRule.field)){

                            startField = String.valueOf(eventObj.fieldMap.get(singleRule.startRule.field));
    
                            if(startField.equalsIgnoreCase(singleRule.startRule.value)){
                                System.debug('>>> update...');
                                currentTrack = new SlaTracking__c();
                                currentTrack.Case__c = eventObj.recordId;
                                currentTrack.SlaAdministration__c = singleRule.slaAdminId;
                                Object dt = eventObj.fieldMap.get('LastModifiedDate');
                                currentTrack.StartDateTime__c = Datetime.valueOf(dt);
                                trackToUpsert.add(currentTrack);
                            }


                        }
                    }
            
                }

            }

            upsert trackToUpsert;
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
            //WHERE Id IN :slaAdminId
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
                slaMgmt.startRule.field = 'CaseField__c';
                slaMgmt.startRule.value = slaAdmin.CaseField__c;

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