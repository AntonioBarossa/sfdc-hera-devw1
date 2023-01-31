@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ExcessiveParameterList')
public inherited sharing class HDT_TRH_CustomActivityChangeEvent {

    public static void afterInsert(List<wrts_prcgvr__Activity__ChangeEvent> activityChangeEventList) {

        System.debug(logginglevel.DEBUG, '>>> eventSize: ' + activityChangeEventList.size());

        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpObjMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>();
        Map<Id, Id> activityIdsMap = new Map<Id, Id>();
        Map<Id, wrts_prcgvr__Activity__c> activityMap = new Map<Id, wrts_prcgvr__Activity__c>();

        try{
            List<Id> activityIds = new List<Id>();
            for(wrts_prcgvr__Activity__ChangeEvent event : activityChangeEventList){
                EventBus.ChangeEventHeader header = event.ChangeEventHeader;
                activityIds.addAll(header.getRecordIds());
            }

            List<wrts_prcgvr__Activity__c> activityList = [
                SELECT Id, Case__c, Order__c, Type__c
                FROM wrts_prcgvr__Activity__c
                WHERE Id IN :activityIds
                WITH SECURITY_ENFORCED
            ];

            for(wrts_prcgvr__Activity__c activity : activityList){
                if(activity.Case__c != null){
                    activityIdsMap.put(activity.Id, activity.Case__c);
                } else if(activity.Order__c != null){
                    activityIdsMap.put(activity.Id, activity.Order__c);
                }
                if(activity.Case__c != null || activity.Order__c != null){
                    activityMap.put(activity.Id, activity);
                }
            }

            HDT_WRP_SlaManagement.HDT_WRP_Event wrpObj;
            for(wrts_prcgvr__Activity__ChangeEvent event : activityChangeEventList){
                
                System.debug(logginglevel.DEBUG, '>>> ' + JSON.serialize(event));

                EventBus.ChangeEventHeader header = event.ChangeEventHeader;

                List<Id> eventIds = header.getRecordIds();
                System.debug(logginglevel.DEBUG, '>>> eventIds ' + eventIds);

                Id changeId;
                for(Id i : eventIds){

                    changeId = activityIdsMap.get(i);

                    if(wrpObjMap.containsKey(changeId)){
                        wrpObj = wrpObjMap.get(changeId);
                    } else {
                        wrpObj = new HDT_WRP_SlaManagement.HDT_WRP_Event();
                        wrpObj.recordId = changeId;
                        wrpObj.sObjType = String.valueOf(changeId.getSobjectType());
                        wrpObj.eventType = header.changeType;
                        wrpObj.fieldMap = new Map<String, Object>();
                        wrpObj.activityEvent = activityMap.get(changeId);
                        wrpObjMap.put(changeId, wrpObj);
                    }
                }

                List<String> objFields = new List<String>();
                objFields.add('ActivityStartTime__c');
                objFields.add('ActivityEndTime__c');

                for(String field : objFields) {
                    
                    if(event.get(field) != null) {
                        Object fieldValue = event.get(field);
                        
                        Id replaceId;
                        for(Id i : eventIds){

                            replaceId = activityIdsMap.get(i);

                            if(wrpObjMap.containsKey(replaceId)){
                                wrpObj = wrpObjMap.get(replaceId);
                                wrpObj.fieldMap.put(field, fieldValue);
                            }
                        }

                    }

                }

            }

            for(String key : wrpObjMap.keySet()){
                Integer conter = 0;
                
                for(String field : wrpObjMap.get(key).fieldMap.keySet()){
                    if(!field.equalsIgnoreCase('LastModifiedDate')){
                        conter++;
                    }
                }

                if(conter == 0){
                    wrpObjMap.remove(key);
                }
            }

        } catch(Exception e){
            System.debug(logginglevel.DEBUG, '>>> Exception ' + e.getMessage() + ' - at line [' + String.valueOf(e.getLineNumber()));
        }

        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpObjCaseMap;
        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpObjOrderMap;
        wrpObjCaseMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>();
        wrpObjOrderMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>();
        
        HDT_WRP_SlaManagement.HDT_WRP_Event event;
        for(Id i : wrpObjMap.keyset()){
            event = wrpObjMap.get(i);
            if(event.sObjType.equalsIgnoreCase('Case')){
                wrpObjCaseMap.put(i, event);
            } else if(event.sObjType.equalsIgnoreCase('Order')){
                wrpObjOrderMap.put(i, event);
            }
        }

        if(wrpObjCaseMap.size() > 0){
            HDT_UTL_SlaManagement managementCase = new HDT_UTL_SlaManagement('Case');
            managementCase.setChangedObjList(wrpObjCaseMap);
            managementCase.execute();
        }

        if(wrpObjOrderMap.size() > 0){
            HDT_UTL_SlaManagement managementOrder = new HDT_UTL_SlaManagement('Order');
            managementOrder.setChangedObjList(wrpObjOrderMap);
            managementOrder.execute();
        }

    }

}