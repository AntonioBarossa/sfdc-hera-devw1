@isTest
public class HDT_LC_EligibilityCriteriaControllerTst {

    @testSetup
    static void setupData() {

        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(2, false);
        productList[0].ProductCode = 'pCode01';
        productList[0].Version__c = '01V1';
        productList[0].Name = 'ExampleProduct';
        productList[0].Family = Label.HDT_ProductFamilyTrigger;

        productList[1].ProductCode = 'pCode02';
        productList[1].Version__c = '01V1';
        productList[1].Name = 'ExampleProduct2';
        productList[1].Status__c = 'In Sviluppo';

        insert productList;

        List<EligibilityCriteria__c> criterias = new List<EligibilityCriteria__c>();
        EligibilityCriteria__c criteria1 = new EligibilityCriteria__c();
        EligibilityCriteria__c criteria2 = new EligibilityCriteria__c();

        criteria1.EligibleForAllCities__c = true;//Checkbox
        criteria1.Product__c = productList[0].Id;//Lookup(Product)
        
        criteria2.EligibleForAllCities__c = false;//Checkbox
        criteria2.Product__c = productList[1].Id;//Lookup(Product)

        criterias.add(criteria1);
        criterias.add(criteria2);
        insert criterias;

        EligibleMunicipality__c muni = new EligibleMunicipality__c();
        muni.Name = 'Agrigento';
        muni.AreaCode__c = 'AG';
        muni.JSONCode__c = '{"value":"AG","label":"Agrigento","isEnabled":true,"cityRemoved":[],"cityAvailable":[{"value":"84036","label":"San Giovanni Gemini"},{"value":"84034","label":"Sambuca di Sicilia"},{"value":"84033","label":"Ribera"},{"value":"84032","label":"Realmonte"},{"value":"84031","label":"Ravanusa"},{"value":"84030","label":"Raffadali"},{"value":"84029","label":"Racalmuto"},{"value":"84028","label":"Porto Empedocle"},{"value":"84027","label":"Palma di Montechiaro"},{"value":"84026","label":"Naro"},{"value":"84025","label":"Montevago"},{"value":"84024","label":"Montallegro"},{"value":"84023","label":"Menfi"},{"value":"84022","label":"Lucca Sicula"},{"value":"84021","label":"Licata"},{"value":"84020","label":"Lampedusa e Linosa"},{"value":"84019","label":"Joppolo Giancaxio"},{"value":"84018","label":"Grotte"},{"value":"84017","label":"Favara"},{"value":"84016","label":"Comitini"},{"value":"84015","label":"Cianciana"},{"value":"84014","label":"Cattolica Eraclea"},{"value":"84013","label":"Castrofilippo"},{"value":"84012","label":"Casteltermini"},{"value":"84011","label":"Canicattì"},{"value":"84010","label":"Campobello di Licata"},{"value":"84009","label":"Cammarata"},{"value":"84008","label":"Camastra"},{"value":"84007","label":"Caltabellotta"},{"value":"84006","label":"Calamonaci"},{"value":"84005","label":"Burgio"},{"value":"84004","label":"Bivona"},{"value":"84003","label":"Aragona"},{"value":"84002","label":"Alessandria della Rocca"},{"value":"84001","label":"Agrigento"},{"value":"84035","label":"San Biagio Platani"},{"value":"84043","label":"Villafranca Sicula"},{"value":"84042","label":"Siculiana"},{"value":"84041","label":"Sciacca"},{"value":"84040","label":"Santo Stefano Quisquina"},{"value":"84039","label":"Sant\'Angelo Muxaro"},{"value":"84038","label":"Santa Margherita di Belice"},{"value":"84037","label":"Santa Elisabetta"}]}';
        muni.EligibilityCriteria__c = criteria1.Id;
        insert muni;

    }

    @isTest
    static void getCityZipCodeObj(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c WHERE EligibleForAllCities__c = true
            LIMIT 1
        ];

