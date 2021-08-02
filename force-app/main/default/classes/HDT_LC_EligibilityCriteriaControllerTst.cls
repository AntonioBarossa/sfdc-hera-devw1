@isTest
public class HDT_LC_EligibilityCriteriaControllerTst {

    @testSetup
    static void setupData() {

        List<Product2> productList = new List<Product2>();
        Product2 p = new Product2();
        p.ProductCode = 'pCode01';
        p.Version__c = '01V1';
        p.Name = 'ExampleProduct';
        p.Family = Label.HDT_ProductFamilyTrigger;
        productList.add(p);
        insert productList;

        EligibilityCriteria__c criteria = new EligibilityCriteria__c();
        criteria.EligibleForAllCities__c = true;//Checkbox
        criteria.Product__c = productList[0].Id;//Lookup(Product)
        insert criteria;

    }

    @isTest
    static void getCityZipCodeObj(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c
            LIMIT 1
        ];

        Test.startTest();
        String record = '{"Product__c":"' + criteria.Product__c + '","CategoryTypeClientOperator__c":"includesAll","CategoryTypeClient__c":null,"ChannelOperator__c":"includesAll","Channel__c":null,"OriginMarketOperator__c":"includesAll","OriginMarket__c":null,"ClientMarkerOperator__c":"includesAll","ClientMarker__c":null,"CompanyOwnerOperator__c":"includesAll","CompanyOwner__c":null,"EquipmenType__c":null,"PromoCode__c":null,"ResidentDeliveryAddress__c":null,"NewClient__c":null,"LoginGroup__c":null,"Agency__c":null,"UseCategory__c":null,"CampaignName__c":null,"ClientAgeMin__c":null,"ClientAgeMax__c":null,"PowerRangeMin__c":null,"PowerRangeMax__c":null,"ConsumptionRangeEEmin__c":null,"ConsumptionRangeEEmax__c":null,"ConsumptionRangeGASmin__c":null,"ConsumptionRangeGASmax__c":null}';
        String dataReceived = '{"eligibleForAllCities": false,"provinceList":[{"cityAvailable":[{"label":"San Giovanni Gemini","value":"84036","id":"84036"}],"cityRemoved":[],"isEnabled":true,"label":"Agrigento","value":"AG"}]}';
        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse criteriaToSave = HDT_LC_EligibilityCriteriaController.saveEligibilityCriteria(criteria.Product__c, record, dataReceived);
        
        String dataReceived2 = '{"eligibleForAllCities": true,"provinceList":[{"cityAvailable":[{"label":"San Giovanni Gemini","value":"84036","id":"84036"}],"cityRemoved":[],"isEnabled":true,"label":"Agrigento","value":"AG"}]}';
        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse criteriaToSave2 = HDT_LC_EligibilityCriteriaController.saveEligibilityCriteria(criteria.Product__c, record, dataReceived2);
        Test.stopTest();

    }

    @isTest
    static void getCityZipCodeObj2(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c
            LIMIT 1
        ];

        Test.startTest();
        HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode zipCodeObjStandard = HDT_LC_EligibilityCriteriaController.getCityZipCodeObj('', '');
        HDT_WRP_EligibilityCriteria.HDT_WRP_CityZipCode zipCodeObj = HDT_LC_EligibilityCriteriaController.getCityZipCodeObj('', criteria.Id);
        Test.stopTest();

    }

    @isTest
    static void getExistingCriteria(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c
            LIMIT 1
        ];

        Test.startTest();
        HDT_WRP_EligibilityCriteria.HDT_WRP_Criterion criteriaRecord = HDT_LC_EligibilityCriteriaController.getExistingCriteria(criteria.Product__c);
        Test.stopTest();

    }

    @isTest
    static void deleteEligibilityCriteria(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c
            LIMIT 1
        ];

        Test.startTest();
        HDT_WRP_EligibilityCriteria.HDT_WRP_SaveResponse saveResponse = HDT_LC_EligibilityCriteriaController.deleteEligibilityCriteria(criteria.Product__c, criteria.Id);
        Test.stopTest();
    }

    @isTest
    static void cloneEligibilityCriteriaRecord(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c
            LIMIT 1
        ];

        criteria.EligibleForAllCities__c = false;
        update criteria;

        Test.startTest();
        String s = HDT_LC_EligibilityCriteriaController.cloneEligibilityCriteriaRecord(criteria.Id, criteria.Product__c);
        Test.stopTest();
    }

    @isTest
    static void getEligibilityCriteriaRecord(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c
            LIMIT 1
        ];

        Test.startTest();
        HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj muniObj = HDT_LC_EligibilityCriteriaController.getEligibilityCriteriaRecord(criteria.Id);

        criteria.EligibleForAllCities__c = false;
        update criteria;

        HDT_WRP_EligibilityCriteria.HDT_WRP_MunicipalityTreeObj muniObj2 = HDT_LC_EligibilityCriteriaController.getEligibilityCriteriaRecord(criteria.Id);
        Test.stopTest();
    }

    @isTest
    static void handleRecordDelete(){

        EligibilityCriteria__c criteria = [
            SELECT Id, Product__c
            FROM EligibilityCriteria__c
            LIMIT 1
        ];

        Test.startTest();
        HDT_LC_EligibilityCriteriaCtrlHelper.handleRecordDelete(false, criteria.Id);
        HDT_LC_EligibilityCriteriaCtrlHelper.handleRecordDelete(true, criteria.Id);
        Test.stopTest();
    }

}