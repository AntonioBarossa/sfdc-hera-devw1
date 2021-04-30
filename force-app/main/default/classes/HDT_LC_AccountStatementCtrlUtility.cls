public inherited sharing class HDT_LC_AccountStatementCtrlUtility {

    public static HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow setHttpDataBodyRow(HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj, HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr){

        try{

            dbr.codiceCliente = tObj.customerCode;
            dbr.tipoTransazione = tObj.tabCode;
            dbr.applicativo = 'ML';
            dbr.tipoEstrattoConto = tObj.statementType;
            dbr.loginId = '0-1';

            //ALL BUTTON CLICKS ARE HERE!
            switch on tObj.requestType {
                //Tasto Home
                when 'home' {
                    dbr = setDefaultHttpDataBodyRow(tObj, dbr);
                }
                //Tasto Tutte le partite recenti:
                when 'allRecentItems' {
                    Date todayDate = date.today();
                    Date minusDate = todayDate.addYears(-5);
                    dbr.dataFine = convertDateFormat(String.valueOf(todayDate));
                    dbr.dataInizio = convertDateFormat(String.valueOf(minusDate));
                }
                //Tasto Aggrega&Filtri 
                when 'joinFilter' {
                    dbr.dataFine = convertDateFormat(dbr.dataFine);
                    dbr.dataInizio = convertDateFormat(dbr.dataInizio);
                }
                //Tasto Filtri 
                when 'filters' {
                    dbr.applicativo = 'ML';
                    dbr.aggregazione = null;
                    dbr.codiceCliente = tObj.customerCode;
                    dbr.tipoTransazione = tObj.tabCode;
                    dbr.tipoEstrattoConto = 'ORDINARIO';
                    dbr.dataInizio = convertDateFormat(dbr.dataInizio);
                    dbr.dataFine = convertDateFormat(dbr.dataFine);
                    dbr.numeroFattura = null;
                    dbr.numeroBollettino = dbr.numeroBollettino;
                    dbr.contoContrattuale = null;
                    dbr.societa = null;
                    dbr.contratto = null;
                    dbr.loginId = '0-1';
                }
                //Tasto Visualizza Esito
                when 'viewResult' {
                    dbr.applicativo = null;
                    dbr.codiceCliente = null;
                    dbr.tipoEstrattoConto = null;
                    dbr.loginId = null;
                    dbr.tipoTransazione = 'EC4';
                }
                //Tasto Scaduto
                when 'expired' {
                    dbr.dataInizio = '01/01/1900';
                    Date todayDate = date.today();
                    dbr.dataFine = convertDateFormat(String.valueOf(todayDate));
                    dbr.tipoTransazione = 'EC1';
                }
                //Tasto Recupero crediti
                when 'creditRecovery' {
                    dbr.tipoTransazione = 'EC10';
                }
                //Tasto Recupero crediti
                when 'expiredFromDay' {
                    List<HDT_ButtonDetails__mdt> mdtButtonList;
                    mdtButtonList = HDT_QR_AccountStatement.getButtonParameters(mdtButtonList, tObj.tabCode, 'expiredFromDay');

                    if(mdtButtonList.size()==0){

                    }

                    Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(mdtButtonList[0].Parameters__c);
                    Object parameter = (Object)jsonMap.get('diffDays');
                    Integer diffDays = Integer.valueOf(parameter);

                    
                    dbr.tipoTransazione = 'EC3';
                    dbr.dataInizio = '01/01/1900';
                    
                    Date todayDate = date.today();
                    dbr.dataFine = convertDateFormat(String.valueOf(todayDate.addDays(-diffDays)));

                }
                when 'manageableItems' {
                    List<HDT_ButtonDetails__mdt> mdtButtonList;
                    mdtButtonList = HDT_QR_AccountStatement.getButtonParameters(mdtButtonList, tObj.tabCode, 'manageableItems');

                    if(mdtButtonList.size()==0){

                    }

                    Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(mdtButtonList[0].Parameters__c);
                    Object parameter = (Object)jsonMap.get('diffDays');
                    Integer diffDays = Integer.valueOf(parameter);

                    dbr.tipoTransazione = 'EC3';
                                        
                    Date todayDate = date.today();
                    dbr.dataInizio = convertDateFormat(String.valueOf(todayDate.addDays(-diffDays)));
                    dbr.dataFine = '01/01/2099';

                }
                //Tasto Contratto/Servizi
                when 'contractService' {

                }
                //Tasto Filtri-Paperless
                when 'paperlessFilters' {

                }

            }

            return dbr;

        } catch(Exception e){
            return null;
        }

    }

    public static HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow setDefaultHttpDataBodyRow(HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj, HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr){
        
        switch on tObj.tabCode {
            //Estratto conto
            when 'EC' {
                dbr.aggregazione = '03';
                dbr.tipoTransazione = 'EC1';
            }
            //Gestione del credito
            when 'EC1' {

            }
            //Indennizzi
            when 'EC8' {

            }
            //Note Var. IVA
            when 'NVI' {
                dbr.aggregazione = '03';
            }
            //Pagamenti e compensazioni
            when 'EC5' {

            }
            //Paperless
            when 'paperless' {
                dbr.tipoTransazione = null;
                dbr.tipoEstrattoConto = null;
            }
            //Parite non fatturate
            when 'EC7' {

            }
            //Rate
            when 'EC4' {

            }
            //Scaduto per riattivazione
            when 'EC9' {

            }
            //Solleciti
            when 'EC6' {

            }
        }
        return dbr;
    }

    public static String convertDateFormat(String inputDate){
        Date tempDate = Date.valueOf(inputDate);
        String day = (tempDate.day()<10) ? '0' + String.valueOf(tempDate.day()) : String.valueOf(tempDate.day());
        String month = (tempDate.month()<10) ? '0'+ String.valueOf(tempDate.month()) : String.valueOf(tempDate.month());
        String year = String.valueOf(tempDate.year());
        return day + '/' + month + '/' + year;
    }

    public static HDT_WS_MulesoftCaller.HDT_WRP_HttpObj setHttpObject(String tabCode, String requestType){

        HDT_WS_MulesoftCaller.HDT_WRP_HttpObj httpObj = new HDT_WS_MulesoftCaller.HDT_WRP_HttpObj();
        httpObj.headersMap = new Map<String, String>();

        List<HDT_TabConfiguration__mdt> endPointMdt;
        endPointMdt = HDT_QR_AccountStatement.getTabConfigurationMetaData(endPointMdt, tabCode);

        if(endPointMdt.size()>0 && !String.isEmpty(endPointMdt[0].EndpointService__c) && !String.isEmpty(endPointMdt[0].Authorization__c)){

            httpObj.endPoint = endPointMdt[0].EndpointService__c;
            httpObj.headersMap.put('Authorization', endPointMdt[0].Authorization__c);

            if(endPointMdt[0].UseMockService__c){
                httpObj.endPoint = Label.MockEndPointAccountStatement;
                httpObj.headersMap.put('Authorization', 'Bearer ' + Label.MockSessionId);
            }

            httpObj.httpMethod = 'POST';
            httpObj.headersMap.put('Content-Type', 'application/json');

        } else {
            httpObj = null;
        }

        return httpObj;
    }

    public static AccountStatementFilter__c executeControllForSingleRecord(HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj record, AccountStatementFilter__c serviceCatalog){

        serviceCatalog.Multiselect__c = false;

        //- Se il campo Numero fattura del primo livello informativo è diverso da null, settare il campo IsInvoice__c a true; (solo nel caso della selezione di un solo record)
        serviceCatalog.IsInvoice__c = (String.isEmpty(record.numeroFattura)) ? false : true;

        //- Se il campo Residuo del record selezionato al primo livello è < 0, settare il campo OnCredit__c a true; (solo nel caso della selezione di un solo record)
        serviceCatalog.OnCredit__c = (Decimal.valueOf(record.residuo)<0) ? true : false;

        //- Settare il campo Vendor__c con il valore del campo Società del primo livello;
        serviceCatalog.Vendor__c = (String.isEmpty(record.societa)) ? '' : record.societa;

        //- Se il campo Prescrivibile del 1 livello è uguale a X e il campo DEL_569 è null, settare il campo IsPrescribable__c a true;
        if(!String.isEmpty(record.fatturaPrescrivibile) && record.fatturaPrescrivibile.equalsIgnoreCase('X') ){
            serviceCatalog.IsPrescribable__c = true;
        } else {
            serviceCatalog.IsPrescribable__c = false;
        }

        //- Se tutte le fatture selezionate presentano il campo RATEIZZATO = SI, settare il campo IsInstallment__c = true;
        serviceCatalog.IsInstallment__c = (!String.isEmpty(record.rateizzato) && record.rateizzato.equalsIgnoreCase('SI')) ? true : false;

        //- Se le fatture selezionate hanno tutte lo stesso conto contrattuale, impostare a true il campo SameCA__c;
        serviceCatalog.SameCA__c = false;

        return serviceCatalog;

    }

    public static AccountStatementFilter__c executeControllForMultipleRecords(List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj> recordsList, AccountStatementFilter__c serviceCatalog){
        Set<String> isInstallmentSet = new Set<String>();
        Set<String> sameCaSet = new Set<String>();
        Decimal tot = 0;

        for(HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj obj : recordsList){
            if(!String.isEmpty(obj.rateizzato)){
                isInstallmentSet.add(obj.rateizzato);
            }

            if(!String.isEmpty(obj.contoContrattuale)){
                sameCaSet.add(obj.contoContrattuale);
            }
            tot += Decimal.valueOf(obj.residuo);
        }

        //- Se tutte le fatture selezionate presentano il campo RATEIZZATO = SI, settare il campo IsInstallment__c = true;
        switch on isInstallmentSet.size() {
            when 0 {
                serviceCatalog.IsInstallment__c = false;
            }

            when 1 {
                String f = (new List<String>(isInstallmentSet) )[0];
                if(f.equalsIgnoreCase('SI')){
                    serviceCatalog.IsInstallment__c = true;
                }
            }
            
            when 2 {
                serviceCatalog.IsInstallment__c = false;
            }                       
        }

        serviceCatalog.OnCredit__c = (tot<0) ? true : false;

        //Se le fatture selezionate hanno tutte lo stesso conto contrattuale, impostare a true il campo SameCA__c; 
        serviceCatalog.SameCA__c = (sameCaSet.size() > 1) ? false : true;
        serviceCatalog.Multiselect__c = true;

        return serviceCatalog;
    }

}