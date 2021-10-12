import { LightningElement, api } from 'lwc';
import getCompanyCode from '@salesforce/apex/HDT_LC_ComunicationsSearchList.getCompanyCode';
import getWsData from '@salesforce/apex/HDT_LC_ComunicationsSearchList.getWsData';
//import sendFileToPrint from '@salesforce/apex/HDT_LC_ComunicationsSearchList.sendFileToPrint';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const billsColumns = [
    { label: 'Numero bolletta', fieldName: 'envelopeId' },
    { label: 'Data registrazione', fieldName: 'issueDate'}
];

const rateColumns = [
    { label: 'Id Plico', fieldName: 'envelopeId' },
    { label: 'Data registrazione', fieldName: 'issueDate'}
];

const sollecitiColumns = [
    { label: 'Id Plico', fieldName: 'envelopeId' },
    { label: 'Data registrazione', fieldName: 'issueDate'}
];

export default class HdtComunicationsSearchList extends NavigationMixin(LightningElement){

    @api parameters;
    @api businessPartner;
    @api contractAccount;
    @api startDateString;
    @api otherParams;
    @api company;
    modalHeader;
    error = {
        show: false,
        message: ''
    }
    spinner = true;

    data = [];
    columns;
    muleRequest = {
        documentCategory: '',
        businessPartner: '',
        contractAccount: '',
        startDate: '',
        endDate: ''
    };
    docInvoiceObj = {
        billNumber: '',
        channel: '',
        date: '',
        documentType: '',
        company: ''
    };
    recordValue;
    url;
    fileName;
    showFile = false;
    blob;

    connectedCallback(){
        console.log('>>> parameters ' + JSON.stringify(this.parameters));
        console.log('>>> otherParams ' + JSON.stringify(this.otherParams));
        console.log('>>> startDateString ' + JSON.stringify(this.startDateString));

        this.getCompanyCodeService();

        var objParameters = JSON.parse(this.parameters);
        this.modalHeader = objParameters.header;

        var dateArray = this.setDateValue(this.startDateString);
        this.muleRequest.startDate = dateArray[0];
        this.muleRequest.endDate = dateArray[1];

        switch (objParameters.type) {
            case 'bills':
                this.muleRequest.documentCategory = 'Bollette';
                this.muleRequest.businessPartner = this.businessPartner;
                this.muleRequest.contractAccount = this.contractAccount;

                this.columns = billsColumns;
                break;

            case 'rate':
                this.muleRequest.documentCategory = 'Comunicazioni';
                this.muleRequest.businessPartner = this.businessPartner;
                this.muleRequest.contractAccount = this.contractAccount;

                this.columns = rateColumns;
                break;

            case 'solleciti':
                this.muleRequest.documentCategory = 'Solleciti';
                this.muleRequest.businessPartner = this.businessPartner;
                delete this.muleRequest.contractAccount;

                this.columns = sollecitiColumns;
        }

        for(var i in this.otherParams){
            this.muleRequest[i] = this.otherParams[i];
        }

        this.getDataFromWs();

    }

    getCompanyCodeService(){
        console.log('>>> convert this company ' + this.company);

        getCompanyCode({companyName: this.company})
        .then(result => {
            console.log('>>> getCompanyCode ' + result);
            this.docInvoiceObj.company = result;
        }).catch(error => {
            this.error.show = true;
            this.error.message = 'CATCH ERROR MESSAGE';
        });
    }

    setDateValue(inputDate){
        var dateArray = [];
        var dateSplitted = inputDate.split('/');
        var startDate = dateSplitted[2] + '-' + dateSplitted[1] + '-' + dateSplitted[0];

        var date = dateSplitted[1] + '/' + dateSplitted[0] + '/' + dateSplitted[2];
        var resultDate = new Date(date);
        resultDate.setDate(resultDate.getDate() + 10);

        var year = resultDate.getFullYear();
        var currentMonth = resultDate.getMonth() + 1;
        var month = ((currentMonth<10) ? '0' + currentMonth.toString() : currentMonth.toString());
        var day = ((resultDate.getDate()<10) ? '0' + resultDate.getDate().toString() : resultDate.getDate().toString());
        var endDate = year.toString() + '-' + month + '-' + day;
        dateArray.push(startDate);
        dateArray.push(endDate);
        return dateArray;
    }

