/**
 * @author Lorenzo Gulotta (lorenzo.gulotta@webresults.it)
 * @date 15/06/2021
 * @description HDT_UTL_LeadProcess Classes
 * @history Lorenzo Gulotta 15/06/2021 – Created Class
 */
public with sharing class HDT_UTL_LeadProcess {
    
    private static HDT_QR_Account acQr= new HDT_QR_Account();
    private static HDT_SRV_CampaignMember cmSrv= new HDT_SRV_CampaignMember();
    private static HDT_QR_Individual indvQr= new HDT_QR_Individual();
    private static HDT_QR_Lead leadQr= new HDT_QR_Lead();
    private static HDT_SRV_ContentDocumentLink cdlSrv = new HDT_SRV_ContentDocumentLink();
    
    public static HDT_WRP_MrrResponse.HDT_WRP_Response formCallback(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject){
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        Map<String,String> mapRequestFields = new Map<String,String>();
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HDT_RT_Main').getRecordTypeId();
       // System.debug('PROVA WSFORM');
       if (request != null && request.objects != null && request.objects.get(0) != null && request.objects.get(0).fields.get(0) != null) {            
            for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
                if(mapRequestFields.get(field.name) == null){
                    mapRequestFields.put(field.name,field.value);
                }
                
            }
           // System.debug('PROVA WSFORM2');
            Boolean isValidated= true;
            if((mapRequestFields.get('COMPANYOWNER') == null || mapRequestFields.get('COMPANYOWNER') == '') || 
            (mapRequestFields.get('CELLULARE') == null|| mapRequestFields.get('CELLULARE')== '') || 
            (mapRequestFields.get('CONSENSOMARKETING') == null || mapRequestFields.get('CONSENSOMARKETING') == '') ||
            (mapRequestFields.get('VERSINFOMARKET') == null || mapRequestFields.get('VERSINFOMARKET') == '') || 
            (mapRequestFields.get('FONTECONSENSOMRK') == null || mapRequestFields.get('FONTECONSENSOMRK') == '') || 
            (mapRequestFields.get('INIZIATIVACONSMARK') == null || mapRequestFields.get('INIZIATIVACONSMARK') == '') ||
            (mapRequestFields.get('COMPANYCONSENSOMARKETING') == null || mapRequestFields.get('COMPANYCONSENSOMARKETING') == '') || 
            (mapRequestFields.get('FONTE') == null || mapRequestFields.get('FONTE') == '') ||
            (mapRequestFields.get('DETTAGLIOFONTE') == null || mapRequestFields.get('DETTAGLIOFONTE') == '') ||
            (mapRequestFields.get('AGENZIA') == null || mapRequestFields.get('AGENZIA') == '') ){
                isValidated= false;
            }
            //System.debug('PROVA WSFORM3');
            if(isValidated){
               // System.debug('PROVA WSFORM4');
                //List<Campaign> campaign= HDT_QR_Campaign.getCampaignIds('LEAD CALLBACK');
                List<Campaign> campaign= HDT_QR_Campaign.campaignByNameMacroActivityEasyCIM(mapRequestFields.get('NOMEMACROACTIVITYEASYCIM'));//HRDTR-00_HRAWRM-907 18/10/2021
                if(campaign != null && !campaign.isEmpty()){
                   // System.debug('PROVA WSFORM5');
                    Lead newLead= new Lead();
                    //!newLead.Company__c='HC'; //HRAWRM-803 01/10/2021  
                    newLead.Company__c= mapRequestFields.get('COMPANY'); //HRAWRM-841 05/10/2021
                    newLead.recordTypeId=leadRecordTypeId;
                    newLead.CompanyOwner__c= mapRequestFields.get('COMPANYOWNER');

                    if(mapRequestFields.get('CELLULARE').left(1) == '3'){
                        newLead.MobilePhone= mapRequestFields.get('CELLULARE');
                    }
                    else{
                        newLead.Phone= mapRequestFields.get('CELLULARE');
                    }
                    
                    newLead.LeadSource= mapRequestFields.get('FONTE');
                    newLead.SourceDetail__c= mapRequestFields.get('DETTAGLIOFONTE');
                    newLead.InterestProduct__c= mapRequestFields.get('PRODOTTO');
                    newLead.CollectionAgency__c	= mapRequestFields.get('AGENZIA');
                    
                    newLead.WebFormField01__c = mapRequestFields.get('CAMPO_01');
                    newLead.WebFormField02__c = mapRequestFields.get('CAMPO_02');
                    newLead.WebFormField03__c = mapRequestFields.get('CAMPO_03');
                    newLead.WebFormField04__c = mapRequestFields.get('CAMPO_04');
                    newLead.WebFormField05__c = mapRequestFields.get('CAMPO_05');
                    newLead.WebFormField06__c = mapRequestFields.get('CAMPO_06');
                    newLead.WebFormField07__c = mapRequestFields.get('CAMPO_07');
                    newLead.WebFormField08__c = mapRequestFields.get('CAMPO_08');
                    newLead.WebFormField09__c = mapRequestFields.get('CAMPO_09');
                    newLead.WebFormField10__c = mapRequestFields.get('CAMPO_10');
                    newLead.WebFormField11__c = mapRequestFields.get('CAMPO_11');
                    newLead.WebFormField12__c = mapRequestFields.get('CAMPO_12');
                    newLead.WebFormField13__c = mapRequestFields.get('CAMPO_13');
                    newLead.WebFormField14__c = mapRequestFields.get('CAMPO_14');
                    newLead.WebFormField15__c = mapRequestFields.get('CAMPO_15');
                    newLead.WebFormField16__c = mapRequestFields.get('CAMPO_16');
                    newLead.WebFormField17__c = mapRequestFields.get('CAMPO_17');
                    newLead.WebFormField18__c = mapRequestFields.get('CAMPO_18');
                    newLead.WebFormField19__c = mapRequestFields.get('CAMPO_19');
                    newLead.WebFormField20__c = mapRequestFields.get('CAMPO_20');
                    newLead.WebFormField21__c = mapRequestFields.get('CAMPO_21');
                    newLead.WebFormField22__c = mapRequestFields.get('CAMPO_22');
                    newLead.WebFormField23__c = mapRequestFields.get('CAMPO_23');
                    newLead.WebFormField24__c = mapRequestFields.get('CAMPO_24');
                    newLead.WebFormField25__c = mapRequestFields.get('CAMPO_25');
                    newLead.WebFormField26__c = mapRequestFields.get('CAMPO_26');
                    newLead.WebFormField27__c = mapRequestFields.get('CAMPO_27');
                    newLead.WebFormField28__c = mapRequestFields.get('CAMPO_28');
                    newLead.WebFormField29__c = mapRequestFields.get('CAMPO_29');
                    newLead.WebFormField30__c = mapRequestFields.get('CAMPO_30');
                    newLead.WebFormField31__c = mapRequestFields.get('CAMPO_31');
                    newLead.WebFormField32__c = mapRequestFields.get('CAMPO_32');
                    newLead.WebFormField33__c = mapRequestFields.get('CAMPO_33');
                    newLead.WebFormField34__c = mapRequestFields.get('CAMPO_34');
                    newLead.WebFormField35__c = mapRequestFields.get('CAMPO_35');
                    newLead.WebFormField36__c = mapRequestFields.get('CAMPO_36');
                    newLead.WebFormField37__c = mapRequestFields.get('CAMPO_37');
                    newLead.WebFormField38__c = mapRequestFields.get('CAMPO_38');
                    newLead.WebFormField39__c = mapRequestFields.get('CAMPO_39');
                    newLead.WebFormField40__c = mapRequestFields.get('CAMPO_40');
                    //HRAWRM-388 03/09/2021
                    newLead.ContactReason__c='Info commerciali';
                    //HRAWRM-388 03/09/2021
                    //System.debug('PROVA WSFORM6');
                    
                    
                    if(mapRequestFields.get('D_O_RICONTATTO') != null){
                        newLead.ContactDate__c=getDateTimeFromString(mapRequestFields.get('D_O_RICONTATTO'));
                    }
                    newLead.FirstName= 'Lead';
                    newLead.LastName= 'Callback';
                    newLead.Company= newLead.FirstName+ ' '+newLead.LastName;
                    
                    HDT_SRV_Lead.checkCreateAccess(newLead);
                    Lead l = HDT_SRV_Lead.createRecord(newLead);
                    Lead ctl= leadQr.getRecordById(l.Id);
                    
                    Individual indv = indvQr.getRecordById(ctl.IndividualId, 'Id, MarketingPrivacy__c, MarketingPrivacyVersion__c, PrivacyMarketingChoiceSource__c,PrivacyMarketingConsentInitiative__c, MarketingCompanyConsent__c,PrivacyMarketingChoiceDate__c');
                    indv.MarketingPrivacy__c= mapRequestFields.get('CONSENSOMARKETING');
                    indv.PrivacyMarketingChoiceDate__c = ('SI'.equalsIgnoreCase( indv.MarketingPrivacy__c) ||'NO'.equalsIgnoreCase( indv.MarketingPrivacy__c)  )?  Date.today():indv.PrivacyMarketingChoiceDate__c; //HRDTR-00_HRAWRM-803 01/10/2021
                    
                    indv.MarketingPrivacyVersion__c= mapRequestFields.get('VERSINFOMARKET');
                    indv.PrivacyMarketingChoiceSource__c= mapRequestFields.get('FONTECONSENSOMRK');
                    indv.PrivacyMarketingConsentInitiative__c= mapRequestFields.get('INIZIATIVACONSMARK');
                    indv.MarketingCompanyConsent__c= mapRequestFields.get('COMPANYCONSENSOMARKETING');
                    HDT_SRV_Individual.checkUpdateAccess(indv);
                    HDT_SRV_Individual.updateRecord(indv);
                   // System.debug('PROVA WSFORM7');
                    Account ac= acQr.getAccountByName(mapRequestFields.get('AGENZIA'));
                    Id campaignId= null;
                    Datetime d= null;
                    String macroactivity= null;
                    if(campaign.size()>1){
                        for(Campaign c: campaign){
                            if(d==null || c.CreatedDate>d) {
                                d = c.CreatedDate;
                                campaignId =c.ID;
                                macroactivity= c.MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
                            }
                        }
                    }else{
                        campaignId = campaign[0].Id;
                        macroactivity= campaign[0].MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
                    }
                    
                    CampaignMember cm = new CampaignMember(CampaignId= campaignId, Agency__c= ac.Id, LeadId= l.Id, phonenumber__c = mapRequestFields.get('CELLULARE'));
                    
                    cmSrv.createRecord(cm);

                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'OK';
                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
                    mrrResponseItem.objects.add(responseObject);
                    RestContext.response.statusCode = 200;
                    return mrrResponseItem;
                }
                else{
                  /*  responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'KO';
                    responseFieldError.fieldType = 'TEXT';
                    responseFieldError.name = 'ERROR_MESSAGE';
                    responseFieldError.value = 'Internal error';
                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                    mrrResponseItem.objects.add(responseObject);
                    RestContext.response.statusCode = 500;*/
                    campaignNotFound( request, mrrResponseItem, responseObject,responseField,responseFieldError);//HRDTR-00_HRAWRM-907 18/10/2021
                    return mrrResponseItem;
                }
                
            }else{
                responseField.fieldType = 'TEXT';
                responseField.name = 'ESITO';
                responseField.value = 'KO';
                responseFieldError.fieldType = 'TEXT';
                responseFieldError.name = 'ERROR_MESSAGE';
                responseFieldError.value = 'Campi Obbligatori Mancanti!';
                responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                mrrResponseItem.objects.add(responseObject);
                RestContext.response.statusCode = 400;
                return mrrResponseItem;
            }
        }else{
            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'KO';
            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = 'There was an issue with your request message';
            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
            mrrResponseItem.objects.add(responseObject);
            RestContext.response.statusCode = 400;
            return mrrResponseItem;
            
        }
        
    }
    public static HDT_WRP_MrrResponse.HDT_WRP_Response formWinback(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject){
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HDT_RT_Main').getRecordTypeId();

        Map<String,String> mapRequestFields = new Map<String,String>();
        if (request != null && request.objects != null && request.objects.get(0) != null && request.objects.get(0).fields.get(0) != null) {            
            for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
                if(mapRequestFields.get(field.name) == null){
                    mapRequestFields.put(field.name,field.value);
                }
                
            }
            Boolean isValidated= true;
            if((mapRequestFields.get('COMPANYOWNER') == null || mapRequestFields.get('COMPANYOWNER') == '') || 
            (mapRequestFields.get('CELLULARE') == null|| mapRequestFields.get('CELLULARE')== '') || 
            (mapRequestFields.get('CONSENSOMARKETING') == null || mapRequestFields.get('CONSENSOMARKETING') == '') ||
            (mapRequestFields.get('VERSINFOMARKET') == null || mapRequestFields.get('VERSINFOMARKET') == '') || 
            (mapRequestFields.get('FONTECONSENSOMRK') == null || mapRequestFields.get('FONTECONSENSOMRK') == '') || 
            (mapRequestFields.get('INIZIATIVACONSMARK') == null || mapRequestFields.get('INIZIATIVACONSMARK') == '') ||
            (mapRequestFields.get('COMPANYCONSENSOMARKETING') == null || mapRequestFields.get('COMPANYCONSENSOMARKETING') == '') || 
            (mapRequestFields.get('FONTE') == null || mapRequestFields.get('FONTE') == '') ||
            (mapRequestFields.get('DETTAGLIOFONTE') == null || mapRequestFields.get('DETTAGLIOFONTE') == '') ||
            (mapRequestFields.get('AGENZIA') == null || mapRequestFields.get('AGENZIA') == '') ){
                isValidated= false;
            }
            
            if(isValidated){
               //List<Campaign> campaign= HDT_QR_Campaign.getCampaignIds('LEAD WINBACK');
               List<Campaign> campaign= HDT_QR_Campaign.campaignByNameMacroActivityEasyCIM(mapRequestFields.get('NOMEMACROACTIVITYEASYCIM'));//HRDTR-00_HRAWRM-907 18/10/2021
                if(campaign != null && !campaign.isEmpty()){
                    Lead newLead= new Lead();
                   //! newLead.Company__c='HC'; //HRAWRM-803 01/10/2021 
                    newLead.Company__c= mapRequestFields.get('COMPANY'); //HRAWRM-841 05/10/2021
                    newLead.recordTypeId=leadRecordTypeId;
                    newLead.CompanyOwner__c= mapRequestFields.get('COMPANYOWNER');
                    if(mapRequestFields.get('CELLULARE').left(1) == '3'){
                        newLead.MobilePhone= mapRequestFields.get('CELLULARE');
                    }
                    else{
                        newLead.Phone= mapRequestFields.get('CELLULARE');
                    }
                    newLead.LeadSource= mapRequestFields.get('FONTE');
                    newLead.SourceDetail__c= mapRequestFields.get('DETTAGLIOFONTE');
                    newLead.CollectionAgency__c	= mapRequestFields.get('AGENZIA');//HRAWRM-840 Bolzon 05/10/2021
                    newLead.InterestProduct__c= mapRequestFields.get('PRODOTTO');
                    newLead.WebFormField01__c = mapRequestFields.get('CAMPO_01');
                    newLead.WebFormField02__c = mapRequestFields.get('CAMPO_02');
                    newLead.WebFormField03__c = mapRequestFields.get('CAMPO_03');
                    newLead.WebFormField04__c = mapRequestFields.get('CAMPO_04');
                    newLead.WebFormField05__c = mapRequestFields.get('CAMPO_05');
                    newLead.WebFormField06__c = mapRequestFields.get('CAMPO_06');
                    newLead.WebFormField07__c = mapRequestFields.get('CAMPO_07');
                    newLead.WebFormField08__c = mapRequestFields.get('CAMPO_08');
                    newLead.WebFormField09__c = mapRequestFields.get('CAMPO_09');
                    newLead.WebFormField10__c = mapRequestFields.get('CAMPO_10');
                    newLead.WebFormField11__c = mapRequestFields.get('CAMPO_11');
                    newLead.WebFormField12__c = mapRequestFields.get('CAMPO_12');
                    newLead.WebFormField13__c = mapRequestFields.get('CAMPO_13');
                    newLead.WebFormField14__c = mapRequestFields.get('CAMPO_14');
                    newLead.WebFormField15__c = mapRequestFields.get('CAMPO_15');
                    newLead.WebFormField16__c = mapRequestFields.get('CAMPO_16');
                    newLead.WebFormField17__c = mapRequestFields.get('CAMPO_17');
                    newLead.WebFormField18__c = mapRequestFields.get('CAMPO_18');
                    newLead.WebFormField19__c = mapRequestFields.get('CAMPO_19');
                    newLead.WebFormField20__c = mapRequestFields.get('CAMPO_20');
                    newLead.WebFormField21__c = mapRequestFields.get('CAMPO_21');
                    newLead.WebFormField22__c = mapRequestFields.get('CAMPO_22');
                    newLead.WebFormField23__c = mapRequestFields.get('CAMPO_23');
                    newLead.WebFormField24__c = mapRequestFields.get('CAMPO_24');
                    newLead.WebFormField25__c = mapRequestFields.get('CAMPO_25');
                    newLead.WebFormField26__c = mapRequestFields.get('CAMPO_26');
                    newLead.WebFormField27__c = mapRequestFields.get('CAMPO_27');
                    newLead.WebFormField28__c = mapRequestFields.get('CAMPO_28');
                    newLead.WebFormField29__c = mapRequestFields.get('CAMPO_29');
                    newLead.WebFormField30__c = mapRequestFields.get('CAMPO_30');
                    newLead.WebFormField31__c = mapRequestFields.get('CAMPO_31');
                    newLead.WebFormField32__c = mapRequestFields.get('CAMPO_32');
                    newLead.WebFormField33__c = mapRequestFields.get('CAMPO_33');
                    newLead.WebFormField34__c = mapRequestFields.get('CAMPO_34');
                    newLead.WebFormField35__c = mapRequestFields.get('CAMPO_35');
                    newLead.WebFormField36__c = mapRequestFields.get('CAMPO_36');
                    newLead.WebFormField37__c = mapRequestFields.get('CAMPO_37');
                    newLead.WebFormField38__c = mapRequestFields.get('CAMPO_38');
                    newLead.WebFormField39__c = mapRequestFields.get('CAMPO_39');
                    newLead.WebFormField40__c = mapRequestFields.get('CAMPO_40');
                    newLead.ContactReason__c='Info commerciali';//HRAWRM-388 03-09-2021
                    if(mapRequestFields.get('D_O_RICONTATTO') != null){
                        newLead.ContactDate__c=getDateTimeFromString(mapRequestFields.get('D_O_RICONTATTO'));
                    }
                    newLead.FirstName= 'Lead';
                    newLead.LastName= 'Winback';
                    newLead.Company= newLead.FirstName+ ' '+newLead.LastName;
                    
                    HDT_SRV_Lead.checkCreateAccess(newLead);
                    Lead l = HDT_SRV_Lead.createRecord(newLead);
                    
                    Lead ctl= leadQr.getRecordById(l.Id);
                    
                    Individual indv= indvQr.getRecordById(ctl.IndividualId, 'Id, MarketingPrivacy__c, MarketingPrivacyVersion__c, PrivacyMarketingChoiceSource__c,PrivacyMarketingConsentInitiative__c, MarketingCompanyConsent__c, PrivacyMarketingChoiceDate__c ');
                    indv.MarketingPrivacy__c= mapRequestFields.get('CONSENSOMARKETING');
                    indv.MarketingPrivacyVersion__c= mapRequestFields.get('VERSINFOMARKET');
                    indv.PrivacyMarketingChoiceSource__c= mapRequestFields.get('FONTECONSENSOMRK');
                    indv.PrivacyMarketingConsentInitiative__c= mapRequestFields.get('INIZIATIVACONSMARK');
                    indv.MarketingCompanyConsent__c= mapRequestFields.get('COMPANYCONSENSOMARKETING');
                    indv.PrivacyMarketingChoiceDate__c = ('SI'.equalsIgnoreCase( indv.MarketingPrivacy__c) ||'NO'.equalsIgnoreCase( indv.MarketingPrivacy__c)  )?  Date.today():indv.PrivacyMarketingChoiceDate__c; //HRDTR-00_HRAWRM-803 01/10/2021
                    HDT_SRV_Individual.checkUpdateAccess(indv);
                    HDT_SRV_Individual.updateRecord(indv);
                    
                    Account ac= acQr.getAccountByName(mapRequestFields.get('AGENZIA'));
                    Id campaignId= null;
                    Datetime d= null;
                    String macroactivity= null;
                    
                    if(campaign.size()>1){
                        for(Campaign c: campaign){
                            if(d==null || c.CreatedDate>d) {
                                d = c.CreatedDate;
                                campaignId =c.ID;
                                macroactivity= c.MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
                            }
                        }
                    }else{
                        campaignId = campaign[0].Id;
                        macroactivity= campaign[0].MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
                    }
                    CampaignMember cm = new CampaignMember(CampaignId= campaignId, Agency__c= ac.Id, LeadId= l.Id, phonenumber__c = mapRequestFields.get('CELLULARE'));
                    cmSrv.createRecord(cm);

                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'OK';
                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
                    mrrResponseItem.objects.add(responseObject);
                    RestContext.response.statusCode = 200;
                    return mrrResponseItem;
                }
                else{
                    /*responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'KO';
                    responseFieldError.fieldType = 'TEXT';
                    responseFieldError.name = 'ERROR_MESSAGE';
                    responseFieldError.value = 'Internal error';
                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                    mrrResponseItem.objects.add(responseObject);
                    RestContext.response.statusCode = 500;*/
                    campaignNotFound( request, mrrResponseItem, responseObject,responseField,responseFieldError);//HRDTR-00_HRAWRM-907 18/10/2021
                    return mrrResponseItem;
                }
            }else{
                responseField.fieldType = 'TEXT';
                responseField.name = 'ESITO';
                responseField.value = 'KO';
                responseFieldError.fieldType = 'TEXT';
                responseFieldError.name = 'ERROR_MESSAGE';
                responseFieldError.value = 'Campi Obbligatori Mancanti!';
                responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                mrrResponseItem.objects.add(responseObject);
                RestContext.response.statusCode = 400;
                return mrrResponseItem;
            }
        }else{
            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'KO';
            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = 'There was an issue with your request message';
            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
            mrrResponseItem.objects.add(responseObject);
            RestContext.response.statusCode = 400;
            return mrrResponseItem;
            
        }
        
    }
    public static HDT_WRP_MrrResponse.HDT_WRP_Response formCaricBoll(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject){
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HDT_RT_Main').getRecordTypeId();

        Map<String,String> mapRequestFields = new Map<String,String>();
        
        if (request != null && request.objects != null && request.objects.get(0) != null && request.objects.get(0).fields.get(0) != null) {            
            for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
                if(mapRequestFields.get(field.name) == null){
                    mapRequestFields.put(field.name,field.value);
                }
                
            }
            Boolean isValidated= true;
            if((mapRequestFields.get('COMPANYOWNER') == null || mapRequestFields.get('COMPANYOWNER') == '') || 
            (mapRequestFields.get('CELLULARE') == null|| mapRequestFields.get('CELLULARE')== '') || 
            (mapRequestFields.get('CONSENSOMARKETING') == null || mapRequestFields.get('CONSENSOMARKETING') == '') ||
            (mapRequestFields.get('VERSINFOMARKET') == null || mapRequestFields.get('VERSINFOMARKET') == '') || 
            (mapRequestFields.get('FONTECONSENSOMRK') == null || mapRequestFields.get('FONTECONSENSOMRK') == '') || 
            (mapRequestFields.get('INIZIATIVACONSMARK') == null || mapRequestFields.get('INIZIATIVACONSMARK') == '') ||
            (mapRequestFields.get('COMPANYCONSENSOMARKETING') == null || mapRequestFields.get('COMPANYCONSENSOMARKETING') == '') || 
            (mapRequestFields.get('FONTE') == null || mapRequestFields.get('FONTE') == '') ||
            (mapRequestFields.get('DETTAGLIOFONTE') == null || mapRequestFields.get('DETTAGLIOFONTE') == '') ||
            (mapRequestFields.get('AGENZIA') == null || mapRequestFields.get('AGENZIA') == '') ){
                isValidated= false;
            }
            
            if(isValidated){
                //List<Campaign> campaign= HDT_QR_Campaign.getCampaignIds('LEAD CALLBACK');
                List<Campaign> campaign= HDT_QR_Campaign.campaignByNameMacroActivityEasyCIM(mapRequestFields.get('NOMEMACROACTIVITYEASYCIM'));//HRDTR-00_HRAWRM-907 18/10/2021

                if(campaign != null && !campaign.isEmpty()){
                    Lead newLead= new Lead();
                    //!newLead.Company__c='HC'; //HRAWRM-803 01/10/2021 
                    newLead.Company__c= mapRequestFields.get('COMPANY'); //HRAWRM-841 05/10/2021
                    newLead.recordTypeId=leadRecordTypeId;
                    newLead.CompanyOwner__c= mapRequestFields.get('COMPANYOWNER');
                    if(mapRequestFields.get('CELLULARE').left(1) == '3'){
                        newLead.MobilePhone= mapRequestFields.get('CELLULARE');
                    }
                    else{
                        newLead.Phone= mapRequestFields.get('CELLULARE');
                    }
                    newLead.LeadSource= mapRequestFields.get('FONTE');
                    newLead.CollectionAgency__c	= mapRequestFields.get('AGENZIA');//HRAWRM-840 Bolzon 05/10/2021
                    newLead.SourceDetail__c= mapRequestFields.get('DETTAGLIOFONTE');
                    newLead.InterestProduct__c= mapRequestFields.get('PRODOTTO');
                    newLead.WebFormField01__c = mapRequestFields.get('CAMPO_01');
                    newLead.WebFormField02__c = mapRequestFields.get('CAMPO_02');
                    newLead.WebFormField03__c = mapRequestFields.get('CAMPO_03');
                    newLead.WebFormField04__c = mapRequestFields.get('CAMPO_04');
                    newLead.WebFormField05__c = mapRequestFields.get('CAMPO_05');
                    newLead.WebFormField06__c = mapRequestFields.get('CAMPO_06');
                    newLead.WebFormField07__c = mapRequestFields.get('CAMPO_07');
                    newLead.WebFormField08__c = mapRequestFields.get('CAMPO_08');
                    newLead.WebFormField09__c = mapRequestFields.get('CAMPO_09');
                    newLead.WebFormField10__c = mapRequestFields.get('CAMPO_10');
                    newLead.WebFormField11__c = mapRequestFields.get('CAMPO_11');
                    newLead.WebFormField12__c = mapRequestFields.get('CAMPO_12');
                    newLead.WebFormField13__c = mapRequestFields.get('CAMPO_13');
                    newLead.WebFormField14__c = mapRequestFields.get('CAMPO_14');
                    newLead.WebFormField15__c = mapRequestFields.get('CAMPO_15');
                    newLead.WebFormField16__c = mapRequestFields.get('CAMPO_16');
                    newLead.WebFormField17__c = mapRequestFields.get('CAMPO_17');
                    newLead.WebFormField18__c = mapRequestFields.get('CAMPO_18');
                    newLead.WebFormField19__c = mapRequestFields.get('CAMPO_19');
                    newLead.WebFormField20__c = mapRequestFields.get('CAMPO_20');
                    newLead.WebFormField21__c = mapRequestFields.get('CAMPO_21');
                    newLead.WebFormField22__c = mapRequestFields.get('CAMPO_22');
                    newLead.WebFormField23__c = mapRequestFields.get('CAMPO_23');
                    newLead.WebFormField24__c = mapRequestFields.get('CAMPO_24');
                    newLead.WebFormField25__c = mapRequestFields.get('CAMPO_25');
                    newLead.WebFormField26__c = mapRequestFields.get('CAMPO_26');
                    newLead.WebFormField27__c = mapRequestFields.get('CAMPO_27');
                    newLead.WebFormField28__c = mapRequestFields.get('CAMPO_28');
                    newLead.WebFormField29__c = mapRequestFields.get('CAMPO_29');
                    newLead.WebFormField30__c = mapRequestFields.get('CAMPO_30');
                    newLead.WebFormField31__c = mapRequestFields.get('CAMPO_31');
                    newLead.WebFormField32__c = mapRequestFields.get('CAMPO_32');
                    newLead.WebFormField33__c = mapRequestFields.get('CAMPO_33');
                    newLead.WebFormField34__c = mapRequestFields.get('CAMPO_34');
                    newLead.WebFormField35__c = mapRequestFields.get('CAMPO_35');
                    newLead.WebFormField36__c = mapRequestFields.get('CAMPO_36');
                    newLead.WebFormField37__c = mapRequestFields.get('CAMPO_37');
                    newLead.WebFormField38__c = mapRequestFields.get('CAMPO_38');
                    newLead.WebFormField39__c = mapRequestFields.get('CAMPO_39');
                    newLead.WebFormField40__c = mapRequestFields.get('CAMPO_40');
                    newLead.ContactReason__c='Info commerciali';//HRAWRM-388 03-09-2021
                    if(mapRequestFields.get('D_O_RICONTATTO') != null){
                        newLead.ContactDate__c=getDateTimeFromString(mapRequestFields.get('D_O_RICONTATTO'));
                    }
                    newLead.FirstName= 'Lead';
                    newLead.LastName= 'CaricaBollete';
                    newLead.Company= newLead.FirstName+ ' '+newLead.LastName;
                    
                    HDT_SRV_Lead.checkCreateAccess(newLead);
                    Lead l = HDT_SRV_Lead.createRecord(newLead);
                    Lead ctl= leadQr.getRecordById(l.Id);
                    
                    Individual indv= indvQr.getRecordById(ctl.IndividualId, 'Id, MarketingPrivacy__c, MarketingPrivacyVersion__c, PrivacyMarketingChoiceSource__c,PrivacyMarketingConsentInitiative__c, MarketingCompanyConsent__c,PrivacyMarketingChoiceDate__c');
                    indv.MarketingPrivacy__c= mapRequestFields.get('CONSENSOMARKETING');
                    indv.MarketingPrivacyVersion__c= mapRequestFields.get('VERSINFOMARKET');
                    indv.PrivacyMarketingChoiceSource__c= mapRequestFields.get('FONTECONSENSOMRK');
                    indv.PrivacyMarketingConsentInitiative__c= mapRequestFields.get('INIZIATIVACONSMARK');
                    indv.MarketingCompanyConsent__c= mapRequestFields.get('COMPANYCONSENSOMARKETING');
                    indv.PrivacyMarketingChoiceDate__c = ('SI'.equalsIgnoreCase( indv.MarketingPrivacy__c) ||'NO'.equalsIgnoreCase( indv.MarketingPrivacy__c)  )?  Date.today():indv.PrivacyMarketingChoiceDate__c; //HRDTR-00_HRAWRM-803 01/10/2021
                    HDT_SRV_Individual.checkUpdateAccess(indv);
                    HDT_SRV_Individual.updateRecord(indv);
                    
                    Account ac= acQr.getAccountByName(mapRequestFields.get('AGENZIA'));
                    Id campaignId= null;
                    Datetime d= null;
                    String macroactivity= null;
                    
                    if(campaign.size()>1){
                        for(Campaign c: campaign){
                            if(d==null || c.CreatedDate>d) {
                                d = c.CreatedDate;
                                campaignId =c.ID;
                                macroactivity= c.MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
                            }
                        }
                    }else if (campaign!=null && !campaign.isEmpty()) {
                        campaignId = campaign[0].Id;
                        macroactivity= campaign[0].MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
                        
                    }
                    CampaignMember cm = new CampaignMember(CampaignId= campaignId, Agency__c= ac.Id, LeadId= l.Id, phonenumber__c = mapRequestFields.get('CELLULARE'));
                    cmSrv.createRecord(cm);

                    if(mapRequestFields.get('FILE') != null && mapRequestFields.get('FILE') != ''){
                        //ContentDocumentLink cdl = new ContentDocumentLink();
                        HDT_QR_ContentVersion conDocQr = new HDT_QR_ContentVersion();
                        ContentVersion cvdl = conDocQr.getRecordById(mapRequestFields.get('FILE'));
                        cdlSrv.createRecord(l.id,cvdl.contentDocumentId,'I');
                    }              
                    
                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'OK';
                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
                    mrrResponseItem.objects.add(responseObject);
                    RestContext.response.statusCode = 200;
                    return mrrResponseItem;
                }
                else{
                   /* responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'KO';
                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
                    mrrResponseItem.objects.add(responseObject);
                    RestContext.response.statusCode = 500;
                    responseFieldError.value = 'Internal Error';*/
                    campaignNotFound( request, mrrResponseItem, responseObject,responseField,responseFieldError);//HRDTR-00_HRAWRM-907 18/10/2021
                    return mrrResponseItem;
                }
            }else{
                responseField.fieldType = 'TEXT';
                responseField.name = 'ESITO';
                responseField.value = 'KO';
                responseFieldError.fieldType = 'TEXT';
                responseFieldError.name = 'ERROR_MESSAGE';
                responseFieldError.value = 'Campi Obbligatori Mancanti!';
                responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                mrrResponseItem.objects.add(responseObject);
                RestContext.response.statusCode = 400;
                return mrrResponseItem;
            }
        }else{
            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'KO';
            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = 'There was an issue with your request message';
            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
            mrrResponseItem.objects.add(responseObject);
            RestContext.response.statusCode = 400;
            return mrrResponseItem;
            
        }
        
    }
    public static HDT_WRP_MrrResponse.HDT_WRP_Response formHvac(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject){
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HDT_RT_Main').getRecordTypeId();

        Map<String,String> mapRequestFields = new Map<String,String>();
        
        if (request != null && request.objects != null && request.objects.get(0) != null && request.objects.get(0).fields.get(0) != null) {            
            for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
                if(mapRequestFields.get(field.name) == null){
                    mapRequestFields.put(field.name,field.value);
                }
                
            }
            Boolean isValidated= true;
            if((mapRequestFields.get('COMPANYOWNER') == null || mapRequestFields.get('COMPANYOWNER') == '') || 
            (mapRequestFields.get('CELLULARE') == null|| mapRequestFields.get('CELLULARE')== '') || 
            (mapRequestFields.get('CONSENSOMARKETING') == null || mapRequestFields.get('CONSENSOMARKETING') == '') ||
            (mapRequestFields.get('VERSINFOMARKET') == null || mapRequestFields.get('VERSINFOMARKET') == '') || 
            (mapRequestFields.get('FONTECONSENSOMRK') == null || mapRequestFields.get('FONTECONSENSOMRK') == '') || 
            (mapRequestFields.get('INIZIATIVACONSMARK') == null || mapRequestFields.get('INIZIATIVACONSMARK') == '') ||
            (mapRequestFields.get('COMPANYCONSENSOMARKETING') == null || mapRequestFields.get('COMPANYCONSENSOMARKETING') == '') || 
            (mapRequestFields.get('FONTE') == null || mapRequestFields.get('FONTE') == '') ||
            (mapRequestFields.get('DETTAGLIOFONTE') == null || mapRequestFields.get('DETTAGLIOFONTE') == '') ||
            (mapRequestFields.get('AGENZIA') == null || mapRequestFields.get('AGENZIA') == '') ){
                isValidated= false;
            }
            
            if(isValidated){
                //List<Campaign> campaign= HDT_QR_Campaign.getCampaignIds('LEAD CALLBACK');
                List<Campaign> campaign= HDT_QR_Campaign.campaignByNameMacroActivityEasyCIM(mapRequestFields.get('NOMEMACROACTIVITYEASYCIM'));//HRDTR-00_HRAWRM-907 18/10/2021

                if(campaign != null && !campaign.isEmpty()){
                    Lead newLead= new Lead();
                    //!newLead.Company__c='HC'; //HRAWRM-803 01/10/2021 
                    newLead.Company__c= mapRequestFields.get('COMPANY'); //HRAWRM-841 05/10/2021
                    newLead.recordTypeId=leadRecordTypeId;
                    newLead.CompanyOwner__c= mapRequestFields.get('COMPANYOWNER');
                    if(mapRequestFields.get('CELLULARE').left(1) == '3'){
                        newLead.MobilePhone= mapRequestFields.get('CELLULARE');
                    }
                    else{
                        newLead.Phone= mapRequestFields.get('CELLULARE');
                    }
                    newLead.LeadSource= mapRequestFields.get('FONTE');
                    newLead.SourceDetail__c= mapRequestFields.get('DETTAGLIOFONTE');
                    newLead.CollectionAgency__c	= mapRequestFields.get('AGENZIA');//HRAWRM-840 Bolzon 05/10/2021
                    newLead.InterestProduct__c= mapRequestFields.get('PRODOTTO');
                    newLead.WebFormField01__c = mapRequestFields.get('CAMPO_01');
                    newLead.WebFormField02__c = mapRequestFields.get('CAMPO_02');
                    newLead.WebFormField03__c = mapRequestFields.get('CAMPO_03');
                    newLead.WebFormField04__c = mapRequestFields.get('CAMPO_04');
                    newLead.WebFormField05__c = mapRequestFields.get('CAMPO_05');
                    newLead.WebFormField06__c = mapRequestFields.get('CAMPO_06');
                    newLead.WebFormField07__c = mapRequestFields.get('CAMPO_07');
                    newLead.WebFormField08__c = mapRequestFields.get('CAMPO_08');
                    newLead.WebFormField09__c = mapRequestFields.get('CAMPO_09');
                    newLead.WebFormField10__c = mapRequestFields.get('CAMPO_10');
                    newLead.WebFormField11__c = mapRequestFields.get('CAMPO_11');
                    newLead.WebFormField12__c = mapRequestFields.get('CAMPO_12');
                    newLead.WebFormField13__c = mapRequestFields.get('CAMPO_13');
                    newLead.WebFormField14__c = mapRequestFields.get('CAMPO_14');
                    newLead.WebFormField15__c = mapRequestFields.get('CAMPO_15');
                    newLead.WebFormField16__c = mapRequestFields.get('CAMPO_16');
                    newLead.WebFormField17__c = mapRequestFields.get('CAMPO_17');
                    newLead.WebFormField18__c = mapRequestFields.get('CAMPO_18');
                    newLead.WebFormField19__c = mapRequestFields.get('CAMPO_19');
                    newLead.WebFormField20__c = mapRequestFields.get('CAMPO_20');
                    newLead.WebFormField21__c = mapRequestFields.get('CAMPO_21');
                    newLead.WebFormField22__c = mapRequestFields.get('CAMPO_22');
                    newLead.WebFormField23__c = mapRequestFields.get('CAMPO_23');
                    newLead.WebFormField24__c = mapRequestFields.get('CAMPO_24');
                    newLead.WebFormField25__c = mapRequestFields.get('CAMPO_25');
                    newLead.WebFormField26__c = mapRequestFields.get('CAMPO_26');
                    newLead.WebFormField27__c = mapRequestFields.get('CAMPO_27');
                    newLead.WebFormField28__c = mapRequestFields.get('CAMPO_28');
                    newLead.WebFormField29__c = mapRequestFields.get('CAMPO_29');
                    newLead.WebFormField30__c = mapRequestFields.get('CAMPO_30');
                    newLead.WebFormField31__c = mapRequestFields.get('CAMPO_31');
                    newLead.WebFormField32__c = mapRequestFields.get('CAMPO_32');
                    newLead.WebFormField33__c = mapRequestFields.get('CAMPO_33');
                    newLead.WebFormField34__c = mapRequestFields.get('CAMPO_34');
                    newLead.WebFormField35__c = mapRequestFields.get('CAMPO_35');
                    newLead.WebFormField36__c = mapRequestFields.get('CAMPO_36');
                    newLead.WebFormField37__c = mapRequestFields.get('CAMPO_37');
                    newLead.WebFormField38__c = mapRequestFields.get('CAMPO_38');
                    newLead.WebFormField39__c = mapRequestFields.get('CAMPO_39');
                    newLead.WebFormField40__c = mapRequestFields.get('CAMPO_40');
                    newLead.ContactReason__c='Info commerciali';//HRAWRM-388 03-09-2021

                    if(mapRequestFields.get('D_O_RICONTATTO') != null){
                        newLead.ContactDate__c=getDateTimeFromString(mapRequestFields.get('D_O_RICONTATTO'));
                    }
                    newLead.Email= mapRequestFields.get('EMAIL');
                    newLead.City= mapRequestFields.get('COMUNE');
                    if(mapRequestFields.get('NOME') != null){
                        newLead.FirstName= mapRequestFields.get('NOME');
                    } else{
                        newLead.FirstName= 'Lead';
                    }
                    newLead.PostalCode= mapRequestFields.get('CAP');
                    
                    if(mapRequestFields.get('COGNOME') != null){
                        newLead.LastName= mapRequestFields.get('COGNOME');
                    } else{
                        newLead.LastName= 'HVAC';
                    }
                    newLead.Company= newLead.FirstName+ ' '+newLead.LastName;
                    System.debug('££check' + newLead);
                    HDT_SRV_Lead.checkCreateAccess(newLead);
                    Lead l = HDT_SRV_Lead.createRecord(newLead);
                    Lead ctl= leadQr.getRecordById(l.Id);
                    
                    Individual indv= indvQr.getRecordById(ctl.IndividualId, 'Id, MarketingPrivacy__c, MarketingPrivacyVersion__c, PrivacyMarketingChoiceSource__c,PrivacyMarketingConsentInitiative__c, MarketingCompanyConsent__c,PrivacyMarketingChoiceDate__c');
                    indv.MarketingPrivacy__c= mapRequestFields.get('CONSENSOMARKETING');
                    indv.MarketingPrivacyVersion__c= mapRequestFields.get('VERSINFOMARKET');
                    indv.PrivacyMarketingChoiceSource__c= mapRequestFields.get('FONTECONSENSOMRK');
                    indv.PrivacyMarketingConsentInitiative__c= mapRequestFields.get('INIZIATIVACONSMARK');
                    indv.MarketingCompanyConsent__c= mapRequestFields.get('COMPANYCONSENSOMARKETING');
                    indv.PrivacyMarketingChoiceDate__c = ('SI'.equalsIgnoreCase( indv.MarketingPrivacy__c) ||'NO'.equalsIgnoreCase( indv.MarketingPrivacy__c)  )?  Date.today():indv.PrivacyMarketingChoiceDate__c; //HRDTR-00_HRAWRM-803 01/10/2021
                    HDT_SRV_Individual.checkUpdateAccess(indv);
                    HDT_SRV_Individual.updateRecord(indv);
                    
                    Account ac= acQr.getAccountByName(mapRequestFields.get('AGENZIA'));
                    Id campaignId= null;
                    Datetime d= null;
                    String macroactivity= null;
                    
                    if(campaign.size()>1){
                        for(Campaign c: campaign){
                            if(d==null || c.CreatedDate>d) {
                                d = c.CreatedDate;
                                campaignId =c.ID;
                                macroactivity= c.MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
                            }
                        }
                    }else{
                        campaignId = campaign[0].Id;
                        macroactivity= campaign[0].MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
                    }
                    CampaignMember cm = new CampaignMember(CampaignId= campaignId, Agency__c= ac.Id, LeadId= l.Id, phonenumber__c = mapRequestFields.get('CELLULARE'));
                    cmSrv.createRecord(cm);

                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'OK';
                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
                    mrrResponseItem.objects.add(responseObject);
                    RestContext.response.statusCode = 200;
                    return mrrResponseItem;
                }
                else{
                   /* responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'KO';
                    responseFieldError.fieldType = 'TEXT';
                    responseFieldError.name = 'ERROR_MESSAGE';
                    responseFieldError.value = 'Internal error';
                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                    mrrResponseItem.objects.add(responseObject);
                    RestContext.response.statusCode = 500;*/
                    campaignNotFound( request, mrrResponseItem, responseObject,responseField,responseFieldError);//HRDTR-00_HRAWRM-907 18/10/2021
                    return mrrResponseItem;
                } 
                
            }else{
                responseField.fieldType = 'TEXT';
                responseField.name = 'ESITO';
                responseField.value = 'KO';
                responseFieldError.fieldType = 'TEXT';
                responseFieldError.name = 'ERROR_MESSAGE';
                responseFieldError.value = 'Campi Obbligatori Mancanti!';
                responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                mrrResponseItem.objects.add(responseObject);
                RestContext.response.statusCode = 400;
                return mrrResponseItem;
            }
        }else{
            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'KO';
            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = 'There was an issue with your request message';
            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
            mrrResponseItem.objects.add(responseObject);
            RestContext.response.statusCode = 400;
            return mrrResponseItem;
            
        }
        
    }
    public static HDT_WRP_MrrResponse.HDT_WRP_Response formSol(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject){
        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HDT_RT_Main').getRecordTypeId();

        Map<String,String> mapRequestFields = new Map<String,String>();
        
        if (request != null && request.objects != null && request.objects.get(0) != null && request.objects.get(0).fields.get(0) != null) {            
            for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
                if(mapRequestFields.get(field.name) == null){
                    mapRequestFields.put(field.name,field.value);
                }
                
            }
            Boolean isValidated= true;
            if((mapRequestFields.get('COMPANYOWNER') == null || mapRequestFields.get('COMPANYOWNER') == '') || 
            (mapRequestFields.get('CELLULARE') == null|| mapRequestFields.get('CELLULARE')== '') || 
            (mapRequestFields.get('CONSENSOMARKETING') == null || mapRequestFields.get('CONSENSOMARKETING') == '') ||
            (mapRequestFields.get('VERSINFOMARKET') == null || mapRequestFields.get('VERSINFOMARKET') == '') || 
            (mapRequestFields.get('FONTECONSENSOMRK') == null || mapRequestFields.get('FONTECONSENSOMRK') == '') || 
            (mapRequestFields.get('INIZIATIVACONSMARK') == null || mapRequestFields.get('INIZIATIVACONSMARK') == '') ||
            (mapRequestFields.get('COMPANYCONSENSOMARKETING') == null || mapRequestFields.get('COMPANYCONSENSOMARKETING') == '') || 
            (mapRequestFields.get('FONTE') == null || mapRequestFields.get('FONTE') == '') ||
            (mapRequestFields.get('DETTAGLIOFONTE') == null || mapRequestFields.get('DETTAGLIOFONTE') == '') ||
            (mapRequestFields.get('AGENZIA') == null || mapRequestFields.get('AGENZIA') == '') ||
            (mapRequestFields.get('EMAIL') == null || mapRequestFields.get('EMAIL')== '') ||
            (mapRequestFields.get('NOME') == null || mapRequestFields.get('NOME')== '') ||
            (mapRequestFields.get('COGNOME') == null || mapRequestFields.get('COGNOME')== '')){
                isValidated= false;
            }
            
            if(isValidated){
                HDT_QR_Contact conQr = new HDT_QR_Contact();
                String contactId = '';
                ContactPointEmail cntEmail = HDT_QR_ContactPoint.searchContactPointEmailSOL(mapRequestFields.get('EMAIL'));
                if(cntEmail != null ){
                    Contact con = conQr.getContactsByIndividual(cntEmail.parentId);
                    contactId = con != null ? con.id : '';
                }
                
                //List<Campaign> campaign= HDT_QR_Campaign.getCampaignIds('LEAD CALLBACK');
                List<Campaign> campaign= HDT_QR_Campaign.campaignByNameMacroActivityEasyCIM(mapRequestFields.get('NOMEMACROACTIVITYEASYCIM'));//HRDTR-00_HRAWRM-907 18/10/2021
                if(campaign != null && !campaign.isEmpty()){
                    Lead newLead= new Lead();
                    //!newLead.Company__c='HC'; //HRAWRM-803 01/10/2021 
                    newLead.Company__c= mapRequestFields.get('COMPANY'); //HRAWRM-841 05/10/2021
                    newLead.recordTypeId=leadRecordTypeId;
                    newLead.CompanyOwner__c= mapRequestFields.get('COMPANYOWNER');
                    newLead.Phone= mapRequestFields.get('TELEFONO');
                    newLead.LeadSource= mapRequestFields.get('FONTE');
                    if(contactId != null && contactId != ''){
                        newLead.Contact__c = contactId;
                    }
                    newLead.CollectionAgency__c	= mapRequestFields.get('AGENZIA');//HRAWRM-840 Bolzon 05/10/2021
                    if(mapRequestFields.get('CELLULARE').left(1) == '3'){
                        newLead.MobilePhone= mapRequestFields.get('CELLULARE');
                    }
                    else{
                        newLead.Phone= mapRequestFields.get('CELLULARE');
                    }
                    newLead.Email= mapRequestFields.get('EMAIL');
                    newLead.State= mapRequestFields.get('COMUNE');
                    newLead.FirstName= mapRequestFields.get('NOME');
                    newLead.PostalCode= mapRequestFields.get('CAP');
                    newLead.LastName= mapRequestFields.get('COGNOME');
                    newLead.Street= mapRequestFields.get('INDIRIZZO');
                    newLead.City= mapRequestFields.get('CITTA');
                    newLead.FiscalCode__c= mapRequestFields.get('CODICEFISCALE');
                    newLead.VATNumber__c= mapRequestFields.get('PARTIVAIVA');
                    newLead.WebFormField01__c = mapRequestFields.get('CAMPO_01');
                    newLead.WebFormField02__c = mapRequestFields.get('CAMPO_02');
                    newLead.WebFormField03__c = mapRequestFields.get('CAMPO_03');
                    newLead.WebFormField04__c = mapRequestFields.get('CAMPO_04');
                    newLead.WebFormField05__c = mapRequestFields.get('CAMPO_05');
                    newLead.WebFormField06__c = mapRequestFields.get('CAMPO_06');
                    newLead.WebFormField07__c = mapRequestFields.get('CAMPO_07');
                    newLead.WebFormField08__c = mapRequestFields.get('CAMPO_08');
                    newLead.WebFormField09__c = mapRequestFields.get('CAMPO_09');
                    newLead.WebFormField10__c = mapRequestFields.get('CAMPO_10');
                    newLead.WebFormField11__c = mapRequestFields.get('CAMPO_11');
                    newLead.WebFormField12__c = mapRequestFields.get('CAMPO_12');
                    newLead.WebFormField13__c = mapRequestFields.get('CAMPO_13');
                    newLead.WebFormField14__c = mapRequestFields.get('CAMPO_14');
                    newLead.WebFormField15__c = mapRequestFields.get('CAMPO_15');
                    newLead.WebFormField16__c = mapRequestFields.get('CAMPO_16');
                    newLead.WebFormField17__c = mapRequestFields.get('CAMPO_17');
                    newLead.WebFormField18__c = mapRequestFields.get('CAMPO_18');
                    newLead.WebFormField19__c = mapRequestFields.get('CAMPO_19');
                    newLead.WebFormField20__c = mapRequestFields.get('CAMPO_20');
                    newLead.WebFormField21__c = mapRequestFields.get('CAMPO_21');
                    newLead.WebFormField22__c = mapRequestFields.get('CAMPO_22');
                    newLead.WebFormField23__c = mapRequestFields.get('CAMPO_23');
                    newLead.WebFormField24__c = mapRequestFields.get('CAMPO_24');
                    newLead.WebFormField25__c = mapRequestFields.get('CAMPO_25');
                    newLead.WebFormField26__c = mapRequestFields.get('CAMPO_26');
                    newLead.WebFormField27__c = mapRequestFields.get('CAMPO_27');
                    newLead.WebFormField28__c = mapRequestFields.get('CAMPO_28');
                    newLead.WebFormField29__c = mapRequestFields.get('CAMPO_29');
                    newLead.WebFormField30__c = mapRequestFields.get('CAMPO_30');
                    newLead.WebFormField31__c = mapRequestFields.get('CAMPO_31');
                    newLead.WebFormField32__c = mapRequestFields.get('CAMPO_32');
                    newLead.WebFormField33__c = mapRequestFields.get('CAMPO_33');
                    newLead.WebFormField34__c = mapRequestFields.get('CAMPO_34');
                    newLead.WebFormField35__c = mapRequestFields.get('CAMPO_35');
                    newLead.WebFormField36__c = mapRequestFields.get('CAMPO_36');
                    newLead.WebFormField37__c = mapRequestFields.get('CAMPO_37');
                    newLead.WebFormField38__c = mapRequestFields.get('CAMPO_38');
                    newLead.WebFormField39__c = mapRequestFields.get('CAMPO_39');
                    newLead.WebFormField40__c = mapRequestFields.get('CAMPO_40');
                    newLead.CustomerMarking__c= mapRequestFields.get('MARCATURA');
                    newLead.Category__c= mapRequestFields.get('CATEGORIA');
                    newLead.ContactReason__c='Info commerciali';//HRAWRM-388 03-09-2021

                    newLead.Company= newLead.FirstName+ ' '+newLead.LastName;
                    
                    HDT_SRV_Lead.checkCreateAccess(newLead);
                    Lead l = HDT_SRV_Lead.createRecord(newLead);
                    Lead ctl= leadQr.getRecordById(l.Id);
                    
                    Individual indv= indvQr.getRecordById(ctl.IndividualId, 'Id, MarketingPrivacy__c, MarketingPrivacyVersion__c, PrivacyMarketingChoiceSource__c,PrivacyMarketingConsentInitiative__c, MarketingCompanyConsent__c,PrivacyMarketingChoiceDate__c');
                    indv.MarketingPrivacy__c= mapRequestFields.get('CONSENSOMARKETING');
                    indv.PrivacyMarketingConsentInitiative__c= mapRequestFields.get('INIZIATIVACONSMARK'); // HRAWRM-919 25/10/2021
                    indv.MarketingCompanyConsent__c= mapRequestFields.get('COMPANYCONSENSOMARKETING');
                    indv.MarketingPrivacyVersion__c= mapRequestFields.get('VERSINFOMARKET');
                    indv.PrivacyMarketingChoiceSource__c= mapRequestFields.get('FONTECONSENSOMRK');
                    indv.PrivacyMarketingChoiceDate__c = ('SI'.equalsIgnoreCase( indv.MarketingPrivacy__c) ||'NO'.equalsIgnoreCase( indv.MarketingPrivacy__c)  )?  Date.today():indv.PrivacyMarketingChoiceDate__c; //HRDTR-00_HRAWRM-803 01/10/2021
                    HDT_SRV_Individual.checkUpdateAccess(indv);
                    HDT_SRV_Individual.updateRecord(indv);
                    
                    Account ac= acQr.getAccountByName(mapRequestFields.get('AGENZIA'));
                    Id campaignId= null;
                    Datetime d= null;
                    String macroactivity= null;
                    
                    if(campaign.size()>1){
                        for(Campaign c: campaign){
                            if(d==null || c.CreatedDate>d) {
                                d = c.CreatedDate;
                                campaignId =c.ID;
                                macroactivity= c.MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
                            }
                        }
                    }else{
                        campaignId = campaign[0].Id;
                        macroactivity= campaign[0].MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
                    }
                    CampaignMember cm = new CampaignMember(CampaignId= campaignId, Agency__c= ac.Id, LeadId= l.Id, phonenumber__c = mapRequestFields.get('CELLULARE'));
                    cmSrv.createRecord(cm);

                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'OK';
                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
                    mrrResponseItem.objects.add(responseObject);
                    RestContext.response.statusCode = 200;
                    return mrrResponseItem;
                }
                else{
                   /* responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'KO';
                    responseFieldError.fieldType = 'TEXT';
                    responseFieldError.name = 'ERROR_MESSAGE';
                    responseFieldError.value = 'Campaign Not Found';
                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                    mrrResponseItem.objects.add(responseObject);
                    RestContext.response.statusCode = 400;*/
                    campaignNotFound( request, mrrResponseItem, responseObject,responseField,responseFieldError);//HRDTR-00_HRAWRM-907 18/10/2021
                    return mrrResponseItem;
                }
                
            }else{
                responseField.fieldType = 'TEXT';
                responseField.name = 'ESITO';
                responseField.value = 'KO';
                responseFieldError.fieldType = 'TEXT';
                responseFieldError.name = 'ERROR_MESSAGE';
                responseFieldError.value = 'Campi Obbligatori Mancanti!';
                responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
                mrrResponseItem.objects.add(responseObject);
                RestContext.response.statusCode = 400;
                return mrrResponseItem;
            }
        }else{
            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'KO';
            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = 'There was an issue with your request message';
            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
            mrrResponseItem.objects.add(responseObject);
            RestContext.response.statusCode = 400;
            return mrrResponseItem;
            
        }
        
    }
    
    @TestVisible
    //HRDTR-00_HRAWRM-907 18/10/2021
    private static void campaignNotFound(HDT_WRP_MrrRequest.HDT_WRP_Request request, HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem,HDT_WRP_MrrResponse.HDT_WRP_Object responseObject, HDT_WRP_MrrResponse.HDT_WRP_Field responseField,HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError){


        responseField.fieldType = 'TEXT';
        responseField.name = 'ESITO';
        responseField.value = 'KO';
        responseFieldError.fieldType = 'TEXT';
        responseFieldError.name = 'ERROR_MESSAGE';
        responseFieldError.value = 'Campaign Not Found';
        responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
        mrrResponseItem.objects.add(responseObject);
        RestContext.response.statusCode = 400;
    }//HRDTR-00_HRAWRM-907 18/10/2021
    public static Datetime getDateTimeFromString(String stringDateTime ){
        if (String.isBlank(stringDateTime)) {
            return null;
        }
        // "2021-08-20T13:00:00Z"
        List<String> dateTimeSplit = stringDateTime.split('-');
        Integer day=Integer.valueOf(dateTimeSplit.get(2).left(2));
        Integer month=Integer.valueOf(dateTimeSplit.get(1));
        Integer year=Integer.valueOf(dateTimeSplit.get(0));
        
        List<String> myTime =dateTimeSplit[2].split(':');
        Integer hour=Integer.valueOf(myTime.get(0).substringAfter('T'));
        Integer minutes=Integer.valueOf(myTime.get(1).replace('Z', ''));
         
       /* System.debug('year : '+year);
        System.debug('month : '+month);
        System.debug('day : '+day);
        System.debug('hour : '+hour);
        System.debug('minutes : '+minutes);*/
        DateTime myDateTime = DateTime.newInstance(year, month, day, hour, minutes, 0);
        Timezone tz = Timezone.getTimeZone('Europe/Rome');
        Integer diff= (tz.getOffset(myDateTime)/1000)/60;
        DateTime newDateTime = myDateTime.addMinutes(diff);

       // System.debug('targetDatetime '+newDateTime);
        return newDateTime;
    }
}