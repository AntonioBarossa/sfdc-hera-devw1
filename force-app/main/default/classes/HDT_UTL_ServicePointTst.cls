/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 23/09/2021
 * @description HDT_UTL_ServicePoint Test Classes
 * @history Lucas Fernandes 23/09/2021 – Created Class
 */
@isTest
public with sharing class HDT_UTL_ServicePointTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_WS_ArrichmentDataEntityResponse response = new HDT_WS_ArrichmentDataEntityResponse();
    private static HDT_WRP_AddressObject addressObject = new HDT_WRP_AddressObject();

	@TestSetup
    static void setup(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;

        System.runAs(internalUser) {

            HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
            spList[0].MeterStatus__c = 'Bozza';
            insert spList;
        }
    }

	@isTest
    public static void testExtractDataFromArriccDataServiceWithExistingSp() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            Test.startTest();

            Date dToday = Date.today().addDays(1);
            String dateStr = String.valueOf(dToday.year() + dToday.month() + dToday.day());

            List<Account> accList = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

            List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject> positions = new List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject>();
            HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'IMPOSTE';
            position.valore = '5';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'DESCRCOMM';
            position.valore = 'Gas'; 
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'ALIQUOTAIVA';
            position.valore = 'CHECK'; 
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'GRUPPONUMERATORE';
            position.valore = 'CHECK';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'VENDITORE';
            position.valore = '13V0000170';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'BP';
            position.valore = '01110';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'DEFINIZIONEOFFERTA';
            position.valore = 'STG_'; 
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'STATODEVICE';
            position.valore = 'A';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'PRESSIONE';
            position.valore = '1.0';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'CODICEREMI';
            position.valore = '123';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'MATRICOLA1';
            position.valore = 'mat';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'BRANDSOCIETARIO';
            position.valore = 'logo';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'DISTRIBUTORE';
            position.valore = accList[0].Id;
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'POD';
            position.valore = 'testServicePointCode';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'MOTGARANZIAFORN';
            position.valore = null;
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'IMPIANTO';
            position.valore = 'testImplantCode';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'RESELLER';
            position.valore = 'X'; 
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'DATACESSAZIONE';
            position.valore = '99991231'; //testar com valor Date.today().addDays(-1), valor inválido e null
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'TIPOIMPIANTO';
            position.valore = '1001-Cottura cibi';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'DESCRTIPOIMP';
            position.valore = 'Cottura';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'CONSUMOCAPDR';
            position.valore = '5.0';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'CONSUMOANNUOEE';
            position.valore = '5.0';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'MERCATO';
            position.valore = 'Default';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'FLAGTELEGESTIBILE';
            position.valore = 'true';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'POTENZACONTRATTUALE';
            position.valore = '2.0';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'POTENZATECNICA';
            position.valore = '2.0';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'TENSIONE';
            position.valore = 'BT';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'RESIDENTEINDFORN';
            position.valore = 'SI';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'CAP';
            position.valore = '35426';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'VIA';
            position.valore = '55';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'CIVICO';
            position.valore = '19';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'LOCALITA';
            position.valore = 'Firenze';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'CODICEVIA';
            position.valore = '123';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'REGIONE';
            position.valore = 'Firenze';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'CODIFICALOCALITA';
            position.valore = 'FR';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'CODICEPAESE';
            position.valore = 'IT';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'MODPAGUSCITA';
            position.valore = 'Rate';
            positions.add(position);
			
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFPAG_FFUG';
            position.valore = '1.0000000';
            positions.add(position);
                        
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFPAGA_FOG';
            position.valore = '0.0000000';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFPAGA_DEP';
            position.valore = '0.0000000';
            positions.add(position);
                        
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFP_DEP355';
            position.valore = '2.0000000';
            positions.add(position);
                        
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'TRATAUNICA';
            position.valore = 'CheckTrauta';
            positions.add(position);
                        
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'DI_TRATAUNICA';
            position.valore = '11/11/1992';
            positions.add(position);
                        
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'TFNCE0000';
            position.valore = '2';
            positions.add(position);
                        
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'TFNCDC0000';
            position.valore = '2';
            positions.add(position);
                        
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFNUM_COMP';
            position.valore = '4.0';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFUADNR';
            position.valore = '6.0';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFUADRS';
            position.valore = '7.0';
            positions.add(position);
                        
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFUND';
            position.valore = '8.0';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFUNDA';
            position.valore = '9.0';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFUNDC';
            position.valore = '9.5';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFUNDI';
            position.valore = '9.9';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFUNDA';
            position.valore = '9.0';
            positions.add(position);
                
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFUNDZ';
            position.valore = '10.0';
            positions.add(position);
                        
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFBI_DIAM1';
            position.valore = '11.0';
            positions.add(position);
                
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFBI_DIAM2';
            position.valore = '12.0';
            positions.add(position);
                
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AF_BOC_IDR';
            position.valore = '13.0';
            positions.add(position);
                        
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'TFRS000000';
            position.valore = '14.0';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AQCNS_ANNO';
            position.valore = '15.0';
            positions.add(position);
                
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFNCOMP';
            position.valore = '3.0';
            positions.add(position);
                        
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFUADRS';
            position.valore = '6.0';
            positions.add(position);
                
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFUADNR';
            position.valore = '6.0';
            positions.add(position);
                          
            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'AFVASCA_AC';
            position.valore = '1';
            positions.add(position);
            

            response.data.posizioni = positions;

            List<ServicePoint__c> spList = [SELECT Id, MeterStatus__c, Distributor__c, Account__c FROM ServicePoint__c WHERE Name='testServicePoint0' LIMIT 1];

            List<ServicePoint__c> spListTest0 = HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(spList[0], response);

            //Testing with different values
            response = new HDT_WS_ArrichmentDataEntityResponse();
            positions = new List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject>();

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'IMPOSTE';
            position.valore = '5';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'DESCRCOMM';
            position.valore = 'Energia Elettrica';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'STATODEVICE';
            position.valore = 'I';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'MOTGARANZIAFORN';
            position.valore = '';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'RESELLER';
            position.valore = ''; 
            positions.add(position);

            response.data.posizioni = positions;

            HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(spList[0], response);

            //Testing other values
            response = new HDT_WS_ArrichmentDataEntityResponse();
            positions = new List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject>();

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'STATODEVICE';
            position.valore = 'Z';
            positions.add(position);

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'DATACESSAZIONE';
            position.valore = '20210320'; 
            positions.add(position);

            response.data.posizioni = positions;

            HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(spList[0], response);

            //Testing other values
            response = new HDT_WS_ArrichmentDataEntityResponse();
            positions = new List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject>();

            position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
            position.campo = 'DATACESSAZIONE'; 
            positions.add(position);

            response.data.posizioni = positions;

            HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(spList[0], response);

            //Testing CALIBRO1 values
            for (Integer i=2; i<19; i++) {
                response = new HDT_WS_ArrichmentDataEntityResponse();
                positions = new List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject>();
                position = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();

                if (i<10) {
                    position.campo = 'CALIBRO1';
                    position.valore = 'GRT00'+i;
                    positions.add(position);
                    response.data.posizioni = positions;

                } else {

                    position.campo = 'CALIBRO1';
                    position.valore = 'GRT0'+i;
                    positions.add(position);
                    response.data.posizioni = positions;
                }    
                HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(spList[0], response);            
            }

            Test.stopTest();

            System.assertEquals(false, spListTest0.isEmpty(), 'ServicePoint populated.');
            System.assertNotEquals(true, spListTest0.isEmpty(), 'ServicePoint not populated.');
        }
    }


    @isTest
    public static void testGetInstanceWrapAddressObject() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

        System.runAs(u){

            Test.startTest();
			List<ServicePoint__c> spList = [SELECT  Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Account__c, AnnualConsumption__c, CommoditySector__c, VATNumberUdb__c, DisconnectibilityPhone__c, PreviousCompany__c, Distributor__c, FlowComputerSN__c, ImplantInstallationDate__c, ImplantTypeGen__c, Disconnectable__c, IsRemoteManaged__c, LockInformation__c, MarketOrigin__c, DisconnectibilityType__c, MeterSN__c, MeterType__c, PlugPresence__c, /*Potentiality__c,*/ PowerAvailable__c, PowerContractual__c, Pressure__c, RemiCode__c, Resident__c, RowIdSiebel__c, SAPImplantCode__c, ServicePointCode__c, SupplyAddessIsForeign__c, SupplyAddress__c, SupplyCity__c, SupplyCountry__c, SupplyIsAddressVerified__c, SupplyPlace__c, SupplyPostalCode__c, SupplyProvince__c, SupplySAPCityCode__c, SupplySAPStreetCode__c, SupplyStreetNumberExtension__c, SupplyStreetNumber__c, AnnualVolumeReplacement__c, SupplyStreet__c, SupplyType_Deprecate__c, SupplyType__c, TemporaryContractCode__c, UseCategory__c, UseTypeEnergy__c, VoltageLevel__c, CurrentYearConsumption__c, MaxRequiredPotential__c, RequestPhase__c, WithdrawalClass__c, GlobalMigrationKey__c, PreviousYearConsumption__c, AnnualConsumptionStandardM3__c, ElectricConsumptionZone1__c, ElectricConsumptionZone2__c, ElectricConsumptionZone3__c, Excises__c, RegionalAdditional__c, IsMigrated__c, SupplyCityCode__c, SupplyStreetCode__c, BrandLogo__c, BuildingCode__c, ActivationEleExternalDistributor__c, Status__c, Vendor__c, ImplantType__c, SwitchInWinback__c, MeterClass__c, Company__c, SupplyPlaceCode__c, MeterStatus__c, PowerRequested__c, SupplyStreetName__c, PressureLevel__c, ExciseEle__c, ExciseGas__c, Vat__c, Collection__c, CorrectiveCoefficient__c, CorrectorDigitNumber__c, CorrectorSN__c, CorrectorSignal__c, CorrectorType__c, CorrectorWithdrawal__c, DigitNumberActive__c, DigitNumberPower__c, DigitNumberReactive__c, DispatchingPoint__c, DistributorTreatment__c, Forfait__c, InstallationDateActive__c, InstallationDatePower__c, InstallationDateReactive__c, MarketTypeCode__c, MaxHourWithdrawal__c, MeterAccessible__c, MeterActiveSN__c, MeterDigitNumber__c, MeterGroup__c, MeterPowerSN__c, MeterReactiveSN__c, MeterSignal__c, MeterYear__c, OrderDueDate__c, PerformanceCost__c, RegimeDate2G__c, RenewalMonth__c, kActive__c, kPower__c, kReactive__c, DistributorNameFormula__c, SAPContractCode__c, isReseller__c, SwitchOutDate__c, ImplantTypeTemp__c, SupplyTypeTemp__c, IsWrongFiscalData__c, IsDigitalMarking__c, NumeratorGroup__c, isSTG__c, SapContractStatus__c, SalesCompanyCode__c  FROM ServicePoint__c WHERE Name='testServicePoint0' LIMIT 1];
            HDT_WRP_AddressObject wrapObj = HDT_UTL_ServicePoint.getInstanceWrapAddressObject(spList[0]);            

            Test.stopTest();
            
            System.assertEquals(false, wrapObj==null, 'wrapObject populated.');
            System.assertNotEquals(true, wrapObj==null, 'wrapObject not populated.');
        }
    }
}