public with sharing class HDT_LC_CambioUso {

    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_QR_ServicePoint srvQr = new HDT_QR_ServicePoint(); 
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
   // private static HDT_QR_CausalCodeCalculation causalCodeQR = new HDT_QR_CausalCodeCalculation();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_QR_BillingProfile billQr = new HDT_QR_BillingProfile();
    private static Map<String,String> mapIvaIdToValue2 = new Map<String,String>{
    '01' => 'Iva 10% (Cod. 01)',
'02' => 'Iva 22% (Cod. 02)',
'03' => 'Iva 10% Soc. Controllate (Cod. 03)',
'04' => 'Iva 22% Soc. Controllate (Cod. 04)',
'05' => 'Iva 10% Soc. Collegate (Cod. 05)',
'06' => 'Iva 22% Soc. Collegate (Cod. 06)',
'07' => 'Iva 10% Soc. Controllanti (Cod. 07)',
'08' => 'Iva 22% Soc. Controllanti (Cod. 08)',
'09' => 'Iva 10% Soc. del Gruppo (Cod. 09)',
'10' => 'Iva 22% Soc. del Gruppo (Cod. 10)',
'12' => 'Iva esente-non imp Art 72 (Cod. 12)',
'13' => 'Iva Fuori Campo Autofatt. Art 2 (Cod. 13)',
'14' => 'Iva 10% Soc. Partecipate (Cod. 14)',
'17' => 'Iva esente-non imp art 8 S. Marino (Cod. 17)',
'19' => 'Iva Fuori Campo Livigno (Cod. 19)',
'25' => 'Iva Reverse Charge (Cod. 25)',
'26' => 'Iva Reseller esente (Cod. 26)',
'27' => 'Iva 10% Consociate (Cod. 27)',
'28' => 'Iva 22% Consociate (Cod. 28)',
'S1' => 'Iva Split payment 10% (Cod. S1)',
'S2' => 'Iva Split payment 22% (Cod. S2)',
'S3' => 'Iva Split payment 10% Soc. del Gruppo (Cod. S3)',
'S4' => 'Iva Split payment 22% Soc. del Gruppo (Cod. S4)'
    };


    @AuraEnabled
    public static boolean updateCase(String caseId,String addebito,string tipoFornitura,String recapito,string tipoImpianto,boolean residente,string note,String disco,String discotype){
        boolean res = true;
        HDT_SRV_Case caseSrv = new HDT_SRV_Case();
        System.debug('*****2:');
        Case c1 = caseQr.getRecordByIdCambioUso(caseId);
        List<ServicePoint__c> srv = srvQr.getRecordById(c1.servicepoint__c,'id,Disconnectable__c,Vat__c,DisconnectibilityType__c,CommoditySector__c,SupplyCity__c,Account__r.CustomerMarking__c,distributor__r.code__c');
        String code = '';
        try{
            List<RateCategory__c> listRate = HDT_QR_RateCategory.getRateList(srv[0] != null ? srv[0].CommoditySector__c : 'Energia Elettrica',srv[0].distributor__r.code__c,'N/A',tipoFornitura);
            for(RateCategory__c r : listRate){
                if(r.DistributorCode__c == srv[0].distributor__r.code__c && r.operatore__c == 'Uguale'){
                    code = r.CalculatedValue__c;
                    res = true;
                    break;
                }
                else if(r.DistributorCode__c != srv[0].distributor__r.code__c && r.operatore__c == 'Diverso'){
                    code = r.CalculatedValue__c;
                    res = true;
                    break;
                }
                else if(r.operatore__c == 'N/A'){
                    code = r.CalculatedValue__c;
                    res = true;
                    break;
                }
            }
            Case c = new case(); 
            if('Si'.equalsIgnorecase(addebito)){
                List<Contract> contractList = contractQr.getActiveRecordsByAccountIdAndServicePointId(c1.accountId,srv[0].id);
                BillingProfile__c bp = billQr.getRecordById(contractList[0].billingProfile__c);
                c.billingProfile__c = contractList[0].billingProfile__c;
                c.IbanAbi__c = bp.ibanAbi__c;
                c.ibanCAB__c = bp.ibanCAB__c;
                c.ibanCin__c = bp.ibanCin__c;
                c.ibanCodeNumber__c = bp.ibanCodeNumber__c;
                c.bankaccountSignatoryFiscalCode__c = bp.bankAccountSignatoryFiscalCode__c;
                c.ibanCin_iban__c = bp.ibanCIN_Iban__c;
                c.bankAccountSignatoryFirstName__c = bp.bankAccountSignatoryFirstName__c;
                c.BankAccountSignatoryLastName__c = bp.BankAccountSignatoryLastName__c;
                c.AccountClass__c = bp.AccountClass__c;
            }

            //List<Contract> contractList = contractQr.getActiveRecordsByAccountIdAndServicePointId(c1.accountId,srv[0].id);
            System.debug('*****1:' + srv);
            Map<String,String> agc = HDT_UTL_Sales.getAgentNameAndCode(srv[0],srv[0].Account__r.CustomerMarking__c);
            //HDT_CausalCodeCalculation__mdt mcc = causalCodeQR.calculateCausalCode();
            c.id = caseId;
            System.debug('*****3:');
            c.SupplyType__c = tipoFornitura;
            c.UseChangeCharge__c = addebito;
            c.PhoneNumber__c = recapito;
            c.ServicePointType__c = tipoImpianto;
            c.SalesCompanyCode__c = agc.get('codiceAgente');
            c.SalesCompany__c = agc.get('nomeAgente');
            c.distributorCode__c = srv[0].distributor__r.code__c;
            c.CausalCode__c = 'CAU';
            c.Resident__c = residente;
            c.rateCategory__c = code;
            c.TaxRate__c = mapIvaIdToValue2.get(srv[0].Vat__c);
           // c.CustomerType__c = c1.account.CustomerType__c;
            c.Disconnectable__c = disco;
            if('No'.equalsIgnoreCase(disco)){
                c.DisconnectibilityType__c = discotype;
            }
           // c.DisconnectibilityType__c = srv[0].DisconnectibilityType__c;
            c.Note__c = note;
            System.debug('*****4:');
            c.phase__c = 'Da Inviare';
            c.status = 'In Lavorazione';
            caseSrv.updateRecord(c);
            
        }
        catch(Exception e){
            res = false;
        }
        return res; 
    }
}