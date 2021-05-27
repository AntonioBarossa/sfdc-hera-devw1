public inherited sharing class HDT_UTL_Product2Process {

    public static HDT_WRP_Product2Process.HDT_WRP_StatusResponse changeStatusHandler(HDT_WRP_Product2Process.HDT_WRP_StatusResponse statusResponse, String productId, Product2 oldProduct, Product2 newProduct, Integer prodOpt, Integer techOff){

        String oldStatus = oldProduct.Status__c;
        String newStatus = newProduct.Status__c;
        String inDevelopment = 'In sviluppo';
        String confirmed = 'Confermata';
        String sold = 'Vendibile';
        String canceled = 'Annullata';
        String expired = 'Scaduta';

        statusResponse = new HDT_WRP_Product2Process.HDT_WRP_StatusResponse();
        statusResponse.success = false;
        statusResponse.message = 'Cambio stato non consentito';

        if(oldStatus.equalsIgnoreCase(inDevelopment)){
            if(newStatus.equalsIgnoreCase(inDevelopment)){
                statusResponse.success = true;
                statusResponse.message = 'NoCheckingRequired';
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(confirmed)){
                statusResponse.success = true;
                statusResponse.message = '';

                if(prodOpt > 0){
                    statusResponse.success = false;
                    statusResponse.message = 'Attenzione devi ricontrollare le Product Option';
                    return statusResponse;
                }

                if(techOff == 0){
                    statusResponse.success = false;
                    statusResponse.message = 'Attenzione non esistono offerte tecniche';
                    return statusResponse;
                }

                List<String> resp;
                resp = HDT_UTL_Product2Process.checkOnDate(resp, newProduct.StartDate__c, newProduct.EndDate__c);
                System.debug('>>> checkOnDate: ' + resp[0] + ' - ' + resp[1]);
                if(resp[0]=='KO'){
                    statusResponse.success = false;
                    statusResponse.message = resp[1];
                }

                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(sold)){
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(canceled)){
                statusResponse.success = true;
                statusResponse.message = 'NoCheckingRequired';
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(expired)){
                return statusResponse;
            }
            
        }	
        
        if(oldStatus.equalsIgnoreCase(confirmed)){
            if(newStatus.equalsIgnoreCase(inDevelopment)){
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(confirmed)){
                statusResponse.success = false;
                statusResponse.message = 'L\'offerta è ' + confirmed + ', non puoi modificarla';
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(sold)){
                statusResponse.success = true;
                statusResponse.message = 'NoCheckingRequired';
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(canceled)){
                statusResponse.success = true;
                statusResponse.message = 'NoCheckingRequired';
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(expired)){
                return statusResponse;
            }
            
        }

        if(oldStatus.equalsIgnoreCase(sold)) {
            if(newStatus.equalsIgnoreCase(inDevelopment)){
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(confirmed)){
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(sold)){
                statusResponse.success = false;
                statusResponse.message = 'L\'offerta è ' + sold + ', non puoi modificarla';
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(canceled)){
                statusResponse.success = true;
                statusResponse.message = 'NoCheckingRequired';
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(expired)){
                statusResponse.success = true;
                statusResponse.message = 'NoCheckingRequired';
                return statusResponse;
            }
            
        }

        if(oldStatus.equalsIgnoreCase(canceled)) {
            if(newStatus.equalsIgnoreCase(inDevelopment)){
                statusResponse.success = true;
                statusResponse.message = 'NoCheckingRequired';
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(confirmed)){
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(sold)){
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(canceled)){
                statusResponse.success = false;
                statusResponse.message = 'L\'offerta è ' + canceled + ', non puoi modificarla';
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(expired)){
                return statusResponse;
            }
            
        }
        
        if(oldStatus.equalsIgnoreCase(expired)) {
            if(newStatus.equalsIgnoreCase(inDevelopment)){
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(confirmed)){
                statusResponse.success = true;
                statusResponse.message = '';

                List<String> resp;
                resp = HDT_UTL_Product2Process.checkOnDate(resp, newProduct.StartDate__c, newProduct.EndDate__c);
                System.debug('>>> checkOnDate: ' + resp[0] + ' - ' + resp[1]);
                if(resp[0]=='KO'){
                    statusResponse.success = false;
                    statusResponse.message = resp[1];
                }

                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(sold)){
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(canceled)){
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(expired)){

                statusResponse.success = true;
                statusResponse.message = '';

                Set<String> fieldSetToSkip = new Set<String>();
                fieldSetToSkip.add('StartDate__c'.toLowerCase());
                fieldSetToSkip.add('EndDate__c'.toLowerCase());

                String fieldChanged;

                try{
                    fieldChanged = checkIfRecordIsChanged(oldProduct, newProduct, fieldSetToSkip);
                    if(!String.isEmpty(fieldChanged)){
                        System.debug('>>>> RECORD CHANGE -> FIELD: ' + fieldChanged);
                        statusResponse.success = false;
                        statusResponse.message = 'Puoi modificare solo Data inizio e Data fine';
                    }

                    List<String> resp;
                    resp = HDT_UTL_Product2Process.checkOnDate(resp, newProduct.StartDate__c, newProduct.EndDate__c);
                    System.debug('>>> checkOnDate: ' + resp[0] + ' - ' + resp[1]);
                    if(resp[0]=='KO'){
                        statusResponse.success = false;
                        statusResponse.message = resp[1];
                    }
                    
                } catch(Exception ex){
                    statusResponse.success = false;
                    statusResponse.message = '> ERROR: ' + ex.getMessage() + ', at line [' + String.valueOf(ex.getLineNumber()) + ']';
                    return statusResponse;
                }

                return statusResponse;
            }
            
        }
        return statusResponse;
        
    }

    private static String checkIfRecordIsChanged(Product2 oldProduct, Product2 newProduct, Set<String> fieldSetToSkip){

        Product2 prodObject = new Product2();
        Schema.SObjectType objType = prodObject.getSObjectType();
        Map<String, Schema.SObjectField> objMap = Schema.SObjectType.Product2.fields.getMap();

        for (String currentField : objMap.keyset()) {
            if(!fieldSetToSkip.contains(currentField)) {
                if(newProduct.get(currentField) != oldProduct.get(currentField)){
                    return currentField;
                }
            }
        }
        return '';

    }

    public static List<String> checkOnDate(List<String> resp, Date startDate, Date endDate){

        resp = new List<String>();

        if(startDate == null){
            resp.add('KO');
            resp.add('Devi inserire una data inizio');
            return resp;
        }

        if(endDate == null){
            resp.add('KO');
            resp.add('Devi inserire una data fine');
            return resp;
        }

        if(startDate <= Date.today()){
            resp.add('KO');
            resp.add('La data inizio deve essere maggiore della data attuale');
            return resp;
        }

        if(startDate >= endDate){
            resp.add('KO');
            resp.add('La data fine non può essere inferiore a quella di fine');
            return resp;
        }

        resp.add('OK');
        resp.add('OK');
        return resp;

    }

    public static List<String> chechProductToConfirm(List<String> resp, Id ProductId){
        resp = new List<String>();
        resp.add('OK');
        resp.add('OK');
        return resp; 
    }

    public static Map<Id, Integer> generateTechnicalOfferMap(Map<Id, Integer> technicalOfferMap, Set<Id> product2IdList){
        technicalOfferMap = new Map<Id, Integer>();
        List<TechnicalOffer__c> technicalOfferList;

        for(Id i: product2IdList){
            technicalOfferMap.put(i, 0);
        }

        technicalOfferList = getTechnicalOffer(technicalOfferList, product2IdList);

        for(TechnicalOffer__c techOff : technicalOfferList){
            if(technicalOfferMap.containsKey(techOff.Product__c)){
                Integer i = technicalOfferMap.get(techOff.Product__c);
                i++;
                technicalOfferMap.put(techOff.Product__c, i);
            }
        }
        return technicalOfferMap;
    }

    private static List<TechnicalOffer__c> getTechnicalOffer(List<TechnicalOffer__c> technicalOfferList, Set<Id> product2IdList){
        technicalOfferList = new List<TechnicalOffer__c>();
        technicalOfferList = [
            SELECT Id, SapCode__c, Status__c, Product__c
            FROM TechnicalOffer__c
            WHERE Product__c IN :product2IdList
            AND SapCode__c != null AND SapCode__c != ''
            AND Status__c = 'Status OK'
        ];
        return technicalOfferList;
    }

    public static Map<Id, Integer> generateProductOptionMap(Map<Id, Integer> productOptionMap, Set<Id> product2IdList){
        productOptionMap = new Map<Id, Integer>();

        for(Id i: product2IdList){
            productOptionMap.put(i, 0);
        }

        List<SBQQ__ProductOption__c> productOptionList;
        productOptionList = getProductOption(productOptionList, product2IdList, 'Vendibile');

        for(SBQQ__ProductOption__c prodOpt : productOptionList){
            if(productOptionMap.containsKey(prodOpt.SBQQ__ConfiguredSKU__c)){
                Integer i = productOptionMap.get(prodOpt.SBQQ__ConfiguredSKU__c);
                i++;
                productOptionMap.put(prodOpt.SBQQ__ConfiguredSKU__c, i);
            }
        }
        return productOptionMap;
    }

    private static List<SBQQ__ProductOption__c> getProductOption(List<SBQQ__ProductOption__c> productOptionList, Set<Id> product2IdList, String status){
        productOptionList = new List<SBQQ__ProductOption__c>();
        productOptionList = [
            SELECT Id, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Status__c
            FROM SBQQ__ProductOption__c
            WHERE SBQQ__ConfiguredSKU__c IN :product2IdList
            AND SBQQ__OptionalSKU__r.Status__c != :status
        ];
        return productOptionList;
    }
}