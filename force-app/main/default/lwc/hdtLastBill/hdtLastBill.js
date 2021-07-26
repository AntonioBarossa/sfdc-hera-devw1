import { LightningElement, track,api,wire } from 'lwc';
import imageResource from '@salesforce/resourceUrl/HDT_Service1';
import imageResource2 from '@salesforce/resourceUrl/HDT_Service2';
import getData from '@salesforce/apex/HDT_LC_LastBill.getData';
import { getRecord } from 'lightning/uiRecordApi';
import getDataInContinuation from '@salesforce/apexContinuation/HDT_LC_LastBill.startRequest';
import updateKpiTracking from '@salesforce/apex/HDT_LC_LastBill.updateKpiTracking';

const FIELDS = [
    'Account.CustomerCode__c',
    'Account.KpiTracking__c'
];
export default class HdtLastBill extends LightningElement {

    @track eleUrl = imageResource;
    @track gasUrl = imageResource2;
    @api customerCode;
    @api kpiId;
    @api recordId;
    @track message;
    @track error = false;
    @track amount;
    @track status;
    @track expirationDate;
    @track billNumber;
    @track commodity;
    @track energy = false;
    @track gas = false;
    @track spinner = true;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
    wireAccount({data, error}) {
        if(data) {
            console.log('data ' + data);
            console.log('CC ' + data.fields.CustomerCode__c.value);
            console.log('Kpi ' + data.fields.KpiTracking__c.value);
            getData({
                accountCode: data.fields.CustomerCode__c.value,
                mode: 'KPI',
                kpiId: data.fields.KpiTracking__c.value
            }).then(result => {
                var resultJSON = JSON.parse(result);
                //console.log(result + ' ' + resultJSON);
                console.log('>>>> RESULT ' + result);
                
                if(resultJSON.callws==='true'){
                    resultJSON = this.getDataFromContinuation(data);
                } else {
                    this.setData(resultJSON);
                }
                

            })
            .catch(error => {
                //console.log('errore ' +error.body.message);
                console.log('errore ' + JSON.stringify(error));
                this.error = true;
                this.spinner = false;
                this.message = 'Si è verificato un errore inatteso';
            });
        }else{
            console.log('no data ' + this.recordId);
            //this.spinner = false;
            //this.message = 'Attenzione! Al momento non è possibile visualizzare l\'ultima bolletta del cliente';
        }
    }

    getDataFromContinuation(data){
        getDataInContinuation({
            accountCode: data.fields.CustomerCode__c.value,
            mode: 'KPI',
            kpiId: data.fields.KpiTracking__c.value
        }).then(result => {
            var resultJSON = JSON.parse(result);
            console.log('>>>> RESULT ' + result);
            this.setData(resultJSON);

            if(resultJSON.outcome === 'OK'){
                this.updateKpiTracking(result, data);
            }
        });
    }

    setData(resultJSON){
        if(resultJSON.outcome === 'OK'){
            this.amount = resultJSON.amount;
            this.status = resultJSON.billStatus;
            this.expirationDate = resultJSON.expiredDate;
            this.billNumber = resultJSON.billNumber;
            this.commodity = JSON.parse(resultJSON.commodity);
            console.log(this.commodity);
            console.log(this.amount);
            console.log(this.status);
            console.log(this.expirationDate);
            console.log(this.billNumber);
            this.energy = this.commodity['Energia elettrica'];
            this.gas = this.commodity['Gas'];
            console.log(this.energy);
            this.spinner = false;
        }else{
            this.error = true;
            this.message = resultJSON.message;
            this.spinner = false;
        }
    }

    updateKpiTracking(result, data){
        console.log('>>> UPDATE KpiTracking');
        updateKpiTracking({result, kpiId: data.fields.KpiTracking__c.value}).then(result => {
            console.log('>>> UPDATE RESULT ' + JSON.stringify(result));
        });
    }

}