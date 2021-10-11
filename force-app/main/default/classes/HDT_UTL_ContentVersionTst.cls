/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 11/10/2021
 * @description HDT_UTL_ContentVersion for Test Classes
 * @history Laureta Demishaj – 11/10/2021 – Created class
*/
@isTest
public class HDT_UTL_ContentVersionTst {
 @isTest
    public static void makeFileTest(){
        Test.startTest();
        Id response = HDT_UTL_ContentVersion.makeFile('This is the body','This is the fileName' ,'This is the fileTitle');
        Test.stopTest();
        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE PathOnClient ='This is the fileName' LIMIT 1];
        System.assertEquals(response, cv.Id, 'The ContentVersion wasn\'t created!');
        System.assertNotEquals(null, response, 'The ContentVersion wasn\'t created!');
    }
}