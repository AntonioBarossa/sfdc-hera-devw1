/*
* @Author: Salvatore A. Sarà 20/10/2021
* Risoluzione "Debug Should Use Logging Level"
* Risoluzione "Avoid debug statements since they impact on performance"
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_UTL_Case {

    private static HDT_QR_AccountContactRelation accountContactRelationQr = new HDT_QR_AccountContactRelation();

    @InvocableMethod(label='HDT_UTL_Case caseFlowPredefaults')
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
        String inputString = inputs[0].genericInputString;

        if('Voltura Tecnica'.equalsIgnoreCase(process)){
            effectiveDate = addBusinessDay(System.today(), 3);
            output.effectiveDate = effectiveDate;    
        } else if('Preventivi'.equalsIgnoreCase(cluster)){
            output.option = calculateOption(implantType, powerRequested);
            if(currentCase.Type.equalsIgnoreCase('Nuovo Impianto') || currentCase.Type.equalsIgnoreCase('Aggiunta Attacco'))
            {
                Case currCase=caseQr.getRecordById(currentCase.Id);
                HDT_UTL_CalculateTransition calculateTransition = new HDT_UTL_CalculateTransition(currentCase.SupplyCity__c, currentCase.Commodity__c, currCase.Distributor__r.Code__c);
                Map<String,Object> companyInfosMap = new Map<String,Object>();
                companyInfosMap = calculateTransition.calculateCompanyInfos();
                City__c city = (City__c)companyInfosMap.get('cityObj');


                List<AtecoMatrix__c> atecoMatrixList = [SELECT AtecoCode__c, City__c FROM AtecoMatrix__c WHERE City__c =: currentCase.SupplyCity__c WITH SECURITY_ENFORCED LIMIT 1];

                if(!atecoMatrixList.isEmpty()){
                    output.atecoCode = atecoMatrixList[0].AtecoCode__c;
                }
                
                // output.salesCompanyCode = calculateSalesCompanyCode(salesCompany);
                if(String.isNotBlank(currentCase.Commodity__c) && 'Acqua'.equalsIgnoreCase(currentCase.Commodity__c)){
                    output.salesCompanyCode = '11-HERASPA';
                    output.salesCompany = 'Hera Comm S.p.A';
                }else {
                    switch on city.SDV__c {
                        when 'HCM' {
                            output.salesCompanyCode = '10V0000160';
                            output.salesCompany = 'Hera Comm Marche';
                        }
                        when 'HC' {
                            output.salesCompanyCode = '13V0000000';
                            output.salesCompany = 'Hera Comm S.p.A.';
                        }
                        when 'EENE'{
                            if(currentCase.Commodity__c!= null && currentCase.Commodity__c.equalsIgnoreCase('Energia Elettrica')){
                                output.salesCompanyCode = '13V0000170';
                            }else {
                                output.salesCompanyCode = '10V0000263';
                            }
                            output.salesCompany = 'ESTENERGY SPA';
                        }
                        when else {
                            output.salesCompanyCode = (String)companyInfosMap.get('SalesCompanyCode');
                            //output.salesCompany = city.SDV__c;
                            output.salesCompany=(String)companyInfosMap.get('SalesCompany');
                        }
                    }
                }
            }
        } 
        else if('Compatibilita'.equalsIgnoreCase(process))
        {
            try 
            {
                output.isCompatible = HDT_UTL_MatrixCompatibility.checkCompatibilityPostSales(currentCase);   
            } 
            catch (Exception e) 
            {   
                output.isCompatible = e.getMessage();
                System.debug(LoggingLevel.DEBUG,'Exception: ' + e.getMessage() + '. At line: ' + e.getLineNumber());    
            }
            
        }
        else if('Contenitore'.equalsIgnoreCase(process)){
            output.childCases = caseQr.getChildCasesReclamo(currentCase.Note__c, currentCase.Id);
        }
        else if('Annullamento'.equalsIgnoreCase(process)){
            Datetime nowDate = Datetime.now();
            String nowDateFormat = nowDate.format('dd/MM/yyyy h:mm a');
            output.cancellationNote = nowDateFormat + ': ' + cancellationNote;
            output.cancellationNote = output.cancellationNote.length() > 255 ? output.cancellationNote.substring(0, 255) : output.cancellationNote; 
        }
        else if('CreaBpCa'.equalsIgnoreCase(process)){
            System.enqueueJob(new HDT_QBL_BpCaRequest( accountContactRelationQr.getCreateBpCa( currentCase.AccountId ), currentCase.SupplyProvince__c, true ) );
        }
        else if('CheckIsCommunity'.equalsIgnoreCase(process)){
            output.isCommunity = HDT_LC_SellingWizardController.checkCommunityLogin();
        }
        else if('getServicePointFromContract'.equalsIgnoreCase(process)){
            List<String> contractCodes = inputString.split(';');
            System.debug(loggingLevel.DEBUG, contractCodes);
            List<Contract> contractList = [SELECT ServicePoint__c FROM Contract WHERE SAPContractCode__c IN :contractCodes WITH SECURITY_ENFORCED];
            output.servicePointId = new List<String>();
            for(Contract contr : contractList){
                if(!output.servicePointId.contains(contr.ServicePoint__c)){
                    output.servicePointId.add(contr.ServicePoint__c);
                }
            }
            output.count = output.servicePointId.size();
        }
        else if('RemoveFacilityBundle'.equalsIgnoreCase(process)){
            boolean result = true;
            List<OrderItem> items = new HDT_QR_OrderItem().getItemsFromQuote(inputs[0].quoteId);
            for(OrderItem item : items){
                if(item.SBQQ__OrderedQuantity__c>0){result=false;break;}
            }
            result&=items.isEmpty();
            output.isCompatible = result? '' : 'NO';
        }else if ('Adesione Rinuncia Fondo Fughe'.equalsIgnoreCase(currentCase.Type)){     
            // Logica valorizzazione della data inizio variazione BBP w2 v4.0 pag 607
            List<Case> caseRetrieved = [SELECT Contract__r.StartDate FROM Case WHERE Id =: currentCase.Id WITH SECURITY_ENFORCED LIMIT 1];
            Date contractStartDate = (caseRetrieved.size() > 0) ? caseRetrieved[0]?.Contract__r?.StartDate : null;

            currentCase.ResidenceChangeDate__c = (contractStartDate != null && 
                                                'Rinuncia Fondo Fughe'.equals(currentCase.Subprocess__c) && 
                                                contractStartDate.addDays(365) < Date.today()) ? 
                                                contractStartDate : Date.today();
            output.currentCase = currentCase;
        }else if ('Modifica Unita Immobiliari Componenti'.equalsIgnoreCase(process)){

            Case newCurrentCase = [SELECT SupplyCity__c, RateCategory__c FROM Case WHERE Id =: currentCase.Id WITH SECURITY_ENFORCED];
            List<AllineamentoGAA__c> listAllineamentoGaa = [SELECT Frequenza__c FROM AllineamentoGAA__c WHERE Comune__c =: newCurrentCase.SupplyCity__c AND Rate_Category__c =: newCurrentCase.RateCategory__c WITH SECURITY_ENFORCED];

            if(listAllineamentoGaa.size() > 0){
                output.allineamentoGaa = 'Y';
                System.debug(LoggingLevel.DEBUG, 'Frequenza__c: ' + listAllineamentoGaa.get(0).Frequenza__c);
                output.frequenzaAllineamentoGaa = listAllineamentoGaa.get(0).Frequenza__c;
            }else{
                output.allineamentoGaa = 'N';
            }
        }
        else if('Reclami'.equalsIgnoreCase(cluster) && 'calculateExpirationDate'.equalsIgnoreCase(process)){
            HDT_UTL_Reclami utlReclami = new HDT_UTL_Reclami();
            Map<String,String> datesNamount = utlReclami.setExpirationDate(currentCase, salesCompany);
            //output.effectiveDate
            if( datesNamount.containsKey('EndDate__c') ){
                output.endDate = date.valueOf(datesNamount.get('EndDate__c'));
            }
            if( datesNamount.containsKey('CompletedDocumentationDate__c') ){
                output.completedDocumentationDate = date.valueOf(datesNamount.get('CompletedDocumentationDate__c'));
            }
            if( datesNamount.containsKey('DepositExpirationDate__c') ){
                output.depositExpirationDate = date.valueOf(datesNamount.get('DepositExpirationDate__c'));
            }
            if( datesNamount.containsKey('AmountToPayInInstallments__c') ){
                output.amountToPayInInstallments = decimal.valueOf(datesNamount.get('AmountToPayInInstallments__c'));
            }
            if( datesNamount.containsKey('DepositAmount__c') ){
                output.depositAmount = decimal.valueOf(datesNamount.get('DepositAmount__c'));
            }
        }else if ('Esenzione Modifica Fognatura Depurazione'.equalsIgnoreCase(process) && 'Modifica Fognatura e Depurazione'.equals(currentCase.Subprocess__c)){
            List<Case> caseRetrieved = [SELECT Contract__r.StartDate, CustomerRequestDate__c FROM Case WHERE Id =: currentCase.Id WITH SECURITY_ENFORCED LIMIT 1];
            Date contractStartDate = (caseRetrieved.size() > 0) ? caseRetrieved[0]?.Contract__r?.StartDate : null;

            if (contractStartDate != null && (contractStartDate.daysBetween(Date.today()) / 365) > 5){
                contractStartDate = date.newinstance(caseRetrieved[0].CustomerRequestDate__c.year(), caseRetrieved[0].CustomerRequestDate__c.month(), caseRetrieved[0].CustomerRequestDate__c.day());
            }
            
            currentCase.EffectiveDate__c = contractStartDate;
            output.currentCase = currentCase;
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
        @InvocableVariable
        public String genericInputString;
        @InvocableVariable
        public String quoteId;
    }

    public class HDT_UTL_FlowOutputs{
        @InvocableVariable
        public Date endDate;
        @InvocableVariable
        public Date completedDocumentationDate;
        @InvocableVariable
        public Date depositExpirationDate;
        @InvocableVariable
        public Decimal amountToPayInInstallments;
        @InvocableVariable
        public Decimal depositAmount;
        @InvocableVariable
        public Date effectiveDate;
        @InvocableVariable
        public String option;
        @InvocableVariable
        public String salesCompanyCode;
        @InvocableVariable
        public String salesCompany;
        @InvocableVariable
        public String isCompatible;
        @InvocableVariable
        public List<Case> childCases;
        @InvocableVariable
        public String cancellationNote;
        @InvocableVariable
        public Boolean isCommunity;
        @InvocableVariable
        public String atecoCode;
        @InvocableVariable
        public List<String> servicePointId;
        @InvocableVariable
        public Integer count;
        @InvocableVariable
        public Date dataInizioVariazione;
        @InvocableVariable
        public String allineamentoGaa;
        @InvocableVariable
        public String frequenzaAllineamentoGaa;
        @InvocableVariable
        public String isDomestico;
        @InvocableVariable
        public Case currentCase;
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

    public static List<ServiceRequest__c> createServiceRequestFromCases(List<Case> caseList)
    {
        List<ServiceRequest__c> serviceRequestList = new List<ServiceRequest__c>();
        String processType = 'Allineamento anagrafica';
        String status = 'Bozza';
        String type = 'Case';
        for(Case singleCase : caseList)
        {
            ServiceRequest__c srRequest = new ServiceRequest__c();
            srRequest.Case__c = singleCase.Id;
            srRequest.CommoditySector__c = singleCase.CommodityFormula__c;
            srRequest.ProcessType__c = processType;
            srRequest.ServicePointCode__c = singleCase.PODPDRFormula__c;
            srRequest.ServicePoint__c = singleCase.ServicePoint__c;
            srRequest.Status__c = status;
            srRequest.Type__c = type;
            serviceRequestList.add(srRequest);
        }
        return serviceRequestList;
    }
}