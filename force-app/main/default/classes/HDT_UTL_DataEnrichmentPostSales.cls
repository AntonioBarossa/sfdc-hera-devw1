public with sharing class HDT_UTL_DataEnrichmentPostSales {

   

    @InvocableMethod(label='Handle Response Data Enrichment')
    public static List<Case> handleResponse(List<HDT_UTL_FlowInput> inputs){

        HDT_QR_DataEnrichmentPostSales depsQr = new HDT_QR_DataEnrichmentPostSales();
        HDT_SRV_DataEnrichmentPostSales depsSrv = new HDT_SRV_DataEnrichmentPostSales();

        List<Case> caseList = new List<Case>();
        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> positions = new List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>();
        List<HDT_DataEnrichmentTransocode__mdt> transcodeConfigList = new List<HDT_DataEnrichmentTransocode__mdt>();
        
        Map<String, Object> transcodeMap = new Map<String, Object>();

        String serializedResponse = inputs[0].serializedResponse;
        Case currentCase = inputs[0].currentCase;
        
        String billingProfileCode;
        String billingProfilesfdcField;
        String billingProfileId;

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

                        }

                    } else {

                        transcodeMap.put(transcodeConfig.SfdcField__c, position.valore);

                    }

                }

            }


        }

        //BILLING PROFILE 
        try{

            billingProfileId = depsSrv.getBillingProfileIdBySapCode(billingProfileCode);
            deliveryAddress = depsSrv.getDeliveryAddress(billingProfileId);

            transcodeMap.put(billingProfilesfdcField, billingProfileId);

            transcodeMap.put('DeliveryAddress__c', deliveryAddress);

        } catch(Exception e) {

            System.debug('Billing Profile non presente a sistema');

        }

        //SALESCOMPANY
        salesCompanyCode = (String) transcodeMap.get('SalesCompanyCode__c');
        salesCompany = depsSrv.calculateSalesCompany(salesCompanyCode);

        transcodeMap.put('SalesCompany__c', salesCompany);


        caseList.add(depsSrv.populateCase(transcodeMap, currentCase));

        return caseList;


    }


    public class HDT_UTL_FlowInput{

        @InvocableVariable
        public String serializedResponse;
        @InvocableVariable
        public Case currentCase;

    }


}