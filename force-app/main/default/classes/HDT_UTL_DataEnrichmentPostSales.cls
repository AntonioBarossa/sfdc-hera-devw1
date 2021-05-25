public with sharing class HDT_UTL_DataEnrichmentPostSales {

    public static Case handleResponse(String serializedResponse, Case currentCase){
        HDT_QR_DataEnrichmentPostSales depsQr = new HDT_QR_DataEnrichmentPostSales();
        HDT_SRV_DataEnrichmentPostSales depsSrv = new HDT_SRV_DataEnrichmentPostSales();
        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> positions = new List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>();
        List<HDT_DataEnrichmentTransocode__mdt> transcodeConfigList = new List<HDT_DataEnrichmentTransocode__mdt>();
        Map<String, Object> transcodeMap = new Map<String, Object>();
        String billingProfileCode;
        String billingProfilesfdcField;
        String billingProfileId;
        String modInvioBolletta;
        String pecBolletta;
        String emailBolletta;
        String deliveryAddress;
        String salesCompanyCode;
        String salesCompany;
        String method;
        String value;
        Decimal decValue;

        positions = (List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>)
            JSON.deserialize(serializedResponse, List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>.class);

        transcodeConfigList = depsQr.getTranscodeConfig();

        for(HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni position : positions){
            for(HDT_DataEnrichmentTransocode__mdt transcodeConfig : transcodeConfigList){
                if(position.campo == transcodeConfig.SapField__c){
                    if(transcodeConfig.IsNumber__c){
                        if(transcodeConfig.Precision__c == 0){
                            try{
                                transcodeMap.put(transcodeConfig.SfdcField__c,
                                Integer.valueOf(position.valore));
                            }catch(Exception e){
                                System.debug(e.getMessage());
                            }
                        }else if(transcodeConfig.Precision__c > 0){
                            try{
                                decValue = Decimal.valueOf(position.valore);
                                transcodeMap.put(transcodeConfig.SfdcField__c, 
                                decValue.setScale(Integer.valueOf(transcodeConfig.Precision__c)));
                            }catch(Exception e){
                                System.debug(e.getMessage());
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
                        }
                    } else {
                        transcodeMap.put(transcodeConfig.SfdcField__c, position.valore);
                    }
                }
            }
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

        } catch(Exception e) {
            System.debug('Billing Profile non presente a sistema');
        }

        //SALESCOMPANY
        salesCompanyCode = (String) transcodeMap.get('SalesCompanyCode__c');
        salesCompany = depsSrv.calculateSalesCompany(salesCompanyCode);
        transcodeMap.put('SalesCompany__c', salesCompany);

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