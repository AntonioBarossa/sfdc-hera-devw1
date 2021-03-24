public inherited sharing class HDT_LC_RecordEditFormFlowController {
    
    @AuraEnabled(cacheable=true)
    public static String getFields(String processType) {
        String userInputFlow;
        List<HDT_UserInputFlow__mdt> userInputFlowList = HDT_QR_RecordEditFormFlowController.queryInput(processType);
        /*List<HDT_UserInputFlow__mdt> userInputFlowList = [
            SELECT FieldsJSON__c, ValidateClass__c,ReadOnlyFields__c
            FROM HDT_UserInputFlow__mdt
            WHERE ProcessType__c =: processType
            LIMIT 1
        ];*/

        if(userInputFlowList.size() > 0 ){
            userInputFlow = JSON.serialize(userInputFlowList);
            
        }
        return userInputFlow;
    }

    @AuraEnabled(cacheable=true)
    public static String validateRecord(String validateClass, String fields, String recordId) {
        String result;
        System.debug('in class ' + fields);
        if(validateClass != null && String.isNotBlank(validateClass)){
            HDT_UTL_CaseValidationInterface support = HDT_UTL_CaseValidationFactory.getInstance(validateClass);
            result = support.validate(fields,recordId);
        }else{
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
        }
        return result;
    }

    @AuraEnabled
    public static List<ContentDocument> getContentDocs(Id arecordId)
    {   
        //List<ContentDocumentLink> cdLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId];
        List<ContentDocumentLink> cdLs = HDT_QR_RecordEditFormFlowController.queryCdLink(arecordId);
        if (cdLs.size() < 1) return new List<ContentDocument>(); 

        // Make a List of ContentDocument IDs
        List <Id> cdIdList = new List <Id> ();
        for (ContentDocumentLink nextCdl : cdLs) {
            cdIdList.add(nextCdl.ContentDocumentId); }        

        //List<ContentDocument> entries = [SELECT Id, Title, FileType,CreatedDate FROM ContentDocument WHERE ContentDocument.Id IN :cdIdList];
        return HDT_QR_RecordEditFormFlowController.queryCd(cdIdList);
    }

   /* @AuraEnabled(cacheable=true)
    public static String getOptions(String serviceClass, String params) {
        String result;
       System.debug('Params getOptions ' + params);
        if(serviceClass != null && String.isNotBlank(serviceClass)){
            HDT_UTL_ComboboxOptionsInterface support = HDT_UTL_ComboboxOptionsFactory.getInstance(serviceClass);
            result = support.getOptions(params);
        }
        return result;
    }


    @AuraEnabled
    public static String prePopulateFields(String recordId, String context){

        Case infoCase = new Case(Id = recordId);

        if(context instanceOf Id){

            Id contextId= (Id) Context;

            String sObjName = contextId.getSObjectType().getDescribe().getName();

            switch on sObjName{
                when 'Case'{

                    Case contextObj = (Case) HDT_QR_InformativeManager.getPrePopulationInfo(contextId, sObjName);

                    infoCase.AccountId = contextObj.AccountId;
                    infoCase.ServicePoint__c = contextObj.ServicePoint__c;
                    infoCase.Market__c = contextObj.Market__c;
                    infoCase.BillingProfile__c = contextObj.BillingProfile__c;
                    infoCase.InformativeCluster__c = contextObj.Cluster__c;
                    infoCase.InformativeType__c = contextObj.Type;
                    infoCase.SalesCompany__c = contextObj.SalesCompany__c;
                    infoCase.Contract__c = contextObj.Contract__c;
                    infoCase.ParentId = contextId;

                }
                when 'Order'{

                    //Da Commentare

                    Order contextObj = (Order) HDT_QR_InformativeManager.getPrePopulationInfo(contextId, sObjName)

                    infoCase.AccountId = contextObj.AccountId;
                    infoCase.ServicePoint__c = contextObj.ServicePoint__c;
                    infoCase.Market__c = contextObj.Market__c;
                    infoCase.BillingProfile__c = contextObj.BillingProfile__c;
                    infoCase.Cluster__c = contextObj.Cluster__c;
                    infoCase.Type = contextObj.Type; //qui capire che campo bisogna prendere
                    infoCase.SalesCompany__c = contextObj.SalesCompany__c;
                    infoCase.Contract__c = contextObj.Contract__c; // qui capire che campo bisogna prendere

                    

                }
                when 'Opportunity'{

                    //Da Commentare

                    Opportunity contextObj = (Opportunity) HDT_QR_InformativeManager.getPrePopulationInfo(contextId, sObjName)

                    infoCase.AccountId = contextObj.AccountId;
                    //infoCase.ServicePoint__c = contextObj.ServicePoint__c;
                    //infoCase.Market__c = contextObj.Market__c;
                    //infoCase.BillingProfile__c = contextObj.BillingProfile__c;
                    //infoCase.Cluster__c = contextObj.Cluster__c;
                    //infoCase.Type = contextObj.Type; //qui capire che campo bisogna prendere
                    //infoCase.SalesCompany__c = contextObj.SalesCompany__c;
                    infoCase.Contract__c = contextObj.ContractId; // qui capire che campo bisogna prendere

                    

                }
                when 'ServicePoint__c'{

                    //Da commentare

                    ServicePoint__c contextObj = (ServicePoint__c) HDT_QR_InformativeManager.getPrePopulationInfo(contextId, sObjName)

                    infoCase.AccountId = contextObj.Account__c;
                    infoCase.ServicePoint__c = contextId;
                    infoCase.Market__c = contextObj.MarketOrigin__c;
                   //infoCase.BillingProfile__c = contextObj.BillingProfile__c;
                    //infoCase.SalesCompany__c = contextObj.SalesCompany__c;
                    //infoCase.Contract__c = contextObj.Contract__c;

                    

                }
                when 'BillingProfile__c'{

                    //Da commentare

                    BillingProfile__c contextObj = (BillingProfile__c) HDT_QR_InformativeManager.getPrePopulationInfo(contextId, sObjName)

                    infoCase.AccountId = contextObj.Account__c;
                    infoCase.Market__c = contextObj.MarketOrigin__c;
                    infoCase.BillingProfile__c = contextId;
                    if(contextObj.Contract__c != null){

                        infoCase.Contract__c = contextObj.Contract__c;
                        infoCase.ServicePoint__c = contextObj.ServicePoint__c;
                        infoCase.SalesCompany__c = contextObj.SalesCompany__c;

                    }



                }
                when 'Account'{
                    
                    infoCase.AccountId = contextId;

                }
                when 'Lead'{

                    infoCase.Lead__c = contextId;

                }
                when 'Contact'{

                    infoCase.ContactId = contextId;

                }
            }

            HDT_UTL_DatabaseService.updateSObject(infoCase);

        }

        return null;

    }

    @AuraEnabled
    public static Case getFieldToPrePopulate(String recordId){

        return HDT_QR_InformativeManager.getFieldToPrePopulate(recordId);

    }*/



}