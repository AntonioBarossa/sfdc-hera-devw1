/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 30/10/2020
 * @description HDT_LC_TargetObjectCreateForm.cls - Class that holds methods that are called from hdtTargetObjectCreateForm.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public inherited sharing class HDT_LC_TargetObjectCreateForm {
    private static HDT_SRV_ServicePoint serviceSp = new HDT_SRV_ServicePoint();
    private static HDT_SRV_SaleServiceItem saleServiceItemService = new HDT_SRV_SaleServiceItem();
    private static HDT_QR_ServicePoint servicePointQuery = new HDT_QR_ServicePoint();
    private static HDT_QR_SaleServiceItem saleServItem = new HDT_QR_SaleServiceItem();


    @AuraEnabled
    public static List<ServicePoint__c> getServicePoint(String code, String fields) {
        serviceSp.checkReadAccess(fields);
        if(code != null && code.startsWith('4') && code.length() == 10){
            return servicePointQuery.getRecordByImplantCode(code, fields);
        }
        else if(code instanceof Id)
        {
            return servicePointQuery.getRecordById(code, fields);
        }
        else{
            return servicePointQuery.getRecordByCode(code, fields);
        }
    }

    @AuraEnabled
    public static Boolean canHandleTari(String comune, String commodity){
        List<City__c> cities = [ SELECT ServiceTari__c FROM City__c WHERE Name = :comune WITH SECURITY_ENFORCED ];
        return !'Ambiente'.equalsIgnoreCase(commodity) && !cities.isEmpty() ? cities[0].ServiceTari__c : false;
    }

    @AuraEnabled
    public static ServicePoint__c createServicePoint(ServicePoint__c servicePoint) {

        if(servicePoint.MeterStatus__c == 'Bozza'){
            servicePoint.Account__c=null;
        }
        ServicePoint__c servicePo =  serviceSp.createRecord(servicePoint);
       
        updateServicePoint(servicePoint);
        return servicePo;
    }
    @AuraEnabled
    public static ServicePoint__c createServicePoint2(ServicePoint__c servicePoint,Sale__c sale) {
        return createServicePoint2(servicePoint, sale, true);
    }

    @AuraEnabled
    public static ServicePoint__c createServicePoint2(ServicePoint__c servicePoint,Sale__c sale, Boolean callWinBack) {

        if(servicePoint.MeterStatus__c == 'Bozza'){
            servicePoint.Account__c=null;
        }
        updateServicePoint3(servicePoint,sale,callWinBack);
        return servicePoint;
    }

    /** @author Andrei Necsulescu (andrei.necsulescu@webresults.it) 
     * This method is necessary because passing the object directly Removes the decimals from the numbers */
    @AuraEnabled
    public static ServicePoint__c createServicePoinString(String servicePoint, Sale__c sale){
        return createServicePoinString(servicePoint, sale, true);
    }

    @AuraEnabled
    public static ServicePoint__c createServicePoinString(String servicePoint, Sale__c sale,Boolean callWinBack){
                
        ServicePoint__c servicePointObject = (ServicePoint__c)JSON.deserialize(servicePoint, ServicePoint__c.class);
        servicePointObject.ImplantTypeTemp__c = servicePointObject.ImplantType__c;
        servicePointObject.SupplyTypeTemp__c = servicePointObject.SupplyType__c;
        servicePointObject.SupplyType__c = null;
        servicePointObject.ImplantType__c = null;

        createServicePoint2(servicePointObject, sale, callWinBack);

        return servicePointObject;

    }

   // @future(callout=true)
    public static void updateServicePoint(ServicePoint__c servicePo) {   
        
        if(servicePo.ServicePointCode__c != null){
            List<SaleServiceItem__c> listSale = saleServItem.getSaleByServicePointFilterCode(servicePo.ServicePointCode__c);
            Sale__c s = new Sale__c();
            HDT_QR_Sale saQr = new HDT_QR_Sale();

            
            if(listSale != null && !listSale.isEmpty()){
                s.id = listSale[0].opportunity__r.Sale__c;
                s = saQr.getRecordById(listSale[0].opportunity__r.Sale__c,'id,Account__r.Category__c,Account__r.CompanyOwner__c');
                boolean isTransitorio = HDT_UTL_Sales.isTransitionNoUp(servicePo,s);
                
                if(isTransitorio){
                    HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse resp = HDT_WS_TransitionWinBack.callTransitionCom(servicePo.ServicePointCode__c);
                    if(resp != null && resp.result!=null && !resp.result.isEmpty()){
                        if('in Corso'.equalsIgnoreCase(resp.result[0].status)){
                            servicePo.SwitchInWinback__c = true;
                        }
                    }
                } 
            }
        }
        serviceSp.updateRecord(servicePo);
    }
    
    public static void updateServicePoint2(ServicePoint__c servicePo,Sale__c sa){
        
        if(servicePo.ServicePointCode__c != null){
            Sale__c s = new Sale__c();
            HDT_QR_Sale saQr = new HDT_QR_Sale();
            boolean isTransitorio = false;

            if(sa!=null){
                if(sa.id!=null){
                    s = saQr.getRecordById(sa.id,'id,Account__r.Category__c,Account__r.CompanyOwner__c');
                    isTransitorio = HDT_UTL_Sales.isTransitionNoUp(servicePo,s);
                }
            }

            //if(isTransitorio){
                HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse resp = HDT_WS_TransitionWinBack.callTransitionCom(servicePo.ServicePointCode__c);
                if(resp != null && resp.result!=null && !resp.result.isEmpty()){
                    if('in Corso'.equalsIgnoreCase(resp.result[0].status)){
                        servicePo.SwitchInWinback__c = true;
                        if(resp.result[0].effectiveDate != null && !resp.result[0]?.effectiveDate.equalsIgnoreCase('0000-00-00')){
                            servicePo.SwitchOutDate__c = date.valueOf(resp.result[0].effectiveDate);
                        }
                    }
                }
            //}
        }
        serviceSp.updateRecord(servicePo);
    }

    public static void updateServicePoint3(ServicePoint__c servicePo,Sale__c sa) {
        updateServicePoint3(servicePo, sa, true);
    }
    
    public static void updateServicePoint3(ServicePoint__c servicePo,Sale__c sa, Boolean callWinBack) { 
        if(servicePo.ServicePointCode__c != null){

            Sale__c s = new Sale__c();
            HDT_QR_Sale saQr = new HDT_QR_Sale();

            if(sa!=null){
                s = saQr.getRecordById(sa.id,'id,Account__r.Category__c,Account__r.CompanyOwner__c');
            }
            if(sa != null){
                boolean isTransitorio = HDT_UTL_Sales.isTransitionNoUp(servicePo,s);
                //if(isTransitorio){
                if (callWinBack){
                    HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse resp = HDT_WS_TransitionWinBack.callTransitionCom(servicePo.ServicePointCode__c);
                    if(resp != null && resp.result!=null && !resp.result.isEmpty()){
                        if('in Corso'.equalsIgnoreCase(resp.result[0].status)){
                            servicePo.SwitchInWinback__c = true;
                            if(resp.result[0].effectiveDate != null && !resp.result[0]?.effectiveDate.equalsIgnoreCase('0000-00-00')){
                                servicePo.SwitchOutDate__c = date.valueOf(resp.result[0].effectiveDate);
                            }
                        }
                    }
                }
                //}
                Set<String> statusMeter = new Set<String>{'Bozza','Inattivo'};
                Set<String> commoditySet = new Set<String>{'Acqua','Teleriscaldamento'};
                if(statusMeter.contains(servicePo.MeterStatus__c) && commoditySet.contains(servicePo.CommoditySector__c) && String.isBlank(servicePo.Account__c)){
                    servicePo.Account__c=sa.Account__c;
                }
            }
        }
        /**
         * Per la Commodity Ambiente non è possibile cercare la fornitura per Codice Punto ma solo per Codice Contratto
         * Vi sono delle casistiche in cui il SP è presente in SFDC ma non il contratto poichè "svecchiato"
         * In queste casistiche la ricerca su SFDC non da risultati, ricercando e salvando il SP da SAP si rischia di creare dei duplicati
         * che andranno in errore per la GlobalMigrationKey. Pertanto viene introdotta una query preventiva per o utilizzare il record esistente oppure
         * inserire un nuovo record
         * 
         * Esteso anche per tutte le commodity per coprire casistiche di duplicazione dei record
        **/
        if(String.isNotBlank(servicePo.SAPImplantCode__c)){
            String implantCode = servicePo.SAPImplantCode__c;
            List<ServicePoint__c> spList = servicePointQuery.getRecordByImplantCode(implantCode,'Id');
            if(!spList.isEmpty()){
                servicePo.Id = spList[0].Id;
                serviceSp.updateRecord(servicePo);
            }else {
                serviceSp.createRecord(servicePo);
            }
        }else {
            serviceSp.createRecord(servicePo);
        }
    }

    @AuraEnabled
    public static ServicePoint__c confirmServicePoint2(ServicePoint__c servicePoint, Boolean sap,Sale__c sale){

        servicePoint.ImplantTypeTemp__c = servicePoint.ImplantType__c;
        servicePoint.SupplyTypeTemp__c = servicePoint.SupplyType__c;
        servicePoint.SupplyType__c = null;
        servicePoint.ImplantType__c = null;

        if(sap == false){
           updateServicePoint2(servicePoint,sale);
        }
        else{
            updateServicePoint3(servicePoint,sale);
        }
        return servicePoint;
    }

    @AuraEnabled
    public static ServicePoint__c confirmServicePoint(ServicePoint__c servicePoint, Boolean sap){
       
        if(sap){
            serviceSp.createRecord(servicePoint);
        }           
        updateServicePoint(servicePoint);
        return servicePoint;
    }

    @AuraEnabled
    public static List<DistributorPointCode__c> getDistributorPointCode(String code, String commodity, String comune, String presenzaAllaccio) {

        HDT_QR_DistributorPointCode queryClass = new HDT_QR_DistributorPointCode();
        List<DistributorPointCode__c> distrPointCodeWithCode = new List<DistributorPointCode__c>();
        List<DistributorPointCode__c> distrPointCodeWithOutCode = new List<DistributorPointCode__c>();

        for(DistributorPointCode__c distPointCode : queryClass.getDistributorPointCode(code, commodity, comune, presenzaAllaccio)){
            if(distPointCode.PointCode__c != null && distPointCode.PointCode__c != ''){
                distrPointCodeWithCode.add(distPointCode);
            }
            else {
                distrPointCodeWithOutCode.add(distPointCode);
            }
        }
        if(distrPointCodeWithCode.size() > 0){
            return distrPointCodeWithCode;
        }
        else {
            return distrPointCodeWithOutCode;
        }
    }

    @AuraEnabled
    public static String getAto(String comune){
        String toReturn = '';
        List<TownATOTable__c> atoList = [Select id, ATO__c from TownATOTable__c where Town__c =:comune WITH SECURITY_ENFORCED];
        toReturn = (!atoList.isEmpty() && String.isNotBlank(atoList[0].ATO__c)) ? atoList[0].ATO__c : toReturn;

        return toReturn;
    }

    @AuraEnabled
    public static Boolean checkFieldCoerenceSpGas(Map<String, Object> inputFieldMap){

        Boolean hasCoerence = false;
        hasCoerence = HDT_SRV_FieldCoerenceServicePoint.checkCoerence(inputFieldMap);

        return hasCoerence;
    }

    @AuraEnabled
    public static string checkCoerenceServicePoint(Map<String, Object> servicePoint, Map<String, Object> inputFieldMap)
    {
        return JSON.serialize(HDT_SRV_FieldCoerenceServicePoint.checkCoerenceServicePoint(servicePoint, inputFieldMap));
    }

}