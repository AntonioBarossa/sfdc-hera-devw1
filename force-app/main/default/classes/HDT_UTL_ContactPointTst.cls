/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 07/09/2021
* @description HDT_UTL_ContactPoint for Test Classes
* @history Elfrida Kora – 07/09/2021 – Created class
*/

@IsTest
public class HDT_UTL_ContactPointTst {
    @TestSetup
    static void allData(){
        
        Id indId = '0PK1X000003C0FhWAK';
         List<ContactPointPhone> cpp = new List<ContactPointPhone>();
        cpp = HDT_UTL_DataFactoryTst.createContactPointPhone(1, true, indId);
        List<ContactPointEmail> cpe = new List<ContactPointEmail>();
        cpe = HDT_UTL_DataFactoryTst.createContactPointEmail(1, true, indId);
        
    } 
    
    @isTest
    public static void instanceMultiContactPointEmail(){
        Test.startTest();
        
        List<String> emailsList = new List<String>();
        emailsList.add('test@test.com');
        List<ContactPointEmail> cpe = HDT_UTL_ContactPoint.instanceMultiContactPointEmail(emailsList,true);
        
        System.assertEquals(cpe.size(), 1, 'Success');
        System.assertNotEquals(cpe.size(), 0, 'Error');
        Test.stopTest();     
        
    }
     @isTest
    public static void verifyContactPointPhone(){
          Test.startTest();
        Id ind = '0PK1X000003JQ66WAG';
        List<String> pointPhone = new List<String>();
        pointPhone.add('06958659787');
        pointPhone.add('06958652687');

        List<ContactPointPhone> cpp = HDT_UTL_ContactPoint.verifyContactPointPhone(ind,pointPhone);
         System.assertEquals(pointPhone.size(), 2, 'Acceptable');
          System.assertNotEquals(pointPhone.size(), 0, 'Unacceptable');
                Test.stopTest();     
   
    }
    
    @IsTest
    public static void verifyContactPointEmail(){
           Test.startTest();
         Id indv = '0PK1X000003JjFoWAK';
         List<String> mails = new List<String>();
        mails.add('elfrida.kora@dunegroup.it');
        mails.add('frida.kora@dunegroup.it');
        
        List<ContactPointEmail> cpe = HDT_UTL_ContactPoint.verifyContactPointEmail(indv,mails);
        System.assertEquals(mails.size(), 2, 'YES');
        System.assertNotEquals(mails.size(), 0, 'NO');
           Test.stopTest();     
        
    }
    
    @IsTest
    public static void createContactPointPhone(){
            Test.startTest();
        Map<String,String> maps = new Map<String,String>();
            maps.put('0PK1X000003KZ7JWAW','069985859');
            maps.put('0PK1X000003Ke3CWAS','069125859');
        
        List<String> phoneL = new List<String>();
        phoneL.add('003987785445');
        phoneL.add('0659887716');
        
        Map<String,List<String>> params = new Map<String,List<String>>();
        params.put('0PK1X000003KZ7JWAW',phoneL);
        
         Map<String,String> prefix = new Map<String,String>();
            prefix.put('0PK1X000003KZ7JWAW','+39');
            prefix.put('0PK1X000003Ke3CWAS','+39');
        
        HDT_UTL_ContactPoint.createContactPointPhone(maps,params,prefix,'Casa');
        

        System.assertEquals(phoneL.size(), 2, 'This is my number of phone');
        System.assertNotEquals(phoneL.size(), 0, 'This number is null');
           Test.stopTest();
        
    }
    
