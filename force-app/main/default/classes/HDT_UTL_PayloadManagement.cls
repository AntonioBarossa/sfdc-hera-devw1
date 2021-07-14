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
                }when 'generateSection20'{
                    return generateSection20(inputs,formParams);
                }when 'generateSection40'{
                    return generateSection40(inputs,formParams);
                }when 'generateSection50'{
                    return generateSection50(inputs,formParams);
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
                city = HDT_UTL_DocumentalManagement.getValue('Case', 'SupplyCity__c', 0, inputs, formParams);
                List<HDT_HcmCityException__mdt> cityExceptionList = queryClass.getHcmCityExceptionByName(city);
                if (cityExceptionList != null && cityExceptionList.size()>0) {
                    companyDesc = 'Hera Comm S.p.A.';
                }
            }
            when 'Account'{
                //gestire in base al compani owner
                companyDesc = HDT_UTL_DocumentalManagement.getValue('Account', 'CompanyOwner__c', 0, inputs, formParams);
                if(companyDesc.equalsIgnoreCase('HERA COMM')){
                    companyDesc = 'Hera Comm S.p.A.';
                }
            }when 'EC','GC'{
                return getCompanyAccountStatement(formParams);
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

    private String getCompanyAccountStatement(Map<String,Object> formParams){
        String result = '1070';
        try{
            String documents = (String) formParams.get('EstrattoConto');
            List<Object> primoLivelloList = (List<Object>)JSON.deserializeUntyped(documents);
            Map<String,Object> primolivello = (Map<String, Object>)primoLivelloList[0];
            List<Object> secondoLivelloList = new List<Object>();
            Map<String, Object> secondoLivello = new Map<String, Object>();
            String hcm = 'HERA COMM MARCHE';
            String newCo = 'ESTENERGY SPA';
            String oldCo = 'HERA COMM NORDEST';
            Boolean societaTemp = false;
            Boolean newCoTemp = false;
            Boolean oldCoTemp = false;
            
            for (Object singleRecord : primoLivelloList) {
                primolivello = (Map<String, Object>) singleRecord;
                String societa = primolivello.get('societa') != null? (String)primolivello.get('societa'):'';
                societa = societa.toUpperCase();
                if(societa.equalsIgnoreCase(hcm)){
                    societaTemp = true;
                }else {
                    societaTemp = false;
                }
                if(societa.equalsIgnoreCase(newCo)){
                    newCoTemp = true;
                }else {
                    newCoTemp = false;
                }
                if(societa.equalsIgnoreCase(oldCo)){
                    oldCoTemp = true;
                }else {
                    oldCoTemp = false;
                }
            }
            if(societaTemp)
                result = '2060';
            else if(newCoTemp) // Migrazione Ascopiave 2019
                result = '7030';// 7030 (NewCo)
            else if(oldCoTemp) // Migrazione Ascopiave 2019
                result = '7015'; // 7015 (OldCo)
            else
                result = '1070';
        }catch(Exception ex){
            System.debug('Errore calcolo società per Estratto Conto');
        }
        return result;
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

    // Genera la sezione di payload ricorsiva 00310|20| per la stampa della Scheda Cliente (sezione "Contratti")
    private String generateSection20(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        String endLine = '\n';
        String div = '|';
        String payloadSection = '';

        String accountId = HDT_UTL_DocumentalManagement.getValue('Account', 'Id', 0, inputs, formParams);

        String objectName = 'Contract';
        String queryFields = 'Id,ContractNumber,BillingProfile__r.ContractAccountCode__c,StartDate,ServicePoint__r.SupplyAddress__c,ServicePoint__r.SAPImplantCode__c,ServicePoint__r.CommoditySector__c,Status';
        String queryString = 'SELECT ' + queryFields;
        String fromString = ' FROM '+ objectName;
        String controllingField = 'AccountId';
        String whereString = ' WHERE ' + controllingField + ' =\''+ accountId + '\'';
        String relatedQueryString = ',(SELECT Id,SBQQ__ProductName__c FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__r.Family = \'Offerta commerciale\')';
        
        queryString = queryString + relatedQueryString + fromString + whereString; 
        System.debug('query ' + queryString);

        List<sObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        for (Integer i = 0; i < recordList.size(); i++) {
            Contract c = (Contract) recordList[i];
            List<SBQQ__Subscription__c> subscriptions = (List<SBQQ__Subscription__c>) c.SBQQ__Subscriptions__r;

            String[] record = new List<String>();
            // Il primo 310|20 è già presente, evitiamo di aggiungerlo una seconda volta.
            if (i > 0) {
                record.add('00310');
                record.add('20');
            }

            record.add(c.ContractNumber);                               // Numero Documento
            record.add(c.BillingProfile__r.ContractAccountCode__c);     // Codice Conto Contrattuale
            record.add(getFormattedDate(c.StartDate));                  // Data stipula
            record.add(c.ServicePoint__r.SupplyAddress__c);             // Indirizzo di fornitura
            record.add(c.ServicePoint__r.SAPImplantCode__c);            // Codice Impianto
            record.add('Contratto');                                    // Tipo (cablato, su Siebel invece era campo ad-hoc)
            record.add(subscriptions[0].SBQQ__ProductName__c);          // Prodotto di servizio
            record.add(c.ServicePoint__r.CommoditySector__c);           // Settore merceologico
            record.add(c.Status);                                       // Stato
            if (i < recordList.size() - 1) {
                record.add(endLine);
            }
            payloadSection += String.join(record, div);
        }

        return payloadSection;
    }

    // Genera la sezione di payload ricorsiva 00310|40| per la stampa della Scheda Cliente (sezione "Richieste di Servizio")
    private String generateSection40(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        String endLine = '\n';
        String div = '|';
        String payloadSection = '';

        List<sObject> cases = inputs.get('CaseList');
        List<sObject> orders = inputs.get('OrderList');
        for (Integer i = 0; i < cases.size(); i++) {
            String[] record = new List<String>();
            // Il primo 310|40 è già presente, evitiamo di aggiungerlo una seconda volta.
            if (i > 0) {
                record.add('00310');
                record.add('40');
            }
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'Origin', i, inputs, formParams));         // Canale
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'CreatedDate', i, inputs, formParams));    // Data ricevimento
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'Type', i, inputs, formParams));           // Sottotipo
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'Cluster__c', i, inputs, formParams));     // Tipo
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'CaseNumber', i, inputs, formParams));     // N. RS
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'Phase__c', i, inputs, formParams));       // Stato
            // Aggiungiamo lo \n finale sempre, tranne quando siamo all'ultimo giro E non abbiamo Order subito dopo.
            if (i != cases.size() - 1) {
                record.add(endLine);
            } else if (i == cases.size() - 1 && !orders.isEmpty()) {
                record.add(endLine);
            }

            payloadSection += String.join(record, div);
        }

        for (Integer i = 0; i < orders.size(); i++) {
            String[] record = new List<String>();
            // Il primo 310|40 è già presente, evitiamo di aggiungerlo una seconda volta.
            // Se i = 0 ma payloadSection è valorizzato, dobbiamo comunque aggiungerlo perchè non siamo più al primo giro.
            if (i > 0 || String.isNotBlank(payloadSection)) {
                record.add('00310');
                record.add('40');
            }
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'Channel__c', i, inputs, formParams));        // Canale
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'CreatedDate', i, inputs, formParams));       // Data ricevimento
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'ProcessType__c', i, inputs, formParams));    // Sottotipo
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'Cluster__c', i, inputs, formParams));        // Tipo
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'OrderNumber', i, inputs, formParams));       // N. RS
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'Phase__c', i, inputs, formParams));          // Stato
            if (i < orders.size() - 1) {
                record.add(endLine);
            }
            payloadSection += String.join(record, div);
        }

        return payloadSection;
    }

    // Genera la sezione di payload ricorsiva 00310|50| per la stampa della Scheda Cliente (sezione "Preventivi")
    private String generateSection50(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        String endLine = '\n';
        String div = '|';
        String payloadSection = '';

        List<sObject> cases = inputs.get('CaseList');
        List<sObject> orders = inputs.get('OrderList');
        for (Integer i = 0; i < cases.size(); i++) {
            String[] record = new List<String>();
            // Il primo 310|50 è già presente, evitiamo di aggiungerlo una seconda volta.
            if (i > 0) {
                record.add('00310');
                record.add('50');
            }
            String createdDate = getFormattedDate(Date.valueOf(HDT_UTL_DocumentalManagement.getValue('CaseList', 'CreatedDate', i, inputs, formParams)));
            record.add(createdDate);                                                                                        // Data Stato
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'Amount__c', i, inputs, formParams));              // Costo
            record.add(createdDate);                                                                                        // Data Doc
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'CaseNumber', i, inputs, formParams));             // Num documento
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'CaseNumber', i, inputs, formParams));             // N. Ordine
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'TensionOption__c', i, inputs, formParams));       // Tipo lavoro
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'CommodityFormula__c', i, inputs, formParams));    // Settore merceologico
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'AddressFormula__c', i, inputs, formParams));      // Indirizzo del lavoro
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'Phase__c', i, inputs, formParams));               // Stato
            if (orders.isEmpty() && i == cases.size() - 1) {
                // SKIP \n 
            }
            // Aggiungiamo lo \n finale sempre, tranne quando siamo all'ultimo giro E non abbiamo Order subito dopo.
            if (i != cases.size() - 1) {
                record.add(endLine);
            } else if (i == cases.size() - 1 && !orders.isEmpty()) {
                record.add(endLine);
            }
            
            payloadSection += String.join(record, div);
        }

        for (Integer i = 0; i < orders.size(); i++) {
            String[] record = new List<String>();
            // Il primo 310|540 è già presente, evitiamo di aggiungerlo una seconda volta.
            // Se i = 0 ma payloadSection è valorizzato, dobbiamo comunque aggiungerlo perchè non siamo più al primo giro.
            if (i > 0 || String.isNotBlank(payloadSection)) {
                record.add('00310');
                record.add('50');
            }
            String createdDate = getFormattedDate(Date.valueOf(HDT_UTL_DocumentalManagement.getValue('OrderList', 'CreatedDate', i, inputs, formParams)));
            record.add(createdDate);                                                                                              // Data Stato
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'EstimateAmount__c', i, inputs, formParams));           // Costo
            record.add(createdDate);                                                                                              // Data Doc
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'OrderNumber', i, inputs, formParams));                 // Num documento
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'OrderNumber', i, inputs, formParams));                 // N. Ordine
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'RequestOption__c', i, inputs, formParams));            // Tipo lavoro
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'CommodityFormula__c', i, inputs, formParams));         // Settore merceologico
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'SupplyAddressFormula__c', i, inputs, formParams));     // Indirizzo del lavoro
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'Phase__c', i, inputs, formParams));                    // Stato
            if (i < orders.size() - 1) {
                record.add(endLine);
            }
            payloadSection += String.join(record, div);
        }

        return payloadSection;
    }

    // Restituisce la data nel formato richiesto da Engage1
    private static String getFormattedDate(Date dateToFormat) {
        Datetime dt = dateToFormat;
        String formattedDate = dt.format('dd/MM/y');
        return formattedDate;
    }
}
