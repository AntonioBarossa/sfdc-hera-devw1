public with sharing class HDT_UTL_GarbageMan {

    public final Map<String, String> DESCRIZIONE_ESITI = new Map<String, String> {
        '01' => 'StreetCode, Comune, Indirizzo, Civico non valorizzati',
        '02' => 'CodiceFiscale e NominativoContatto entrambi non valorizzati',
        '03' => 'Indirizzo non trovato',
        '04' => 'Nessuna data disponibile in fase di Richiesta appuntamento',
        '05' => 'Errore in fase di Creazione RDS',
        '06' => 'Errore in fase di Richiesta appuntamento',
        '07' => 'Errore in fase di Conferma appuntamento',
        '08' => 'Errore in fase di Invio RDS verso SAP',
        '99' => 'Errore generico'
    };

    public List<wrts_prcgvr__PhaseTransition__c> getPhaseTransition(String templateName, Id recordTypeId){
        return  [   
                    SELECT Id 
                    FROM wrts_prcgvr__PhaseTransition__c 
                    WHERE wrts_prcgvr__CalloutTemplate__c =:templateName
                    AND wrts_prcgvr__RecordTypeId__c = :recordTypeId
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
    }

    public void launchCalloutTemplateSync(Id sobjId, Id transitionId){
        //Select all fields from a Sobject START
        Schema.DescribeSObjectResult descSobj = ((Id) sobjId).getSobjectType().getDescribe();

        Map<String, Schema.SObjectField> mapFields = descSobj.fields.getMap();
        String queryStatement = 'SELECT '+STRING.join(new List<String>(mapFields.keySet()), ', ')+ ' FROM '+descSobj.getName()+ ' WHERE Id=:sobjId LIMIT 1';
        //system.debug(queryStatement);
        List<Sobject> sobjs = Database.Query(STRING.escapeSingleQuotes(queryStatement));

        //Select All Fields From a Sobject END


        String transQuery = 'SELECT '+ STRING.join(new List<String>(Schema.SObjectType.wrts_prcgvr__PhaseTransition__c.fields.getMap().keySet()), ', ') + ' FROM wrts_prcgvr__PhaseTransition__c WHERE Id=:transitionId LIMIT 1';

        wrts_prcgvr__PhaseTransition__c transition = Database.Query(String.escapeSingleQuotes(transQuery));
        Matcher matcher=Pattern.compile('^(.+)\\(method="(.+)"\\);').matcher(transition.wrts_prcgvr__ApexCalloutActions__c);
        String className = matcher.find()? matcher.group(1) : null;
        if(STRING.isBlank(className))   throw new HDT_UTL_HeraException('Error class not found');

        String method =  matcher.group(2);

        wrts_prcgvr.Interfaces_1_0.IApexCalloutAction callout = (wrts_prcgvr.Interfaces_1_0.IApexCalloutAction) Type.forName(className).newInstance();

        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('sender', sobjs[0]);
        argsMap.put('transition', transition);
        argsMap.put('method', method);
        argsMap.put('parameters', new Map<String,String>());

        callout.execute(argsMap);
    }

    public List<Case> getCurrentCase(Id caseId){
        return [  
                    SELECT Id, WasterCode__c, StartAppointment__c, 
                    EndAppointment__c, RecordTypeId, Outcome__c,
                    Phase__c, Status, InvoicingStreetName__c, 
                    InvoicingStreetNumber__c, InvoicingPostalCode__c, InvoicingCity__c, 
                    InvoicingStreetCode__c, TypeOperation__c
                    FROM Case
                    WHERE Id =: caseId 
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
    }
}
