@IsTest
public with sharing class HDT_UTL_DoubleCalloutPreventionTst {
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        //PCLICK ORDERS
        HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Bozza',constants.ORDER_RECORDTYPEID_SWITCHIN,constants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
        HDT_UTL_DataFactoryTst.newPhaseTransition('Amm. Precheck OK SII','Bozza',constants.ORDER_RECORDTYPEID_SWITCHIN,constants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
        HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Amm. Precheck OK SII',constants.ORDER_RECORDTYPEID_SWITCHIN,constants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
        HDT_UTL_DataFactoryTst.newPhaseTransition('Completata','Bozza',constants.ORDER_RECORDTYPEID_SWITCHIN,constants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);

        //PCLICK CASES
        HDT_UTL_DataFactoryTst.newPhaseTransition('Attesa check preliminari','Bozza',constants.CASE_RECORDTYPEID_AUTOLETTURA,constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA);
        HDT_UTL_DataFactoryTst.newPhaseTransition('Check preliminari OK','Bozza',constants.CASE_RECORDTYPEID_AUTOLETTURA,constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA);
        HDT_UTL_DataFactoryTst.newPhaseTransition('Check preliminari OK','Attesa check preliminari',constants.CASE_RECORDTYPEID_AUTOLETTURA,constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA);
        HDT_UTL_DataFactoryTst.newPhaseTransition('Completata','Bozza',constants.CASE_RECORDTYPEID_AUTOLETTURA,constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA);


        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(2,false,'MMS','MMS Azienda','Aziende SME');
        insert accs;
        List<Contact> conts = HDT_UTL_DataFactoryTst.createContact(1, false, accs[0].Id);
        conts[0].Company__c='MMS';
        insert conts;

        //Orders
        List<Order> orders =  new List<Order>();
        for (Order ord : HDT_UTL_DataFactoryTst.createOrder(3, false, accs[0].id, 'Bozza')){
            ord.Contact__c = conts[0].id;
            ord.RecordTypeId = constants.ORDER_RECORDTYPEID_SWITCHIN;
            ord.ProcessType__c = 'Switch in Gas';
            orders.add(ord);
        }
        insert orders;

        //Case
        HDT_UTL_DataFactoryTst.createCaseAutolettura(3, true, accs[0].Id, conts[0].Id, null, null, null);
    }

    @isTest
    private static void noCalloutRecord(){
        List<SObject> newRecord = [SELECT Id, Phase__c, PhaseStory__c, Type, OpinionRequestNumber__c FROM Case];
        Map<Id,SObject> oldRecordMap = new Map<Id,SObject>([SELECT Id, Phase__c, PhaseStory__c, Type, OpinionRequestNumber__c FROM Case]);
        for (SObject record : newRecord){
            record.put('Phase__c','Check preliminari OK');
        }
        HDT_UTL_DoubleCalloutPrevention prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Case');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'noCalloutRecord: case prevention doesn\'t Work');
        newRecord = [SELECT Id, Phase__c, PhaseStory__c, ProcessType__c, Skip_Callout__c FROM Order];
        oldRecordMap = new Map<Id,SObject>([SELECT Id, Phase__c, PhaseStory__c, ProcessType__c, Skip_Callout__c FROM Order]);
        for (SObject record : newRecord){
            record.put('Phase__c','Da Inviare');
        }
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Order');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'noCalloutRecord: order prevention doesn\'t Work');
    }

    @isTest
    private static void skipCalloutCase(){
        List<SObject> newRecord = [SELECT Id, Phase__c, PhaseStory__c, Type, OpinionRequestNumber__c FROM Case];
        Map<Id,SObject> oldRecordMap = new Map<Id,SObject>([SELECT Id, Phase__c, PhaseStory__c, Type, OpinionRequestNumber__c FROM Case]);
        for (SObject record : newRecord){
            record.put('Phase__c','Check preliminari OK');
            record.put('OpinionRequestNumber__c',-1);
        }
        HDT_UTL_DoubleCalloutPrevention prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Case');
        System.assertEquals(true, prevention.skipIntegrationCall(), 'skipCalloutCase: case prevention doesn\'t Work');
        newRecord = [SELECT Id, Phase__c, PhaseStory__c, ProcessType__c, Skip_Callout__c FROM Order];
        oldRecordMap = new Map<Id,SObject>([SELECT Id, Phase__c, PhaseStory__c, ProcessType__c, Skip_Callout__c FROM Order]);
        for (SObject record : newRecord){
            record.put('Phase__c','Da Inviare');
            record.put('Skip_Callout__c',-1);
        }
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Order');
        System.assertEquals(true, prevention.skipIntegrationCall(), 'skipCalloutCase: order prevention doesn\'t Work');
    }

    @isTest
    private static void errorObjectType(){
        List<SObject> newRecord = [SELECT Id, Phase__c, PhaseStory__c, Type, OpinionRequestNumber__c FROM Case];
        Map<Id,SObject> oldRecordMap = new Map<Id,SObject>([SELECT Id, Phase__c, PhaseStory__c, Type, OpinionRequestNumber__c FROM Case]);
        for (SObject record : newRecord){
            record.put('Phase__c','Check preliminari OK');
        }
        HDT_UTL_DoubleCalloutPrevention prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Order');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'errorObjectType: case prevention doesn\'t Work');
        newRecord = [SELECT Id, Phase__c, PhaseStory__c, ProcessType__c, Skip_Callout__c FROM Order];
        oldRecordMap = new Map<Id,SObject>([SELECT Id, Phase__c, PhaseStory__c, ProcessType__c, Skip_Callout__c FROM Order]);
        for (SObject record : newRecord){
            record.put('Phase__c','Da Inviare');
        }
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Case');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'errorObjectType: order prevention doesn\'t Work');
    }

    @isTest
    private static void noConfiguration(){
        List<SObject> newRecord = [SELECT Id, Phase__c, PhaseStory__c, Type, OpinionRequestNumber__c FROM Case];
        Map<Id,SObject> oldRecordMap = new Map<Id,SObject>([SELECT Id, Phase__c, PhaseStory__c, Type, OpinionRequestNumber__c FROM Case]);
        List<Map<String,Object>> args = new List<Map<String,Object>>();
        for (SObject record : newRecord){
            record.put('Phase__c','Completata');
            args.add(
                new Map<String,Object>{
                    'argument' => 'argument',
                    'method' => 'testMethod2',
                    'objectType' => 'Case',
                    'apexClass' => 'testClass2',
                    'recordId' => record.get('Id')
                }
            );
        }
        insertAsyncCallout(args);
        HDT_UTL_DoubleCalloutPrevention prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Case');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'noConfiguration: case prevention doesn\'t Work');
        
        newRecord = [SELECT Id, Phase__c, PhaseStory__c, ProcessType__c, Skip_Callout__c FROM Order];
        oldRecordMap = new Map<Id,SObject>([SELECT Id, Phase__c, PhaseStory__c, ProcessType__c, Skip_Callout__c FROM Order]);
        args = new List<Map<String,Object>>();
        for (SObject record : newRecord){
            record.put('Phase__c','Completata');
            args.add(
                new Map<String,Object>{
                    'argument' => 'argument',
                    'method' => 'testMethod',
                    'objectType' => 'Order',
                    'apexClass' => 'testClass',
                    'recordId' => record.get('Id')
                }
            );
        }
        insertAsyncCallout(args);
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Order');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'noConfiguration: order prevention doesn\'t Work');

    }

    @IsTest
    private static void caseTest(){
        List<SObject> newRecord = [SELECT Id, Phase__c, PhaseStory__c, Type, OpinionRequestNumber__c FROM Case LIMIT 1];
        Map<Id,SObject> oldRecordMap = new Map<Id,SObject>([SELECT Id, Phase__c, PhaseStory__c, Type, OpinionRequestNumber__c FROM Case WHERE Id = :(Id)newRecord[0].get('Id')]);
        // primo caso esiste la configurazione ma il metodo indicato non corrisponde a quelo del record;
        newRecord[0].put('Phase__c','Check preliminari OK');
        insertSingleAsyncCallout(new Map<String,Object>{
            'argument' => '',
            'method' => 'method',
            'objectType' => 'Case',
            'apexClass' => 'Apex',
            'recordId' => newRecord[0].get('Id')
        });
        HDT_UTL_DoubleCalloutPrevention prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Case');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'caseTest first Case: case prevention doesn\'t Work');

        //secondo caso esiste la confgurazione ed esiste il record di callout
        insertSingleAsyncCallout(new Map<String,Object>{
            'argument' => '',
            'method' => 'testMethod',
            'objectType' => 'Case',
            'apexClass' => 'testClass',
            'recordId' => newRecord[0].get('Id')
        });
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Case');
        System.assertEquals(true, prevention.skipIntegrationCall(), 'caseTest Second Case: case prevention doesn\'t Work');

        //terzo Caso manca il fase history
        insertSingleAsyncCallout(new Map<String,Object>{
            'argument' => '',
            'method' => 'testMethod2',
            'objectType' => 'Case',
            'apexClass' => 'testClass2',
            'argument' => 'testArgument2',
            'recordId' => newRecord[0].get('Id')
        });
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Case');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'caseTest third Case: case prevention doesn\'t Work');
        
        //quarto Caso c'è il fase history
        newRecord[0].put('PhaseStory__c','@@@@Bozza@@@@@Attesa check preliminari');
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Case');
        System.assertEquals(true, prevention.skipIntegrationCall(), 'caseTest fourth Case: case prevention doesn\'t Work');

        //quinto caso manca l'argument nel async
        newRecord[0].put('Phase__c','Check preliminari KO');
        insertSingleAsyncCallout(new Map<String,Object>{
            'argument' => '',
            'method' => 'testMethod3',
            'objectType' => 'Case',
            'apexClass' => 'testClass3',
            'recordId' => newRecord[0].get('Id')
        });
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Case');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'caseTest fifth Case: case prevention doesn\'t Work');
        
        //sesto caso argument popolato
        insertSingleAsyncCallout(new Map<String,Object>{
            'argument' => '',
            'method' => 'testMethod3',
            'objectType' => 'Case',
            'apexClass' => 'testClass3',
            'argument' => 'testArgument',
            'recordId' => newRecord[0].get('Id')
        });
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Case');
        System.assertEquals(true, prevention.skipIntegrationCall(), 'caseTest sixth Case: case prevention doesn\'t Work');
    }

    @IsTest
    private static void orderTest(){
        List<SObject> newRecord = [SELECT Id, Phase__c, PhaseStory__c, ProcessType__c, Skip_Callout__c FROM Order LIMIT 1];
        Map<Id,SObject> oldRecordMap = new Map<Id,SObject>([SELECT Id, Phase__c, PhaseStory__c, ProcessType__c, Skip_Callout__c FROM Order WHERE Id = :(Id)newRecord[0].get('Id')]);
        // primo caso esiste la configurazione ma il metodo indicato non corrisponde a quelo del record;
        newRecord[0].put('Phase__c','Da Inviare');
        insertSingleAsyncCallout(new Map<String,Object>{
            'argument' => '',
            'method' => 'method',
            'objectType' => 'Order',
            'apexClass' => 'Apex',
            'recordId' => newRecord[0].get('Id')
        });
        HDT_UTL_DoubleCalloutPrevention prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Order');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'caseTest first Case: case prevention doesn\'t Work');

        //secondo caso esiste la confgurazione ed esiste il record di callout
        insertSingleAsyncCallout(new Map<String,Object>{
            'argument' => '',
            'method' => 'testMethod',
            'objectType' => 'Order',
            'apexClass' => 'testClass',
            'recordId' => newRecord[0].get('Id')
        });
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Order');
        System.assertEquals(true, prevention.skipIntegrationCall(), 'caseTest Second Case: case prevention doesn\'t Work');

        //terzo Caso manca il fase history
        insertSingleAsyncCallout(new Map<String,Object>{
            'argument' => '',
            'method' => 'testMethod2',
            'objectType' => 'Order',
            'apexClass' => 'testClass2',
            'argument' => 'testArgument2',
            'recordId' => newRecord[0].get('Id')
        });
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Order');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'caseTest third Case: case prevention doesn\'t Work');
        
        //quarto Caso c'è il fase history
        newRecord[0].put('PhaseStory__c','@@@@Bozza@@@@@Amm. Precheck OK SII');
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Order');
        System.assertEquals(true, prevention.skipIntegrationCall(), 'caseTest fourth Case: case prevention doesn\'t Work');

        //quinto caso manca l'argument nel async
        newRecord[0].put('Phase__c','Comunicazione Verso Heroku KO');
        insertSingleAsyncCallout(new Map<String,Object>{
            'argument' => '',
            'method' => 'testMethod3',
            'objectType' => 'Order',
            'apexClass' => 'testClass3',
            'recordId' => newRecord[0].get('Id')
        });
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Order');
        System.assertEquals(false, prevention.skipIntegrationCall(), 'caseTest fifth Case: case prevention doesn\'t Work');
        
        //sesto caso argument popolato
        insertSingleAsyncCallout(new Map<String,Object>{
            'argument' => '',
            'method' => 'testMethod3',
            'objectType' => 'Order',
            'apexClass' => 'testClass3',
            'argument' => 'testArgument',
            'recordId' => newRecord[0].get('Id')
        });
        prevention = new HDT_UTL_DoubleCalloutPrevention(newRecord,oldRecordMap,'Order');
        System.assertEquals(true, prevention.skipIntegrationCall(), 'caseTest sixth Case: case prevention doesn\'t Work');
    }

    @IsTest
    private static void runTest(){
        List<SObject> newObject = new List<SObject>();
        for(Case c :  [SELECT Id, Phase__c, PhaseStory__c, Type, OpinionRequestNumber__c FROM Case]){
            c.Phase__c = 'Check preliminari OK';
            newObject.add(c);
        }
        for(Order o :  [SELECT Id, Phase__c, PhaseStory__c, ProcessType__c, Skip_Callout__c FROM Order]){
            o.Phase__c = 'Da Inviare';
            newObject.add(o);
        }
        Boolean thrownException = false;
        Test.startTest();
            try{
                update newObject;
            }catch(Exception e){
                thrownException = true;
            }    
        test.stopTest();
        System.assertEquals(false, thrownException, 'runTest: problem intrigger');
    }

    private static void insertSingleAsyncCallout(Map<String,Object> arg){
        List<Map<String,Object>> args = new List<Map<String,Object>>();
        args.add(arg);
        insertAsyncCallout(args);
    }

    private static void insertAsyncCallout(List<Map<String,Object>> args){
        List<wrts_prcgvr__AsyncJob__c> asyncJobs = [SELECT Id FROM wrts_prcgvr__AsyncJob__c];
        if (!asyncJobs.isEmpty()){
            delete asyncJobs;
            asyncJobs = new List<wrts_prcgvr__AsyncJob__c>();
        }
        for (Map<String,Object> arg : args){
            wrts_prcgvr__AsyncJob__c asyncJob = new wrts_prcgvr__AsyncJob__c();
            asyncJob.wrts_prcgvr__JobItem__c = (Id)arg.get('recordId');
            asyncJob.wrts_prcgvr__ApexClassName__c = (String)arg.get('apexClass');
            asyncJob.wrts_prcgvr__JobType__c = 'Callout';
            asyncJob.wrts_prcgvr__ObjectType__c = (String)arg.get('objectType');
            asyncJob.wrts_prcgvr__MethodName__c = (String)arg.get('method');
            asyncJob.wrts_prcgvr__Arguments__c = (String)arg.get('argument');
            asyncJobs.add(asyncJob);
        }

        insert asyncJobs;
    }


    public static Map<String,List<HDT_DoubleCalloutPrevention__mdt>> getConfigRecordForTest(){
        Map<String,List<HDT_DoubleCalloutPrevention__mdt>> testConfigs =  new Map<String,List<HDT_DoubleCalloutPrevention__mdt>>{
            'Order' => new List<HDT_DoubleCalloutPrevention__mdt>{
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Da Inviare', 
                    MethodToCheck__c = 'testMethod2',
                    ApexClass__c = 'testClass2', 
                    Arguments__c = 'testArgument2', 
                    CheckOnPhaseStory__c = 'Amm. Precheck OK SII',
                    IsActive__c = true,
                    ProcessType__c = 'Switch in Gas',
                    ObjectName__c = 'Order'
                ),
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Comunicazione Verso Heroku KO', 
                    MethodToCheck__c = 'testMethod3',
                    ApexClass__c = 'testClass3', 
                    Arguments__c = 'testArgument', 
                    CheckOnPhaseStory__c = '',
                    IsActive__c = true,
                    ProcessType__c = 'Switch in Gas',
                    ObjectName__c = 'Order'
                )
                ,
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Da Inviare', 
                    MethodToCheck__c = 'testMethod',
                    ApexClass__c = 'testClass', 
                    Arguments__c = '', 
                    CheckOnPhaseStory__c = '',
                    IsActive__c = true,
                    ProcessType__c = 'Switch in Gas',
                    ObjectName__c = 'Order'
                ),
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Da Inviare', 
                    MethodToCheck__c = 'yyy',
                    ApexClass__c = 'xxx', 
                    Arguments__c = '', 
                    CheckOnPhaseStory__c = 'Amm. Precheck OK SII',
                    IsActive__c = true,
                    ProcessType__c = 'Switch in Gas',
                    ObjectName__c = 'Order'
                ),
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Da Inviare', 
                    MethodToCheck__c = 'yyy',
                    ApexClass__c = 'xxx', 
                    Arguments__c = 'yyy', 
                    CheckOnPhaseStory__c = '',
                    IsActive__c = true,
                    ProcessType__c = 'Switch in Gas',
                    ObjectName__c = 'Order'
                )
                ,
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Da Inviare', 
                    MethodToCheck__c = 'yyy',
                    ApexClass__c = 'xxx', 
                    Arguments__c = '', 
                    CheckOnPhaseStory__c = '',
                    IsActive__c = true,
                    ProcessType__c = 'Switch in Gas',
                    ObjectName__c = 'Order'
                )
            },
            'Case' => new List<HDT_DoubleCalloutPrevention__mdt>{
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Check preliminari OK', 
                    MethodToCheck__c = 'testMethod2',
                    ApexClass__c = 'testClass2', 
                    Arguments__c = 'testArgument2', 
                    CheckOnPhaseStory__c = 'Attesa check preliminari',
                    IsActive__c = true,
                    ProcessType__c = 'Allineamento Anagrafica',
                    ObjectName__c = 'Case'
                ),
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Check preliminari KO', 
                    MethodToCheck__c = 'testMethod3',
                    ApexClass__c = 'testClass3', 
                    Arguments__c = 'testArgument', 
                    CheckOnPhaseStory__c = '',
                    IsActive__c = true,
                    ProcessType__c = 'Allineamento Anagrafica',
                    ObjectName__c = 'Case'
                )
                ,
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Check preliminari OK', 
                    MethodToCheck__c = 'testMethod',
                    ApexClass__c = 'testClass', 
                    Arguments__c = '', 
                    CheckOnPhaseStory__c = '',
                    IsActive__c = true,
                    ProcessType__c = 'Allineamento Anagrafica',
                    ObjectName__c = 'Case'
                ),
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Check preliminari OK', 
                    MethodToCheck__c = 'yyy',
                    ApexClass__c = 'xxx', 
                    Arguments__c = 'yyy', 
                    CheckOnPhaseStory__c = 'Attesa check preliminari',
                    IsActive__c = true,
                    ProcessType__c = 'Allineamento Anagrafica',
                    ObjectName__c = 'Case'
                ),
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Check preliminari OK', 
                    MethodToCheck__c = 'yyy',
                    ApexClass__c = 'xxx', 
                    Arguments__c = 'yyy', 
                    CheckOnPhaseStory__c = '',
                    IsActive__c = true,
                    ProcessType__c = 'Allineamento Anagrafica',
                    ObjectName__c = 'Case'
                )
                ,
                new HDT_DoubleCalloutPrevention__mdt(
                    PhaseToCheck__c = 'Check preliminari OK', 
                    MethodToCheck__c = 'yyy',
                    ApexClass__c = 'xxx', 
                    Arguments__c = '', 
                    CheckOnPhaseStory__c = '',
                    IsActive__c = true,
                    ProcessType__c = 'Allineamento Anagrafica',
                    ObjectName__c = 'Case'
                )
            }
            
        };

        return testConfigs;
    }
}