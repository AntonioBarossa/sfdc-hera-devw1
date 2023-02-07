@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ClassNamingConventions, PMD.ExcessiveParameterList, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces, PMD.LocalVariableNamingConventions')
public inherited sharing class HDT_UTL_SlaManagement {
    
    private Set<Id> recordIdList;
    private List<HDT_WRP_SlaManagement.HDT_WRP_Event> wrpCaseList;
    private List<SlaTracking__c> trackingRecordsList;
    private Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpEventObjMap;
    private String executionObject;
    private String trackingFieldKey;
    private String recordTypeDevName;
    private Map<Id, Object> sObjectCriteriaMap;
    private List<String> criteriaFields;

    public HDT_UTL_SlaManagement(String executionObject) {
        System.debug(logginglevel.DEBUG, '>>> HDT_UTL_SlaManagement...');

        this.executionObject = executionObject;
        criteriaFields = new List<String>{'Cluster__c'};

        switch on executionObject {
            when 'Case' {
                trackingFieldKey = 'Case__c';
                recordTypeDevName = 'HDT_RT_PostSales';
                criteriaFields.add('SalesCompany__c');
                criteriaFields.add('FirstLevelComplaintClassification__c');
                criteriaFields.add('SecondLevelComplaintClassification__c');
                criteriaFields.add('AtoFormula__c');
                criteriaFields.add('CompanyOwner__c');
                criteriaFields.add('Commodity__c');
            }	
            when 'Order' {
                trackingFieldKey = 'Order__c';
                recordTypeDevName = 'HDT_RT_Sales';
                criteriaFields.add('CustomerType__c');
                criteriaFields.add('SalesCompany__c');
                criteriaFields.add('ATO__c');
                criteriaFields.add('Process__c');
                criteriaFields.add('CompanyOwner__c');
                criteriaFields.add('Commodity__c');
            }
        }

        //CustomerType__c
        //SalesCompany__c
        //FirstLevelComplaintClassification__c	
        //SecondLevelComplaintClassification__c
        //Ato__c
        //Cluster__c
        //Process__c
        //CompanyOwner__c
        //Commodity__c

    }

    public void setChangedObjList(Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpEventObjMap){
        this.wrpCaseList = wrpEventObjMap.values();
        recordIdList = wrpEventObjMap.keySet();
    }
    
    public void execute(){

        try{

            List<SlaTracking__c> trackToUpsert = new List<SlaTracking__c>();
            Map<Id, List<SlaTracking__c>> trackingMap = new Map<Id, List<SlaTracking__c>>();
            Map<Id, HDT_WRP_SlaManagement.HDT_WRP_AdminRule> wrpAdminMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_AdminRule>();

            trackingRecordsList = new List<SlaTracking__c>();
            getTrackingRecords();
            getSobjectForCriteriaCheck();

            if(trackingRecordsList.size() > 0){
                Id keyId;
                for(SlaTracking__c track : trackingRecordsList){
                    keyId = (Id)track.get(trackingFieldKey);
                    if(trackingMap.containsKey(keyId)){
                        trackingMap.get(keyId).add(track);
                    } else {
                        trackingMap.put(keyId, new List<SlaTracking__c>{track});
                    }
                }
            }

            List<HDT_WRP_SlaManagement.HDT_WRP_AdminRule> wrpAdminList = buildSlaRules(recordTypeDevName);

            for(HDT_WRP_SlaManagement.HDT_WRP_AdminRule wrpAdmin : wrpAdminList){
                wrpAdminMap.put(wrpAdmin.adminRuleId, wrpAdmin);
            }

            SlaTracking__c currentTrack;
            //++Set<Id> adminIds;
            for(HDT_WRP_SlaManagement.HDT_WRP_Event eventObj : wrpCaseList){

                System.debug(logginglevel.DEBUG, '>>> eventObj.eventType: ' + eventObj.eventType);

                //++adminIds = new Set<Id>();
                //
                if(eventObj.eventType.equalsIgnoreCase('UPDATE') && trackingMap.containsKey(eventObj.recordId)){

                    System.debug(logginglevel.DEBUG, '>>> update tracking context');

                    List<SlaTracking__c> trackingList = trackingMap.get(eventObj.recordId);

                    for(SlaTracking__c track : trackingMap.get(eventObj.recordId)){
                        System.debug(logginglevel.DEBUG, '>>> checking trckSla: ' + track.Id);
                        //++adminIds.add(track.SlaAdministration__c);

                        if(wrpAdminMap.containsKey(track.SlaAdministration__c) && track.Status__c.equalsIgnoreCase('Aperto')){

                            System.debug(logginglevel.DEBUG, '>>> update existing sla....');
                            track = updateTrackingRecord(track, wrpAdminMap.get(track.SlaAdministration__c), eventObj);
                            if(track != null){
                                System.debug(logginglevel.DEBUG, '>>> update track...');
                                trackToUpsert.add(track);
                            } else {
                                System.debug(logginglevel.DEBUG, '>>> no track to update');
                            }

                        }
                    }

                }

                // check for new tracking record to insert
                // 
                if(eventObj.eventType.equalsIgnoreCase('CREATE') && wrpAdminMap.size() > 0){
                    System.debug(logginglevel.DEBUG, '>>> check for new tracking record to insert...');
                    for(Id adminRuleId : wrpAdminMap.keySet()){

                        ///++if(!adminIds.contains(adminRuleId)){
                            /// check if this rule have to create new tracking record
                            System.debug(logginglevel.DEBUG, '>>> check if this rule have to create new tracking record...');
                            currentTrack = createNewTrackingRecord(currentTrack, wrpAdminMap.get(adminRuleId), eventObj);
                            if(currentTrack != null){
                                System.debug(logginglevel.DEBUG, '>>> add new track...');
                                trackToUpsert.add(currentTrack);
                            } else {
                                System.debug(logginglevel.DEBUG, '>>> no track to insert');
                            }
                        //++}
                    }
                }

            }

            if(trackToUpsert.size() > 0){
                HDT_UTL_DatabaseService.upsertSObject(trackToUpsert);
            }
            
            //sendCustomNotification('ok');

        } catch(Exception e){
            System.debug(logginglevel.DEBUG, '>>> Exception ' + e.getMessage() + ' at line ' + String.valueOf(e.getLineNumber()));
            //sendCustomNotification(e.getMessage());
        }
    }

    public void getTrackingRecords(){

        String stringQuery = '';
        stringQuery += 'SELECT Id, Activity__c, SlaAdministration__c, Case__c, EndDateTime__c, StartDateTime__c, Description__c, SlaName__c, Order__c, Status__c, Name ';
        stringQuery += 'FROM SlaTracking__c ';
        stringQuery += 'WHERE ' + trackingFieldKey + ' IN : recordIdList ';
        stringQuery += 'WITH SECURITY_ENFORCED';

        List<sObject> sobjList = Database.query(stringQuery);
        trackingRecordsList = (List<SlaTracking__c>)sobjList;

    }

    public void getSobjectForCriteriaCheck(){
        String stringQuery = '';
        stringQuery += 'SELECT Id, ' + String.join(criteriaFields, ',') + ' ';
        stringQuery += 'FROM ' + executionObject + ' ';
        stringQuery += 'WHERE Id IN : recordIdList ';
        stringQuery += 'WITH SECURITY_ENFORCED';
        List<sObject> sobjList = Database.query(stringQuery);

        sObjectCriteriaMap = new Map<Id, Object>();
        for(sObject sObj : sobjList){
            sObjectCriteriaMap.put(sObj.Id, sObj);
        }

    }

    public static List<HDT_WRP_SlaManagement.HDT_WRP_AdminRule> buildSlaRules(String slaRuleType){
        
        List<HDT_WRP_SlaManagement.HDT_WRP_AdminRule> slaAdminRules = new List<HDT_WRP_SlaManagement.HDT_WRP_AdminRule>();

        List<SlaAdministration__c> slaAdminList = [ 
            SELECT Id, CaseField__c, OrderField__c, Cluster__c, CompanyOwner__c, EndDate__c, StartDate__c,
                   Description__c, EndCasePhase__c, StartCasePhase__c, Range__c, Name, Process__c, Ato__c,
                   RecordType.DeveloperName, Commodity__c, SalesCompany__c, CustomerType__c, RangeType__c, Type__c, ActivityType__c,
                   StartOrderPhase__c, EndOrderPhase__c, FirstLevelComplaintClassification__c, SecondLevelComplaintClassification__c
            FROM SlaAdministration__c
            WHERE RecordType.DeveloperName = :slaRuleType
            AND IsActive__c = true
        ];

        if(slaAdminList.size() == 0){
            return slaAdminRules;
        }

        HDT_WRP_SlaManagement.HDT_WRP_AdminRule slaMgmt;
        for(SlaAdministration__c slaAdmin : slaAdminList){
            slaMgmt = new HDT_WRP_SlaManagement.HDT_WRP_AdminRule();
            slaMgmt = buildObjectCriteria(slaMgmt, slaAdmin);
            slaMgmt = buildSingleRule(slaMgmt, slaAdmin);
            slaAdminRules.add(slaMgmt);
        }

        return slaAdminRules;

    }

    public Boolean errorCheckActivity(HDT_WRP_SlaManagement.HDT_WRP_Event eventObj, HDT_WRP_SlaManagement.HDT_WRP_AdminRule singleRule){

        Boolean ruleActivityType = String.isNotEmpty(singleRule.activityType);
        Boolean eventActivityType = String.isNotEmpty(eventObj.activityEvent.Type__c);

        if(ruleActivityType && eventActivityType){
            System.debug(logginglevel.DEBUG, '>>> check activity: ' + eventObj.activityEvent.Type__c.equalsIgnoreCase(singleRule.activityType));
            return !eventObj.activityEvent.Type__c.equalsIgnoreCase(singleRule.activityType);
        } else {
            return false;
        }

    }

    public Boolean errorCheckObjectCriteria(Id recordId, Map<String, Object> objectCriteria){

        if(objectCriteria.size() == 0){
            return false;
        }

        switch on executionObject {
            when 'Case' {
                Case eventCaseToCompare = (Case)sObjectCriteriaMap.get(recordId);
                for(String field : objectCriteria.keySet()){
                    if(eventCaseToCompare.get(field) != objectCriteria.get(field)){
                        System.debug(logginglevel.DEBUG, '>>> criteria error: ' + field);
                        return true;
                    }
                }
                return false;
            }	
            when 'Order' {
                Order eventOrderToCompare = (Order)sObjectCriteriaMap.get(recordId);
                for(String field : objectCriteria.keySet()){
                    if(eventOrderToCompare.get(field) != objectCriteria.get(field)){
                        System.debug(logginglevel.DEBUG, '>>> criteria error: ' + field);
                        return true;
                    }
                }
                return false;
            } when else {
                return true;
            }
        }

    }

    public static Boolean ruleDateIsValid(DateTime dateToValidate, HDT_WRP_SlaManagement.HDT_WRP_AdminRule singleRule){
        System.debug(logginglevel.DEBUG, '>>> dateToValidate: ' + String.valueOf(dateToValidate) + ' - startDate: ' + String.valueOf(singleRule.startValidDate) + ' - endDate: ' + String.valueOf(singleRule.endValidDate));
        return (dateToValidate >= singleRule.startValidDate && dateToValidate <= singleRule.endValidDate);
    }

    public SlaTracking__c updateTrackingRecord(SlaTracking__c currentTrack, HDT_WRP_SlaManagement.HDT_WRP_AdminRule singleRule, HDT_WRP_SlaManagement.HDT_WRP_Event eventObj){

        if(errorCheckActivity(eventObj, singleRule)){
            System.debug(logginglevel.DEBUG, '>>> errorCheckActivity');
            return null;
        }

        if(errorCheckObjectCriteria(eventObj.recordId, singleRule.objectCriteria)){
            System.debug(logginglevel.DEBUG, '>>> errorCheckObjectCriteria');
            return null;
        }

        if(singleRule.endRule.obj.equalsIgnoreCase(executionObject)){

            Object dt;
            if(singleRule.endRule.isDate){
                System.debug(logginglevel.DEBUG, '>>> isDate -> ' + singleRule.endRule.field);
                if(!eventObj.fieldMap.containsKey(singleRule.endRule.field)){
                    return null;  
                }
                dt = eventObj.fieldMap.get(singleRule.endRule.field);
            } else {
                String endField = String.valueOf(eventObj.fieldMap.get(singleRule.endRule.field));
                if(endField.equalsIgnoreCase(singleRule.endRule.value)){
                    dt = eventObj.fieldMap.get('LastModifiedDate');
                } else {
                    return null;
                }
            }
            currentTrack.EndDateTime__c = Datetime.valueOf(dt);
            currentTrack.Status__c = 'Chiuso';

            if(ruleDateIsValid(currentTrack.EndDateTime__c, singleRule)){
                System.debug(logginglevel.DEBUG, '>>> admin rule date is not valid');
                return currentTrack;
            } else {
                return null;
            }

        } else {
            return null;
        }

    }

    public SlaTracking__c createNewTrackingRecord(SlaTracking__c currentTrack, HDT_WRP_SlaManagement.HDT_WRP_AdminRule singleRule, HDT_WRP_SlaManagement.HDT_WRP_Event eventObj){

        System.debug(logginglevel.DEBUG, '>>> check this rule ' + singleRule.adminRuleId);

        if(errorCheckActivity(eventObj, singleRule)){
            System.debug(logginglevel.DEBUG, '>>> errorCheckActivity');
            return null;
        }

        if(errorCheckObjectCriteria(eventObj.recordId, singleRule.objectCriteria)){
            System.debug(logginglevel.DEBUG, '>>> errorCheckObjectCriteria');
            return null;
        }

        if(eventObj.fieldMap.containsKey(singleRule.startRule.field)){

            System.debug(logginglevel.DEBUG, '>>> startRule.field: ' + singleRule.startRule.field);
            currentTrack = new SlaTracking__c();
            currentTrack.Status__c = 'Aperto';
            //currentTrack.Case__c = eventObj.recordId;
            currentTrack.SlaAdministration__c = singleRule.adminRuleId;

            if(eventObj.activityEvent != null && eventObj.activityEvent.Id != null){
                currentTrack.Activity__c = eventObj.activityEvent.Id;
            }

            currentTrack.put(trackingFieldKey, eventObj.recordId);

            Object dt;
            if(singleRule.startRule.isDate){
                System.debug(logginglevel.DEBUG, '>>> isDate -> ' + singleRule.startRule.field);
                if(!eventObj.fieldMap.containsKey(singleRule.startRule.field)){
                    return null;  
                }
                dt = eventObj.fieldMap.get(singleRule.startRule.field);
            } else {
                System.debug(logginglevel.DEBUG, '>>> isNotDate -> ' + singleRule.startRule.field);
                String startField = String.valueOf(eventObj.fieldMap.get(singleRule.startRule.field));
                if(startField.equalsIgnoreCase(singleRule.startRule.value)){
                    dt = eventObj.fieldMap.get('LastModifiedDate');
                } else {
                    return null;
                }
            }

            currentTrack.StartDateTime__c = Datetime.valueOf(dt);
            


            if(!ruleDateIsValid(currentTrack.StartDateTime__c, singleRule)){
                System.debug(logginglevel.DEBUG, '>>> admin rule date is not valid');
                return null;
            }

            return currentTrack;

        } else {
            return null;
        }

    }

    public static HDT_WRP_SlaManagement.HDT_WRP_AdminRule buildObjectCriteria(HDT_WRP_SlaManagement.HDT_WRP_AdminRule slaMgmt, SlaAdministration__c slaAdmin){
        
        if(slaAdmin.StartDate__c != null){
            slaMgmt.startValidDate = slaAdmin.StartDate__c;
        }

        if(slaAdmin.EndDate__c != null){
            slaMgmt.endValidDate = slaAdmin.EndDate__c;
        }

        if(String.isNotEmpty(slaAdmin.Cluster__c)){
            slaMgmt.objectCriteria.put('Cluster__c', slaAdmin.Cluster__c);
        }

        if(String.isNotEmpty(slaAdmin.CompanyOwner__c)){
            slaMgmt.objectCriteria.put('CompanyOwner__c', slaAdmin.CompanyOwner__c);
        }

        if(String.isNotEmpty(slaAdmin.Commodity__c)){
            slaMgmt.objectCriteria.put('Commodity__c', slaAdmin.Commodity__c);
        }

        if(String.isNotEmpty(slaAdmin.SalesCompany__c)){
            slaMgmt.objectCriteria.put('SalesCompany__c', slaAdmin.SalesCompany__c);
        }

        //CustomerType__c
        //SalesCompany__c
        //FirstLevelComplaintClassification__c	
        //SecondLevelComplaintClassification__c
        //Ato__c
        //Cluster__c
        //Process__c
        //CompanyOwner__c
        //Commodity__c

        switch on slaAdmin.RecordType.DeveloperName {
            when 'HDT_RT_PostSales' {
                if(String.isNotEmpty(slaAdmin.Cluster__c)){
                    slaMgmt.objectCriteria.put('Cluster__c', slaAdmin.Cluster__c);
                }

                if(String.isNotEmpty(slaAdmin.FirstLevelComplaintClassification__c)){
                    slaMgmt.objectCriteria.put('FirstLevelComplaintClassification__c', slaAdmin.FirstLevelComplaintClassification__c);
                }

                if(String.isNotEmpty(slaAdmin.SecondLevelComplaintClassification__c)){
                    slaMgmt.objectCriteria.put('SecondLevelComplaintClassification__c', slaAdmin.SecondLevelComplaintClassification__c);
                }

                if(String.isNotEmpty(slaAdmin.Ato__c)){
                    slaMgmt.objectCriteria.put('AtoFormula__c', slaAdmin.Ato__c);
                }

            }
            when 'HDT_RT_Sales' {

                if(String.isNotEmpty(slaAdmin.CustomerType__c)){
                    slaMgmt.objectCriteria.put('CustomerType__c', slaAdmin.CustomerType__c);
                }

                if(String.isNotEmpty(slaAdmin.Ato__c)){
                    slaMgmt.objectCriteria.put('ATO__c', slaAdmin.Ato__c);
                }

                if(String.isNotEmpty(slaAdmin.Process__c)){
                    slaMgmt.objectCriteria.put('Process__c', slaAdmin.Process__c);
                }

            }

        }
        return slaMgmt;
    }

    public static HDT_WRP_SlaManagement.HDT_WRP_AdminRule buildSingleRule(HDT_WRP_SlaManagement.HDT_WRP_AdminRule slaMgmt, SlaAdministration__c slaAdmin){

        slaMgmt.adminRuleId = slaAdmin.Id;
        slaMgmt.activityType = slaAdmin.ActivityType__c;

        switch on slaAdmin.Type__c {
            when '01' {
                // Transizione Fasi Case
                slaMgmt.startRule.isDate = false;
                slaMgmt.startRule.obj = 'Case';
                slaMgmt.startRule.field = 'Phase__c';
                slaMgmt.startRule.value = slaAdmin.StartCasePhase__c;

                slaMgmt.endRule.isDate = false;
                slaMgmt.endRule.obj = 'Case';
                slaMgmt.endRule.field = 'Phase__c';
                slaMgmt.endRule.value = slaAdmin.EndCasePhase__c;
            }	
            when '02' {
                // Data presente sul Case –> Apertura Activity
                slaMgmt.startRule.isDate = true;
                slaMgmt.startRule.obj = 'Case';
                slaMgmt.startRule.field = slaAdmin.CaseField__c;
                slaMgmt.startRule.value = '';

                slaMgmt.endRule.isDate = true;
                slaMgmt.endRule.obj = 'Case';
                slaMgmt.endRule.field = 'ActivityStartTime__c';
                slaMgmt.endRule.value = '';
            }
            when '03' {
                // Data presente sul Case –> Chiusura Activity
                slaMgmt.startRule.isDate = true;
                slaMgmt.startRule.obj = 'Case';
                slaMgmt.startRule.field = slaAdmin.CaseField__c;
                slaMgmt.startRule.value = '';

                slaMgmt.endRule.isDate = true;
                slaMgmt.endRule.obj = 'Case';
                slaMgmt.endRule.field = 'ActivityEndTime__c';
                slaMgmt.endRule.value = '';
            }	
            when '04' {
                // Data presente sul Case –> Fase Case
                slaMgmt.startRule.isDate = true;
                slaMgmt.startRule.obj = 'Case';
                slaMgmt.startRule.field = slaAdmin.CaseField__c;
                slaMgmt.startRule.value = '';

                slaMgmt.endRule.isDate = false;
                slaMgmt.endRule.obj = 'Case';
                slaMgmt.endRule.field = 'Phase__c';
                slaMgmt.endRule.value = slaAdmin.EndCasePhase__c;
            }
            when '05' {
                // Apertura Activity –> Chiusura Activity
                slaMgmt.startRule.isDate = true;
                slaMgmt.startRule.obj = 'Case';
                slaMgmt.startRule.field = 'ActivityStartTime__c';
                slaMgmt.startRule.value = '';

                slaMgmt.endRule.isDate = true;
                slaMgmt.endRule.obj = 'Case';
                slaMgmt.endRule.field = 'ActivityEndTime__c';
                slaMgmt.endRule.value = '';
            }
            when '06' {
                // Transizione Fasi Order
                slaMgmt.startRule.isDate = false;
                slaMgmt.startRule.obj = 'Order';
                slaMgmt.startRule.field = 'Phase__c';
                slaMgmt.startRule.value = slaAdmin.StartOrderPhase__c;

                slaMgmt.endRule.isDate = false;
                slaMgmt.endRule.obj = 'Order';
                slaMgmt.endRule.field = 'Phase__c';
                slaMgmt.endRule.value = slaAdmin.EndOrderPhase__c;
            }
            when '07' {
                // Data presente sull'Order –> Apertura Activity

                slaMgmt.startRule.isDate = false;
                slaMgmt.startRule.obj = 'Order';
                slaMgmt.startRule.field = slaAdmin.OrderField__c;
                slaMgmt.startRule.value = '';

                slaMgmt.endRule.isDate = false;
                slaMgmt.endRule.obj = 'Order';
                slaMgmt.endRule.field = 'ActivityStartTime__c';
                slaMgmt.endRule.value = '';
            }
            when '08' {
                // Data presente sull'Order –> Chiusura Activity
                slaMgmt.startRule.isDate = false;
                slaMgmt.startRule.obj = 'Order';
                slaMgmt.startRule.field = slaAdmin.OrderField__c;
                slaMgmt.startRule.value = '';

                slaMgmt.endRule.isDate = false;
                slaMgmt.endRule.obj = 'Order';
                slaMgmt.endRule.field = 'ActivityEndTime__c';
                slaMgmt.endRule.value = '';
            }
            when '09' {
                // Data presente sull'Order –> Fase Order
                slaMgmt.startRule.isDate = true;
                slaMgmt.startRule.obj = 'Order';
                slaMgmt.startRule.field = slaAdmin.OrderField__c;
                slaMgmt.startRule.value = '';

                slaMgmt.endRule.isDate = false;
                slaMgmt.endRule.obj = 'Order';
                slaMgmt.endRule.field = 'Phase__c';
                slaMgmt.endRule.value = slaAdmin.EndOrderPhase__c;
            }
            when '10' {
                // Data apertura activity –> Data chiusura activity
                slaMgmt.startRule.isDate = true;
                slaMgmt.startRule.obj = 'Order';
                slaMgmt.startRule.field = 'ActivityStartTime__c';
                slaMgmt.startRule.value = '';

                slaMgmt.endRule.isDate = true;
                slaMgmt.endRule.obj = 'Order';
                slaMgmt.endRule.field = 'ActivityEndTime__c';
                slaMgmt.endRule.value = '';
            }
        
        }

        return slaMgmt;
    }

    //public static void sendCustomNotification(String message){
//
    //    try{
    //        Id typeId = [SELECT Id FROM CUstomNotificationType WITH SECURITY_ENFORCED LIMIT 1].Id;
    //        Id userId = '0051X0000055rbNQAQ';
    //        Messaging.CustomNotification notification = new Messaging.CustomNotification();
    //        notification.setTitle('Event notification');
    //        notification.setBody(message);
    //        notification.setSenderId(userId);
    //        notification.setNotificationTypeId(typeId);
    //        notification.setTargetId(userId);
    //        notification.send(new Set<String> {userId});
    //    } catch(Exception ex){
    //        System.debug(logginglevel.DEBUG, '>>> somethig goes wrong with comunication: ' + ex.getMessage() + ' [' + String.valueOf(ex.getLineNumber()) + ']');
    //    }
//
    //}

    public static List<String> getFieldsForChangeEvent(String objApiName, String fieldSetName){
        List<String> fieldSetList = new List<String>();
        try{
            List<Schema.FieldSetMember> fieldSetMembers;
            fieldSetMembers = ((SObject)Type.forName(objApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
            for(Schema.FieldSetMember s : fieldSetMembers) {
                fieldSetList.add(String.valueOf(s.getFieldPath()));
            }

        } catch(Exception ex){
            System.debug(logginglevel.DEBUG, '>>> ERROR: ' + ex.getMessage() + ' [' + ex.getLineNumber() + ']');
        }

        return fieldSetList;
    }

}