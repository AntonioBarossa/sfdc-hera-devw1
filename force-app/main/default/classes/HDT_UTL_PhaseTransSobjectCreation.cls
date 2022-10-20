/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 20-10-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.AvoidDebugStatements')
global inherited sharing class HDT_UTL_PhaseTransSobjectCreation implements wrts_prcgvr.Interfaces_1_2.IApexActionBulk {
    
    private static List<Sobject> sObjectsToInsert = new List<Sobject>();

    global Object execute(Object args){
    
        Map<String, Object> argsMap = (Map<String, Object>) args;
        system.debug(LoggingLevel.DEBUG,json.serialize(args));
        List<Order> senders = (List<Order>) ((Map<String,Object>)argsMap.get('parameter')).get('records');
        String method = (String) argsMap.get('method');
        
        switch on method {
            when 'FacilityApproval'{
                RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_IstruttoriaAgevolazione' WITH SECURITY_ENFORCED];

                for(Order o : senders){
                    Case caso = new Case(RecordTypeId = recordType.Id, Type = 'Avviso di Servizio', Phase__c = 'Bozza', Order__c = o.Id);
                    sObjectsToInsert.add(caso);
                }
            }
        }

    return null;

    }

    public static void insertBulkSobjects(){
        if(sObjectsToInsert.isEmpty()){
            return;
        }else{
            HDT_UTL_DatabaseService.insertSObject(sObjectsToInsert);
        }
    }

}