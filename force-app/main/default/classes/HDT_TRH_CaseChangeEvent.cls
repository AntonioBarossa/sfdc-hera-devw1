@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ExcessiveParameterList')
public inherited sharing class HDT_TRH_CaseChangeEvent {

    public static void afterInsert(List<CaseChangeEvent> CaseChangeEventList) {

        System.debug(logginglevel.DEBUG, '>>> eventSize: ' + CaseChangeEventList.size());

        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpObjMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>();
        Set<Id> deletedRecords = new Set<Id>();

        try{
            List<String> filterFields;
            HDT_WRP_SlaManagement.HDT_WRP_Event wrpObj;
            List<Id> eventIds;
            EventBus.ChangeEventHeader header;
            Object fieldValue;

            filterFields = HDT_UTL_SlaManagement.getFieldsForChangeEvent('Case', 'ChangeEventFields');

            for(CaseChangeEvent event : CaseChangeEventList){
                
                System.debug(logginglevel.DEBUG, '>>> ' + JSON.serialize(event));

                header = event.ChangeEventHeader;
                eventIds = header.getRecordIds();

                System.debug(logginglevel.DEBUG, '>>> eventIds ' + eventIds);

                if(header.changeType.equalsIgnoreCase('UNDELETE')){
                    // UNDELETE action not managed
                    continue;
                }

                if(header.changeType.equalsIgnoreCase('DELETE')){
                    deletedRecords.addAll(eventIds);
                    System.debug(logginglevel.DEBUG, '>>> deletedRecords ' + deletedRecords);
                    continue;
                }
                
                for(String field : filterFields) {
                    
                    fieldValue = event.get(field);
                    //System.debug(logginglevel.DEBUG, '>>> field: ' + field + ' - value: ' + fieldValue);

                    if(fieldValue == null) {
                        continue;
                    }

                    for(Id i : eventIds){
                        if(wrpObjMap.containsKey(i)){
                            wrpObj = wrpObjMap.get(i);
                            wrpObj.fieldMap.put(field, fieldValue);
                        } else {
                            wrpObj = new HDT_WRP_SlaManagement.HDT_WRP_Event();
                            wrpObj.recordId = i;
                            wrpObj.sObjType = 'Case';
                            wrpObj.eventType = header.changeType;
                            wrpObj.fieldMap = new Map<String, Object>{field => fieldValue};
                            wrpObjMap.put(i, wrpObj);
                        }

                        if(!wrpObjMap.get(i).fieldMap.containsKey('LastModifiedDate')){
                            wrpObjMap.remove(i);
                        }

                    }

                }

            }

        } catch(Exception e){
            System.debug(logginglevel.DEBUG, '>>> Exception ' + e.getMessage() + ' - at line [' + String.valueOf(e.getLineNumber()) + ']');
        }

        System.debug(logginglevel.DEBUG, '>>> wrpObjMap ' + wrpObjMap);

        if(wrpObjMap.size() > 0){
            // only for CREATE and UPDATE events
            System.debug(logginglevel.DEBUG, '>>> CREATE and UPDATE events...');
            HDT_UTL_SlaManagement management = new HDT_UTL_SlaManagement('Case');
            management.setChangedObjList(wrpObjMap);
            management.execute();
        }

        if(deletedRecords.size() > 0){
            // only for DELETE event
            System.debug(logginglevel.DEBUG, '>>> DELETE handler event...');
            HDT_UTL_SlaManagement deleteManagement = new HDT_UTL_SlaManagement('Case');
            deleteManagement.setDeletedRecordIdsList(deletedRecords);
            deleteManagement.deleteEventHandler(Datetime.now());
        }

    }

}