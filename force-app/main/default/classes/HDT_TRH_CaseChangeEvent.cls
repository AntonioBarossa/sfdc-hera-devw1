@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ExcessiveParameterList')
public inherited sharing class HDT_TRH_CaseChangeEvent {

    public static void afterInsert(List<CaseChangeEvent> CaseChangeEventList) {

        System.debug(logginglevel.DEBUG, '>>> eventSize: ' + CaseChangeEventList.size());

        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpObjMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>();
        Set<Id> deletedRecords = new Set<Id>();

        try{
            HDT_WRP_SlaManagement.HDT_WRP_Event wrpObj;
            for(CaseChangeEvent event : CaseChangeEventList){
                
                System.debug(logginglevel.DEBUG, '>>> ' + JSON.serialize(event));

                EventBus.ChangeEventHeader header = event.ChangeEventHeader;

                List<Id> eventIds = header.getRecordIds();
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

                for(Id i : eventIds){
                    if(wrpObjMap.containsKey(i)){
                        wrpObj = wrpObjMap.get(i);
                    } else {
                        wrpObj = new HDT_WRP_SlaManagement.HDT_WRP_Event();
                        wrpObj.recordId = i;
                        wrpObj.sObjType = 'Case';
                        wrpObj.eventType = header.changeType;
                        wrpObj.fieldMap = new Map<String, Object>();
                        wrpObjMap.put(i, wrpObj);
                    }
                }

                List<String> objFields;
                objFields = HDT_UTL_SlaManagement.getFieldsForChangeEvent('Case', 'ChangeEventFields');

                for(String field : objFields) {
                    
                    if(event.get(field) != null) {
                        Object fieldValue = event.get(field);
                        //System.debug(logginglevel.DEBUG, '>>> field: ' + field + ' - value: ' + fieldValue);

                        for(Id i : eventIds){
                            if(wrpObjMap.containsKey(i)){
                                wrpObj = wrpObjMap.get(i);
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
            HDT_UTL_SlaManagement.deleteEventHandler(deletedRecords, Datetime.now());
        }

    }

}