        Test.startTest();
        String record = '{"Product__c":"' + criteria.Product__c + '","CategoryTypeClientOperator__c":"includesAll","CategoryTypeClient__c":null,"ChannelOperator__c":"includesAll","Channel__c":null,"OriginMarketOperator__c":"includesAll","OriginMarket__c":null,"ClientMarkerOperator__c":"includesAll","ClientMarker__c":null,"CompanyOwnerOperator__c":"includesAll","CompanyOwner__c":null,"EquipmenType__c":null,"PromoCode__c":null,"ResidentDeliveryAddress__c":null,"NewClient__c":null,"LoginGroup__c":null,"Agency__c":null,"UseCategory__c":null,"CampaignName__c":null,"ClientAgeMin__c":null,"ClientAgeMax__c":null,"PowerRangeMin__c":null,"PowerRangeMax__c":null,"ConsumptionRangeEEmin__c":null,"ConsumptionRangeEEmax__c":null,"ConsumptionRangeGASmin__c":null,"ConsumptionRangeGASmax__c":null}';
        String dataReceived = '{"eligibleForAllCities": false,"provinceList":[{"cityAvailable":[{"label":"San Giovanni Gemini","value":"84036","id":"84036"}],"cityRemoved":[],"isEnabled":true,"label":"Agrigento","value":"AG"}]}';
        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse criteriaToSave = HDT_LC_EligibilityCriteriaController.saveEligibilityCriteria(criteria.Product__c, record, dataReceived);
        
        System.assertEquals(true, criteriaToSave.success, 'success != true');
        System.assert(!String.isBlank(criteriaToSave.criteriaId), 'criteriaId == null');

        String dataReceived2 = '{"eligibleForAllCities": true,"provinceList":[{"cityAvailable":[{"label":"San Giovanni Gemini","value":"84036","id":"84036"}],"cityRemoved":[],"isEnabled":true,"label":"Agrigento","value":"AG"}]}';
        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse criteriaToSave2 = HDT_LC_EligibilityCriteriaController.saveEligibilityCriteria(criteria.Product__c, record, dataReceived2);

        System.assertEquals(true, criteriaToSave2.success, 'success != true');
        System.assert(!String.isBlank(criteriaToSave2.criteriaId), 'criteriaId == null');

