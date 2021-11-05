/**
 * Header of the class "HDT_WS_SalesApexCalloutActionMock"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class Mock of the relative Apex Class "HDT_WS_SalesApexCalloutAction"
 * @history
 * @Created 19/10/2021
 * Modified By:
 **/
@isTest
public class HDT_WS_SalesApexCalloutActionMock implements HTTPCalloutMock{

	 public HTTPResponse respond(HTTPRequest request){
         
         HttpResponse response = new HttpResponse();
         return response;
     }
	public wrts_prcgvr.MRR_1_0.MultiResponse respond(Sobject args){
        
        Case arg = (Case)args;
        
        wrts_prcgvr.MRR_1_0.Field field1 = new wrts_prcgvr.MRR_1_0.Field();
        field1.name = 'COD_PRAT_UTENTE';
        field1.value = 'randomcode';
        
        wrts_prcgvr.MRR_1_0.Field field2 = new wrts_prcgvr.MRR_1_0.Field();
        field2.name = 'result';
        field2.value = 'OK';
        if(arg.DiscardDescription__c.equals('11'))
            field2.value = 'KO';
        
        wrts_prcgvr.MRR_1_0.Field field3 = new wrts_prcgvr.MRR_1_0.Field();
        field3.name = 'FASE';
        
        switch on arg.DiscardDescription__c{
            when 'zero'{
                field3.value = 'Ammissibilità KO';
            }
            when 'one'{
                field3.value = 'Ammissibilità OK';
            }
            when '2'{
                field3.value = 'Esito KO da DL';
            }
            when '3'{
                field3.value = 'Esito OK da DL';
            }
            when '4'{
                field3.value = 'Amm. Precheck KO SII';
            }
            when '5'{
                field3.value = 'Amm. Precheck OK SII';
            }
            when '6'{
                field3.value = 'Esito KO da SII';
            }
            when '7'{
                field3.value = 'Esito OK da SII';
            }
            when '8'{
                field3.value = 'Errore lavorazione SAP';
            }
            when '9'{
                field3.value = 'Completata';
            }
            when '10','11','12'{
                field3.value = null;
            }
        }
        
        wrts_prcgvr.MRR_1_0.Field field4 = new wrts_prcgvr.MRR_1_0.Field();
        field4.name = 'CODERR';
        field4.value = '032';
        
        wrts_prcgvr.MRR_1_0.Field field5 = new wrts_prcgvr.MRR_1_0.Field();
        field5.name = 'DES_ERR_AEEG';
        field5.value = 'des';
        
        wrts_prcgvr.MRR_1_0.Field field6 = new wrts_prcgvr.MRR_1_0.Field();
        field6.name = 'CODERR_AEEG';
        field6.value = '034';
        
        wrts_prcgvr.MRR_1_0.Field field7 = new wrts_prcgvr.MRR_1_0.Field();
        field7.name = 'IMP_PREV_DIST';
        field7.value = '1.0';
        
        wrts_prcgvr.MRR_1_0.Field field8 = new wrts_prcgvr.MRR_1_0.Field();
        field8.name = 'VKONT';
        field8.value = 'something';
        
        wrts_prcgvr.MRR_1_0.Field field9 = new wrts_prcgvr.MRR_1_0.Field();
        field9.name = 'errorMessage';
        field9.value = 'error occurred';
        
        wrts_prcgvr.MRR_1_0.Field field10 = new wrts_prcgvr.MRR_1_0.Field();
        field10.name = 'COD_FLUSSO';
        field10.value = 'testflusso';
        
        wrts_prcgvr.MRR_1_0.Field field11 = new wrts_prcgvr.MRR_1_0.Field();
        field11.name = 'CODERR_ES';
        field11.value = '003';
        
        wrts_prcgvr.MRR_1_0.Field field12 = new wrts_prcgvr.MRR_1_0.Field();
        field12.name = 'NOTE_ERR';
        field12.value = 'testnote';

        List<wrts_prcgvr.MRR_1_0.Field> fieldss = new List<wrts_prcgvr.MRR_1_0.Field>();
        fieldss.add(field1);
        fieldss.add(field2);
        fieldss.add(field3);
        fieldss.add(field4);
        fieldss.add(field5);
        fieldss.add(field6);
        fieldss.add(field7);
        fieldss.add(field8);
        fieldss.add(field9);
        fieldss.add(field10);
        fieldss.add(field11);
        fieldss.add(field12);
        
        wrts_prcgvr.MRR_1_0.WObject ob = new wrts_prcgvr.MRR_1_0.WObject();
        ob.fields = fieldss;

        List<wrts_prcgvr.MRR_1_0.WObject> objs = new List<wrts_prcgvr.MRR_1_0.WObject>();
        objs.add(ob);
        
        wrts_prcgvr.MRR_1_0.Header head = new wrts_prcgvr.MRR_1_0.Header();
        head.requestId = 'test';
        
        wrts_prcgvr.MRR_1_0.Response res = new wrts_prcgvr.MRR_1_0.Response();
        res.objects = objs;
        res.header = head;
		if(arg.DiscardDescription__c.equals('12'))
             res.objects = null;
        
        List<wrts_prcgvr.MRR_1_0.Response> resps = new List<wrts_prcgvr.MRR_1_0.Response>();
        resps.add(res);
        
        wrts_prcgvr.MRR_1_0.MultiResponse response = new wrts_prcgvr.MRR_1_0.MultiResponse();
        response.responses = resps;

        return response;
     }
}