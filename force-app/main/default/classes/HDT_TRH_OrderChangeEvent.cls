public with sharing class HDT_TRH_OrderChangeEvent {

    public static void afterInsert(List<OrderChangeEvent> orderChangeEventList) {

        System.debug(logginglevel.DEBUG, '>>> eventSize: ' + orderChangeEventList.size());

        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpObjMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>();

        try{
            HDT_WRP_SlaManagement.HDT_WRP_Event wrpObj;
            for(OrderChangeEvent event : orderChangeEventList){
                
                System.debug(logginglevel.DEBUG, '>>> ' + JSON.serialize(event));

                EventBus.ChangeEventHeader header = event.ChangeEventHeader;

                List<Id> eventIds = header.getRecordIds();
                System.debug(logginglevel.DEBUG, '>>> eventIds ' + eventIds);

                for(Id i : eventIds){
                    if(wrpObjMap.containsKey(i)){
                        wrpObj = wrpObjMap.get(i);
                    } else {
                        wrpObj = new HDT_WRP_SlaManagement.HDT_WRP_Event();
                        wrpObj.recordId = i;
                        wrpObj.sObjType = 'Order';
                        wrpObj.eventType = header.changeType;
                        wrpObj.fieldMap = new Map<String, Object>();
                        wrpObjMap.put(i, wrpObj);
                    }
                }

                List<String> objFields;
                objFields = HDT_UTL_SlaManagement.getFieldsForChangeEvent('Order', 'ChangeEventFields');

                //switch on header.changeType {
                //    when 'CREATE' {
                //        objFields = HDT_UTL_SlaManagement.getFieldsForChangeEvent('Case', 'ChangeEventFields');
                //    }	
                //    when 'UPDATE' {
                //        objFields = new List<String>();
                //        objFields = header.changedFields;
                //    }
                //}

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

        System.debug(logginglevel.DEBUG, '>>> wrpObjMap: ' + String.valueOf(wrpObjMap));

        if(wrpObjMap.size() > 0){
            //HDT_UTL_SlaManagement management = new HDT_UTL_SlaManagement('Order');
            //management.setChangedObjList(wrpObjMap);
            //management.execute();
        }
    }

}