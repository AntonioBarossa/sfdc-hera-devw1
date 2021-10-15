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
                }when 'generateSection70'{
                    return generateSection70(inputs,formParams);
                }when 'generateSectionReclami'{
                    return generateSectionReclami(inputs,formParams);
                }when 'handleFlagDeliveryAddress'{
                    return handleFlagDeliveryAddress(inputs,formParams);
                }when 'handleFlagPaperless' {
                    return handleFlagPaperless(inputs,formParams);
                }when 'calculateSignModeDriver' {
                    return calculateSignModeDriver(inputs,formParams);
                }when 'calculateDriverCatalogo'{
                    return calculateDriverCatalogo(inputs,formParams);
                }when 'handleAmountVas'{
                    return handleAmountVas(inputs,formParams);
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
    
    
    @TestVisible
    private String handleAmountVas(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        try{
            List<SObject> itemVasList = inputs.get('ItemVAS');
            System.debug('itemVasList: ' + itemVasList);
            
            Double amountNoIva = 0;
            Double fixedAmountNoIva = 0;
            Integer quantity = 0;
            if (itemVasList == null) return '||';
            Integer i = 0;
            for (SObject singleVas : itemVasList) {
                amountNoIva += Double.valueOf(HDT_UTL_DocumentalManagement.getValue('ItemVAS', 'UnitPrice', i, inputs, formParams));
                fixedAmountNoIva += Double.valueOf(HDT_UTL_DocumentalManagement.getValue('ItemVAS', 'PriceNetDiscounted__c', i, inputs, formParams));
                quantity += Integer.valueOf(HDT_UTL_DocumentalManagement.getValue('ItemVAS', 'Quantity', i, inputs, formParams));
                i++;
            }
            
            return amountNoIva + '|' + fixedAmountNoIva + '|' + quantity;
        } catch (Exception ex) {
            return '||';
        }
        
    }
    
    
    private String handleFlagDeliveryAddress(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        String context = (String) formParams.get('Contesto');
        if(!context.equalsIgnoreCase('Order')) return '';
        String contractCode = HDT_UTL_DocumentalManagement.getValue('Order', 'ContractId', 1, inputs, formParams);
        if(String.isNotBlank(contractCode))return '';
        String accountAddress = HDT_UTL_DocumentalManagement.getValue('Order', 'ResidentialStreetName__c', 1, inputs, formParams);
        String deliveryAddress = HDT_UTL_DocumentalManagement.getValue('Order', 'ShippingStreetName__c', 1, inputs, formParams);
        String supplyAddress = HDT_UTL_DocumentalManagement.getValue('Order', 'SupplyStreetName__c', 1, inputs, formParams);
        if(supplyAddress.equalsIgnoreCase(supplyAddress)) return 'IF';
        if(supplyAddress.equalsIgnoreCase(accountAddress)) return 'SL';

        return '';
    }

    private String handleFlagPaperless(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        String isPaperless = 'N';
        String context = (String) formParams.get('Contesto');
        if(!context.equalsIgnoreCase('Case')) return isPaperless;
        String processType = HDT_UTL_DocumentalManagement.getValue('Case', 'Type', 0, inputs, formParams);
        String depositPaymentMode = HDT_UTL_DocumentalManagement.getValue('Case', 'DepositPaymentMode__c', 0, inputs, formParams);
        if(String.isBlank(processType)) return isPaperless;
        if (processType == 'Paperless' || (processType == 'Piano Rateizzazione' && depositPaymentMode == 'Paperless')){
            isPaperless = 'Y';
        }
        return isPaperless;
    }

    private String calculateCompanyCode(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        //TODO: Gestione Account e Estratto Conto
        String context = (String) formParams.get('Contesto');
        String companyDesc = '';
        String city = '';
        String distributorName = '';
        String commodity = '';
        switch on context {
            when 'Order' {
                companyDesc = HDT_UTL_DocumentalManagement.getValue('Order', 'SalesCompany__c', 0, inputs, formParams);
                city = HDT_UTL_DocumentalManagement.getValue('Order', 'SupplyCity__c', 0, inputs, formParams);
                distributorName = HDT_UTL_DocumentalManagement.getValue('Order', 'DistributorFormula__c', 0, inputs, formParams);
                commodity = HDT_UTL_DocumentalManagement.getValue('Order', 'CommodityFormula__c', 0, inputs, formParams);
                List<HDT_HcmCityException__mdt> cityExceptionList = queryClass.getHcmCityExceptionByName(city, commodity);
                if (cityExceptionList != null && cityExceptionList.size()>0) {
                    List<HDT_DistributorExceptionHC__mdt> distributorList = queryClass.getHcDistributorExceptionByName(distributorName);
                    if (distributorList != null && distributorList.size()>0) {
                        companyDesc = 'Hera Comm S.p.A.';
                    } else {
                        companyDesc = 'Hera Comm Marche';
                    }
                }
            }
            when 'Case'{
                companyDesc = HDT_UTL_DocumentalManagement.getValue('Case', 'SalesCompany__c', 0, inputs, formParams);
                city = HDT_UTL_DocumentalManagement.getValue('Case', 'SupplyCity__c', 0, inputs, formParams);
                distributorName = HDT_UTL_DocumentalManagement.getValue('Case', 'DistributorName__c', 0, inputs, formParams);
                commodity = HDT_UTL_DocumentalManagement.getValue('Case', 'CommodityFormula__c', 0, inputs, formParams);
                List<HDT_HcmCityException__mdt> cityExceptionList = queryClass.getHcmCityExceptionByName(city, commodity);
                if (cityExceptionList != null && cityExceptionList.size()>0) {
                    List<HDT_DistributorExceptionHC__mdt> distributorList = queryClass.getHcDistributorExceptionByName(distributorName);
                    if (distributorList != null && distributorList.size()>0) {
                        companyDesc = 'Hera Comm S.p.A.';
                    } else {
                        companyDesc = 'Hera Comm Marche';
                    }
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
        System.debug('context: ' + context);
        System.debug('city: ' + city);
        System.debug('distributorName: ' + distributorName);
        System.debug('commodity: ' + commodity);
        System.debug('companyDesc: ' + companyDesc);
        
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
        String caseType = '';
        String supplyType = '';
        String cluster = '';
        switch on context {
            when 'Case' {
                amount = HDT_UTL_DocumentalManagement.getValue('Case', 'Amount__c', 0, inputs, formParams);
                fixedAmount = HDT_UTL_DocumentalManagement.getValue('Case', 'FixedAmount__c', 0, inputs, formParams);
                variableAmount = HDT_UTL_DocumentalManagement.getValue('Case', 'VariableAmount__c', 0, inputs, formParams);
                iva = HDT_UTL_DocumentalManagement.getValue('Case', 'VATPercentage__c', 0, inputs, formParams);
                caseType = HDT_UTL_DocumentalManagement.getValue('Case', 'Type', 0, inputs, formParams);
                supplyType = HDT_UTL_DocumentalManagement.getValue('Case', 'SupplyType__c', 0, inputs, formParams);
                cluster = HDT_UTL_DocumentalManagement.getValue('Case', 'Cluster__c', 0, inputs, formParams);
            }
            when else {
                //quotationType = ''; //da ordine manca il campo
                //processType =  HDT_UTL_DocumentalManagement.getValue('Order', 'ProcessType__c', 0, inputs, formParams);
            }
        }
        
        System.debug('Amount: ' + amount);
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

            if(String.isBlank(variableAmount) && String.isBlank(fixedAmount) && context.equalsIgnoreCase('Case') && cluster.equalsIgnoreCase('Preventivi')){
                //variableAmount è l'importo prestazione calcolato come amount - fixedAmount
                //fixed amount è solo quotaVend se Variazione potenza dom sennò è quotaDistr + quotaVend| Se l'offerta è Placet togliere la quota Vend
                if(caseType.contains('Potenza') && supplyType.equalsIgnoreCase('Domestico')){
                    fixedAmount = '23';
                }else {
                    fixedAmount = '48,81';
                }
                variableAmount = String.valueOf(Double.valueOf(amount) - Double.valueOf(fixedAmount));
            }
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
        System.debug('query: ' + queryString);

        List<sObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        System.debug('recordList: ' + recordList);
        
        for (Integer i = 0; i < recordList.size(); i++) {
            Contract c = (Contract) recordList[i];
            List<SBQQ__Subscription__c> subscriptions = (List<SBQQ__Subscription__c>) c.SBQQ__Subscriptions__r;
            System.debug('subscriptions: ' + subscriptions);
            
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
        System.debug('payloadSection ' + payloadSection);

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
            String createdDate = getFormattedDate(Date.valueOf(HDT_UTL_DocumentalManagement.getValue('CaseList', 'CreatedDate', i, inputs, formParams)));
            record.add(HDT_UTL_DocumentalManagement.getValue('CaseList', 'Origin', i, inputs, formParams));         // Canale
            record.add(createdDate);                                                                                // Data ricevimento
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
            String createdDate = getFormattedDate(Date.valueOf(HDT_UTL_DocumentalManagement.getValue('OrderList', 'CreatedDate', i, inputs, formParams)));
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'Channel__c', i, inputs, formParams));        // Canale
            record.add(createdDate);                                                                                    // Data ricevimento
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'ProcessType__c', i, inputs, formParams));    // Sottotipo
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'Cluster__c', i, inputs, formParams));        // Tipo
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'OrderNumber', i, inputs, formParams));       // N. RS
            record.add(HDT_UTL_DocumentalManagement.getValue('OrderList', 'Phase__c', i, inputs, formParams));          // Stato
            // Aggiungiamo lo \n finale sempre tranne che all'ultimo giro.
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
        // Come primo step contiamo il numero di preventivi su Case e Order, necessario in seguito.
        Integer numPreventiviCases = 0;
        Integer numPreventiviOrders = 0;
        for (Integer i = 0; i < cases.size(); i++) {
            String cluster = HDT_UTL_DocumentalManagement.getValue('CaseList', 'Cluster__c', i, inputs, formParams);
            if (cluster == 'Preventivi' || cluster == 'Verifiche') {
                numPreventiviCases++;
            }
        }
        for (Integer i = 0; i < orders.size(); i++) {
            String processType = HDT_UTL_DocumentalManagement.getValue('OrderList', 'ProcessType__c', i, inputs, formParams);
            if (processType == 'Prima Attivazione con modifica') {
                numPreventiviOrders++;
            }
        }
        Integer preventivoCounter = 0;
        for (Integer i = 0; i < cases.size(); i++) {
            String cluster = HDT_UTL_DocumentalManagement.getValue('CaseList', 'Cluster__c', i, inputs, formParams);
            if (cluster == 'Preventivi' || cluster == 'Verifiche') {
                preventivoCounter++;
                String[] record = new List<String>();
                // Il primo 310|50 è già presente, evitiamo di aggiungerlo una seconda volta.
                if (preventivoCounter > 1) {
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
                // Aggiungiamo lo \n finale sempre, tranne quando siamo all'ultimo giro E non abbiamo Order subito dopo.
                if (preventivoCounter != numPreventiviCases) {
                    record.add(endLine);
                } else if (preventivoCounter == numPreventiviCases && numPreventiviOrders > 0) {
                    record.add(endLine);
                }
                
                payloadSection += String.join(record, div);
            }
        }

        preventivoCounter = 0;
        for (Integer i = 0; i < orders.size(); i++) {
            String processType = HDT_UTL_DocumentalManagement.getValue('OrderList', 'ProcessType__c', i, inputs, formParams);
            if (processType != 'Prima Attivazione con modifica') {
                continue;
            }
            preventivoCounter++;
            String[] record = new List<String>();
            // Il primo 310|50 è già presente, evitiamo di aggiungerlo una seconda volta.
            // Se preventivoCounter = 1 ma payloadSection è valorizzato, dobbiamo comunque aggiungerlo perchè non siamo più al primo giro.
            if (preventivoCounter > 1 || String.isNotBlank(payloadSection)) {
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
            // Aggiungiamo lo \n finale sempre tranne che all'ultimo giro.
            if (preventivoCounter != numPreventiviOrders) {
                record.add(endLine);
            }
            payloadSection += String.join(record, div);
        }

        return payloadSection;
    }

    // Genera la sezione di payload ricorsiva 00310|70| per la stampa della Scheda Cliente (sezione "Anagrafiche Collegate")
    private String generateSection70(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        String endLine = '\n';
        String div = '|';
        String payloadSection = '';

        String accountId = HDT_UTL_DocumentalManagement.getValue('Account', 'Id', 0, inputs, formParams);
        HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
        AccountContactRelation acr = acrQueryHandler.getPrimaryContactRelation(accountId);
        if (acr == null) {
            System.debug('Nessun contatto titolare trovate per accountId: ' + accountId);
            return '';
        }

        List<AccountContactRelation> relations = acrQueryHandler.getRelatedAccounts(acr.ContactId);
        for (Integer i = 0; i < relations.size(); i++) {
            AccountContactRelation rel = relations[i];
            String[] record = new List<String>();
            // Il primo 310|70 è già presente, evitiamo di aggiungerlo una seconda volta.
            if (i > 0) {
                record.add('00310');
                record.add('70');
            }

            record.add(rel.Account.FirstName__c);                  // Nome
            record.add(rel.Account.LastName__c);                   // Cognome/ragione sociale
            if (rel.AccountId != accountId) {
                record.add(rel.Account.FiscalCode__c);             // Codice Fiscale cliente principale
                record.add(rel.Account.FirstName__c);              // Nome principale
                record.add(rel.Account.LastName__c);               // Cognome/ragione sociale principale
                record.add(rel.Account.CustomerCode__c);           // Codice cliente principale
                record.add(rel.Account.VATNumber__c);              // PIVA cliente principale
            }

            // Aggiungiamo lo \n finale sempre tranne che all'ultimo giro.
            if (i < relations.size() - 1) {
                record.add(endLine);
            }
            payloadSection += String.join(record, div);
        }

        return payloadSection;
    }

    /*
    Genera la sezione di payload per la stampa della risposta motivata dei reclami (corpo della risposta).
    Esempio di payload: 

        00310|100|Gentile cliente|
        00310|100|come anticipato nella telefonata del 12/07, le confermiamo di aver trasmesso al Distributore INRETE l’autolettura di mc 300|
        00310|100|...
        ...
        00310|110|Simone Fazio|
        00310|120|Servizio: Gas|
        00310|120|Tipologia fornitura: mercato libero|
        00310|120|Tariffa cliente: Hera Impronta Zero Casa Gas|
        00310|120|Indirizzo di fornitura: VIA ZENA 5 LOIANO (BO)|
        00310|120|PDR: 03081000247066|
        00310|120|Servizio: Gas|
        00310|120|Tipologia fornitura: mercato libero|
        00310|120|Tariffa cliente: Hera Impronta Zero Casa Gas|
        00310|120|Indirizzo di fornitura: VIA FELSINA 37 BOLOGNA (BO)|
        00310|120|PDR: 03081000243674|
        00310|130|1|25|
    */
    private String generateSectionReclami(Map<String,List<sObject>> inputs, Map<String,Object> formParams){
        String endLine = '\n';
        String div = '|';
        String payloadSection = '';

        String context = (String) formParams.get('Contesto');
        if (context != 'Case') {
            return '';
        }

        String cluster = HDT_UTL_DocumentalManagement.getValue('Case', 'Cluster__c', 0, inputs, formParams);
        if (String.isNotBlank(cluster) && cluster != 'Reclami') {
            return '';
        }

        String htmlResponse = HDT_UTL_DocumentalManagement.getValue('Case', 'ComplaintBodyResponse__c', 0, inputs, formParams);
        if (String.isBlank(htmlResponse)) {
            return '';
        }

        String plainTextResponse = htmlResponse.stripHtmlTags();
        String[] splittedResponse = plainTextResponse.split('\n');

        List<String> cleanedResponseLines = new List<String>();
        for (Integer i = 0; i < splittedResponse.size(); i++) {
            String cleanResponseLine = HDT_UTL_DocumentalManagement.removeSpecialChar(splittedResponse[i]);
            List<String> splittedLine = new List<String>();  // array in caso la riga sia troppo lunga e debba essere splittata.
            // Split righe più di lunghe di 150 caratteri, altrimenti Engage1 non riesce a calcolare lo spazio necessario nel PDF.
            if (cleanResponseLine.length() > 150) {
                System.debug('Riga troppo lunga per Engage1: ' + cleanResponseLine);
                // https://stackoverflow.com/a/10735971/16766541
                // regex per splittare in base al word boundary (\b) se la riga supera 150 caratteri
                Pattern splitPattern = Pattern.compile('.{1,150}\\b'); 
                Matcher splitMatcher = splitPattern.matcher(cleanResponseLine);
                while (splitMatcher.find()) {
                    splittedLine.add(splitMatcher.group(0).trim());
                }
                System.debug('splitted line: ' + splittedLine);
            }

            if (!splittedLine.isEmpty()) {
                cleanedResponseLines.addAll(splittedLine);
            } else {
                cleanedResponseLines.add(cleanResponseLine);
            }
        }

        // Sezione ricorsiva 310|100 con il corpo della risposta.
        for (Integer i = 0; i < cleanedResponseLines.size(); i++) {
            String[] record = new List<String>();
            // Il primo 310|100 è già presente, evitiamo di aggiungerlo una seconda volta.
            if (i > 0) {
                record.add('00310');
                record.add('100');
            }

            record.add(cleanedResponseLines[i]);
            record.add(endLine);

            payloadSection += String.join(record, div);
        }

        // Record 310|110 con riferimento operatore che ha lavorato la pratica.
        String[] userRecord = new List<String>();
        userRecord.add('00310');
        userRecord.add('110');
        userRecord.add(UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
        userRecord.add(endLine);
        payloadSection += String.join(userRecord, div);

        // Sezione ricorsiva 310|120 con le info sulle forniture incluse nella risposta del reclamo.
        List<String> caseIds = new List<String>();
        String isContainer = HDT_UTL_DocumentalManagement.getValue('Case', 'IsContainer__c', 0, inputs, formParams);
        if (Boolean.valueOf(isContainer)) {
            String selectedChildCases = HDT_UTL_DocumentalManagement.getValue('Case', 'Note__c', 0, inputs, formParams);
            if (String.isNotBlank(selectedChildCases)) {
                for (String caseId : selectedChildCases.split(';')) {
                    caseIds.add(caseId);
                }
            }
        } else {
            caseIds.add(HDT_UTL_DocumentalManagement.getValue('Case', 'Id', 0, inputs, formParams));
        }
        System.debug('caseIds: ' + caseIds);

        HDT_QR_Case queryCase = new HDT_QR_Case();
        String queryFieldsCase = 'Id,CaseNumber,Contract__c,Market__c,SendDate__c,CommodityFormula__c,AddressFormula__c,PODPDRFormula__c'; // WIP. per aggiungere l'offerta bisogna querare anche i contratti del cliente... :(
        List<Case> responseCases = queryCase.getRecordsById(caseIds, queryFieldsCase);
        System.debug('responseCases: ' + responseCases);

        List<String> contractIds = new List<String>();
        for (Case c : responseCases) {
            contractIds.add(c.Contract__c);
        }
        String objectName = 'Contract';
        String queryFieldsContract = 'Id';
        String queryString = 'SELECT ' + queryFieldsContract;
        String fromString = ' FROM '+ objectName;
        String controllingField = 'Id';
        String whereString = ' WHERE ' + controllingField + ' IN :contractIds';
        String relatedQueryString = ',(SELECT Id,SBQQ__ProductName__c FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__r.Family = \'Offerta commerciale\')';
        queryString = queryString + relatedQueryString + fromString + whereString; 
        System.debug('contracts query ' + queryString);
        
        List<sObject> recordList = new List<sObject>();
        SObjectType objtype = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe(); 
        if (objRes.isAccessible()) {
            recordList = Database.query(queryString);
        }
        System.debug('recordList: ' + recordList);

        Map<Id, String> offersMap = new Map<Id, String>(); // mappa tra id contratto e offerta commerciale del contratto.
        for (Integer i = 0; i < recordList.size(); i++) {
            Contract c = (Contract) recordList[i];
            List<SBQQ__Subscription__c> subscriptions = (List<SBQQ__Subscription__c>) c.SBQQ__Subscriptions__r;
            System.debug('subscriptions: ' + subscriptions);
            offersMap.put(c.Id, subscriptions[0].SBQQ__ProductName__c);
        }

        // Info sulle forniture
        String emptyLine = '00310|120| |' + endLine;
        for (Case c : responseCases) {
            {
                String[] record = new List<String>();
                record.add('00310');
                record.add('120');
                record.add('Servizio: ' + c.CommodityFormula__c);
                record.add(endLine);
                payloadSection += String.join(record, div);
            }
            {
                String[] record = new List<String>();
                record.add('00310');
                record.add('120');
                record.add('Tipologia fornitura: ' + c.Market__c);
                record.add(endLine);
                payloadSection += String.join(record, div);
            }
            {
                String[] record = new List<String>();
                record.add('00310');
                record.add('120');
                record.add('Tariffa cliente: ' + offersMap.get(c.Contract__c));
                record.add(endLine);
                payloadSection += String.join(record, div);
            }
            {
                String[] record = new List<String>();
                record.add('00310');
                record.add('120');
                record.add('Indirizzo di fornitura: ' + c.AddressFormula__c);
                record.add(endLine);
                payloadSection += String.join(record, div);
            }
            {
                String[] record = new List<String>();
                record.add('00310');
                record.add('120');
                if ('Gas' == c.CommodityFormula__c) {
                    record.add('PDR: ' + c.PODPDRFormula__c);
                } else { // TODO WAVE 2: adeguare per le altre commodity.
                    record.add('POD: ' + c.PODPDRFormula__c);
                }
                record.add(endLine);
                payloadSection += String.join(record, div);
                payloadSection += emptyLine;
            }
        }

        // Info allegati al reclamo, se presenti.
        HDT_QR_CaseValidations docQueryHandler = new HDT_QR_CaseValidations();
        List<ContentDocumentLink> docList = docQueryHandler.getDocumentByCaseId(HDT_UTL_DocumentalManagement.getValue('Case', 'Id', 0, inputs, formParams));
        if (!docList.isEmpty()) {
            payloadSection += emptyLine;
            String[] record = new List<String>();
            record.add('00310');
            record.add('120');
            record.add('Insieme a questa lettera le inviamo i documenti indicati qui sotto:');
            record.add(endLine);
            payloadSection += String.join(record, div);

            for (Integer i = 0; i < docList.size(); i++) {
                ContentDocumentLink doc = docList[0];
                if (doc.ContentDocument != null) {
                    record = new List<String>();
                    record.add('00310');
                    record.add('120');
                    record.add(String.valueOf(i + 1) + ') ' + doc.ContentDocument.title);
                    record.add(endLine);
                    payloadSection += String.join(record, div);
                }
            }
        }

        // Info sulle date ricezione del reclamo (incluse sempre nella sezione 310|120)
        for (Integer i = 0; i < 4; i++) {
            payloadSection += emptyLine;
        }
        for (Integer i = 0; i < responseCases.size(); i++) {
            Case c = responseCases[i];
            String[] record = new List<String>();
            record.add('00310');
            record.add('120');
            record.add('Risposta al Reclamo ricevuto in data ' + getFormattedDate(c.SendDate__c) + ' ns Prot ' + c.CaseNumber);
            // Aggiungiamo lo \n finale sempre tranne che all'ultimo giro.
            if (i < responseCases.size() - 1) {
                record.add(endLine);
            }
            payloadSection += String.join(record, div);
        }

        // Record 310|130 per box indennizzi, previsto solo per i reclami scritti (non per le richieste di info).
        String complaintClassification = HDT_UTL_DocumentalManagement.getValue('Case', 'FirstLevelComplaintClassification__c', 0, inputs, formParams);
        if (String.isNotBlank(complaintClassification) && complaintClassification != 'Richiesta di informazioni') {
            Boolean indemnityConfirmed = Boolean.valueOf(HDT_UTL_DocumentalManagement.getValue('Case', 'IndemnityConfirmed__c', 0, inputs, formParams));
            String indemnityMotivation = HDT_UTL_DocumentalManagement.getValue('Case', 'IndemnityMotivation__c', 0, inputs, formParams);
            String indemnityDueSendResponse = HDT_UTL_DocumentalManagement.getValue('Case', 'IndemnityDueSendResponse__c', 0, inputs, formParams);
            Decimal indemnityDueSendResponseDecimal = String.isNotBlank(indemnityDueSendResponse) ? Decimal.valueOf(indemnityDueSendResponse) : 0;
            String indemnityDueBillingCorrection = HDT_UTL_DocumentalManagement.getValue('Case', 'IndemnityDueBilllingCorrection__c', 0, inputs, formParams);
            Decimal indemnityDueBillingCorrectionDecimal = String.isNotBlank(indemnityDueBillingCorrection) ? Decimal.valueOf(indemnityDueBillingCorrection) : 0;
            String correctionRight = HDT_UTL_DocumentalManagement.getValue('Case', 'CorrectionRight__c', 0, inputs, formParams);
            String correctionDocumentEmissionDate = HDT_UTL_DocumentalManagement.getValue('Case', 'CorrectionDocumentEmissionDay__c', 0, inputs, formParams);
            Boolean expiredCorrection = indemnityDueBillingCorrection != null;

            String[] record = new List<String>();
            record.add('00310');
            record.add('130');
            // Calcolo tipologia di indennizzo attesa da Engage1.
            String boxType = calculateIndemnityBox(complaintClassification, indemnityConfirmed, indemnityMotivation, correctionRight, expiredCorrection, correctionDocumentEmissionDate, indemnityDueSendResponseDecimal);
            if (String.isNotBlank(boxType)) {
                record.add(boxType);
                // Importo indennizzo, se necessario.
                if ((boxType == '1' || boxType == '5') && indemnityDueSendResponseDecimal > 0) {
                    record.add(indemnityDueSendResponse);
                } else if ((boxType == '2' || boxType == '8') && indemnityDueBillingCorrectionDecimal > 0) {
                    record.add(''); // campo vuoto per l'indemnityDueSendResponse, l'indemnityDueBillingCorrection deve stare in seconda posizione.
                    record.add(indemnityDueBillingCorrection);
                } else if (boxType == '4' && indemnityDueSendResponse != null && indemnityDueSendResponseDecimal > 0 && indemnityDueBillingCorrectionDecimal > 0) {
                    record.add(indemnityDueSendResponse);
                    record.add(indemnityDueBillingCorrection);
                }
            }

            // Aggiungiamo anche | e l'endLine poichè il record indennizzi è opzionale e il 310|120 non può aggiungere a prenscindere un endline finale.
            payloadSection += '|' + endLine + String.join(record, div);
        }

        return payloadSection;
    }

    public static String calculateIndemnityBox(String complaintClassification, Boolean indemnityConfirmed, String indemnityMotivation, String correctionRight, Boolean expiredCorrection, String correctionDocumentEmissionDate, Decimal indemnityDueSendResponse) {
        String boxType = '';

        // Emissione rettifica non prevista, indennizzo per solo ritardo nella risposta
        if (complaintClassification == 'Reclamo Scritto' && indemnityConfirmed && correctionRight != 'Si') {
            boxType = '1';
        }
        // Emissione rettifica prevista ma non scaduta, indennizzo per solo ritardo nella risposta
        else if (complaintClassification == 'Reclamo Scritto' && indemnityConfirmed && correctionRight == 'Si' && !expiredCorrection && String.isNotBlank(correctionDocumentEmissionDate)) {
            boxType = '1';
        }
        // Emissione rettifica prevista e scaduta, indennizzo per sola rettifica
        else if (complaintClassification == 'Reclamo Scritto' && indemnityConfirmed && correctionRight == 'Si' && expiredCorrection && String.isNotBlank(correctionDocumentEmissionDate) && indemnityDueSendResponse == 0) {
            boxType = '2';
        }
        // Emissione rettifica prevista e scaduta, indennizzi per ritardo nella risposta e nella rettifica
        else if (complaintClassification == 'Reclamo Scritto' && indemnityConfirmed && correctionRight == 'Si' && expiredCorrection && String.isNotBlank(correctionDocumentEmissionDate) && indemnityDueSendResponse > 0) {
            boxType = '4';
        }
        // Emissione rettifica prevista ma data emissione ancora non presente e ho superato lo SLA, indennizzo per solo ritardo nella risposta + avviso eventuale indennizzo rettifica
        else if (complaintClassification == 'Reclamo Scritto' && indemnityConfirmed && correctionRight == 'Si' && String.isBlank(correctionDocumentEmissionDate) && expiredCorrection) {
            boxType = '5';
        }
        // Emissione rettifica prevista ma data emissione ancora non presente e NON ho superato lo SLA, indennizzo per solo ritardo nella risposta
        else if (complaintClassification == 'Reclamo Scritto' && indemnityConfirmed && correctionRight == 'Si' && String.isBlank(correctionDocumentEmissionDate) && !expiredCorrection) {
            boxType = '1';
        }
        // Emissione rettifica prevista ma data emissione ancora non presente
        else if (complaintClassification == 'Rettifica Doppia Fatturazione' && correctionRight == 'Si' && String.isBlank(correctionDocumentEmissionDate)) {
            boxType = '';
        }
        // Emissione rettifica prevista e scaduta
        else if (complaintClassification == 'Rettifica Doppia Fatturazione' && correctionRight == 'Si' && String.isNotBlank(correctionDocumentEmissionDate) && expiredCorrection) {
            boxType = '8';
        }
        // Emissione rettifica prevista ma non scaduta
        else if (complaintClassification == 'Rettifica Doppia Fatturazione' && correctionRight == 'Si' && String.isNotBlank(correctionDocumentEmissionDate) && !expiredCorrection) {
            boxType = '';
        }

        // Check finale se indennizzo già inviato in stesso anno
        if (!indemnityConfirmed && indemnityMotivation == 'Altro indennizzo stesso anno solare') {
            boxType = '6';
        }

        System.debug('calculateIndemnityBox inputs: ' + complaintClassification + ', ' + indemnityConfirmed + ', ' + indemnityMotivation + ', ' + correctionRight + ', ' + expiredCorrection + ', ' + correctionDocumentEmissionDate + ', ' + indemnityDueSendResponse);
        System.debug('calculateIndemnityBox boxType output: ' + boxType);
        return boxType;
    }

    // Calcola il driver MODALITA_FIRMA, che è un driver PRIMARIO e quindi o ha un valore configurato su Engage1, oppure deve essere vuoto.
    private String calculateSignModeDriver(Map<String,List<sObject>> inputs, Map<String,Object> formParams) {
        String context = (String) formParams.get('Contesto');
        String signModeForm = HDT_UTL_DocumentalManagement.getValue('FormParameters', 'signMode', 0, inputs, formParams);
        if (String.isNotBlank(signModeForm)) {
            return signModeForm == 'Vocal Order' ? signModeForm : '';
        }

        String signMode = '';
        if (context == 'Order') {
            signMode = HDT_UTL_DocumentalManagement.getValue('Order', 'SignatureMethod__c', 0, inputs, formParams);
        }/*  else if (context == 'Case') {
            signMode = HDT_UTL_DocumentalManagement.getValue('Case', 'SignMode__c', 0, inputs, formParams);
        } */ // al momento Engage1 non ha configurato nessun plico post-sales con driver MODALITA_FIRMA valorizzato.

        return signMode == 'Vocal Order' ? signMode : '';
    }

    /*
     Calcola il driver secondario CATALOGO in base alla price list presente sull'Order. Le price list disponibili sono le seguenti:
        Energia Elettrica Domestico
        Energia Elettrica Non Domestico
        Gas Domestico (A-Domestico)
        Gas Non Domestico (B-Condominio, C-Aziende di pubblica utilità, D-Altri usi)
        VAS ELE
        VAS GAS
        VAS Standalone
    */
    private String calculateDriverCatalogo(Map<String,List<sObject>> inputs, Map<String,Object> formParams) {
        String context = (String) formParams.get('Contesto');
        if (context != 'Order') {
            return '';
        }

        String orderId = HDT_UTL_DocumentalManagement.getValue('Order', 'Id', 0, inputs, formParams);
        Order orderData = HDT_QR_DocumentalConfiguration.getOrderPriceBook(orderId);
        String priceBookName = orderData.SBQQ__Quote__r?.SBQQ__PriceBook__r?.Name;

        if (String.isBlank(priceBookName)) {
            return '';
        }

        if (priceBookName.containsIgnoreCase('non domestico')) {
            return 'SME Offerte a scaffale';
        }

        if (priceBookName.containsIgnoreCase('vas')) {
            return '';
        }

        // TODO WAVE 3: adeguare per i valori FUI|TUTELA|SALVAGUARDIA
        return 'MM Offerte a scaffale';
    }

    // Restituisce la data nel formato richiesto da Engage1
    private static String getFormattedDate(Date dateToFormat) {
        Datetime dt = dateToFormat;
        String formattedDate = dt.format('dd/MM/y');
        return formattedDate;
    }
    
}