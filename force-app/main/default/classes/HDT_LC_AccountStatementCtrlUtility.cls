public inherited sharing class HDT_LC_AccountStatementCtrlUtility {

    public static HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow setHttpDataBodyRow(HDT_WRP_AccountStatement.HDT_WRP_TechObj tObj, HDT_WRP_AccountStatement.HDT_WRP_HttpDataBodyRow dbr){

        try{

            //String transactionType = dbr.tipoTransazione;

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
                    dbr.tipoTransazione = 'EC2';
                    dbr.aggregazione = '03';
                }
                //Tasto Aggrega&Filtri 
                when 'joinFilter' {

                    if(tObj.tabCode == 'EC'){
                        if(String.isEmpty(dbr.aggregazione)){
                            dbr.aggregazione = '03';
                        }
                        dbr.tipoTransazione = 'EC2';
                    }

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

                    if(String.isEmpty(dbr.dataInizio)){
                        dbr.dataInizio = null;
                    } else {
                        dbr.dataInizio = convertDateFormat(dbr.dataInizio);
                    }
       
                    if(String.isEmpty(dbr.dataFine)){
                        dbr.dataFine = null;
                    } else {
                        dbr.dataFine = convertDateFormat(dbr.dataFine);
                    }

                    dbr.numeroFattura = null;
                    dbr.numeroBollettino = dbr.numeroBollettino;
                    dbr.contoContrattuale = null;
                    dbr.societa = null;
                    dbr.contratto = null;
                    dbr.loginId = '0-1';
                }
                //Tasto Visualizza Esito
                when 'viewResult' {
                    dbr.applicativo = 'ML';
                    dbr.aggregazione = '03';
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
                        /*
                        * @Author: Salvatore A. Sarà 18/10/2021
                        * Risoluzione "Avoid Empty Block Statements"
                        */
                        return dbr;
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
                        /*
                        * @Author: Salvatore A. Sarà 18/10/2021
                        * Risoluzione "Avoid Empty Block Statements"
                        */
                        return dbr;
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
                    dbr.tipoTransazione = 'EC2';
                }
                //Tasto Filtri-Paperless
                when 'paperlessFilters' {
                    /*
                    * @Author: Salvatore A. Sarà 18/10/2021
                    * Risoluzione "Avoid Empty Block Statements"
                    */
                    return dbr;
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
                if(String.isNotEmpty(dbr.originLwc) && dbr.originLwc.equalsIgnoreCase('activity')){
                    dbr.tipoTransazione = 'EC2';
                }
                

                return dbr;
            }
            //Indennizzi
            when 'EC8' {
                /*
                * @Author: Salvatore A. Sarà 18/10/2021
                * Risoluzione "Avoid Empty Block Statements"
                */
                return dbr;                
            }
            //Note Var. IVA
            when 'EC3' {
                dbr.aggregazione = '03';
                //for bug fix
                dbr.tipoEstrattoConto = 'NVI';
            }
            //Pagamenti e compensazioni
            when 'EC5' {
                /*
                * @Author: Salvatore A. Sarà 18/10/2021
                * Risoluzione "Avoid Empty Block Statements"
                */
                return dbr;
            }
            //Paperless
            when 'paperless' {
                dbr.tipoTransazione = null;
                dbr.tipoEstrattoConto = null;
            }
            //Parite non fatturate
            when 'EC7' {
                /*
                * @Author: Salvatore A. Sarà 18/10/2021
                * Risoluzione "Avoid Empty Block Statements"
                */
                return dbr;
            }
            //Rate
            when 'EC4' {
                /*
                * @Author: Salvatore A. Sarà 18/10/2021
                * Risoluzione "Avoid Empty Block Statements"
                */
                return dbr;
            }
            //Scaduto per riattivazione
            when 'EC9' {
                /*
                * @Author: Salvatore A. Sarà 18/10/2021
                * Risoluzione "Avoid Empty Block Statements"
                */
                return dbr;
            }
            //Solleciti
            when 'EC6' {
                /*
                * @Author: Salvatore A. Sarà 18/10/2021
                * Risoluzione "Avoid Empty Block Statements"
                */
                return dbr;
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

        //if(endPointMdt.size()>0 && !String.isEmpty(endPointMdt[0].EndpointService__c) && !String.isEmpty(endPointMdt[0].Authorization__c)){
        if(endPointMdt.size()>0 && !String.isEmpty(endPointMdt[0].EndpointService__c)){
            //httpObj.endPoint = endPointMdt[0].EndpointService__c;
            //httpObj.headersMap.put('Authorization', endPointMdt[0].Authorization__c);

            httpObj.endPoint = endPointMdt[0].EndpointService__c;

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

    public static AccountStatementFilter__c executeControllForSingleRecord(HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj record, AccountStatementFilter__c serviceCatalog, String tabValue){
        
        Set<String> raiFeeSet = new Set<String>();
        /**@frpanico 22/10/2021
        * Added Social bonus Map
        */
        Map<String,String> socialBonusMap = new Map<String,String>();

        serviceCatalog.Multiselect__c = false;
        serviceCatalog.IsInvoice__c = (String.isEmpty(record.numeroFattura)) ? false : true;
        serviceCatalog.OnCredit__c = (Decimal.valueOf(record.residuo)<0) ? true : false;
        serviceCatalog.Vendor__c = (String.isEmpty(record.societa)) ? '' : record.societa;

        if(tabValue.equalsIgnoreCase('EC')){
            raiFeeSet = checkSecondLevel(record.secondoLivelloInformativo, raiFeeSet);
        } else if(tabValue.equalsIgnoreCase('EC4')){
            raiFeeSet = checkSecondLevel(record.secondoLivelloInformativoF2, raiFeeSet);
        }
        serviceCatalog.IsRaiFee__c = (serviceCatalog.Context__c.equalsIgnoreCase('EC2L') && raiFeeSet.size() > 0);
        /**@frpanico 22/10/2021
        * Added logic for "Bonus Sociale"
        * If the field is not empty add to the Map<String,String>
        * bonusSociale as key
        * dataScadenza as value
        */
        if(!String.isEmpty(record.bonusSociale))
        {
            socialBonusMap.put(record.bonusSociale,record.dataScadenza);
        }

        if(!String.isEmpty(record.fatturaPrescrivibile) && record.fatturaPrescrivibile.equalsIgnoreCase('X') && String.isNotBlank(record.del569) ){
            serviceCatalog.IsPrescribable__c = true;
        } else {
            serviceCatalog.IsPrescribable__c = false;
        }

        serviceCatalog.IsInstallment__c = (!String.isEmpty(record.rateizzato) && record.rateizzato.equalsIgnoreCase('SI')) ? true : false;
        serviceCatalog.SameCA__c = true;
        /**@frpanico 22/10/2021
        * Calculate the new field SocialBonus__c
        * it calls the method checkSocialBonus which takes in input the map previously feeded
        */
        serviceCatalog.SocialBonus__c = checkSocialBonus(socialBonusMap, serviceCatalog.Account__c);

        return serviceCatalog;

    }

    /*
    * @Author: Salvatore A. Sarà 19/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static AccountStatementFilter__c executeControllForMultipleRecords(List<HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj> recordsList, AccountStatementFilter__c serviceCatalog, String tabValue){
        Set<String> isInstallmentSet = new Set<String>();
        Set<String> sameCaSet = new Set<String>();
        Set<String> raiFeeSet = new Set<String>();
        /**@frpanico 21/10/2021
         * Added Social bonus Map
         */
        Map<String,String> socialBonusMap = new Map<String,String>();
        Decimal tot = 0;

        for(HDT_WRP_AccountStatement.HDT_WRP_DeserializeObj obj : recordsList){

            if(tabValue.equalsIgnoreCase('EC')){
                raiFeeSet = checkSecondLevel(obj.secondoLivelloInformativo, raiFeeSet);
            } else if(tabValue.equalsIgnoreCase('EC4')){
                raiFeeSet = checkSecondLevel(obj.secondoLivelloInformativoF2, raiFeeSet);
            }

            //if(!String.isEmpty(obj.documentoPareggio) && obj.documentoPareggio.substring(0, 2).equalsIgnoreCase('27')){
            //    raiFeeSet.add(obj.documentoPareggio);
            //}

            if(!String.isEmpty(obj.rateizzato)){
                isInstallmentSet.add(obj.rateizzato);
            }

            /**@frpanico 21/10/2021
             * Added logic for "Bonus Sociale"
             * If the field is not empty add to the Map<String,String>
             * bonusSociale as key
             * dataScadenza as value
             */
            if(!String.isEmpty(obj.bonusSociale))
            {
                socialBonusMap.put(obj.bonusSociale,obj.dataScadenza);
            }

            if(!String.isEmpty(obj.contoContrattuale)){
                sameCaSet.add(obj.contoContrattuale);
            }
            tot += Decimal.valueOf(obj.residuo);
        }

        System.debug(LoggingLevel.DEBUG, '>>>>>>>>>>>> isInstallmentSet ' + String.valueOf(isInstallmentSet));

        if(isInstallmentSet.size() > 0){
            if(isInstallmentSet.contains('SI')){
                serviceCatalog.IsInstallment__c = true;
            } else {
                serviceCatalog.IsInstallment__c = false;
            }
        } else {
            serviceCatalog.IsInstallment__c = false;
        }

        //switch on isInstallmentSet.size() {
        //    when 0 {
        //        serviceCatalog.IsInstallment__c = false;
        //    }

        //    when 1 {
        //        String f = (new List<String>(isInstallmentSet) )[0];
        //        if(f.equalsIgnoreCase('SI')){
        //            serviceCatalog.IsInstallment__c = true;
        //        }
        //    }
        //    
        //    when 2 {
        //        serviceCatalog.IsInstallment__c = false;
        //    }                       
        //}

        System.debug(LoggingLevel.DEBUG, '>>>>>>>>>>>> IsInstallment__c ' + String.valueOf(serviceCatalog.IsInstallment__c));

        serviceCatalog.OnCredit__c = (tot<0) ? true : false;
        serviceCatalog.SameCA__c = (sameCaSet.size() > 1) ? false : true;
        serviceCatalog.Multiselect__c = true;
        serviceCatalog.IsRaiFee__c = (serviceCatalog.Context__c.equalsIgnoreCase('EC2L') && raiFeeSet.size() > 0);
        /**@frpanico 21/10/2021
         * Calculate the new field SocialBonus__c
         * it calls the method checkSocialBonus which takes in input the map previously feeded
         */
        serviceCatalog.SocialBonus__c = checkSocialBonus(socialBonusMap, serviceCatalog.Account__c);

        return serviceCatalog;
    }

    public static Set<String> checkSecondLevel(List<HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj> secondLevelList, Set<String> raiFeeSet){

        for(HDT_WRP_AccountStatement.HDT_WRP_SecondLevelObj secondLevelObj : secondLevelList){
            if(!String.isEmpty(secondLevelObj.docPareggio) && secondLevelObj.docPareggio.substring(0, 2).equalsIgnoreCase('27')){
                raiFeeSet.add(secondLevelObj.docPareggio);
            }
        }

        return raiFeeSet;

    }

    /**@frpanico 21/10/2021
     * Added a method that runs through the map given as input (if null it returns true)
     * if the "dataScadenza" field of one entryis more than 10 days before today it returns false
     */
    private static Boolean checkSocialBonus(Map<String,String> socialBonusMap, String accountId)
    {   
        HDT_QR_Case caseQr = new HDT_QR_Case();
        Boolean result = true;
        List<Case> caseList = caseQr.getCaseByAccountid(accountId, new Set<String>{'Piano Rateizzazione'});
        for(String bonusSociale : socialBonusMap.keyset())
        {
            if(bonusSociale.equalsIgnoreCase('SI'))
            {   
                List<String> splittedDate = socialBonusMap.get(bonusSociale).split('/');
                Date dataScadenza = Date.newInstance(Integer.valueOf(splittedDate[2]), Integer.valueOf(splittedDate[1]), Integer.valueOf(splittedDate[0]));
                if(dataScadenza < System.Today().addDays(-10) || (caseList != null && !caseList.isEmpty()))
                {
                    result = false;
                    break;
                }
            }
        }
        return result;
    }
}