@isTest
public class HDT_UTL_GenerateMunicipalityJsonTst {

    @testSetup
    static void setup() {
        List<City__c> cityList = new List<City__c>();
        List<String> csvList = new List<String>();
        csvList.add('1,1001,Agliè,Piemonte,Torino,TO');
        csvList.add('1,1002,Airasca,Piemonte,Torino,TO');
        csvList.add('1,1003,Ala di Stura,Piemonte,Torino,TO');
        csvList.add('1,1004,Albiano d\'Ivrea,Piemonte,Torino,TO');
        csvList.add('1,1006,Almese,Piemonte,Torino,TO');
        csvList.add('1,1007,Alpette,Piemonte,Torino,TO');
        csvList.add('1,1008,Alpignano,Piemonte,Torino,TO');
        csvList.add('1,1009,Andezeno,Piemonte,Torino,TO');
        csvList.add('1,1010,Andrate,Piemonte,Torino,TO');
        csvList.add('1,1011,Angrogna,Piemonte,Torino,TO');
        csvList.add('8,99005,Misano Adriatico,Emilia-Romagna,Rimini,RN');
        csvList.add('8,99006,Mondaino,Emilia-Romagna,Rimini,RN');
        csvList.add('8,99008,Montefiore Conca,Emilia-Romagna,Rimini,RN');
        csvList.add('8,99009,Montegridolfo,Emilia-Romagna,Rimini,RN');
        csvList.add('8,99011,Morciano di Romagna,Emilia-Romagna,Rimini,RN');
        csvList.add('8,99013,Riccione,Emilia-Romagna,Rimini,RN');
        csvList.add('9,48015,Fiesole,Toscana,Firenze,FI');
        csvList.add('9,48017,Firenze,Toscana,Firenze,FI');
        csvList.add('9,48018,Firenzuola,Toscana,Firenze,FI');
        csvList.add('9,48019,Fucecchio,Toscana,Firenze,FI');
        csvList.add('9,48020,Gambassi Terme,Toscana,Firenze,FI');
        csvList.add('9,48021,Greve in Chianti,Toscana,Firenze,FI');
        csvList.add('9,48022,Impruneta,Toscana,Firenze,FI');
        csvList.add('9,48024,Lastra a Signa,Toscana,Firenze,FI');

        City__c city;
        for(String csv : csvList){
            List<String> csvValue = csv.split(',');
            city = new City__c();
            city.RegionCode__c = csvValue[0];
            city.MunicipalityCode__c = csvValue[1];
            city.Name = csvValue[2];
            city.RegionName__c = csvValue[3];
            city.ProvinceName__c = csvValue[4];
            city.Province__c = csvValue[5];
            cityList.add(city);
        }

        insert cityList;

    }

    @isTest
    static void createJsonObj_test1(){
        Test.startTest();
        HDT_UTL_GenerateMunicipalityJson.createJsonObj(false);
        List<ContentVersion> contVersList = [SELECT Id, IsMajorVersion FROM ContentVersion];
        Test.stopTest();
        System.assertEquals(true, contVersList[0].IsMajorVersion, 'ContentVersion IsMajorVersion');
    }

    @isTest
    static void createJsonObj_test2(){
        Test.startTest();
        HDT_UTL_GenerateMunicipalityJson.createJsonObj(true);
        List<ContentVersion> contVersList = [SELECT Id, IsMajorVersion FROM ContentVersion];
        Test.stopTest();
        System.assertEquals(true, contVersList[0].IsMajorVersion, 'ContentVersion IsMajorVersion');
    }

}