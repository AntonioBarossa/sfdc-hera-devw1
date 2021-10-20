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

        return servicePointQuery.getRecordByCode(code, fields);
    }

    @AuraEnabled
    public static ServicePoint__c createServicePoint(ServicePoint__c servicePoint) {
        system.debug('HDT_LC_TargetObjectCreateForm createServicePoint ' + servicePoint );
        if(servicePoint.MeterStatus__c == 'Bozza'){
            servicePoint.Account__c=null;
        }
        ServicePoint__c servicePo =  serviceSp.createRecord(servicePoint);
       
        updateServicePoint(servicePoint);

        /*List<SaleServiceItem__c> listSale = saleServItem.getSaleByServicePoint(servicePo.id);
        Sale__c s = new Sale__c();
        if(listSale != null && !listSale.isEmpty()){
            s.id = listSale[0].opportunity__r.Sale__c;
            boolean isTransitorio = HDT_UTL_Sales.isTransition(servicePo,s);
            if(isTransitorio){
                HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse resp = HDT_WS_TransitionWinBack.callTransitionCom(servicePo.ServicePointCode__c);
                if(resp != null && !resp.result.isEmpty()){
                    if('in Corso'.equalsIgnoreCase(resp.result[0].status)){
                        servicePo.SwitchInWinback__c = true;
                    }
                    else{
                        servicePo.SwitchInWinback__c = false;
                    }
                }
                else{
                    servicePo.SwitchInWinback__c = false;
                }
            }
            else{
                servicePo.SwitchInWinback__c = false;
            }
            serviceSp.updateRecord(servicePo);
        }*/
        return servicePo;
    }
    @AuraEnabled
    public static ServicePoint__c createServicePoint2(ServicePoint__c servicePoint,Sale__c sale) {
        system.debug('HDT_LC_TargetObjectCreateForm createServicePoint ' + servicePoint );
        if(servicePoint.MeterStatus__c == 'Bozza'){
            servicePoint.Account__c=null;
        }
        //ServicePoint__c servicePo =  serviceSp.createRecord(servicePoint);
       
        updateServicePoint3(servicePoint,sale);

        /*List<SaleServiceItem__c> listSale = saleServItem.getSaleByServicePoint(servicePo.id);
        Sale__c s = new Sale__c();
        if(listSale != null && !listSale.isEmpty()){
            s.id = listSale[0].opportunity__r.Sale__c;
            boolean isTransitorio = HDT_UTL_Sales.isTransition(servicePo,s);
            if(isTransitorio){
                HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse resp = HDT_WS_TransitionWinBack.callTransitionCom(servicePo.ServicePointCode__c);
                if(resp != null && !resp.result.isEmpty()){
                    if('in Corso'.equalsIgnoreCase(resp.result[0].status)){
                        servicePo.SwitchInWinback__c = true;
                    }
                    else{
                        servicePo.SwitchInWinback__c = false;
                    }
                }
                else{
                    servicePo.SwitchInWinback__c = false;
                }
            }
            else{
                servicePo.SwitchInWinback__c = false;
            }
            serviceSp.updateRecord(servicePo);
        }*/
        return servicePoint;
    }

    /** @author Andrei Necsulescu (andrei.necsulescu@webresults.it) 
     * This method is necessary because passing the object directly Removes the decimals from the numbers */
    @AuraEnabled
    public static ServicePoint__c createServicePoinString(String servicePoint, Sale__c sale){
        
        System.debug('createServicePoint_tmp received servicepoint string ' + servicePoint);
        
        ServicePoint__c servicePointObject = (ServicePoint__c)JSON.deserialize(servicePoint, ServicePoint__c.class);
        servicePointObject.ImplantTypeTemp__c = servicePointObject.ImplantType__c;
        servicePointObject.SupplyTypeTemp__c = servicePointObject.SupplyType__c;
        servicePointObject.SupplyType__c = null;
        servicePointObject.ImplantType__c = null;
        
        /*try{
            Map<String, Object> servMap = new Map<String, Object>( servicePointObject.getPopulatedFieldsAsMap() );
            servMap.put('ImplantTypeTemp__c',servMap.get('ImplantType__c'));//remove( 'MeterStatus__c' );
            servMap.put('SupplyTypeTemp__c',servMap.get('SupplyType__c'));
            servMap.remove('ImplantType__c');
            servMap.remove('SupplyType__c');
            servicePointObject = (ServicePoint__c) JSON.deserialize( JSON.serialize( servMap ), ServicePoint__c.class );
            System.debug(servicePointObject);
        }catch(Exception e){
            System.debug('ERRORE utilizzo vecchia versione');
        }*/

        System.debug('createServicePoint_tmp converted servicepoint string ' + servicePointObject);

        createServicePoint2(servicePointObject, sale);

        return servicePointObject;

    }

   // @future(callout=true)
    public static void updateServicePoint(ServicePoint__c servicePo) {   
        
        //List<ServicePoint__c> listServ = servicePointQuery.getRecordById(id,'Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, SupplyAddress__c, Distributor__c, ServicePointCode__c, SupplyCity__c, SupplyCountry__c, SupplyPlace__c, SupplyPostalCode__c, SupplyProvince__c, SupplySAPCityCode__c, SupplySAPStreetCode__c, SupplyStreetNumberExtension__c, SupplyStreetNumber__c, SupplyStreet__c, Account__c, CommoditySector__c, MeterSN__c, TemporaryContractCode__c, BrandLogo__c, BuildingCode__c, ActivationEleExternalDistributor__c, ImplantTypeGen__c, RowIdSiebel__c, SAPImplantCode__c, SupplyType_Deprecate__c, UseCategory__c, PlugPresence__c, ImplantInstallationDate__c, IsRemoteManaged__c, LockInformation__c, SwitchInWinback__c, CurrentYearConsumption__c, RemiCode__c, AnnualConsumption__c, Resident__c, MeterType__c, PowerAvailable__c, MarketOrigin__c, PowerContractual__c, FlowComputerSN__c, VoltageLevel__c, DisconnectibilityPhone__c, SupplyIsAddressVerified__c, SupplyType__c, Potentiality__c, Pressure__c, SupplyAddessIsForeign__c, UseTypeEnergy__c, WithdrawalClass__c, RequestPhase__c, MaxRequiredPotential__c, PreviousYearConsumption__c, Status__c, GlobalMigrationKey__c, Disconnectable__c, DisconnectibilityType__c, IsMigrated__c, AnnualConsumptionStandardM3__c, ElectricConsumptionZone1__c, ElectricConsumptionZone2__c, ElectricConsumptionZone3__c, Excises__c, RegionalAdditional__c, SupplyCityCode__c, SupplyStreetCode__c, ImplantType__c, Vendor__c, MeterClass__c, Company__c, SupplyPlaceCode__c, MeterStatus__c, PowerRequested__c, SupplyStreetName__c, PressureLevel__c');
       // ServicePoint__c servicePo = listServ[0];if()
        System.debug('******1');
        if(servicePo.ServicePointCode__c != null){
            System.debug('******2');
            List<SaleServiceItem__c> listSale = saleServItem.getSaleByServicePointFilterCode(servicePo.ServicePointCode__c);
            Sale__c s = new Sale__c();
            HDT_QR_Sale saQr = new HDT_QR_Sale();
            if(listSale != null && !listSale.isEmpty()){
                System.debug('******3');
                s.id = listSale[0].opportunity__r.Sale__c;
                System.debug('******4');
                s = saQr.getRecordById(listSale[0].opportunity__r.Sale__c,'id,Account__r.Category__c,Account__r.CompanyOwner__c');
                System.debug('******5');
                boolean isTransitorio = HDT_UTL_Sales.isTransitionNoUp(servicePo,s);
                System.debug('******6:' +isTransitorio);
                if(isTransitorio){
                    System.debug('******7');
                    HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse resp = HDT_WS_TransitionWinBack.callTransitionCom(servicePo.ServicePointCode__c);
                    System.debug('******8:' + resp);
                    if(resp != null && resp.result!=null && !resp.result.isEmpty()){
                        if('in Corso'.equalsIgnoreCase(resp.result[0].status)){
                            servicePo.SwitchInWinback__c = true;
                        }
                        // else{
                           // servicePo.SwitchInWinback__c = false;
                        // }
                    }
                    // else{
                      //  servicePo.SwitchInWinback__c = false;
                    // }
                }
                // else{
                  //  servicePo.SwitchInWinback__c = false;
                // }    
            }
        }
        serviceSp.updateRecord(servicePo);
        /*s.id = id;
        s.SwitchInWinback__c = true;
        serviceSp.updateRecord(s);*/
    }
    
    public static void updateServicePoint2(ServicePoint__c servicePo,Sale__c sa){   
        
        //List<ServicePoint__c> listServ = servicePointQuery.getRecordById(id,'Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, SupplyAddress__c, Distributor__c, ServicePointCode__c, SupplyCity__c, SupplyCountry__c, SupplyPlace__c, SupplyPostalCode__c, SupplyProvince__c, SupplySAPCityCode__c, SupplySAPStreetCode__c, SupplyStreetNumberExtension__c, SupplyStreetNumber__c, SupplyStreet__c, Account__c, CommoditySector__c, MeterSN__c, TemporaryContractCode__c, BrandLogo__c, BuildingCode__c, ActivationEleExternalDistributor__c, ImplantTypeGen__c, RowIdSiebel__c, SAPImplantCode__c, SupplyType_Deprecate__c, UseCategory__c, PlugPresence__c, ImplantInstallationDate__c, IsRemoteManaged__c, LockInformation__c, SwitchInWinback__c, CurrentYearConsumption__c, RemiCode__c, AnnualConsumption__c, Resident__c, MeterType__c, PowerAvailable__c, MarketOrigin__c, PowerContractual__c, FlowComputerSN__c, VoltageLevel__c, DisconnectibilityPhone__c, SupplyIsAddressVerified__c, SupplyType__c, Potentiality__c, Pressure__c, SupplyAddessIsForeign__c, UseTypeEnergy__c, WithdrawalClass__c, RequestPhase__c, MaxRequiredPotential__c, PreviousYearConsumption__c, Status__c, GlobalMigrationKey__c, Disconnectable__c, DisconnectibilityType__c, IsMigrated__c, AnnualConsumptionStandardM3__c, ElectricConsumptionZone1__c, ElectricConsumptionZone2__c, ElectricConsumptionZone3__c, Excises__c, RegionalAdditional__c, SupplyCityCode__c, SupplyStreetCode__c, ImplantType__c, Vendor__c, MeterClass__c, Company__c, SupplyPlaceCode__c, MeterStatus__c, PowerRequested__c, SupplyStreetName__c, PressureLevel__c');
        System.debug('******1');
        if(servicePo.ServicePointCode__c != null){
        System.debug('******2');
        // List<SaleServiceItem__c> listSale = saleServItem.getSaleByServicePointFilterCode(servicePo.ServicePointCode__c);
        Sale__c s = new Sale__c();
        HDT_QR_Sale saQr = new HDT_QR_Sale();
            System.debug('******3');
            boolean isTransitorio = false;
            //s.id = listSale[0].opportunity__r.Sale__c;

            if(sa!=null){
                if(sa.id!=null){
            s = saQr.getRecordById(sa.id,'id,Account__r.Category__c,Account__r.CompanyOwner__c');
                	isTransitorio = HDT_UTL_Sales.isTransitionNoUp(servicePo,s);
                }

            }

            System.debug('******4' + isTransitorio);
            if(isTransitorio){
                System.debug('******5');
                HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse resp = HDT_WS_TransitionWinBack.callTransitionCom(servicePo.ServicePointCode__c);
                System.debug('******6:' + resp.result[0].status);
                if(resp != null && resp.result!=null && !resp.result.isEmpty()){
                    if('in Corso'.equalsIgnoreCase(resp.result[0].status)){
                        servicePo.SwitchInWinback__c = true;
                        if(resp.result[0].effectiveDate != null){
                            servicePo.SwitchOutDate__c = date.valueOf(resp.result[0].effectiveDate);
                        }
                        System.debug('******7:' + resp.result[0].status);
                    }
                    // else{
                      //  servicePo.SwitchInWinback__c = false;
                    // }
                }
                // else{
                   // servicePo.SwitchInWinback__c = false;
                // }
            }
            // else{
               // servicePo.SwitchInWinback__c = false;
            // }
            
        
        }
        serviceSp.updateRecord(servicePo);
        /*s.id = id;
        s.SwitchInWinback__c = true;
        serviceSp.updateRecord(s);*/
    }
    public static void updateServicePoint3(ServicePoint__c servicePo,Sale__c sa) {   
        
        //List<ServicePoint__c> listServ = servicePointQuery.getRecordById(id,'Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, SupplyAddress__c, Distributor__c, ServicePointCode__c, SupplyCity__c, SupplyCountry__c, SupplyPlace__c, SupplyPostalCode__c, SupplyProvince__c, SupplySAPCityCode__c, SupplySAPStreetCode__c, SupplyStreetNumberExtension__c, SupplyStreetNumber__c, SupplyStreet__c, Account__c, CommoditySector__c, MeterSN__c, TemporaryContractCode__c, BrandLogo__c, BuildingCode__c, ActivationEleExternalDistributor__c, ImplantTypeGen__c, RowIdSiebel__c, SAPImplantCode__c, SupplyType_Deprecate__c, UseCategory__c, PlugPresence__c, ImplantInstallationDate__c, IsRemoteManaged__c, LockInformation__c, SwitchInWinback__c, CurrentYearConsumption__c, RemiCode__c, AnnualConsumption__c, Resident__c, MeterType__c, PowerAvailable__c, MarketOrigin__c, PowerContractual__c, FlowComputerSN__c, VoltageLevel__c, DisconnectibilityPhone__c, SupplyIsAddressVerified__c, SupplyType__c, Potentiality__c, Pressure__c, SupplyAddessIsForeign__c, UseTypeEnergy__c, WithdrawalClass__c, RequestPhase__c, MaxRequiredPotential__c, PreviousYearConsumption__c, Status__c, GlobalMigrationKey__c, Disconnectable__c, DisconnectibilityType__c, IsMigrated__c, AnnualConsumptionStandardM3__c, ElectricConsumptionZone1__c, ElectricConsumptionZone2__c, ElectricConsumptionZone3__c, Excises__c, RegionalAdditional__c, SupplyCityCode__c, SupplyStreetCode__c, ImplantType__c, Vendor__c, MeterClass__c, Company__c, SupplyPlaceCode__c, MeterStatus__c, PowerRequested__c, SupplyStreetName__c, PressureLevel__c');
        System.debug('******1');
        if(servicePo.ServicePointCode__c != null){
        System.debug('******2');
        // List<SaleServiceItem__c> listSale = saleServItem.getSaleByServicePointFilterCode(servicePo.ServicePointCode__c);
        Sale__c s = new Sale__c();
        HDT_QR_Sale saQr = new HDT_QR_Sale();
            System.debug('******3');
            //s.id = listSale[0].opportunity__r.Sale__c;
            if(sa!=null){

            s = saQr.getRecordById(sa.id,'id,Account__r.Category__c,Account__r.CompanyOwner__c');
            }
            boolean isTransitorio = HDT_UTL_Sales.isTransitionNoUp(servicePo,s);
            System.debug('******4' + isTransitorio);
            if(isTransitorio){
                System.debug('******5');
                HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse resp = HDT_WS_TransitionWinBack.callTransitionCom(servicePo.ServicePointCode__c);
                if(resp != null && resp.result!=null && !resp.result.isEmpty()){
                    if('in Corso'.equalsIgnoreCase(resp.result[0].status)){
                        //effectiveDate
                        servicePo.SwitchInWinback__c = true;
                        if(resp.result[0].effectiveDate != null){
                            servicePo.SwitchOutDate__c = date.valueOf(resp.result[0].effectiveDate);
                        }
                        System.debug('******7:' + resp.result[0].status);
                    }
                    // else{
                      //  servicePo.SwitchInWinback__c = false;
                      //  servicePo.SwitchOutDate__c = null;
                    // }
                }
                // else{
                  //  servicePo.SwitchInWinback__c = false;
                  //  servicePo.SwitchOutDate__c = null;
                // }
            }
            // else{
              //  servicePo.SwitchInWinback__c = false;
              //  servicePo.SwitchOutDate__c = null;
            // }
            
        
        }
        serviceSp.createRecord(servicePo);
        /*s.id = id;
        s.SwitchInWinback__c = true;
        serviceSp.updateRecord(s);*/
    }

    @AuraEnabled
    public static ServicePoint__c confirmServicePoint2(ServicePoint__c servicePoint, Boolean sap,Sale__c sale){
        system.debug('HDT_LC_TargetObjectCreateForm confirmServicePoint START');
        system.debug('ServicePoint : ' + servicePoint);
        system.debug('sale : ' + sale);
        system.debug('isSap = ' +  sap);
        servicePoint.ImplantTypeTemp__c = servicePoint.ImplantType__c;
        servicePoint.SupplyTypeTemp__c = servicePoint.SupplyType__c;
        servicePoint.SupplyType__c = null;
        servicePoint.ImplantType__c = null;
        /* try{
            Map<String, Object> servMap = new Map<String, Object>( servicePoint.getPopulatedFieldsAsMap() );
            servMap.put('ImplantTypeTemp__c',servMap.get('ImplantType__c'));//remove( 'MeterStatus__c' );
            servMap.put('SupplyTypeTemp__c',servMap.get('SupplyType__c'));
            servMap.remove('ImplantType__c');
            servMap.remove('SupplyType__c');
            servicePoint = (ServicePoint__c) JSON.deserialize( JSON.serialize( servMap ), ServicePoint__c.class );
            System.debug(servicePoint);
        }catch(Exception e){
            System.debug('ERRORE utilizzo vecchia versione');
        }*/
        if(sap == false){
            system.debug('entra in updateRecord');
           // serviceSp.updateRecord(servicePoint);
           updateServicePoint2(servicePoint,sale);
        }else{
            system.debug('entra in createRecord');
    
            //serviceSp.createRecord(servicePoint); 

            updateServicePoint3(servicePoint,sale);
        }
           
        //updateServicePoint2(servicePoint,sale);
        /*List<SaleServiceItem__c> listSale = saleServItem.getSaleByServicePoint(servicePoint.id);
        Sale__c s = new Sale__c();
        if(listSale != null && !listSale.isEmpty()){
            s.id = listSale[0].opportunity__r.Sale__c;
            boolean isTransitorio = HDT_UTL_Sales.isTransition(servicePoint,s);
            System.debug('****:' + isTransitorio);
            if(isTransitorio){
                HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse resp = HDT_WS_TransitionWinBack.callTransitionCom(servicepoint.ServicePointCode__c);
                system.debug('****Here4:');
                if(resp != null && resp.result != null &&!resp.result.isEmpty()){
                    system.debug('****Here5:');
                    if('in Corso'.equalsIgnoreCase(resp.result[0].status)){
                        system.debug('****Here6:');
                        servicePoint.SwitchInWinback__c = true;
                    }
                    else{
                        system.debug('****Here7:');
                        servicePoint.SwitchInWinback__c = false;
                    }
                }
                else{
                    system.debug('****Here8:');
                    servicePoint.SwitchInWinback__c = false;
                }
            }
            else{
                system.debug('****Here9:');
                servicePoint.SwitchInWinback__c = false;
            }
            updateServicePoint(servicePoint.id);
        }*/

        system.debug('HDT_LC_TargetObjectCreateForm confirmServicePoint END');
        return servicePoint;
    }
    @AuraEnabled
    public static ServicePoint__c confirmServicePoint(ServicePoint__c servicePoint, Boolean sap){
        system.debug('HDT_LC_TargetObjectCreateForm confirmServicePoint START');
        system.debug('ServicePoint : ' + servicePoint);
        system.debug('isSap = ' +  sap);
        if(sap == false){
            system.debug('entra in updateRecord');
           // serviceSp.updateRecord(servicePoint);
        }else{
            system.debug('entra in createRecord');

            serviceSp.createRecord(servicePoint);
        }
           
        updateServicePoint(servicePoint);
        /*List<SaleServiceItem__c> listSale = saleServItem.getSaleByServicePoint(servicePoint.id);
        Sale__c s = new Sale__c();
        if(listSale != null && !listSale.isEmpty()){
            s.id = listSale[0].opportunity__r.Sale__c;
            boolean isTransitorio = HDT_UTL_Sales.isTransition(servicePoint,s);
            System.debug('****:' + isTransitorio);
            if(isTransitorio){
                HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse resp = HDT_WS_TransitionWinBack.callTransitionCom(servicepoint.ServicePointCode__c);
                system.debug('****Here4:');
                if(resp != null && resp.result != null &&!resp.result.isEmpty()){
                    system.debug('****Here5:');
                    if('in Corso'.equalsIgnoreCase(resp.result[0].status)){
                        system.debug('****Here6:');
                        servicePoint.SwitchInWinback__c = true;
                    }
                    else{
                        system.debug('****Here7:');
                        servicePoint.SwitchInWinback__c = false;
                    }
                }
                else{
                    system.debug('****Here8:');
                    servicePoint.SwitchInWinback__c = false;
                }
            }
            else{
                system.debug('****Here9:');
                servicePoint.SwitchInWinback__c = false;
            }
            updateServicePoint(servicePoint.id);
        }*/

        system.debug('HDT_LC_TargetObjectCreateForm confirmServicePoint END');
        return servicePoint;
    }

    @AuraEnabled
    public static List<DistributorPointCode__c> getDistributorPointCode(String code,String commodity) {
        
        system.debug('HDT_LC_TargetObjectCreateForm getDistributorPointCode START');
        system.debug('code : '+ code);

        HDT_QR_DistributorPointCode queryClass = new HDT_QR_DistributorPointCode();
        // List<Map<String,Object>> listCustomDistributorPoint = new List<Map<String,Object>>();
        //Map<String,String> customDistributorPoint = new Map<String,String>();

        // String[] splitCode = code.split('');
        // system.debug('splitCode : '+ splitCode);
        // String finalCode = splitCode[0]+splitCode[1]+splitCode[2]+splitCode[3]+splitCode[4];
        // system.debug('finalCode : '+ finalCode);

        String finalCode = code.left(5);
        List<DistributorPointCode__c> listDistributorPoint = queryClass.getDistributorPointCode(finalCode,commodity);
        // system.debug('listDistributorPoint : '+ listDistributorPoint);
        // Map<String,Object> row = new Map<String,Object>();
        
        system.debug('HDT_LC_TargetObjectCreateForm getDistributorPointCode END');
        return listDistributorPoint;
    }
}