        Test.stopTest();

    }

    @isTest
    static void getCityZipCodeObj2(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c WHERE EligibleForAllCities__c = true
            LIMIT 1
        ];

        Test.startTest();

        HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode zipCodeObjStandard = HDT_LC_EligibilityCriteriaController.getCityZipCodeObj('', '');

        System.assertEquals('', zipCodeObjStandard.message, 'message != null');
        System.assert(zipCodeObjStandard.regionList.size() > 0, 'regionList.size() == 0');
        
        HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode zipCodeObj = HDT_LC_EligibilityCriteriaController.getCityZipCodeObj('', criteria.Id);

        System.assertEquals(true, zipCodeObj.success, 'success != true');
        System.assertEquals('', zipCodeObj.message, 'message != null');
        System.assert(zipCodeObj.regionList.size() > 0, 'regionList.size() == 0');

        Test.stopTest();

    }

    @isTest
    static void getCityZipCodeObj3(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c WHERE EligibleForAllCities__c = false
            LIMIT 1
        ];

        Test.startTest();
        HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode zipCodeObjStandard = HDT_LC_EligibilityCriteriaController.getCityZipCodeObj('', '');

        System.assertEquals(true, zipCodeObjStandard.success, 'success != true');
        System.assertEquals('', zipCodeObjStandard.message, 'message != null');
        System.assert(zipCodeObjStandard.regionList.size() > 0, 'regionList.size() == 0');

        HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode zipCodeObj = HDT_LC_EligibilityCriteriaController.getCityZipCodeObj('', criteria.Id);

        System.assertEquals(true, zipCodeObj.success, 'success != true');
        System.assertEquals('', zipCodeObj.message, 'message != null');
        System.assert(zipCodeObj.regionList.size() > 0, 'regionList.size() == 0');

        Test.stopTest();

    }


    @isTest
    static void getExistingCriteria(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c WHERE EligibleForAllCities__c = true
            LIMIT 1
        ];

        Test.startTest();
        HDT_WRP_EligibilityCriteria.HDT_WRP_Criterion criteriaRecord = HDT_LC_EligibilityCriteriaController.getExistingCriteria(criteria.Product__c);

        System.assertEquals(true, criteriaRecord.success, 'success != true');
        System.assert(!String.isBlank(criteriaRecord.eligibilityId), 'eligibilityId == null');

        Test.stopTest();

    }

    @isTest
    static void getExistingCriteria2(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c WHERE EligibleForAllCities__c = false
            LIMIT 1
        ];

        Test.startTest();
        HDT_WRP_EligibilityCriteria.HDT_WRP_Criterion criteriaRecord = HDT_LC_EligibilityCriteriaController.getExistingCriteria(criteria.Product__c);

        System.assertEquals(false, criteriaRecord.success, 'success != false');
        System.assert(Label.HDT_EligCriteria_ProductType.equals(criteriaRecord.message), 'message != Label.HDT_EligCriteria_ProductType');

        Test.stopTest();

    }

    @isTest
    static void deleteEligibilityCriteria(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c WHERE EligibleForAllCities__c = true
            LIMIT 1
        ];

        Test.startTest();
        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse = HDT_LC_EligibilityCriteriaController.deleteEligibilityCriteria(criteria.Product__c, criteria.Id);

        System.debug('saveResponse: ' + saveResponse);

        System.assertEquals(true, saveResponse.success, 'success != true');
        System.assert(!String.isBlank(saveResponse.message), 'message == null');

        Test.stopTest();
    }

    @isTest
    static void cloneEligibilityCriteriaRecord(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c WHERE EligibleForAllCities__c = true
            LIMIT 1
        ];

        criteria.EligibleForAllCities__c = false;
        update criteria;

        Test.startTest();

        String s = HDT_LC_EligibilityCriteriaController.cloneEligibilityCriteriaRecord(criteria.Id, criteria.Product__c);

        System.assert(!String.isBlank(s), 'Si è verificato un errore in fase di clonazione dell\' Eligibility Criteria');

        Test.stopTest();
    }

    @isTest
    static void getEligibilityCriteriaRecord(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c WHERE EligibleForAllCities__c = true
            LIMIT 1
        ];

        Test.startTest();
        HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj muniObj = HDT_LC_EligibilityCriteriaController.getEligibilityCriteriaRecord(criteria.Id);

        System.assertEquals(true, muniObj.eligibleForAllCities, 'eligibleForAllCities != true');
        System.assert(muniObj.treeNotAvailableItemList == null, 'treeNotAvailableItemList != null');

        criteria.EligibleForAllCities__c = false;
        update criteria;

        HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj muniObj2 = HDT_LC_EligibilityCriteriaController.getEligibilityCriteriaRecord(criteria.Id);

        System.assertEquals(false, muniObj2.eligibleForAllCities, 'eligibleForAllCities != false');
        System.assert(muniObj2.treeNotAvailableItemList.size() > 0, 'treeNotAvailableItemList.size() == 0');

        Test.stopTest();
    }

    @isTest
    static void handleRecordDelete(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c WHERE EligibleForAllCities__c = true
            LIMIT 1
        ];

        Test.startTest();
        Boolean firstResult = HDT_LC_EligibilityCriteriaCtrlHelper.handleRecordDelete(false, criteria.Id);
        Boolean secondResult = HDT_LC_EligibilityCriteriaCtrlHelper.handleRecordDelete(true, criteria.Id);

        System.assertEquals(true, firstResult, 'firstResult != true');
        System.assertEquals(true, secondResult, 'secondResult != true');

        Test.stopTest();
    }

}