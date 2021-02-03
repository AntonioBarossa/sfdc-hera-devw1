import { LightningElement, api } from 'lwc';

const columns = [
    { label: 'Label', fieldName: 'name' },
    { label: 'Phone', fieldName: 'phone', type: 'phone' },
    { label: 'Balance', fieldName: 'amount', type: 'currency' },
    { label: 'CloseAt', fieldName: 'closeAt', type: 'date' },
];

export default class HdtViewSapDataTable extends LightningElement {
    data = [];
    columns = columns;
    @api recordId;
    @api type;

    connectedCallback(){
        console.log('# recordId -> ' + this.recordId);
        console.log('# type -> ' + this.type);
        this.restCall();
    }

    restCall(event) {

        console.log('# restCall #');

        fetch(
                'https://monted-dev-ed.my.salesforce.com/services/apexrest/GetSAPfakeData/0',
                {
                // Request type
                method: 'POST',
                body: JSON.stringify({value1: 'x'}),
                headers:{
                    // content type
                    'Content-Type': 'application/json',
                    "Authorization": "Bearer 00D58000000KR1c!AQgAQFRdXqZ_kFTgfNJQFap.98.MCuf.rO5D8zjxpPbre8a5Y1wmjokAMe3R0t9kGPiwWX6mXQ1CR8GDAUYT2msxIL7RRGSB",
                }
        })
        .then((response) => {
            // returning the response in the form of JSON
            console.log('### response.json ');
            return response.json();
        })
        .then((jsonResponse) => {
            console.log('### jsonResponse_status: ' + jsonResponse.status);            
        })
        .catch(error => {

        })
    }

}