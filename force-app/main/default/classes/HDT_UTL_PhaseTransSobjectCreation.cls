/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 18-01-2023
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.AvoidDebugStatements')
global inherited sharing class HDT_UTL_PhaseTransSobjectCreation implements wrts_prcgvr.Interfaces_1_2.IApexActionBulk {
    
    private static List<Sobject> sObjectsToInsert = new List<Sobject>();

    global Object execute(Object args){
    
        Map<String, Object> argsMap = (Map<String, Object>) args;
        system.debug(LoggingLevel.DEBUG,json.serialize(args));
        List<SObject> senders = (List<SObject>) ((Map<String,Object>)argsMap.get('parameter')).get('records');
        String method = (String) argsMap.get('method');
        
        switch on method {
            when 'FacilityApproval'{
                Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();

                for(SObject s : senders){
                    if(s instanceof Order){
                        Order ord = (Order) s;
                        Case caso = new Case(RecordTypeId = recordTypeId, Type = 'Avviso di Servizio', Phase__c = 'Bozza', Cluster__c = 'Segnalazioni', Order__c = ord.Id, AccountId = ord.AccountId );
                        sObjectsToInsert.add(caso);
                    }
                }
            }
            when 'DL116_20'{
                Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();

                for(SObject s : senders){
                    if(s instanceof Order){
                        Order ord = (Order) s;
                        Case caso = new Case(RecordTypeId = recordTypeId, Type='Segnalazioni Ambientali', OperationGroup__c = 'DLGS_116/2020-IUAS0003', TypeOperation__c = 'CONSEGNA/RITIRO TUTTI I CONTEN', Material__c = 'Nessun materiale', Note__c = 'Uscita dal servizio. Del 116', Phase__c = 'Da Inviare', Status='In Lavorazione', Cluster__c = 'Segnalazioni', Order__c = ord.Id, AccountId = ord.AccountId );
                        sObjectsToInsert.add(caso);
                    }
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
            sObjectsToInsert.clear();
        }
    }

}