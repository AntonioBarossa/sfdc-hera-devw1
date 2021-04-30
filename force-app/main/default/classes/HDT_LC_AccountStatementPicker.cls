public with sharing class HDT_LC_AccountStatementPicker {
    @AuraEnabled
    public static String getStatements(String params)
    {   
        String response = submitRequest(params);
        String data = manageResponse(response);
        return data;
    }

    @AuraEnabled
    public static String getDocumentSelected(String caseId)
    {  
        System.debug('### CASE ' + caseId);
        List<SObject> documentSelected = HDT_SRV_DocumentSelectedManager.getDocumentsSelected(caseId);
        if(documentSelected.size()>0){
            return JSON.serialize(documentSelected);
        }else {
            return null;
        }
    }


    private static String manageResponse(String response){
        if(response == null)return null;
        //Map<String,String> toReturn = new Map<String,String>();
        Map<String,Object> body = (Map<String,Object>) JSON.deserializeUntyped(response);
        Map<String,Object> prestazione = (Map<String,Object>) body.get('prestazione');
        List<Object> posizioni = (List<Object>) prestazione.get('posizioni');
        if(posizioni.size()>0){
            Map<String,String> invoiceTranscodeMap = new Map<String,String>();
            Map<String,String> companyTranscodeMap = new Map<String,String>();
            invoiceTranscodeMap = getInvoiceTypeLabel();
            companyTranscodeMap = getCompanyLabel();
            for(Object single : posizioni){
                Map<String, Object> posizione = (Map<String, Object>)single;
                if(posizione.get('tipoDoc') != null && posizione.get('tipoDoc') != ''){
                    String tipoDocDesc = invoiceTranscodeMap.get((String)posizione.get('tipoDoc'));
                    posizione.put('tipoDocDesc',tipoDocDesc);
                }
                if(posizione.get('socEmittente') != null && posizione.get('socEmittente') != ''){
                    String companyDesc = companyTranscodeMap.get((String)posizione.get('socEmittente'));
                    posizione.put('socEmittenteDesc',companyDesc);
                }
                posizione.put('contoContrattuale',prestazione.get('codContoContratto'));
                transcodeAmount(posizione);
            }
        }else{
            return null;
        }
        System.debug('Posizioni ' + JSON.serialize(posizioni));
        return JSON.serialize(posizioni);
    }

    private static void transcodeAmount(Map<String, Object> posizione){
        String totale = (String)posizione.get('totPagare');
        String residuo = (String)posizione.get('residuo');
        String totDocumento = (String)posizione.get('totFattura');
        String canoneRai = (String)posizione.get('restituzioneCanoneRai');

        if(totale != '' && totale != null && totale != 'undefined'){
			if(totale.indexOf('-') > -1){
				totale = totale.replace('-','');
				totale = '-'+totale;
                posizione.put('totPagare',totale);
			}
            
		}
		if(residuo != '' && residuo != null && residuo != 'undefined'){
			if(residuo.indexOf('-') > -1){
				residuo = residuo.replace('-','');
				residuo = '-'+residuo;
                posizione.put('residuo',residuo);
			}
		}
		if(totDocumento != '' && totDocumento != null && totDocumento != 'undefined'){
			if(totDocumento.indexOf('-') > -1){
				totDocumento = totDocumento.replace('-','');
				totDocumento = '-'+totDocumento;
                posizione.put('totFattura',totDocumento);
			}
		}
		if(canoneRai != '' && canoneRai != null && canoneRai != 'undefined'){
			if(canoneRai.indexOf('-') > -1){
				canoneRai = canoneRai.replace('-','');
				canoneRai = '-'+canoneRai;
                posizione.put('restituzioneCanoneRai',canoneRai);
			}
		}

    }
    private static String submitRequest(String params){
        HttpRequest req = new HttpRequest();
        try {
            req.setEndpoint('Callout:MulesoftEqualStatements');
            req.setMethod('POST');
            req.setBody(params);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            return res.getBody();
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        return null;
    }

    private static Map<String,String> getInvoiceTypeLabel(){
        String queryString = 'SELECT id,Label, InvoiceCode__c from HDT_InvoiceType__mdt';
        String objectName = 'HDT_InvoiceType__mdt';
        List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        Map<String,String> mapCodeValue = new Map<String,String>();
        for(SObject single : recordList){
            HDT_InvoiceType__mdt record = (HDT_InvoiceType__mdt) single;
            mapCodeValue.put(record.InvoiceCode__c, record.Label);
        }
        return mapCodeValue;
    }

    private static Map<String,String> getCompanyLabel(){
        String queryString = 'SELECT id,Label, CompanyCode__c  from HDT_HeraCompany__mdt';
        String objectName = 'HDT_HeraCompany__mdt';
        List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        Map<String,String> mapCodeValue = new Map<String,String>();
        for(SObject single : recordList){
            HDT_HeraCompany__mdt record = (HDT_HeraCompany__mdt) single;
            mapCodeValue.put(record.CompanyCode__c, record.Label);
        }
        return mapCodeValue;
    }
}
