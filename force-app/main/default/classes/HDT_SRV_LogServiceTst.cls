@IsTest
public with sharing class HDT_SRV_LogServiceTst {
    
    public static HDT_LogMappingRecord__mdt getTestConfig(String configName){
        return (new Map<String,HDT_LogMappingRecord__mdt>{
                'ConfigTest1' => new HDT_LogMappingRecord__mdt(
                    Object__c = 'wrts_prcgvr__Log__c',
                    Service__c = 'wrts_prcgvr__ApexClassName__c',
                    Method__c = 'wrts_prcgvr__ToolName__c',
                    Request__c = 'wrts_prcgvr__Description__c',
                    Response__c='wrts_prcgvr__Code__c',
                    Error__c = 'wrts_prcgvr__Message__c',
                    RecordId__c = 'wrts_prcgvr__ParentId__c',
                    RequestDate__c = 'wrts_prcgvr__Time__c',
                    ResponseDate__c = '',
                    IsActive__c = true
                ),
                'ConfigTest2' => new HDT_LogMappingRecord__mdt(
                    Object__c = 'Integration_Log__c',
                    Service__c = 'WebService__c',
                    Method__c = 'Method__c',
                    Request__c = 'Request__c',
                    Response__c='',
                    Error__c = 'Error__c',
                    RecordId__c = 'RecordId__c',
                    RequestDate__c = '',
                    ResponseDate__c = '',
                    IsActive__c = true
                ),
                'ConfigTest3' => new HDT_LogMappingRecord__mdt(
                    Object__c = 'NotValidObject',
                    Service__c = 'WebService__c',
                    Method__c = 'Method__c',
                    Request__c = 'Request__c',
                    Response__c='',
                    Error__c = 'Error__c',
                    RecordId__c = 'RecordId__c',
                    RequestDate__c = '',
                    ResponseDate__c = '',
                    IsActive__c = true
                ),
                'ConfigTest4' => new HDT_LogMappingRecord__mdt(
                    Object__c = 'Integration_Log__c',
                    Service__c = 'InvalidField1',
                    Method__c = 'InvalidField1',
                    Request__c = 'InvalidField1',
                    Response__c='InvalidField1',
                    Error__c = 'InvalidField1',
                    RecordId__c = 'InvalidField1',
                    RequestDate__c = 'InvalidField1',
                    ResponseDate__c = 'InvalidField1',
                    IsActive__c = true
                )
            }
        ).get(configName);
    }

    @IsTest
    public static void testSingleRecord(){
        HDT_SRV_LogService serviceConfigOne = new HDT_SRV_LogService('ConfigTest1');
        HDT_SRV_LogService serviceConfigTwo = new HDT_SRV_LogService('ConfigTest2');
        Datetime nowDate = System.now();
        String methodFieldServiceTwo = 'sdfsdfsddfdsfsdfsfoihkdjv,d.,mvdnflgfdhnbdfbdfljfgjdsfgjdioghsdufghurieirjteriotjerjgopdfpgjdpstrybinthtrghuispogjfdisjlgrjgsrjngsbshgstrpiughnbhtuhgsntbhugbnurgephnrgerèotunèrweutrenbwreinoèbtioèuèntèbioègbutèiugrntèbigutrngiubntrobtugntrbitugtrnbtigurnbt';
        Test.startTest();
            serviceConfigOne.insertSingleLog('Service 1', 'Post', 'Example Request', 'Example Response', 'Error', UserInfo.getUserId(), nowDate, nowDate);
            serviceConfigTwo.insertSingleLog('Service 2', methodFieldServiceTwo, 'Example Request', 'Example Response', 'Error', UserInfo.getUserId(), nowDate, nowDate);
        Test.stopTest();
        wrts_prcgvr__Log__c log = [SELECT Id,wrts_prcgvr__ToolName__c,wrts_prcgvr__Description__c,wrts_prcgvr__Code__c,wrts_prcgvr__Message__c,wrts_prcgvr__ParentId__c,wrts_prcgvr__Time__c FROM wrts_prcgvr__Log__c WHERE wrts_prcgvr__ApexClassName__c = 'Service 1'];
        System.assertEquals('Post', log.wrts_prcgvr__ToolName__c, 'Method Service 1');
        System.assertEquals('Example Request', log.wrts_prcgvr__Description__c, 'Request Service 1');
        System.assertEquals('Example Response', log.wrts_prcgvr__Code__c, 'Response Service 1');
        System.assertEquals('Error', log.wrts_prcgvr__Message__c, 'Error Service 1');
        System.assertEquals(UserInfo.getUserId(), log.wrts_prcgvr__ParentId__c, 'RecordId Service 1');
        System.assertEquals(nowDate, log.wrts_prcgvr__Time__c, 'Request Date Service 1');
        Integration_Log__c serviceLog = [SELECT Id,Method__c,Request__c,Error__c,RecordId__c FROM Integration_Log__c WHERE WebService__c = 'Service 2'];
        System.assertEquals(methodFieldServiceTwo.substring(0,255), serviceLog.Method__c, 'Method Service 2');
        System.assertEquals('Example Request', serviceLog.Request__c, 'Request Service 2');
        System.assertEquals('Error', serviceLog.Error__c, 'Error Service 2');
        System.assertEquals(UserInfo.getUserId(), serviceLog.RecordId__c, 'RecordId Service 2');
    }

    @IsTest
    public static void testMassiveRecords(){
        HDT_SRV_LogService serviceConfigOne = new HDT_SRV_LogService('ConfigTest1');
        HDT_SRV_LogService serviceConfigTwo = new HDT_SRV_LogService('ConfigTest2');
        Datetime nowDate = System.now();
        Test.startTest();
            for (Integer i = 0; i<10; i++){
                serviceConfigOne.addLog('Service 1', 'Post' + i, 'Example Request' + i, 'Example Response' + i, 'Error' + i, UserInfo.getUserId(), nowDate, nowDate);
                serviceConfigTwo.addLog('Service 2', 'Post' + i, 'Example Request' + i, 'Example Response' + i, 'Error'+ i, UserInfo.getUserId(), nowDate, nowDate);
            }
            serviceConfigOne.saveMassiveRecords();
            serviceConfigTwo.saveMassiveRecords();
        Test.stopTest();
        System.assertEquals(10,[SELECT Id FROM wrts_prcgvr__Log__c ].size(),'Service 1 not insert');
        System.assertEquals(10,[SELECT Id FROM Integration_Log__c ].size(),'Service 2 not insert');
    }

    @IsTest
    public static void testWrongObject(){
        HDT_SRV_LogService wrongObjectService = new HDT_SRV_LogService('ConfigTest3');
        Datetime nowDate = System.now();
        wrongObjectService.insertSingleLog('Service 1', 'Post', 'Example Request', 'Example Response', 'Error', UserInfo.getUserId(), nowDate, nowDate);
        for (Integer i = 0; i<10; i++){
            wrongObjectService.addLog('Service 1', 'Post' + i, 'Example Request' + i, 'Example Response' + i, 'Error' + i, UserInfo.getUserId(), nowDate, nowDate);
        }
        wrongObjectService.saveMassiveRecords();
        System.assertEquals(0,[SELECT Id FROM wrts_prcgvr__Log__c ].size(),'Error object manage doesn\'t work');
        System.assertEquals(0,[SELECT Id FROM Integration_Log__c ].size(),'Error object manage doesn\'t work');
    }

    @isTest 
    public static void testWrongFields(){
        HDT_SRV_LogService wrongFieldService = new HDT_SRV_LogService('ConfigTest4');
        Datetime nowDate = System.now();
        
        wrongFieldService.insertSingleLog('Service 1', 'Post', 'Example Request', 'Example Response', 'Error', UserInfo.getUserId(), nowDate, nowDate);
        for (Integer i = 0; i<10; i++){
            wrongFieldService.addLog('Service 1', 'Post' + i, 'Example Request' + i, 'Example Response' + i, 'Error' + i, UserInfo.getUserId(), nowDate, nowDate);
        }
        wrongFieldService.saveMassiveRecords();
        System.assertEquals(0,[SELECT Id FROM wrts_prcgvr__Log__c ].size(),'Error field manage doesn\'t work');
        System.assertEquals(0,[SELECT Id FROM Integration_Log__c ].size(),'Error field manage doesn\'t work');

    }

    @isTest 
    public static void testWrongConfigName(){
        HDT_SRV_LogService wrongFieldService = new HDT_SRV_LogService('ConfigTestX');
        Datetime nowDate = System.now();
        
        wrongFieldService.insertSingleLog('Service 1', 'Post', 'Example Request', 'Example Response', 'Error', UserInfo.getUserId(), nowDate, nowDate);
        for (Integer i = 0; i<10; i++){
            wrongFieldService.addLog('Service 1', 'Post' + i, 'Example Request' + i, 'Example Response' + i, 'Error' + i, UserInfo.getUserId(), nowDate, nowDate);
        }
        wrongFieldService.saveMassiveRecords();
        System.assertEquals(0,[SELECT Id FROM wrts_prcgvr__Log__c ].size(),'Error field manage doesn\'t work');
        System.assertEquals(0,[SELECT Id FROM Integration_Log__c ].size(),'Error field manage doesn\'t work');

    }


}
