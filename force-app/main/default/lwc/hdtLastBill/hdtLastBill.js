import { LightningElement, track,api,wire } from 'lwc';
import imageResource from '@salesforce/resourceUrl/HDT_Service1';
import imageResource2 from '@salesforce/resourceUrl/HDT_Service2';
import imageResource3 from '@salesforce/resourceUrl/HDT_Service3';
import imageResource4 from '@salesforce/resourceUrl/HDT_Service4';
import getData from '@salesforce/apex/HDT_LC_LastBill.getData';
import { getRecord } from 'lightning/uiRecordApi';
import getDataInContinuation from '@salesforce/apexContinuation/HDT_LC_LastBill.startRequest';
import updateKpiTracking from '@salesforce/apex/HDT_LC_LastBill.updateKpiTracking';
import getLastBillData from '@salesforce/apex/HDT_LC_LastBill.getLastBillDataFromSap';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


const FIELDS = [
    'Account.CustomerCode__c',
    'Account.KpiTracking__c'
];
export default class HdtLastBill extends LightningElement {

    @track eleUrl = imageResource;
    @track gasUrl = imageResource2;
    @track acquaUrl = imageResource3;
    @track ambienteUrl = imageResource4;
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
    @track acqua = false;
    @track ambiente = false;
    @track spinner = true;
    pdfSpinner = false;
    customerAccountCode;

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
                
                this.customerAccountCode = data.fields.CustomerCode__c.value;

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

            console.log('>>> commodity: ' + this.commodity);
            console.log('>>> amount: ' + this.amount);
            console.log('>>> status: ' + this.status);
            console.log('>>> expirationDate: ' + this.expirationDate);
            console.log('>>> billNumber: ' + this.billNumber);

            this.energy = this.commodity['Energia elettrica'];
            this.gas = this.commodity['Gas'];
            this.acqua = this.commodity['Acqua'];
            this.ambiente = this.commodity['Ambiente'];
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

    getLastBillData(){
        getLastBillData({accountCode: this.customerAccountCode})
        .then(result => {
            console.log('>>>> RESULT ' + result);
            if(result){
                var obj = JSON.parse(result);
                this.sendPrint(obj);
            } else {
                this.pdfSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione!',
                        message: 'Bolletta non disponibile',
                        variant: 'warning'
                    }),
                );
            }

        });
    }

    openFile(){
        console.log('>>> visualbolletta - showSingleBill');

        if(this.message){
            return;
        }

        this.pdfSpinner = true;
        this.getLastBillData();

        //const date = selected.dataEmissione.split("/");

        //var docInvoiceObj = {
        //    billNumber: this.billNumber.replace(/^0+/, ''),
        //    channel: 'SOL',
        //    date: '2021-09-17',//date[2] + '-' + date[1] + '-' + date[0],
        //    type: 'Bolletta',
        //    company: '1070'--->selected.societa
        //}

        //test mock
        //var docInvoiceObj = {
        //    billNumber: '411911206203',
        //    channel: 'SOL',
        //    date: '2019-11-29',
        //    type: 'D66l7V',
        //    company: '1070'
        //}

        //this.sendPrint(docInvoiceObj);
    }

    sendPrint(docInvoice){
        this.template.querySelector("c-hdt-pdf-viewer-handler").sendPrintFromParent(JSON.stringify(docInvoice));
    }

    downloadComplete(){
        this.pdfSpinner = false;
    }

}