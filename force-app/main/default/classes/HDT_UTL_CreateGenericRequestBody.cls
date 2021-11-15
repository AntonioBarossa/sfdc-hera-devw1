public with sharing class HDT_UTL_CreateGenericRequestBody {
    
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static String createBodyRequest(SObject sobj){

        System.debug(LoggingLevel.DEBUG, 'createBodyRequest - Received sObject: ' + sobj);

        HDT_WRP_VoltureChangeManager reqRoot = new HDT_WRP_VoltureChangeManager();
        List<HDT_WRP_VoltureChangeManager.HDT_WRP_Request> requests = new List<HDT_WRP_VoltureChangeManager.HDT_WRP_Request>();
        HDT_WRP_VoltureChangeManager.HDT_WRP_Request request = new HDT_WRP_VoltureChangeManager.HDT_WRP_Request();
        HDT_WRP_VoltureChangeManager.HDT_WRP_Header header = new HDT_WRP_VoltureChangeManager.HDT_WRP_Header();
        List<HDT_WRP_VoltureChangeManager.HDT_WRP_Object> objects = new List<HDT_WRP_VoltureChangeManager.HDT_WRP_Object>();
        List<HDT_WRP_VoltureChangeManager.HDT_WRP_Field> fields = new List<HDT_WRP_VoltureChangeManager.HDT_WRP_Field>();
        
        List<HDT_Request_Servizi_Q01Q02__mdt> reqContPodPdrMdtList = [SELECT Name__c, Value__c, Standard_Value__c, Field_Type__c FROM HDT_Request_Servizi_Q01Q02__mdt WHERE Object_Name__c =: String.valueof(sobj.getSObjectType()) WITH SECURITY_ENFORCED];
        
        if (reqContPodPdrMdtList.size() > 0) {

            System.debug(LoggingLevel.DEBUG, 'Custom Metadata found');
            
            try {

                header.requestId = 'tempValue';
                header.fields = null;
                header.requestTimeStamp = String.valueOf(Datetime.now());
                header.requestType = 'CREA_RIC';
    
                request.header = header;
                
                for (HDT_Request_Servizi_Q01Q02__mdt mdt : reqContPodPdrMdtList){

                    HDT_WRP_VoltureChangeManager.HDT_WRP_Field f = new HDT_WRP_VoltureChangeManager.HDT_WRP_Field();
                    f.fieldType = mdt.Field_Type__c;
                    f.name =  mdt.Name__c;
                    
                    if (!String.isBlank(mdt.Value__c)){
                        f.value = String.valueof(sobj.get(mdt.Value__c));
                    }else{
                        f.value = mdt.Standard_Value__c;
                    }
                    
                    fields.add(f);
                }
    
                HDT_WRP_VoltureChangeManager.HDT_WRP_Object obj = new HDT_WRP_VoltureChangeManager.HDT_WRP_Object();
                obj.fields = fields;
                obj.id = null;
                obj.name = 'Static Value';
                obj.objects = null;
                obj.objectType = null;
        
                objects.add(obj);
                request.objects = objects;

                requests.add(request);

                reqRoot.header = null;
                reqRoot.requests = requests;

            } catch (Exception e) {

                System.debug(LoggingLevel.DEBUG, 'Catched Exception ' + e.getMessage());
                throw e;

            }
        }
        
        System.debug(LoggingLevel.DEBUG, 'REQUEST: ' + JSON.serialize(reqRoot));
        return JSON.serialize(reqRoot);

    }

}
