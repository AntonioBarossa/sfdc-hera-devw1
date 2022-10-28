/*
    @Author:        Francesco Vitiello
    CreatedDate:    09/09/2021
*/

@isTest
public with sharing class HDT_UTL_QuoteManagementTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_QuoteManagementTest';
    
    
    //TEST SETUP
    
    @TestSetup
    static void setup(){
        
        QuoteManagement__c qm = new QuoteManagement__c();
        qm.Commodity__c = 'Energia Elettrica';
        qm.Operation_type__c = 'Verifica GdM';
        qm.Subprocess__c='Verifica elettrica';
        insert qm;

    }

    //TESTS
    

    @isTest
    private static void addRequiredInformationTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'addRequiredInformationTest';
        System.debug(debugString);
        
        //SETUP

        List<HDT_UTL_QuoteManagement.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_QuoteManagement.HDT_UTL_FlowInputs>();
        HDT_UTL_QuoteManagement.HDT_UTL_FlowInputs myInput = new HDT_UTL_QuoteManagement.HDT_UTL_FlowInputs();

        myInput.processType = 'Preventivi';
        myInput.localDispatcher = 'mylocalDispatcher';
        myInput.seller = 'myseller';
        myInput.voltage = 'myVoltage';
        myInput.powerAvailable = 8.5;
        myInput.powerCommitted = 5.5;
        myInput.connectionType = 'Temporanea';
        myInput.powerRequested = 5.5;
        myInput.supplyType = 'mySupplyType';
        myInput.phaseType = 'myPhaseType';
        myInput.energyUseType = 'myEnergyUseType';
        myInput.displacementDistance = 'myDisplacementDistance';
        myInput.operationtype = 'Variazione Potenza';
        myInput.commodity = 'Energia Elettrica';
        myInput.caliber = 'myCaliber';
        myInput.voltageAvailable = 'myVoltageAvailable';
        myInput.phaseAvalaible = 'myPhaseAvalaible';        

        inputs.add(myInput);

        //TESTING
        Test.startTest();
        Try{

            HDT_UTL_QuoteManagement.addRequiredInformation(inputs);
            myInput.powerRequested = 5.6;
            myInput.phaseAvalaible = '';  
            HDT_UTL_QuoteManagement.addRequiredInformation(inputs);
            myInput.powerRequested = 5.4;
            myInput.voltageAvailable = '';
            myInput.connectionType = '';
            HDT_UTL_QuoteManagement.addRequiredInformation(inputs);

            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(inputs != null, 'Attenzione, inputs non può essere null!');
        
    }

    @isTest
    private static void checkLocalDispatcherTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'checkLocalDispatcherTest';
        System.debug(debugString);
        
        //SETUP

        String localDispatcher = 'myDispatcher';


        //TESTING
        Test.startTest();
        Try{

            HDT_UTL_QuoteManagement.checkLocalDispatcher(localDispatcher);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(localDispatcher != null, 'Attenzione, localDispatcher non può essere null!');
        
    }

    @isTest
    private static void getRangeValueTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getRangeValueTest';
        System.debug(debugString);
        
        //SETUP

        Decimal power = 5.5;


        //TESTING
        Test.startTest();
        Try{

            HDT_UTL_QuoteManagement.getRangeValue(power);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(power != null, 'Attenzione, power non può essere null!');
        
    }

    @IsTest
    static void testQueryAddInformation(){
        
        //TESTING
        Test.startTest();

        QuoteManagement__c qm = HDT_QR_QuoteManagement.queryAddInformation('Energia Elettrica', 'Verifica GdM','Verifica elettrica');

        //ASSERTS
        System.assertNotEquals(null, qm, 'QuoteManagement__c = null');

        Test.stopTest();
        
    }


}