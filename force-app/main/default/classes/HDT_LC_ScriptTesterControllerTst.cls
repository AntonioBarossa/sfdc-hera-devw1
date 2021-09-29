/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 29/09/2021
 * @description HDT_LC_ScriptTesterControllerTst for Test Classes
 * @history Laureta Demishaj – 29/9/2021 – Created class
*/
@isTest
public class HDT_LC_ScriptTesterControllerTst {

    @isTest
    public static void getScriptsTst(){
         try {
          HDT_LC_ScriptTesterController response = new  HDT_LC_ScriptTesterController();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}