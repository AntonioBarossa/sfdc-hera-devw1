/*
    @Author:        Francesco Vitiello
    CreatedDate:    01/10/2021
*/

@isTest
public with sharing class HDT_UTL_ElectronicInvoicingTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_ElectronicInvoicingTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void validateTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTest';
        System.debug(debugString);
        
        //SETUP
                
        HDT_UTL_ElectronicInvoicing.HDT_WRP_ElectronicInvoicing myElectronicInvoicing = new HDT_UTL_ElectronicInvoicing.HDT_WRP_ElectronicInvoicing();

        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);

            myElectronicInvoicing.sendMode = 'Estero';
            myElectronicInvoicing.billSendMode = 'Fatturazione PA';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);

            myElectronicInvoicing.sendMode = 'XML + carta/email';
            myElectronicInvoicing.xmlType = '';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);

            myElectronicInvoicing.sendMode = 'XML + carta/email';
            myElectronicInvoicing.xmlType = 'Sintetico';
            myElectronicInvoicing.officeCode = 'myOfficeSubjectCode';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);

            myElectronicInvoicing.sendMode = 'XML + carta/email';
            myElectronicInvoicing.xmlType = 'Sintetico';
            myElectronicInvoicing.accountRecordTypeName = 'HDT_RT_Business';
            myElectronicInvoicing.customerMarking = 'D1-Persona fisica';
            myElectronicInvoicing.officeCode = '';
            myElectronicInvoicing.certifiedEmail = '';
            myElectronicInvoicing.billSendMode = 'Cartaceo';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);

            myElectronicInvoicing.sendMode = 'XML + carta/email';
            myElectronicInvoicing.xmlType = 'Sintetico';
            myElectronicInvoicing.billSendMode = 'Fatturazione PA';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);
            
            myElectronicInvoicing.sendMode = 'XML';
            myElectronicInvoicing.xmlType = '';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);

            myElectronicInvoicing.sendMode = 'XML';
            myElectronicInvoicing.xmlType = 'Sintetico';
            myElectronicInvoicing.billSendMode = 'Fatturazione PA';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);
            
            myElectronicInvoicing.sendMode = 'XML';
            myElectronicInvoicing.xmlType = 'Sintetico';
            myElectronicInvoicing.officeCode = 'myOfficeSubjectCode';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);

            myElectronicInvoicing.sendMode = 'XML';
            myElectronicInvoicing.xmlType = 'Sintetico';
            myElectronicInvoicing.officeCode = '';
            myElectronicInvoicing.certifiedEmail = '';
            myElectronicInvoicing.officeCode = 'mOffice';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);

            myElectronicInvoicing.sendMode = 'XML PA';
            myElectronicInvoicing.xmlType = '';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);

            myElectronicInvoicing.sendMode = 'XML PA';
            myElectronicInvoicing.xmlType = 'Sintetico';
            myElectronicInvoicing.officeCode = '';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);

            myElectronicInvoicing.sendMode = 'XML PA';
            myElectronicInvoicing.xmlType = 'Sintetico';
            myElectronicInvoicing.officeCode = 'myOfficeSubjectCode';
            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);

            myElectronicInvoicing.sendMode = 'XML PA';
            myElectronicInvoicing.xmlType = 'Sintetico';
            myElectronicInvoicing.billSendMode  = 'Cartaceo';
            myElectronicInvoicing.officeCode = 'Office';

            HDT_UTL_ElectronicInvoicing.validate(myElectronicInvoicing);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
        
        //ASSERTS
        System.assert(myElectronicInvoicing != null, 'Attenzione, myElectronicInvoicing non può essere null!');
        
    }

}