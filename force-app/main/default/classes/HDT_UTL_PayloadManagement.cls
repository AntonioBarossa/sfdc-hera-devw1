public with sharing class HDT_UTL_PayloadManagement implements HDT_UTL_DocumentalManagementInterface{
    public HDT_QR_PayloadManagement queryClass = new HDT_QR_PayloadManagement();
    public String execute(String method,Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        String result = '';
        try {
            switch on method {
                when 'calculateCompanyCode' {
                    return calculateCompanyCode(inputs,formParams);
                }when 'checkQuotationType'{
                    return checkQuotationType(inputs,formParams);
                }when 'calculateQuotationAmount'{
                    return calculateQuotationAmount(inputs,formParams);
                }when 'checkGruppoIva'{
                    return checkGruppoIva(inputs,formParams);
                }when 'checkCommercialOffer'{
                    return checkCommercialOffer(inputs,formParams);
                }
                when else {
                    return '';
                }
            }
        } catch (Exception ex) {
            System.debug('Si è verificato un errore nel richiamo del metodo ' + method + ': ' + ex.getMessage() + ' alla riga ' + ex.getLineNumber());
        }
        return result;
    }

    private String calculateCompanyCode(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        //TODO: Gestione Account e Estratto Conto
        String context = (String) formParams.get('Contesto');
        String companyDesc = '';
        String city = '';
        switch on context {
            when 'Order' {
                companyDesc = 'Hera Comm S.p.A.';
                companyDesc = HDT_UTL_DocumentalManagement.getValue('Order', 'SalesCompany__c', 0, inputs, formParams);
                city = HDT_UTL_DocumentalManagement.getValue('Order', 'SupplyCity__c', 0, inputs, formParams);
                List<HDT_HcmCityException__mdt> cityExceptionList = queryClass.getHcmCityExceptionByName(city);
                if (cityExceptionList != null && cityExceptionList.size()>0) {
                    companyDesc = 'Hera Comm S.p.A.';
                }
            }
            when 'Case'{
                companyDesc = HDT_UTL_DocumentalManagement.getValue('Case', 'SalesCompany__c', 0, inputs, formParams);
            }
            when 'Account'{
                //gestire in base al compani owner
                companyDesc = HDT_UTL_DocumentalManagement.getValue('Account', 'CompanyOwner__c', 0, inputs, formParams);
                if(companyDesc.equalsIgnoreCase('HERA COMM')){
                    companyDesc = 'Hera Comm S.p.A.';
                }
            }
            when else {
                companyDesc = '';
            }
        }
        return getCompanyCode(companyDesc);
    }

    private String getCompanyCode(String companyDesc){
        if(companyDesc==null || String.isBlank(companyDesc)) return '';
        String queryString = 'SELECT id,Label, CompanyCode__c from HDT_HeraCompany__mdt WHERE Label=\''+companyDesc+'\'';
        String objectName = 'HDT_HeraCompany__mdt';
        List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        if(recordList != null && recordList.size()>0){
            return (String) recordList[0].get('CompanyCode__c');
        }else {
            return '';
        }
    }

    private String checkQuotationType(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        String context = (String) formParams.get('Contesto');
        String quotationType='';
        String processType = '';
        String cluster='';
        switch on context {
            when 'Case' {
                quotationType = HDT_UTL_DocumentalManagement.getValue('Case', 'QuotationType__c', 0, inputs, formParams);
                processType = HDT_UTL_DocumentalManagement.getValue('Case', 'DocumentalProcessType__c', 0, inputs, formParams);
                cluster = HDT_UTL_DocumentalManagement.getValue('Case', 'Cluster__c', 0, inputs, formParams);
            }
            when else {
                quotationType = ''; //da ordine manca il campo
                processType =  HDT_UTL_DocumentalManagement.getValue('Order', 'ProcessType__c', 0, inputs, formParams);
                cluster = HDT_UTL_DocumentalManagement.getValue('Order', 'Cluster__c', 0, inputs, formParams);
            }
        }
        //aggiungere cluster attivazioni
        if(cluster.equalsIgnoreCase('Preventivi') || cluster.equalsIgnoreCase('Verifiche')){
            if(quotationType.equalsIgnoreCase('Predeterminabile')){
                return 'SIP';
            }else if(quotationType.equalsIgnoreCase('Rapido') && processType.equalsIgnoreCase('Aumento Potenza')){
                return 'NOP';
            }else if(quotationType.equalsIgnoreCase('Rapido') && processType.equalsIgnoreCase('Diminuzione Potenza')){
                return 'POT';
            }else if(quotationType.equalsIgnoreCase('Predeterminabile')) {
                return 'SIP';
            }else {
                return '';
            }
        }else {
            return '';
        }
    }
    private String calculateQuotationAmount(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        //imponibile = importo preventivo
        //aliquota iva
        //prestazione=(imponibile-contributo);
        //totale=(imponibile+valIva);
        //valIva=((imponibile/100)*aliquota);
        String context = (String) formParams.get('Contesto');
        String amount='';
        Double amountDouble;
        Integer ivaInteger = 0;
        String iva = '';
        Double ivaAmount=0;
        String fixedAmount = '';
        String variableAmount = '';
        Double totalAmount;
        String result='';
        switch on context {
            when 'Case' {
                amount = HDT_UTL_DocumentalManagement.getValue('Case', 'Amount__c', 0, inputs, formParams);
                fixedAmount = HDT_UTL_DocumentalManagement.getValue('Case', 'FixedAmount__c', 0, inputs, formParams);
                variableAmount = HDT_UTL_DocumentalManagement.getValue('Case', 'VariableAmount__c', 0, inputs, formParams);
                iva = HDT_UTL_DocumentalManagement.getValue('Case', 'VATPercentage__c', 0, inputs, formParams);
            }
            when else {
                //quotationType = ''; //da ordine manca il campo
                //processType =  HDT_UTL_DocumentalManagement.getValue('Order', 'ProcessType__c', 0, inputs, formParams);
            }
        }
        if(String.isNotBlank(amount)){
            amountDouble = Double.valueOf(amount);
            if(String.isNotBlank(iva)){
                if(iva.indexOf('10') > -1){
                    ivaInteger = 10;
                }else if(iva.indexOf('22') > -1){
                    ivaInteger = 22;
                }
                if(ivaInteger > 0)
                    ivaAmount = ((amountDouble/100)*ivaInteger);
            }
            totalAmount = amountDouble + ivaAmount;
            result = variableAmount + '|' + fixedAmount + '|' + amount + '|' + ivaInteger + '|' + ivaAmount + '|' + totalAmount;
        }else {
            result = '|||||';
        }
        
        return result;
    }

    private String checkGruppoIva(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        String gPiva = HDT_UTL_DocumentalManagement.getValue('Account', 'VATGroup__c', 0, inputs, formParams);//VATGroup__c
        String startPiva = HDT_UTL_DocumentalManagement.getValue('Account', 'VATGroupStartDate__c', 0, inputs, formParams);//VATGroupStartDate__c
        String flagPiva = HDT_UTL_DocumentalManagement.getValue('Account', 'IsVATGroupJoined__c', 0, inputs, formParams);//IsVATGroupJoined__c
        String endPiva = HDT_UTL_DocumentalManagement.getValue('Account', 'VATGroupEndDate__c', 0, inputs, formParams);//VATGroupEndDate__c
        Date maxDate = date.newInstance(4000, 12, 31);
        if(String.isBlank(flagPiva) || flagPiva.equalsIgnoreCase('false')){
            return '';
        }else if(String.isNotBlank(endPiva) && Date.valueOf(endPiva) == maxDate){
            if(Date.today()> Date.valueOf(startPiva)){
                return gPiva + '|' + HDT_UTL_DocumentalManagement.transformDate(Date.valueOf(startPiva));
            }else {
                return '';
            }
        }else{
            if(Date.today() > Date.valueOf(startPiva) && Date.today() < Date.valueOf(endPiva)){
                return gPiva + '|' + HDT_UTL_DocumentalManagement.transformDate(Date.valueOf(startPiva));
            }else {
                return '';
            }
        }
    }

    private String checkCommercialOffer(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        String offerName = HDT_UTL_DocumentalManagement.getValue('Order', 'ProductName__c', 0, inputs, formParams);//ProductName__c
        String implantType = HDT_UTL_DocumentalManagement.getValue('Order', 'ImplantType__c', 0, inputs, formParams);//ImplantType__c
        String result = '';
        if(String.isNotBlank(offerName)){
            if(offerName.indexOf('Sole Lune') > -1){
                result = 'X|';
            }else {
                result = '|';
            }
            if(offerName.indexOf('24') > -1){
                result += 'X|';
            }else {
                result += '|';
            }
            if(offerName.indexOf('caso A') > -1){
                result += 'X|';
            }else {
                result += '|';
            }
            if(offerName.indexOf('caso B') > -1){
                result += 'X|';
            }else {
                result += '|';
            }
        }else {
            result = '||||';
        }
        if(String.isNotBlank(implantType)){
            if (implantType.indexOf('Cottura cibi') > -1) {
                result+='CO|';
            }else if (implantType.indexOf('acq calda') > -1) {
                result+='AC|';
            }else if (implantType.indexOf('Riscaldamento') > -1) {
                result+='RA|';
            }else if (implantType.indexOf('Risc. centraliz') > -1) {
                result+='RC|';
            }else {
                 result +='|';
            }
        }else {
            result += '|';
        }

        if(String.isNotBlank(offerName)){
            if(offerName.indexOf('Bonus') > -1){
                result = 'X|';
            }else {
                result = '|';
            }
            if(offerName.indexOf('Opzione Natura') > -1){
                result = 'X';
            }
        }else {
            result += '|';
        }
        return result;
    }
}
