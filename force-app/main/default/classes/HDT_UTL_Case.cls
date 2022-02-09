/*
* @Author: Salvatore A. Sarà 20/10/2021
* Risoluzione "Debug Should Use Logging Level"
* Risoluzione "Avoid debug statements since they impact on performance"
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_Case {

    private static HDT_QR_AccountContactRelation accountContactRelationQr = new HDT_QR_AccountContactRelation();

    @InvocableMethod(label='Predefault')
    public static List<HDT_UTL_FlowOutputs> caseFlowPredefaults(List<HDT_UTL_FlowInputs> inputs){

        HDT_QR_Case caseQr = new HDT_QR_Case();

        List<HDT_UTL_FlowOutputs> outputs = new List<HDT_UTL_FlowOutputs>();
        List<Case> childCases = new List<Case>();
        HDT_UTL_FlowOutputs output = new HDT_UTL_FlowOutputs();

        String cluster = inputs[0].cluster;
        String process = inputs[0].process;
        Date effectiveDate = inputs[0].effectiveDate;
        String implantType = inputs[0].implantType;
        Decimal powerRequested = inputs[0].powerRequested;
        String salesCompany = inputs[0].salesCompany;
        Case currentCase = inputs[0].currentCase;
        String cancellationNote = inputs[0].cancellationNote;
        

        if(process == 'Voltura Tecnica'){

            if(effectiveDate != null){
                effectiveDate = addBusinessDay(effectiveDate, 3);
            }else{
                effectiveDate = addBusinessDay(System.today(), 3);
            }

            output.effectiveDate = effectiveDate;
        
        } else if(cluster == 'Preventivi'){
            output.option = calculateOption(implantType, powerRequested);
            output.salesCompanyCode = calculateSalesCompanyCode(salesCompany);
        } 
        else if(process.equalsIgnoreCase('Compatibilita'))
        {
            try 
            {
                output.isCompatible = HDT_UTL_MatrixCompatibility.checkCompatibilityPostSales(currentCase);   
            } 
            catch (Exception e) 
            {   
                output.isCompatible = '';
                System.debug(LoggingLevel.DEBUG,'Exception: ' + e.getMessage() + '. At line: ' + e.getLineNumber());    
            }
            
        }
        else if(process.equalsIgnoreCase('Contenitore'))
        {
            output.childCases = caseQr.getChildCasesReclamo(currentCase.Note__c, currentCase.Id);
        }
        else if(process.equalsIgnoreCase('Annullamento'))
        {
            Datetime nowDate = Datetime.now();
            String nowDateFormat = nowDate.format('dd/MM/yyyy h:mm a');
            output.cancellationNote = nowDateFormat + ': ' + cancellationNote;
            
        }
        else if(process.equalsIgnoreCase('CreaBpCa')){
            System.enqueueJob(new HDT_QBL_BpCaRequest( accountContactRelationQr.getCreateBpCa( currentCase.AccountId ), currentCase.SupplyProvince__c ) );
        }

        outputs.add(output);

        return outputs;


    }

    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String cluster;
        @InvocableVariable
        public String process;
        @InvocableVariable
        public Date effectiveDate;
        @InvocableVariable
        public String implantType;
        @InvocableVariable
        public Decimal powerRequested;
        @InvocableVariable
        public String salesCompany;
        @InvocableVariable
        public Case currentCase;
        @InvocableVariable
        public String cancellationNote;


    }

    public class HDT_UTL_FlowOutputs{

        @InvocableVariable
        public Date effectiveDate;
        @InvocableVariable
        public String option;
        @InvocableVariable
        public String salesCompanyCode;
        @InvocableVariable
        public String isCompatible;
        @InvocableVariable
        public List<Case> childCases;
        @InvocableVariable
        public String cancellationNote;

    }

    public static Date addBusinessDay(Date startDate, Integer businessDayToAdd){

        Date finalDate = startDate;

        Integer direction = businessDayToAdd < 0 ? -1 : 1;

        while(businessDayToAdd != 0){

            finalDate = finalDate.addDays(direction);
            
            if(!isWeekend(finalDate)){

                businessDayToAdd -= direction;
            
            }

        }

        return finalDate;

    }

    public static Boolean isWeekend(Date myDate){

        String myDateString = Datetime.newInstance(myDate.year(), myDate.month(),myDate.day()).format('EEE');

        return 'Sat'.equals(myDateString) || 'Sun'.equals(myDateString);

    }

    public static String calculateOption(String implantType, Decimal powerRequested){
        String result = '';

        switch on implantType {
            when '13A0-Usi di Abitazione BT' {
                result = 'Domestici-TD';
            }
            when '13BB-Illuminazione pubblica BT' {
                result = 'AEEG Opzione BTIP-E_BTIP';
            }
            when '13CB-Non domestici in BT'{

                if(powerRequested > 0 && powerRequested <= 1.5) {
                    result = 'AEEG Opz BTA1 <= 1,5 kW-E_BTA1';
                } else if(powerRequested > 1.5 && powerRequested <= 3) {
                    result = 'AEEG Op BTA2 >1,5<=3 kW-E_BTA2';
                } else if(powerRequested > 3 && powerRequested <= 6) {
                    result = 'AEEG Op BTA3 >3 <=6 kW-E_BTA3';
                } else if(powerRequested > 6 && powerRequested <= 10) {
                    result = 'AEEG Op BTA4 >6 <=10 kW-E_BTA4';
                } else if(powerRequested > 10 && powerRequested <= 16.5) {
                     result = 'AEEG Op BTA5 > 10 kW-E_BTA5';
                } else if(powerRequested > 16.5) {
                    result = 'AEEG Op BTA6 olt 16,5kW-E_BTA6';
                } else {
                    result = '';
                }

            }
            when '13EM-Non domestici MT' {
                if(powerRequested > 0 && powerRequested <= 100) {
                    result = 'AEEG Opz MTA1 fin 100kW-E_MTA1';
                } else if(powerRequested > 100 && powerRequested <= 500) {
                    result = 'AEEG Op MTA2 >100 <=500-E_MTA2';
                } else if(powerRequested > 500) {
                    result = 'AEEG Op MTA3 olt 500kW-E_MTA3';
                } else {
                    result = '';
                }
            }
            when '13DM-Illuminazione pubblica MT' {
                result = 'AEEG Opzione MTIP-E_MTIP';
            }
            when '13FM-Non domestici AT' {
                result = 'AEEG Op ALTA fin 220 kV-E_ALTA';
            }when else{
                result = '';
            }
        }

        return result;
    }


    public static string calculateSalesCompanyCode(String salesCompany){

        String result = '';

        if(salesCompany != null){
            switch on salesCompany{
                when 'HC'{

                    result = '13V0000000';

                }
                when 'HCM'{

                    result = '10V0000160';

                }
                when else{
                    result = '13V0000000';
                }
            }
        }

        return result;

    }

    /**
     * Crea una Activity PClick sotto un Case.
     * recordId = id del Case
     * description = testo libero da mostrare nell'activity
     * templateName = nome del template PClick dell'activity da creare
     * type = tipo attività
     */ 
    public static void createActivity(String recordId, String description, String templateName, String type){
        String queryString = 'Select id,wrts_prcgvr__Assignees__c, wrts_prcgvr__Subject__c, wrts_prcgvr__DueDateField__c,Name from wrts_prcgvr__ActivityTemplate__c  where Name = \''+ templateName +'\'';
        String objectName = 'wrts_prcgvr__ActivityTemplate__c';
        List<SObject> listRecord = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        wrts_prcgvr__ActivityTemplate__c template = new wrts_prcgvr__ActivityTemplate__c();
        if(listRecord.size()>0){
            template = (wrts_prcgvr__ActivityTemplate__c) listRecord[0];
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.wrts_prcgvr__ActivityTemplate__c = template.Id;
            activity.Case__c = recordId;
            activity.CausalError__c = description;
            activity.wrts_prcgvr__Description__c = description;
            activity.Type__c = type;
            HDT_UTL_DatabaseService.insertSObject(activity);
        }
    }



}