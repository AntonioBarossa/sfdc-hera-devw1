@istest
global class HDT_QBL_SIE34CallServiceMck implements HttpCalloutMock{ 
    global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');
    response.setBody(JSON.serialize(
    new Map<String,Object>{
        'status'=>'status',
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
                'message'=>'message',
                'additionalInfo'=>'additionalInfo'
            }
        }

    }
));

    response.setStatusCode(200);
    return response; 
}
    
}