    getDataFromWs(){
        var muleRequestString = JSON.stringify(this.muleRequest);

        console.log('>>> muleRequest ' + muleRequestString);

        getWsData({wrapperObj: muleRequestString})
        .then(result => {
            //console.log(result);
            var resultObj = JSON.parse(result);
            if(resultObj.success){
                var dataObj = JSON.parse(resultObj.body);

                if(dataObj.status === 'success'){
                    this.data = dataObj.data;
                } else {
                    this.error.show = true;
                    this.error.message = dataObj; 
                }

                this.spinner = false;
            } else {
                var dataObj = JSON.parse(resultObj.body);
                
                if(dataObj.errorDetails[0].code === '102'){

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Attenzione',
                            message: 'Non è stato trovato nessun dato',
                            variant: 'info'
                        }),
                    );

                } else if(dataObj.errorDetails[0].code === '107'){

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Attenzione',
                            message: 'Sono presenti molti dati, riprova restringendo il range delle date',
                            variant: 'info'
                        }),
                    );

                } else {
                    this.error.show = true;
                    this.error.message = 'Codice: ' + dataObj.errorDetails[0].code;
                    this.error.message += '; Messaggio: ' + dataObj.errorDetails[0].message;
                    this.error.message += ' - Informazioni: ' + dataObj.errorDetails[0].additionalInfo; 
                }

                this.spinner = false;
            }
            

        }).catch(error => {
            this.error.show = true;
            this.error.message = 'CATCH ERROR MESSAGE';
        });
    }

    onChangeHandler(event){
        console.log('>>> set ' + event.currentTarget.name + ' = ' + event.detail.value);
        this.muleRequest[event.currentTarget.name] = event.detail.value;
    }

    interrogation(event){
        try{

            console.log('>>> ' + JSON.stringify(this.muleRequest));

            if(this.muleRequest.startDate === undefined || this.muleRequest.startDate === null || this.muleRequest.startDate === '' || 
               this.muleRequest.endDate === undefined || this.muleRequest.endDate === null || this.muleRequest.endDate === ''){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'Questi due valori sono obbligatori!',
                        variant: 'warning'
                    }),
                );
                return;
            }

            this.spinner = true;
            this.data = [];
            this.getDataFromWs();
        } catch(ex){
            console.log(ex);
        }
    }

    //getSelectedRow(event) {
    //    const selectedRow = event.detail.selectedRows;
    //    console.log('>>> SELECTION: ' + selectedRow[0].billNumber);
    //    this.recordValue = selectedRow[0].billNumber;
    //}

    apply(event){
        
        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();
        console.log('>>> I WANT PDF ABOUT > ' + JSON.stringify(selected));

        if(selected.length === 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: 'Non hai selezionato nulla',
                    variant: 'warning'
                }),
            );
            return;
        }

        this.docInvoiceObj.billNumber = selected[0].envelopeId.replace(/^0+/, '');
        this.docInvoiceObj.channel = 'CRM';

        const date = selected[0].issueDate.split(" ");

        this.docInvoiceObj.date = date[0];
        this.docInvoiceObj.documentType = this.muleRequest.documentCategory;

        this.sendToApex(JSON.stringify(this.docInvoiceObj));
    }

    sendToApex(bodyString){
        console.log('# closeModal #');
        console.log('>>> BODY > ' + bodyString);
        const sendToApex = new CustomEvent("printpdf", {
            detail: {obj: bodyString}
        });

        // Dispatches the event.
        this.dispatchEvent(sendToApex);
    }

    closeModal(event){
        console.log('# closeModal #');
        const closeEvent = new CustomEvent("closemodal", {
            detail: {booleanVar: 'showBillList'}
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

}