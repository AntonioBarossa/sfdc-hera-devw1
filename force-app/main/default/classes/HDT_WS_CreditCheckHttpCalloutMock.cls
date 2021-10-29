/**
 * @author Valere (valere@noeli-it.net)
 * @date 29/09/2021
 * @description HDT_WS_CreditCheck Test Class
 * @history valere - 29/09/2021– Created Class
 */
@isTest
public class HDT_WS_CreditCheckHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(JSON.serialize(
            new Map<String,Object>{
                'status'=>'status',
                'result'=>new Map<String,Object>{
                        'applicationGuid'=>'applicationGuid',
                        'applicationId'=>'applicationId',
                        'identificativoCrm'=>'identificativoCrm',
                        'responseStatus'=>'responseStatus',
                        'errorTimestamp'=>'errorTimestamp'
                },
                'correlationId'=>'correlationId',
                'timestamp'=>'timestamp',
                'data'=>new Map<String,Object>{
                    'testata'=>new Map<String,Object>{
                        'esito'=>'esito',
                        'messaggio'=>'messaggio'
                    },
                    'posizioni'=>new List<Object>{
                        new Map<String,Object>{
                            'campo'=>'campo',
                            'valore'=>'valore'
                        }
                    }
                },
                'errorDetails'=>new List<Object>{
                    new Map<String,Object>{
                        'code'=>'code',
                        'message'=>new Map<String,String>{
                            'message1'=>'message1',
                            'message2'=>'message2'
                        },
                        'additionalInfo'=>'additionalInfo'
                    }
                }

            }
        ));
        response.setStatusCode(200);
        return response; 
    }
}