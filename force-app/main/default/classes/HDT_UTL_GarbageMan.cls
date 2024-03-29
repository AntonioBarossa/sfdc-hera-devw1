@SuppressWarnings('PMD.AvoidDebugStatements, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces')
public with sharing class HDT_UTL_GarbageMan {

    private static final Pattern PATTERN_DATA = Pattern.compile('(\\d+)-(\\d+)-(\\d+)\\s+(\\d+):(\\d+):(\\d+)');

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

    public Object launchCalloutTemplateSync(Id sobjId, Id transitionId){
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

        return callout.execute(argsMap);
    }

    public String getCompanyOwnerFromCityData(String comune){
        String companyOwner;
        List<CityTechnicalData__c> tecs = 
        [
            SELECT CompanyOwner__c 
            FROM CityTechnicalData__c 
            WHERE Name =:comune
            WITH SECURITY_ENFORCED
        ];
        if(!tecs.isEmpty()) companyOwner = tecs[0].CompanyOwner__c;
        return companyOwner;
    }


    public List<Case> getCurrentCase(Id caseId){
        return [  
                    SELECT Id, WasterCode__c, StartAppointment__c, 
                    EndAppointment__c, RecordTypeId,
                    Phase__c, Status, InvoicingStreetName__c, 
                    InvoicingStreetNumber__c, InvoicingPostalCode__c, InvoicingCity__c, 
                    WithdrawalFee__c, ServicePoint__c,CaseNumber,
                    Outcome__c, CreatedDate, AccountCode__c,
                    SupplyPostalCode__c, SupplyStreetName__c,
                    SupplyStreetNumber__c, SupplyStreetCode__c,
                    InvoicingStreetCode__c, TypeOperation__c
                    FROM Case
                    WHERE Id =: caseId 
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
    }

    public List<AccountContactRelation> getContactRelation(Id accountId){
        if(accountId==null) return new List<AccountContactRelation>();
        return  
        [
            SELECT 
                Id, ContactId,
                Contact.Email, Contact.MobilePhone
            FROM AccountContactRelation 
            WHERE 
                AccountId =:accountId
                AND IsDirect = true
                AND IsActive = true
                AND Roles IN ('Legale rappresentante', 'Titolare')
            WITH SECURITY_ENFORCED 
            LIMIT 1
        ];

    }

    public Case initCase(Account account){
        Case theCase = new Case();
        theCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();
        theCase.Cluster__c = 'Segnalazioni';
        theCase.Type = 'Gestione Rifiuti';
        theCase.OperationGroup__c = 'CONSULTA IL RIFIUTOLOGO';
        theCase.Origin = 'Rifiutologo';
        theCase.Commodity__c = 'Ambiente';
        theCase.Phase__c = 'In Attesa Appuntamento';
        theCase.Status = 'In Lavorazione';

        List<AccountContactRelation> accContactRels = getContactRelation(account?.Id);
        if(!accContactRels.isEmpty()){
            AccountContactRelation accContactRel = accContactRels[0];
            theCase.AccountId = account.Id;
            theCase.CompanyOwner__c = account.CompanyOwner__c;
            theCase.ContactId = accContactRel.ContactId;
            theCase.SuppliedEmail = accContactRel.Contact.Email;
            theCase.SuppliedPhone = accContactRel.Contact.MobilePhone;
            theCase.BillingCity__c = account.BillingPlace__c;
        }
        
        return theCase;
    }

    public String outputDateEsito(Datetime d){
        if(d==null) return '';
        return d.format('YYYY-MM-dd hh:mm:ss');
    }

    public DateTime formatDate(String dateToFormat){
        Matcher matcher = PATTERN_DATA.matcher(dateToFormat);
        if(!matcher.find()){
            throw new HDT_UTL_HeraException('Error on Regex To Format Dates');
        }
        return DateTime.newInstance(
                Integer.valueOf(matcher.group(3)), 
                Integer.valueOf(matcher.group(2)), 
                Integer.valueOf(matcher.group(1)), 
                Integer.valueOf(matcher.group(4)), 
                Integer.valueOf(matcher.group(5)), 
                Integer.valueOf(matcher.group(6))
        );
    }
}
