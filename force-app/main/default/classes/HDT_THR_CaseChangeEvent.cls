@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ExcessiveParameterList')
public inherited sharing class HDT_THR_CaseChangeEvent {

    public static void afterInsert(List<CaseChangeEvent> CaseChangeEventList) {

        System.debug('>>> eventSize: ' + CaseChangeEventList.size());

        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_sObject> wrpObjMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_sObject>();

        HDT_WRP_SlaManagement.HDT_WRP_sObject wrpObj;
        for(CaseChangeEvent event : CaseChangeEventList){
            
            System.debug('>>> ' + JSON.serialize(event));

            EventBus.ChangeEventHeader header = event.ChangeEventHeader;

            List<Id> eventIds = header.getRecordIds();
            System.debug('>>> eventIds ' + eventIds);

            for(Id i : eventIds){
                if(wrpObjMap.containsKey(i)){
                    wrpObj = wrpObjMap.get(i);
                } else {
                    wrpObj = new HDT_WRP_SlaManagement.HDT_WRP_sObject();
                    wrpObj.recordId = i;
                    wrpObj.sObjType = 'Case';
                    wrpObj.eventType = header.changeType;
                    wrpObj.fieldMap = new Map<String, Object>();
                    wrpObjMap.put(i, wrpObj);
                }
            }

            List<String> objFields = new List<String>();

            switch on header.changeType {
                when 'CREATE' {
                    objFields.add('CustomerRequestDate__c');
                    objFields.add('CaseNumber');
                }	
                when 'UPDATE' {
                    objFields = header.changedFields;
                }
            }

            for(String field : objFields) {
                
                if(event.get(field) != null) {
                    Object fieldValue = event.get(field);
                    //System.debug('>>> field: ' + field + ' - value: ' + fieldValue);

                    for(Id i : eventIds){
                        if(wrpObjMap.containsKey(i)){
                            wrpObj = wrpObjMap.get(i);
                            wrpObj.fieldMap.put(field, fieldValue);
                        }
                    }

                }

            }

            //switch on cce.ChangeEventHeader.changeType {
            //    when 'INSERT' {
            //        cceInsertMap.put();
            //    }	
            //    when 'UPDATE' {
            //        cceUpdateMap
            //    }
            //}

        }

        HDT_UTL_SlaManagement management = new HDT_UTL_SlaManagement();
        management.setRecordIds(wrpObjMap.keySet());
        management.setChangedObjList(wrpObjMap.values());
        management.manageInsert();
    }

}