public with sharing class HDT_UTL_CalculateFiscalCode {

    private static String vowels='AEIUO';
    private static String[] vowelsLetters=new List<String>();
    private static String[] consonantsLetters=new List<String>();
    
    @AuraEnabled
    public static String calculateFiscalCode(Map<String,String> infoData){

        String checkCitta = HDT_QR_City.getCityCode(infoData.get('birthPlace').toUpperCase());
        String fiscalCode='';
        if(''.equals(checkCitta)){
            fiscalCode = null ;
        }else{
            
            fiscalCode += getLastNameCode(infoData.get('lastName').toUpperCase());
            fiscalCode += getFirstNameCode(infoData.get('firstName').toUpperCase());
            fiscalCode += getYear(infoData.get('birthDate'));
            fiscalCode += getMonthLetter(infoData.get('birthDate'));
            fiscalCode += getDayAndGenderCode(infoData.get('birthDate'), infoData.get('gender'));
            fiscalCode += checkCitta;
            System.debug(checkCitta);
            fiscalCode += getControlLetter(fiscalCode);
        }
        return fiscalCode;
    }
    private static Boolean isVowel(String test, String letter){
        return test.contains(letter)?true:false;
    }
    private static String getLastNameCode(String word){
        String lastNameCode='';
        splitLetters(word);
        if(consonantsLetters.size()>=3){
            lastNameCode= consonantsLetters.get(0)+consonantsLetters.get(1)+consonantsLetters.get(2);
        }else{
            if(consonantsLetters.size()==2 && vowelsLetters.size()>0 ){
                lastNameCode= consonantsLetters.get(0)+consonantsLetters.get(1)+vowelsLetters.get(0);
            }
            if(consonantsLetters.size()==1 ){
                if(vowelsLetters.size()>1){
                  lastNameCode=consonantsLetters.get(0)+vowelsLetters.get(0)+vowelsLetters.get(1);
                }else if(vowelsLetters.size()==1){
                    lastNameCode=consonantsLetters.get(0)+vowelsLetters.get(0)+ 'X';
                }
            }
        }
        return lastNameCode;   
    }
    private static String getFirstNameCode(String word){
        String firstNameCode='';
        splitLetters(word);
        if(consonantsLetters.size()>3){
            firstNameCode= consonantsLetters.get(0)+consonantsLetters.get(2)+consonantsLetters.get(3);
        }else if(consonantsLetters.size()==3 ){
            firstNameCode= consonantsLetters.get(0)+consonantsLetters.get(1)+consonantsLetters.get(2);
        }else if(consonantsLetters.size()==2 && vowelsLetters.size()>=1){
            firstNameCode=consonantsLetters.get(0)+consonantsLetters.get(1)+vowelsLetters.get(0);
        }else if(consonantsLetters.size()==1 ){
            if( vowelsLetters.size()>=2){
                firstNameCode=consonantsLetters.get(0)+vowelsLetters.get(0)+vowelsLetters.get(1);
            }else{
                firstNameCode=consonantsLetters.get(0)+vowelsLetters.get(0)+'X';
            }
        }
        return firstNameCode;
    }
    
    private static void splitLetters(String word){
        vowelsLetters=new List<String>();
      consonantsLetters=new List<String>();
        for(Integer i=0;i<word.length();i++){
            if(isVowel(vowels,word.substring(i, i+1))){
                vowelsLetters.add(word.substring(i, i+1));
            }else{
                consonantsLetters.add(word.substring(i, i+1));
            }
        }
    }
    
    private static String getYear(String birthday){
        String yearCode='';
        Date birth = Date.valueOf(birthday);
        Integer year= birth.year();
        yearCode= String.valueOf(year).substring(2);
        return yearCode;
    }
    private static String getMonthLetter(String birthDate){
        Date birth = Date.valueOf(birthDate);
        Integer month= birth.month();

        switch on month{
            when 1 {
                return 'A';
            }when 2 {
                return 'B';
            }when 3 {
                return 'C';
            }when 4 {
                return 'D';
            }when 5 {
                return 'E';
            }when 6 {
                return 'H';
            }when 7 {
                return 'L';
            }when 8 {
                return 'M';
            }when 9 {
                return 'P';
            }when 10 {
                return 'R';
            }when 11 {
                return 'S';
            }when 12 {
                return 'T';
            }when else{
                return '';
            }
        }                                                                        
    }
    private static String getDayAndGenderCode(String birthday, String gender){
        String dayAndGenderCode='';
        Date birth = Date.valueOf(birthday);
        Integer day= birth.day();
        if(gender=='Maschio'){
            if(day>9){
                dayAndGenderCode= String.valueOf(day);
            }else{
                dayAndGenderCode= '0'+ String.valueOf(day);
            }
        }else{
            dayAndGenderCode= String.valueOf(40+day);
        }
        return dayAndGenderCode;
    }   
    
    private static String getControlLetter(String s){
		List<String> evenChars=new List<String>();
		List<String> oddChars= new List<String>();
        String letter='';
		Integer counter=0;
		for(Integer i=0;i<s.length();i++){
			if(math.mod(i,2)==0){
                oddChars.add(s.substring(i,i+1));
            }else{
                evenChars.add(s.substring(i,i+1));
            }
		}
        for (String c : oddChars) {
            switch on c{
                when '0' { 
                    counter+=1;
                }when '1' { 
                    counter+=0;
                }when '2' { 
                    counter+=5;
                }when '3' { 
                    counter+=7;
                }when '4' { 
                    counter+=9;
                }when '5' { 
                    counter+=13;
                }when '6' { 
                    counter+=15;
                }when '7' { 
                    counter+=17;
                }when '8' { 
                    counter+=19;
                }when '9' { 
                    counter+=21;
                }when 'A' { 
                    counter+=1;
                }when 'B' { 
                    counter+=0;
                }when 'C' { 
                    counter+=5;
                }when 'D' { 
                    counter+=7;
                }when 'E' { 
                    counter+=9;
                }when 'F' { 
                    counter+=13;
                }when 'G' { 
                    counter+=15;
                }when 'H' { 
                    counter+=17;
                }when 'I' { 
                    counter+=19;
                }when 'J' { 
                    counter+=21;
                }when 'K' { 
                    counter+=2;
                }when 'L' { 
                    counter+=4;
                }when 'M' { 
                    counter+=18;
                }when 'N' { 
                    counter+=20;
                }when 'O' { 
                    counter+=11;
                }when 'P' { 
                    counter+=3;
                }when 'Q' { 
                    counter+=6;
                }when 'R' { 
                    counter+=8;
                }when 'S' { 
                    counter+=12;
                }when 'T' { 
                    counter+=14;
                }when 'U' { 
                    counter+=16;
                }when 'V' { 
                    counter+=10;
                }when 'W' { 
                    counter+=22;
                }when 'X' { 
                    counter+=25;
                }when 'Y' { 
                    counter+=24;
                }when 'Z' { 
                    counter+=23;
                }
            }
        }
        for (String e : evenChars) {
            switch on e{
                when '0' { 
                    counter+=0;
                }when '1' { 
                    counter+=1;
                }when '2' { 
                    counter+=2;
                }when '3' { 
                    counter+=3;
                }when '4' { 
                    counter+=4;
                }when '5' { 
                    counter+=5;
                }when '6' { 
                    counter+=6;
                }when '7' { 
                    counter+=7;
                }when '8' { 
                    counter+=8;
                }when '9' { 
                    counter+=9;
                }when 'A' { 
                    counter+=0;
                }when 'B' { 
                    counter+=1;
                }when 'C' { 
                    counter+=2;
                }when 'D' { 
                    counter+=3;
                }when 'E' { 
                    counter+=4;
                }when 'F' { 
                    counter+=5;
                }when 'G' { 
                    counter+=6;
                }when 'H' { 
                    counter+=7;
                }when 'I' { 
                    counter+=8;
                }when 'J' { 
                    counter+=9;
                }when 'K' { 
                    counter+=10;
                }when 'L' { 
                    counter+=11;
                }when 'M' { 
                    counter+=12;
                }when 'N' { 
                    counter+=13;
                }when 'O' { 
                    counter+=14;
                }when 'P' { 
                    counter+=15;
                }when 'Q' { 
                    counter+=16;
                }when 'R' { 
                    counter+=17;
                }when 'S' { 
                    counter+=18;
                }when 'T' { 
                    counter+=19;
                }when 'U' { 
                    counter+=20;
                }when 'V' { 
                    counter+=21;
                }when 'W' { 
                    counter+=22;
                }when 'X' { 
                    counter+=23;
                }when 'Y' { 
                    counter+=24;
                }when 'Z' { 
                    counter+=25;
                }
            }
        }
        switch on math.mod(counter,26) {
            when 0 {
                letter='A';
            }when 1 {
                letter='B';
            }when 2 {
                letter='C';
            }when 3 {
                letter='D';
            }when 4 {
                letter='E';
            }when 5 {
                letter='F';
            }when 6 {
                letter='G';
            }when 7 {
                letter='H';
            }when 8 {
                letter='I';
            }when 9 {
                letter='J';
            }when 10 {
                letter='K';
            }when 11 {
                letter='L';
            }when 12 {
                letter='M';
            }when 13 {
                letter='N';
            }when 14 {
                letter='O';
            }when 15 {
                letter='P';
            }when 16 {
                letter='Q';
            }when 17 {
                letter='R';
            }when 18 {
                letter='S';
            }when 19 {
                letter='T';
            }when 20 {
                letter='U';
            }when 21 {
                letter='V';
            }when 22 {
                letter='W';
            }when 23 {
                letter='X';
            }when 24 {
                letter='Y';
            }when 25 {
                letter='Z';
            }
        }
        return letter;
    }
}