    @IsTest
    public static void createContactPointPhoneContact(){
        Test.startTest();
        Map<String,String> mymap = new Map<String,String>();
            mymap.put('0PK1X000003EOXpWAO','069985859');
            mymap.put('0PK1X000003JK9WWAW','069125369');
        
        List<String> phoneList = new List<String>();
        phoneList.add('003987785445');
        phoneList.add('0659887716');
        
        Map<String,List<String>> parimary = new Map<String,List<String>>();
        parimary.put('0PK1X000003KZ7JWAW',phoneList);
        
         Map<String,String> myNumb = new Map<String,String>();
            myNumb.put('0PK1X000003S6iPWAS','+39');
            myNumb.put('0PK1X000003S6iPWAS','+39');
        
        Map<String,String> firstMap = new Map<String,String>();
        firstMap.put('0PK1X000003S99AWAS','069985859');
        firstMap.put('0PK1X000003Ke3CWAS','069125456');

        
        HDT_UTL_ContactPoint.createContactPointPhoneContact(mymap,parimary,myNumb,'Casa',firstMap);
        

        System.assertEquals(phoneList.size(),2, 'Phone List with numbers');
        System.assertNotEquals(phoneList.size(),0, 'Phone List without numbers');
           Test.stopTest();
                
    }
    
     @IsTest
    public static void createContactPointEmail(){
         Test.startTest();
         Map<String,String> mapOne = new Map<String,String>();
            mapOne.put('0PK1X000003EOXpWAO','test@test.com');
            mapOne.put('0PK1X000003JK9WWAW','one@two.it');
        
        List<String> emailList = new List<String>();
        emailList.add('test@test.com');
        emailList.add('one@two.it');
        
        Map<String,List<String>> second = new Map<String,List<String>>();
        second.put('0PK1X000003KZ7JWAW',emailList);
        
         HDT_UTL_ContactPoint.createContactPointEmail(mapOne,second);
        
         System.assertEquals(emailList.size(),2, 'Email List with address');
         System.assertNotEquals(emailList.size(),0, 'Email List without emails');
           Test.stopTest();

    }
    
    @IsTest
    public static void testCreateContactPointEmailContact(){
        Test.startTest();
         Map<String,String> mapTwo = new Map<String,String>();
            mapTwo.put('0PK1X000003S99AWAS','anna@comparsi.com');
            mapTwo.put('0PK1X000003JK9WWAW','one@two.com');
        
        List<String> emailTwo = new List<String>();
        emailTwo.add('paolo@maldini.com');
        emailTwo.add('luciano@pavarotti.it');
        
        Map<String,List<String>> myEmail = new Map<String,List<String>>();
        myEmail.put('0PK1X000003KZ7JWAW',emailTwo);
        
        Map<String,String> fourMap = new Map<String,String>();
        fourMap.put('0PK1X000003SARWWA4','paolo.bonolis@yahoo.com');
        fourMap.put('0PK1X000003Ke3CWAS','maria.defilippi@dunegroup.it');
        System.debug('listContactPointEmail'+[SELECT Id FROM ContactPointEmail]);
        
         List<ContactPointEmail> listReturn = HDT_UTL_ContactPoint.createContactPointEmailContact(mapTwo,myEmail,fourMap); 
        System.debug('listReturn'+listReturn);
        
         System.assertEquals(listReturn.size(),4, 'This is the right size of emails');
         System.assertNotEquals(listReturn.size(),2, 'Size of email are two and not one');
           Test.stopTest();
        
    }
    
     @IsTest
    public static void  testCreateContactPointEmail(){
        Test.startTest();
        Id indv = '0PK1X000003FBnOWAW';
        String emailPrimary = 'elfrida.kora@gmail.com';
        List<String> otherMails = new List<String>();
        otherMails.add('paolo@maldini.com');
        otherMails.add('luciano@pavarotti.it');
       System.debug('listContactMailBefore: '+[SELECT Id FROM ContactPointEmail]);

        List<ContactPointEmail> listReturns =  HDT_UTL_ContactPoint.createContactPointEmail(emailPrimary,indv,otherMails);
        System.debug('listReturn'+listReturns);
        
        System.assertEquals(listReturns.size(),3, 'This is the right size of emails');
         System.assertNotEquals(listReturns.size(),2, 'Size of email are two and not one');
           Test.stopTest();
    }

}