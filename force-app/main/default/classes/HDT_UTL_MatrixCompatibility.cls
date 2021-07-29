/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 12/07/2021
 * @description Class that holds methods for Matrix Compatibility 
 */

public inherited sharing class HDT_UTL_MatrixCompatibility {

    @AuraEnabled
    public static Map<String,Object> checkCompatibilitySales(Map<String,Object> servReq){
        try {
            System.debug(servReq);
            Map<String,Object> resMap = new Map<String,Object>();
            ServiceRequest__c srRequest = new ServiceRequest__c();
            srRequest.ServicePointCode__c = String.valueOf(servReq.get('servicePointCode')); 
            srRequest.Status__c = 'Bozza';
            srRequest.Order__c = String.valueOf(servReq.get('order'));
            srRequest.CommoditySector__c = String.valueOf(servReq.get('commoditySector'));
            srRequest.Type__c = String.valueOf(servReq.get('type')); 
            if(servReq.get('servicePoint') != null){
                srRequest.ServicePoint__c = String.valueOf(servReq.get('servicePoint'));
            }else{
                srRequest.Account__c = String.valueOf(servReq.get('account'));
                srRequest.BillingProfile__c = String.valueOf(servReq.get('billingProfile'));
            }
            if(servReq.get('processType') != null){
                srRequest.ProcessType__c= getProcessTypeOrder(String.valueOf(servReq.get('processType')),servReq.get('commoditySector'));

            }

            ServiceRequest__c sReq = HDT_SRV_ServiceRequest.createRecord(srRequest);
            System.debug(srRequest);
            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = checkCompatibility(sReq);
            System.debug(result);
            HDT_SRV_ServiceRequest.deleteRecord(sReq);
            //list of incompatible records
            resMap.put('ServiceRequest', srRequest);
            if(!result.incompatibilities.isEmpty()){
                resMap.put('compatibility', getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities));
            }else{
                resMap.put('compatibility', '');
            }
            
            return resMap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String checkCompatibilityPostSales(Case cs){
        try {
            String compatibility='';
            ServiceRequest__c srvRequest= new ServiceRequest__c();
            srvRequest.Case__c= cs.Id;
            srvRequest.ServicePointCode__c= cs.PODPDRFormula__c;
            srvRequest.Status__c= getStatus(cs.Status,'Case');
            srvRequest.CommoditySector__c= cs.CommodityFormula__c;
            srvRequest.Type__c= 'Case';
            if(cs.ServicePoint__c != null){
                srvRequest.ServicePoint__c= cs.ServicePoint__c;
            }else{
                srvRequest.Account__c= cs.AccountId;
                srvRequest.BillingProfile__c= cs.BillingProfile__c;
            }
            srvRequest.ProcessType__c= getProcessTypeCase(cs.Type, cs.CommodityFormula__c);
            ServiceRequest__c sReq = HDT_SRV_ServiceRequest.createRecord(srvRequest);
            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result = checkCompatibility(sReq);
            //list of incompatible records
            if(!result.incompatibilities.isEmpty()){
                compatibility = getIncompatibilityMessage((ServiceRequest__c[])result.incompatibilities);
                HDT_SRV_ServiceRequest.deleteRecord(sReq);
            }
                
            return compatibility;   
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static wrts_prcgvr.ObjectCompatibility_1_0.CheckResult checkCompatibility(ServiceRequest__c srRequest){
        try {
            wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt objectCompatibility =
            (wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt) wrts_prcgvr.VersionManager.newClassInstance('ObjectCompatibility');
            //API call

            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result =
            (wrts_prcgvr.ObjectCompatibility_1_0.CheckResult)
            objectCompatibility.check(new Map<String,Object>{
            'sObject' => srRequest
            });
            return result;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static String getIncompatibilityMessage(ServiceRequest__c[] incomps){
        Set<Id> conflictIds = new Set<Id>();
        Set<String> conflicts = new Set<String>();

        ServiceRequest__c[] incompatibilities= (ServiceRequest__c[])incomps;
        for(ServiceRequest__c c : incompatibilities){
            conflictIds.add(c.Id);
        }
        for(ServiceRequest__c s : [SELECT Id, Order__c,Case__c,Type__c FROM ServiceRequest__c WHERE Id IN :conflictIds]) {
            if(s.Type__c=='Case'){
                conflicts.add(s.Case__c);
            }else{
                conflicts.add(s.Order__c);
            }
        }
        System.debug('conflicts: '+ conflicts);

        String[] conflictsString = new List<String>(conflicts);
        return String.join(conflictsString, ', ');
    }

    public static String getStatus(String status, String type){
        String sts='';
        if(type == 'Case'){
            switch on status {
                when 'New' {
                    sts = 'Bozza';
                }when 'In Lavorazione' {
                    sts = 'In Lavorazione';
                }when 'Sequenzializzato' {
                    sts = 'Sequenzializzato';
                }when 'Closed' {
                    sts = 'Chiuso';
                }
            }
        }else{
            switch on status {
                when 'Draft' {
                    sts = 'Bozza';
                }when 'In Lavorazione' {
                    sts = 'In Lavorazione';
                }when 'Activated' {
                    sts = 'Chiuso';
                }when 'Completed' {
                    sts = 'Completato';
                }when 'Annullato' {
                    sts = 'Annullato';
                }when 'Sequenzializzato' {
                    sts = 'Sequenzializzato';
                }
            } 
        }
        
        return sts;
    }

    private static String getProcessTypeOrder(String pType, Object commoditySector){
        String processType='';

        switch on pType {
            when 'Cambio Offerta Ele' {
                processType = 'Cambio offerta - EE';
            }when 'Cambio Offerta Gas' {
                processType = 'Cambio offerta - GAS';
            }when 'Cambio Uso' {
                processType = 'Cambio uso - EE';
            }when 'Connessione con Attivazione' {
                processType = 'Connessione con attivazione - EE';
            }when 'Prima Attivazione Ele' {
                processType = 'Prima attivazione - EE';
            }when 'Prima Attivazione con modifica' {
                processType = 'Prima attivazione con modifica - EE';
            }when 'Riattivazione non morose' {
                processType = 'Riattivazioni non morose - GAS';
            }when 'Subentro Ele' {
                processType = 'Subentro su GDM chiuso - EE';
            }when 'Subentro Gas' {
                processType = 'Subentro su GDM chiuso - GAS';
            }when 'Switch In Gas' {
                processType = 'Switch in  - GAS';
            }when 'Switch In Ele' {
                processType = 'Switch in - EE';
            }when 'Aggiunta Sconti o Bonus VAS Ele' {
                processType = 'Sconti e bonus - EE';
            }when 'Aggiunta Sconti o Bonus VAS Gas' {
                processType = 'Sconti e bonus - GAS';
            }when 'Prima Attivazione Fuori delibera' {
                processType = 'Prima attivazione - GAS';
            }when 'Prima Attivazione In delibera' {
                processType = 'Prima attivazione - GAS';
            }when 'Switch in con voltura tecnica' {
                if(commoditySector !=null){
                    if(String.valueOf(commoditySector) == 'Energia Elettrica'){
                        processType = 'Switch in con voltura tecnica - EE';
                    }else if(String.valueOf(commoditySector) == 'Gas'){
                        processType = 'Switch in con voltura tecnica - GAS';
                    }
                } 
            }when 'Switch in Ripristinatorio' {
                if(commoditySector !=null){
                    if(String.valueOf(commoditySector) == 'Energia Elettrica'){
                        processType = 'Switch in ripristinatorio - EE';
                    }else if(String.valueOf(commoditySector) == 'Gas'){
                        processType = 'Switch in ripristinatorio - GAS';
                    }
                } 
            }when 'Temporanea - Nuova Attivazione' {
                processType = 'Temporanea - Nuova attivazione - EE';
            }when 'Voltura Ele' {
                processType = 'Voltura - EE';
            }when 'Voltura Gas' {
                processType = 'Voltura - GAS';
            } when 'Switch in Fittizio' {
                processType = 'Switch tecnico';
            } when 'Voltura con Switch' {
                if(commoditySector !=null){
                    if(String.valueOf(commoditySector) == 'Energia Elettrica'){
                        processType = 'Voltura con switch - EE';
                    }else if(String.valueOf(commoditySector) == 'Gas'){
                        processType = 'Voltura con switch - GAS';
                    }
                } 
            } 
        }
        return processType;
    }

    private static String getProcessTypeCase(String pType, String comodity){
        String processType='';

        switch on pType {
            when 'Modifica Alert' {
                processType = 'Alert';
            }when 'Allineamento Anagrafica' {
                processType = 'Allineamento anagrafica';
            }when 'Allineamento Canone RAI' {
                processType = 'Allineamento Canone RAI - EE';
            }when 'Annullamento Contratti' {
                processType = 'Annullamento contratti';
            }when 'Attivazione Click&Pay' {
                processType = 'Attivazione ClickPay';
            }when 'Autoelettrica' {
                processType = 'Autoelettrica/modalità attivazione contratto';
            }when 'Blocco Sollecito/Interessi' {
                processType = 'Blocco al sollecito ed interessi';
            }when 'BP/CA - errata categoria' {
                processType = 'BP-CA - Errata categoria';
            }when 'Caduta Linea/Chiamata Muta' {
                processType = 'Caduta Linea / Chiamata Muta';
            }when 'Cambio cont. non registrato' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Cambio contatore non registrato - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Cambio contatore non registrato - GAS';
                    }
                }
            }when 'Comunicazione di Fallimento' {
                processType = 'Comunicazione di Fallimento';
            }when 'Comunicazione Pagamento' {
                processType = 'Comunicazione Pagamento';
            }when 'Consegna copia chiave GdM' {
                processType = 'Consegna copia chiave GdM - GAS';
            }when 'Contenzioso In Corso' {
                processType = 'Contenzioso in corso';
            }when 'Contratto Non Richiesto' {
                processType = 'Contratto non richiesto';
            }when 'Copia Bolletta/Bollettino' {
                processType = 'Copia Bolletta/Bollettino';
            }when 'Dettaglio Bolletta' {
                processType = 'Dettaglio Bolletta';
            }when 'Disassociazione Utente Web' {
                processType = 'Disassociazione Utente Web';
            } when 'Emissione Impulsi' {
                processType = 'Emissione impulsi - Preventivo analitico - GAS';
            } when 'Errore Chiamata' {
                processType = 'Errore di chiamata';
            } when 'Errore di Fatturazione' {
                processType = 'Errore di Fatturazione';
            } when 'Esercizio Diritti Privacy' {
                processType = 'Esercizio diritto privacy';
            } when 'HVAC' {
                processType = 'HVAC';
            } when 'Informative' {
                processType = 'Informative';
            } when 'Spostamento Votive Modena' {
                processType = 'Intervento spostamento Votive Modena - EE';
            } when 'Marcatura/Uso PdR' {
                processType = 'Marcatura / Uso PDR - GAS';
            } when 'Modifica Impianto' {
                processType = 'Modifica impianto - Preventivo analitico - EE';
            } when 'Modifica Privacy' {
                processType = 'Modifica privacy';
            } when 'Modifica Tariffa Residente/Non Residente' {
                processType = 'Modifica tariffa Residente / Non Residente  - EE';
            } when 'Notifica Attivazione POD' {
                processType = 'Notifica attivazione POD - EE';
            } when 'Verifica Tensione - Pressione' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Verifica Tensione - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Verifica Pressione - GAS';
                    }
                }
            } when 'Notifica Variazione Stato PDR SII' {
                processType = 'Notifica variazione Stato PDR SII (VSG2.0200) - GAS';
            } when 'Nuovo Impianto - Aggiunta Attacco' {
                processType = 'Nuovo Impianto/Aggiunta attacco - preventivo analitico';
            } when 'Pagamento ClickPay' {
                processType = 'Pagamento Online / Pagamento ClickPay';
            } when 'Paperless' {
                processType = 'Paperless';
            } when 'Piano Rateizzaizone' {
                processType = 'Piano Rateizzazione';
            } when 'Disattivazione VAS' {
                processType = 'Post sales VAS (Disattivazione)';
            } when 'Prescrizione Fatture' {
                processType = 'Prescrizione fatture (Del. 569)';
            } when 'Trasmissione Dati Cliente Finale SII' {
                processType = 'Processo VS2 - Trasmissione Dati Cliente Finale SII - EE';
            } when 'Proroga Temporanea' {
                processType = 'Proroga connessione temporanea - EE';
            } when 'Rettifica Consumi' {
                processType = 'Rettifica Consumi';
            } when 'Revoca Domiciliazione' {
                processType = 'Revoca Domiciliazione';
            } when 'Richiesta Domiciliazione' {
                processType = 'Richiesta domiciliazione';
            } when 'Richiesta lettura cliente' {
                processType = 'Richiesta lettura c/cliente - GAS';
            } when 'Rimborso' {
                processType = 'Rimborso';
            } when 'Ripensamento' {
                processType = 'Ripensamento';
            } when 'Ripristino Fornitura Interrotta' {
                processType = 'Ripristino fornitura interrotta - GAS';
            } when 'Ritorno a Fatturazione Bimestrale/Mensile' {
                processType = 'Ritorno a fatturazione Bimestrale / Mensile';
            } when 'Segnalazioni VAS' {
                processType = 'Segnalazioni VAS';
            } when 'Sospensione a seguito di potenziale pericolo' {
                processType = 'Sospensione a seguito di potenziale pericolo';
            } when 'Sospensione Canone Rai Calamità' {
                processType = 'Sospensione Canone RAI calamità - EE';
            } when 'Sost. contatore cliente' {
                processType = 'Sostituzione Contatore c/cliente - GAS';
            } when 'Split Payment' {
                processType = 'Split Payment';
            } when 'Storno Rateizzazione' {
                processType = 'Storno Rateizzazione';
            } when 'Switch Out SII' {
                processType = 'Switch out dal SII';
            } when 'Testo Contratto in Bolletta' {
                processType = 'Testo contratto in bolletta';
            } when 'Unificazione POD' {
                processType = 'Unificazione POD - Preventivo Analitico - EE';
            } when 'Variazione Anagrafica Cliente' {
                processType = 'Variazione anagrafica cliente';
            } when 'Variazione Domiciliazione' {
                processType = 'Variazione domiciliazione';
            } when 'Variazione su Amministratore' {
                processType = 'Variazione su amministratore';
            } when 'Variazione Tensione' {
                processType = 'Variazione tensione - Preventivo analitico - EE';
            } when 'Verifica Dati al DL' {
                processType = 'Verifica dati al DL';
            } when 'Verifica Pareggio Fittizio Canone Rai' {
                processType = 'Verifica pareggio Fittizio Canone RAI - EE';
            } when 'Votive Modena Cessazione' {
                processType = 'Votive Modena / Cessazione - EE';
            } when 'Votive Modena Pagamenti Morosità' {
                processType = 'Votive Modena / Pagamenti morosità - EE';
            } when 'Votive Modena Contestazione Fattura' {
                processType = 'Votive Modena Contestazione Fattura - EE';
            } when 'Chiusura Contatore' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Chiusura contatore - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Chiusura contatore - GAS';
                    }
                }
            } when 'Comportamento Altri Venditori' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Comportamento altri venditori - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Comportamento altri venditori - GAS';
                    }
                }
            } when 'Comportamento Venditori HC' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Comportamento venditori HC - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Comportamento venditori HC - GAS';
                    }
                }
            } when 'Condizioni Contrattuali Errate' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Condizioni contrattuali errate - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Condizioni contrattuali errate - GAS';
                    }
                }
            } when 'Dichiarazione di intento' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Dichiarazione di Intento - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Dichiarazione di intento - GAS';
                    }
                }
            } when 'Gestione Bonus Sociale' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Gestione Bonus Sociale - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Gestione Bonus Sociale - GAS';
                    }
                }
            } when 'Gestione Calamità' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Gestione Calamità - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Gestione Calamità - GAS';
                    }
                }
            } when 'Gestione Disalimentabilità' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Gestione disalimentabilità - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Gestione disalimentabilità - GAS';
                    }
                }
            } when 'Interruzione Fornitura' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Interruzione fornitura - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Interruzione fornitura - GAS';
                    }
                }
            } when 'Inversione del Contatore' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Inversione del contatore - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Inversione del contatore - GAS';
                    }
                }
            } when 'Mancata Telelettura/lettura' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Mancata telelettura/Lettura - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Mancata telelettura/Lettura - GAS';
                    }
                }
            } when 'Modifica/Azzeramento Consumo Annuo' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Modifica azzeramento consumo annuo - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Modifica azzeramento consumo annuo - GAS';
                    }
                }
            } when 'Modifica Layout di dettaglio' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Modifica Layout di dettaglio - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Modifica Layout di dettaglio - GAS';
                    }
                }
            } when 'Modifica Portale SOL Gestione Energia' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Modifica Portale SOL Gestione Energia - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Modifica Portale SOL Gestione Energia - GAS';
                    }
                }
            } when 'Recesso per Altri Motivi' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Recesso per altri motivi - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Recesso per altri motivi - GAS';
                    }
                }
            } when 'Recesso per Rifiuto Voltura' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Recesso per rifiuto voltura - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Recesso per rifiuto voltura - GAS';
                    }
                }
            } when 'Recesso su Richesta Cliente' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Recesso su richiesta cliente - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Recesso su richiesta cliente - GAS';
                    }
                }
            } when 'Riattivazione Fornitura' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Riattivazione fornitura - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Riattivazione fornitura - GAS';
                    }
                }
            } when 'Ricostruzione Consumi' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Ricostruzione Consumi - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Ricostruzione Consumi - GAS';
                    }
                }
            } when 'Rimozione Impianto' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Rimozione impianto Ele - Preventivo predeterminabile - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Rimozione impianto Gas - Preventivo analitico - GAS';
                    }
                }
            } when 'Risoluzione No Disalimentabile' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Risoluzione no Disalimentabile - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Risoluzione no Disalimentabile - GAS';
                    }
                }
            } when 'Risoluzione No Punto Sospeso' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Risoluzione no Sospensione - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Risoluzione no Sospensione - GAS';
                    }
                }
            } when 'Risoluzione Punto Sospeso' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Risoluzione punto sospeso - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Risoluzione punto sospeso - GAS';
                    }
                }
            } when 'Sollecito Emissione Bolletta' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Sollecito emissione bolletta - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Sollecito emissione bolletta - GAS';
                    }
                }
            } when 'Sospensione Fornitura' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Sospensione fornitura - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Sospensione fornitura - GAS';
                    }
                }
            } when 'Spostamento Contatore' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Spostamento Contatore -Preventivo Analitico - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Spostamento Contatore - Preventivo Analitico - GAS';
                    }
                }
            } when 'Fiscale' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Variazione fiscale - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Variazione fiscale - GAS';
                    }
                }
            } when 'Variazione indirizzo di fornitura' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Variazione indirizzo di fornitura - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Variazione indirizzo di fornitura - GAS';
                    }
                }
            } when 'Variazione Portata' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Variazione potenza - Preventivo analitico - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Variazione portata - Preventivo analitico - GAS';
                    }
                }
            } when 'Verifica GDM' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Verifica GdM - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Verifica GdM - GAS';
                    }
                }
            } when 'Verifica Titolarità POD/PDR' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Verifica titolarità POD - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Verifica titolarità PDR - GAS';
                    }
                }
            } when 'Voltura Tecnica' {
                if(comodity !=null){
                    if(comodity== 'Energia Elettrica'){
                        processType = 'Voltura tecnica - EE';
                    }else if(comodity == 'Gas'){
                        processType = 'Voltura tecnica - GAS';
                    }
                }
            } 
        }
        return processType;
    }
}
