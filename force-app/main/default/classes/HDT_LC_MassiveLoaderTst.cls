@isTest
public with sharing class HDT_LC_MassiveLoaderTst {
    @isTest
    public static void testOk(){
        HDT_LC_MassiveLoader.initialize();
        String processName='Lead';
        HDT_LC_MassiveLoader.getCsvBody(processName);
        
        HDT_LC_MassiveLoader.createMassiveLoaderRequest(processName);
        String data='HERA COMM,HCM,null,347852147,null,,Mario,Rossi,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,,null,,25,null,Maschio,null,SI,1,2020-10-1,Webform callback,AAA,sito standard,NO,1,2020-10-1,Webform callback,HCM,sito standard,null,,null,,2020-10-1,null,,null,,null,,null,,null,test';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{data})        ;
        
        Blob generateFileBlob   = Blob.valueof(data+'\n'+data);
        ContentVersion cv       = new ContentVersion();
        cv.ContentLocation      = 'S';
        cv.VersionData          = generateFileBlob;
        cv.Title                = 'Lead.csv';
        cv.PathOnClient         = 'Lead.csv';
        //cv.FileType             = 'Lead'    ;
        insert cv;
        
        Map<String, Object> response =HDT_LC_MassiveLoader.checkCsv('Lead.csv',cv.id,processName,req.id);
        System.assertEquals(false, response.get('error'), false);
        HDT_LC_MassiveLoader.updateMassiveLoaderRequest(req.id,processName);
        
        
    }
    @isTest
    public static void testOk2(){
        
        String processName='Lead';
        String data='HERA COMM,HCM,null,347852147,null,,Mario,Rossi,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,,null,,25,null,Maschio,null,SI,1,2020-10-1,Webform callback,AAA,sito standard,NO,1,2020-10-1,Webform callback,HCM,sito standard,null,,null,,2020-10-1,null,,null,,null,,null,,null,test';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{data})        ;
        test.startTest();
        Map<String, Object> response =HDT_LC_MassiveLoader.updateMassiveLoaderRequest(req.id,processName);
        System.assertEquals(false, response.get('error'), false);

        test.StopTest();
        
        
    }
    @isTest
    public static void testko1(){
        String processName='Lead';
        
        
        HDT_LC_MassiveLoader.createMassiveLoaderRequest(processName);
        String data='HERA COMM,HCM,null,347852147,,Mario,Rossi,Laurea,Studente,Benedetto Brin,1,80100,80100,Napoli,NA,null,,null,,25,null,Maschio,null,SI,1,2020-10-1,Webform callback,AAA,sito standard,NO,1,2020-10-1,Webform callback,HCM,sito standard,null,,null,,2020-10-1,null,,null,,null,,null,,null,test';
        MassiveLoaderRequest__c req= HDT_UTL_DataFactoryTst.createMassiveLoaderRequest(processName,new List<String>{data})        ;
        
        Blob generateFileBlob   = Blob.valueof(data);
        ContentVersion cv       = new ContentVersion();
        cv.ContentLocation      = 'S';
        cv.VersionData          = generateFileBlob;
        cv.Title                = 'Lead.csv';
        cv.PathOnClient         = 'Lead.csv';
        //cv.FileType             = 'Lead'    ;
        insert cv;
        
        HDT_LC_MassiveLoader.checkCsv('Lead.csv',cv.id,processName,req.id);
        Map<String, Object> response =HDT_LC_MassiveLoader.updateMassiveLoaderRequest('test','test');
        System.assertEquals(true, response.get('error'), true);

        
        
    }
    @isTest
    public static void testKO(){
        HDT_LC_MassiveLoader.initialize();
        HDT_LC_MassiveLoader.getCsvBody('test');
        HDT_LC_MassiveLoader.createMassiveLoaderRequest('test');
        Map<String, Object> response = HDT_LC_MassiveLoader.checkCsv('Subentro','test','selectedProcessName','massiveLoaderRequestId');
        System.assertEquals(true, response.get('error'), true);
    }
    
}
