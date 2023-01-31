@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_LC_SelfReading {

    private static HDT_QR_SelfReadings queryClass = new HDT_QR_SelfReadings();

    @AuraEnabled
    public static void insertSelfReading(String fields){
        System.debug(LoggingLevel.DEBUG, 'HDT_LC_SelfReading: ' +fields);
 
        Reading__c obj = (Reading__c)JSON.deserialize(fields, Reading__c.class);
 
        HDT_UTL_DatabaseService.insertSObject(obj);
    }
 
    @AuraEnabled
    public static void updateSelfReading(String fields){
 
        Reading__c obj = (Reading__c)JSON.deserialize(fields, Reading__c.class);
 
        HDT_UTL_DatabaseService.updateSObject(obj);
    }

    @AuraEnabled
    public static Id getReadingId(String objectName, Id objectId, String commodity){

        return queryClass.getReadingId(objectName, objectId, commodity);
        
    }

    @AuraEnabled
    public static string updateOrder(String fields, String recordId, 
    Boolean isRetroactive, 
    Boolean isReading, 
    Date readingCustomerDate,
    Boolean completed){

        Order obj = new Order();
        if(fields != null){
            obj = (Order)JSON.deserialize(fields, Order.class);
            obj.ConnectionType__c = 'Permanente';
        }

        obj.Id = recordId;
        if(!completed){
            if(readingCustomerDate != null){
                obj.ReadingCustomerDate__c = readingCustomerDate;
            }

            if(isRetroactive){
                obj.Volture__c = 'Retroattiva';
            } else if(isReading){
                obj.Volture__c = 'Con Autolettura';
            } else {
                obj.Volture__c = 'Standard';
            }

        } else {
            //inserire update cliente uscente
            //inserire update cliente uscente
            obj.Step__c = 20;
            obj.Phase__c = 'Accettazione Voltura';
        }

        if(obj.RetroactiveDate__c != null){
            if(obj.RetroactiveDate__c >= System.today()){
                throw new AuraHandledException('La Data Retroattiva deve essere nel passato'); 
            }
        } else if(obj.SignedDate__c != null){
            if(obj.SignedDate__c > System.today()){
                throw new AuraHandledException('La Data Firma non può essere nel futuro'); 
            }

        }

        HDT_UTL_DatabaseService.updateSObject(obj);
        return null;
    }


    @AuraEnabled
    public static string getRecordTypeId(String commodity){
        String recordTypeName = commodity == 'Gas' ? 'HDT_RT_LetturaGas' : ( commodity == 'Acqua' ? 'HDT_RT_LetturaAcqua':'HDT_RT_LetturaEle');
        RecordType rtId = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName WITH SECURITY_ENFORCED];
        return rtId.Id;
    }

    @AuraEnabled
    public static String checkLastReadings(String servicePointId){

        HDT_QR_ServicePoint queryHandler = new HDT_QR_ServicePoint();
        List<ServicePoint__c> servicePoints = queryHandler.getRecordById(servicePointId, 'Id,SAPImplantCode__c');
        if (!servicePoints.isEmpty()) {
            // Il ServicePoint su una autolettura da processo potrebbe non ancora essere associato ad un impianto su SAP.
            if (String.isBlank(servicePoints[0].SAPImplantCode__c)) {
                return 'ERROR_NO_ASSET_NUMBER';
            }
        }

        HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
        sapIntegration.recordId = servicePointId;
        sapIntegration.requestType = 'VerificaUltimaLettura';

        HDT_UTL_SapIntegrationInterface support = HDT_UTL_SapIntegrationAdapterFactory.getInstance('HDT_WS_GenericSapIntegrationAdapter');
        try {
            sapIntegration = support.submitRequest(sapIntegration);
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'checkLastReadings - Exception TypeName: ' + ex.getTypeName());
            System.debug(LoggingLevel.DEBUG, 'checkLastReadings - Exception Message: ' + ex.getMessage());
            System.debug(LoggingLevel.DEBUG, 'checkLastReadings - Exception StackTraceString: ' + ex.getStackTraceString());
            
        }

        System.debug(LoggingLevel.DEBUG, 'Response Verifica Ultima Lettura: ' + sapIntegration.responseBody);
        return sapIntegration.responseBody;
    }

}