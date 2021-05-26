public inherited sharing class HDT_UTL_Product2Process {

    public static HDT_WRP_Product2Process.HDT_WRP_StatusResponse changeStatusHandler(HDT_WRP_Product2Process.HDT_WRP_StatusResponse statusResponse, String productId, Product2 oldProduct, Product2 newProduct){

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
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(sold)){
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(canceled)){
                return statusResponse;
            }

            if(newStatus.equalsIgnoreCase(expired)){

                String fieldChanged = checkIfRecordIsChanged(oldProduct, newProduct);
                statusResponse.success = true;
                statusResponse.message = '';

                if(!String.isEmpty(fieldChanged) && !fieldChanged.equalsIgnoreCase('EndDate__c') && !fieldChanged.equalsIgnoreCase('StartDate__c')){
                    System.debug('>>>> RECORD CHANGE -> FIELD: ' + fieldChanged);
                    statusResponse.success = false;
                    statusResponse.message = 'Puoi modificare solo le date';
                } 

                return statusResponse;
            }
            
        }
        return statusResponse;
        
    }

    public static String checkIfRecordIsChanged(Product2 oldProduct, Product2 newProduct){

        Product2 prodObject = new Product2();
        Schema.SObjectType objType = prodObject.getSObjectType();
        Map<String, Schema.SObjectField> objMap = Schema.SObjectType.Product2.fields.getMap();

        for (String currentField : objMap.keyset()) {
           try {
               if(newProduct.get(currentField) != oldProduct.get(currentField)){
                   return currentField;
               }
           } catch (Exception e) {
               return '';
           }
        }
        return '';

    }

}