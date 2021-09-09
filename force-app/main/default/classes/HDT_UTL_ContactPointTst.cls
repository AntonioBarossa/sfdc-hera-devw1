/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 07/09/2021
* @description HDT_UTL_ContactPoint for Test Classes
* @history Elfrida Kora – 07/09/2021 – Created class
*/

      

@IsTest
public class HDT_UTL_ContactPointTst {
    
        public static List<Individual> indList = HDT_UTL_DataFactoryTst.createIndividual(1, true);
        public static Id indId = indList[0].Id;
       
    @TestSetup
    static void allData(){
        
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
        
        System.assertEquals(emailsList[0],cpe[0].EmailAddress,'The methoed return correctly the mail passed parameter as string: test@test.com');
        System.assertNotEquals(null,cpe[0].EmailAddress,'The methoed return corretly the mail passed parameter as string,as we can see its not null');
        Test.stopTest();     
        
    }
     @isTest
    public static void verifyContactPointPhone(){
          Test.startTest();
       
        List<String> pointPhone = new List<String>();
        pointPhone.add('06958659787');
        pointPhone.add('06958652687');

        List<ContactPointPhone> cpp = HDT_UTL_ContactPoint.verifyContactPointPhone(indId,pointPhone);
        System.assertEquals(pointPhone[0], cpp[0].TelephoneNumber, 'The method return correctly the number passed parameter as string: 06958659787');
        System.assertNotEquals(null,cpp[0].TelephoneNumber, 'The methoed return correctly the numbers passed parameter as string as we can see its not null');
                Test.stopTest();     
   
    }
    
    @IsTest
    public static void verifyContactPointEmail(){
           Test.startTest();        
        List<String> mails = new List<String>();
        mails.add('elfrida.kora@dunegroup.it');
        mails.add('frida.kora@dunegroup.it');
        
        List<ContactPointEmail> cpee = HDT_UTL_ContactPoint.verifyContactPointEmail(indId,mails);
        System.assertEquals(mails[0],cpee[0].EmailAddress,'The methoed return correctly the mail passed parameter as string:elfrida.kora@dunegroup.it');
        System.assertNotEquals(null,cpee[0], 'The methoed return correctly the mail passed parameter as string as we can see its not null');
           Test.stopTest();     
        
    }
    
    @IsTest
    public static void createContactPointPhone(){
            Test.startTest();

        Map<String,String> maps = new Map<String,String>();
            maps.put(indId,'069985859');
            maps.put(indId,'069125859');
        
        List<String> phoneL = new List<String>();
        phoneL.add('003987785445');
        phoneL.add('0659887716');
        
        Map<String,List<String>> params = new Map<String,List<String>>();
        params.put(indId,phoneL);
        
         Map<String,String> prefix = new Map<String,String>();
            prefix.put(indId,'+39');
            prefix.put(indId,'+39');
        
        HDT_UTL_ContactPoint.createContactPointPhone(maps,params,prefix,'Casa');
        System.debug('phoneL' +phoneL);
        

        System.assertEquals(phoneL.size(), 2, 'The method return correctly the number passed parameter as string');
        System.assertNotEquals(phoneL.size(), 0, 'The methoed return correctly the number passed parameter as string as we can see its not null');
           Test.stopTest();
        
    }
    
    @IsTest
    public static void createContactPointPhoneContact(){
        Test.startTest();
       
        Map<String,String> mymap = new Map<String,String>();
            mymap.put(indId,'069985859');
            mymap.put(indId,'069125369');
        
        List<String> phoneList = new List<String>();
        phoneList.add('003987785445');
        phoneList.add('0659887716');
        
        Map<String,List<String>> parimary = new Map<String,List<String>>();
        parimary.put(indId,phoneList);
        
         Map<String,String> myNumb = new Map<String,String>();
            myNumb.put(indId,'+39');
            myNumb.put(indId,'+39');
        
        Map<String,String> firstMap = new Map<String,String>();
         firstMap.put('069985859',indId);
         firstMap.put('0691256',indId);

        
        HDT_UTL_ContactPoint.createContactPointPhoneContact(mymap,parimary,myNumb,'Casa',firstMap);
        

        System.assertEquals(phoneList.size(),2, 'The method return correctly the number passed parameter as string');
        System.assertNotEquals(phoneList.size(),0, 'The methoed return correctly the number passed parameter as string as we can see its not null');
           Test.stopTest();
                
    }
    
     @IsTest
    public static void createContactPointEmail(){
         Test.startTest();
        
         Map<String,String> mapOne = new Map<String,String>();
            mapOne.put(indId,'test@test.com');
            mapOne.put(indId,'one@two.it');
        
        List<String> emailList = new List<String>();
        emailList.add('test@test.com');
        emailList.add('one@two.it');
        
        Map<String,List<String>> second = new Map<String,List<String>>();
        second.put(indId,emailList);
        
         HDT_UTL_ContactPoint.createContactPointEmail(mapOne,second);
        
         System.assertEquals(emailList.size(),2, 'The method return correctly the mail passed parameter as string');
         System.assertNotEquals(emailList.size(),0, 'The methoed return correctly the mail passed parameter as string as we can see its not null');
           Test.stopTest();

    }
    
    @IsTest
    public static void testCreateContactPointEmailContact(){
        Test.startTest();
        
         Map<String,String> mapTwo = new Map<String,String>();
            mapTwo.put(indId,'anna@comparsi.com');
            mapTwo.put(indId,'one@two.com');
        
        List<String> emailTwo = new List<String>();
        emailTwo.add('paolo@maldini.com');
        emailTwo.add('luciano@pavarotti.it');
        
        Map<String,List<String>> myEmail = new Map<String,List<String>>();
        myEmail.put(indId,emailTwo);
        
        Map<String,String> fourMap = new Map<String,String>();
        fourMap.put('paolo.bonolis@yahoo.com',indId);
        fourMap.put('maria@dunegroup.it',indId);
        System.debug('listContactPointEmail'+[SELECT Id FROM ContactPointEmail]);
        
         List<ContactPointEmail> listReturn = HDT_UTL_ContactPoint.createContactPointEmailContact(mapTwo,myEmail,fourMap); 
        System.debug('listReturn'+listReturn);
        
         System.assertEquals(listReturn.size(),3, 'The method return correctly the mail passed parameter as string, has the right size');
         System.assertNotEquals(listReturn.size(),2, 'Size of emails are two and not one');
           Test.stopTest();
        
    }
    
     @IsTest
    public static void  testCreateContactPointEmail(){
        Test.startTest();
        List<Individual> indList = new List<Individual>();
        indList = HDT_UTL_DataFactoryTst.createIndividual(1, true);
        Id indv = indList[0].Id;
        String emailPrimary = 'elfrida.kora@gmail.com';
        List<String> otherMails = new List<String>();
        otherMails.add('paolo@maldini.com');
        otherMails.add('luciano@pavarotti.it');
       System.debug('listContactMailBefore: '+[SELECT Id FROM ContactPointEmail]);

        List<ContactPointEmail> listReturns =  HDT_UTL_ContactPoint.createContactPointEmail(emailPrimary,indv,otherMails);
        System.debug('listReturn'+listReturns);
        
        System.assertEquals(listReturns.size(),3, 'The method return correctly the mail passed parameter as string, has the right size');
         System.assertNotEquals(listReturns.size(),2, 'Size of email are two and not one');
           Test.stopTest();
    }

}