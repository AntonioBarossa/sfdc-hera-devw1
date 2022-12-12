public with sharing class HDT_UTL_DataEnrichmentPostSales {

    /**
     * Gestisce la response dell'arricchimento dati scrivendo i valori su currentCase.
     */
    public static Case handleResponse(String serializedResponse, Case currentCase){
        Set<String> dataEnrichmentFields = new Set<String>();
        return handleResponse(serializedResponse, currentCase, dataEnrichmentFields);
    }

    /**
     * Gestisce la response dell'arricchimento dati scrivendo i valori su currentCase e restituendo la lista dei campi valorizzati in dataEnrichmentFields.
     */

     /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    * Risoluzione "Local variable is declared and-or assigned but not used"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static Case handleResponse(String serializedResponse, Case currentCase, Set<String> dataEnrichmentFields){
        HDT_QR_DataEnrichmentPostSales depsQr = new HDT_QR_DataEnrichmentPostSales();
        HDT_SRV_DataEnrichmentPostSales depsSrv = new HDT_SRV_DataEnrichmentPostSales();
        HDT_QR_AnagAlignment anagAlignQr = new HDT_QR_AnagAlignment();
        List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject> positions = new List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject>();
        List<HDT_DataEnrichmentTransocode__mdt> transcodeConfigList = new List<HDT_DataEnrichmentTransocode__mdt>();
        Map<String, Object> transcodeMap = new Map<String, Object>();
        String billingProfileCode;
        String billingProfilesfdcField;
        String billingProfileId;
        String contractSapCode;
        String contractSfdcField;
        String contractId;
        String modInvioBolletta;
        String pecBolletta;
        String emailBolletta;
        String deliveryAddress;
        String salesCompanyCode;
        String salesCompany;
        String method;
        String sottoTipologiaDuso;
        /*
			@Author: Davide Viola - 20/10/2021
			Description: PMD -> Commentata variabile non utilizzata.
		*/
        Decimal decValue;
        HDT_WS_ArrichmentDataEntityResponse resp= (HDT_WS_ArrichmentDataEntityResponse) JSON.deserialize(serializedResponse, HDT_WS_ArrichmentDataEntityResponse.class);
        positions = resp.data.posizioni;
        transcodeConfigList = depsQr.getTranscodeConfig();
        for(HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject position : positions){
            for(HDT_DataEnrichmentTransocode__mdt transcodeConfig : transcodeConfigList){
               if(position.campo == transcodeConfig.SapField__c){
                    if(transcodeConfig.IsNumber__c){
                        if(transcodeConfig.Precision__c == 0){
                            try{
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                Integer.valueOf(Decimal.valueOf(position.valore)));
                            }catch(Exception e){
                                System.debug(LoggingLevel.DEBUG, e.getMessage());
                            }
                        }else if(transcodeConfig.Precision__c > 0){
                            try{
                                decValue = Decimal.valueOf(position.valore);
                                transcodeMap.put(transcodeConfig.SfdcField__c, 
                                decValue.setScale(Integer.valueOf(transcodeConfig.Precision__c)));
                            }catch(Exception e){
                                System.debug(LoggingLevel.DEBUG, e.getMessage());
                            }
                        }
                    } else if(transcodeConfig.IsTranscode__c){
                        method = transcodeConfig.Method__c;                        
                        switch on method{
                            when 'getPicklistValue'{
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                depsSrv.getPicklistValue('Case', transcodeConfig.SfdcField__c, position.valore));
                            }
                            when 'getBoolFromString'{
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                depsSrv.getBoolFromString(position.valore));
                            }
                            when 'getDateByYear'{
                                transcodeMap.put(transcodeConfig.SfdcField__c, 
                                depsSrv.getDateByYear(position.valore));
                            }
                            when 'getBillingProfileIdBySapCode'{
                                billingProfilesfdcField = transcodeConfig.SfdcField__c;
                                billingProfileCode = position.valore;
                            }
                            when 'getContractIdBySapCode'{
                                contractSfdcField = transcodeConfig.SfdcField__c;
                                String caseContractLookup = (String) currentCase.get(contractSfdcField);
                                // Transcodifichiamo solo se il Case non ha già un contratto, altrimenti facciamo una query inutile sul Contract.
                                if (String.isBlank(caseContractLookup)){
                                    contractSapCode = position.valore;
                                }
                            }
                            when 'getCaliber'{
                                transcodeMap.put(transcodeConfig.SfdcField__c, 
                                depsSrv.getCaliber(position.valore));
                            }
                            when 'writeCollectiveBillType' {
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                depsSrv.writeCollectiveBillType(position.valore, currentCase));
                            }
                            when 'getOpzione'{
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                depsSrv.getOpzione(position.valore));
                            }
                            when 'getDateFromString'{
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                depsSrv.getDateFromString(position.valore));
                            }
                            when 'variationsBlock'{
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                depsSrv.variationsBlock(position.valore));
                            }
                            when 'writeBlockCode' {
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                depsSrv.writeBlockCode(position.valore, currentCase));
                            }
                            /*when 'transCodeDoubleOppositeToDecimal' {
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                depsSrv.transCodeDoubleOppositeToDecimal(position.valore));
                            }*/
                            when 'transCodeSiNo' {
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                depsSrv.transCodeSiNo(position.valore));
                            }
                            when 'transCodeDoubleToString' {
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                depsSrv.transCodeDoubleToString(position.valore));
                            }
                            when 'alignGaaDate' {
                                Date dataGaa = depsSrv.alignGaaDate(String.valueOf(transcodeMap.get('DataUltimoAllineamentoGAA__c')), position.valore);
                                transcodeMap.put(transcodeConfig.SfdcField__c, dataGaa);
                            }
                            when 'transCodeSiNoConDescr' {
                                transcodeMap.put(transcodeConfig.SfdcField__c, depsSrv.transCodeSiNoConDescr(position.valore));
                            }
                            when 'transcodificaInfoDepurazione' {
                                transcodeMap.put(transcodeConfig.SfdcField__c, depsSrv.transcodificaInfoDepurazione(position.valore));
                            }
                            
                        }
                    } else {
                        transcodeMap.put(transcodeConfig.SfdcField__c, position.valore);
                    }
                }
            }
        }

        if(String.isBlank(String.valueOf(transcodeMap.get('Market__c'))) && ('Acqua'.equalsIgnoreCase(currentCase.CommodityFormula__c) || 'Acqua'.equalsIgnoreCase(currentCase.Commodity__c))){
            transcodeMap.put('Market__c', 'Regolamentato');
        }

        //BILLING PROFILE 
        try{
            BillingProfile__c billingRecord = depsQr.getBillingProfileIdBySapCode(billingProfileCode);
            billingProfileId = billingRecord.Id;
            //deliveryAddress = depsSrv.getDeliveryAddress(billingProfileId);
            deliveryAddress = billingRecord.InvoicingAddressFormula__c;
            String viaRecapito = billingRecord.InvoicingStreetName__c != null? billingRecord.InvoicingStreetName__c :'';
            String civicoRecapito = billingRecord.InvoicingStreetNumber__c != null? billingRecord.InvoicingStreetNumber__c :'';
            String comuneRecapito = billingRecord.InvoicingCity__c != null? billingRecord.InvoicingCity__c :'';
            String capRecapito = billingRecord.InvoicingPostalCode__c != null? billingRecord.InvoicingPostalCode__c :'';
            String suffissoRecapito = billingRecord.InvoicingStreetNumberExtension__c != null? billingRecord.InvoicingStreetNumberExtension__c :'';
            String provinciaRecapito = billingRecord.InvoicingProvince__c != null? billingRecord.InvoicingProvince__c :'';
            String nazioneRecapito = billingRecord.InvoicingCountry__c != null? billingRecord.InvoicingCountry__c :'';
            nazioneRecapito = nazioneRecapito.length()>0?nazioneRecapito.substring(0,2):nazioneRecapito;
            String codiceUfficio = billingRecord.SubjectCode__c != null?billingRecord.SubjectCode__c:'';
            String tipoXml = billingRecord.XMLType__c != null?billingRecord.XMLType__c:'';
            String pecElettronica = billingRecord.ElectronicInvoiceCertifiedEmailAddress__c != null?billingRecord.ElectronicInvoiceCertifiedEmailAddress__c:'';
            String modInvioFatt = billingRecord.ElectronicInvoicingMethod__c != null?billingRecord.ElectronicInvoicingMethod__c:'';
            Date dataConsensoPEc = billingRecord.SendCertifiedEmailConsentDate__c;
            modInvioBolletta = billingRecord.BillSendingMethod__c;
            pecBolletta = billingRecord.InvoiceCertifiedEmailAddress__c;
            emailBolletta = billingRecord.InvoiceEmailAddress__c;
            
            transcodeMap.put('BillSendingMethod__c', modInvioBolletta);
            transcodeMap.put('InvoiceEmail__c', emailBolletta);
            transcodeMap.put('InvoiceCertifiedEmailAddress__c', pecBolletta);
            transcodeMap.put(billingProfilesfdcField, billingProfileId);
            transcodeMap.put('InvoicingPostalCode__c', capRecapito);
            transcodeMap.put('InvoicingProvince__c', provinciaRecapito);
            transcodeMap.put('DeliveryAddress__c', deliveryAddress);
            transcodeMap.put('InvoicingStreetNumber__c', civicoRecapito);
            transcodeMap.put('InvoicingCity__c', comuneRecapito);
            transcodeMap.put('InvoicingStreetNumberExtension__c', suffissoRecapito);
            transcodeMap.put('InvoicingStreetName__c', viaRecapito);
            transcodeMap.put('OfficeSubjectCode__c', codiceUfficio);
            transcodeMap.put('XMLType__c', tipoXml);
            transcodeMap.put('ElectronicInvoiceCertifiedEmailAddress__c', pecElettronica);
            transcodeMap.put('ElectronicInvoicingMethod__c', modInvioFatt);
            transcodeMap.put('SendCertifiedEmailConsentDate__c', dataConsensoPEc);
            transcodeMap.put('InvoicingCountry__c', nazioneRecapito);

        } catch(Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Billing Profile non presente a sistema');
        }

        //ServicePoint
        try{
            ServicePoint__c servicePoint = depsQr.getServicePointData(currentCase.ServicePoint__c);
            transcodeMap.put('SupplyType__c',ServicePoint.SupplyType__c);
            transcodeMap.put('Disconnectable__c',ServicePoint.Disconnectable__c);
            transcodeMap.put('DisconnectibilityType__c',ServicePoint.DisconnectibilityType__c);
        } catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Errore Ereditare campi SP -> ' + e.getMessage());
        }

        // Contract
        try{
            if (String.isNotBlank(contractSapCode)){
                Contract c = depsQr.getContractData(contractSapCode);
                contractId = c.Id;
                transcodeMap.put(contractSfdcField, contractId);
            }
        } catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'Errore Set Lookup Contract -> ' + e.getMessage());
        }
        //Accise & Addizionale Regionale
        String taxes = (String)transcodeMap.get('Taxes__c') != null ? (String)transcodeMap.get('Taxes__c') : '';
        if(String.isBlank(String.valueOf(transcodeMap.get('Excises__c'))) && String.isNotBlank(taxes))
        {
            List<HDT_ExciseTranscode__mdt> exciseTranscode = [SELECT Id, Excise__c FROM HDT_ExciseTranscode__mdt WHERE ExciseString__c = :taxes WITH SECURITY_ENFORCED];
            Double excises = !exciseTranscode.isEmpty() ? exciseTranscode[0].Excise__c : 0.0;
            transcodeMap.put('Excises__c', excises);
        }
        if(String.isBlank(String.valueOf(transcodeMap.get('RegionalAdditional__c'))) && String.isNotBlank(taxes))
        {
            Double regionalAdditional = anagAlignQr.findRegionalAdditional(taxes, (String)transcodeMap.get('SupplyCity__c'), '');
            transcodeMap.put('RegionalAdditional__c', regionalAdditional);
        }

        //SALESCOMPANY && SALESCOMPANYCODE
        salesCompanyCode = (String) transcodeMap.get('SalesCompanyCode__c');
        salesCompanyCode = String.isBlank(salesCompanyCode) && 'Acqua'.equalsIgnoreCase(currentCase.CommodityFormula__c) ? '11-HERASPA' : salesCompanyCode;
        salesCompanyCode = String.isBlank(salesCompanyCode) && 'Acqua'.equalsIgnoreCase(currentCase.Commodity__c) ? '11-HERASPA' : salesCompanyCode;
        salesCompanyCode = String.isBlank(salesCompanyCode) && 'Ambiente'.equalsIgnoreCase(currentCase.CommodityFormula__c) ? '1200000000' : salesCompanyCode;
        salesCompanyCode = String.isBlank(salesCompanyCode) && 'Ambiente'.equalsIgnoreCase(currentCase.Commodity__c) ? '1200000000' : salesCompanyCode;
        salesCompany = depsSrv.calculateSalesCompany(salesCompanyCode);
        
        transcodeMap.put('SalesCompany__c', salesCompany);
        transcodeMap.put('SalesCompanyCode__c', salesCompanyCode);

        //SOTTOTIPOLOGIA D'USO
        sottoTipologiaDuso = HDT_SRV_DataEnrichmentPostSales.handleSubType(salesCompany, (String) transcodeMap.get('RateCategory__c'));
        transcodeMap.put('UseSubCategory__c',sottoTipologiaDuso);
       
        dataEnrichmentFields.addAll(transcodeMap.keySet());
        return depsSrv.populateCase(transcodeMap, currentCase);
    }

    // Wrapper per i flow
    @InvocableMethod(label='Handle Response Data Enrichment')
    public static List<Case> handleResponseFlow(List<HDT_UTL_FlowInput> inputs){
        String serializedResponse = inputs[0].serializedResponse;
        Case currentCase = inputs[0].currentCase;
        
        List<Case> caseList = new List<Case>();
        caseList.add(handleResponse(serializedResponse, currentCase));
        return caseList;
    }

    public class HDT_UTL_FlowInput{

        @InvocableVariable
        public String serializedResponse;
        @InvocableVariable
        public Case currentCase;

    }


}